#!/usr/bin/env Rscript

# Load external functions required for the script
source("functions.R")          # Contains custom utility functions
source("functions_plots.R")    # Contains custom plotting functions
source("plot_parameters.R")    # Contains parameters for plotting

# Load necessary libraries quietly to avoid cluttering the output
suppressMessages(library(randomForest))  # For random forest modeling
suppressMessages(library(ggplot2))       # For creating plots
suppressMessages(library(patchwork))     # For combining multiple plots
suppressMessages(library(grid))          # For grid graphics
suppressMessages(library(Metrics))       # For statistical metrics like RMSE

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Define Input Files and Load Data
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Create a list of prediction files for different traits, using 'data_folder' variable

in_list <- c(
  paste0("RData/", data_folder, "/predictions_Cab.RData"),
  paste0("RData/", data_folder, "/predictions_Car.RData"),
  paste0("RData/", data_folder, "/predictions_LAI.RData"),
  paste0("RData/", data_folder, "/predictions_LMA.RData")
)

# Load prediction data from the specified files
for (f in in_list) {
  load(f)  # Loads variables like 'rf.pred.Cab.df', 'rf.pred.Car.df', etc.
}

# Load observed measurement data from CSV file, setting the first column as row names
meas <- read.csv("data/measurements_0504-1011_all.csv", row.names = 1)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set Plotting Parameters
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Define font sizes and plot appearance parameters
title_fs <- 20      # Title font size (e.g., for group names)
axis_fs <- 19       # Axis tick numbers font size
labels_fs <- 18     # Axis labels font size
annotate_fs <- 5    # Font size for annotations (e.g., RMSE, R²)
pch <- 19           # Point type - solid circle
cex <- 3.75         # Point size scale

# Initialize an empty list to store plots for each trait
plots <- list()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Loop Over Measured Traits and Generate Plots
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Loop over measurement traits: 1 = Cab, 2 = Car, 3 = LAI, 4 = LMA

