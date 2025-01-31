#!/usr/bin/env Rscript

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script: spectra_quantiles.R
# Purpose: This script reads observed and simulated reflectance spectra,
#          processes the data by removing noisy spectra and smoothing,
#          calculates quantiles and averages, and generates a plot comparing
#          observed measurements with PROSAIL model simulations.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Load utility functions
source("functions.R")

# Load necessary libraries, suppress messages to keep output clean
suppressMessages(library(crayon))
suppressMessages(library(tidyverse))
suppressMessages(library(ggplot2))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Load Soil Spectrum Data
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Load the soil spectrum data required for PROSAIL simulations
load("data/BL.dry_spec.RData")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Check if Preprocessed Quantiles Data Exists
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if (file.exists("RData/quantiles_plot_data.RData")) {
  # Load precomputed quantiles data if it exists
  load("RData/quantiles_plot_data.RData")
} else {
  # If quantiles data doesn't exist, proceed to prepare it
  cat("Old savefile doesn't exist, preparing...\n")

  # Load additional libraries required for data processing
  suppressMessages(library(hsdar))    # For PROSAIL simulations
  suppressMessages(library(smooth))   # For smoothing functions
  suppressMessages(library(reshape2)) # For data reshaping

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # PROSAIL Simulation
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Check if a previous PROSAIL simulation exists
  if (file.exists("RData/0407/workspace_save_PROSAIL_done.RData")) {
    # Load previous PROSAIL simulation data
    load("RData/0407/workspace_save_PROSAIL_done.RData")
    cat("...previous PROSAIL simulation loaded successfully!\n")
  } else {
    # If no previous simulation exists, perform a new PROSAIL simulation
    cat("...previous PROSAIL simulation is not found, performing the simulation...\n")
    # Run PROSAIL with the defined parameter list, set TypeLidf and soil reflectance
    prosail_spectra <- PROSAIL(parameterList = parameter_list, TypeLidf = 2, rsoil = BL.dry_spec)
    # Save the workspace for future use
    save(list = ls(), file = "RData/0407/workspace_save_PROSAIL_done.RData")
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Read Observed Reflectance Data
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Read all available observed reflectance data (wavelengths 350-399 nm already removed)
  data <- read.csv("data/reflectances_obs_0504-1011_all.csv") 
  wavel <- data[, 1]  # Extract wavelength information

  # Get the number of simulations in the parameter list
  list_size <- dim(parameter_list)[1]

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Define Spectral Ranges to Exclude
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  spectra_ranges <- 3  # Option to choose different spectral ranges

  # Define ranges to exclude from observed data and PROSAIL spectra
  if (spectra_ranges == 3) {
    ranges_to_delete <- c(920:1081, 1350:1601, 1820:2101)  # Wavelength ranges to exclude
    # Corresponds to ranges: 1320-1480 nm, 1750-2000 nm, 2220-2500 nm
  }

  if (spectra_ranges == 2) {
    ranges_to_delete <- c(920:1081, 1350:2101)  # Exclude a larger spectral range
    # Corresponds to ranges: 1320-1480 nm, 1750-2500 nm
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Remove Specified Spectral Ranges from Data
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Set the specified ranges to NA in the observed data (excluding the wavelength column)
  data[ranges_to_delete, -1] <- NA

  # Remove the wavelength column from data to create data2
  data2 <- data[, -1] 

  # Convert PROSAIL spectra to a data frame if not already
  prosail_spectra <- as.data.frame(prosail_spectra)

  # Set the specified ranges to NA in the PROSAIL spectra
  prosail_spectra[, ranges_to_delete] <- NA

  # Optionally, verify that the ranges have been set to NA
  # print(prosail_spectra[920:930, 1:5])  # Check a subset to ensure values are NA
  # print(data2[920:930, 2:6])            # Check a subset to ensure values are NA

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Identify Noisy Spectra in Observed Data
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  cat("Searching for noisy spectra...\n")

  # Specify the range indices for wavelengths
  start_wavelength <- 1
  end_wavelength <- nrow(data2)

  # Check for noisy spectra in data2 (spectra with values outside [0, 1])
  noisy_spectra <- apply(data2, 2, function(spectrum) {
    any((spectrum[start_wavelength:end_wavelength] > 1 | spectrum[start_wavelength:end_wavelength] < 0), na.rm = TRUE)
  })

  # Get the names of the noisy spectra
  noisy_spectrum_names <- colnames(data2)[noisy_spectra]

  # Print the number of noisy spectra found
  if (length(noisy_spectrum_names) > 0) {
    # Calculate the total number of noisy spectra
    total_noisy_spectra <- sum(noisy_spectra)
    cat("Total Noisy Spectra:", total_noisy_spectra, "\n")
    # Optionally, print the names of the noisy spectra
    # cat("Noisy Spectrum Names:", paste(noisy_spectrum_names, collapse = ", "), "\n")
  } else {
    cat("No noisy spectra found.\n")
  }

  # Get the indices of spectra that are not noisy
  non_noisy_indices <- which(!noisy_spectra)

  # Create a new DataFrame containing only the non-noisy spectra
  data2_nl <- data2[, non_noisy_indices]  # 'nl' stands for 'noiseless'

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Spline Smoothing of Observed Spectra
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  cat("Spline smoothing.\n")

  # Define a function to apply smoothing spline to a spectrum
  smooth_spectrum <- function(spectrum, x, df = 50) {
    # Remove NA values from the spectrum
    non_na_indices <- !is.na(spectrum)
    x_non_na <- x[non_na_indices]
    y_non_na <- spectrum[non_na_indices]

    # Apply smoothing spline with specified degrees of freedom
    smooth_values <- smooth.spline(x = x_non_na, y = y_non_na, df = df)$y

    # Create a vector to store smoothed values, filled with NA initially
    smoothed_spectrum <- rep(NA, length(spectrum))
    smoothed_spectrum[non_na_indices] <- smooth_values

    return(smoothed_spectrum)
  }

  # Apply the smoothing function to each spectrum in data2_nl
  smoothed_data <- apply(data2_nl, 2, smooth_spectrum, x = 1:2101, df = 50)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Prepare Data for Plotting
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Convert the smoothed data to a data frame
  data2_nls <- as.data.frame(t(smoothed_data))

  # Get the names of the spectra (column names)
  spectra_names <- names(data2_nl)

  # Ensure the column names match between observed and PROSAIL spectra
  names(data2_nls) <- names(prosail_spectra)  # Necessary for correct prediction

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Calculate Quantiles and Averages for Plotting
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Prepare data for plotting
  tdata <- as.data.frame(data2_nls)

  # Optionally, display variable information
  var_info(tdata)
  var_info(prosail_spectra)

  # Calculate mean and quantiles for the observed spectra
  avg <- apply(tdata, 2, mean, na.rm = TRUE)
  q.high <- apply(tdata, 2, quantile, 0.9, na.rm = TRUE)
  q.low <- apply(tdata, 2, quantile, 0.1, na.rm = TRUE)

  # Calculate mean and quantiles for the PROSAIL simulated spectra
  avg_p <- apply(prosail_spectra, 2, mean, na.rm = TRUE)
  q.high_p <- apply(prosail_spectra, 2, quantile, 0.9, na.rm = TRUE)
  q.low_p <- apply(prosail_spectra, 2, quantile, 0.1, na.rm = TRUE)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Prepare Data Frame for ggplot2
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Create a data frame containing wavelengths and calculated statistics
  spectra_df <- data.frame(
    Wavelength = wavel,
    Avg = avg,
    Q95 = q.high,
    Q05 = q.low,
    Avg_p = avg_p,
    Q95_p = q.high_p,
    Q05_p = q.low_p
  )

  # Optionally, melt the data frame for ggplot2 (not used in current code)
  # spectra_melted <- melt(spectra_df, id.vars = "Wavelength")

  # Optionally, display variable information
  var_info(spectra_df)

  # Save the prepared data for future use
  save(spectra_df, file = "RData/quantiles_plot_data.RData")
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Plotting the Spectra Quantiles
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Create the plot using ggplot2
p <- ggplot(spectra_df, aes(x = Wavelength)) +
  # Add ribbon for observed spectra quantiles
  geom_ribbon(aes(ymin = Q05, ymax = Q95), fill = "blue", alpha = 0.2, show.legend = FALSE) + 
  # Add line for average observed spectra
  geom_line(aes(y = Avg, color = "Average measurements"), size = 1) +                                                                                    
  # Add dashed lines for observed quantiles
  geom_line(aes(y = Q95, color = "5th/95th quantile measurements"), size = 1, linetype = "dashed") +                                                                
  geom_line(aes(y = Q05, color = "5th/95th quantile measurements"), size = 1, linetype = "dashed", show.legend = FALSE) +                                                               
  # Add ribbon for PROSAIL spectra quantiles
  geom_ribbon(aes(ymin = Q05_p, ymax = Q95_p), fill = "brown1", alpha = 0.2, show.legend = FALSE) + 
  # Add line for average PROSAIL spectra
  geom_line(aes(y = Avg_p, color = "Average PROSAIL"), size = 1) +                                                                                    
  # Add dashed lines for PROSAIL quantiles
  geom_line(aes(y = Q95_p, color = "5th/95th quantile PROSAIL"), size = 1, linetype = "dashed") +                                                                
  geom_line(aes(y = Q05_p, color = "5th/95th quantile PROSAIL"), size = 1, linetype = "dashed", show.legend = FALSE) +
  # Define custom colors for the lines
  scale_color_manual(values = c(
    "Average measurements" = "blue3", 
    "5th/95th quantile measurements" = "blue", 
    "Average PROSAIL" = "brown4", 
    "5th/95th quantile PROSAIL" = "brown"
  )) +
  # Set labels and theme
  labs(title = "",
       x = "Wavelength, nm",
       y = "Reflectance") + 
  theme_classic() +  
  theme(
    plot.title = element_text(size = 18, face = "bold"),                                                                                                      
    axis.title.x = element_text(size = 26),                                                                                                                   
    axis.title.y = element_text(size = 26),
    axis.text.x = element_text(size = 24),
    axis.text.y = element_text(size = 24),
    legend.position = c(0.95, 1.02),  # Position legend inside plot, upper right corner 
    legend.justification = c("right", "top"), 
    legend.background = element_rect(fill = "white", color = NA), 
    legend.title = element_blank(),  # Remove legend title
    legend.text = element_text(size = 18) 
  ) + 
  theme(legend.key.size =  unit(1, "cm"))

# Save the plot to a file
ggsave(filename = "plots/spectra_quantiles_new.png", plot = p, width = 12, height = 8, dpi = 400)

