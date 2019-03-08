rm(list = ls(all=T))
setwd("D:/Papers.Projects/Climate.Smart.Agriculture/R/")
# save(list=ls(all=TRUE), file="D:/Papers.Projects/Climate.Smart.Agriculture/R/CSA.v2.RData") # save RDATA for later use
load("D:/Papers.Projects/Climate.Smart.Agriculture/R/CSA.v2.RData")

library(raster)
library(rgdal)
library(dismo)
library(maptools)
library(XML)
library(SDMTools)
library(foreign)
library(rJava); # Sys.setenv(JAVA_HOME='C:\\Program Files\\Java\\jre7') # for 64-bit version
library(xlsx)
library(rgbif)
library(gdata)
library(taxize)
library(ade4)
library(rgeos)
library(fmsb)
source("D:/R/Scripts/VIF.R")
source("D:/R/Scripts/null_model_function.R")

#library(pheno)
#daylength(as.integer(180),52)

countries <- readShapeLines("D:/GIS/Administrative/world/33578/world_country_admin_boundary_shapefile_with_fips_codes")
P4S.latlon <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
proj4string(countries) <- P4S.latlon
plot(countries)

### 1. Download GBIF data Cucumis ####

#### Genera to be merged with Cucumis according Schaefer & Renner 2008
#### Cucumella, Dicoelospermum, Mukia, Myrmecosicyos, Oreosyce

cucumella.download <- gbif("cucumella", "*", geo=F) # 220 records
dicaelospermum.download <- gbif("dicaelospermum", "*", geo=F) # 1 records
dicoelospermum.download <- gbif("dicoelospermum", "*", geo=F) # 1 records
mukia.download <- gbif("mukia", "*", geo=F) # 1304 records
head(mukia.download); # table(mukia.download$species)
myrmecosicyos.download <- gbif("Myrmecosic*", "*", geo=F) # 5 records
oreosyce.download <- gbif("oreosyce", "*", geo=F) # 206 records

CDMMO.download <- rbind(cucumella.download, dicaelospermum.download, dicoelospermum.download, mukia.download, myrmecosicyos.download, oreosyce.download)
head(CDMMO.download)

### Additional synonyms from Schaefer 2007

bryonia.download <- gbif("bryonia", "leio*", geo=F) # 1 records
hymenosicyos.download <- gbif("hymenosicyos", "*", geo=F) # 0 records
karivia.download <- gbif("karivia", "*", geo=F) # 3 records
kedrostis.cinerea.download <- gbif("kedrostis", "ciner*", geo=F) # 1 records
kedrostis.engleri.download <- gbif("kedrostis", "engler*", geo=F) # 0 records
melothria.javanica.download <- gbif("melothria", "javan*", geo=F) # 8 records
melothria.leiosperma.download <- gbif("melothria", "leios*", geo=F) # 4 records
melothria.maderaspatana.download <- gbif("melothria", "maderas*", geo=F) # 128 records
melothria.ritchiei.download <- gbif("melothria", "ritch*", geo=F) # 0 records
melothria.rumphiana.download <- gbif("melothria", "rumph*", geo=F) # 0 records

additional.Schaefer.2007 <- rbind(bryonia.download,hymenosicyos.download, karivia.download, kedrostis.cinerea.download, kedrostis.engleri.download, melothria.javanica.download, melothria.leiosperma.download, melothria.maderaspatana.download, melothria.ritchiei.download, melothria.rumphiana.download)

head(additional.Schaefer.2007)

additional.cucumis <- rbind(CDMMO.download, additional.Schaefer.2007)
head(additional.cucumis)
dim(additional.cucumis) # 1882 25

### GBIF Cucumis

cucumis.gbif <- gbif("cucumis", "*", geo=F) # 27696 records
dim(cucumis.gbif) # 27696    25
head(cucumis.gbif)

### Cucumis all

cucumis <- rbind(cucumis.gbif, additional.cucumis)
dim(cucumis) # 29578    25
colnames(cucumis)

cucumis.all <- write.csv(cucumis, '../data/Cucumis/Cucumis.all.csv', row.names=F)
cucumis.all <- read.csv('../data/Cucumis/Cucumis.all.csv')
colnames(cucumis.all)
head(cucumis.all); dim(cucumis.all) # 29578    25

plot(countries); points(cucumis.all$lon, cucumis.all$lat, pch=19, col=cucumis.all$species)
table(cucumis.all$species)
table(as.character(cucumis.all$basisOfRecord))
cucumis.fossil <- cucumis.all[which(cucumis.all$basisOfRecord =="fossil"),]
cucumis.all <- cucumis.all[which(cucumis.all$basisOfRecord !="fossil"),] # remove fossil records
cucumis.living <- cucumis.all[which(cucumis.all$basisOfRecord =="living"),] # living collections
table(as.character(cucumis.living$species))
head(cucumis.living)
plot(countries); points(cucumis.living$lon, cucumis.living$lat, pch=19, col=cucumis.living$species)
cucumis.all <- cucumis.all[which(cucumis.all$basisOfRecord !="living"),] # remove living records, likely greenhouse grown plants and not wild species, or CWR
head(cucumis.all); dim(cucumis.all) #26656    25
table(as.character(cucumis.all$basisOfRecord))
cucumis.all[1:100,]
str(cucumis.all)

### Cleaning - remove collections from greenhouses and markets, etc.

pattern <- "horti|greenhous|bot. gar|botanical garden|bot gar|wageningen|veredel|moscow|market|experi"
x <- grep(pattern, cucumis.all$cloc, ignore.case = T)
cucumis.all[x,'cloc']
dim(cucumis.all[x,]) # 318
cucumis.all <- cucumis.all[-x,]
dim(cucumis.all) #26338    25
head(cucumis.all)
table(cucumis.all$species, exclude=NULL)

pattern <- "Netherlands Antilles" # Gives error in geocode - see below
x <- grep(pattern, cucumis.all$cloc, ignore.case = T)
cucumis.all[x,'cloc']
dim(cucumis.all[x,]) # 318
cucumis.all <- cucumis.all[-x,]
dim(cucumis.all) #26313    25
head(cucumis.all)
table(cucumis.all$species, exclude=NULL)

### Cucumis hystrix
cucumis.hystrix.search <- grep('cucumis hystrix', cucumis.all$species, ignore.case=T, value=T)
cucumis.hystrix <- cucumis.all[which(cucumis.all$species %in% cucumis.hystrix.search),]
cucumis.hystrix # 19 records
cucumis.hystrix[,c('lat', 'lon', 'locality', 'cloc')]

### Unique species names

cucumis.all$species <- as.factor(as.character(cucumis.all$species))
species.names <- data.frame(table(cucumis.all$species))
species.names # 628
write.csv(species.names, '../data/Cucumis/cucumis.species.csv')

