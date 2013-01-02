#!/usr/bin/perl

require "client.pl";
require "server.pl";

sub printHelp()
{
	print<<EOF;
	
		NAME

			catcomm

		SYNOPSIS

			catcomm [start|stop|sync|--help] address port
		
		DESCRIPTION

			start
				Start the catcomm server

			stop
				Stop the catcomm server

			sync
				Sync files with all peers configured in config.xml
				
				address
					If an address is specified for the sync command, catcomm will only
					exchange files with the specified host.
				port
					If a port is specified for the sync command, catcomm will only
					exchange files with the specified host.
					NOTE: this option MUST be used alongside the address option

			--help
				Print this message
				
		AUTHOR
			Written by Nikola Sobadzhiev.

EOF
}

my $command = shift;

if ($command eq "start")
{
	startServer();
}
elsif ($command eq "stop")
{
	stopServer();
}
elsif ($command eq "sync")
{
	my $host = shift;
	my $port = shift;
	
	if ($host and $port)
	{
		syncWithPeer($host, $port);
	}
	else
	{
		syncWithAllPeers();
	}
}
elsif ($command eq "--help")
{
	printHelp();
}
else
{
	printHelp();
}
