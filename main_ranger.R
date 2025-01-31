#!/usr/bin/env Rscript
Sys.setenv(LANG = "en")

rm(list=ls())

suppressMessages(library(hsdar))
suppressMessages(library(crayon))
suppressMessages(library(tidyverse))
suppressMessages(library(prosail))
suppressMessages(library(smooth))
suppressMessages(library(ranger))

source("functions.R")
#source("parameter_list_ranger.R")
source("parameter_list_0709_PCA_large.R")

# reading soil spectrum
load("data/BL.dry_spec.RData")

args <- commandArgs(trailingOnly = TRUE)  # var for shell arguments

if (length(args) == 0 || args[1] == "") {
	stop("No working directory was spedified, terminating...")
} else {
  workdir_affix <- as.character(args[1])
}

prosail_filename <- paste0("RData/",workdir_affix,"/workspace_save_PROSAIL_done.RData")

if (file.exists(prosail_filename)) {
	load(prosail_filename)
	cat("Previous PROSAIL simulation loaded successfully. \n")
} else {
	cat("PROSAIL simulation not found, running the model...\n")
	prosail_spectra <- PROSAIL(parameterList=parameter_list, TypeLidf=2, rsoil=BL.dry_spec)
	save(prosail_spectra, file=prosail_filename)
}

# read ALL available reflectances
data <- read.csv("data/reflectances_obs_0504-1011_all.csv") # 350-399 nm lines deleted already
wavel <- data[,1]

list_size <- dim(parameter_list)[1]

spectra_ranges <- 2

# define ranges to cut from obs data and prosail spectra
if (spectra_ranges == 1 ) {
ranges_to_delete <- c(920:2101) 
}

if (spectra_ranges == 2 ) {
ranges_to_delete <- c(920:1081, 1350:2101) # 1320-1480, 1750-2500 # delete complete 3rd part of the spectrum
}

if (spectra_ranges == 3) {
ranges_to_delete <- c(920:1081, 1350:1601, 1820:2101) # 1320-1480, 1750-2000, 2220-2500
}

# cut the desired ranges from data and wavelength column
prosail_spectra2 <- prosail_spectra[, -ranges_to_delete]
data2 <- data[-ranges_to_delete, -1] 
wavel2 <- wavel[-ranges_to_delete]

#~~~~~~~~~~~~~~~~~~~~~~~~~
# determine noisy spectra
#

cat("Searching for noisy spectra...\n")

# specify the range indices:
start_wavelength <- 1
end_wavelength <- nrow(data2)

# check for noisy spectra in data2
noisy_spectra <- apply(data2, 2, function(spectrum) {
  any(spectrum[start_wavelength:end_wavelength] > 1 | spectrum[start_wavelength:end_wavelength] < 0)
})

# get the names of the noisy spectra
noisy_spectrum_names <- colnames(data2)[noisy_spectra]

# print the names of noisy spectra
if (length(noisy_spectrum_names) > 0) {
  cat("Noisy Spectrum Names:", paste(noisy_spectrum_names, collapse = ", "), "\n")
} else {
  cat("No noisy spectra found.\n")
}

# calculate the total number of noisy spectra
total_noisy_spectra <- sum(noisy_spectra)
cat("Total Noisy Spectra:", total_noisy_spectra, "\n")

# get the indices of spectra that are not noisy
non_noisy_indices <- which(!noisy_spectra)

# create a new DataFrame containing only the non-noisy spectra
data2_nl <- data2[, non_noisy_indices] # data2_noiseless

# ~~~~~~~~~~~~~~~~~~~~
# Spline smoothing
#

# df - degrees of freedom, set to 50

cat("Spline smoothing. \n")

range1 <- 1:919
range2 <- 920:1187
range3 <- 1188:1405

if ( spectra_ranges == 1) {
smoothed_spectra <- apply(data2_nl, 2, function(spectrum) {
  smooth1 <- smooth.spline(x = range1, y = spectrum[range1], df = 50)$y
})
}

if ( spectra_ranges == 2) {
smoothed_spectra <- apply(data2_nl, 2, function(spectrum) {
  smooth1 <- smooth.spline(x = range1, y = spectrum[range1], df = 50)$y
  smooth2 <- smooth.spline(x = range2, y = spectrum[range2], df = 50)$y

  # Concatenate the smoothed segments
  c(smooth1, smooth2)
})
}

if ( spectra_ranges == 3) {
smoothed_spectra <- apply(data2_nl, 2, function(spectrum) {
  smooth1 <- smooth.spline(x = range1, y = spectrum[range1], df = 50)$y
  smooth2 <- smooth.spline(x = range2, y = spectrum[range2], df = 50)$y
  smooth3 <- smooth.spline(x = range3, y = spectrum[range3], df = 50)$y

  # Concatenate the smoothed segments
  c(smooth1, smooth2, smooth3)
})
}

