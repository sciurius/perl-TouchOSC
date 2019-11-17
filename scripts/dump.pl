#!/usr/bin/perl -w

# Author          : Johan Vromans
# Created On      : Fri Nov 15 13:59:52 2019
# Last Modified By: Johan Vromans
# Last Modified On: Sun Nov 17 15:42:41 2019
# Update Count    : 8
# Status          : Unknown, Use with caution!

################ Common stuff ################

use v5.24;
use strict;
use warnings;
use utf8;

# Package name.
my $my_package = 'TouchOSCTools';
# Program name and version.
my ($my_name, $my_version) = qw( dump 0.03 );

################ Command line parameters ################

use Getopt::Long 2.13;

# Command line options.
my $pdf;			# generate pdf
my $verbose = 1;		# verbose processing

# Development options (not shown with -help).
my $debug = 0;			# debugging
my $trace = 0;			# trace (show process)
my $test = 0;			# test mode.

# Process command line options.
app_options();

# Post-processing.
$trace |= ($debug || $test);

################ Presets ################

use FindBin;
use lib $FindBin::Bin . "/../lib";

################ The Process ################

use TouchOSC;

my $file = shift;

# Load the data.
my $layout = TouchOSC->load( file => $file );

my $did;

# Generate PDF sketch if requested.
if ( $pdf ) {
    $layout->save_pdf( file => $pdf);
    $did++;
}

# Dump to standard output, with strings unencoded.
unless ( $did ) {
    no warnings 'redefine';
    *TouchOSC::Common::fmt_string = sub{$_[1]};
    print $layout->as_string;
}

################ Subroutines ################

sub app_options {
    my $help = 0;		# handled locally
    my $ident = 0;		# handled locally
    my $man = 0;		# handled locally

    my $pod2usage = sub {
        # Load Pod::Usage only if needed.
        require Pod::Usage;
        Pod::Usage->import;
        &pod2usage;
    };

    # Process options.
    if ( @ARGV > 0 ) {
	GetOptions('pdf=s'	=> \$pdf,
		   'ident'	=> \$ident,
		   'verbose+'	=> \$verbose,
		   'quiet'	=> sub { $verbose = 0 },
		   'trace'	=> \$trace,
		   'help|?'	=> \$help,
		   'man'	=> \$man,
		   'debug'	=> \$debug)
	  or $pod2usage->(2);
    }
    if ( $ident or $help or $man ) {
	print STDERR ("This is $my_package [$my_name $my_version]\n");
    }
    if ( $man or $help ) {
	$pod2usage->(1) if $help;
	$pod2usage->(VERBOSE => 2) if $man;
    }

    # One argument required.
    $pod2usage->(2) unless @ARGV == 1;
}

__END__

################ Documentation ################

=head1 NAME

dump - show content of TouchOSC layout

=head1 SYNOPSIS

dump [options] file

 Options:
   --pdf=XXX		generates a PDF with image
   --ident		shows identification
   --help		shows a brief help message and exits
   --man                shows full documentation and exits
   --verbose		provides more verbose information
   --quiet		runs as silently as possible

=head1 OPTIONS

=over 8

=item B<--pdf=>I<XXX>

Generates a PDF document showing an image the content of the layout.
Note that the image is for design purposes only and is B<not> how it
looks on the tablet.

=item B<--help>

Prints a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=item B<--ident>

Prints program identification.

=item B<--verbose>

Provides more verbose information.
This option may be repeated to increase verbosity.

=item B<--quiet>

Suppresses all non-essential information.

=item I<file>

The input file to process. This can be a TouchOSC layout, e.g.
C<24channel-1fader-tab.layout>, or an XML document extracted from a
TouchOSC layout.

=back

=head1 DESCRIPTION

B<This program> will read the given input file and print the content
to standard output in the form of an XML document.

With B<--pdf> option, generates a PDF document containing a visual
representation of the layput.

=cut