### 2. Georeference records lacking coordinates but with locality description ####

# Records with missing coordinates
head(cucumis.all); dim(cucumis.all) # 26313    25
cond <- ((is.na(cucumis.all$lat) & is.na(cucumis.all$lon)) | cucumis.all$lat ==0 & cucumis.all$lon ==0)
summary(cond)
# cucumis.coords <- subset(cucumis.all, ((!is.na(lat) & !is.na(lon)) | (cucumis.all$lat != 0 & cucumis.all$lon != 0)))
cucumis.coords <- cucumis.all[!cond,]
head(cucumis.coords); dim(cucumis.coords) # 9860 25  records with coordinates
data.frame(table(as.factor(as.character(cucumis.coords$species)), exclude=NULL))
str(cucumis.all)
cucumis.all$locality <- as.character(cucumis.all$locality)
cucumis.all$cloc <- as.character(cucumis.all$cloc)

# georef.1 <- subset(cucumis.all, (is.na(lat) & is.na(lon) & !is.na(cloc))) # lat & lon & cloc missing = NA
georef.1 <- cucumis.all[cond,]
head(georef.1); dim(georef.1) # 16453    25
georef.2 <- subset(georef.1, (!georef.1$cloc == "" & !georef.1$cloc == "Unknown" & !georef.1$cloc == "ND" & !georef.1$cloc == "Not available")) # remove empty, unknown and ND
head(georef.2); dim(georef.2) # 16187   25; localities lacking coordinates but with locality description

cucumis.hystrix.georef.2.search <- grep('cucumis hystrix', georef.2$species, ignore.case=T, value=T) # 19 records
cucumis.hystrix.georef.2.search
cucumis.hystrix.georef.2 <- georef.2[which(georef.2$species %in% cucumis.hystrix.georef.2.search),]
cucumis.hystrix.georef.2

georef.2[1:100, c("cloc")]
georef.3 <- subset(cucumis.all, (cucumis.all$lat == 0 & cucumis.all$lon == 0 & !is.na(cloc))) # lat & lon are 0
head(georef.3); dim(georef.3) # 0    25

georef <- rbind(georef.2, georef.3) # All records with cloc but without coordinates
head(georef); dim(georef) # 16187    25
colnames(georef)
str(georef)
duplicates.cloc <- duplicated(georef[, c('cloc')])
table(duplicates.cloc) # 2539 13648
unique.cloc <- georef[!duplicates.cloc,]
head(unique.cloc); dim(unique.cloc) # 2539   25; unique localities lacking coordinates but with locality description
write.csv(unique.cloc, '../data/Cucumis/unique.cloc.csv', row.names=F)
unique.cloc <- read.csv('../data/Cucumis/unique.cloc.csv', h=T)
#unique.cloc <- unique.cloc[,2:26]
head(unique.cloc); dim(unique.cloc) # 2539   25
str(unique.cloc)
unique.cloc$cloc <- as.character(unique.cloc$cloc)
str(unique.cloc)

#georef.Netherlands.Antilles <- unique.cloc[which(unique.cloc$cloc =="Netherlands Antilles"),] # gives weird error - cannot figure out what going wrong?
#georef <- georef[which(georef$cloc !="Netherlands Antilles"),]

### 3. Automated georeferencing using GOOGLE API ####
### Has a 2500 maximum daily number of requests - 1st run till 1098
### error: You have exceeded your daily request quota for this API

unique.cloc.2539 <- unique.cloc

try(geocode('Caimancito, JUJUY, Ledesma, Argentina, SOUTH AMERICA'))
try(geocode('Caimancito, Argentina'))
try(geocode('Ban-chiou-chian, Che-li Hsien, Yunnan, Jinghong, China, Asia'))
geocode('Che-li Hsien, Yunnan, Jinghong, China, Asia')
geocode("Jardin d'exp?rience de Collioure, de l'int?rieure de l'Afrique, Namibia")
geocode('Jardin d exp?rience de Collioure, de l int?rieure de l Afrique, Namibia')

unique.cloc$cloc.clean <- gsub("'", " ",unique.cloc$cloc)  # remove ' from cloc names

### Replace coordinates with Google coordinates if accuracy is within uncertainty
uncertainty <- 10000 # in meters = 10km

#j=10

unique.cloc[1226,]

#for(j in 1:nrow(unique.cloc)){
for(j in 1463:nrow(unique.cloc)){
  Sys.sleep(0.5) # wait 0.5 seconds
  b <- geocode(unique.cloc$cloc.clean[j])
  print(j)
  #b
  #str(b)
  b2 <- subset(b, b$uncertainty == min(b$uncertainty)) # select record with least uncertainty
  #b2
  #dim(b2)
  if(dim(b2)[1] == 0){
    unique.cloc[j,'lat'] <- unique.cloc[j,'lat'] #; print(1)
    unique.cloc[j,'lon'] <- unique.cloc[j,'lon'] #; print('a')  
  } else {
    b2 <- b2[1,] # sometimes 2 same minimum values i.e. geocode('Austria,Niederoesterreich,Weinviertel,Katzelsdorf')
    if(b2[,'uncertainty'] < uncertainty) {
      unique.cloc[j,'lat'] <- b2[,'latitude']
      unique.cloc[j,'lon'] <- b2[,'longitude']
      unique.cloc[j,'coordUncertaintyM'] <- b2[,'uncertainty']
    }  else {
      unique.cloc[j,'lat'] <- unique.cloc[j,'lat']
      unique.cloc[j,'lon'] <- unique.cloc[j,'lon']
    }
  }
}

head(unique.cloc)
write.csv(unique.cloc[1463:2539,], '../data/Cucumis/unique.cloc.geocode.1463.2539.csv', row.names=F)
write.csv(unique.cloc, '../data/Cucumis/unique.cloc.geocode.x.csv', row.names=F)
# Pasted in excel

unique.cloc.geocode <- read.csv('../data/Cucumis/unique.cloc.geocode.1.2539.csv')
head(unique.cloc.geocode); dim(unique.cloc.geocode) # 2539   26
unique.cloc.geocode[1:100, c("lat", "lon")]
unique.cloc.geocode <- subset(unique.cloc.geocode, (!is.na(lat) & !is.na(lon)))
head(unique.cloc.geocode); dim(unique.cloc.geocode) # 837  26 localities georeferenced with Google
names(unique.cloc.geocode)
unique.cloc.geocode <- unique.cloc.geocode[,c('cloc', 'lat', 'lon', 'coordUncertaintyM')]
unique.cloc.geocode <- unique.cloc.geocode[order(unique.cloc.geocode[,'cloc']), ]
head(unique.cloc.geocode)

### 4. merge unique.cloc.geocode with georef to link coordinates to collection localities ####

