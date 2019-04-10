Available workflows
===================

![](images/Dy4DWFnWkAAx-Qg.jpeg)

1. [**maximum entropy**](1_maxent.rmd) - perform species distribution modeling 
   using dismo::maxent. The modeling is performed on the data sets in 
   `/data/filtered`. The performance of the models is assessed by comparing 
   their AUC with a distribution of AUC values obtained by modeling on randomly
   selected points within the buffered species area. The results of this 
   assessment are written to `/results/maxent/model_summaries/AUCvalues.csv`.
   The modeling results themselves are written to `/results/per_species/` and
   include:
   - raw occurrences (occurrences.png), i.e. the input data
   - the maxent model as an rda file (valid_maxent_model.rda)
   - the maxent projection as rda, unrestricted (valid_maxent_prediction.rda) 
     and restricted by zoogeographic region 
     (valid_maxent_predication_restricted.rda)
   - a prediction map (prediction_map.png), and the same with the input 
     occurrences superimposed on this (prediction_occurence_map.png)
   - the curves plotting the species' response to the selected variables
     (valid_maxent_response_curve.png)
   - the relative importance of the selected variables
     (valid_maxent_variable_importance.png)
   - a placeholder README.md file that links these result files together
2. The [variable importance](2_variable_importance.rmd) workflow summarizes the
   importance the variables (i.e. GIS layers) have had in the maxent models 
   across all species.
3. The [outlying mean index](3_omi.rmd) workflow computes 'trait' values for each
   species and for each GIS layer. The values are obtained either by taking the
   GIS layers directly under the raw occurrences and by taking values averaged
   over the GIS layer pixels whose habitat suitability is higher than that of
   the worst 10% of the raw occurrences. Subsequently the Gower's distance 
   between species is computed for these values, and the species are then 
   clustered.
3. The [niche clusters](3_niche_clusters.rmd) workflow
2. The [phylogeny](2_phylogeny.rmd) workflow tests whether evolutionary 
   relatedness, i.e. phylogeny, shapes the pattern of similarities and 
   differences in abiotic niche dimensions among the terrestrial Ungulates. The 
   general approach to test this is to perform a Mantel test that randomizes
   niche clustering a predefined number of times (e.g. 100) with respect to the
   phylogenetic clustering, and then assesses the distribution of correlation
   coefficients.

Manuscript
----------

Apart from the notes being collected here, we are also preparing an 
[overleaf manuscript](https://www.overleaf.com/project/5c7cfef8ac6a080f4fd4476a)
