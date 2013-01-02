#!/usr/bin/perl

sub createLink($$)
{
	my $linkPath = shift || die "Creating a symlink without a path\n";
	my $linkName = shift || die "Creating a symlink without a name\n";
	
	# check if symlinks are available
	$symlink_exists = eval { symlink("",""); 1 };
	
	if ($symlink_exists)
	{
		symlink($linkPath, $linkName);
	}
}

1;