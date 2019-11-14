#! perl

use v5.24;
use strict;
use warnings;
use utf8;

package TouchOSC::Control::Toggle;

use parent 'TouchOSC::Control';

use Carp;

sub init {
    my ( $self, $init ) = @_;

    $self->{color} = delete( $init->{color} ) || "white";
    $self->{local_off} = delete( $init->{local_off} ) // 1;
    $self->{scalef} = delete($init->{scalef}) || 0;
    $self->{scalet} = delete($init->{scalet}) || 1;

    $self;
}

sub fmt_att {
    my ( $self, $att, $value ) = @_;

    if ( $att =~ /^(local_off)$/ ) {
	return " $att='".$self->fmt_boolean($value)."'";
    }

    undef;
}

1;
