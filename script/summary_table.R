# Annex bioRxiv 

library(raster)

# load taxa list
REPO_HOME <- paste(getwd(),'/../',sep='')
taxa.names <- scan(paste(REPO_HOME, "/data/filtered/taxa.txt", sep = ""), sep = "\n", what = character())

# create empty dataframe with columns "Species_name", "AUC values, "n", "important_variables"
df.summary <- data.frame(matrix(ncol = 4, nrow = length(taxa.names)))
x <- c("species", "n", "AUC", "important_variables")
colnames(df.summary) <- x

# load AUC df
df.auc<- sprintf("%s/Results/maxent/AUCvalues.csv", REPO_HOME)
df.auc<- read.csv(df.auc, header = T)

# load trait contribution
df.traits<- sprintf("%s/Results/maxent/traits_contribution_maxent.csv", REPO_HOME)
df.traits <- read.csv(df.traits, header = T, row.names = 1)
d<- as.data.frame(names(df.traits))
write.csv(d, "C:/Users/elkeh/Documents/Stage_Naturalis/summarytable_nummers_variabelen.csv")
y <- c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15",
       "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "29",
       "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41")
colnames(df.traits) <- y

# make output directories, if needed

for (i in 1:length(taxa.names)) {
  # set species name
  df.summary[i,1] <- taxa.names[i]
  # count number of occurence points 
  csv.file <- sprintf("%s/data/filtered/%s.csv", REPO_HOME, taxa.names[i])
  csv <- read.csv(csv.file, header = T)
  df.summary[i,2] <- nrow(csv)
  # select the AUC value
  df.summary[i,3] <- df.auc[i,"trainingAUC"]
  # order the trait contribution
  traits.row <- df.traits[i,]
  traits.row<- na.omit(t(traits.row))
  traits.row<-traits.row[order(traits.row, decreasing = TRUE),] 
  traits.row<- as.data.frame(traits.row)
  traits.row<- rownames(traits.row)
  df.summary[i,4] <- paste(traits.row, collapse= "," )
  }

output<- paste(REPO_HOME, "/Results/maxent/summary_df.csv", sep="")  
write.csv(df.summary, output)
