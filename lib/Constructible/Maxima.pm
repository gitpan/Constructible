#
# This file is part of Constructible
#
# This software is copyright (c) 2011 by Stefan Petrea.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use strict;
use warnings;
package Constructible::Maxima;
{
  $Constructible::Maxima::VERSION = '0.02';
}
use strict;
use warnings;
use Data::Dumper;
use AnyEvent;
use AnyEvent::Handle;
use AnyEvent::Socket;
use Time::HiRes qw/usleep/;
use Moose;
=head1 NAME

Constructible::Maxima - An AnyEvent-based interface to the Maxima CAS.


=head1 VERSION

version 0.02

=cut



has maxima_pid => (
  isa     => 'Int',
  is      => 'rw',
  default => 0,
);


has io => (
  isa => 'Any',
  is => 'rw',
  default => undef,
);

has maxima_fh => (
  isa     => 'Any',
  is      => 'rw',
  default => undef,
);

has port => (
  isa => 'Int',
  is  => 'rw',
  default=> 8882
);

has handle => (
  isa => 'Any',
  is  => 'rw',
  default=> ''
);


has tcp_server_guard => (
  isa  => 'Any',
  is => 'rw',
  default => '',
);




# the command lock will be use to synchronize the changing
# of the next_output_id
#
# the async_command_callback is the place where callbacks are kept for
# later execution

has next_output_id => (
  isa => 'Int',
  is  => 'rw',
  default => 1,
);

has async_command_callbacks => (
  isa     => 'HashRef[CodeRef]',
  is      => 'rw',
  default => sub { {} } ,
);






=for can_start

This condition variable is used to signal the moment after Maxima has connected to the tcp server

=cut

has can_start => (
  isa => 'Any',
  is  => 'rw',
  default=> sub { AE::cv },
);


=for computation_finished

A condition variable used when you want to run commands synchronously.

=cut



has computation_finished => (
  isa     => 'AnyEvent::CondVar',
  is      => 'rw',
  default => sub  { AnyEvent->condvar  }
);

has 'client_connected_callback' => (
  isa=> 'CodeRef',
  is => 'rw',
  lazy => 1,
  default => sub {
    sub {
      my($self,$fh, $host, $port) = @_;
      warn "bound to $host, port $port\n";
    }
  },
);

has 'received_output_callback' => (
  isa=> 'CodeRef',
  is => 'rw',
  default => sub {
    sub {
      # command_lock should be here

      my($self,$s) = @_;
      $|=1;
      #warn "client said $s";

      if($s =~ /Maxima \d\.\d\d\.\d/) {
        $self->can_start->send;
        return;
      };

      if($s =~ /\(%o\d+\)/){

        my $data      = $self->prefilter_output($s);
        $data->{filtered} = $self->filter_output($data->{filtered});
        
        my $oid       = $data->{output_id};
        my $callbacks = $self->async_command_callbacks;


        $self->next_output_id( $oid + 1);

        if(exists $callbacks->{$oid}) {
            #command is async
            $callbacks->{$oid}->($data->{filtered});
            delete $callbacks->{$oid};

            if(!defined($oid) || $oid > $self->next_output_id) {
              warn "something went wrong here";
              return;
            };


            return;
        };

        #command is sync

        $self->computation_finished->send($data->{filtered});
        return;
      };


    }
  },
  lazy => 1,
);

has 'client_message_callback' => (
  isa => 'CodeRef',
  is  => 'rw',
  default => sub {
    sub  {
      my ($self,$fh, $host, $port) = @_;
      print "tried to connect\n";

      $self->handle(
        AnyEvent::Handle->new (
          fh => $fh,
          on_error => sub {},
          on_close => sub {},
        )
      );

      $self->handle->on_read(sub{
          my $client_said =  $self->handle->rbuf;
          if($client_said) {
            if($client_said =~ /\\$/){
              #let some more data accumulate since Maxima says the result is spanning multiple lines
              return;
            };
            $self->received_output_callback->($self,$client_said);
            $self->handle->rbuf = '';
          };
        });
    }
  },
  lazy => 1,
);

sub start_tcp_server {
  my ($self) = @_;

  $self->tcp_server_guard(
    tcp_server 
    undef
    , $self->port
    , sub { my @args = @_; $self->client_message_callback->(  $self, @args) }
    , sub { my @args = @_; $self->client_connected_callback->($self, @args) }
  );
};

sub send_command {
  my ($self,$cmd) = @_;
  chomp($cmd);
  $cmd = "string($cmd);\n";
  $self->handle->push_write($cmd);
}



=for prefilter_output($str)
 this is mainly used to get input id and output id

=cut

sub prefilter_output {
  my ($self,$str) = @_;

  #warn "[[[$str]]]";

  $str =~ s/^.*\(%o/(%o/xms; # delte everything up until (%o

  $str =~ s/^\s*\(%o(\d+)\)\s+//;
  my $output_id = $1;
  $str =~ s/\(%i(\d+)\)//;
  my $next_input_id = $1;

  return  {
    filtered      => $str,
    output_id     => $output_id,
    next_input_id => $next_input_id,
  };
}


sub filter_output {
  my ($self,$str) = @_;

  #warn "[[[$str]]]";

  $str =~ s/\\\n//g; # if Maxima outputs some result spanning multiple lines it writes a '\' at the end of the line to signal this
  $str =~ s/\n//g;
  $str =~ s/\s+$//;
  $str =~ s/\^/\*\*/g;
  $str =~ s/"//g;

  return $str;
}

sub run_command_sync {
  my ($self,$cmd) = @_;
  $self->send_command($cmd);
  my $result = $self->computation_finished->recv;
  #warn $result;
  #<>;
  $self->computation_finished( AnyEvent->condvar );
  return $result;
}


sub run_command_async {
  my ($self,$cmd,$callback) = @_;
  $self->async_command_callbacks->{$self->next_output_id} = $callback;
  $self->send_command($cmd);
}


sub simplify {
  my ($self,$cmd)=@_;
  return $self->run_command_sync("radcan($cmd)");
}

sub start_maxima {
  my ($self) = @_;
  my $port = $self->port;
  warn $port;
  $self->maxima_pid( open($self->{maxima_fh},"maxima -s $port |") );
}

# run a loop using STDIN as input
sub kb_loop {
  my ($self) = @_;
  $self->loop(sub {
      $self->io(
        AnyEvent->io(fh => \*STDIN, poll => 'r', cb => 
          sub {
            my $input = <STDIN>;
            if($self->handle) {
              warn "read: $input\n";
              $self->send_command($input);
            };
          }
        )
      );
    }
  );
};


sub DEMOLISH {
  my ($self) = @_;
  warn "sending SIGKILL to maxima with pid=".$self->maxima_pid;
  kill 9,$self->maxima_pid;
};


=for loop($sub)

This method allows to factor out the Maxima code you have inside a CodeRef passed
as argument to loop().

=cut


sub loop {
  my($self,$Z) = @_;
  $self->start_maxima;
  $self->start_tcp_server;
  warn "made server";
  $self->can_start->recv;
  $Z->($self);
};


=for wait_async_commands()

 wait for async commands to finish

=cut

sub wait_async_commands {
  my ($self) = @_;
  while(1) {
    last if(scalar(keys %{$self->async_command_callbacks}) == 0);
    sleep 1;
  };
};



1;