head(georef)
names(georef)
dim(georef) # 16187    25
str(georef)
georef <- georef[order(georef[,'cloc']), ]

str(unique.cloc.geocode)
unique.cloc.geocode$cloc <- as.character(unique.cloc.geocode$cloc)
head(unique.cloc.geocode)
unique.cloc.geocode <- unique.cloc.geocode[order(unique.cloc.geocode[,'cloc']), ]

georef.coords <- merge(georef, unique.cloc.geocode, by='cloc', all.x=T, incomparables = NA)
dim(georef.coords) # 16187    28
head(georef.coords)
georef.coords[1:50,]
names(georef.coords)
georef.coords[1:50,c('lat.x', 'lat.y', 'lat.x', 'lat.y')]
dim(georef.coords)
head(georef.coords)

colnames(georef); colnames(georef.coords)
georef$lat <- georef.coords$lat.y
georef$lon <- georef.coords$lon.y # replace original NA's with merged data
head(georef)
georef[1:50, c("lat", "lon")]
georef.coords <- subset(georef, !is.na(lat) & !is.na(lon))
head(georef.coords); dim(georef.coords) # 1399 25
georef.coords[1:100,c("lat", "lon", "locality")]

### Cucumis hystrix
cucumis.hystrix.georef <- grep('cucumis hystrix', georef.coords$species, ignore.case=T, value=T)
cucumis.hystrix <- georef.coords[which(georef.coords$species %in% cucumis.hystrix.search),]
cucumis.hystrix # Only 6 received coordinates through Google below, which is correct!
plot(countries); points(cucumis.hystrix$lon, cucumis.hystrix$lat, pch=19, col='red')

### 5. Combine datasets ####

cucumis.all.coords <- rbind(cucumis.coords, georef.coords)
colnames(cucumis.all.coords)
plot(countries); points(cucumis.all.coords$lon, cucumis.all.coords$lat, pch=19, col=cucumis.all.coords$species)
duplicates <- duplicated(cucumis.all.coords[,c("species", "lat", "lon")])
table(duplicates, exclude=NULL)
cucumis.all.coords <- cucumis.all.coords[!duplicates,]
dim(cucumis.all.coords) # 8308
str(cucumis.all.coords)
cucumis.all.coords$species <- as.factor(as.character(cucumis.all.coords$species))
plot(countries); points(cucumis.all.coords$lon, cucumis.all.coords$lat, pch=19, col=cucumis.all.coords$species)

### Cucumis hystrix
cucumis.hystrix.georef <- grep('cucumis hystrix', cucumis.all.coords$species, ignore.case=T, value=T)
cucumis.hystrix <- cucumis.all.coords[which(cucumis.all.coords$species %in% cucumis.hystrix.search),]
cucumis.hystrix # Only 5 unique with coordinates through Google below, which is correct!
plot(countries); points(cucumis.hystrix$lon, cucumis.hystrix$lat, pch=19, col='red')

### 6. resolve synonymy ####

species.628.ncbi <- read.table('../data/Cucumis/species.ncbi.txt', header=T, sep = '\t') # Hannes Hettling
head(species.628.ncbi); dim(species.628.ncbi)
cucumis.species <- read.csv('../data/Cucumis/cucumis.species.csv')
head(cucumis.species); dim(cucumis.species)
table(species.628.ncbi$ncbi_name, exclude=NULL)
cucumis.species <- as.data.frame(cucumis.species$Var1)
colnames(cucumis.species)[1] <- c("name")
cucumis.species <- cbind(cucumis.species, species.628.ncbi[,2:18])
head(cucumis.species)

### prepare data

head(cucumis.species); dim(cucumis.species) # 628 18
splist <- as.character(cucumis.species[,1])
write.table(splist, '../data/Cucumis/splist.csv', sep=",", row.names=F, col.names=F)
length(splist) # 628 unique names in data file

# tnrs function produces duplicate entries - reason not known??? -> solution loop per species
# Create empty results.matrix for results - results.matrix ###
tnrs1 <- tnrs(query=splist[1], getpost="POST", source="iPlant_TNRS"); tnrs1
seq1 <- seq(1:7) # tnrs returns 7 columns
results.matrix <- matrix(seq1, 1) # data, nrows, ncols, etc.
colnames(results.matrix) <- colnames(tnrs1)
results.matrix
results.matrix <- results.matrix[-1,] # remove dummy first row
dim(results.matrix)
rm(seq1, tnrs1) # remove seq1

#t=splist[4]; t=3
#t='Cucumis agrestis'

results <- results.matrix
{
  for(t in 1:length(splist)){
    
    splist_tnrs <- tnrs(query=splist[t], getpost="POST", source="iPlant_TNRS")
    
    #str(splist_tnrs)
    if(dim(splist_tnrs)[1] == 0) {
      splist.names <- names(splist_tnrs)
      splist_tnrs <- data.frame(matrix(rep(NA, 7), 1))
      names(splist_tnrs) <- splist.names
    }  else {
      splist_tnrs = splist_tnrs
    }
    
    results <- rbind(results, splist_tnrs)
    cat("-") # print dash
    if (t%%50 == 0) # %% is modulus
      cat(" ", t, "\n")
    # flush.console()
  }
  if (t%%50 != 0) {
    cat(" ", t, "\n")
  }
  else {
    cat("\n")
    flush.console()
  }
}

results <- cbind(data.frame(splist), results)
head(results); dim(results); names(results)
results <- cbind(results, species.628.ncbi[,2:18])
write.csv(results, '../data/Cucumis/species.628.ncbi.tnrs.csv', row.names=F)

##################################
### Manually check results !!! ###
##################################

cucumis.names <- read.csv('../data/Cucumis/species.628.ncbi.tnrs_corr.csv', h=T)
str(cucumis.all.coords); dim(cucumis.all.coords) # 8308   25
head(cucumis.all.coords)
names(cucumis.all.coords)
cucumis.all.coords <- cucumis.all.coords[order(cucumis.all.coords[,'species']), ]

names(cucumis.names)
head(cucumis.names) # splist.v2 -> cleaned blank spaces in splist
cucumis.names <- cucumis.names[order(cucumis.names[,'splist']), ]

### 7. Merge records ####

# Note splist from original GBIF names. These include double blank spaces which were removed in splist.v2
cucumis.corr <- merge(cucumis.all.coords, cucumis.names[,c('splist', 'acceptedname')], by.x="species", by.y="splist", all.x=TRUE) # right outer join
names(cucumis.corr)
head(cucumis.corr)
dim(cucumis.corr) # 8308 26
cucumis.corr <- cucumis.corr[which(cucumis.corr$acceptedname != "NA"), ]
cucumis.corr$acceptedname <- as.factor(as.character(cucumis.corr$acceptedname))
head(cucumis.corr)
dim(cucumis.corr) # 8160 26
str(cucumis.corr)
sort(unique(cucumis.corr$acceptedname))
as.data.frame(table(cucumis.corr$acceptedname))

