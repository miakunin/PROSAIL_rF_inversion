#!/usr/bin/env Rscript

# Load external functions from 'functions.R'
source("functions.R")

library(xgboost)

load("RData/0407/PROSAIL_done_RF_ready.RData") # file with the prosail calculations, spectra cleaning, etc.

# loading all the RF results (predictions):
load("RData/0407/predictions_Cab.RData")
load("RData/0407/predictions_Car.RData")
load("RData/0407/predictions_LAI.RData")
load("RData/0407/predictions_LMA.RData")

train_matrix <- as.matrix(prosail_spectra2) # create matrix variable for XGBoost training from the PROSAIL sim

# creating DMatrices:
dtrain_Cab <- xgb.DMatrix(data = train_matrix, label = parameter_list[, 1])
dtrain_Car <- xgb.DMatrix(data = train_matrix, label = parameter_list[, 2])
dtrain_LAI <- xgb.DMatrix(data = train_matrix, label = parameter_list[, 7])
dtrain_LMA <- xgb.DMatrix(data = train_matrix, label = parameter_list[, 5])

# Set up model parameters:
params <- list(
  objective = "reg:squarederror", # For regression tasks
  max_depth = 8,                 # Similar to controlling `mtry` in Random Forest
  eta = 0.1,                     # Learning rate
  subsample = 0.8,               # Subsample ratio of the training instance
  colsample_bytree = 0.8         # Subsample ratio of columns when constructing each tree
)

# Training the model
# It's actually well paralellized so it works pretty fast

# List of DMatrix datasets and their corresponding model names
dtrain_list <- list(
  Cab = dtrain_Cab,
  Car = dtrain_Car,
  LAI = dtrain_LAI,
  LMA = dtrain_LMA
)

# List to store the trained models and predictions
xgb_models <- list()
xgb_predictions <- list()

# create a matrix from the observations (it was dataframe for the RF)
pred_data <- as.matrix(data2_nls)

# Loop through each dataset and train the model
for (name in names(dtrain_list)) {
	cat(name,"\n")
  xgb_models[[name]] <- xgb.train(
    params = params,                # Model parameters
    data = dtrain_list[[name]],     # DMatrix with data
    nrounds = 500,                  # Number of boosting rounds
    watchlist = list(train = dtrain_list[[name]]), # Monitor progress
    verbose = 1                     # Print training log
  )
  importance <- xgb.importance(model = xgb_models[[name]])
  print(importance)
	xgb_predictions[[name]] <- predict(xgb_models[[name]], newdata = pred_data)
}

cat("Models trained!!\n")

# creating data frames for each prediction (for plotting)
# inherit original rownames (referred to the field observations labeling)
#	saving to the corresponding files in designated folder for further plotting

xgb.pred.Cab.df <- as.data.frame(xgb_predictions[["Cab"]])
rownames(xgb.pred.Cab.df) <- rownames(rf.pred.Cab.df)
save(xgb.pred.Cab.df, file="RData/0407_XGBoost/predictions_Cab.RData")

xgb.pred.Car.df <- as.data.frame(xgb_predictions[["Car"]])
rownames(xgb.pred.Car.df) <- rownames(rf.pred.Car.df)
save(xgb.pred.Car.df, file="RData/0407_XGBoost/predictions_Car.RData")

xgb.pred.LAI.df <- as.data.frame(xgb_predictions[["LAI"]])
rownames(xgb.pred.LAI.df) <- rownames(rf.pred.LAI.df)
save(xgb.pred.LAI.df, file="RData/0407_XGBoost/predictions_LAI.RData")

xgb.pred.LMA.df <- as.data.frame(xgb_predictions[["LMA"]])
rownames(xgb.pred.LMA.df) <- rownames(rf.pred.LMA.df)
save(xgb.pred.LMA.df, file="RData/0407_XGBoost/predictions_LMA.RData")



