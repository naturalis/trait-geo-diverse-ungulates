## pre-processen abiotic variables 

library(rgdal)
library(raster)

# brick and pre-process current abiotic dataset 

## import Bioclim
setwd("C:/Users/elkeh/Documents/Stage_Naturalis/InputData/Abiotic_Environmental_parameters/Raw_Data/Current")
Bioclim<- stack(list.files(pattern="*.bil"))

Bioclim1<-raster(Bioclim,1)

## import ENVI
ENVI<- stack(list.files(pattern="*.tif"))

## import elevation 
Elevation<- raster("C:/Users/elkeh/Documents/Stage_Naturalis/InputData/Abiotic_Environmental_parameters/Raw_Data/GloElev_30as.asc")
plot(Elevation)

ResElevation<- resample(Elevation, Bioclim1, method="ngb")
plot(ResElevation)

## calculate slope

slope<-terrain(ResElevation, opt='slope', neighbors =8)
plot(slope)

## calculate aspect 
Aspect<-terrain(ResElevation, opt ='aspect', neighbors =8)
plot(Aspect)


## import soil types 
SoilTypes<- raster("C:/Users/elkeh/Documents/Stage_Naturalis/InputData/Abiotic_Environmental_parameters/Raw_Data/hwsd.bil")
ResSoilTypes<- resample(SoilTypes, Bioclim1, method="ngb")

# stack all the abiotic layers 
Totalstack<-stack(Bioclim, ENVI, slope, Aspect, ResSoilTypes)

plot(Totalstack)

writeRaster(Totalstack, "AbioticVariables_Current.tif")

## brick and pre-process mid-Holocene abiotic dataset 

## import Bioclim
setwd("C:/Users/elkeh/Documents/Stage_Naturalis/InputData/Abiotic_Environmental_parameters/Raw_Data/Mid_Holocene")
Bioclim_midholocene<- stack(list.files(pattern="*.bil"))

## import ENVI
ENVI_midholocene<- stack(list.files(pattern="*.tif"))

# stack all the abiotic layers 
Totalstack<-stack(ENVI_midholocene, slope, Aspect, ResSoilTypes)

plot(Totalstack)

writeRaster(Totalstack, "AbioticVariables_mid_Holocene.tif")
