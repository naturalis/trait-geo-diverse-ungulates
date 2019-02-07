Methods
=======

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

| Scientific name             | Wild name            | Domestic name  | GBIF ID | MSW3 ID  |
|-----------------------------|----------------------|----------------|---------|----------|
| Bos javanicus javanicus     | Banteng              | Bali cattle    | 4262589 | 14200684 |
| Bos frontalis gaurus        | Gaur                 | Gayal / mithun | 4262588 | 14200678 |
| Bos grunniens mutus         | Wild yak             | Yak            | 6165160 | 14200682 |
| Bos taurus primigenius      | Aurochs              | Cattle         | 4262590 | 14200690 |
| Bubalus bubalis arnee       | Indian water buffalo | Water buffalo  | 7559792 | 14200696 |
| Camelus bactrianus          | Bactrian camel       | Bactrian camel | 2441238 | 14200112 |
| Camelus dromedarius         | Arabian camel        | Arabian camel  | 9055455 | 14200115 |  
| Capra hircus aegagrus       | Bezoar               | Goat           | 4262706 | 14200778 |
| Equus africanus africanus   | Nubian wild ass      | Donkey         | 8697171 | 14100006 | 
| Equus africanus somaliensis | Somali wild ass      | Donkey         | 8612957 | 14100007 |
| Equus ferus                 | Russian wild horse   | Horse          | 4409270 | 14100017 |
| Lama guanicoe cacsilensis   |
| Ovis orientalis gmelini     |
| Rangifer tarandus           |
| Sus scrofa libycus          |
| Sus scrofa moupinensis      |
| Vicugna vicugna mensalis    |
