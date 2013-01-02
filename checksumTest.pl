#!/usr/bin/perl

require "checksum.pl";

my $command = shift || die "checksumTest started with no command\n";
my $testFileName = shift || die "checksumTest started with no file name\n";

if ($command eq "printMD5")
{
	print(checksumForFile($testFileName) . "\n");
}
elsif ($command eq "verify")
{
	my $checkedMd5 = shift || die "checksumTest started with no checksum\n";
	if (checkMd5ForFile($testFileName, $checkedMd5))
	{
		print("YES, Checksums match\n");
	}
	else
	{
		print("NO, Checksums don't match\n");
	}
}