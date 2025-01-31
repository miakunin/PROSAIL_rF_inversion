#!/usr/bin/env Rscript

# Load external functions from 'functions.R'
source("functions.R")

# Load necessary libraries quietly to suppress startup messages
suppressMessages(library(hsdar))          # Hyperspectral Data Analysis in R
suppressMessages(library(randomForest))   # For building random forest models
suppressMessages(library(crayon))         # Colored terminal output
suppressMessages(library(tidyverse))      # Data manipulation and visualization

# Retrieve command-line arguments (if any)
args <- commandArgs(trailingOnly = TRUE)  # 'args' will contain any arguments passed to the script

# Check if a folder path was provided as an argument; if not, use the default path
if (length(args) == 0 || args[1] == "") {
  affix1 <- "RData/0407/"  # Assign default folder path !!!!!!!
  cat("No folder was specified, working in RData/0407.\n")
} else {
  affix1 <- as.character(args[1])  # Use the folder path provided in the argument
}

# Load preprocessed data required for random forest modeling
load(paste0(affix1, "/PROSAIL_done_RF_ready.RData"))
# This should load variables such as 'train_var', 'test_var', 'parameter_list', and 'spectra_names'
cat("Starting rf processes\n")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Random Forest Model Training for LMA (Chlorophyll Content)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cat("LMA training...\n")

# Train the random forest model to predict LMA using training data
rf_LMA <- randomForest(
  x = train_var,                  # Predictor variables (spectral data)
  y = parameter_list[, 5],        # Response variable (LMA values from the fifth column of parameter_list)
  ntree = 500,                    # Number of trees in the forest
  mtry = 256,                     # Number of variables randomly sampled as candidates at each split
  importance = TRUE,              # Enable calculation of variable importance
  keep.forest = TRUE              # Retain the forest structure for future predictions
)

# Save the trained random forest model to a file for future use
save(rf_LMA, file = paste0(affix1, "/rf_LMA.RData"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Prediction Using the Trained Random Forest Model
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cat("Predict LMA\n")

# Use the trained model to predict LMA values on the test data
rf.pred.LMA <- predict(rf_LMA, newdata = test_var)

# Create a data frame with the predicted LMA values and corresponding spectrum names
rf.pred.LMA.df <- data.frame(
  LMA = as.numeric(rf.pred.LMA),  # Convert predictions to numeric values
  row.names = spectra_names       # Assign spectrum names as row names for identification
)

# Save the predictions to a file for later analysis or reporting
save(rf.pred.LMA.df, file = paste0(affix1, "/predictions_LMA.RData"))

