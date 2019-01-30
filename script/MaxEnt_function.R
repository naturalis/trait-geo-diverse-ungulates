#### This function calculates a MaxEnt species distribution model

clip<-function(raster,shape) {
  a1_crop<-crop(raster,shape)
  step1<-rasterize(shape,a1_crop)
  a1_crop*step1}

Maxent_fuction<- function(species_occurence, currentEnv){
  #random sample 10 rows in dataframe 
  #rs_species<- species_occurence[sample(nrow(species_occurence), 10), ]
  
  # calculate the suitable extent for the training model 
  # calculate all the point dinstances in meters
  matrix<-as.matrix(species_occurence[, c("decimal_longitude", "decimal_latitude")])
  
  distance<-pointDistance(matrix, lonlat = TRUE)
  
  point_df2<-max(distance, na.rm=TRUE)
  
  ## we constrain the max distance with a maximum of 1000 km 
  if (point_df2 > 1000000) point_df2 <- 1000000 else point_df2<- point_df2
  
  # You take the radius but if the radius is bigger than half the radius of the earth you take the whole dataset as an extent
  x <- polygons(circles((species_occurence[, c("decimal_longitude", "decimal_latitude")]), d= point_df2 , lonlat=TRUE, r=6378137,dissolve=TRUE))
  ## clip function 
  modelEnv=clip(currentEnv, x)
  names(modelEnv)<- names(currentEnv)

  # remove collinearity 
  Env_removed_correlation<-removeCollinearity(modelEnv, multicollinearity.cutoff = 0.7, select.variables = TRUE)
  currentEnv2<- subset(modelEnv, Env_removed_correlation)

  ## make a dataframe of just the longitude and latitude locations remove all the other variables
  Species_occ<- cbind.data.frame(species_occurence$decimal_longitude,species_occurence$decimal_latitude)
  
  # create a k-fold cross validation. This means we set aside 25% of the data as test data and we use the other 75% as train data. 
  fold<- kfold(Species_occ, k=4)
  Species_test<- Species_occ[fold == 1, ]
  Species_train<- Species_occ[fold != 1, ]
  
  ## Maxent model with training data and cropped extent to train the model 
  species_model<- dismo::maxent(currentEnv2, Species_train)
  
  output<- list(species_model, currentEnv2, Species_test)

}