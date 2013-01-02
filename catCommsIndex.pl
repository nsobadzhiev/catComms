#!/usr/bin/perl

use warnings;
require 'xmlParser.pl';

my $indexFileName = "/media/niki/niki/Documents/Uni/Perl/project/fileIndex.xml";

sub getIndexFile()
{
	local $/;	# prevents reading only the first line of a file
	# open the index file
	open(FILE, $indexFileName) or die "Can't read index file' [$!]\n";
	$indexFileContent = <FILE>;
	close (FILE);
	my %indexHash = xmlParser($indexFileContent);
	return %indexHash;	
}

sub tagsForFileEntry($)
{
	my $fileEntry = shift || die "tagsForFileEntry called with no input";
	my $tagsHash = $fileEntry->{tags};
	my $tagsArray = $tagsHash->{tag};
	return @$tagsArray;
}

sub hasFileWithName($)
{
	my $fileName = shift || die "hasFileWithName called with no file name";
	@allFiles = allFilePaths();
	
	foreach $file (@allFiles)
	{
		if ($file eq $fileName)
		{
			print("File with name ($fileName) already exists\n");
			return 1;
		}
	}
	return 0;
}

sub fileHasCategoryWithName($$)
{
	my $fileName = shift || die "fileHasCategoryWithName called with no file name";
	my $categoryName = shift || die "fileHasCategoryWithName called with no category name";
	@allCategories = categoriesForFile($fileName);
	
	foreach $category (@allCategories)
	{
		if ($category eq $categoryName)
		{
			print("File with name ($fileName) already has category named ($categoryName)\n");
			return 1;
		}
	}
	return 0;
}

sub addCategoryForFile($$)
{
	my $filePath = shift || die "addCategoryForFile called with no file name";
	my $categoryName = shift || die "addCategoryForFile called with no category";
	my %indexhash = getIndexFile();
	my @allFiles = $indexhash{file};

	foreach $file (@allFiles)
	{
		foreach $fileEl (@$file)
		{
			my $path = $fileEl->{path};
			if ($path eq $filePath)
			{
				if (not fileHasCategoryWithName($filePath, $categoryName))
				{
					my @categories = tagsForFileEntry($fileEl);
					push(@categories, $categoryName);
					$fileEl->{tags}{tag} = \@categories;
					xmlSave(\%indexhash, $indexFileName);
					# XMLout(\%indexhash, OutputFile => $indexFileName);
					last;
				}
			}
		}
	}
}

sub removeCategoryForFile($$)
{
	my $filePath = shift || die "removeCategoryForFile called with no file name";
	my $categoryName = shift || die "addCategoryForFile called with no category";
	my %indexhash = getIndexFile();
	my @allFiles = $indexhash{file};

	foreach $file (@allFiles)
	{
		foreach $fileEl (@$file)
		{
			my $path = $fileEl->{path};
			if ($path eq $filePath)
			{
				my @categories = tagsForFileEntry($fileEl);
				
				# find the specified category in the categories array
				my $arrayIndex = 0;					
				$arrayIndex++ until (($categories[$arrayIndex] eq $categoryName) or ($arrayIndex >= scalar(@categories) - 1));

				if ($arrayIndex < scalar(@categories))
				{
					# the category has been found (and arrayIndex hold the index of the element in the array)
					# remove this category and save the index file
					splice(@categories, $arrayIndex, 1);
					$fileEl->{tags}{tag} = \@categories;
					XMLout(\%indexhash, OutputFile => $indexFileName);
					last;
				}
			}
		}
	}
}

sub categoriesForFile($)
{
	my $filePath = shift || die "categoriesForFile called with no input";
	my %indexhash = getIndexFile();
	my @allFiles = $indexhash{file};

	foreach $file (@allFiles)
	{
		foreach $fileEl (@$file)
		{
			my $path = $fileEl->{path};
			if ($path eq $filePath)
			{
				return tagsForFileEntry($fileEl);
			}
		}
	}
	return ();
}

sub allFilePaths()
{
	my %indexhash = getIndexFile();
	my @allFiles = $indexhash{file};
	my @filePaths = ();
	foreach $file (@allFiles)
	{
		foreach $fileEl (@$file)
		{
			my $path = $fileEl->{path};
			push(@filePaths, $path);
		}
	}
	return @filePaths;
}

sub addFileWithCategories($$)
{
	my $fileName = shift || die "addFileWithCategories called with no file name";
	#splice(@_, 0, 1); #|| die "addFileWithCategories called with no categories";
	my @categories = @ARGV;

	my %indexhash = getIndexFile();
	my $allFiles = $indexhash{file};

	if (not hasFileWithName($fileName))
	{
		# create entry for the categories
		my %tagHash = ("tag" => \@categories);
		my %tagsHash; # = ("tags" => \%tagHash, "path" => $fileName);
		$tagsHash{path} = $fileName;
		$tagsHash{tags} = \%tagHash;	

		# add the file to the xml structure and serialize it
		push(@$allFiles, \%tagsHash);
		$indexhash{file} = $allFiles;
		xmlSave(\%indexhash, $indexFileName);
	}
}

sub removeFile($)
{
	my $fileName = shift || die "removeFile called with no file name";

	my %indexhash = getIndexFile();
	my $allFiles = $indexhash{file};

	#foreach $file (@$allFiles)
	#{
		foreach $index ((0 .. scalar(@$allFiles) - 1))
		{
			print "Current file: " . $allFiles->[$index]{path} . "\n";
			if ($fileName eq $allFiles->[$index]{path})
			{
				splice(@$allFiles, $index, 1);
				$indexhash{file} = $allFiles;
				xmlSave(\%indexhash, $indexFileName);
				print "Removed index: $index\n";
			}
		}
	#}
}

sub printHelp()
{
	print<<EOF;
	
		NAME

			smuggleIndex

		SYNOPSIS

			smuggleIndex [add|remove|show|categories|remove_category|add_category| -h] fileName categories
		
		DESCRIPTION

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

			-h
				Print this message
				
		AUTHOR
			Written by Nikola Sobadzhiev.

EOF
}

my $command = shift;

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
else
{
	printHelp();
}


#
#
# Test
#
#

# my %indexhash = getIndexFile();
# my $indexValue = $indexhash{file}[0]{tags}{tag}[0];
# my @testCategories = categoriesForFile("./sampleData/sampleText");

# foreach my $category (@testCategories)
# {
# 	print("Found category: $category\n");
# }

# addCategoryForFile("./sampleData/sampleText", "test");
# addFileWithCategories("testFile", ("reading", "writing"));
# removeFile("testFile");

# my @allFiles = allFilePaths();

# foreach my $filePath (@allFiles)
# {
# 	print("Found file: $filePath\n");
# }

# print("First file name: $indexValue\n");

1;
