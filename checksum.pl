#!/usr/bin/perl

use Digest::MD5;
use Cwd;

sub checksumForFile($)
{
	my $fileName = shift || die "checksumForFile called with no file name\n";
	
	open (my $fileHandle, '+<', $fileName) or die "Can't open '$fileName': $!";
	binmode ($fileHandle);

	my $md5Sum = Digest::MD5->new->addfile($fileHandle)->hexdigest;
}

sub checkMd5ForFile($$)
{
	my $fileName = shift || die "checkMd5ForFile called with no file name\n";
	my $remoteChecksum = shift || die "checkMd5ForFile called with no checksum\n";
	my $localChecksum = checksumForFile($fileName);
	return ($localChecksum eq $remoteChecksum);
}

print("Working in: " . getcwd());

1;