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

sub as_cairo {
    my ( $self, $cr ) = @_;
    my $w = $self->{_w} > $self->{_h} ? $self->{_w} : $self->{_h};
    $w *= $self->{_grid};

    $cr->save;
    $cr->rectangle ( 0, 0, $w-40, 40 );
    $cr->set_source_rgba( $self->cairo_colour("lightgray")->@* );
    $cr->fill;
    $cr->arc ( $w-20, 20, 12, 0, 6.28 );
    $cr->fill;

    if ( $self->{la_t} && $self->{la_s} ) {
	$cr->select_font_face ('sans', 'normal', 'normal');
	$cr->set_font_size ( $self->{la_s} );
	my $te = $cr->text_extents( $self->{la_t} );
	$cr->move_to( ($w-40 - $te->{width})/2,
		      (40-$te->{height})/2 - $te->{y_bearing}
		    );
	$cr->set_source_rgba( $self->cairo_colour($self->{la_c})->@* );
	$cr->show_text($self->{la_t});
	$cr->stroke;
    }
    $cr->restore;

    $cr->translate( 0, 40 );
    foreach ( $self->{_controls}->@* ) {
	$_->as_cairo($cr);
    }
    $cr->show_page;
}

sub load {
    my ( $pkg, %atts ) = @_;

    my $parent = $atts{parent};
    my $data = $atts{data};

    %atts = ();
    $atts{$_} = $data->{$_}
      for qw( name la_t la_s la_b la_c la_o li_t li_s li_b li_c li_o );

    my $page = $pkg->new( parent => $parent, %atts);

    foreach ( $data->{_controls}->@* ) {
	$page->add_control( parent => $page, %$_ );
    }

    return $page;
}

1;
