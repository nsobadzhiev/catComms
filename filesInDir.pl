#!/usr/bin/perl

sub filesInDir($);

sub files($)
{
	my $dir;
	my $dirName = shift || die "Missing directory parameter\n";
	opendir(dir, $dirName);
	@files = readdir(dir);
	return @files;
}

sub getFileSeparator
{
	#use File::Util;
   	#my($f) = File::Util->new();
   	
	# TODO: Replace with OS independent value
	return  "/";
}

sub isDir($)
{
	my $fileName = shift || die "isDir called with no file name\n";
	
	if (-d $fileName) 
	{
		print("$fileName is a dir\n");
		return 1;
	}
	return 0;
}

sub filesReccursive($)
{
	my $currentFolder = shift;
	my @all;

	chdir($currentFolder) or die("Cannot access folder $current_folder");

	#Get the all files and folders in the given directory.
	my @both = glob("*");

	my @folders;
	foreach my $item (@both) 
	{
		if(-d $item) 
		{
			#Get all folders into another array - so that first the files will appear and then the folders.
			push(@folders,$item);
		} 
		else 
		{ 
			#If it is a file just put it into the final array.
			push(@all,$item);
		}
	}

	foreach my $thisFolder (@folders) 
	{
		#Continue calling this function for all the folders
		my $full_path = "$currentFolder" . getFileSeparator() . "$thisFolder";

		my @deep_items = filesReccursive($full_path); # :RECURSION:
		foreach my $item (@deep_items) {
			push(@all, "$thisFolder" . getFileSeparator() . "$item");
		}
	}
	return @all;
}

#
# test
#

#print("=============== Shallow ===============\n");

#my $dirParameter = shift || die "Usege: filesInDir <dirName>\n";
#my @foundFiles = files($dirParameter);

#for my $file (@foundFiles)
#{
#	print("Found file named: $file\n");
#}

#print("=============== Recursive ===============\n");

#my @all  = filesReccursive("$dirParameter");

#foreach my $item (@all) 
#{ 
#	print "$item\n";
#}

1;
