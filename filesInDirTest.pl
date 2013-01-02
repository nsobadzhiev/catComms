#!/usr/bin/perl

require "filesInDir.pl";

my $file = shift;

if (isDir($file))
{
	print("$file is a dir\n");
}
else
{
	print("$file is not a dir\n");
}