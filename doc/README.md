Available workflows
===================

![](Dy4DWFnWkAAx-Qg.jpeg)

1. The [MaxEnt](1_maxent.rmd) workflow performs species distribution modeling
   using MaxEnt. The modeling is performed on the data sets in `/data/filtered`,
   and the results are written in `/results/per_species`. For valid (accurate)
   models, the habitat suitability projection is written to a map, including
   a version with the input occurrences. In addition, the variable importance 
   and the response to each variable is plotted.
2. The [phylogeny](2_phylogeny.rmd) workflow tests whether evolutionary 
   relatedness, i.e. phylogeny, shapes the pattern of similarities and 
   differences in abiotic niche dimensions among the terrestrial Ungulates. The 
   general approach to test this is to perform a Mantel test that randomizes
   niche clustering a predefined number of times (e.g. 100) with respect to the
   phylogenetic clustering, and then assesses the distribution of correlation
   coefficients.

Occurrence data collection for wild species
-------------------------------------------

We collected occurrence data from GBIF using higher taxon searches for _Artiodactyla_ and
_Perissodactyla_. The results of these searches are shown in the following table:

| Taxon          | Date       | Occurrences | Data sets | DOI                                |
|----------------|------------|-------------|-----------|------------------------------------|
| Artiodactyla   | 2018-10-19 | 1,221,109   | 1,019     | https://doi.org/10.15468/dl.qqwyhp |
| Perissodactyla | 2018-10-20 | 226,805     | 289       | https://doi.org/10.15468/dl.jxwvia |

We then pre-processed the DarwinCore records resulting from these searches by the following steps:

