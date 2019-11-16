#! perl

use v5.24;
use strict;
use warnings;
use utf8;

package TouchOSC::Common;

use Carp;
use MIME::Base64 qw( encode_base64 );

my %nextid;

sub nextid {
    my ( $self, $id ) = @_;
    $id //= "id";
    return $id . ++$nextid{$id};
}

sub orientation {
    my ( $self ) = @_;
    while ( $self->{_parent} ) {
	$self = $self->{_parent};
    }
    $self->{orientation} eq 'horizontal';
}

sub fmt_string {
    my ( $self, $s ) = @_;
    encode_base64( $s, '' );
}

sub fmt_boolean {
    my ( $self, $b ) = @_;
    return $b if $b eq "true" || $b eq "false";
    return "true" if $b;
    return "false";
}

sub fmt_int {
    my ( $self, $v ) = @_;
    carp("Value $v truncated to int") unless $v == int($v);
    return int($v);
}

sub fmt_float {
    my ( $self, $v ) = @_;
    return sprintf("%f", $v) =~ s/(\.\d)0+$/$1/r;
}

sub fmt_color {
    my ( $self, $v ) = @_;
    return $v;
}

sub is {
    my ( $self, $att ) = @_;
    $self->fmt_boolean( $self->{$att} ) eq "true";
}

our %colours =
  ( black    => [ 0, 0, 0, 1 ],
    white    => [ 1, 1, 1, 1 ],
    red      => [ 1, 0, 0, 1 ],
    green    => [ 0, 1, 0, 1 ],
    blue     => [ 0, 1, 1, 1 ],
    yellow   => [ 1, 1, 0, 1 ],
    magenta  => [ 1, 0, 1, 1 ],
    cyan     => [ 0, 1, 1, 1 ],
    brown    => [ 150/256, 75/256, 0, 1 ],
    orange   => [ 1, 150/256, 50/256, 1 ],
    lightgray => [ 0.9, 0.9, 0.9, 1 ],
    gray     => [ 0.8, 0.8, 0.8, 1 ],
  );

sub cairo_colour {
    my ( $self, $col ) = @_;
    $colours{$col} // $colours{black};
}

sub Cairo::Context::rrectangle {
    my ( $self, $x, $y, $w, $h ) = @_;

    my $d = 4 * atan2(1,1) / 180;
    my $r = 3;
    $self->arc( $x + $w - $r, $y + $r, $r, -90 * $d, 0 * $d );
    $self->arc( $x + $w - $r, $y + $h - $r, $r, 0 * $d, 90 * $d);
    $self->arc( $x + $r, $y + $h - $r, $r, 90 * $d, 180 * $d);
    $self->arc( $x + $r, $y + $r, $r, 180 * $d, 270 * $d);
    $self->close_path;

}

1;
