
#  ------------------------------------------------------------------------

#  Dimensionality reduction 

#  Rank with TF-IDF and select w words (optional)
#  LDA analysis, input number of topics 


#  ------------------------------------------------------------------------
library("methods")


# Input arguments
args <- commandArgs(TRUE)
dtmDirectory <- args[1]
nwords <- args[2]
ntopics <- args[3] 
scriptDirectory <- args[4]
# Loads used defined variables in config.R file, should be located in the
# working directory
source(paste(scriptDirectory,"/config.R", sep=""))
source(paste(scriptDirectory,"/helpers.R", sep=""))



# Create output dir
outputDir = paste(dtmDirectory,"._analysis", sep="")
dir.create(outputDir, showWarnings = FALSE)


# Data --------------------------------------------------------------------

# Load dtm
dtm <- getDTM(paste(dtmDirectory,"/", sep=""))


# Compute TF-IDF ----------------------------------------------------------

tfidf.selection <- function(dtm){
  
  # Compute tfidf
  term_tfidf <-
    tapply(dtm@x/rowSums(dtm)[(dtm@i +1)], (dtm@j +1), mean) *
    log2(nrow(dtm)/colSums((dtm) > 0))
  
  names(term_tfidf) <- dtm@Dimnames[[2]]
  
#   # Plot 50 words with highest tfidf weight
#   opar <- par(mar=c(5,20,4,2)+0.1,mgp=c(1,1,0), cex = 0.75)
#   bp <- barplot(sort(term_tfidf, decreasing = TRUE)[1:50], horiz = TRUE, las = 1, 
#                 main = 'Words with highest \nTFIDF weights')
#   par(opar)
  
  # Choose the nwords highest ranked tokens by tfidf 
  dtm_new <- dtm[, order(term_tfidf, decreasing = TRUE)[1:nwords]]
  dtm_new <- dtm_new[rowSums(dtm_new) > 0,] # Remove logs which now do not have any lines
  
  if(dim(dtm_new)[1] - dim(dtm)[1] > 0){
    print(paste(dim(dtm_new)[1] - dim(dtm)[1]), 
          'log(s) have zero words left after TFIDF dimensionality reduction')
  }
  

  return(dtm_new)
}


# Only perform if not nwords are NULL
if(!is.null(nwords)){
  print("Running TFIDF")
  dtm <- tfidf.selection(dtm)
}

features <- dtm@Dimnames[[2]]
save(features, file = paste(outputDir, '/tfidfFeatures.rda', sep=""))



# LDA ---------------------------------------------------------------------


lda.dimred <- function(dtm, alpha = 0.1){
  require(topicmodels)
  
  
  start.time <- proc.time()
  lda.model = LDA(dtm, k = ntopics, method = "Gibbs",
              control = list(alpha = alpha, burnin = 1000,
                             thin = 1000, iter = 1000))
  print('Time needed for LDA')
  print(proc.time() - start.time)
  
  # Pick the topic proportions
  topic.proportions <- lda.model@gamma
  colnames(topic.proportions) <- paste('t', 1:ntopics, sep='')
  row.names(topic.proportions) <- dtm@Dimnames[[1]]
  
  # Save to file
  save(topic.proportions, file = paste(outputDir, '/topics.rda', sep=""))
  save(lda.model, file =paste(outputDir, '/lda.rda', sep=""))
  
}

print("Running LDA")
lda.dimred(dtm)

