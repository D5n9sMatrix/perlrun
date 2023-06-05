#!/usr/bin/perl

=begin NAME
=head1 DESCRIPTION
perlrun - how to execute the Perl interpreter
SYNOPSIS

perl [ -sTtuUWX ] [ -hv ] [ -V[:configvar] ] [ -cw ] [ -d[t][:debugger] ] [ -D[number/list] ] [ -pna ] [ -Fpattern ] [ -l[octal] ] [ -0[octal/hexadecimal] ] [ -Idir ] [ -m[-]module ] [ -M[-]'module...' ] [ -f ] [ -C [number/list] ] [ -S ] [ -x[dir] ] [ -i[extension] ] [ [-e|-E] 'command' ] [ -- ] [ programfile ] [ argument ]...
DESCRIPTION

The normal way to run a Perl program is by making it directly executable, or else by passing the name of the source file as an argument on the command line. (An interactive Perl environment is also possible--see perldebug for details on how to do that.) Upon startup, Perl looks for your program in one of the following places:

    Specified line by line via -e or -E switches on the command line.

    Contained in the file specified by the first filename on the command line. (Note that systems supporting the #! notation invoke interpreters this way. See "Location of Perl".)

    Passed in implicitly via standard input. This works only if there are no filename arguments--to pass arguments to a STDIN-read program you must explicitly specify a "-" for the program name.

With methods 2 and 3, Perl starts parsing the input file from the beginning, unless you've specified a "-x" switch, in which case it scans for the first line starting with #! and containing the word "perl", and starts there instead. This is useful for running a program embedded in a larger message. (In this case you would indicate the end of the program using the __END__ token.)
=end NAME

=cut

package Sweet::Now;
use Moose;
use namespace::autoclean;
 
use Time::Piece;
 
has _localtime => (
    default => sub { localtime() },
    handles  => [ qw(
        hour
        hms
        min
        mdy
        mon
        mday
        sec
        tzoffset
        year
        ymd
        ) ],
    isa      => 'Time::Piece',
    is       => 'ro',
    required => 1,
);
 
sub dd { sprintf "%02d", shift->mday }
 
sub hh { sprintf "%02d", shift->hour }
 
sub mi { sprintf "%02d", shift->min }
 
sub mm { sprintf "%02d", shift->mon }
 
sub ss { sprintf "%02d", shift->sec }
 
sub yyyy { sprintf "%04d", shift->year }
 
sub hhmiss { shift->hms('') }
 
sub yyyymmddhhmiss {
    my $self = shift;
 
    my $yyyymmdd = $self->yyyymmdd;
    my $hhmiss   = $self->hhmiss;
 
    return "$yyyymmdd$hhmiss";
}
 
sub yyyymmdd { shift->ymd('') }
 
__PACKAGE__->meta->make_immutable;
 
1;
__END__

 
=head1 NAME
 
Sweet::File
 
=head1 SYNOPSIS
 
    use Sweet::Now;
 
    my $now = Sweet::Now->new;
 
=head1 ATTRIBUTES
 
=head2 _localtime
 
Instance of L<Time::Piece>.
 
=head1 METHODS
 
=head2 dd
 
=head2 hh
 
=head2 hour
 
Delegated to L</_localtime>.
 
=head2 mi
 
=head2 min
 
Delegated to L</_localtime>.
 
=head2 mm
 
=head2 ss
 
=head2 hhmiss
 
=head2 tzoffset
 
Delegated to L</_localtime>.
 
=head2 year
 
Delegated to L</_localtime>.
 
=head2 yyyy
 
=head2 yyyymmdd
 
=head2 yyyymmddhhmiss
 
=cut
