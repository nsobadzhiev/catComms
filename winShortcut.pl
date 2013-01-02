#!/usr/bin/perl

use Win32::Shortcut;

# TODO: aquire an inferior operating system and test this

sub createLink($$)
{
	my $linkPath = shift || die "Creating a windows shortcut without a path\n";
	my $linkName = shift || die "Creating a windows shortcut without a name\n";

	$LINK=new Win32::Shortcut();
	$LINK->{'Path'}=$linkPath;
	$LINK->{'WorkingDirectory'}=$linkPath;
	$LINK->{'ShowCmd'}=SW_SHOWMAXIMIZED;
	$LINK->Save("$linkName.lnk");
	$LINK->Close();
}