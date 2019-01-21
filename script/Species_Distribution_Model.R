## SDM


rm(list=ls())
ls()

#set working directory and data directory

setwd("C:/Users/elkeh/Documents/Stage_Naturalis/SDM")
getwd()
datdir<-file.path("data")

# add library path
.libPaths("C:/Users/elkeh/OneDrive/Documenten/R/win-library/3.4")
library(raster)

library(maps)
library(mapdata)
library(rJava) 
library(maptools)
library(jsonlite)
library(caret)
library(ENMeval)
library(repmis)
library(CoordinateCleaner)
library(dismo) 

library(virtualspecies)



## load in the environmental and occurence data

# with the getData function you can extract the bioclim variables from the WorldClim database directly

currentEnv1=getData("worldclim", var="bio", res=10)

# The datasets containing Slope, Aspect and Soil type are downloaded below
# dus hier moet ff komen brick download hier blabla als de dropbox niet werkt
## hier ook een zipfile van maken en op de github zetten
slope<- raster("C:/Users/elkeh/Dropbox/trait-geo-diverse-ungulates/Input_Datasets/Abiotic_Data/Slope.tif")

aspect<- raster("C:/Users/elkeh/Dropbox/trait-geo-diverse-ungulates/Input_Datasets/Abiotic_Data/Aspect.tif")

sd<-stack(slope,aspect)

res<-resample(sd, currentEnv1, method="ngb")

setwd("C:/Users/elkeh/Dropbox/trait-geo-diverse-ungulates/Input_Datasets/Abiotic_Data")
writeRaster(res, "Slope_Aspect_10min.tif")


memory.limit(1000)
Env_removed_correlation<-removeCollinearity(currentEnv1, multicollinearity.cutoff = 0.7, select.variables = TRUE)
CurrentEnv2<- subset(currentEnv1, Env_removed_correlation)
### hier al zeggen welke lagen je wle of niet wilt gebruiken
## linken naar functie waar eruit komt welke lagen gecorreleerd zijn

currentEnv<- dropLayer(currentEnv, c("bio2", "bio3", "bio4", "bio10", "bio11", "bio13", "bio14", "bio15"))


## import the species occurence dataset from github 
## first download the list of taxa to loop through the dataset
t<-read.table("https://github.com/naturalis/trait-geo-diverse-ungulates/raw/master/data/taxa.txt", header = FALSE, sep = "", dec = ".")

# to download the first species in the list set i to 1
file<-paste("https://github.com/naturalis/trait-geo-diverse-ungulates/raw/master/data/", t[1,1], sep = "")
species_occurence<-read.csv(file)


## Below a loop is created to list through all the species in the table 

## select the species of interest. In script X we loop through the species list automatically

for (i in t){
  
## The function Species_distribution_model first removes outliers from the occurence dataset. 
model <-Species_Distribution_Model(currentEnv, species_occurence)

## plot the variable contribution to find out which variable is the most important
nameplot_variablecontribution<- paste0("C:/Users/elkeh/Documents/Stage_Naturalis/Results/maxent/Variable_Importance_plots/Variable_Contribution_", t[i,1],".png", sep = "" )
png(nameplot_variablecontribution, width = 1000, height = 800, res = 130)
plot(species_model)
dev.off()

## plot the response curve per abiotic variable 
nameplot_variableresponse<- paste0("C:/Users/elkeh/Documents/Stage_Naturalis/Results/maxent/Variable_Response_plot/variable_response_", t[i,1],".png", sep = "" )
png(nameplot_variableresponse, width = 1000, height = 800, res = 130)
response(species_model)
dev.off()

# now we can use this model to predict which areas are suitable
species.pred <- predict(species_model, currentEnv)

# plot suitability map
nameplot_predictionmap<- paste0("C:/Users/elkeh/Documents/Stage_Naturalis/Results/maxent/Prediction_plot/prediction_map_", t[i,1],".png", sep = "" )
png(nameplot_predictionmap, width = 1000, height = 800, res = 130)
plot(species.pred, main= "Suitability map")
map(wrld_simpl, fill=FALSE, add=TRUE)
points(species_occurence$decimal_longitude, species_occurence$decimal_latitude, col="black", pch=20, cex=0.75)
dev.off()

## assess predictive performance
## we do this with an approach called Area Under the Receiver Operator Curve AUC
## only values higher than 0.7 are considered valid
# to construct an AUC model we need random points 
random<- randomPoints(modelEnv, 1000)
Validation_species<- evaluate(p=Species_test, a=random, x=currentEnv, model =species_model)

nameplot_validation<- paste0("C:/Users/elkeh/Documents/Stage_Naturalis/Results/maxent/Validation_plots/validation_", t[i,1],".png", sep = "" )
png(nameplot_validation, width = 1000, height = 800, res = 130)
plot(Validation_species, "ROC")
dev.off()
## save output in correct folder 
# save the prediction model in the correct model 

wd<- if (Validation_species@auc > 0.7) "C:/Users/elkeh/Documents/Stage_Naturalis/Results/maxent/Prediction_model/AccurateSDM" else "C:/Users/elkeh/Documents/Stage_Naturalis/Results/maxent/Prediction_model/nonAccurateSDM"
name<- paste0(wd,"/PredictionRaster_",t[i,1], sep = "" )
writeRaster(species.pred, filename = name, format="GTiff")

}
  

## perform schoeners d

rasters_suitability<-stack(species.pred,species.pred, species.pred, species.pred)

overlap<-calc.niche.overlap(rasters_suitability, stat="D", maxent.args )
