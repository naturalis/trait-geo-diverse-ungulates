## importing and cleaning occurence data


setwd("C:/Users/elkeh/Documents/Stage_Naturalis/InputData/SeperateSpecies_Locations")
.libPaths("C:/Users/elkeh/OneDrive/Documenten/R/win-library/3.4")


library(dismo)
library(maptools)

OccurenceData<-read.csv("C:/Users/elkeh/Documents/Stage_Naturalis/InputData/SeperateSpecies_Locations/Dama_dama.csv")
dim(OccurenceData)

## Select records that have both a long and lat value 
SubOccurence<-subset(OccurenceData,  !is.na(decimal_latitude) & !is.na(decimal_longitude))
dim(SubOccurence)

## Plot datapoints for visual inspection

data(wrld_simpl)
plot(wrld_simpl, axes=TRUE)

box()

points(OccurenceData$decimal_longitude, OccurenceData$decimal_latitude, col='orange', pch=20, cex=0.75)

points(OccurenceData$decimal_longitude, OccurenceData$decimal_latitude, col='red', cex=0.75)

