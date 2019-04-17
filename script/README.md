# script folder

This folder contains re-usable scripts in R (extension: .R) and Perl (extension: .pl).

By re-usable we mean that they can be included in other files. As such, R Markdown
files (extension: .Rmd) are not supposed to be placed here, but in the doc folder. 

1. [**extract data function**](Data.R) - contains three functions 'get_layers', 'get_maxent_model' and 'get_occurrences'. The first function downloads the bioclim datasets and loads the additional environmental datasets from the GitHub repository in the desired resolution (5 or 10 degrees). The second function opens the stored MaxEnt models and opens them in the correct environment. The third function extracts the occurrence data from the data/filtered repository. (r-script)
2. [**maxent function**](MaxEnt_function.R) - contains five functions 'removeCollinearity_adjusted ', 'clip', 'Maxent_function', 'nullModel_adjusted', and 'nullModel_without_spatial'. The removeCollinearity_adjusted function is an adjusted function of the removeCollinearity function in the virtualspecies R package. The function calculates collinarity between raster layers and groups the correlated layers together. Afterwards one layer within a group of correlated layers is randomly sampled. The clip function crops the raster layers to the extent of a given shapefile. The Maxent_function transforms the csv files to coordinate points and draws buffers of 1000 km around these points. The buffers are used to clip the rasters and this raster stack is used to remove collinearity. As a last step the the maxent is calculated with the maxent function from the dismo package. The nullModel_adjusted function constructs the maxent model a 100 times with random points sampled within the model extent. The output of this function is a list of AUC values for all the random models. (r-script)
3. [**darwincore to csv file**](darwincore2csv.R) - this script takes a darwin core archive and extracts all distinct occurrences from it, writing them to a csv file in the 'data/filtered' directory. (r-script)
4. [**make ecoregion states**](make_ecoregion_states.pl) - this script calculates how many occurrences for a species are in any given biome. (Perl-script)
5. [**make grassland_states states**](make_grassland_states.pl) - this script calculates ??? vragen! (Perl-script)
6. [**pipeline from Niels Raes**](pipeline_Niels_Raes.R) - this script contains the automatic pipeline Niels Raes used to calculate ecological niche models. (R-script)
7. [**construct summary table**](summary_table.R) - this script combines the results per species calculated by the script in the doc folder (AUC values, number of occurrence points, variable importance). The results of this script are stored as 'Results/maxent/summary_df.csv'. (R-script)
8. [**traitDependent functions**](traitDependent_functions.R) - This function checks trees to see if they pass the ape ultrametricity test'. (R-script)








