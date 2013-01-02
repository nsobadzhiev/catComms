#!/usr/bin/perl

require "filesInDir.pl";
require "xmlParser.pl";

use Data::Dumper;

my $configFileName = "config.xml";

my %configHash = undef;
my @categories = undef;
my @peers = undef;
my @sharedFiles;
my @sharedFilesFullPath = undef;
my $serverPort = undef;

sub categoriesOfInterest()
{
	return @categories;
}

sub dirForCategory($)
{
	my $categoryName = shift || die "dirForCategory called with no category name\n";
	foreach $category (@categories)
	{
		my $name = $category->{name};
		if ($name eq $categoryName)
		{
			return $category->{destination};
		}
	}
	return undef;
}

sub allDestinationDirs()
{
	my @allDirs = ();
	foreach $category (@categories)
	{
		push(@allDirs, $category->{destination});
	}
	return @allDirs;
}

sub allPeers()
{
	return @peers;
}

sub sharedFiles()
{
	return @sharedFiles;
}

sub sharedFilesFullPath()
{
	return @sharedFilesFullPath;
}

sub parseConfig()
{
	# TODO: only parse config if not already done
	%configHash = readConfig();
	parseCategories();
	parsePeers();
	parseSharedFiles();
	parseConnection();
}

sub parseCategories()
{
	# first of all remove any previously parsed categories
	@categories = ();
	
	my $allCategoriesHash = $configHash{interestCategories};
	my $allCategories = $allCategoriesHash->{category};
	print( Dumper($allCategories));

	foreach $category (keys($allCategories))
	{
		my $name = $category;
		my $destHash = $allCategories->{$category};
		my $dest = $destHash->{destination};

		# create a new hash containing the name and destination pairs
		# and add it to the categories array
		my %newCategory = ();
		$newCategory{name} = $name;
		$newCategory{destination} = $dest;
		push(@categories, \%newCategory);
	}
}

sub parsePeers()
{
	# first of all remove any previously parsed peers
	@peers = ();
	
	my $allPeersHash = $configHash{peers};
	my $allPeers = $allPeersHash->{peer};

	foreach $peer (@$allPeers)
	{
		my $address = $peer->{address};
		my $port = $peer->{port};
			
		# create a new hash containing the address and port pairs
		# and add it to the peers array
		my %newPeer = ();
		$newPeer{address} = $address;
		$newPeer{port} = $port;
		print("Dumping peer ($address, $port)\n");
		print(Dumper \%newPeer);
		push(@peers, \%newPeer);
	}
}

sub parseSharedFiles()
{
	# first of all remove any previously parsed files
	@sharedFiles = ();
	@sharedFilesFullPath = ();
	
	my $allFiles = $configHash{sharedFiles}->{file};

	foreach $file (@$allFiles)
	{
		my $path = $file;
		
		# the file might actually be a directory. In this case recursively add all files
		# inside the directory
		if (isDir($path))
		{
			foreach $containedFile (filesReccursive($path))
			{
				push(@sharedFiles, $containedFile);
				push(@sharedFilesFullPath, fullPathForFile($containedFile, $path));
			}
		}
		else
		{
			push(@sharedFiles, $path);
			push(@sharedFilesFullPath, $path);
		}
	}
}

sub parseConnection()
{
	my $connectionHashRef = $configHash{connection};
	my %connectionHash = %$connectionHashRef;
	$serverPort = $connectionHash{port};
}

sub fullPathForFile($$)
{
	my $fileName = shift || die "fullPathForFile called ith no file name\n";
	my $fileRoot = shift || die "fullPathForFile called ith no root dir\n";
	
	#if (not($fileRoot =~ ///$/))
	#{
	#	$fileRoot = $fileRoot . "/";
	#}
	return $fileRoot . $fileName;
}

sub readConfig()
{
	local $/;	# prevents reading only the first line of a file
	# open the config file
	open(FILE, $configFileName) or die "Can't read config file' [$!]\n";
	my $configFileContent = <FILE>;
	close (FILE);
	my %contentsHash = xmlParser($configFileContent);
	return %contentsHash;	
}

1;