plot(countries);points(cucumis.corr$lon, cucumis.corr$lat, pch=19, col=cucumis.corr$acceptedname)
data.frame(table(cucumis.corr$acceptedname, exclude=NULL))
dim(data.frame(table(cucumis.corr$acceptedname, exclude=NULL))) # 63 species with georeferenced records

### Cucumis hystrix
cucumis.hystrix.search2 <- grep('cucumis hystrix', cucumis.corr$acceptedname, ignore.case=T, value=T)
cucumis.hystrix.coords <- cucumis.corr[which(cucumis.corr$acceptedname %in% cucumis.hystrix.search2),]
cucumis.hystrix.coords # 5 records
plot(countries);points(cucumis.hystrix.coords$lon, cucumis.hystrix.coords$lat, pch=19, col='red')

sp.accept <- data.frame(c(sort(trim(unique(as.character(cucumis.corr$acceptedname))))))
sp.accept

coordinates(cucumis.corr) <- ~lon+lat
cucumis.corr@proj4string <- P4S.latlon
head(cucumis.corr)
plot(countries);plot(cucumis.corr, pch=19, col=cucumis.corr$acceptedname, add=T)
str(cucumis.corr)

### 8. Create PET ####

files.present <- list.files('D:/GIS/Worldclim/Present/5arcmin/bio/', pattern="[.]bil$", full.names=T) # alternatives for pattern (c|C)(e|E)(l|L)$
# files <- list.files('Z:/World/Climate/Worldclim/05arcmin/Present/bio/', pattern="[.]bil$", full.names=T) # alternatives for pattern (c|C)(e|E)(l|L)$
files.present
present.stack <- stack(files.present)
present.df <- as.data.frame(present.stack, xy=T)
head(present.df)
present.df <- na.omit(present.df)
dim(present.df) # 2287025      23
present.df$bio01a <- present.df$bio01/10 # calculate PET (Loiselle 2008; http://onlinelibrary.wiley.com/doi/10.1111/j.1365-2699.2007.01779.x/abstract)
present.df$bio01a[present.df$bio01a < 0] <- 0
present.df$bio01a[present.df$bio01a > 30] <- 0
present.df$PET <- ((present.df$bio01a/present.df$bio12)*58.93)
present.df$PET[present.df$PET > 100] <- 100 # or NA
summary(present.df$PET)
coordinates(present.df) <- ~x+y
gridded(present.df) = T
str(present.df)
present.df@proj4string <- P4S.latlon
str(present.df)
head(present.df)
dim(present.df) # 2287025      21
summary(present.df$PET)

drops <- c("bio01a")
present.df <- present.df[,!(names(present.df) %in% drops)]
r <- raster(present.df, 'PET')
plot(r); plot(cucumis.corr, add=T)

alt <- raster(files.present[1])
plot(alt)
extent(alt)

r <- extend(r, extent(alt))
writeRaster(r, 
            filename  = "D:/GIS/Worldclim/Present/5arcmin/PET/PET.present.asc",
            format    = 'ascii',
            NAflag    = -9999,
            overwrite = T)

PET.present <- raster('D:/Papers.Projects/Climate.Smart.Agriculture/GIS/present/PET.present.asc')
plot(PET.present)

### 9. Compile climate data ####

files.present <- list.files('D:/GIS/Worldclim/Present/5arcmin/bio/', pattern="[.]bil$", full.names=T) # alternatives for pattern (c|C)(e|E)(l|L)$
# files <- list.files('Z:/World/Climate/Worldclim/05arcmin/Present/bio/', pattern="[.]bil$", full.names=T) # alternatives for pattern (c|C)(e|E)(l|L)$
files.present
PET.file <- "D:/GIS/Worldclim/Present/5arcmin/PET/PET.present.asc"
DSL.file <- "D:/GIS/Worldclim/Present/5arcmin/DSL/dsl.100.present.asc"
GDD.10.file <- "D:/GIS/Worldclim/Present/5arcmin/GDD/gdd.base.10.asc"
files.present <- c(files.present, PET.file, DSL.file, GDD.10.file)
present.stack <- stack(files.present[2:23])
head(present.stack)
present.df <- as.data.frame(present.stack, xy=T)
coordinates(present.df) <- ~x+y
gridded(present.df) <- T
present.df@proj4string <- P4S.latlon
present.df$grid.index <- present.df@grid.index # Add grid.index value
head(present.df)
image(present.df, 'gdd.base.10')

### 10. Get abiotic data and remove duplicates - cucumis.unique ####

str(cucumis.corr)
str(present.df)
cucumis.abiotic <- over(cucumis.corr, present.df) # Get climate variables + grid.index for Cucumis collections
str(cucumis.abiotic)
head(cucumis.abiotic)
dim(cucumis.abiotic); dim(cucumis.corr)
head(cucumis.corr); str(cucumis.corr)
cucumis.corr <- cbind(cucumis.corr, cucumis.abiotic) # Link collections and climate data
head(cucumis.corr)
duplicates <- duplicated(cucumis.corr[,c("acceptedname", "grid.index")]) # Duplicates on grid.index
table(duplicates) # 6695 F 1465 T
cucumis.unique <- cucumis.corr[!duplicates,] # remove duplicates
str(cucumis.unique)
head(cucumis.unique)
dim(cucumis.unique) # 6695   49
summary(cucumis.unique)
cucumis.unique <- cucumis.unique[which(cucumis.unique$PET !="NA"),]
dim(cucumis.unique) # 6615   49
str(cucumis.unique)
head(cucumis.unique)
data.frame(table(cucumis.unique$acceptedname)) # 63 species
plot(raster(present.df, 'gdd.base.10')); points(cucumis.unique$lon, cucumis.unique$lat, col=cucumis.unique$acceptedname)

### 11. Cross check georeference with country polygons
###     and remove records from non-native countries

countries.poly <- readShapePoly("D:/GIS/Administrative/world/33578/world_country_admin_boundary_shapefile_with_fips_codes")
proj4string(countries.poly) <- "+proj=longlat +datum=WGS84"
plot(countries.poly)
class(countries.poly)
names(countries.poly)
str(countries.poly)
head(countries.poly$CNTRY_NAME)

names(cucumis.unique)
coordinates(cucumis.unique) <- ~lon+lat
proj4string(cucumis.unique) <- "+proj=longlat +datum=WGS84"

