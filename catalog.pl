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
	my @catalogHash = xmlParser($catalogString);
	print "catalogHash: ";
	print(Dumper $catalogHash[1]);
	my $filesArray = $catalogHash[1];
	
	
	foreach $file (keys %$filesArray)
	{
		my $fileName = $file;
		print "File in catalog:\n";
		print(Dumper $file);
		my $checksum = $filesArray->{$file}->{checksum};
		print "Checksum in catalog: $checksum\n";
		my @tags = ();
		my $tagsArray = $filesArray->{$file}->{tags};
		my $tagArray = $tagsArray->{tag};
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
	print("Going through files\n");
	
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

sub catalogForFiles(@)
{
	parseConfig();

	my %catalog = ();
	my @filesElement = ();
	
	print("dumping parameter files\n");
                print(Dumper @_);
	
	foreach my $sharedFile (@_)
	{
		print("dumping sharedFile\n");
                print(Dumper $sharedFile);
		my $fileChecksum = $sharedFile->{checksum};
		my $categories = $sharedFile{tags};
		print("dumping categories\n");
		print(Dumper @$categories);
		my %fileHash = ();
		my %tagsHash = ();
		
		$tagsHash{tag} = $categories;
		$fileHash{name} = [$sharedFile->{name}];
		$fileHash{checksum} = [$fileChecksum];
		$fileHash{tags} = [\%tagsHash];
		push(@filesElement, \%fileHash);
	}

	print("dumping request files\n");
                print(Dumper @filesElement);

	$catalog{file} = \@filesElement;
	return xmlStringWithRootItem(\%catalog, "catalog");
}

1;
