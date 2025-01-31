#!/usr/bin/env Rscript

# Load external functions from 'functions.R'
source("functions.R")

# Load the 'randomForest' package for model predictions
library(randomForest)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Define Input Files and Load Data
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# The 'in_list' contains paths to .RData files with prediction data.
# Several versions of 'in_list' are provided, with some commented out.
# Uncomment the appropriate one based on the data you want to use.

# Example of previous input lists (commented out)
# in_list <- c("RData/predictions_Cab_pca.RData", "RData/predictions_Cab.RData", ...)

# Current input list with prediction data for various traits
in_list <- c(
  "RData/0407/predictions_Cab.RData",
  "RData/0407/predictions_Car.RData",
  "RData/0407/predictions_LAI.RData",
  "RData/0407/predictions_LMA.RData"
)

# Load all prediction data files specified in 'in_list'
for (f in in_list) {
  load(f)  # Loads variables like 'rf.pred.Cab.df', 'rf.pred.Car.df', etc.
}

# Read measurements data from CSV file, using the first column as row names
meas <- read.csv("data/measurements_0504-1011_all.csv", row.names = 1)

# Display a list of variables currently in the environment
cat("List of variables: \n")
ls()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set Trait for Plotting Based on Command-Line Arguments
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Retrieve command-line arguments (if any)
args <- commandArgs(trailingOnly = TRUE)

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
  meas_trait <- 1                        # Column index for Cab in 'meas' data
  ylabel <- "Cab [μg/cm\u00B2]"          # Y-axis label
  plot_filename1 <- "plots/pred_GCEF_Cab_vertical_scatter_final_2.png"  # Output filename
  yranges_offset <- 15                   # Y-axis range offset for plotting, 2-5 for pigments, 0 for LMA
} else if (trait == "Car") {
  var_plot1 <- rf.pred.Car_ranger.df     # Predicted Car values
  meas_trait <- 2
  ylabel <- "Car [μg/cm\u00B2]"
  plot_filename1 <- "plots/pred_GCEF_Car_vertical_scatter_final.png"
  yranges_offset <- 2
} else if (trait == "LAI") {
  var_plot1 <- rf.pred.LAI_ranger.df     # Predicted LAI values
  meas_trait <- 3
  ylabel <- "LAI [m\u00B2/m\u00B2]"
  plot_filename1 <- "plots/pred_GCEF_LAI_vertical_scatter_final.png"
  yranges_offset <- 1
} else if (trait == "LMA") {
  var_plot1 <- rf.pred.LMA_ranger.df     # Predicted LMA values
  meas_trait <- 4
  ylabel <- "LMA [g/cm\u00B2]"
  plot_filename1 <- "plots/pred_GCEF_LMA_vertical_scatter_final.png"
  yranges_offset <- 0
} else if (trait == "LWC") {
  var_plot1 <- rf.pred.LWC_ranger.df     # Predicted LWC values
  meas_trait <- 5
  ylabel <- "LWC [g/cm\u00B2]"
  plot_filename1 <- "plots/pred_GCEF_LWC_ranger_final.png"
  yranges_offset <- 0
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set Plot Appearance Parameters
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

title_fs <- 2.8       # Title font size
axis_fs <- 2.0        # Axis font size
labels_fs <- 2.5      # Labels font size
main_fs <- 2.5        # Main text font size
header_fs <- 2.6      # Header font size

main_title <- trait   # Main title for the plots

# Initialize the plotting device with specified dimensions
png(plot_filename1, width = 1600, height = 1200)

# Set up the plotting area with 3 rows and 1 column
par(mfrow = c(3, 1), oma = c(2, 1, 3.5, 1), mar = c(3, 3, 3, 3) + 2.5)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Plotting for IGM Group
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Define index positions for IGM group in 'plots_list' and 'meas' data
p <- c(1, 10, 19, 28, 37, 46, 55, 64)

# Create a list of IGM groups with their names, reference measurements, and modeled predictions
igm_group <- list(
  group1 = list(
    name = plots_list[p[1]],
    reference = meas[meas_trait, p[1]],
    modeled = var_plot1[grep(plots_list_re[p[1]], rownames(var_plot1)), ]
  ),
  # There is no data for this day for IGM study site therefore group2 is left out
  group3 = list(
    name = plots_list[p[3]],
    reference = meas[meas_trait, p[3]],
    modeled = var_plot1[grep(plots_list_re[p[3]], rownames(var_plot1)), ]
  ),
  group4 = list(
    name = plots_list[p[4]],
    reference = meas[meas_trait, p[4]],
    modeled = var_plot1[grep(plots_list_re[p[4]], rownames(var_plot1)), ]
  ),
  group5 = list(
    name = plots_list[p[5]],
    reference = meas[meas_trait, p[5]],
    modeled = var_plot1[grep(plots_list_re[p[5]], rownames(var_plot1)), ]
  ),
  group6 = list(
    name = plots_list[p[6]],
    reference = meas[meas_trait, p[6]],
    modeled = var_plot1[grep(plots_list_re[p[6]], rownames(var_plot1)), ]
  ),
  group7 = list(
    name = plots_list[p[7]],
    reference = meas[meas_trait, p[7]],
    modeled = var_plot1[grep(plots_list_re[p[7]], rownames(var_plot1)), ]
  ),
  group8 = list(
    name = plots_list[p[8]],
    reference = meas[meas_trait, p[8]],
    modeled = var_plot1[grep(plots_list_re[p[8]], rownames(var_plot1)), ]
  )
)

# Calculate Y-axis range based on all values in the group
all_values <- unlist(lapply(igm_group, function(x) c(x$reference, x$modeled)))
y_min <- min(all_values)
y_max <- max(all_values)
y_range <- c(y_min - yranges_offset, y_max + yranges_offset)

# Initialize an empty plot for IGM group
plot(
  1, type = "n",
  xlim = c(0.5, length(igm_group) + 0.5),
  ylim = y_range,
  xaxt = 'n', ylab = ylabel, xlab = "",
  main = "IGM",
  cex = main_fs, cex.main = title_fs, cex.lab = labels_fs, cex.axis = axis_fs
)
# Add grid lines to the plot
grid(nx = NA, ny = NULL, col = "lightgray", lty = "dotted")

# Plot modeled predictions and reference measurements for each group
for (i in seq_along(igm_group)) {
  group <- igm_group[[i]]
  # Plot modeled predictions as black points
  points(rep(i, length(group$modeled)), group$modeled, col = "black", pch = 19, cex = main_fs)
  # Plot reference measurements as red points
  points(i, group$reference, col = "red", pch = 19, cex = main_fs + 1)
}

# Customize the X-axis with group names
axis(
  1, at = 1:length(igm_group),
  labels = sub("^([^-]*-){2}", "", sapply(igm_group, `[[`, "name")),
  cex.axis = axis_fs * 1.2
)

# Add a legend to the plot
legend(
  "topright",
  legend = c("Predicted", "Observation"),
  col = c("black", "red"),
  pch = 19, pt.cex = main_fs + 1, cex = axis_fs + 1
)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Plotting for EGG Group
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Define index positions for EGG group
p <- c(2, 11, 20, 29, 38, 47, 56, 65)

# Create a list of EGG groups
egg_group <- list(
  group1 = list(
    name = plots_list[p[1]],
    reference = meas[meas_trait, p[1]],
    modeled = var_plot1[grep(plots_list_re[p[1]], rownames(var_plot1)), ]
  ),
  group2 = list(
    name = plots_list[p[2]],
    reference = meas[meas_trait, p[2]],
    modeled = var_plot1[grep(plots_list_re[p[2]], rownames(var_plot1)), ]
  ),
  group3 = list(
    name = plots_list[p[3]],
    reference = meas[meas_trait, p[3]],
    modeled = var_plot1[grep(plots_list_re[p[3]], rownames(var_plot1)), ]
  ),
  group4 = list(
    name = plots_list[p[4]],
    reference = meas[meas_trait, p[4]],
    modeled = var_plot1[grep(plots_list_re[p[4]], rownames(var_plot1)), ]
  ),
  group5 = list(
    name = plots_list[p[5]],
    reference = meas[meas_trait, p[5]],
    modeled = var_plot1[grep(plots_list_re[p[5]], rownames(var_plot1)), ]
  ),
  group6 = list(
    name = plots_list[p[6]],
    reference = meas[meas_trait, p[6]],
    modeled = var_plot1[grep(plots_list_re[p[6]], rownames(var_plot1)), ]
  ),
  group7 = list(
    name = plots_list[p[7]],
    reference = meas[meas_trait, p[7]],
    modeled = var_plot1[grep(plots_list_re[p[7]], rownames(var_plot1)), ]
  ),
  group8 = list(
    name = plots_list[p[8]],
    reference = meas[meas_trait, p[8]],
    modeled = var_plot1[grep(plots_list_re[p[8]], rownames(var_plot1)), ]
  )
)

# Calculate Y-axis range
all_values <- unlist(lapply(egg_group, function(x) c(x$reference, x$modeled)))
y_min <- min(all_values)
y_max <- max(all_values)
y_range <- c(y_min - yranges_offset, y_max + yranges_offset)

# Initialize an empty plot for EGG group
plot(
  1, type = "n",
  xlim = c(0.5, length(egg_group) + 0.5),
  ylim = y_range,
  xaxt = 'n', ylab = ylabel, xlab = "",
  main = "EGG",
  cex = main_fs, cex.main = title_fs, cex.lab = labels_fs, cex.axis = axis_fs
)
# Add grid lines
grid(nx = NA, ny = NULL, col = "lightgray", lty = "dotted")

# Plot data points for EGG group
for (i in seq_along(egg_group)) {
  group <- egg_group[[i]]
  points(rep(i, length(group$modeled)), group$modeled, col = "black", pch = 19, cex = main_fs)
  points(i, group$reference, col = "red", pch = 19, cex = main_fs + 1)
}

# Customize X-axis labels
axis(
  1, at = 1:length(egg_group),
  labels = sub("^([^-]*-){2}", "", sapply(egg_group, `[[`, "name")),
  cex.axis = axis_fs * 1.2
)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Plotting for EGM Group
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Define index positions for EGM group
p <- c(3, 12, 21, 30, 39, 48, 57, 66)

# Create a list of EGM groups
egm_group <- list(
  group1 = list(
    name = plots_list[p[1]],
    reference = meas[meas_trait, p[1]],
    modeled = var_plot1[grep(plots_list_re[p[1]], rownames(var_plot1)), ]
  ),
  group2 = list(
    name = plots_list[p[2]],
    reference = meas[meas_trait, p[2]],
    modeled = var_plot1[grep(plots_list_re[p[2]], rownames(var_plot1)), ]
  ),
  group3 = list(
    name = plots_list[p[3]],
    reference = meas[meas_trait, p[3]],
    modeled = var_plot1[grep(plots_list_re[p[3]], rownames(var_plot1)), ]
  ),
  # There is no data for this day for EGM study site therefore group4 is left out
  group5 = list(
    name = plots_list[p[5]],
    reference = meas[meas_trait, p[5]],
    modeled = var_plot1[grep(plots_list_re[p[5]], rownames(var_plot1)), ]
  ),
  group6 = list(
    name = plots_list[p[6]],
    reference = meas[meas_trait, p[6]],
    modeled = var_plot1[grep(plots_list_re[p[6]], rownames(var_plot1)), ]
  ),
  group7 = list(
    name = plots_list[p[7]],
    reference = meas[meas_trait, p[7]],
    modeled = var_plot1[grep(plots_list_re[p[7]], rownames(var_plot1)), ]
  ),
  group8 = list(
    name = plots_list[p[8]],
    reference = meas[meas_trait, p[8]],
    modeled = var_plot1[grep(plots_list_re[p[8]], rownames(var_plot1)), ]
  )
)

# Calculate Y-axis range
all_values <- unlist(lapply(egm_group, function(x) c(x$reference, x$modeled)))
y_min <- min(all_values)
y_max <- max(all_values)
y_range <- c(y_min - yranges_offset, y_max + yranges_offset)

# Initialize an empty plot for EGM group
plot(
  1, type = "n",
  xlim = c(0.5, length(egm_group) + 0.5),
  ylim = y_range,
  xaxt = 'n', ylab = ylabel, xlab = "",
  main = "EGM",
  cex = main_fs, cex.main = title_fs, cex.lab = labels_fs, cex.axis = axis_fs
)
# Add grid lines
grid(nx = NA, ny = NULL, col = "lightgray", lty = "dotted")

# Plot data points for EGM group
for (i in seq_along(egm_group)) {
  group <- egm_group[[i]]
  points(rep(i, length(group$modeled)), group$modeled, col = "black", pch = 19, cex = main_fs)
  points(i, group$reference, col = "red", pch = 19, cex = main_fs + 1)
}

# Customize X-axis labels
axis(
  1, at = 1:length(egm_group),
  labels = sub("^([^-]*-){2}", "", sapply(egm_group, `[[`, "name")),
  cex.axis = axis_fs * 1.2
)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Finalize and Save the Plot
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Add the main title across all subplots
mtext(main_title, outer = TRUE, side = 3, line = 1, cex = header_fs)

# Close the plotting device and save the file
dev.off()