for (meas_trait in c(1,2,3,4)) {
	if (meas_trait == 1) { 
		var_plot1 <- xgb.pred.Cab.df		# Predicted Cab values
		main_title <- "Cab"						# Main title for the plot
		plot_name <- paste0("plots/pred_Cab_rf_",plotname_affix1,"_",plotname_affix2,"_scatter_combined_final_aggr_ggplot2.png")
		x_text <- "Observed chlorophyll, \u03bcg/cm²"		# X-axis label
		y_text <- "Predicted chlorophyll, \u03bcg/cm² "	# Y-axis label
		round_prec <- 1				# Rounding precision for metrics
		group_label <- "(a)"	# Label for subplots
		cat(" \n")
		cat("Processing Cab\n")
		cat("Plot:    RMSE:    NRMSE:    R2:\n")
	} else if (meas_trait == 2) { 
		var_plot1 <- xgb.pred.Car.df
		main_title <- "Car" 
		plot_name <- paste0("plots/pred_Car_rf_",plotname_affix1,"_",plotname_affix2,"_scatter_combined_final_uni_ggplot2.png")
		x_text <- "Observed carotenoids, μg/cm²"# [μg/cm\u00B2]"
		y_text <- "Predicted carotenoids, μg/cm²"# [μg/cm\u00B2]"
		round_prec <- 1
		group_label <- "(b)"
		cat(" \n")
		cat("Processing Car\n")
		cat("Plot:    RMSE:    NRMSE:    R2:\n")
	} else if (meas_trait == 3) { 
		var_plot1 <- xgb.pred.LAI.df
		main_title <- "LAI" 
	  plot_name <- paste0("plots/pred_LAI_rf_",plotname_affix1,"_",plotname_affix2,"_scatter_combined_final_uni_ggplot2.png")
		x_text <- "Observed LAI, m\u00B2/m\u00B2"
		y_text <- "Predicted LAI, m\u00B2/m\u00B2"
		round_prec <- 2
		group_label <- "(c)"
		cat(" \n")
		cat("Processing LAI\n")
		cat("Plot:    RMSE:    NRMSE:    R2:\n")
	} else if (meas_trait == 4) { 
		var_plot1 <- xgb.pred.LMA.df
		main_title <- "LMA" 
	  plot_name <- paste0("plots/pred_LMA_rf_",plotname_affix1,"_",plotname_affix2,"_scatter_combined_final_uni_ggplot2.png")
		x_text <- "Observed LMA, g/cm\u00B2"
		y_text <- "Predicted LMA, g/cm\u00B2"
		round_prec <- 4
		group_label <- "(d)"
		cat(" \n")
		cat("Processing LMA\n")
		cat("Plot:    RMSE:    NRMSE:    R2:\n")
	}
 
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Prepare Data Groups for Plotting
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Define indices for IGM group
	p <- c(1,10,19,28,37,46,55,64) # Index sequence for IGM (those are the colimns in the input data file that contain the data)

	igm_group = list(
		group1 = list(name = plots_list[p[1]], reference = meas[meas_trait, p[1]], modeled = (var_plot1[grep(plots_list_re[p[1]], rownames(var_plot1)), ])),
	#	group2 = list(name = plots_list[p[2]], reference = meas[meas_trait, p[2]], modeled = (var_plot1[grep(plots_list_re[p[2]], rownames(var_plot1)), ])), # no data for that day so we skip it
		group3 = list(name = plots_list[p[3]], reference = meas[meas_trait, p[3]], modeled = (var_plot1[grep(plots_list_re[p[3]], rownames(var_plot1)), ])),
		group4 = list(name = plots_list[p[4]], reference = meas[meas_trait, p[4]], modeled = (var_plot1[grep(plots_list_re[p[4]], rownames(var_plot1)), ])),
		group5 = list(name = plots_list[p[5]], reference = meas[meas_trait, p[5]], modeled = (var_plot1[grep(plots_list_re[p[5]], rownames(var_plot1)), ])),
		group6 = list(name = plots_list[p[6]], reference = meas[meas_trait, p[6]], modeled = (var_plot1[grep(plots_list_re[p[6]], rownames(var_plot1)), ])),
		group7 = list(name = plots_list[p[7]], reference = meas[meas_trait, p[7]], modeled = (var_plot1[grep(plots_list_re[p[7]], rownames(var_plot1)), ])),
		group8 = list(name = plots_list[p[8]], reference = meas[meas_trait, p[8]], modeled = (var_plot1[grep(plots_list_re[p[8]], rownames(var_plot1)), ]))
		)

	p <- c(2,11,20,29,38,47,56,65,3,12,21,30,39,48,57,66) # Index sequence for EGM combined
	egm_group = list(
		group1 = list(name = plots_list[p[1]], reference = meas[meas_trait, p[1]], modeled = (var_plot1[grep(plots_list_re[p[1]], rownames(var_plot1)), ])),
		group2 = list(name = plots_list[p[2]], reference = meas[meas_trait, p[2]], modeled = (var_plot1[grep(plots_list_re[p[2]], rownames(var_plot1)), ])),
		group3 = list(name = plots_list[p[3]], reference = meas[meas_trait, p[3]], modeled = (var_plot1[grep(plots_list_re[p[3]], rownames(var_plot1)), ])),
		group4 = list(name = plots_list[p[4]], reference = meas[meas_trait, p[4]], modeled = (var_plot1[grep(plots_list_re[p[4]], rownames(var_plot1)), ])),
		group5 = list(name = plots_list[p[5]], reference = meas[meas_trait, p[5]], modeled = (var_plot1[grep(plots_list_re[p[5]], rownames(var_plot1)), ])),
		group6 = list(name = plots_list[p[6]], reference = meas[meas_trait, p[6]], modeled = (var_plot1[grep(plots_list_re[p[6]], rownames(var_plot1)), ])),
		group7 = list(name = plots_list[p[7]], reference = meas[meas_trait, p[7]], modeled = (var_plot1[grep(plots_list_re[p[7]], rownames(var_plot1)), ])),
		group8 = list(name = plots_list[p[8]], reference = meas[meas_trait, p[8]], modeled = (var_plot1[grep(plots_list_re[p[8]], rownames(var_plot1)), ])),
		group9 = list(name = plots_list[p[9]], reference = meas[meas_trait, p[9]], modeled = (var_plot1[grep(plots_list_re[p[9]], rownames(var_plot1)), ])),
		group10 = list(name = plots_list[p[10]], reference = meas[meas_trait, p[10]], modeled = (var_plot1[grep(plots_list_re[p[10]], rownames(var_plot1)), ])),
		group11 = list(name = plots_list[p[11]], reference = meas[meas_trait, p[11]], modeled = (var_plot1[grep(plots_list_re[p[11]], rownames(var_plot1)), ])),
	#	group12 = list(name = plots_list[p[12]], reference = meas[meas_trait, p[12]], modeled = (var_plot1[grep(plots_list_re[p[12]], rownames(var_plot1)), ])), # no data for that day so we skip it
		group13 = list(name = plots_list[p[13]], reference = meas[meas_trait, p[13]], modeled = (var_plot1[grep(plots_list_re[p[13]], rownames(var_plot1)), ])),
		group14 = list(name = plots_list[p[14]], reference = meas[meas_trait, p[14]], modeled = (var_plot1[grep(plots_list_re[p[14]], rownames(var_plot1)), ])),
		group15 = list(name = plots_list[p[15]], reference = meas[meas_trait, p[15]], modeled = (var_plot1[grep(plots_list_re[p[15]], rownames(var_plot1)), ])),
		group16 = list(name = plots_list[p[16]], reference = meas[meas_trait, p[16]], modeled = (var_plot1[grep(plots_list_re[p[16]], rownames(var_plot1)), ]))
		)

	#EGM_comb_group <- c(egg_group, egm_group)

  # Generate NutNet control and NPK groups using a custom function
  # 'plot_get_group_nutnet' is assumed to be defined in 'functions_plots.R'
  nutnet_c_group <- plot_get_group_nutnet(4, 5, 6, meas, var_plot1)
  nutnet_npk_group <- plot_get_group_nutnet(7, 8, 9, meas, var_plot1)
	
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Generate Plots for the Current Trait
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Generate plot for GCEF data (EGM and IGM groups)
  # 'plot_group_scat_uni_2sets_ggplot2_opt' is a custom plotting function
	plot1 <- plot_group_scat_uni_2sets_ggplot2_opt(egm_group, igm_group, "GCEF", "EGG+EGM", "IGM", group_label, x_text, y_text, title_fs, labels_fs, axis_fs, annotate_fs, round_prec)

  # Generate plot for NutNet data (control and NPK groups)
	plot2 <- plot_group_scat_uni_2sets_ggplot2_opt(nutnet_c_group, nutnet_npk_group, "NutNet", "Control", "NPK", "", x_text, y_text, title_fs, labels_fs, axis_fs, annotate_fs, round_prec)

	# Combine the two plots side by side, add title, and store in 'plots' list
	plots[[meas_trait]] <- (plot1|plot2) + plot_annotation(title = main_title)

	}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Combine All Plots into a Panel
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

plot_out <- wrap_plots(plots[[1]], plots[[2]], plots[[3]], plots[[4]], ncol = 2)

#warnings()

# Save the combined plot to a file with specified dimensions and resolution
ggsave(paste0("plots/panel_plot_final_", plotname_affix1, "_", plotname_affix2, ".png"), plot = plot_out, width = 24, height = 12, dpi = 400)

