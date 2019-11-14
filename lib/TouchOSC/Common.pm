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


1;
