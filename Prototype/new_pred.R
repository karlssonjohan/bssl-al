
#  ------------------------------------------------------------------------

#  Predict new data 

#  ------------------------------------------------------------------------
library("methods")


# User input 
args <- commandArgs(TRUE)
dtmDir <- args[1]
modelDir <- args[2]
modelSelection <- args[3]
scriptDirectory <- args[4]
ldaRda = paste(modelDir,"/lda.rda", sep="")
tfidfFeaturesRda = paste(modelDir,"/tfidfFeatures.rda", sep="")
bslModel = paste(modelDir,"/bsl-model.rda", sep="")
bsslModel = paste(modelDir,"/bssl-model.rda", sep="")
slModel = paste(modelDir,"/sl-model.rda", sep="")


# Load user defined config file
source(paste(scriptDirectory,"/config.R", sep=""))


# Load functions from other scripts
source(paste(scriptDirectory,"/bssl.R", sep=""))
source(paste(scriptDirectory,"/helpers.R", sep=""))


library(topicmodels)

# Data --------------------------------------------------------------------

# Load the new data
newDTM <- getDTM(paste(dtmDir,"/", sep=""))

# import list of words after tfidf reduction and lda model
load(ldaRda)
load(tfidfFeaturesRda)


# Select the features left after tfidf reduction
newDTM.tfidf <- rep(0, length(features))
names(newDTM.tfidf) <- features
newDTM.tfidf[features[features %in% newDTM@Dimnames[[2]]]] <- 
  newDTM[,features[features %in% newDTM@Dimnames[[2]]]]
newDTM.tfidf <- Matrix(newDTM.tfidf, nrow = 1, ncol = length(features))
newDTM.tfidf@Dimnames <- list(newDTM@Dimnames[[1]], features)

# Precidt the topic proportions 
lda.pred <- LDA(newDTM.tfidf, model = lda.model, 
                control = list(estimate.beta = FALSE, 
                               burnin = 1000, thin = 100, iter = 1000, 
                               best = TRUE))

x <- data.frame(lda.pred@gamma)
names(x) <- paste('t', 1:ncol(x), sep='')
X <- model.matrix(~., data=x)


# Prediction --------------------------------------------------------------

# Bayesian supervised learning
if(modelSelection == 'bsl'){
  load(bslModel)
  pred <- predict.with.posterior(model$beta, X=X, levels = model$levels)
  pred$prob  
}

# Bayesian semi-supervised learning
if(modelSelection == 'bssl'){
  load(bsslModel)
  pred <- predict.with.posterior(model$beta, X=X, levels = model$levels)
  pred$prob  
}

# Supervised learning (non-Bayesian)
if(modelSelection == 'sl'){
  load(slModel)
  pred <- calc_prob(matrix(coef(model)), X)
  colnames(pred) <- model$lev
  pred
}

