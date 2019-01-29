#### This function calculates a MaxEnt species distribution model

clip<-function(raster,shape) {
  a1_crop<-crop(raster,shape)
  step1<-rasterize(shape,a1_crop)
  a1_crop*step1}

Maxent_fuction<- function(species_occurence, currentEnv){
  ## random sample 10 rows in dataframe 
  rs_species<- species_occurence[sample(nrow(species_occurence), 10), ]
  
  # calculate the suitable extent for the training model 
  # calculate all the point dinstances in meters
  matrix<-as.matrix(rs_species[, c("decimal_longitude", "decimal_latitude")])
  
  distance<-pointDistance(matrix, lonlat = TRUE)
  
  point_df2<-max(distance, na.rm=TRUE)
  
  x <- polygons(circles((rs_species[, c("decimal_longitude", "decimal_latitude")]), d= point_df2 , lonlat=TRUE)) 
  
  ## clip function 
  modelEnv=clip(currentEnv, x)
  
  # remove collinearity 
  Env_removed_correlation<-removeCollinearity(modelEnv, multicollinearity.cutoff = 0.7, select.variables = TRUE)
  currentEnv2<- subset(modelEnv, Env_removed_correlation)
  plot(currentEnv2)
  
  ## make a dataframe of just the longitude and latitude locations remove all the other variables
  Species_occ<- cbind.data.frame(rs_species$decimal_longitude,rs_species$decimal_latitude)
  
  # create a k-fold cross validation. This means we set aside 25% of the data as test data and we use the other 75% as train data. 
  fold<- kfold(rs_species, k=4)
  Species_test<- rs_species[fold == 1, ]
  Species_train<- rs_species[fold != 1, ]
  
  ## Maxent model with training data and cropped extent to train the model 
  species_model<- dismo::maxent(modelEnv, Species_train)
  
  # validate the model with the test data
  # to construct an AUC model we need random points
  
  random<- randomPoints(modelEnv, 1000)
  Validation_species<- evaluate(p=Species_test, a=random, x=modelEnv, model =species_model)
  
}