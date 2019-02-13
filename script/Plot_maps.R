library(raster)
library(maps)
library(rJava) 
library(maptools)
library(jsonlite)
library(caret)
library(ENMeval)
library(repmis)
library(CoordinateCleaner)
library(dismo) 
library(virtualspecies)
library(sp)
library(rgeos)

## Occurence data
# download list with species from GibHub
t<-read.table("https://github.com/naturalis/trait-geo-diverse-ungulates/raw/master/data/filtered/Taxa.txt", header = FALSE, sep = "", dec = ".")


for (i in 1:141){
  # select 10th species in the list 
  file<-paste("https://github.com/naturalis/trait-geo-diverse-ungulates/raw/master/data/filtered/", t[i,1], sep = "")
  species_occurence<-read.csv(file)
  colnames(species_occurence) <- c("taxon_id","taxon_name","decimal_latitude","decimal_longitude")
  
  ## get name to save data
  nameplot_variablecontribution<- paste0("C:/Users/elkeh/Documents/Stage_Naturalis/Controle_Data/", t[i,1],".png", sep = "" )
  png(nameplot_variablecontribution, width = 1000, height = 800, res = 130)
  
  data(wrld_simpl)
  plot(wrld_simpl, axes=TRUE, xlim=c(min(species_occurence$decimal_longitude)-10,max(species_occurence$decimal_longitude)+10), ylim=c(min(species_occurence$decimal_latitude)-10,max(species_occurence$decimal_latitude)+10), fill=TRUE, col="gainsboro", main= t[i,1] )
  points(species_occurence$decimal_longitude, species_occurence$decimal_latitude, col="orange", pch=20, cex=0.75)
  box()
  dev.off()
  
}