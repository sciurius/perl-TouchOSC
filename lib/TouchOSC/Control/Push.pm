#! perl

use v5.24;
use strict;
use warnings;
use utf8;

package TouchOSC::Control::Push;

use parent 'TouchOSC::Control';

use Carp;

sub init {
    my ( $self, $init ) = @_;

    $self->{color} = delete( $init->{color} ) || "white";
    $self->{local_off} = delete( $init->{local_off} ) // 1;

    # Push sends scalet, release sends scalef.
    $self->{sp} = delete( $init->{send_on_push} ) // 1;
    $self->{sr} = delete( $init->{send_on_release} ) // 1;
    $self->{scalef} = delete($init->{scalef}) || 0;
    $self->{scalet} = delete($init->{scalet}) || 1;

    $self->{velocity} = delete( $init->{velocity} ) || 0;
    $self->{velocity_invert} = delete( $init->{velocity_invert} ) || 0;

    $self;
}

sub fmt_att {
    my ( $self, $att, $value ) = @_;

    if ( $att =~ /^(sp|sr|local_off)$/ ) {
	return " $att='".$self->fmt_boolean($value)."'";
    }
    if ( $att =~ /^(velocity|velocity_invert)$/ ) {
	return "" unless $value;
	return " $att='".$self->fmt_int($value)."'";
    }

    undef;
}

1;
