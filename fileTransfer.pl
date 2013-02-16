#!/usr/bin/perl

use IO::Socket;

sub sendFile($$)
{
	my ($sock, $file) = @_ ;
	print "File is $file";

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
	
	my $bandwidth = 1024;

	while (sysread(FILE, $buffer , $bandwidth))
	{
		print $sock $buffer;
	}

	close (FILE);
}

sub sendString($$$)
{
	print "Sending string: (,,)\n";
	my ($sock, $string, $fileName) = @_ ;
	print "Sending string: $string\n";
	print "Sending filename: $fileName\n";
	print("dumping server socket \n");
                print(Dumper $sock);
	
	# send some control information:
	# 1. File name - $catalogFileName
	# 2. File size in bytes (so the peer knows when to stop reading)
	my $stringSize = length($string);
	print "About to send";
	print $sock "$fileName#:#" ; # send the file name.
	print $sock "$stringSize\_" ; # send the size of the file to server.
	print "sendning..";
	print $sock $string;
	print "Just sent the following: $string\n";
}

sub receiveFile($$$)
{
	my $socket = shift || die "receiveFile called with no socket\n";
	my $savePath = shift || die "receiveFile called with no save path\n";
	my $hasNegotiatedCatalog = shift;
	
	my ($buffer,%data,$data_content);
	my $buffer_size = 1;
	my $catalogString = "";
	$data_content = 0;

	while (1) 
	{
		if ( sysread($socket, $buffer , $buffer_size) ) 
		{
			$data_content = $data_content + length($buffer);
			print "Incoming transmission...($data_content)\n";
			if ($data{filename} !~ /#:#$/) 
			{
				print "Filename = $data{filename}\n";
				$data{filename} .= $buffer ;
			}
			elsif ($data{filesize} !~ /_$/) 
			{
				print "File size found\n";
				$data{filesize} .= $buffer ;
			}
			elsif ($data_content < $data{filesize}) 
			{
				print "Receiving content \n";
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
					print "Saving a file\n";
					open (FILENEW,">>$data{filesave}");
					binmode(FILENEW);
					print FILENEW $buffer;
					close (FILENEW);
					
					$buffer = '';
					%data = ();
					$data_content = 0;
				}
				else
				{
					print "Appending catalog: $buffer\n";
					$catalogString = $catalogString . $buffer;
				}
			}
			else 
			{
				$catalogString = $catalogString . $buffer;
				print("File transfer complete\n");
				if (not $hasNegotiatedCatalog)
				{
					print "This should be a catalog $catalogString\n";
					return $catalogString;
				}
				$buffer = '';
				%data = ();
				$data_content = 0;
				last;
			}
		}
		else
		{
			#last;
		}
	}
}

1;