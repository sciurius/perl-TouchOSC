#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Archive::Zip;
use XML::Tiny qw( parsefile );
use MIME::Base64;

my $arg = shift;

my $document;
if ( $arg =~ /\.touchosc$/i ) {
    my $zip = Archive::Zip->new;
    die unless $zip->read($arg) == 0;
    my $member = $zip->memberNamed("index.xml");
    $document = parsefile("_TINY_XML_STRING_".$member->contents);
}
else {
    open( my $xmlfile, '<:utf8', $arg );
    $document = parsefile($xmlfile);
    close($xmlfile);
}

decode_content($document);
#print_content($document);
use DDumper; DDumper($document);


sub decode_content {
    my ( $doc ) = @_;
    foreach my $e ( @$doc ) {
	for ( qw( name osc_cs text la_t li_t ) ) {
	    $e->{attrib}->{$_} = decode_base64($e->{attrib}->{$_})
	      if $e->{attrib}->{$_};
	}
	decode_content( $e->{content} ) if $e->{content};
    }
}

sub print_content {
    my ( $doc, $indent ) = @_;
    $indent //= "";
    foreach my $e ( @$doc ) {
	my $s = $indent . "<" . $e->{name};
	my $l = length($s);
	if ( $e->{attrib} ) {
	    my %done;
	    foreach my $k ( qw( name type x y w h ),
			    sort keys(%{$e->{attrib}}) ) {
		next unless defined $e->{attrib}->{$k};
		next if $done{$k}++;
		my $v = $e->{attrib}->{$k};
		my $n = " $k='$v'";
		if ( length($s) + length($n) > 78 ) {
		    print( "$s\n" );
		    $s = " " x $l;
		}
		$s .= $n;
	    }
	}
	if ( $e->{content} && @{$e->{content}} ) {
	    print("$s>\n");
	    print_content( $e->{content}, $indent."  " ) if $e->{content};
	    print( $indent, "</", $e->{name}, ">\n" );
	}
	else {
	    print("$s/>\n");
	}
    }
}
