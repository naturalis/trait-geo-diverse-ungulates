#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use List::Util qw'shuffle sum';
use Bio::Phylo::IO 'parse_tree';

# process command line arguments
my $samples = 100;
my $intree; # newick
my @domesticated = qw(
	Bos_frontalis_gaurus
	Bos_grunniens_mutus
	Bos_javanicus
	Bos_taurus_primigenius
	Bubalus_bubalis_arnee
	Camelus_bactrianus
	Camelus_dromedarius
	Capra_hircus_aegagrus
	Equus_przewalskii
	Lama_glama_guanicoe
	Ovis_aries_orientalis
	Rangifer_tarandus
	Sus_scrofa
	Vicagna_vicugna
);
GetOptions(
	'intree=s'       => \$intree,
	'domesticated=s' => \@domesticated,
	'samples=i'      => \$samples,
);

# read input tree
my $tree = parse_tree(
	'-format' => 'newick',
	'-file'   => $intree,
);

# calc patristic distance of input sample
my @dist;
my @domtips = map { $tree->get_by_name($_) } @domesticated;
for my $i ( 0 .. $#domtips - 1 ) {
	for my $j ( $i + 1 .. $#domtips ) {
		push @dist, $domtips[$i]->calc_patristic_distance( $domtips[$j] );
	}
}
print 0, "\t", sum(@dist)/scalar(@dist), "\n";

# now do the resampling
my @tips = @{ $tree->get_terminals };
for my $n ( 1 .. $samples ) {

	# create sample
	my @dist;
	@tips = shuffle(@tips);
	my @sample = @tips[ 0 .. $#domtips ];
	for my $i ( 0 .. $#tips - 1 ) {
		for my $j ( $i + 1 .. $#tips ) {
			push @dist, $tips[$i]->calc_patristic_distance( $tips[$j] );	
		}
	}
	my $names = join '|', sort { $a cmp $b } map { $_->get_name } @sample;
	print $n, "\t", sum(@dist)/scalar(@dist), "\t", $names, "\n";
}