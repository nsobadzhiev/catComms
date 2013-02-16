#!/usr/bin/perl

use IO::Socket;
use Data::Dumper;
require "catalog.pl";
require "filesInDir.pl";
require "config.pl";
require "checksum.pl";
require "fileTransfer.pl";

my $server = undef;
my $catalogFileName = "catalog.xml";
my $hasNegotiatedCatalog = 0;		# true if peers have exchanged catalogs

# INT_handler is the subroutine that is going to be called in response to a SIG_INT from the OS
# (typically when typing CNTRL+C in terminal).
# This implementation will make sure to close the socket, otherlise it might stay open after the server
# is no longer needed
sub INT_handler {
	print "Closing server...\n";
	stopServer();
	exit(0);
}

$SIG{'INT'} = 'INT_handler';		# Use INT_handler as handler for SIG_INT (CNTRL+C)
$SIG{'TSTP'} = 'INT_handler';		# USE INT_handler as handler for SIG_TSTP (CNTRL+Z)

sub startServer($$)
{
	my $port = shift;
	my $saveDir = shift || './files';
	
#	if (! -d $saveDir) 
#	{
#		mkdir($saveDir, 0755);
#		print "Save directory created: $saveDir\n";
#	}
	
	$server = IO::Socket::INET->new(
	  Listen => 5,
	  LocalAddr => 'localhost',
	  LocalPort => $port ,
	  Proto     => 'tcp'
	) or die "Can't create server socket: $!";
	
	while(my $client = $server->accept)
	{
		print "\nNew client!\n";
		my $receivedCatalog = receiveFile($client, $saveDir, $hasNegotiatedCatalog);
		print("Received catalog: $receivedCatalog\n");
		if ($receivedCatalog)
		{
			handleCatalogReceived($receivedCatalog);
		}
	}
}

sub stopServer()
{
	close($server);
}

sub handleCatalogReceived($)
{
	my $receivedCatalog = shift || die "handleCatalogReceived called with no catalog\n";
	my @filesInCatalog = parseCatalog($receivedCatalog);
	my @destinationDirs = allDestinationDirs();
	my @localFiles = allFilesFromDirs(@destinationDirs);
	my @requestFiles = ();
	
	foreach my $file (@filesInCatalog)
	{
		my $fileName = $file->{name};
		my $fileChecksum = $file->{checksum};
		if (not hasFileLocally($fileName, $fileChecksum, @localFiles))
		{
			push(@requestFiles, $fileName);
		}
	}
	
	my $responseCatalog = catalogForFiles(@requestFiles);
	
	sendString($server, $responseCatalog, $catalogFileName);
}

sub allFilesFromDirs($)
{
	my @allFiles = ();
	foreach my $dir (@_)
	{
		my @dirContents = filesReccursive($dir);
		@allFiles = (@allFiles, @dirContents);
	}
	return @allFiles;
}

sub hasFileLocally($$$)
{
	my $fileName = shift || die "hasFileLocally called with no file name\n";
	my $fileChecksum = shift || die "hasFileLocally called with no checksum\n";
	
	foreach my $localFile (@_)
	{
		if ($localFile eq $fileName)
		{
			if (checkMd5ForFile($localFile, $fileChecksum))
			{
				return 1;
			}
		}
	}
	return 0;
}

1;