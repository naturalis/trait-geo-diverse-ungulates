#### This function calculates a MaxEnt species distribution model

clip<-function(raster,shape) {
  a1_crop<-crop(raster,shape)
  step1<-rasterize(shape,a1_crop)
  a1_crop*step1}

Maxent_fuction<- function(species_occurence, currentEnv){
  # You can random sample the datasets to less occurence datasets using the following line:
  #if (nrow(species_occurence) > 500 ) species_occurence <- species_occurence[sample(nrow(species_occurence), 500), ] else species_occurence <- species_occurence
  
  bindlonglat<- as.data.frame(cbind(species_occurence[, c("decimal_longitude", "decimal_latitude")]))
  points<- bindlonglat
  points$decimal_longitude<- as.numeric(as.character(points$decimal_longitude))
  points$decimal_latitude<- as.numeric(as.character(points$decimal_latitude))
  coordinates(points)<- ~ decimal_longitude + decimal_latitude
  x<- gBuffer(points, width= 5, byid = TRUE)
  x<- gUnaryUnion(x)
 
   ## clip function
  modelEnv=clip(currentEnv, x)
  names(modelEnv)<- names(currentEnv)
  plot(modelEnv)

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