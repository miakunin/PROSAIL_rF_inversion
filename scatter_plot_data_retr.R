#!/usr/bin/env Rscript

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script: scatter_plot_data_retr.R
# Purpose: Extracts absolute residuals between modeled and reference data for
#          different groups and saves them to CSV files.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Load external functions required for data processing and plotting
source("functions.R")
source("functions_plots.R")

# Suppress messages from loading libraries to keep the console output clean
suppressMessages(library(randomForest))  # For random forest modeling

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Define Input Data and Parameters
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Define the folder containing prediction data
folder <- "0710_PCA_ranger_large"
folder <- "0407"  # Uncomment this line to override the previous folder

# Create a list of file paths to prediction data for different traits
in_list <- c(
  paste0("RData/", folder, "/predictions_Cab.RData"),
  paste0("RData/", folder, "/predictions_Car.RData"),
  paste0("RData/", folder, "/predictions_LAI.RData"),
  paste0("RData/", folder, "/predictions_LMA.RData")
)

# Load measurement data from CSV file, setting the first column as row names
meas <- read.csv("data/measurements_0504-1011_all.csv", row.names = 1)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Load Prediction Data
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Loop through the list of prediction files and load each one
for (f in in_list) {
  load(f)  # Loads variables like 'rf.pred.Cab.df', 'rf.pred.Car.df', etc.
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Select Trait for Analysis
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Select the variable for analysis (e.g., LMA)
var1 <- rf.pred.LMA.df     # Predicted LMA values
meas_trait <- 4            # Column index for LMA in 'meas' data (1: Cab, 2: Car, 3: LAI, 4: LMA)
varname <- "LMA"           # Name of the trait for labeling and file naming

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Prepare Data Groups for Different Experiments
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Define indices for IGM group in 'plots_list' and 'meas' data
p <- c(1, 10, 19, 28, 37, 46, 55, 64)  # Index sequence for IGM

# Create IGM group data over different dates
igm_group = list(
  may04 = list(
    name = plots_list[p[1]],
    reference = meas[meas_trait, p[1]],
    modeled = var1[grep(plots_list_re[p[1]], rownames(var1)), ]
  ),
  # may24 is commented out
  jun07 = list(
    name = plots_list[p[3]],
    reference = meas[meas_trait, p[3]],
    modeled = var1[grep(plots_list_re[p[3]], rownames(var1)), ]
  ),
  jun21 = list(
    name = plots_list[p[4]],
    reference = meas[meas_trait, p[4]],
    modeled = var1[grep(plots_list_re[p[4]], rownames(var1)), ]
  ),
  jul06 = list(
    name = plots_list[p[5]],
    reference = meas[meas_trait, p[5]],
    modeled = var1[grep(plots_list_re[p[5]], rownames(var1)), ]
  ),
  jul20 = list(
    name = plots_list[p[6]],
    reference = meas[meas_trait, p[6]],
    modeled = var1[grep(plots_list_re[p[6]], rownames(var1)), ]
  ),
  sep20 = list(
    name = plots_list[p[7]],
    reference = meas[meas_trait, p[7]],
    modeled = var1[grep(plots_list_re[p[7]], rownames(var1)), ]
  ),
  oct11 = list(
    name = plots_list[p[8]],
    reference = meas[meas_trait, p[8]],
    modeled = var1[grep(plots_list_re[p[8]], rownames(var1)), ]
  )
)

# Define indices for EGG group
p <- c(2, 11, 20, 29, 38, 47, 56, 65)  # Index sequence for EGG

# Create EGG group data over different dates
egg_group = list(
  may04 = list(
    name = plots_list[p[1]],
    reference = meas[meas_trait, p[1]],
    modeled = var1[grep(plots_list_re[p[1]], rownames(var1)), ]
  ),
  may24 = list(
    name = plots_list[p[2]],
    reference = meas[meas_trait, p[2]],
    modeled = var1[grep(plots_list_re[p[2]], rownames(var1)), ]
  ),
  jun07 = list(
    name = plots_list[p[3]],
    reference = meas[meas_trait, p[3]],
    modeled = var1[grep(plots_list_re[p[3]], rownames(var1)), ]
  ),
  jun21 = list(
    name = plots_list[p[4]],
    reference = meas[meas_trait, p[4]],
    modeled = var1[grep(plots_list_re[p[4]], rownames(var1)), ]
  ),
  jul06 = list(
    name = plots_list[p[5]],
    reference = meas[meas_trait, p[5]],
    modeled = var1[grep(plots_list_re[p[5]], rownames(var1)), ]
  ),
  jul20 = list(
    name = plots_list[p[6]],
    reference = meas[meas_trait, p[6]],
    modeled = var1[grep(plots_list_re[p[6]], rownames(var1)), ]
  ),
  sep20 = list(
    name = plots_list[p[7]],
    reference = meas[meas_trait, p[7]],
    modeled = var1[grep(plots_list_re[p[7]], rownames(var1)), ]
  ),
  oct11 = list(
    name = plots_list[p[8]],
    reference = meas[meas_trait, p[8]],
    modeled = var1[grep(plots_list_re[p[8]], rownames(var1)), ]
  )
)

# Define indices for EGM group
p <- c(3, 12, 21, 30, 39, 48, 57, 66)  # Index sequence for EGM

# Create EGM group data over different dates
egm_group = list(
  may04 = list(
    name = plots_list[p[1]],
    reference = meas[meas_trait, p[1]],
    modeled = var1[grep(plots_list_re[p[1]], rownames(var1)), ]
  ),
  may24 = list(
    name = plots_list[p[2]],
    reference = meas[meas_trait, p[2]],
    modeled = var1[grep(plots_list_re[p[2]], rownames(var1)), ]
  ),
  jun07 = list(
    name = plots_list[p[3]],
    reference = meas[meas_trait, p[3]],
    modeled = var1[grep(plots_list_re[p[3]], rownames(var1)), ]
  ),
  # jun21 is commented out
  jul06 = list(
    name = plots_list[p[5]],
    reference = meas[meas_trait, p[5]],
    modeled = var1[grep(plots_list_re[p[5]], rownames(var1)), ]
  ),
  jul20 = list(
    name = plots_list[p[6]],
    reference = meas[meas_trait, p[6]],
    modeled = var1[grep(plots_list_re[p[6]], rownames(var1)), ]
  ),
  sep20 = list(
    name = plots_list[p[7]],
    reference = meas[meas_trait, p[7]],
    modeled = var1[grep(plots_list_re[p[7]], rownames(var1)), ]
  ),
  oct11 = list(
    name = plots_list[p[8]],
    reference = meas[meas_trait, p[8]],
    modeled = var1[grep(plots_list_re[p[8]], rownames(var1)), ]
  )
)

# Retrieve NutNet control and NPK groups using custom function
# 'plot_get_group_nutnet' is assumed to be defined in 'functions_plots.R'
nutnet_c_group <- plot_get_group_nutnet(4, 5, 6, meas, var1)
nutnet_npk_group <- plot_get_group_nutnet(7, 8, 9, meas, var1)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Define Function to Process Groups and Calculate Residuals
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Function to process group data and calculate absolute residuals
process_group <- function(group) {
  # Convert modeled data to numeric, handling "N/A" entries
  modeled_data <- as.numeric(ifelse(group$modeled == "N/A", NA, group$modeled))
  clean_modeled <- modeled_data[!is.na(modeled_data)]
  # Calculate the average of modeled data
  averaged_modeled <- mean(clean_modeled, na.rm = TRUE)
  # Get reference value
  reference <- as.numeric(ifelse(group$reference == "N/A", NA, group$reference))
  # Calculate absolute difference between modeled and reference
  absolute_difference <- abs(averaged_modeled - reference)
  # Return as a data frame
  return(data.frame(
    Averaged_Modeled = averaged_modeled,
    Reference = reference,
    Absolute_residuals = absolute_difference
  ))
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Process Groups and Calculate Residuals
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apply 'process_group' function to each group and combine results into data frames
igm_group_df <- do.call(rbind, lapply(igm_group, process_group))
egm_group_df <- do.call(rbind, lapply(egm_group, process_group))
egg_group_df <- do.call(rbind, lapply(egg_group, process_group))
nutnet_c_group_df <- do.call(rbind, lapply(nutnet_c_group, process_group))
nutnet_npk_group_df <- do.call(rbind, lapply(nutnet_npk_group, process_group))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Output and Save Results
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display variable information and print the data frame for one group
var_info(nutnet_npk_group_df)
print(nutnet_npk_group_df)

# Write the absolute residuals to CSV files for each group
write.csv(
  igm_group_df$Absolute_residuals,
  paste0("data/igm_group_", varname, "_", folder, ".csv"),
  row.names = FALSE
)
write.csv(
  egm_group_df$Absolute_residuals,
  paste0("data/egm_group_", varname, "_", folder, ".csv"),
  row.names = FALSE
)
write.csv(
  egg_group_df$Absolute_residuals,
  paste0("data/egg_group_", varname, "_", folder, ".csv"),
  row.names = FALSE
)
write.csv(
  nutnet_c_group_df$Absolute_residuals,
  paste0("data/nutnet_c_group_", varname, "_", folder, ".csv"),
  row.names = FALSE
)
write.csv(
  nutnet_npk_group_df$Absolute_residuals,
  paste0("data/nutnet_npk_group_", varname, "_", folder, ".csv"),
  row.names = FALSE
)

