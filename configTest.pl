#!/usr/bin/perl

require "config.pl";

print("Now testing $ARGV[0]...\n");

parseConfig();

print("\n\nTest 1: ");

print("Retrieve all categories of interest\n");
print("Result:\n");

my @allCategories = categoriesOfInterest();

foreach $category (@allCategories)
{
	my $name = $category->{name};
	my $dest = $category->{destination};
	print("Name: $name\n");
	print("Dest: $dest\n");
}

print("\nEnd of test 1:\n");


print("\n\nTest 2: ");

print("Retrieve destination for category based it's name\n");
print("Result:\n");

my @allCategories = categoriesOfInterest();

foreach $category (@allCategories)
{
	my $name = $category->{name};
	my $dest = dirForCategory($name);
	print("Name: $name\n");
	print("Dest: $dest\n");
}

print("\nEnd of test 2:\n");


print("\n\nTest 3: ");

print("Retrieve all peers\n");
print("Result:\n");

my @allPeers = allPeers();

foreach $peer (@allPeers)
{
	my $address = $category->{address};
	my $port = $category->{port};
	print("Addr: $address\n");
	print("Port: $port\n");
}

print("\nEnd of test 3:\n");


print("\n\nTest 4: ");

print("Retrieve all shared files\n");
print("Result:\n");

my @allFiles = sharedFiles();

foreach $file (@allFiles)
{
	print("$file\n");
}

print("\nEnd of test 4:\n");

print("\n\nTest 5: ");

print("Retrieve server port\n");
print("Result:\n");

my $port = serverPort();

print("$port\n");


print("\nEnd of test 5:\n");