#! perl

use v5.24;
use strict;
use warnings;
use utf8;

package TouchOSC::Control::Rotary;

use parent 'TouchOSC::Control';

use Carp;

sub init {
    my ( $self, $init ) = @_;

    $self->{color} = delete( $init->{color} ) || "white";

    # Invert: Fader moves from right to left.
    $self->{inverted} = delete($init->{inverted}) // "false";
    # Center: Fader moves both sides.
    $self->{centered} = delete($init->{centered}) // "false";
    $self->{response} = delete($init->{response}) // "absolute";
    $self->{norollover} = delete($init->{norollover}) // "true";

    $self->{scalef} = delete($init->{scalef}) || 0;
    $self->{scalet} = delete($init->{scalet}) || 1;

    my $o = $self->orientation;
    # Rotate: Fader moves from bottom to top.
    $o = !$o if delete($init->{rotate});
    if ( $self->{type} !~ /[hv]$/ ) {
	$self->{type} .= $o  ? 'v' : 'h';
    }

    $self;
}

sub fmt_att {
    my ( $self, $att, $value ) = @_;

    if ( $att =~ /^(norollover|centered|inverted)$/ ) {
	return " $att='".$self->fmt_boolean($value)."'";
    }
    if ( $att =~ /^(response)$/ ) {
	return " $att='$value'";
    }

    undef;
}

1;
