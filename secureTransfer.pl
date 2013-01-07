#!/usr/bin/perl

use Net::SCP qw(scp iscp);

sub secureSend($$)
{
	my $sourcePath = shift | die "secureSend called with no source\n";
	my $destPath = shift | die "secureSend called with no destination\n";
	scp($source, $destination) or die $scp->{errstr};
}