ov <- over(cucumis.unique, countries.poly) # Get country values from shape
head(ov)
ov$CNTRY_NAME <- as.character(ov$CNTRY_NAME)
cucumis.unique$country <- as.character(cucumis.unique$country)
j <- which(ov$CNTRY_NAME != cucumis.unique$country) # Identify records with different country at records level than from polygon
j
cbind(j, cbind(cucumis.unique$country, ov$CNTRY_NAME)[j,])
j2 <- c(349, 355, 369, 404, 545, 827, 951, 1148, 1195, 1389, 1446, 1862, 1905, 2074, 2080, 2677, 2689, 3093, 3437, 3482, 3709, 3722, 4032, 4059, 4100, 4125, 4136, 5133, 5183, 5264, 5321, 5589, 5623, 5686, 5929, 6150, 6198, 6514, 6515, 6572)

cucumis.unique.corr <- cucumis.unique[-j2,] # Remove wrong records
ov2 <- over(cucumis.unique.corr, countries.poly)
head(ov2)
ov2$CNTRY_NAME <- as.character(ov2$CNTRY_NAME)
cucumis.unique.corr$country <- as.character(cucumis.unique.corr$country)
j3 <- which(ov2$CNTRY_NAME != cucumis.unique.corr$country)
j3
cbind(j3, cbind(cucumis.unique.corr$country, ov2$CNTRY_NAME)[j3,])

head(cucumis.unique.corr)
dim(cucumis.unique.corr) # 6575   47
data.frame(table(cucumis.unique.corr$acceptedname))

### Remove unlikely countries, i.e. Netherlands
# Native range of Cucumis is restricted to Africa/Madagascar - Asia - Australia
# Not to blur the niche properties with agricultural treatments we removed all records from non-native range

names(cucumis.unique.corr)
unique.countries <- sort(unique(cucumis.unique.corr$country))
unique.countries
str(unique.countries)
non.native.countries <- c("Albania", "Argentina", "Austria", "Belgium", "Belize", "Bolivia", "Bosnia and Herzegovina", "Brazil", "Bulgaria", "Canada", "Chile", "Croatia", "Colombia", "Costa Rica", "Cuba", "Cyprus", "Czech Republic", "Dominican Republic", "Ecuador", "El Salvador", "Finland", "France", "Germany", "Greece", "Guatemala", "Guyana", "Honduras", "Hungary", "Italy", "Japan", "Liechtenstein", "Macedonia", "Mexico", "Moldova", "Netherlands", "New Caledonia", "Nicaragua", "Norway", "Panama", "Paraguay", "Peru", "Poland", "Portugal", "Puerto Rico", "Romania", "Russia", "Serbia", "Slovakia", "South Korea", "Spain", "Sweden", "Switzerland", "Ukraine", "United Kingdom", "United States", "Venezuela")

cucumis.unique.corr <- cbind(cucumis.unique.corr@coords, cucumis.unique.corr@data)
str(cucumis.unique.corr)
head(cucumis.unique.corr)
x <- cucumis.unique.corr$country %in% non.native.countries
table(x)
cucumis.unique.corr$non.native <- x
head(cucumis.unique.corr)
cucumis.unique.corr <- cucumis.unique.corr[cucumis.unique.corr$non.native == FALSE,]
dim(cucumis.unique.corr) # 4374   50
cucumis.unique.corr <- cucumis.unique.corr[(cucumis.unique.corr$lon > -30 & cucumis.unique.corr$lat < 47),]
dim(cucumis.unique.corr) # 4371   50
plot(countries); points(cucumis.unique.corr$lon, cucumis.unique.corr$lat, col=cucumis.unique.5$acceptedname, pch=19)

### 10. Select records for species wit more than 5 records ####

head(cucumis.unique.corr)
dim(cucumis.unique.corr) # 4371   50
str(cucumis.unique.corr)
cucumis.unique.corr$acceptedname <- as.factor(as.character(cucumis.unique.corr$acceptedname))
data.frame(table(cucumis.unique.corr$acceptedname, exclude=NULL))
cucumis.5 <- data.frame(table(cucumis.unique.corr$acceptedname))
cucumis.5
str(cucumis.5)
cucumis.5 <- cucumis.5[which(cucumis.5$Freq >= 5),]
cucumis.5 <- c(as.character(cucumis.5$Var1))
cucumis.unique.5 <- cucumis.unique.corr[cucumis.unique.corr$acceptedname %in% cucumis.5, ]
dim(cucumis.unique.5) # 4335   50
length(unique(cucumis.unique$acceptedname)) # 63
length(unique(cucumis.unique.5$acceptedname)) # 41 species with >=5 records
str(cucumis.unique.5)
head(cucumis.unique.5)

write.csv(cucumis.5, "D:/Papers.Projects/Climate.Smart.Agriculture/data/Cucumis/cucumis.5.csv", row.names=F)
write.csv(cucumis.unique.5, "D:/Papers.Projects/Climate.Smart.Agriculture/data/Cucumis/cucumis.unique.5.csv", row.names=F)
plot(countries); points(cucumis.unique.5$lon, cucumis.unique.5$lat, col=cucumis.unique.5$acceptedname, pch=19)

cucumis.unique.5 <- read.csv("D:/Papers.Projects/Climate.Smart.Agriculture/data/Cucumis/cucumis.unique.5.csv")
head(cucumis.unique.5); dim(cucumis.unique.5) # 4335   50
cucumis.5 <- read.csv("D:/Papers.Projects/Climate.Smart.Agriculture/data/Cucumis/cucumis.5.csv")
head(cucumis.5)
str(cucumis.5)
cucumis.5 <- as.vector(cucumis.5)

### 11. PCA Cucumis.unique.5 ####

head(cucumis.unique.5)
str(cucumis.unique.5)
names(cucumis.unique.5)
summary(cucumis.unique.5[,27:48])

pc <- dudi.pca(cucumis.unique.5[,27:48], center=T, scale=T, scannf=F) # PCA
str(pc)
pc$tab$acceptedname <- cucumis.unique.5$acceptedname
plot(pc$li$Axis1, pc$li$Axis2, asp=1, col=pc$tab$acceptedname)
scatter(pc)

pc$eig
barplot(pc$eig)
var1 <- (pc$eig[1]/sum(pc$eig))*100
var1 # 38.93919
var2 <- (pc$eig[2]/sum(pc$eig))*100
var2 # 26.31047
var3 <- (pc$eig[3]/sum(pc$eig))*100
var3 # 9.544308
var <- var1 + var2 + var3
var # 74.79396

### 12. Run Maxent models in 1000 km buffered area around presences to balance prevalence - from null.model.buffer ####

### Visualize data ###
r <- raster("Z:/World/Climate/Worldclim/05arcmin/Present/bio/bio01.bil")
r <- raster("D:/GIS/Worldclim/Present/5arcmin/bio/bio01.bil")
plot(r)
plot(countries, add=T)
str(r)
dim(r)

### Write ascii layers and create dataframe for present

files.present

