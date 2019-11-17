#! perl

use v5.24;
use strict;
use warnings;
use utf8;
use Carp;

package TouchOSC::Import;

use MIME::Base64 qw(decode_base64);

sub parsefile {
    my ( $pkg, %atts ) = @_;
    my $file = $atts{file};

    my $document;
    if ( $file =~ /\.touchosc$/i ) {
	require Archive::Zip;
	my $zip = Archive::Zip->new;
	die unless $zip->read($file) == 0;
	my $member = $zip->memberNamed("index.xml");
	$document = $member->contents;
    }
    elsif ( $file =~ /\.xml$/ ) {
	open( my $xmlfile, '<:utf8', $file );
	$document = do { local $/; <$xmlfile> };
	close($xmlfile);
    }
    unless ( $document ) {
	croak("Don't know how to load $file");
    }

    # The TouchOSC XML is dead simple and can easily be represented
    # as a perl structure.

    $document =~ s/^<\?xml.*?>\s*//;
    croak("Invalid document (no <layout>)")
      unless $document =~ m;^\s*<layout\s+(.*?)>\s*(.*)</layout>;s;
    my $atts = $1;
    my $content = $2;

    my $layout = _parseatts($atts);
    $layout->{_pages} = [];
    $layout->{grid} = 1;

    #### TODO: w / h fiddling.
    @{$layout}{qw(w h)} = @{$layout}{qw(h w)};
    my $o = delete($layout->{orientation}) eq "horizontal";
    my $need_decode;

    while ( $content =~ m;<tabpage\s+(.*?)>\s*(.*)</tabpage>;gs ) {
	my $page = _parseatts($1);
	$page->{_controls} = [];
	my $content = $2;

	# Try to auto-sense whether base64 decoding is needed.
	unless ( defined $need_decode ) {
	    $need_decode = decode_base64($page->{name}) =~ /^\w+$/;
	}
	for ( qw( name la_t li_t ) ) {
	    next unless $page->{$_};
	    $page->{$_} = decode_base64($page->{$_})
	      if $need_decode;
	}

	$content =~ s;>\s*</control>;/>;g;
	while ( $content =~ m;<control\s+(.*?)/>;gs ) {
	    my $ctrl = _parseatts($1);
	    for ( qw( name osc_cs text ) ) {
		next unless $ctrl->{$_};
		$ctrl->{$_} = decode_base64($ctrl->{$_})
		  if $need_decode;
	    }
	    if ( $ctrl->{type} =~ /^(fader|label|rotary)([hv])/ ) {
		$ctrl->{type} = $1;
		$ctrl->{rotate} = $2 eq "h";
		delete($ctrl->{centered}) if $ctrl->{type} eq "label";
	    }

	    #### TODO: x / y fiddling.
	    if ( $o ) {
	    }
	    else {
		@{$ctrl}{qw(h w)} = @{$ctrl}{qw(w h)};
		$ctrl->{x} = $layout->{h} - $ctrl->{x} - 40 - $ctrl->{h};
		@{$ctrl}{qw(x y)} = @{$ctrl}{qw(y x)};
	    }
	    push( @{ $page->{_controls} }, $ctrl );
	    if ( 0 && $ctrl->{type} eq 'toggle' ) {
		warn($ctrl->{name},
		     ": x=", $ctrl->{x}, ", y=", $ctrl->{y},
		     ", w=", $ctrl->{w}, ", h=", $ctrl->{h},
		     " (W=", $layout->{w}, ", H=", $layout->{h}, ", O=$o)",
		     "\n");
	    }
	}
	push( @{ $layout->{_pages} }, $page );
    }

    return $layout;
}

sub _parseatts {
    my ( $atts ) = @_;

    my %atts;
    while ( $atts =~ /(\w+)\s*=\s*(["'])(.*?)\2\s*/g ) {
	$atts{$1} = $3;
    }

    return \%atts;
}

1;
