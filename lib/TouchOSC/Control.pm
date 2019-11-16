#! perl

use v5.24;
use strict;
use warnings;
use utf8;

package TouchOSC::Control;

use parent 'TouchOSC::Common';

use TouchOSC::Control::Fader;
use TouchOSC::Control::Label;
use TouchOSC::Control::Led;
use TouchOSC::Control::Push;
use TouchOSC::Control::Rotary;
use TouchOSC::Control::Toggle;

use Carp;

sub new {
    my ( $pkg, %init ) = @_;
    croak("Missing 'type' in control create") unless $init{type};
    my $self = { type => delete($init{type}) };

    if ( $init{parent} ) {
	$self->{_parent} = delete($init{parent});
	$self->{$_} ||= $self->{_parent}->{$_}
	  for qw( _grid );
    }
    $self->{name} = delete($init{name}) // $pkg->nextid($self->{type});

    for ( qw( x y w h ) ) {
	croak("Missing '$_' in control create") unless defined $init{$_};
	$self->{$_} = delete($init{$_});
    }

    $self->{osc_cs} = delete($init{osc_cs}) || "";

    $pkg .= '::'.ucfirst(lc($self->{type}));
    bless $self => $pkg;

    $self->init( \%init );
    if ( %init ) {
	carp("$pkg: Unknown attribute \"$_\"")
	  for sort keys %init;
	croak("$pkg: Aborted");
    }

    return $self;
}

sub init {
    my ( $self, $init ) = @_;
    $self;
}

sub as_string {
    my ( $self, %opts ) = @_;
    my $indent = $opts{indent} // 1;

    my $ii = " " x ( 2 * $indent );
    my $res = "";
    my $s = qq{$ii<control};
    $ii = " " x length($s);

    my %done;
    my $o = $self->orientation;
    my $n;
    foreach ( qw( type name x y w h ), sort keys(%$self) ) {
	my $k = $_;
	$n = "";
	next if $k =~ /^_/;
	next unless defined $self->{$k};
	next if $done{$k}++;
	my $v = $self->{$k};
	$n = $self->fmt_att( $k, $v );
	next if defined $n;

	if ( $k =~ /^(name|osc_cs)$/ ) {
	    $v = $self->fmt_string($v);
	}
	elsif ( $k =~ /^(color)$/ ) {
	    $v = $self->fmt_color($v);
	}
	elsif ( $k eq "x" ) {
	    if ( !$o ) {
		$k = "y";
	    }
	    $v = $self->fmt_int( $v * $self->{_grid} );
	}
	elsif ( $k eq "y" ) {
	    if ( !$o ) {
		$k = "x";
		$v = $self->{_parent}{_w} - $v - 40/$self->{_grid} - $self->{h};
	    }
	    $v = $self->fmt_int( $v * $self->{_grid} );
	}
	elsif ( $k eq "w" ) {
	    if ( !$o ) {
		$k = "h";
	    }
	    $v = $self->fmt_int( $v * $self->{_grid} );
	}
	elsif ( $k eq "h" ) {
	    if ( !$o ) {
		$k = "w";
	    }
	    $v = $self->fmt_int( $v * $self->{_grid} );
	}
	elsif ( $k =~ /^(scale[tf])$/ ) {
	    $v = $self->fmt_float($v);
	}
	elsif ( $k =~ /^(type)$/ ) {
	}
	else {
	    carp("Unformatted attribute: $k for " . $self->{type} .
		 " \"" . $self->{name} . "\"");
	}

	$n = " $k='$v'";
    }
    continue {
	if ( length($s) + length($n) > 78 ) {
	    $res .= "$s\n";
	    $s = $ii;
	}
	$s .= $n;
    }

    $res .= "$s/>\n";
    return $res;
}

sub fmt_att {
    my ( $self, $att, $value ) = @_;
    undef;
}

sub as_cairo {
    my ( $self, $cr ) = @_;

    my ( $x, $y, $w, $h ) = map { $_ * $self->{_grid} } @{$self}{qw( x y w h)};

    $cr->rrectangle ( $x, $y, $w, $h );
    my $col = $self->{color};
    $cr->set_source_rgba( $self->cairo_colour($col)->@* );
    $cr->stroke;

}

1;
