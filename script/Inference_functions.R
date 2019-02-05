## these functions are obtained from 
#Kleyer, M., Dray, S., Bello, F., Lepš, J., Pakeman, R. J., Strauss, B., ... & Lavorel, S. (2012). 
#Assessing species and community functional responses to environmental gradients: 
#which multivariate methods?. Journal of Vegetation Science, 23(5), 805-821. Annex 4

Inference_compute<-function(Fam="binomial", combin=NULL, Mat=NULL, Response=NULL, 
                            Explanatory=NULL, Average = F){    
  
  
    Temp<-c(colnames(Explanatory))
  NbVar<-length(Temp)
  Temp<-Mat[,ncol(Mat)]
  Dato<-cbind(Response, Explanatory)
  
  #######################
  #Inference models.
  #######################
  
  Model_list_M=c()
  AIC_List<-as.data.frame(matrix(0, nrow=length(combin), ncol=4,
                                 dimnames=list(seq(1:length(combin)), c("AICc", "Rank", "DeltaAICc", "Wic"))))
  
  i<-1
  while(i<= length(combin)){
    Formula<-as.formula(paste("Response~", paste(combin[i]),collapse = ""))
    Model_list_M[i] <- list(gam(formula=Formula, family = Fam, data = Dato))
    AIC_List[i,1]<-selMod(Model_list_M[i])$AICc         
    i<-i+1
  }
  
  
  
  #Rank the models based on AIC
  AIC_List[,2]<-rank(AIC_List[,1])
  AIC_List[,3]<-AIC_List[,1]-min(AIC_List[,1])
  AIC_List[,4]<-exp(-0.5*AIC_List[,3])/sum(exp(-0.5*AIC_List[,3]))
  AIC_List<-cbind(combin,AIC_List)
  #assign("AIC_List", AIC_List, pos=1)  
  
  #Estimate the importance of each variable.
  
  Var.importance<-as.data.frame(matrix(0, nrow=NbVar, ncol=2,
                                       dimnames=list(Temp, c("Sum.wi", "Rel.Importance"))))
  
  i<-1
  while(i<= length(combin)){
    j<-1
    while(j<=NbVar){
      Test<-match(Temp[j], Mat[,i])
      if(!is.na(Test)){          
        Var.importance[j,1]<-Var.importance[j,1] +  AIC_List[i,5]
      }  
      j<-j+1
    }
    i<-i+1
  }
  
  
  # Calcul de Rel.Importance
  Var.importance[,2]<-100*Var.importance[,1]/sum(Var.importance[,1])
  #o<-order(Var.importance$Rel.Importance,decreasing=T)
  #Var.importance<-Var.importance[o,]
  
  #Store the results in the workspace
  #assign("Var.importance", Var.importance, pos=1)
  
  #Model averaging
  if(Average!=F){
    Averaged.Pred<-rep(0, length=nrow(Dato))
    i<-1
    # calcul de la somme des wiPi :
    while(i<=ncol(Mat)){
      Averaged.Pred<-Averaged.Pred + (fitted(Model_list_M[[i]]) * AIC_List$Wi[i])
      i<-i+1
    }
    #  assign("Averaged.Pred", Averaged.Pred, pos=1)    
  }
  
  #Response curves:
  
  #Create a dataframe to perform the evaluation strip plot
  Xp <- as.data.frame(matrix(sapply(Explanatory, mean), nrow=nrow(Explanatory), NbVar, byrow=TRUE,  dimnames=list(seq(1:nrow(Explanatory)), colnames(Explanatory))))
  for(i in 1:NbVar){
    if(sapply(Explanatory, is.factor)[i])
      Xp[,i]<-rep(as.factor(names(which.max(summary(Explanatory[,i])))), nrow(Xp))
  }   
  
  #Loop to produce the predictions for the plots
  #create a dataframe to store the evaluation strip plots (2 columns per variable)
  plot.response = as.data.frame(matrix(0, ncol=2*NbVar, nrow= nrow(Xp), dimnames=list(seq(nrow(Xp)), rep(names(Explanatory), each = 2))))
  z=1
  i=1
  while(i<=NbVar) {
    Xf<-rep(0, length=nrow(Explanatory))
    for(a in 1:length(combin)){
      # xr <- sapply(Explanatory, range)
      Xp1 <- Xp
      Xp1[,i] <- Explanatory[,i]
      Xf <- Xf + predict(Model_list_M[[a]], as.data.frame(Xp1), type="response")* AIC_List$Wi[a]
    }
    if (length(unique(Xf)) !=1) {
      if(!is.factor(Explanatory[,i])){  
        temp<-cbind(Xp1[ ,i], Xf)
        plot.response[,z]=sort(temp[ ,1])
        plot.response[,z+1]=temp[row.names(as.data.frame(sort(temp[ ,1]))),2]
      }
      else {
        plot.response[,z]=Xp1[ ,i]
        plot.response[,z+1]=Xf
      }         
    }
    i=i+1
    z=z+2          
  }   
  
  
  return(list("AIC_List"=AIC_List,  "Var.importance" = Var.importance,  
              "Plot.response" = plot.response, "Averaged.Pred" = Averaged.Pred))
  
  
}


Inference_modelset<-function(Explanatory=NULL){
  
  ################################
  
  #Keep the number of explanatory variables
  
  NbVar<-ncol(Explanatory)
  combin<-c(colnames(Explanatory))
  
  i<-1
  while(i<=NbVar){
    if(!is.factor(Explanatory[,i]))
      combin[i]<-c(paste("s(", combin[i], ",2)", sep = ""))
    else combin[i]<-c(paste(combin[i]))
    i<-i+1
  }
  
  
  Mat<-as.data.frame(matrix(0, nrow=NbVar, ncol=NbVar))
  Mat[1,1:NbVar]<- t(combin)
  Temp<-combin
  
  Dm=seq(from=2, to=NbVar-1)
  a=1
  while(a<=length(Dm)){
    Maxi=dim(combn(Temp,Dm[a]))[2]
    i<-1
    while(i<=Maxi){
      combin = c(combin, paste(combn(Temp,Dm[a])[,i], collapse="+"))
      i<-i+1
    }
    Mat<-cbind(Mat, rbind(combn(Temp,Dm[a]), matrix(0, nrow=NbVar-nrow(combn(Temp,Dm[a])),
                                                    ncol=ncol(combn(Temp,Dm[a])))))      
    a<-a+1
  }
  
  combin = c(combin, paste(Temp,collapse="+"))  
  Mat = cbind(Mat, Temp)
  
  
  return(list(combin, Mat))
  
}

