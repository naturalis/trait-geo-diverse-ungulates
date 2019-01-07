# Script to split the dataset with the locations of all species to seperate species 


#set working directory and data directory

setwd("C:/Users/elkeh/Documents/Stage_Naturalis/InputData/SeperateSpecies_Locations")
getwd()
datdir<-file.path("data")

# add library path
.libPaths("C:/Users/elkeh/OneDrive/Documenten/R/win-library/3.4")

library(rgdal)
library(raster)
library(tidyverse)
library(sf)

## load CSV file with all the species

Species_df<-read.csv("C:/Users/elkeh/Documents/Stage_Naturalis/InputData/Species_Locations.csv")

## list all the unique species in the data frame. Around 200 species. 

list_unique_species<- unique(Species_df$taxon_name)

UniqueSpecies_df<- as.data.frame(list_unique_species)


#UniqueSpecies_df<- tibble::rowid_to_column(UniqueSpecies_df, "ID")

## loop to create location dataset per species 

for (i in 1:220){
  species<- as.character(UniqueSpecies_df$list_unique_species[i])
  selection <- filter(Species_df, Species_df$taxon_name == species)
  selection_Unique <- subset(selection[!duplicated(selection[c(3,4)]),])
  name <- str_replace_all(string=species, pattern=" ", repl="_")
  write.csv(selection_Unique, file = paste0(name, ".csv" ))
}

## you can plot the datasets using the following code 

Pointdata<- st_as_sf(selection, coords = c("decimal_longitude", "decimal_latitude"), crs = "+proj=longlat +datum=WGS84")

require(mapview)
mapview(Pointdata)
