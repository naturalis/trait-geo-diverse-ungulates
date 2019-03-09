#!/usr/bin/perl
use strict;
use warnings;
use File::Spec;
use Getopt::Long;
use Geo::ShapeFile;
use Geo::ShapeFile::Point;
use Data::Dumper;
use Text::CSV 'csv';
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($INFO);

# process command line arguments
my $taxa;
my $shape;
GetOptions(
  'taxa=s'  => \$taxa,
  'shape=s' => \$shape,
);

# read taxa file
my @taxa;
open my $fh, '<', $taxa or die $!;
while(<$fh>) {
  chomp;
  s/\s//g;
  push @taxa, $_ if $_;
}

# process taxa file path
my ( $vol, $dir, $file ) = File::Spec->splitpath($taxa);

# open shape file
my $shp = Geo::ShapeFile->new( $shape, { 'no_cache' => 0 } );

# print header
print join( "\t", qw(taxon.name grassland other ratio) ), "\n";

# iterate over taxa
for my $taxon ( @taxa ) {
  
  # construct path to CSV file
  my $csvfile = File::Spec->catpath( $vol, $dir, $taxon . '.csv' );
  
  # iterate over records
  my ( $in, $total ) = ( 0, 0 );
  for my $record ( @{ csv( 'in' => $csvfile, 'headers' => 'auto' ) } ) {
    
    # instantiate shapefile point
    my $x = $record->{'decimal_longitude'};
    my $y = $record->{'decimal_latitude'};
    my $gbif_id = $record->{'gbif_id'};
    my $point = Geo::ShapeFile::Point->new( 'X' => $x, 'Y' => $y );
		
		# test if it's in a grassland
		SHAPE: for my $id ( 1 .. $shp->shapes ) {
		  my $sr = $shp->get_shp_record($id);
		  if ( $sr->contains_point($point) ) {
		    $in++;
		    last SHAPE;
		  }
		}
		$total++;
  }
  
  # print result
  print join( "\t", $taxon, $in, $total-$in, $in/$total ), "\n";
}

