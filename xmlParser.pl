#!/usr/bin/perl

use XML::Simple;

sub xmlParser($)
{
	my $xml = shift;
	my $xs = XML::Simple->new();
	my $ref = $xs->XMLin($xml);
	my $test = $ref->{index};
	return %$ref;
}

sub xmlSave($$)
{
	my $indexRef = shift || die "xmlSave called with no hash\n";
	my $savePath = shift || die "xmlSave called with no save path\n";

	XMLout($indexRef, OutputFile => $savePath);
}

sub xmlSaveWithRootItem($$$)
{
	my $indexRef = shift || die "xmlSaveWithRootItem called with no hash\n";
	my $savePath = shift || die "xmlSaveWithRootItem called with no save path\n";
	my $rootItemName = shift || die "xmlSaveWithRootItem called with no root item name\n";

	XMLout($indexRef, OutputFile => $savePath, RootName => $rootItemName);
}

sub xmlString($)
{
	my $indexRef = shift || die "xmlString called with no hash\n";

	return XMLout($indexRef);
}

sub xmlStringWithRootItem($$)
{
	my $indexRef = shift || die "xmlStringWithRootItem called with no hash\n";
	my $rootItemName = shift || die "xmlStringWithRootItem called with no root item name\n";
	
	return XMLout($indexRef, RootName => $rootItemName);
}

#######################################
#
# test
#
#######################################

#$xmlString = shift || die "Usage: xmlParser <xmlString>";
#print("XML string: $xmlString\n");
#my %parsedXML = xmlParser($xmlString);

#foreach (keys %parsedXML) 
#{
#	print "found element";
#	print $hash{$_};
#	print "\n";
#}
#
#my $configValue = $parsedXML{peers}{peer}[0]{address};
#print("Value for peers: $configValue\n");
#
#$configValue = $parsedXML{sharedFiles};
#print("Value for peers: $configValue\n");
#
#$configValue = $parsedXML{interestCategories};
#print("Value for peers: $configValue\n");

1;
