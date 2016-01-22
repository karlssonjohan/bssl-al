
#  ------------------------------------------------------------------------

#  Non-Bayesian supervised learning


#  ------------------------------------------------------------------------


# User input 
args <- commandArgs(TRUE)
inputDir <- args[1]
scriptDirectory <- args[2]
labeledLogsDirectory <- args[3]

# Program variables
outputDir = inputDir
topicsRDA = paste(inputDir,"/topics.rda", sep="")
labeledLogsCSV = paste(labeledLogsDirectory,"/labeled_logs.csv", sep="")
slModel = paste(outputDir,"/sl-model.rda", sep="")

# Load user defined config file
source(paste(scriptDirectory,"/config.R", sep=""))

library(nnet)   


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

model <- multinom(yl ~ Xl[,])

save(model, file=slModel)
