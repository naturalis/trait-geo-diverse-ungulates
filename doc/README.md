
Available workflows
===================

![](images/Dy4DWFnWkAAx-Qg.jpeg)

1. [**maximum entropy**](1.maxent/index.html) - species distribution modeling using 
   dismo::maxent. The modeling is performed on the data sets in 
   `/data/filtered`. The performance of the models is assessed by comparing 
   their AUC with a distribution of AUC values obtained by modeling on randomly
   selected points within the buffered species area. The results of this 
   assessment are written to `/results/maxent/model_summaries/AUCvalues.csv`.
   The modeling results themselves are written to `/results/per_species/` and
   include a README.md file for each species that explains the source and 
   purpose of the different output files.
2. [**variable importance and model summaries**](html_files/2.varimp) - summarizes the
   importance the variables (i.e. GIS layers) have had in the maxent models 
   across all species. Produces output for each species and for each GIS
   layer, written to `/results/maxent/model_summaries/traits_contribution_maxent.csv` and `/results/maxent/model_summaries/mean_traits_contribution_maxent.csv`. The variable importance dataframes are used to summarize the models per species (AUC value, n occurrence points, variable importance in descending order), written to `/results/maxent/model_summaries/summary_df.csv`
3. [**outlying mean index**](3_omi.rmd) - computes 'trait' values for each
   species and for each GIS layer. The values are obtained either by taking the
   GIS pixel values directly under the raw occurrences or by taking values 
   averaged over the GIS pixels whose habitat suitability is higher than 
   that of the worst 10% of the raw occurrences. Subsequently the Gower's 
   distance between species is computed for these values, and the species are 
   then clustered using neighbor-joining and hierarchical clustering.
4. [**niche clusters**](4_niche_clusters.rmd) - takes a dendrogram (whether
   Schoener's D or Gower's D, and irrespective of clustering algorithm) and
   attempts to partition this optimally such that the dendrogram is subdivided
   in clusters that are specific to the domesticated species. Visualizes these
   clusterings. Identifies the niche traits with the greatest magnitude 
   difference between the cluster ingroup and outgroup.
5. [**phylogeny**](5_phylogeny.rmd) - tests whether evolutionary 
   relatedness, i.e. phylogeny, shapes the pattern of similarities and 
   differences in abiotic niche dimensions among the terrestrial Ungulates. The 
   general approach to test this is to perform a Mantel test that randomizes
   niche clustering a predefined number of times (e.g. 100) with respect to the
   phylogenetic clustering, and then assesses the distribution of correlation
   coefficients.
6. [**phyloglm**](6_phyloglm.rmd) - performs phylogenetic generalized linear
   modeling and model selection to identify which niche traits most predict
   domestication.
7. [**trait-dependent diversification**](7_trait-dependent_diversification.rmd)
   - assesses whether there is evidence for an adaptive radiation in relation
   to grazing, using a BiSSE analysis.
8. [**DPLACE**](8_dplace.rmd) - performs statistical tests to link societal
   data from DPLACE to Ungulate niches.

Manuscript
----------

Apart from the notes being collected here, we are also preparing an 
[overleaf manuscript](https://www.overleaf.com/project/5c7cfef8ac6a080f4fd4476a)
