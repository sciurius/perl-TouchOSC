#! perl

use v5.24;
use strict;
use warnings;
use utf8;

package TouchOSC;

=head1 NAME

TouchOSC - Generate and/or print TouchOSC layouts.

=head1 SUMMARY

    my $layout = TouchOSC->new( height => 800, width => 1280, grid => 20 );
    my $page = $layout->add_page( title => "Tracks 1-24" );
    # Note: All dimensions are in grid units!
    $page->add_control( name => "track1", type => 'label',
			x => 2, y => 2, w => 5, h => 2,
			color => 'green',
			background => 'true',
			size => 22,
			osc_cs => '/strip/name/1',
		      );
    $layout->save( file => "test.touchosc" );

=head1 ABSTRACT

This toolkit provides a set of modules to read, generate and print
TouchOSC layouts.

For TouchOSC, see L<https://hexler.net/products/touchosc>.

=cut

use Carp;
use TouchOSC::Page;
our @CARP_NOT = qw( TouchOSC::Page );

use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

our $VERSION = "0.02";

sub new {
    my ( $pkg, %init ) = @_;

    my $self = { _pages => [] };

    # Mode:
    #  0: iPhone   320 x  480 horizontal
    #  1: iPad     768 x 1024 horizontal
    #  2: iPhone5  320 x  568 horizontal
    $self->{mode} = 3;		# custom

    # Note the editor displays the layout 90⁰ rotated.
    if ( $init{width} && $init{height} ) {
	if ( $init{width} > $init{height} ) {
	    $self->{w} = delete($init{height});
	    $self->{h} = delete($init{width});
	    $self->{orientation} = 'vertical';
	}
	else {
	    $self->{h} = delete($init{height});
	    $self->{w} = delete($init{width});
	    $self->{orientation} = 'horizontal';
	}
    }
    else {
	# This is the most practical way to get 1280x800 tablet...
	$self->{w} = 800;
	$self->{h} = 1280;
	$self->{orientation} = 'vertical';
    }

    $self->{version} = delete($init{version}) || 17;

    $self->{_grid}   = delete($init{grid})    || 10;
    $self->{_pages} = [];

    if ( %init ) {
	carp("$pkg: Unknown attribute \"$_\"")
	  for sort keys %init;
	croak("$pkg: Aborted");
    }

    bless $self => $pkg;
}

sub add_page {
    my $self = shift;

    my $page;
    if ( @_ == 1 && UNIVERSAL::isa( $_[0], 'TouchOSC::Page' ) ) {
	$page = shift;
    }
    else {
	$page = TouchOSC::Page->new( parent => $self, @_ );
    }
    push( $self->{_pages}->@*, $page );

    return $page;
}

################ Persistency ################

#### TouchOSC native (zip with indexxml).

sub save {
    my ( $self, %args ) = @_;
    require Archive::Zip;
    my $file = $args{file} || $self->{_file} || "__layout.touchosc";
    my $z = Archive::Zip->new;
    my $m = $z->addString( $self->as_string, "index.xml" );
    $m->desiredCompressionMethod( Archive::Zip::COMPRESSION_DEFLATED() );
    die unless $z->writeToFileNamed($file) == 0;
}

sub as_string {
    my ( $self, %opts ) = @_;
    my $res = qq{<?xml version="1.0" encoding="UTF-8"?>\n};
    $res .= qq{<layout};
    for ( qw( w h mode orientation version ) ) {
	$res .= " $_='" . $self->{$_} . "'";
    }
    $res .= qq{>\n};

    foreach ( $self->{_pages}->@* ) {
	$res .= $_->as_string( %opts, indent => 1 );
    }

    $res .= qq{</layout>\n};
    return $res;
}

sub load {
    my ( $self, %args ) = @_;
    my $file = $args{file} || $self->{_file};
    die("Missing filename in load\n") unless $file;

    require TouchOSC::Import;
    my $s = TouchOSC::Import->parsefile( file => $file );

    my %atts;
    $atts{$_} = $s->{$_} for qw( w h mode orientation version );

    if ( $atts{mode} == 0 ) {
	$atts{w} = 320;
	$atts{h} = 480;
    }
    elsif ( $atts{mode} == 1 ) {
	$atts{w} = 768;
	$atts{h} = 1024;
    }
    elsif ( $atts{mode} == 2 ) {
	$atts{w} = 320;
	$atts{h} = 568;
    }
    delete($atts{mode});
    delete($atts{orientation});
    $atts{width} = delete($atts{w});
    $atts{height} = delete($atts{h});

    my $layout = TouchOSC->new( %atts, grid=>1 );

    foreach ( $s->{_pages}->@* ) {
	$layout->add_page( TouchOSC::Page->load( parent => $layout, data => $_ ) );
    }

    return $layout;
}

#### PDF Image (for development)

sub save_pdf {
    my ( $self, %args ) = @_;
    require Cairo;
    my $file = $args{file} || $self->{_file} || "__layout.pdf";
    my $o = $self->{orientation} eq 'vertical';
    my $h = $o ? $self->{h} : $self->{w};
    my $w = $o ? $self->{w} : $self->{h};
    my $surface = Cairo::PdfSurface->create ( $file, $h, $w );
    my $cr = Cairo::Context->create ($surface);
    $cr->select_font_face ('sans', 'normal', 'normal');
    $cr->rectangle( 0, 0, $h, $w );
    $cr->set_source_rgba( TouchOSC::Control->cairo_colour("black")->@* );
    $cr->fill;
    $self->as_cairo($cr);
}

sub as_cairo {
    my ( $self, $cr ) = @_;
    foreach ( $self->{_pages}->@* ) {
	$_->as_cairo($cr);
    }
}

=head1 LICENSE

Copyright (C) 2019, Johan Vromans

This module is free software. You can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

This program is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut

1;
