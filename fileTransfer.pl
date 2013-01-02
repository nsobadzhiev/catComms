#!/usr/bin/perl

use IO::Socket;

sub sendFile($$)
{
	my ($sock, $file) = @_ ;

	if (! -s $file) 
	{
		die "ERROR! Can't find or blank file $file";
	}

  	my $file_size = -s $file ;
	my ($file_name) = ( $file =~ /([^\\\/]+)[\\\/]*$/gs );

	print "Filename = $file_name\n";
  	
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
	}

	close (FILE);
}

sub sendString($$$)
{
	my ($sock, $string, $fileName) = @_ ;
	
	# send some control information:
	# 1. File name - $catalogFileName
	# 2. File size in bytes (so the peer knows when to stop reading)
	my $stringSize = length($string);
	print $sock "$fileName#:#" ; # send the file name.
	print $sock "$stringSize\_" ; # send the size of the file to server.
	
	print $sock $string;
}

sub receiveFile($$$)
{
	my $socket = shift || die "receiveFile called with no socket\n";
	my $savePath = shift || die "receiveFile called with no save path\n";
	my $noSaveFile = shift;
	
	my ($buffer,%data,$data_content);
	my $buffer_size = 1;
	my $catalogString = "";

	while (1) 
	{
		if ( sysread($socket, $buffer , $buffer_size) ) 
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

				if (not (($data{filename} eq $noSaveFile) and ($hasNegotiatedCatalog)))
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
				if ($data{filename} eq $noSaveFile)
				{
					return $catalogString;
				}
				last;
			}
		}
	}
}