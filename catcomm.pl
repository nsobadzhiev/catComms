#!/usr/bin/perl

require "client.pl";
require "server.pl";
require "catCommsIndex.pl";

sub printHelp()
{
	print<<EOF;
	
		NAME

			catcomm

		SYNOPSIS

			catcomm [start|stop|sync|--help] address port
			catcomm [add|remove|show|categories|remove_category|add_category| -h] fileName categories
		
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
					
						add fileName [categories]
				Add a file to the index

			remove fileName
				Remove a file from the index

			show
				List all files in the index

			categories fileName
				List all categories for a specified file

			remove_category fileName categoryName
				Remove a specified category for a file

			add_category fileName categoryName
				Add a spefified category for a file

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
if ($command eq "add")
{
	$fileName = shift || printHelp();
	@categories = @ARGV || printHelp();
	addFileWithCategories($fileName, @categories);
}
elsif ($command eq "remove")
{
	$fileName = shift || printHelp();
	removeFile($fileName);
}
elsif ($command eq "show")
{
	@allFiles = allFilePaths();
	foreach $file (@allFiles)
	{
		print("\t" . $file . "\n");
	}
}
elsif ($command eq "categories")
{
	$fileName = shift || printHelp();
	@allCategories = categoriesForFile($fileName);
	foreach $category (@allCategories)
	{
		print("\t" . $category . "\n");
	}
}
elsif ($command eq "remove_category")
{
	$fileName = shift || printHelp();
	$category = shift || printHelp();
	removeCategoryForFile($fileName, $category);
}
elsif ($command eq "add_category")
{
	$fileName = shift || printHelp();
	$category = shift || printHelp();
	addCategoryForFile($fileName, $category);
}
elsif ($command eq "--help")
{
	printHelp();
}
else
{
	printHelp();
}