for(i in files.present[2:23])  {
  raster <- raster(i)
  #raster <- crop(raster, ext.sunda)
  writeRaster(raster, 
              filename  = paste("D:/Papers.Projects/Climate.Smart.Agriculture/GIS/present/", basename(i), sep = ""),
              format    = 'ascii',
              NAflag    = -9999,
              overwrite = T)
}

present.stack <- stack(files.present[2:23])
present.df <- as.data.frame(present.stack, xy=T)
head(present.df); dim(present.df) # 7776000      24

### Create empty mask layer

mask <- raster(files.present[1])
plot(mask)
# set.seed(1963)
# bg <- randomPoints(mask, 100)
# head(bg)
plot(!is.na(mask)); points(bg, pch=19, cex=0.5) # 100 random points from mask
mask <- !is.na(mask)
mask[mask == 0] <- NA
plot(mask)
summary(mask)
writeRaster(mask, filename  = "D:/Papers.Projects/Climate.Smart.Agriculture/GIS/present_project/mask.asc", format = 'ascii', NAflag = -9999, overwrite = T)
mask <- raster('D:/Papers.Projects/Climate.Smart.Agriculture/GIS/present_project/mask.asc')
plot(mask, col='red')

# add mask to present.df
# present.df$mask <- as.data.frame(stack('D:/Papers.Projects/Climate.Smart.Agriculture/GIS/present_project/mask.asc')) 
# head(present.df); dim(present.df) # 7776000      25

### Loop all SDMs

i=22
i=3

