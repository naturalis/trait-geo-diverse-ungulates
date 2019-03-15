#### This function calculates a MaxEnt species distribution model
removeCollinearity_adjusted <- function(raster.stack, multicollinearity.cutoff = .7,
                                        select.variables = FALSE, sample.points = FALSE, 
                                        nb.points = 10000, plot = FALSE)
  
{
  env.df <- getValues(raster.stack)
  env.df <- env.df[-unique(which(is.na(env.df), arr.ind = T)[, 1]), ] # Removing NAs 
  
  # Correlation matrix creation
  cor.matrix <- matrix(data = 0,
                       nrow = nlayers(raster.stack),
                       ncol = nlayers(raster.stack),
                       dimnames = list(names(raster.stack), names(raster.stack)))
  
  # Correlation based on Pearson
  cor.matrix<-1 - abs(stats::cor(env.df, method = "pearson" ))
  cor.matrix[is.na(cor.matrix)]<- 0
  
  # Transforming the correlation matrix into an ascendent hierarchical classification
  dist.matrix <- stats::as.dist(cor.matrix)
  ahc <- stats::hclust(dist.matrix, method = "complete")
  groups <- stats::cutree(ahc, h = 1 - multicollinearity.cutoff)
  if(length(groups) == max(groups))
  {
    message(paste("  - No multicollinearity detected in your data at threshold ", multicollinearity.cutoff, "\n", sep = ""))
    mc <- FALSE
  } else
  { mc <- TRUE }
  
  
  # Random selection of variables
  if(select.variables)
  {
    sel.vars <- NULL
    for (i in 1:max(groups))
    {
      sel.vars <- c(sel.vars, sample(names(groups[groups == i]), 1))
    }
  } else
  {
    if(mc)
    {
      sel.vars <- list()
      for (i in groups)
      {
        sel.vars[[i]] <- names(groups)[groups == i]
      }
    } else
    {
      sel.vars <- names(raster.stack)
    }
  }
  return(sel.vars)
}

# clips a `raster` environment of layers to the extent defined in the provided `shape`
clip <- function(raster,shape) {
  raster
  shape
  a1_crop <- crop(raster,shape)
  step1 <- rasterize(shape,a1_crop)
  a1_crop * step1
}

# performs a maxent analysis including:
# - buffering / clipping
# - variable selection
# - k-fold cross validation
Maxent_function <- function(species_occurence, currentEnv) {
  bindlonglat <- as.data.frame(cbind(species_occurence[, c("decimal_longitude", "decimal_latitude")]))
  points <- bindlonglat
  points$decimal_longitude <- as.numeric(as.character(points$decimal_longitude))
  points$decimal_latitude <- as.numeric(as.character(points$decimal_latitude))
  coordinates(points) <- ~ decimal_longitude + decimal_latitude
  x <- gBuffer(points, width= 9, byid = TRUE) ## 1000 km buffers
  x <- gUnaryUnion(x)
  ## clip function
  modelEnv = clip(currentEnv, x)
  names(modelEnv) <- names(currentEnv)

  # remove collinearity 
  Env_removed_correlation <- removeCollinearity_adjusted(modelEnv, multicollinearity.cutoff = 0.7, select.variables = TRUE)
  currentEnv2 <- subset(modelEnv, Env_removed_correlation)
  
  ## make a dataframe of just the longitude and latitude locations remove all the other variables
  Species_occ <- cbind.data.frame(species_occurence$decimal_longitude, species_occurence$decimal_latitude)
  
  ## Maxent model with training data and cropped extent to train the model. We use all the occurence data to train the model 
  species_model <- dismo::maxent(currentEnv2, Species_occ, args = c("noproduct", "nothreshold", "nohinge", "noextrapolate", "outputformat=logistic", "jackknife", "applyThresholdRule=10 percentile training presence",  "redoifexists"))
  
  ### null model 
  output <- list(species_model, currentEnv2, Species_occ, x)
  
}


# Null model function

nullModel_adjusted <- function (visited_areas, modelenvironment, polygonextent, occurence_samples, rep = 100)
{
  e <- list()
  #stopifnot(n < nrow(x))
  bindlonglat <- as.data.frame(cbind(visited_areas[, c("decimal_longitude", "decimal_latitude")]))
  points <- bindlonglat
  points$decimal_longitude <- as.numeric(as.character(points$decimal_longitude))
  points$decimal_latitude <- as.numeric(as.character(points$decimal_latitude))
  coordinates(points) <- ~ decimal_longitude + decimal_latitude
  crop_points<- crop(points, polygonextent)
  #plot(points)
  #plot(crop_points, add=TRUE, col="red")

    for (i in 1:rep) {
    random_points<- sample(crop_points, occurence_samples)
    species_mod <- dismo::maxent(modelenvironment, random_points, args = c("noproduct", "nothreshold", "nohinge", "noextrapolate", "outputformat=logistic", "jackknife", "applyThresholdRule=10 percentile training presence",  "redoifexists"))
   AUC<- species_mod@results[[5,1]]
   e[i] <- AUC
    }
  output<- e
}

