#!/usr/bin/perl

use IO::Socket;
require "catalog.pl";
require "fileTransfer.pl";
require "config.pl";
  
my $catalogFileName = "/media/niki/niki/Documents/Uni/Perl/project/catComms/catalog.xml";

sub negotiateCatalogWithPeer($)
{
	my $socket = shift;
	my $catalog = composeCatalog();
	sendString($socket, $catalog, "catalog.xml");
	my $responseCatalog = receiveFile($socket, "files", 0);
	return parseCatalog($responseCatalog);
}

sub syncWithPeer($$)
{
	my $address = shift || die "syncWithPeer called with no host address\n";
	my $port = shift || die "syncWithPeer called with no host port\n";
	my $socket = openSocketToPeer($address, $port);
	my @filesToBeSent = negotiateCatalogWithPeer($socket);
	destroySocket($socket);
	
	foreach my $file (@filesToBeSent)
	{
		my $fileName = $file->{name};
		my $socket = openSocketToPeer($address, $port);
		print "Sending file: $fileName\n";
		sendFile($socket, $fileName);
		destroySocket($socket);
	}
}

sub syncWithAllPeers()
{
	my @peers = allPeers();
	
	foreach my $peer (@peers)
	{
		my $address = $peer->{address};
		my $port = $peer->{port};
		syncWithPeer($address, $port);
	}
}

sub openSocketToPeer($$)
{
	my $address = shift || die "openSocketToPeer called with no host address\n";
	my $port = shift || die "openSocketToPeer called with no host port\n";
	
	print("Opeining socket to peer: ($address:$port)\n");
	
	my $sock = new IO::Socket::INET(
     		PeerAddr => $address,
     		PeerPort => $port,
     		Proto    => 'tcp',
     		Timeout  => 30);

	($sock) || die "Failed to connect to peer ($address:$port)\n";
	return $sock;
}

sub destroySocket($)
{
	my $socket = shift;
	close($socket);
}

sub send_file 
{
	my ( $file , $host , $port ) = @_ ;

	if (! -s $file) 
	{
		die "ERROR! Can't find or blank file $file";
	}

  	my $file_size = -s $file ;
	my ($file_name) = ( $file =~ /([^\\\/]+)[\\\/]*$/gs );

	print "Filename = $file_name\n";

	my $sock = new IO::Socket::INET(
     		PeerAddr => $host,
     		PeerPort => $port,
     		Proto    => 'tcp',
     		Timeout  => 30);

	($sock) || die "ERROR! Can't connect\n";
  	
	$sock->autoflush(1);

	print "Sending $file_name\n$file_size bytes." ;

	print $sock "$file_name#:#" ; # send the file name.
	print $sock "$file_size\_" ; # send the size of the file to server.

	open (FILE,$file);
	binmode(FILE);

	my $buffer;

	while (sysread(FILE, $buffer , $bandwidth))
	{
		print $sock $buffer;
		print ".";
		sleep(1);
  	}

  	print "OK\n\n" ;

  	close (FILE) ;
  	close($sock) ;
}
