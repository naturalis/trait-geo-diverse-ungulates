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