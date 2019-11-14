#! perl

use v5.24;
use strict;
use warnings;
use utf8;

package TouchOSC::Page;

use parent 'TouchOSC::Common';

use TouchOSC::Control;
use Carp;
our @CARP_NOT = qw( TouchOSC::Control );

sub new {
    my ( $pkg, %init ) = @_;
    my $self = { _controls => [] };

    if ( $init{parent} ) {
	$self->{_parent} = delete($init{parent});
	$self->{$_} ||= $self->{_parent}->{$_}
	  for qw( _grid );
	$self->{_w} ||= $self->{_parent}->{w};
	$self->{_h} ||= $self->{_parent}->{h};
	$self->{$_} /= $self->{_grid} for qw( _w _h );
    }
    $self->{name} = $init{name} //= $pkg->nextid("page");
    $init{title} //= delete($init{name});
    $self->{li_t} = $self->{la_t} = delete($init{title});
    $self->{li_c} = delete($init{li_c}) // "gray";
    $self->{li_s} = delete($init{li_s}) // 14;
    $self->{li_o} = delete($init{li_o}) // "false";
    $self->{li_b} = delete($init{li_b}) // "false";
    $self->{la_c} = delete($init{la_c}) // "gray";
    $self->{la_s} = delete($init{la_s}) // 14;
    $self->{la_o} = delete($init{la_o}) // "false";
    $self->{la_b} = delete($init{la_b}) // "false";

    $self->{$_} = 0 for qw( scalef scalet );

    # Not handled yet:
    # key="SHIFT+3"
    # midi_type="0" midi_channel="1" ...

    bless $self => $pkg;
}

sub add_control {
    my $self = shift;

    my $ctl;
    if ( @_ == 1 && UNIVERSAL::isa( $_[0], 'TouchOSC::Control' ) ) {
	$ctl = shift;
    }
    else {
	$ctl = TouchOSC::Control->new( parent => $self, @_ );
    }
    push( $self->{_controls}->@*, $ctl );
}

sub as_string {
    my ( $self, %opts ) = @_;
    my $indent = $opts{indent} // 1;

    my $ii = " " x ( 2 * $indent );
    my $res = qq{$ii<tabpage};
    $ii .= " " x 8;
    for ( qw( name li_t la_t  ) ) {
	$res .= " $_='" . $self->fmt_string($self->{$_}) . "'";
    }
    $res .= "\n$ii";
    for ( qw( li_c li_s la_c la_s ) ) {
	$res .= " $_='" . $self->{$_} . "'";
    }
    $res .= "\n$ii";
    for ( qw( li_o li_b la_o la_b ) ) {
	$res .= " $_='" . $self->fmt_boolean($self->{$_}) . "'";
    }
    $res .= "\n$ii";
    for ( qw( scalef scalet ) ) {
	$res .= " $_='" . $self->fmt_float($self->{$_}) . "'";
    }
    $res .= qq{>\n};

    foreach ( $self->{_controls}->@* ) {
	$res .= $_->as_string( %opts, indent => $indent+1 );
    }

    $res .= " " x ( 2 * $indent );
    $res .= qq{</tabpage>\n};
    return $res;
}


1;
