Analysis
========

These steps assumes that 'data/labeled_logs.csv' exist with information on the labeled logs.

## Prerequisites
You need to install R. Get it at http://www.r-project.org/ 
Also install these R packages using  install.packages('packagename') in R:

- Matrix (should be included in the installation)
- topicmodels
- mvtnorm
- ggplot2
- glmnet
- gridExtra
- nnet

You probably need to specify the directory for user installed packages in the config file. 


## Dimensionality reduction

Note: Takes about an hour.

Rscript dim_red.R path/to/feature/data nwords ntopics

<code>Rscript dim_red.R 'C:/Users/erogeka/failed-for-test/_dtm' 2000 20 path-to-Rscripts-directory </code>

Input: 

- Directory whith dtm.mtx, featureNames.txt & fileID.txt
- number of words chosen with TFIDF. Set NULL for no TFIDF dim reduction. (NULL is recommended but takes longer time)
- number of topics with LDA
- Path to Rscripts directory

Output: Topic proportion matrix as an .rda file in directory input_dir._analysis


## Supervised modeling

Note that response and covariates can be manually altered in the config.R file as well as input parameters for the models.


#### Bayesian

It is important that the acceptance probability is approximately 0.3 for the posterior distributions to be correct. If the acceptance rate is way off you can try to change bsl_kappa in the config file.

The same function as in bssl-modeling is used, but only with the available labeled data. 

Rscript bsl-modeling.R /path/to/topics.rda vis = TRUE/FALSE path-to-Rscripts-directory path-to-labeled_logs.csv

<code>Rscript bsl-modeling.R /home/erogeka/_logs/_collections/failed._seq._dtm._analysis TRUE . /home/erogeka/_logs/_collections/ </code>

Input:

- Directroy with topics.rda
- vis (TRUE/FALSE) for visualizations of parameter posterior distributions
- Path to Rscripts directory
- Path to CSV with labeled and unlabeled logs

Output: 

- The posterior distributions of the model parameters are saved in input_dir/bsl-model.rda
- PDFs with plots. Also generates Rplots.pdf which can be ignored.


#### Non-Bayesian

Rscript sl-modeling.R  /path/to/topics.rda path-to-Rscripts-directory path-to-labeled_logs.csv



<code> Rscript sl-modeling.R /home/erogeka/_logs/_collections/failed._seq._dtm._analysis . /home/erogeka/_logs/_collections </code>


Input:
Directroy with topics.rda
Path to Rscripts directory
Path to CSV with labeled and unlabeled logs
Output: 
 The model parameters are saved in input_dir/sl-model.rda



## Bayesian semi-supervised modeling

It is important that the acceptance probability is approximately 0.3 for the posterior distributions to be correct. If the acceptance rate is way off you can try to change bssl_kappa in the config file.


Rscript bssl-modeling.R /path/to/topics.rda vis = TRUE/FALSE path-to-Rscripts-directory  path_to_labeled_logs.csv


<code> Rscript bssl-modeling.R /home/erogeka/_logs/_collections/failed._seq._dtm._analysis TRUE . /home/erogeka/_logs/_collections </code>



Input:

- Directroy with topics.rda
- vis (TRUE/FALSE) for visualizations of parameter posterior distributions
- Path to Rscripts directory
- Path to CSV with labeled and unlabeled logs

Output: 

- The posterior distributions of the model parameters are saved in './results/bssl-model.rda'
- PDFs with plots. Also generates Rplots.pdf which can be ignored.



## Active learning

This script can call the other model scripts, evaluate unlabeled data with this model and return a query of the most informative query according to a chosen active learning strategy. 
Note: This example only uses a supervised non-Bayesian classification model. 
Rscript al.R model alMethod  labeled_logs.csv


<code> Rscript al.R /home/erogeka/_logs/_collections/failed._seq._dtm._analysis 'maxEntropy' /home/erogeka/_logs/_collections/labeled_logs.csv </code>



Input:

ModDirectory with models (modelname.rda)
alMethod can be 'LC' (Least Confident), 'marg' (Margin), 'maxEntropy' (Maximum Entropy), exp.model.change.ml' (Expected Model Change),'exp.error.reduction' (Expected Error Reduction), 'random' (Random sampling)
labeled_logs.csv

Output:

The Id of the log that is most interesting to label in order to improve the model.


## Predict new unlabeled sample

Rscript new_pred.R path_to_new_log_dtm path_to_trained_models model path-to-Rscripts-directory

<code>Rscript new_pred.R 'C:\Users\erogeka\_logs\new-failed-log2._processedLogs._filtered._dtm' 'C:\Users\erogeka\_logs\w13a-w13b-w14a-w14b-failed-model-builds._processedLogs._filtered._dtm._analysis' bsl '<path-to-Rscripts-directory>' </code>


Input:

- Path to dtm.mtx for new log
- Path to trained models (sl-model.rda, bsl-model.rda and bssl-model.rda)
- model: model name for prediction. Available models: 'sl' (supervised learning), 'bsl' (Bayesian supervised learning) and 'bssl' (Bayesian semi-supervised learning)
- Path to Rscripts directory

Output: 

Prediction, that is, the probability that the log reflects a design fault and the probablity that the log reflects an environment fault.




