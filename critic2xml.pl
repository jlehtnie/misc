#!/usr/bin/env perl

use warnings;
use strict;
use XML::Simple qw(XMLout);

my %files;

# TODO: get data directly from Perl::Critic
while (<>) {
    my ($fname, $line, $col, $sev, $msg, $src) = split("\0", $_, 6);
    push @{$files{$fname}}, { 
        line => $line,
        column => $col,
        severity => $sev,
        message => $msg,
        source => $src
    };
}

@_ = map { { name => $_, error => $files{$_} }  } sort { $a<=>$b } keys %files;

# TODO: version attribute to root element
print XMLout({ file => \@_ }, RootName => checkstyle );