for(i in 3:length(cucumis.5)){ # First 2 species not Cucumis!!!
  #for(i in 1:2){
  species <- cucumis.5[i]
  species
  # head(cucumis.unique.5)
  cucumis.unique.species <- cucumis.unique.5[cucumis.unique.5$acceptedname %in% species, ] # retrieve species records
  dim(cucumis.unique.species) # 16 50
  head(cucumis.unique.species)
  cucumis.unique.species <- cucumis.unique.species[, c("acceptedname", "lon", "lat")]
  names(cucumis.unique.species) <- c("species", "lon", "lat")
  head(cucumis.unique.species)
  plot(countries); points(cucumis.unique.species$lon, cucumis.unique.species$lat, pch=19, col='red')
  cucumis.unique.species <- cucumis.unique.species[which(cucumis.unique.species$lon < 170),] # otherwise the polygons cannot be drawn, extent over 180 degrees
  write.csv(cucumis.unique.species, gsub(' ', '_', (paste('D:/Papers.Projects/Climate.Smart.Agriculture/data/Cucumis/maxentSpecies/', species, '.csv', sep=""))), row.names=F) # write species points file
  
  # Convert to spatial Points Data Frame and create 1000km buffer
  coordinates(cucumis.unique.species) <- ~lon+lat
  proj4string(cucumis.unique.species) <- P4S.latlon
  plot(countries); points(cucumis.unique.species, pch=19, cex=0.5, col='red')
  x <- circles(cucumis.unique.species, d=1000000, lonlat=TRUE) # 1000 km
  pol <- gUnaryUnion(x@polygons) # dissolve polygons
  # extent(pol)
  plot(pol, col='blue', add=T); points(cucumis.unique.species, pch=19, cex=0.5, col='red')
  
  # extract cell numbers for the circles
  v <- extract(mask, x@polygons, cellnumbers=T)
  # str(v)
  # use rbind to combine the elements in list v
  v <- do.call(rbind, v)
  # head(v); dim(v)
  
  # remove ocean cells
  v <- unique(na.omit(v))
  head(v); dim(v)
  # to display the results
  m <- mask
  m[] <- NA
  m[as.vector(v[,1])] <- 1
  plot(m, col='red')
  extent(m)
  str(m); summary(m)
  plot(m, ext=extent(x@polygons)+1, col='blue', add=T) # xlim = c((x@polygons@bbox[1,1]-5),(x@polygons@bbox[1,2]+5)), ylim = c((x@polygons@bbox[2,1]-5),(x@polygons@bbox[2,2]+5)),
  plot(x@polygons, add=T)
  points(cucumis.unique.species, pch=19, cex=0.5, col='red')
  plot(countries, add=T)
  # str(m)
  
  # Write mask for buffered areas
  writeRaster(m, filename  = "D:/Papers.Projects/Climate.Smart.Agriculture/GIS/present/mask.asc", format = 'ascii', NAflag = -9999, overwrite = T)
  # mask.buffer <- raster("D:/Papers.Projects/Climate.Smart.Agriculture/GIS/present/mask.asc")
  # plot(mask.buffer)
  
  ### Add mask.buffer to present.df
  head(present.df); dim(present.df) # 7776000      24
  # present.df <- subset(present.df, select = -c(mask)) # remove mask column
  
  present.species.df <- present.df # copy present.df
  mask.buffer.df <- as.data.frame(stack('D:/Papers.Projects/Climate.Smart.Agriculture/GIS/present/mask.asc'), xy=T) # read mask layer
  head(mask.buffer.df); dim(mask.buffer.df); colSums(mask.buffer.df, na.rm=T, dims=1)
  present.species.df$mask <- mask.buffer.df[,'mask']
  head(present.species.df); dim(present.species.df)
  present.species.df <- na.omit(present.species.df)
  head(present.species.df); dim(present.species.df) 
  ### Select uncorrelated variables using VIF
  
  ### Variance Inflation Factor within buffered area ####
  # A VIF for a single explanatory variable is obtained using the r-squared value of the regression of that variable against all other explanatory variables (http://www.r-bloggers.com/collinearity-and-stepwise-vif-selection/)
  
  x <- sample(1:(dim(present.species.df)[1]), 10000, replace=F) # sample 10k background points for the VIF
  sample.df <- present.species.df[x,]
  head(sample.df); dim(sample.df)
  plot(countries); points(sample.df$x, sample.df$y, col='green'); plot(countries, add=T)
  sample.matrix <- as.matrix(sample.df[,3:25])
  head(sample.matrix); dim(sample.matrix) # 10000 23
  
  ### VIF ###
  #keep.dat <- vif_func(in_frame = sample.matrix[,1:22], thresh=5, trace=T) # thresh=5
  #keep.dat
  keep.dat <- colnames(sample.matrix[,1:22]) # To use all variables
  ###########
  
  keep.dat <- c(keep.dat, 'mask')
  str(keep.dat)
  sample.matrix.keep <- sample.matrix[, (colnames(sample.matrix) %in% keep.dat)]
  head(sample.matrix.keep); dim(sample.matrix.keep) # 10000 10 - BACKGROUND SAMPLE
  summary(sample.matrix.keep)
  sample.df.keep <- data.frame(sample.matrix.keep) 
  dim(sample.df.keep) # BACKGROUND SAMPLE DATAFRAME
  
  # Species dataframe for keep.dat
  cucumis.unique.species.df <- cucumis.unique.5[cucumis.unique.5$acceptedname %in% species, (colnames(cucumis.unique.5) %in% keep.dat)] # retrieve species records
  head(cucumis.unique.species.df); dim(cucumis.unique.species.df) # 35 9
  cucumis.unique.species.df$mask <- 1 # Add mask column
  names(cucumis.unique.species.df)
  
  ### Create directory
  species
  
  mainDirMaxent <- "D:/Papers.Projects/Climate.Smart.Agriculture/data/Cucumis/maxentOutput"
  # subDirMaxent <- gsub(" ", "_", species)
  
  #if (file.exists(subDirMaxent)){
  #  print('directory exists')
  # } else {
  #  dir.create(file.path(mainDirMaxent, subDirMaxent))
  #}
  
  ##############
  ### MAXENT ###
  ##############
  
  ### CHECK FOLDER NAMES !!!
  ### Logistic
  swd <- rbind(cucumis.unique.species.df, sample.df.keep); dim(swd) # swd dataframe
  pa <- c(rep(1, nrow(cucumis.unique.species.df)), rep(0, nrow(sample.df.keep))); length(pa) # presence/absence vector
  me <- maxent(swd, pa, args = c("noproduct", "nothreshold", "nohinge", "noextrapolate", "outputformat=logistic", "jackknife", "applyThresholdRule=10 percentile training presence", "projectionlayers=D:/Papers.Projects/Climate.Smart.Agriculture/GIS/present", "redoifexists"), path=file.path(mainDirMaxent)) # path=file.path(mainDirMaxent, subDirMaxent), "projectionlayers=D:/Papers.Projects/Climate.Smart.Agriculture/GIS/present,D:/Papers.Projects/Climate.Smart.Agriculture/GIS/present_project" 10 percentile training presence
  
  ### Raw format
  #me <- maxent(swd, pa, args = c("noproduct", "nothreshold", "nohinge", "noextrapolate", "outputformat=raw", "jackknife", "projectionlayers=D:/Papers.Projects/Climate.Smart.Agriculture/GIS/present,D:/Papers.Projects/Climate.Smart.Agriculture/GIS/present_project", "redoifexists"), path=file.path(mainDirMaxent)) # path=file.path(mainDirMaxent, subDirMaxent) , "applyThresholdRule=Maximum training sensitivity plus specificity"
  
  # present - with species specific mask
  # present_project - global projection: BE AWARE i.e. Temp. seasonality can be similar in tropical and temperate regions, therefore global projections are not reliable!!!
  
  me
  # str(me)
  # me@lambdas
  # plot(me)
  response(me)
  
  eval <- evaluate(me, p=cucumis.unique.species.df, a=sample.df.keep)
  eval
  str(eval)
  AUC <- eval@auc
  AUC
  threshold(eval)
  plot(eval, 'ROC')
  
  # Replace file names with species names
  filez <- list.files(path=file.path(mainDirMaxent), pattern="species", full.names=T)
  filez
  sapply(filez, FUN = function(eachPath){
    file.rename(from = eachPath, to = sub(pattern ="species", replacement = gsub(" ", "_", species), eachPath))
  })
  
  ### Some files are locked by r.sessions - file.copy solution
  filez <- list.files(path=file.path(mainDirMaxent), pattern="species", full.names=T)
  filez
  file.info(filez)
  for(i in 1:length(filez)){
    file.copy(filez[i], gsub('species', gsub(" ", "_", species), filez[i]))
  }
  
  # maxentResults
  file.rename(from = paste(file.path(mainDirMaxent), '/maxentResults.csv', sep=""), to = paste(file.path(mainDirMaxent), "/", gsub(" ", "_", species), '_maxentResults.csv', sep=""))
  
  # plots folder
  filez2 <- list.files(paste(path=file.path(mainDirMaxent), '/plots', sep=""), pattern="species", full.names=T)
  filez2
  sapply(filez2, FUN = function(eachPath){
    file.rename(from = eachPath, to = sub(pattern ="species", replacement = gsub(" ", "_", species), eachPath))
  })
  
  ### Species map ###
  
  #   par(mfrow=c(1,2))
  #   maxent.present.raster <- raster(paste(path=file.path(mainDirMaxent), '/', gsub(" ", "_", species), '_present.asc', sep=""))
  #   maxent.present.raster.crop <- crop(maxent.present.raster, extent(pol)+10)
  #   countries.crop <- crop(countries, extent(pol)+10)  
  #   plot(countries.crop, xlim = c((extent(pol)@xmin-5),(extent(pol)@xmax+5)), ylim = c((extent(pol)@ymin-5),(extent(pol)@ymax+5)))
  #   plot(maxent.present.raster.crop, add=T)
  #   plot(pol, add=T); plot(countries.crop, add=T); points(cucumis.unique.species, pch=19, cex=0.5, col='red')
  #   box()
  #   extent(maxent.present.raster)
  #   dev.off()
  
  ### Null-model ###
  
  maxentResults <- read.csv(paste(file.path(mainDirMaxent), '/', gsub(" ", "_", species), '_maxentResults.csv', sep=""))
  # maxentResults
  vector <- maxentResults$X.Training.samples
  # str(vector)
  vector <- as.vector(sort(vector))
  vector
  
  head(present.species.df); dim(present.species.df)
  x <- present.species.df[, (colnames(present.species.df) %in% keep.dat)]
  head(x)
  
  ## Run null-model from source
  nm <- nullModel(x, n = vector, rep = 100)
  nm # shows the evaluations of the 'rep' null models created
  auc <- sapply(nm, function(x){slot(x,'auc')})# get just the auc values of  the null models
  auc <- auc[order(auc, decreasing = TRUE)]
  hist(auc) #make a histogram
  write.csv(auc, paste(file.path(mainDirMaxent), '/', gsub(" ", "_", species), '_nm_auc.csv', sep=""))
  
  maxentResults$nm <- auc[5] # Add null-model value to maxentResults
  write.csv(maxentResults, file=paste(file.path(mainDirMaxent), '/', gsub(" ", "_", species), '_maxentResults.csv', sep=""))
  
}

############################
#### END ###################
############################

# present.me <- predict(me, present.stack, progress='text') # takes a long time
# plot(present.me)

# density.Project Present
system(command=paste('java -cp D:/Programs/Maxent.3.3.3k/maxent.jar density.Project ', file.path(mainDirMaxent, subDirMaxent), '/species.lambdas D:/Papers.Projects/Climate.Smart.Agriculture/GIS/present ', file.path(mainDirMaxent, subDirMaxent), '/', subDirMaxent, '_present noproduct nothreshold nohinge noextrapolate "outputformat=logistic" jackknife "applyThresholdRule=Maximum training sensitivity plus specificity" redoifexists', sep=""))

