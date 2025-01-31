#!/usr/bin/env Rscript
Sys.setenv(LANG = "en")

# Remove all objects from the current workspace to start fresh
rm(list=ls())

# Source external functions and parameter list required for the script
source("functions.R")				# Contains custom functions used in the script
source("parameter_list.R")	# Contains the 'parameter_list' variable

# Load necessary libraries quietly to avoid cluttering the output
suppressMessages(library(hsdar))					# Hyperspectral Data Analysis in R
suppressMessages(library(randomForest))		# For random forest modeling
suppressMessages(library(crayon))					# Colored terminal output
suppressMessages(library(prosail))				# PROSAIL canopy reflectance model
suppressMessages(library(tidyverse))			# Data manipulation and visualization
suppressMessages(library(smooth))					# Smoothing functions

# Load the soil spectrum data required for the PROSAIL simulation
load("data/BL.dry_spec.RData")

args <- commandArgs(trailingOnly = TRUE)  # Getting arguments from the command line 

if (length(args) == 0 || args[1] == "") { # If there is no arguments - stop
  cat("No folder was specified.\n")
	stop("Define working directory.\n")
} else {
  affix1 <- as.character(args[1])
	cat(paste0("Working directory set to ",affix1),"\n")
}

prosail_filename <- paste0(affix1,"/workspace_save_PROSAIL_done.RData")	# affix1 should be the working directory for the data

#~~~~~~~~~~~~~~~~~~~~~~~~~
# PROSAIL simulation
#

# Check if a previous PROSAIL simulation exists
if (file.exists(prosail_filename)) {
	# Load existing PROSAIL simulation data
	load(prosail_filename)
	cat("Previous PROSAIL simulation loaded successfully!\n")
} else {
	# If not found, perform a new PROSAIL simulation using the defined parameters	
	cat("No PROSAIL was found, performing the simulation...\n")
	prosail_spectra <- PROSAIL(
		parameterList=parameter_list, # Parameters for the simulation 
		TypeLidf=2, 									# Leaf inclination distribution function type (if not 2, lidfa parameter is not used)
		rsoil=BL.dry_spec							# Soil reflectance spectrum
	)
	# Save the simulation results for future use
	save(prosail_spectra, file=prosail_filename)
}

#~~~~~~~~~~~~~~~~~~~~~~~~~
# Data Preparation

# Read all available observed reflectance data
data <- read.csv("data/reflectances_obs_0504-1011_all.csv") # 350-399 nm lines deleted already
wavel <- data[,1]		# Extract wavelength column

# Define the number of spectral ranges to process (either 2 or 3)
# whether to keep the tail of the specra or cut it
spectra_ranges <- 2

# Define wavelength ranges to exclude based on the number of spectral ranges
if (spectra_ranges == 3) {
ranges_to_delete <- c(920:1081, 1350:1601, 1820:2101) # 1320-1480, 1750-2000, 2220-2500
}

if (spectra_ranges == 2 ) {
ranges_to_delete <- c(920:1081, 1350:2101) # 1320-1480, 1750-2500 # delete complete 3rd part of the spectrum
}

# Remove the specified ranges from PROSAIL spectra, observed data, and wavelengths
prosail_spectra2 <- prosail_spectra[, -ranges_to_delete]	# Adjust PROSAIL spectra
data2 <- data[-ranges_to_delete, -1] 											# Adjust observed data (also exclude wavelength column)	
wavel2 <- wavel[-ranges_to_delete]												# Adjust wavelength vector	

#~~~~~~~~~~~~~~~~~~~~~~~~~
# determine noisy spectra
#

cat("Searching for noisy spectra...\n")

# Define the indices for the spectral range to check
start_wavelength <- 1
end_wavelength <- nrow(data2)

# Identify spectra with values outside the [0, 1] range
noisy_spectra <- apply(data2, 2, function(spectrum) {
  any(spectrum[start_wavelength:end_wavelength] > 1 | spectrum[start_wavelength:end_wavelength] < 0)
})

# Get the names of the noisy spectra
noisy_spectrum_names <- colnames(data2)[noisy_spectra]

# Print the names of noisy spectra if any are found
if (length(noisy_spectrum_names) > 0) {
  cat("Noisy Spectrum Names:", paste(noisy_spectrum_names, collapse = ", "), "\n")
} else {
  cat("No noisy spectra found.\n")
}

# Print the total number of noisy spectra
total_noisy_spectra <- sum(noisy_spectra)
cat("Total Noisy Spectra:", total_noisy_spectra, "\n")

# Indices of spectra that are not noisy
non_noisy_indices <- which(!noisy_spectra)

# Create a new data frame containing only the non-noisy spectra
data2_nl <- data2[, non_noisy_indices] # 'nl' stands for 'noiseless'

# ~~~~~~~~~~~~~~~~~~~~
# Spline smoothing
#

# df - degrees of freedom, set to 50

cat("Spline smoothing. \n")

# Define ranges for spline smoothing based on spectral indices
range1 <- 1:919
range2 <- 920:1187
range3 <- 1188:1405	# Only used if spectra_ranges == 3

# Apply smoothing splines to each spectral range
if ( spectra_ranges == 3) {
 # For three spectral ranges
	smoothed_spectra <- apply(data2_nl, 2, function(spectrum) {
		# Apply smoothing spline with degrees of freedom set to 50
 		smooth1 <- smooth.spline(x = range1, y = spectrum[range1], df = 50)$y
  	smooth2 <- smooth.spline(x = range2, y = spectrum[range2], df = 50)$y
  	smooth3 <- smooth.spline(x = range3, y = spectrum[range3], df = 50)$y
  	# Concatenate the smoothed segments
  	c(smooth1, smooth2, smooth3)
	})
}

if (spectra_ranges == 2) {
  # For two spectral ranges
  smoothed_spectra <- apply(data2_nl, 2, function(spectrum) {
    # Apply smoothing spline with degrees of freedom set to 50
    smooth1 <- smooth.spline(x = range1, y = spectrum[range1], df = 50)$y
    smooth2 <- smooth.spline(x = range2, y = spectrum[range2], df = 50)$y
    # Concatenate the smoothed segments
    c(smooth1, smooth2)
  })
}

#~~~~~~~~~~~~~~~~~~~~~~~~~
# Final Data Preparation
#

# Convert variables to data frames for consistency
prosail_spectra <- as.data.frame(prosail_spectra)
prosail_spectra2 <- as.data.frame(prosail_spectra2)
data2_nls <- as.data.frame(t(smoothed_spectra))  # 'nls' stands for 'noiseless smoothed'

# Save the names of the spectra for future reference
spectra_names <- names(data2_nl)

# Ensure the column names match between observed and simulated data for correct alignment
names(data2_nls) <- names(prosail_spectra2) # need to keep the same names in the data frames for correct prediction

# Display variable information (assuming 'var_info' is a custom function)
var_info(prosail_spectra2)
var_info(data2_nls)

# Create a list to hold indices for each observation date
row_i_dates <- list()
for (i in seq_along(obs_dates)) {
  # Find row indices where the row names contain the observation date
  row_i_dates[[i]] <- grep(obs_dates[i], rownames(data2_nls))
}

#~~~~~~~~~~~~~~~~~~~~~~~~~
# Save Prepared Data
#

# Save the processed data and variables for later use in modeling
save(
  parameter_list,  # List of parameters used in PROSAIL simulation
  spectra_names,   # Names of the spectra samples
  data2_nls,       # Smoothed and noiseless observed data
  prosail_spectra2, # Processed PROSAIL simulation data
  file = paste0(affix1,"/PROSAIL_done_RF_ready.RData"  # Output file
)
