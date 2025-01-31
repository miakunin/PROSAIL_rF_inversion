#!/usr/bin/env Rscript

#
# This is a fork of the main.R script
#	it works in the same manner but does applies PCA at the end
# for the detailed comments see main.R
#

Sys.setenv(LANG = "en")

rm(list=ls())

source("functions.R")

suppressMessages(library(hsdar))
suppressMessages(library(randomForest))
suppressMessages(library(crayon))
suppressMessages(library(prosail))
suppressMessages(library(tidyverse))
suppressMessages(library(smooth))

source("parameter_list_0711.R")
#load("RData/0407/parameter_list.RData")

# reading soil spectrum
load("data/BL.dry_spec.RData")

args <- commandArgs(trailingOnly = TRUE)  # var for shell arguments

if (length(args) == 0 || args[1] == "") {
  cat("No folder was specified.\n")
	stop("Define working directory.\n")
} else {
  affix1 <- as.character(args[1])
	cat(paste0("Working directory set to ",affix1),"\n")
}

prosail_filename <- paste0(affix1,"/workspace_save_PROSAIL_done.RData")

#~~~~~~~~~~~~~~~~~~~~~~~~~
# PROSAIL simulation
#

if (file.exists(prosail_filename)) {
	load(prosail_filename)
	cat("Previous PROSAIL simulation loaded successfully. \n")
} else {
	cat("PROSAIL simulation not found, running the model...\n")
	prosail_spectra <- PROSAIL(parameterList=parameter_list, TypeLidf=2, rsoil=BL.dry_spec)
	cat("	...done. saving results.\n")
	save(prosail_spectra, file=prosail_filename)
}

# read ALL available reflectances
data <- read.csv("data/reflectances_obs_0504-1011_all.csv") # 350-399 nm lines deleted already
wavel <- data[,1]

list_size <- dim(parameter_list)[1]

spectra_ranges <- 2

# define ranges to cut from obs data and prosail spectra
if (spectra_ranges == 3) {
ranges_to_delete <- c(920:1081, 1350:1601, 1820:2101) # 1320-1480, 1750-2000, 2220-2500
}

if (spectra_ranges == 2 ) {
ranges_to_delete <- c(920:1081, 1350:2101) # 1320-1480, 1750-2500 # delete complete 3rd part of the spectrum
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

# df - degrees of freedom, set to 50

cat("Spline smoothing. \n")

range1 <- 1:919
range2 <- 920:1187
range3 <- 1188:1405

if ( spectra_ranges == 3) {
smoothed_spectra <- apply(data2_nl, 2, function(spectrum) {
  smooth1 <- smooth.spline(x = range1, y = spectrum[range1], df = 50)$y
  smooth2 <- smooth.spline(x = range2, y = spectrum[range2], df = 50)$y
  smooth3 <- smooth.spline(x = range3, y = spectrum[range3], df = 50)$y

  # Concatenate the smoothed segments
  c(smooth1, smooth2, smooth3)
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

# Create a new DataFrame with the smoothed spectra

# making the variables dataframes:
prosail_spectra <- as.data.frame(prosail_spectra)
prosail_spectra2 <- as.data.frame(prosail_spectra2)
data2_nls <- as.data.frame(t(smoothed_spectra))

spectra_names <- names(data2_nl)

names(data2_nls) <- names(prosail_spectra2) # need to keep the same names in the data frames for correct prediction

#var_info(prosail_spectra2)
#var_info(data2_nls)

# getting indices for each date:
row_i_dates <- list()
for (i in seq_along(obs_dates)) { row_i_dates[[i]] <- grep(obs_dates[i], rownames(data2_nls))}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PCA
#

cat("Performing PCA\n")

pca_prosail <- prcomp(prosail_spectra2, center = TRUE, scale. = TRUE)
#num_components <- 20
num_components <- 10

prosail_spectra2_pca <- pca_prosail$x[, 1:num_components]
data2_scaled <- scale(data2_nls, center = pca_prosail$center, scale = pca_prosail$scale)
data2_pca <- as.data.frame(data2_scaled %*% pca_prosail$rotation[, 1:num_components])
train_var <- as.data.frame(prosail_spectra2_pca)
test_var <- as.data.frame(data2_pca)

var_info(train_var)
var_info(test_var)

save(parameter_list, spectra_names, train_var, test_var, file=paste0(affix1,"/PROSAIL_done_RF_ready.RData"))
