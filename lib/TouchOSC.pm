#! perl

use v5.24;
use strict;
use warnings;
use utf8;

package TouchOSC;

use Carp;
use TouchOSC::Page;
our @CARP_NOT = qw( TouchOSC::Page );

use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

our $VERSION = "0.01";

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

sub save {
    my ( $self, %args ) = @_;
    my $zip = $args{file} || $self->{_file};
    my $z = Archive::Zip->new;
    my $m = $z->addString( $self->as_string, "index.xml" );
    $m->desiredCompressionMethod( COMPRESSION_DEFLATED );
    die unless $z->writeToFileNamed($zip) == 0;
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


=head1 LICENSE

Copyright (C) 2019, Johan Vromans

This module is free software. You can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

This program is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut

1;
