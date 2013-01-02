#!/usr/bin/perl

require "link.pl";

my $symPath = shift;
my $symName = shift;

createLinkForFile($symPath, $symName);