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

1;
