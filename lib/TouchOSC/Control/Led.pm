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

1;
