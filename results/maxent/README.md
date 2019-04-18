# Maxent results
The results section is devided in three sections all containing the results derived with on of the three methods to calculate niche overlap. 

## performance of ecological niche models 
- [AUCValues.csv](AUCValues.csv) contains the area-under-the-curve values that were compared
  against those obtained by random sampling within the buffered species area in the 'main'
  maxent workflow
- [traits_contribution_maxent.csv](traits_contribution_maxent.csv) contains the contribution
  of each GIS layer for each species. This is necessarily a sparse matrix because most
  layers are thrown out (to avoid collinearity) during the variable selection procedure. This
  spreadsheet is produced by the variable importance workflow.
- [mean_traits_contribution_maxent.csv](mean_traits_contribution_maxent.csv) summarizes the
  results of the previous spreadsheet to obtain the importance of each variable averaged
  over all species. Also produced by the variable importance workflow.

## overlap in niche trait space based on modelled habitat projections
- [clustering_nj_MaxEnt_occurences.pdf](clustering_nj_MaxEnt_occurences.pdf) shows the mean pairwise patristic distance between domesticated and domesticated Ungulates in red and the distance between domesticated Ungulates and wild Ungulates in the blue bars. 
- [clusters.Maxent.traits.gower.csv](clusters.Maxent.traits.gower.csv) contains per species the cluster it belongs to based on niche trait overlap derived from the MaxEnt habitat projections.
- [dendrogram.Maxent.traits.gower.pdf](dendrogram.Maxent.traits.gower.pdf) shows the clusters plotted on a dendrogram based on traits derived from MaxEnt habitat projections.
- [magnitudes.Maxent.csv](magnitudes.Maxent.csv) the dataframe contains information about the importance of the environmental traits in the differentiation of the clusters that contain domesticated Ungulates. The clusters are based on the traits per species derived from the MaxEnt habitat projections.
- [maxent_omi.csv](gower/maxent_omi.csv) contains the distances between the species measured by Gower's distance on the previously calculated niche traits. 
- [maxent_omi_hclust.tree](gower/maxent_omi_hclust.tree) phylogenetic tree based on hierarchical agglomerative clustering of the distance data. 
- [maxent_omi_nj.tree](gower/maxent_omi_nj.tree) phylogenetic tree based on neighbor-joining of distance data.

## overlap in niche trait space derived from raw occurrence data
- [clustering_nj_raw_occurences.pdf](clustering_nj_raw_occurences.pdf) shows the mean pairwise patristic distance between domesticated and domesticated Ungulates in red and the distance between domesticated Ungulates and wild Ungulates in the blue bars. The distances are based on the niche traits derived from raw occurrence points.
- [clusters.raw.occurences.gower.csv](clusters.raw.occurences.gower.csv) contains per species the cluster it belongs to based on niche trait overlap derived from raw occurrence data.
- [dendrogram.raw.occurences.gower.pdf](clusters.raw.occurences.gower.csv) shows the clusters plotted on a dendrogram based on traits derived from raw occurrence data.
- [magnitudes.raw.csv](magnitudes.raw.csv) contains information about the importance of the environmental traits in the differentiation of the clusters that contain domesticated Ungulates. The clusters are based on the traits per species derived from raw occurrence data.
- [raw_omi.csv](gower/raw_omi.csv) contains the distances between the species measured by Gower's distance on the previously calculated niche traits. 
- [raw_omi_hclust.tree](gower/raw_omi_hclust.tree) phylogenetic tree based on hierarchical agglomerative clustering of the distance data. 
- [raw_omi_nj.tree](gower/raw_omi_nj.tree) phylogenetic tree based on neighbor-joining of distance data.

## overlap in niche space derived from modelled habitat projections
- [clustering_nj_schoener.pdf](clustering_nj_schoener.pdf) shows the mean pairwise patristic distance between domesticated and domesticated Ungulates in red and the distance between domesticated Ungulates and wild Ungulates in the blue bars. The distances are based on the niche space overlap derived from MaxEnt habitat projections.
- [clusters.Maxent.Schoener.csv](clusters.Maxent.Schoener.csv) contains per species the cluster it belongs to based on niche overlap derived from the MaxEnt habitat projections.
- [dendrogram.Maxent.Schoener.pdf](dendrogram.Maxent.Schoener.pdf) shows the clusters plotted on a dendrogram based on MaxEnt habitat projections.
- [overlap.csv](schoener/overlap.csv) contains the overlap between the species niche space measured with Schoener's D. To create a measure over distance we subtractedthe overlap, i.e. the inverse of the overlap from 1.
- [inverse_overlap_nj.tree](schoener/inverse_overlap_nj.tree) phylogenetic tree based on hierarchical agglomerative clustering of the distance data. 
