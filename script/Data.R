library(raster, quietly = T)

get_layers <- function(data.path, data.res = 10) {
  
  # load bioclim
  data.layers = raster::getData(
    "worldclim", 
    var="bio", 
    res=data.res, 
    path=paste(data.path, '/data/GIS', sep=''), 
    download=T
  )
  
  # list tiff files from provided location
  tiff.dir <- sprintf('%s/data/GIS/%i_deg/', data.path, data.res)
  tiff.list <- list.files(tiff.dir, pattern = '.tif')
  
  # stack the additional layers
  tiff.layers <- stack()
  for (i in 1:length(tiff.list) ){
    
    # load layer, set name, stack 
    tiff.name <- tiff.list[i]
    tiff.path <- paste(tiff.dir, tiff.name, sep = '')
    layer.name <- sub('.tif','',tiff.name)
    layer.obj <- raster::raster(tiff.path)
    names(layer.obj) <- layer.name
    data.layers <- raster::stack(data.layers,layer.obj)
  }
  return(data.layers)
}

get_maxent_model <- function(data.path, taxon.name) {
  
  # construct path to maxent model file
  maxent.model.file <- sprintf(
    '%s/results/per_species/%s/valid_maxent_model.rda', 
    data.path, 
    taxon.name
  )
  
  # check if model exists
  if ( file.exists(maxent.model.file) ) {
    
    # return model
    tmp.env <- new.env()
    tmp.nm <- load(maxent.model.file, tmp.env)[[1]]
    maxent.model <- tmp.env[[tmp.nm]]
    return(maxent.model)
  } else {
    
    # return NULL
    message(sprintf("No model file for %s", genus.name, taxon.name))
    return(NULL)
  }
}

get_occurrences <- function(data.path, taxon.name) {
  csv.file <- sprintf('%s/data/filtered/%s.csv',data.path,taxon.name)
  occurrences <- read.csv2(csv.file, header = T, sep = ',')
  return(occurrences)
}