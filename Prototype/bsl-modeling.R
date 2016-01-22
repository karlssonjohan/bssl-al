
#  ------------------------------------------------------------------------

#  Bayesian supervised learning


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
bslModel = paste(outputDir,"/bsl-model.rda", sep="")
bslTraceDensity = paste(outputDir,"/bsl-trace-density.pdf", sep="") 
bslBoxplots =  paste(outputDir,"/bsl-boxplots.pdf", sep="") 

# Load functions from other scripts
source(paste(scriptDirectory,"/config.R", sep=""))
source(paste(scriptDirectory,"/bssl.R", sep=""))
source(paste(scriptDirectory,"/helpers.R", sep=""))


# Data --------------------------------------------------------------------

# Topic proportions
# load('./results/topics.rda')
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

model <- ssl_MH(y =  y[!is.na(y)], x = x[!is.na(y),], burn = burn, samp = samp,
                kappa = bsl_kappa, tau=tau)


save(model, file=bslModel)



# Visualization & evaluation ----------------------------------------------

if(vis == TRUE){
  mcmc.plots(model$beta, pdf = TRUE ,filename = bslTraceDensity, 
             title = '')
  
  	  mcmc.boxplots(model$beta, pdf = TRUE ,filename = bslBoxplots, 
                title = '')
  
}