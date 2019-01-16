Methods
=======

> Here we describe the overall workflow of the analysis. The general idea is that this will become the 
> skeleton for a _Materials and methods_ section of a publication.

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
stored [here](../data). The files in this folder are filtered such that all the records for a species are _distinct_ (i.e. no
multiples of the same lat/lon pair for multiple occurrences), only retaining species with more than 10 records (as per Raes & Aguirre-
Gutierrez, 2018).
