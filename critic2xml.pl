#!/usr/bin/env perl

use warnings;
use strict;
use XML::Simple qw(XMLout);
use Perl::Critic qw();
use Perl::Critic::Violation qw();
use Perl::Critic::Utils;
use Carp qw(croak);
use MCE::Map;

# TODO: critic args handling
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


my %files;
my @violations = critic_files_or_dirs(@ARGV);

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

# TODO: version attribute to root element
print XMLout({ file => \@_ }, RootName => 'checkstyle' );