present.raster <- raster(paste(file.path(mainDirMaxent, subDirMaxent), '/', subDirMaxent, '_present.asc', sep=""))
plot(present.raster); plot(countries, add=T)

# density.Project present_project
system(command=paste('java -cp D:/Programs/Maxent.3.3.3k/maxent.jar density.Project ', file.path(mainDirMaxent, subDirMaxent), '/species.lambdas D:/Papers.Projects/Climate.Smart.Agriculture/GIS/present_project ', file.path(mainDirMaxent, subDirMaxent), '/', subDirMaxent, '_project noproduct nothreshold nohinge noextrapolate "outputformat=logistic" jackknife "applyThresholdRule=Maximum training sensitivity plus specificity" redoifexists', sep="")) #  doclamp fadebyclamping

project.raster <- raster(paste(file.path(mainDirMaxent, subDirMaxent), '/', subDirMaxent, '_project.asc', sep=""))
plot(project.raster); plot(countries, add=T)

### GlobCover 2009 ####

glob.cover.2009 <- raster('D:/GIS/Globcover2009_V2.3_Global/GLOBCOVER_L4_200901_200912_V2.3.tif')
str(glob.cover.2009)
dim(glob.cover.2009)
legend <- read.xlsx('D:/GIS/Globcover2009_V2.3_Global/Globcover2009_Legend.xls', 1)
head(legend)
glob.cover.2009@crs <- P4S.latlon
glob.cover.2009.africa <- crop(glob.cover.2009, ext.africa)

writeRaster(glob.cover.2009.africa, 
            filename  = "D:/Papers.Projects/Andel.Tinde.van/medicinal.plants/predictors/mask/glob.cover.2009.africa.asc",
            format    = 'ascii',
            NAflag    = -9999,
            overwrite = T)

rm(glob.cover.2009)
plot(glob.cover.2009.africa)
summary(glob.cover.2009.africa)
glob.cover.2009.africa[glob.cover.2009.africa >= 210] <- NA # remove water & ice etc. see legend.xls
glob.cover.2009.africa[glob.cover.2009.africa >= 190] <- 0 # set urban & bare to 0
glob.cover.2009.africa.natural.vegetation <- glob.cover.2009.africa
glob.cover.2009.africa.natural.vegetation[glob.cover.2009.africa.natural.vegetation <= 30] <- 0 # set cropland to 0
glob.cover.2009.africa.natural.vegetation[glob.cover.2009.africa.natural.vegetation > 0] <- 1 # set natural forest cover to 1

writeRaster(glob.cover.2009.africa.natural.vegetation, 
            filename  = "D:/Papers.Projects/Andel.Tinde.van/medicinal.plants/predictors/mask/gc2009nvhighres.asc",
            format    = 'ascii',
            NAflag    = -9999,
            overwrite = T)

str(glob.cover.2009.africa.natural.vegetation)
plot(glob.cover.2009.africa.natural.vegetation)
glob.cover.2009.africa.natural.vegetation@ncols #18720
bio01.TA@ncols # 624
glob.cover.2009.africa.natural.vegetation@ncols/bio01.TA@ncols # 30
gc.2009.africa.nv.mean.5arcmin <- aggregate(glob.cover.2009.africa.natural.vegetation, fact = 30, fun=mean) # % natural  vegetation at 5 arcmin
plot(gc.2009.africa.nv.mean.5arcmin)
str(gc.2009.africa.nv.mean.5arcmin)
gc.2009.africa.nv.05.5arcmin <- gc.2009.africa.nv.mean.5arcmin
gc.2009.africa.nv.05.5arcmin[gc.2009.africa.nv.05.5arcmin > 0.5] <- 1 # above 50% present
gc.2009.africa.nv.05.5arcmin[gc.2009.africa.nv.05.5arcmin <= 0.5] <- 0 # below 50% absent
gc.2009.africa.nv.05.5arcmin[gc.2009.africa.nv.05.5arcmin <= 0.5] <- NA # below 50% absent
plot(gc.2009.africa.nv.05.5arcmin, col=rainbow(2))
summary(gc.2009.africa.nv.05.5arcmin)

writeRaster(gc.2009.africa.nv.05.5arcmin, 
            filename  = "D:/Papers.Projects/Andel.Tinde.van/medicinal.plants/predictors/mask/gc.2009.africa.nv.05.5arcmin.asc",
            format    = 'ascii',
            NAflag    = -9999,
            overwrite = T)

gc.2009.africa.nv.min.5arcmin <- aggregate(glob.cover.2009.africa.natural.vegetation, fact = 30, fun=min) # % natural  vegetation at 5 arcmin
plot(gc.2009.africa.nv.min.5arcmin)

writeRaster(gc.2009.africa.nv.mean.5arcmin, 
            filename  = "D:/Papers.Projects/Andel.Tinde.van/medicinal.plants/predictors/mask/gc2009nvmean.asc",
            format    = 'ascii',
            NAflag    = -9999,
            overwrite = T)

writeRaster(gc.2009.africa.nv.min.5arcmin, 
            filename  = "D:/Papers.Projects/Andel.Tinde.van/medicinal.plants/predictors/mask/gc2009nvmin.asc",
            format    = 'ascii',
            NAflag    = -9999,
            overwrite = T)

### Range measures ####

sp.dist <- list.files('D:/Papers.Projects/Andel.Tinde.van/medicinal.plants/maxent.output/', pattern="_present_thresholded[.]asc$", full.names=T)
gc.nv <- "D:/Papers.Projects/Andel.Tinde.van/medicinal.plants/predictors/mask/gc.2009.africa.nv.05.5arcmin.asc"
sp.dist <- c(sp.dist, gc.nv)
names.sp.dist <- gsub('_present_thresholded.asc', '', basename(sp.dist))
names.sp.dist <- gsub('gc.2009.africa.nv.05.5arcmin.asc', 'gc.nv', names.sp.dist)
sp.dist.asc2df <- asc2dataframe(sp.dist, varnames = names.sp.dist)
head(sp.dist.asc2df)
dim(sp.dist.asc2df)
colnames(sp.dist.asc2df)
table(sp.dist.asc2df[1:5,3:17])
x <- data.frame(colSums(sp.dist.asc2df[,3:16]))
y <- data.frame(colSums(sp.dist.asc2df[sp.dist.asc2df$gc.nv==1,3:16]))
x$nv <- y[,1]
x$nv.perc <- round((x[,2]/x[,1])*100,0)
write.csv(x, file='../ms/range.sizes.csv')

### From dismo ##########
ecocrop('potato', 5:16, 15:26, runif(12)*100)
getCrop('Acacia brachystachya Benth.')
crop <- getCrop('Hot pepper')
ecocrop(crop, 5:16, 15:26, rainfed=FALSE)
