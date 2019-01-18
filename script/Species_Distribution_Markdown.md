Species Distribution Model
================
Elke Hendrix
January 14, 2019

Introduction
============

dus even uitleggen wat voor model dit is en waar je het voor kan gebruiken

Case study : domesticated vs wild ungulates
===========================================

The domestication of flora and fauna is one of the most significant transitions in humankind's history and domination of planet earth (Kareiva et al., 2007, Larson et al., 2014). Domestication can be explained as the alteration of wild species by selecting traits that are useful to our society, examples of this are the selection of dogs that are able to live with people or the selection of larger wheat that have more seeds per plant (Kareiva et al., 2007). Over the course of thousands of years’ humans have domesticated relatively few large animals. The group of large animals that we have domesticated are called Ungulates (Perissodactyla + Artiodactyla) but we have only domesticated about 20 species from the +- 200 Ungulates. Interestingly, some of the 20 domesticated Ungulate species were domesticated multiple times independently through space and time, while the other +180 Ungulate species were never domesticated for a variety of reasons. Some of these reasons can be explained by behavioral preadaptations like social structures, sexual behaviour, parent-young interaction, feeding behaviour and response to humans and new environments (Zeder, 2012). Hence, it might be possible that domestication can be explained by abiotic preferences.

The following libraries need to be loaded:

``` r
library(maps)
library(rJava) 
library(maptools)
```

    ## Loading required package: sp

    ## Checking rgeos availability: TRUE

``` r
library(jsonlite)
library(caret)
```

    ## Loading required package: lattice

    ## Loading required package: ggplot2

``` r
library(ENMeval)
```

    ## Loading required package: dismo

    ## Loading required package: raster

``` r
library(repmis)
library(CoordinateCleaner)
library(dismo) 
library(virtualspecies)
```

Data
====

Abiotic data
------------

Our model is going to be based on climatic variables, topography and vegetation variables.

Climatic information about the present was subtracted from the widely used Bioclim dataset which includes 19 bioclimatic datasets. The datasets contain information such as precipitation in the driest quarter or maximum temperatures of the coldest month and are constructed based on monthly remote sensing data between 1950 and 2000, with a spatial resolution of 2.5 minutes (Hijmans et al., 2005, Title et al ., 2018). The dataset can directly be downloaded with the getData() function from the raster package. It is also possible to adjust the spatial resolution res=2.5 to 30 seconds, 5 minutes and 10 minutes.

The Bioclim dataset contains information about the present climatic variables. The problem with the use of GBIF occurrence data is that the GBIF dataset does not specify the date at which the animal was present at the location. Therefore the range in which the animal was at the location could be the whole holocene, this makes it impossible to reconstruct past palaeo climatic environments. For this research we assume with caution that using the climatic dataset based on our current climate, is enough to account for the climate variability during the course of the Holocene. However we are aware that much more climatic variability was present during the course of the Holocene which has been shown in ice cores from Greenland and Antarctic (Augustin et al., 2004).

``` r
currentEnv1=getData("worldclim", var="bio", res=10)
```

Topography datasets were extracted from the Harmonized World Soil Database (HWSD) and are based on NASA’s Shuttle Radar Topographic Mission (SRTM) dataset. The topography height datasets are directly correlated to temperature and can therefore not directly be used in a species distribution model. In order to be usefull we calculated slope and aspect variables from the HWSD dataset which can directly be downloaded from our dropbox (<https://www.dropbox.com/sh/12yi6vjyqpixmvj/AAAfx-4yRKYMfeW8RaZjbK4Za?dl=1>). Again we made the assumption that slope and aspect are largely static through the course of the Holocene but we are aware that this is not always the case, for example coastline areas (Title et al., 2018).

``` r
SlopeAspect<- stack("C:/Users/elkeh/Dropbox/trait-geo-diverse-ungulates/Input_Datasets/Abiotic_Data/Slope_Aspect_10min.tif")
```

The abiotic raster layers are combined using the stack() function from the raster package.

``` r
currentEnv<- stack(SlopeAspect, currentEnv1)
plot(currentEnv)
```

![](Species_Distribution_Markdown_files/figure-markdown_github/unnamed-chunk-4-1.png) Layers with climatic and topographic information that are correlated with one another cannot be used in the species distribution model. Function 'remove\_correlation.R' in the scripts folder shows which layers are correlated with one another and which layers have to be removed to create a raster stack of abiotic data without correlation. remove all layers with a correlation coefficient higher than 0.7.

``` r
Env_removed_correlation<-removeCollinearity(currentEnv, multicollinearity.cutoff = 0.7, select.variables = TRUE)
currentEnv2<- subset(currentEnv, Env_removed_correlation)
plot(currentEnv2)
```

![](Species_Distribution_Markdown_files/figure-markdown_github/unnamed-chunk-5-1.png)

Occurence data
--------------

Species distribution model
==========================

Construction of the model
-------------------------

Model predictions
-----------------

Model evaluation
----------------

Niche overlap
=============

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
