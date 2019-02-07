#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Geo::ShapeFile;
use Geo::ShapeFile::Point;
use List::Util qw(shuffle);
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($INFO);

=begin pod

How many occurrences for a species are in any given biome?

This script takes as inputs a 'shape file' with polygons that outline the different
biomes of the world, and a directory of CSV files with species occurrences. Each file
should be named after the (sub)species, using underscores for species, and with the 
.csv extension, e.g. 'Homo_sapiens.csv'. From these CSV files, the columns 
'decimal_latitude' and 'decimal_longitude' will be used. Optionally, a maximum number 
of occurrences per species can be specified. Occurrences will then be sampled without 
replacement up to that number. The invocation thus is:

    make_ecoregion_states.pl -i <dir> -s <shape file> -m <integer> > outfile.tsv

The result is a tab-separated file where each row is a species (i.e. file name 
converted from 'Homo_sapiens.csv' to 'Homo sapiens'), and the columns are the biome
names as per the value of 'BIOME_NAME' in the shape file's DBF record.

=cut

# process command line arguments
my $indir;
my $shape;
my $max;
GetOptions(
	'indir=s' => \$indir,
	'shape=s' => \$shape,
	'max=i'   => \$max,
);

# read occurrences
my %taxa;
opendir my $dh, $indir or die $!;
while( my $entry = readdir $dh ) {

	# is a csv file
	if ( -e "${indir}/${entry}" and $entry =~ /\.csv$/ ) {
	
		# make taxon name from file name
		my $taxon = $entry;
		$taxon =~ s/\.csv$//;
		$taxon =~ s/_/ /g;
		$taxa{$taxon} = { 'points' => [], 'biomes' => {} } if not $taxa{$taxon};
		INFO "reading $taxon";
		
		# store occurrence
		my @header;
		open my $fh, '<', "${indir}/${entry}" or die $!;
		while(<$fh>) {
			chomp;
			my @record = split /,/, $_;
			
			# read header
			if ( not @header ) {
				@header = @record;
			}
			else {
				my %record = map { $header[$_] => $record[$_] } 0 .. $#header;
				push @{ $taxa{$taxon}->{'points'} }, Geo::ShapeFile::Point->new( 
					'X' => $record{'decimal_longitude'}, 
					'Y' => $record{'decimal_latitude'}
				);
			}				
		}		
	}
}

# read shape file
my %biomes;
my $shp = Geo::ShapeFile->new( $shape, { 'no_cache' => 0 } );
for my $id ( 1 .. $shp->shapes ) {
	my %db    = $shp->get_dbf_record($id);
	my $shape = $shp->get_shp_record($id);
	my $biome = $db{'BIOME_NAME'};
	next if $biome eq 'N/A';
	$biomes{$biome}++;
	INFO "checking shape $id ($biome)";
	
	# iterate over species
	for my $taxon ( keys %taxa ) {
		my @points = shuffle( @{ $taxa{$taxon}->{'points'} } );
		my @sample;
		if ( $max ) {
			my $max_index = $max <= $#points ? $max : $#points;
			@sample = @points[ 0 .. $max_index ];
		}
		else {
			@sample = @points;
		}
		for my $point ( @sample ) {
			if ( $shape->contains_point($point) ) {
				$taxa{$taxon}->{'biomes'}->{$biome}++;
			}
		}
	}
}

# print header
print join( "\t", ( 'taxon_name', 'biomes', sort { $a cmp $b } keys %biomes ) ), "\n";
for my $taxon ( sort { $a cmp $b } keys %taxa ) {

	# prepare output record
	my @result = ( $taxon );
	push @result, scalar( keys( %{ $taxa{$taxon}->{'biomes'} } ) );
	for my $biome ( sort { $a cmp $b } keys %biomes ) {
		push @result, $taxa{$taxon}->{'biomes'}->{$biome} || 0;	
	}
	print join("\t", @result), "\n";
}
