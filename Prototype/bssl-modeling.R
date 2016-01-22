
#  ------------------------------------------------------------------------

#  Bayesian semi-supervised learning


#  ------------------------------------------------------------------------

# User input 
args <- commandArgs(TRUE)
inputDir <- args[1]
vis <- args[2]
scriptDirectory <- args[3]
labeledLogsDirectory <- args[4]

# Program variables
outputDir = inputDir
topicsRDA = paste(inputDir,"/topics.rda", sep="")
labeledLogsCSV = paste(labeledLogsDirectory,"/labeled_logs.csv", sep="")
bsslModel = paste(outputDir,"/bssl-model.rda", sep="")
bsslTraceDensity = paste(outputDir,"/bssl-trace-density.pdf", sep="") 
bsslBoxplots =  paste(outputDir,"/bssl-boxplots.pdf", sep="") 

# Load functions from other scripts
source(paste(scriptDirectory,"/config.R", sep=""))
source(paste(scriptDirectory,"/bssl.R", sep=""))
source(paste(scriptDirectory,"/helpers.R", sep=""))


# Data --------------------------------------------------------------------

# Topic proportions
load(topicsRDA)


labeledLogs <- read.csv2(labeledLogsCSV, row.names = 1)



# Merge topic distributions and info of labels
data <- merge(labeledLogs[, c('general.failure.cause', 
                              'specific.failure.cause')],
              topic.proportions, by=0)
row.names(data) <- data$Row.names; data$Row.names <- NULL

# Set "design/environment" as unknown
data$general.failure.cause[data$general.failure.cause == 'design/environment'] <- NA

# Divide the data on labeled and unlabeled sets
yl <- as.character(data[!is.na(data[,response]),response])
yu <- as.character(data[is.na(data[,response]), response])
Xl <- model.matrix(~. -1, data[!is.na(data[,response]), covariates])
Xu <- model.matrix(~. -1, data[is.na(data[,response]), covariates])
x <- data.frame(rbind(Xl, Xu))
X <- model.matrix(~.,x)
y <- factor(c(yl, yu))


# Modeling ----------------------------------------------------------------

model <- ssl_MH(y =  y, x = x, burn = burn, samp = samp,
                kappa = bssl_kappa, tau=tau)


save(model, file=bsslModel)

 # Visualization & evaluation ----------------------------------------------

if(vis == TRUE){
 	 mcmc.plots(model$beta, pdf = TRUE ,filename = bsslTraceDensity, 
             title = '')
  
	mcmc.boxplots(model$beta, pdf = TRUE ,filename = bsslBoxplots, 
                title = '')
  
}