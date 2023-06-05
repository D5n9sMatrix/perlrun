#!/usr/bin/perl

=begin NAME
=head1 DESCRIPTION

The #! line is always examined for switches as the line is being parsed. Thus, if you're on a machine that allows only one argument with the #! line, or worse, doesn't even recognize the #! line, you still can get consistent switch behaviour regardless of how Perl was invoked, even if "-x" was used to find the beginning of the program.

Because historically some operating systems silently chopped off kernel interpretation of the #! line after 32 characters, some switches may be passed in on the command line, and some may not; you could even get a "-" without its letter, if you're not careful. You probably want to make sure that all your switches fall either before or after that 32-character boundary. Most switches don't actually care if they're processed redundantly, but getting a "-" instead of a complete switch could cause Perl to try to execute standard input instead of your program. And a partial -I switch could also cause odd results.

Some switches do care if they are processed twice, for instance combinations of -l and -0. Either put all the switches after the 32-character boundary (if applicable), or replace the use of -0digits by BEGIN{ $/ = "\0digits"; }.

Parsing of the #! switches starts wherever "perl" is mentioned in the line. The sequences "-*" and "- " are specifically ignored so that you could, if you were so inclined, say

=end NAME

=cut