1. extracted [selected columns](https://github.com/naturalis/trait-geo-diverse/blob/master/script/make_occurrences.pl#L27-L34),
   [normalized boolean field for geospatial issues](https://github.com/naturalis/trait-geo-diverse/blob/master/script/make_occurrences.pl#L65),
   looked up the [long taxon name for the record](https://github.com/naturalis/trait-geo-diverse/blob/master/script/make_occurrences.pl#L70),
   and wrote the result to tab separated data 
2. assessed whether records had been annotated with non-accepted taxonomic names, and
   [wrote these to a synonyms table](https://github.com/naturalis/trait-geo-diverse/blob/master/script/make_gbif_synonyms.pl#L46-L48)
3. [loaded](https://github.com/naturalis/trait-geo-diverse/blob/master/script/load_occurrence_taxa.pl) canonical and synonymous names
   into a sqlite [schema](https://github.com/naturalis/trait-geo-diverse/blob/master/script/schema.sql) to form an extended taxonomic
   backbone, whose topology is based on [Mammal Species of the World, 3rd edition](http://www.departments.bucknell.edu/biology/resources/msw3/)
4. [loaded](https://github.com/naturalis/trait-geo-diverse/blob/master/script/load_occurrences.pl) the occurrences themselves, anchored
   on the taxonomic backbone. At this step we removed records with incomplete [lat/long/event_date](https://github.com/naturalis/trait-geo-diverse/blob/master/script/load_occurrences.pl#L41-L43)
   fields, records with [geospatial issues](https://github.com/naturalis/trait-geo-diverse/blob/master/script/load_occurrences.pl#L46), 
   and records whose basis was [UNKNOWN](https://github.com/naturalis/trait-geo-diverse/blob/master/script/load_occurrences.pl#L49)

After these steps, the number of remaining records was 834,182. We then exported these per species to CSV files, which we
stored [here](../data/filtered). For any given species, the following steps were taken to produce its output file:

1. [collect all records](https://github.com/naturalis/trait-geo-diverse/blob/9701ab15ec27aa47bedea11b0ff18a3e75589911/lib/MY/OccurrenceFilter.pm#L125-L146) for the species, including all subspecies
2. keep an initial [random sample of 1000 records](https://github.com/naturalis/trait-geo-diverse/blob/9701ab15ec27aa47bedea11b0ff18a3e75589911/lib/MY/OccurrenceFilter.pm#L150-L156)
3. [do not filter on `basisOfRecord`](https://github.com/naturalis/trait-geo-diverse/blob/9701ab15ec27aa47bedea11b0ff18a3e75589911/lib/MY/OccurrenceFilter.pm#L158-L166) (in plants one would normally only keep `PHYSICAL_SPECIMEN`, here we keep all types)
4. keep records whose [`eventDate` is onwards from 1900-01-01](https://github.com/naturalis/trait-geo-diverse/blob/9701ab15ec27aa47bedea11b0ff18a3e75589911/lib/MY/OccurrenceFilter.pm#L169-L190)
5. keep records where latitude and longitude have a [precision](https://github.com/naturalis/trait-geo-diverse/blob/9701ab15ec27aa47bedea11b0ff18a3e75589911/lib/MY/OccurrenceFilter.pm#L193-L204) of at least two decimal places
6. keep records whose coordinates are [_distinct_](https://github.com/naturalis/trait-geo-diverse/blob/9701ab15ec27aa47bedea11b0ff18a3e75589911/lib/MY/OccurrenceFilter.pm#L207-L217)
7. keep records whose coordinates [fall within polygons](https://github.com/naturalis/trait-geo-diverse/blob/9701ab15ec27aa47bedea11b0ff18a3e75589911/lib/MY/OccurrenceFilter.pm#L223-L302) for the species ranges (in a shape file) if available
7. keep records whose [mean pairwise distance to all others does not differ from the species mean](https://github.com/naturalis/trait-geo-diverse/blob/9701ab15ec27aa47bedea11b0ff18a3e75589911/lib/MY/OccurrenceFilter.pm#L305-L352) by more than 1 standard deviation
8. only keep species with more than 10 records (as per Raes & Aguirre-Gutierrez, 2018)

Domesticated species
--------------------

We consider the following, possibly extinct, (sub)species as wild ancestors of domesticated ungulates.

| Scientific name        | Wild name            | Domestic name  | GBIF ID | MSW3 ID  | Article DOI                      | GBIF data DOI      |
|------------------------|----------------------|----------------|---------|----------|----------------------------------|--------------------|
| Bos javanicus          | Banteng              | Bali cattle    | 2441027 | 14200683 | 10.13057/biodiv/d160230          | 10.15468/dl.gez0fu |
| Bos frontalis gaurus   | Gaur                 | Gayal / mithun | 4262588 | 14200678 | 10.1093/gigascience/gix094       | 10.15468/dl.4wqyum |
| Bos grunniens mutus    | Wild yak             | Yak            | 6165160 | 14200682 | 10.1111/j.1365-2699.2010.02379.x | 10.15468/dl.ghsq5k |
| Bos taurus primigenius | Aurochs              | Cattle         | 4262590 | 14200690 | 10.1038/hdy.2016.79              | 10.15468/dl.umadrb |
| Bubalus bubalis arnee  | Indian water buffalo | Water buffalo  | 7559792 | 14200696 | 10.1111/j.1365-2052.2010.02166.x | 10.15468/dl.hmvx8i |
| Camelus bactrianus     | Bactrian camel       | Bactrian camel | 2441238 | 14200112 | 10.1111/j.1365-2052.2008.01848.x | 10.15468/dl.xpccdk |
| Camelus dromedarius    | Arabian camel        | Arabian camel  | 9055455 | 14200115 | 10.1073/pnas.1519508113          | 10.15468/dl.1ccpft |
| Capra hircus aegagrus  | Bezoar               | Goat           | 4262706 | 14200778 | 10.1073/pnas.0804782105          | 10.15468/dl.eluwca |
| Equus africanus        | African wild ass     | Donkey         | 5787168 | 14100004 | 10.1098/rspb.2010.0708           | 10.15468/dl.zwa3id |
| Equus przewalskii      | Przewalski's horse   | Horse          | 5787169 | 14100018 | 10.1073/pnas.1111122109          | 10.15468/dl.jemutr |
| Lama glama guanicoe    | Guanaco              | Llama          | 5706328 | 14200120 | 10.1098/rspb.2001.1774           | 10.15468/dl.zbzcx8 |
| Ovis aries orientalis  | Mouflon              | Sheep          | 4262537 | 14200833 | 10.1038/hdy.2010.122             | 10.15468/dl.c8cqbw |
| Rangifer tarandus      | Reindeer             | Reindeer       | 5220114 | 14200328 | 10.1098/rspb.2008.0332           | 10.15468/dl.sh1osv |
| Sus scrofa             | Wild boar            | Pig            | 7705930 | 14200054 | PMID:10747069                    | 10.15468/dl.rgyaaf |
| Vicugna vicugna        | Vicugna              | Alpaca         | 5220192 | 14200122 | 10.1098/rspb.2001.1774           | 10.15468/dl.qpjtrx |

Manually selected wild species data
-----------------------------------

The data cleaning workflow failed to produce sufficient records for a handful of wild species. Using custom queries, more data
were obtained for these:

- Budorcas taxicolor: 10.15468/dl.pbnqf0
- Madoqua saltiana: 10.15468/dl.4c9ouv
- Neotragus batesi: 10.15468/dl.orreg1
- Ovis ammon: 10.15468/dl.ykvnch
- Procapra picticaudata: 10.15468/dl.a8nwfm
- Rucervus duvaucelii: 10.15468/dl.1kfjfv
- Tragulus javanicus: 10.15468/dl.ch6cpf
- Tragulus kanchil: 10.15468/dl.a0fjcx

Manuscript
----------

Apart from the notes being collected here, we are also preparing an [overleaf manuscript](https://www.overleaf.com/project/5c7cfef8ac6a080f4fd4476a)
