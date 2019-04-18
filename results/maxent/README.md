# Maxent results
- [clustering_nj_MaxEnt_occurences.pdf](clustering_nj_MaxEnt_occurences.pdf) shows the mean pairwise patristic distance between domesticated and domesticated Ungulates in red and the distance between domesticated Ungulates and wild Ungulates in the blue bars. The distances are based on the niche traits derived from MaxEnt habitat projections. 
- [clustering_nj_raw_occurences.pdf](clustering_nj_raw_occurences.pdf) shows the mean pairwise patristic distance between domesticated and domesticated Ungulates in red and the distance between domesticated Ungulates and wild Ungulates in the blue bars. The distances are based on the niche traits derived from raw occurrence points.
- [clustering_nj_schoener.pdf](clustering_nj_schoener.pdf) shows the mean pairwise patristic distance between domesticated and domesticated Ungulates in red and the distance between domesticated Ungulates and wild Ungulates in the blue bars. The distances are based on the niche space overlap derived from MaxEnt habitat projections.
- [clusters.Maxent.Schoener.csv](clusters.Maxent.Schoener.csv) contains per species the cluster it belongs to based on niche overlap derived from the MaxEnt habitat projections.
- [clusters.Maxent.traits.gower.csv](clusters.Maxent.traits.gower.csv) contains per species the cluster it belongs to based on niche trait overlap derived from the MaxEnt habitat projections.
- [clusters.raw.occurences.gower.csv](clusters.raw.occurences.gower.csv) contains per species the cluster it belongs to based on niche trait overlap derived from raw occurrence data.
- [dendrogram.Maxent.Schoener.pdf](dendrogram.Maxent.Schoener.pdf) shows the clusters plotted on a dendrogram based on MaxEnt habitat projections.
- [dendrogram.Maxent.traits.gower.pdf](dendrogram.Maxent.traits.gower.pdf) shows the clusters plotted on a dendrogram based on traits derived from MaxEnt habitat projections.
- [dendrogram.raw.occurences.gower.pdf](clusters.raw.occurences.gower.csv) shows the clusters plotted on a dendrogram based on traits derived from raw occurrence data.
- [magnitudes.Maxent.csv](magnitudes.Maxent.csv) the dataframe contains information about the importance of the environmental traits in the differentiation of the clusters that contain domesticated Ungulates. The clusters are based on the traits per species derived from the MaxEnt habitat projections.
- [magnitudes.raw.csv](magnitudes.raw.csv) contains information about the importance of the environmental traits in the differentiation of the clusters that contain domesticated Ungulates. The clusters are based on the traits per species derived from raw occurrence data.

The folders contain the following information:
- [comparative](maxent/comparative/) this folder contains the results of both Schoener's distance and Gower's distance. 
- [model_summaries](maxent/model_summaries) this folder contains dataframes that combine the results in the MaxEnt folder
