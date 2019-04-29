library(dplyr)

# optional arguments during the recursion:
# - `included` a boolean vector of the current variables in the model
# - `models` a list of models and their AICs
phyloglmstep <- function(formula, phy, data, ...) {
  
  # Create Formula as a string, returns it parsed
  create.formula <- function(dependent, predictors, included) {
    pi <- predictors[included]
    ps <- paste(pi, collapse = ' + ')
    m <- sprintf( '%s ~ 1 + %s', paste(dependent), ps )
    return(as.formula(m))
  }
  
  # Maybe Negate: whatever arg is provided, is negated if n = T
  mn <- function(arg,n) {
    if (n) {
      return(!arg)
    } else {
      return(arg)
    }
  }
  
  # first n=T, then n=F
  iterate.fit <- function(predictors,included,n,models) {
    
    # named vector of AICs in current iteration
    aics <- vector(mode="numeric",length=length(predictors[mn(included,n)]))
    names(aics) <- predictors[mn(included,n)]
    
    # iterate over predictors; if not yet included, add and fit it, record AIC
    j <- 1
    for ( i in 1:length(predictors) ) {
      if ( mn(included[i],n) ) {
        inc <- included
        inc[i] <- n
        mod <- create.formula(dependent,predictors,inc)
        if ( is.null(models) || ! ( c(mod) %in% c(models) ) ) {
          tryCatch({
            result <- phyloglm(mod,data,phy,method="logistic_MPLE",btol=30)
            aics[j] <- result$aic
          }, error = function(error_condition) {
            message(sprintf('phyloglm problem for %s',format(mod)))
          }, finally={
            
          })
        }
        j <- j + 1
      }
    } 
    aics <- aics[aics > 0]
    return(sort(aics))
  }
  
  # coerce in case it's a string, then parse
  formula <- as.formula(formula)
  predictors <- attr(terms(formula), "term.labels")
  dependent <- formula[[2]]
  
  # fetch or initialize optional arguments
  params <- list(...)
  included <- params$included
  aics <- params$aics
  models <- params$models
  if ( is.null(included) ) {
    included <- vector( mode = "logical", length = length(predictors) )
  }
  
  # fit fw models, pick best result, add it to the included, log result
  current.aics <- iterate.fit(predictors,included,TRUE,models)
  best.predictor <- names(current.aics)[1]
  best.aic <- current.aics[1]
  included[ match( best.predictor, predictors ) ] <- T
  best.model <- create.formula( dependent, predictors, included )
  message( sprintf( 'FW: aic=%f (%s)\n', best.aic, format(best.model) ) )
  
  # fit sw models, pick best result, maybe remove from included, log result
  if ( length(predictors[included]) > 1 ) {
    current.aics <- iterate.fit(predictors,included,FALSE,models)
    best.predictor <- names(current.aics)[1]
    best.sw.aic <- current.aics[1]
    if ( best.sw.aic < best.aic ) {
      best.aic <- best.sw.aic
      included[ match( best.predictor, predictors ) ] <- F
      best.model <- create.formula( dependent, predictors, included )
      message( sprintf( 'SW: aic=%f (%s)\n', best.aic, format(best.model) ) )
    }
  }
  
  # first iteration, store result and recurse
  if ( is.null(aics) ) {
    aics <- c(best.aic)
    models <- c(best.model)
    phyloglmstep(formula,phy,data,included=included,aics=aics,models=models)
    
  } else {
    
    # result is better, store and recurse
#    if ( best.aic < min(aics) ) {
      aics <- c(aics,best.aic)
      models <- c(models,best.model)
      phyloglmstep(formula,phy,data,included=included,aics=aics,models=models)
      
#    } else {
      
      # no further improvement, return df
#      return(aics)
#    }
  }
}