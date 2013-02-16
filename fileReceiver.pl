#!/usr/bin/perl

use IO::Socket;
use Data::Dumper;
require "catalog.pl";
require "filesInDir.pl";
require "config.pl";
require "checksum.pl";

my $server = undef;
my $catalogFileName = "catalog.xml";
my $hasNegotiatedCatalog = 0;		# true if peers have exchanged catalogs

sub startServer($$$)
{
	my $address = shift || localhost;
	my $port = shift || 6123;
	my $saveDir = shift || './files';
	
	if (! -d $saveDir) 
	{
		mkdir($saveDir, 0755);
		print "Save directory created: $saveDir\n";
	}
	
	$server = IO::Socket::INET->new(
	  Listen => 5,
	  LocalAddr => 'localhost',
	  LocalPort => $port ,
	  Proto     => 'tcp'
	) or die "Can't create server socket: $!";
	
	while(my $client = $server->accept)
	{
		print "\nNew client!\n";
		my ($buffer,%data,$data_content);
		my $buffer_size = 1;
		my $catalogString = "";

		while (1) 
		{
			if ( sysread($client, $buffer , $buffer_size) ) 
			{
				if ($data{filename} !~ /#:#$/) 
				{
					print "Filename = $data{filename}\n";
					$data{filename} .= $buffer ;
				}
				elsif ($data{filesize} !~ /_$/) 
				{
					$data{filesize} .= $buffer ;
				}
				elsif (length($data_content) < $data{filesize}) 
				{
					if ($data{filesave} eq '') 
					{
						$data{filesave} = "$save_dir/$data{filename}";
						$data{filesave} =~ s/#:#$//;
						$buffer_size = 1024*10;
						if (-e $data{filesave}) 
						{
							unlink ($data{filesave});
						}
						print "Saving: $data{filesave} ($data{filesize}bytes)\n" ;
					}

					if ($hasNegotiatedCatalog)
					{
						# the if statement above checks if catalogs are negotiated. This prevents
						# a peer from sending files before catalogs are exchanged
						open (FILENEW,">>$data{filesave}");
						binmode(FILENEW);
						print FILENEW $buffer;
						close (FILENEW);
					}
					else
					{
						$catalogString = $catalogString . $buffer;
					}
				}
				else 
				{
					if ($data{filename} eq $catalogFileName)
					{
						handleCatalogReceived($catalogString);
					}
					print Dumper(%data);
					last;
				}
			}
		}
	}
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
	print $server $responseCatalog;
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
