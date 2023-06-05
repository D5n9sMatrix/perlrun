#!/usr/bin/env perl

# The examples above use a relative path to the perl interpreter, getting whatever version is first in the user's path. If you want a specific version of Perl, say, perl5.14.1, you should place that directly in the #! line's path.

# If the #! line does not contain the word "perl" nor the word "indir", the program named after the #! is executed instead of the Perl interpreter. This is slightly bizarre, but it helps people on machines that don't do #!, because they can tell a program that their SHELL is /usr/bin/perl, and Perl will then dispatch the program to the correct interpreter for them.

# After locating your program, Perl compiles the entire program to an internal form. If there are any compilation errors, execution of the program is not attempted. (This is unlike the typical shell script, which might run part-way through before finding a syntax error.)

# If the program is syntactically correct, it is executed. If the program runs off the end without hitting an exit() or die() operator, an implicit exit(0) is provided to indicate successful completion.
#! and quoting on non-Unix systems

# Unix's #! technique can be simulated on other systems:

# OS/2
