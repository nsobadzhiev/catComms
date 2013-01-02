#!/usr/bin/perl

require "xmlParser.pl";
require "checksum.pl";
require "config.pl";
require "catCommsIndex.pl";
use Data::Dumper;

sub parseCatalog($)
{
	my $catalogString = shift || "parseCatalog called with no catalog string\n";
	my @parsedFiles = ();
	my %catalogHash = xmlParser($catalogString);
	my $filesArray = $catalogHash{catalog};
	
	foreach $file (@$filesArray)
	{
		my $fileName = $file->{name};
		my $checksum = $file->{checksum};
		my @tags = ();
		my $tagsArray = $file->{tags};
		my $tagArray = $tagsArray->{tags};
		foreach $tag (@$tagArray)
		{
			push(@tags, $tag);
		}
		my %fileHash = ();
		$fileHash{name} = $fileName;
		$fileHash{checksum} = $checksum;
		$fileHash{tags} = \@tags;
		push(@parsedFiles, \%fileHash);
	}
	return @parsedFiles;
}

sub composeCatalog()
{
	parseConfig();
	
	my @allFiles = allFilePaths();
	my @allFilesFullPath = sharedFilesFullPath();
	my %catalog = ();
	my @filesElement = ();
	
	foreach my $sharedFile (@allFiles)
	{
		my $fileChecksum = checksumForFile($sharedFile);
		my @categories = categoriesForFile($sharedFile);
		print("dumping categories\n");
		print(Dumper @categories);
		my %fileHash = ();
		my %tagsHash = ();
		$tagsHash{tag} = \@categories;
		$fileHash{name} = [$sharedFile];
		$fileHash{checksum} = [$fileChecksum];
		$fileHash{tags} = [\%tagsHash];
		push(@filesElement, \%fileHash);
	}
	$catalog{file} = \@filesElement;
	return xmlStringWithRootItem(\%catalog, "catalog");
}

sub catalogForFiles($)
{
	my %catalog = ();
	my @filesElement = ();
	foreach my $file (@_)
	{
		my %fileHash = ();
		$fileHash{name} = [$file];
		push(@filesElement, \%fileHash);
	}
	$catalog{file} = \@filesElement;
	return xmlStringWithRootItem(\%catalog, "catalog");
}

1;