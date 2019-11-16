#! perl

use v5.24;
use strict;
use warnings;
use utf8;

package TouchOSC::Control::Led;

use parent 'TouchOSC::Control';

use Carp;

sub init {
    my ( $self, $init ) = @_;

    $self->{color}  = delete($init->{color})  || "white";
    $self->{scalef} = delete($init->{scalef}) || 0;
    $self->{scalet} = delete($init->{scalet}) || 1;

}

sub as_cairo {
    my ( $self, $cr ) = @_;

    my ( $x, $y, $w, $h ) = map { $_ * $self->{_grid} } @{$self}{qw( x y w h)};

    $cr->arc ( $x + $w/2, $y + $w/2, $w/2-2, 0, 2*4*atan2(1,1) );
    my $col = $self->{color};
    $cr->set_source_rgba( $self->cairo_colour($col)->@* );
    $cr->fill;

}

1;
