#!/usr/bin/env perl

use warnings;
use strict;
use XML::Simple qw(XMLout);
use Perl::Critic qw();
use Perl::Critic::Violation qw();
use Perl::Critic::Utils qw();
use Carp qw(croak);
use MCE::Map;

my %CRITIC_ARGS = ();

sub critic_file {
    my ( $file ) = @_;
    croak q{no file specified} if not defined $file;
    croak qq{"$file" does not exist} if not -f $file;

    my $critic = undef;
    my @violations = ();

    $critic = Perl::Critic->new( %CRITIC_ARGS );
    @violations = $critic->critique( $file );

    my $verbose = $critic->config->verbose();
    Perl::Critic::Violation::set_format( $verbose );
    for (@violations) { print }
    return @violations;
}

sub critic_files_or_dirs {
    my @files = Perl::Critic::Utils::all_perl_files(@_);
    croak "Nothing to critique" if not @files;
    mce_map { critic_file($_) } @files;
}

unless (@ARGV >= 3) {
    print "usage: $0 ouput-file [ -critic-opt=value ] -- inputs\n";
    exit 1;
}

my $output = shift @ARGV;

while (@ARGV) {
    $_ = shift;
    if ($_ eq "--") { last };
    my ($opt, $arg);
    if (/^-/) {
        if (/=/) {
            ($opt, $arg) = split /=/;
            $CRITIC_ARGS{$opt} = $arg;
        }
        else {
            $CRITIC_ARGS{$opt} = 1;
        }
    }
}

my @violations = critic_files_or_dirs(@ARGV);
my %files;

for (@violations) {
    push @{$files{$_->filename()}}, { 
        line => $_->line_number(),
        column => $_->column_number(),
        severity => $_->severity(),
        message => $_->description(),
        source => $_->explanation()
    };
}

@_ = map { { name => $_, error => $files{$_} }  } sort { $a cmp $b } keys %files;

open my $out, ">", $output;
print $out "<?xml version='1.0' encoding='UTF-8'?>\n";
print $out "<checkstyle version='4.3'>\n";
print $out XMLout({ file => \@_ }, RootName => undef );
print $out "</checkstyle>\n";
close $out;
