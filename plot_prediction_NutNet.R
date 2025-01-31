#!/usr/bin/env Rscript

# Load external functions from 'functions.R' and 'functions_plots.R'
source("functions.R")
source("functions_plots.R")

# Load necessary library
library(randomForest)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Define Input Files and Load Data
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# The 'in_list' variable contains paths to .RData files with prediction data.
# Multiple versions of 'in_list' are provided; some are commented out.
# Uncomment the appropriate one based on the data you wish to use.

# Previous input lists (commented out)
# in_list <- c("RData/predictions_Cab_pca.RData", "RData/predictions_Cab.RData", ...)

# Current input list with prediction data for various traits
in_list <- c(
  "RData/0407/predictions_Cab.RData",
  "RData/0407/predictions_Car.RData",
  "RData/0407/predictions_LAI.RData",
  "RData/0407/predictions_LMA.RData"
)

# Read all the inputs specified in 'in_list'
for (f in in_list) {
  load(f)  # Loads variables like 'rf.pred.Cab.df', 'rf.pred.Car.df', etc.
}

# Load measurement data from CSV file, using the first column as row names
meas <- read.csv("data/measurements_0504-1011_all.csv", row.names = 1)

# Optionally, display list of variables in the environment (commented out)
# cat("List of variables: \n")
# ls()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set Trait for Plotting Based on Command-Line Arguments
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Retrieve command-line arguments (if any)
args <- commandArgs(trailingOnly = TRUE)  # Variable for shell arguments

# Check if a trait was specified; default to 'Cab' if not
if (length(args) == 0 || args[1] == "") {
  trait <- "Cab"  # Default trait
  cat("No trait was specified, do plots for Cab.\n")
} else {
  trait <- args[1]  # Trait specified by the user
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Configure Plotting Parameters Based on the Trait
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Initialize variables based on the selected trait
if (trait == "Cab") {
  var_plot1 <- rf.pred.Cab.df            # Predicted Cab values
  # var_plot2 <- rf.pred.Cab.pca.df      # Alternative predictions (commented out)
  meas_trait <- 1                        # Column index for Cab in 'meas' data
  ylabel <- "Cab [μg/cm\u00B2]"          # Y-axis label
  # Filenames for output plots
  plot_filename1 <- "plots/pred_NutNet_control_Cab_final.png"
  plot_filename2 <- "plots/pred_NutNet_NPK_Cab_final.png"
  yranges_offset <- 15                   # Y-axis range offset for plotting
} else if (trait == "Car") {
  var_plot1 <- rf.pred.Car.df
  meas_trait <- 2
  ylabel <- "Car [μg/cm\u00B2]"
  plot_filename1 <- "plots/pred_NutNet_control_Car_final.png"
  plot_filename2 <- "plots/pred_NutNet_NPK_Car_final.png"
  yranges_offset <- 2
} else if (trait == "LAI") {
  var_plot1 <- rf.pred.LAI.df
  meas_trait <- 3
  ylabel <- "LAI [m\u00B2/m\u00B2]"
  plot_filename1 <- "plots/pred_NutNet_control_LAI_final.png"
  plot_filename2 <- "plots/pred_NutNet_NPK_LAI_final.png"
  yranges_offset <- 1
} else if (trait == "LMA") {
  var_plot1 <- rf.pred.LMA.df
  meas_trait <- 4
  ylabel <- "LMA [g/cm\u00B2]"
  plot_filename1 <- "plots/pred_NutNet_control_LMA_final.png"
  plot_filename2 <- "plots/pred_NutNet_NPK_LMA_final.png"
  yranges_offset <- 0
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set Text and Plot Appearance Parameters
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Main title for the plots
main_title <- trait

# Font sizes for various plot elements
title_fs <- 2.8       # Title font size
axis_fs <- 2.0        # Axis font size
labels_fs <- 2.5      # Labels font size
main_fs <- 3.0        # Main text font size
header_fs <- 2.6      # Header font size

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Plotting for Control Group (NutNet)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Initialize the plotting device for the control group
png(plot_filename1, width = 1600, height = 1200)

# Set up the plotting area with 3 rows and 1 column
par(mfrow = c(3, 1), oma = c(2, 1, 3.5, 1), mar = c(3, 3, 3, 3) + 5)

# Define groups of data for plotting
# Index numbers correspond to plots in 'meas' and 'plots_list'

# Plot for b1p02c (index 4)
plot1 <- plot_group_only_one(4, var_plot1, meas, "NutNet b1p02c")

# Plot for b2p09c (index 5)
plot1 <- plot_group_only_one(5, var_plot1, meas, "NutNet b2p09c")

# Plot for b3p19c (index 6)
plot1 <- plot_group_only_one(6, var_plot1, meas, "NutNet b3p19c")

# Add the main title across all subplots
mtext(main_title, outer = TRUE, side = 3, line = 1, cex = 2.5)

# Close the plotting device and save the file
dev.off()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Plotting for NPK Treatment Group (NutNet)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Initialize the plotting device for the NPK group
png(plot_filename2, width = 1600, height = 1200)

# Set up the plotting area with 3 rows and 1 column
par(mfrow = c(3, 1), oma = c(2, 1, 3.5, 1), mar = c(3, 3, 3, 3) + 5)

# Define groups of data for plotting

# Plot for b1p04npk (index 7)
plot1 <- plot_group_only_one(7, var_plot1, meas, "NutNet b1p04npk")

# Plot for b2p10npk (index 8)
plot1 <- plot_group_only_one(8, var_plot1, meas, "NutNet b2p10npk")

# Plot for b3p23npk (index 9)
plot1 <- plot_group_only_one(9, var_plot1, meas, "NutNet b3p23npk")

# Add the main title across all subplots
mtext(main_title, outer = TRUE, side = 3, line = 1, cex = header_fs)

# Close the plotting device and save the file
dev.off()

