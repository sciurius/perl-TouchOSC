#! perl

use v5.24;
use strict;
use warnings;
use utf8;

package TouchOSC::Control::Label;

use parent 'TouchOSC::Control';

use Carp;

sub init {
    my ( $self, $init ) = @_;

    $self->{color} = delete( $init->{color} ) || "white";

    $self->{background} = delete($init->{background}) // "false";
    $self->{outline}    = delete($init->{outline})    // "false";
    $self->{text}       = delete($init->{text})       // '';
    $self->{size}       = delete($init->{size})       || 14;

    my $o = $self->orientation;
    $o = !$o if delete($init->{rotate});
    if ( $self->{type} !~ /[hv]$/ ) {
	$self->{type} .= $o  ? 'h' : 'v';
    }

    $self;
}

sub fmt_att {
    my ( $self, $att, $value ) = @_;

    if ( $att =~ /^(background|outline)$/ ) {
	return " $att='".$self->fmt_boolean($value)."'";
    }
    if ( $att =~ /^(size)$/ ) {
	return " $att='".$self->fmt_int($value)."'";
    }
    if ( $att =~ /^(text)$/ ) {
	return " $att='".$self->fmt_string($value)."'";
    }

    undef;
}

sub as_cairo {
    my ( $self, $cr ) = @_;

    my ( $x, $y, $w, $h ) = map { $_ * $self->{_grid} } @{$self}{qw( x y w h)};

    $cr->rrectangle ( $x, $y, $w, $h );
    my $col = $self->{color};
    $cr->set_source_rgba( $self->cairo_colour($col)->@* );
    $cr->stroke;

    $cr->select_font_face ('sans', 'normal', 'normal');
    $cr->set_font_size ( $self->{size} * 72/96);
    my $te = $cr->text_extents( $self->{text} );

    $cr->save;
    if ( $self->{type} =~ /h$/ ) {
	$cr->move_to( $x + ($w - $te->{height})/2,# - $te->{y_bearing},
		      $y + ($h - $te->{width})/2 );
	$cr->rotate( 2*atan2(1,1) );
    }
    else {
	$cr->move_to( $x + ($w - $te->{width})/2,
		      $y + ($h - $te->{height})/2 - $te->{y_bearing} );
    }
    $cr->set_source_rgba( TouchOSC::Control->cairo_colour($self->{color})->@* );
    $cr->show_text($self->{text});
    $cr->stroke;
    $cr->restore;
}

1;
