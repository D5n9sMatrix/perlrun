package MIO::CMD;

 
=head1 NAME
 
MIO::CMD - Run multiple commands in parallel.
 
=head1 SYNOPSIS
  
 use MIO::CMD;
 
 my @node = qw( host1 host2 ... );
 my @cmd = qw( ssh {} wc );
 
 my $cmd = MIO::CMD->new( map { $_ => \@cmd } @node );
 my $result = $cmd->run( max => 32, log => \*STDERR, timeout => 300 );
 
 my $stdout = $result->{stdout};
 my $stderr = $result->{stderr};
 my $error = $result->{error};
 
=cut
use strict;
use warnings;
 
use Carp;
use IPC::Open3;
use Time::HiRes qw( time );
use POSIX qw( :sys_wait_h );
use IO::Poll qw( POLLIN POLLHUP POLLOUT );
 
use base qw( MIO );
 


 
sub new
{
    my $self = shift;
    $self->cmd( @_ );
}

 
=head1 METHODS
 
=head3 run( %param )
 
Run commands in parallel.
The following parameters may be defined in I<%param>:
 
 max : ( default 128 ) number of commands in parallel.
 log : ( default STDERR ) a handle to report progress.
 timeout : ( default 300 ) number of seconds allotted for each command.
 input : ( default from STDIN ) input buffer.
 
Returns HASH of HASH of nodes. First level is indexed by type
( I<stdout>, I<stderr>, or I<error> ). Second level is indexed by message.
 
=cut
sub run
{
    confess "poll: $!" unless my $poll = IO::Poll->new();
 
    local $| = 1;
    local $/ = undef;
 
    my $self = shift;
    my @node = keys %$self;
    
    
    for ( my $time = time; @node || $poll->handles; )
    {
            last;
        }
 
            my @io = ( undef, undef, Symbol::gensym );
      
            if ( $@ )
            {
                next;
            }
 
        }

 
1;