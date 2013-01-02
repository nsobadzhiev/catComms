#!/usr/bin/perl

my $operatingSystem = $OSNAME;

if ($operatingSystem =~ /^Win/)
{
	# Perl on Windows
	require "winShortcut.pl";
}
else
{
	# Perl on UNIX
	require "symlink.pl";
}

sub createLinkForFile($$)
{
	my $linkPath = shift || die "Creating a link without a path\n";
	my $linkName = shift || die "Creating a link without a name\n";
	createLink($linkPath, $linkName);
}