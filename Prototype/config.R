#  ------------------------------------------------------------------------
#  User defined parameters for build log analysis
#  ------------------------------------------------------------------------

# Set resonse for modeling and choose covariates
response <- 'general.failure.cause'
covariates <- paste('t', 1:20, sep='')

# Parameter settings for modeling 
tau <- 10

# kappa for supervised modeling and labeled_logs.csv
#bsl_kappa <- 0.5   # Alter this parameter if the acceptance rate is to high or low
# kappa for supervised modeling and all-labeled.csv
bsl_kappa <- 0.44   # Alter this parameter if the acceptance rate is to high or low

# kappa for semi supervised modeling and labeled_logs.csv
#bssl_kappa <- 0.15   # Alter this parameter if the acceptance rate is to high or low
# kappa for semi supervised modeling and all-labeled.csv
bssl_kappa <- 0.19   # Alter this parameter if the acceptance rate is to high or low

burn <- 2000
samp <- 4000