# Create a new DataFrame with the smoothed spectra

# making the variables dataframes:
prosail_spectra <- as.data.frame(prosail_spectra)
prosail_spectra2 <- as.data.frame(prosail_spectra2)
data2_nls <- as.data.frame(t(smoothed_spectra))

spectra_names <- names(data2_nl)

names(data2_nls) <- names(prosail_spectra2) # need to keep the same names in the data frames for correct prediction

# getting indices for each date:
row_i_dates <- list()
for (i in seq_along(obs_dates)) { row_i_dates[[i]] <- grep(obs_dates[i], rownames(data2_nls))}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PCA
#

cat("Applying PCA...\n")

var_info(prosail_spectra2)

pca_prosail <- prcomp(prosail_spectra2, center = TRUE, scale. = TRUE)
#num_components <- 20
num_components <- 9
nmtry <- num_components %/% 3
nmtry <- 3

prosail_spectra2_pca <- pca_prosail$x[, 1:num_components]

data2_scaled <- scale(data2_nls, center = pca_prosail$center, scale = pca_prosail$scale)
data2_pca <- as.data.frame(data2_scaled %*% pca_prosail$rotation[, 1:num_components])

train_var <- as.data.frame(prosail_spectra2_pca)
test_var <- as.data.frame(data2_pca)

cat("PCA done!\n")
var_info(train_var)
var_info(test_var)

save(parameter_list, spectra_names, train_var, test_var, file=paste0("RData/",workdir_affix,"/PROSAIL_done_RF_ready.RData"))

# ~~~~~~~~~~~~~~~~~~~
# Begin randomForest
#

# as the ranger library is much much much faster than classic randomForest, there is no need to run four separate scripts for model training in parallel
# we can do them one by one here with no time (assuming the same size of the parameter_list

cat("Starting RandomForest (ranger) processes...\n")

var_info(train_var)
var_info(test_var)

cat("  --> Cab\n")
rf_Cab <- ranger(x=train_var, y=parameter_list[, 1], num.trees=500, mtry=nmtry, verbose=TRUE)
cat("  --> Car\n")
rf_Car <- ranger(x=train_var, y=parameter_list[, 2], num.trees=500, mtry=nmtry, verbose=TRUE)
cat("  --> LAI\n")
rf_LAI <- ranger(x=train_var, y=parameter_list[, 7], num.trees=500, mtry=nmtry, verbose=TRUE)
cat("  --> LMA\n")
rf_LMA <- ranger(x=train_var, y=parameter_list[, 5], num.trees=500, mtry=nmtry, verbose=TRUE)
#rf_LWC <- ranger(x=train_var, y=parameter_list[, 4], num.trees=500, mtry=16, verbose=TRUE)

#save(rf_Cab,rf_Car,rf_LAI,rf_LMA,rf_LWC, file=paste0("RData/",workdir_affix,"/rf_LWC_ranger_save.RData"))
save(rf_Cab, rf_Car, rf_LAI, rf_LMA, file=paste0("RData/",workdir_affix,"/rf_ranger_save.RData"))

# ~~~~~~~~~~~~~~~~~~~~~
# Parameter prediction
# 

cat("Predict Cab\n")
rf.pred.Cab <- predict(rf_Cab, data=test_var)
rf.pred.Cab.df <- data.frame(Cab = as.numeric(rf.pred.Cab$prediction), row.names = spectra_names)
save(rf.pred.Cab.df, file=paste0("RData/",workdir_affix,"/predictions_Cab.RData"))

cat("Predict Car\n")
rf.pred.Car <- predict(rf_Car, data=test_var)
rf.pred.Car.df <- data.frame(Car = as.numeric(rf.pred.Car$prediction), row.names = spectra_names)
save(rf.pred.Car.df, file=paste0("RData/",workdir_affix,"/predictions_Car.RData"))

cat("Predict LAI\n")
rf.pred.LAI <- predict(rf_LAI, data=test_var)
rf.pred.LAI.df <- data.frame(LAI = as.numeric(rf.pred.LAI$prediction), row.names = spectra_names)
save(rf.pred.LAI.df, file=paste0("RData/",workdir_affix,"/predictions_LAI.RData"))

cat("Predict LMA\n")
rf.pred.LMA <- predict(rf_LMA, data=test_var)
rf.pred.LMA.df <- data.frame(LMA = as.numeric(rf.pred.LMA$prediction), row.names = spectra_names)
save(rf.pred.LMA.df, file=paste0("RData/",workdir_affix,"/predictions_LMA.RData"))

#cat("Predict LWC\n")
#rf.pred.LWC <- predict(rf_LWC, data=test_var)
#rf.pred.LWC.df <- data.frame(LWC = as.numeric(rf.pred.LWC$prediction), row.names = spectra_names)
#save(rf.pred.LWC.df, file=paste0("RData/",workdir_affix,"/predictions_LWC.RData"))
