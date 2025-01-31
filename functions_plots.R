# functions that are used for plotting

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Function: plot_group_only_one
# Purpose:  Plot data for a single group across multiple time points
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

plot_group_only_one <- function(index, var_plot1, meas, group_title) {

  # Create a list to store data for each time point
  # Each group corresponds to a time point, incrementing the index appropriately
	data_group = list(
		group1 = list(name = plots_list[index], reference = meas[meas_trait, index], modeled = (var_plot1[grep(plots_list_re[index], rownames(var_plot1)), ])),
		group2 = list(name = plots_list[index+9], reference = meas[meas_trait, index+9], modeled = (var_plot1[grep(plots_list_re[index+9], rownames(var_plot1)), ])),
		group3 = list(name = plots_list[index+18], reference = meas[meas_trait, index+18], modeled = (var_plot1[grep(plots_list_re[index+18], rownames(var_plot1)), ])),
		group4 = list(name = plots_list[index+27], reference = meas[meas_trait, index+27], modeled = (var_plot1[grep(plots_list_re[index+27], rownames(var_plot1)), ])),
		group5 = list(name = plots_list[index+36], reference = meas[meas_trait, index+36], modeled = (var_plot1[grep(plots_list_re[index+36], rownames(var_plot1)), ])),
		group6 = list(name = plots_list[index+45], reference = meas[meas_trait, index+45], modeled = (var_plot1[grep(plots_list_re[index+45], rownames(var_plot1)), ])),
		group7 = list(name = plots_list[index+54], reference = meas[meas_trait, index+54], modeled = (var_plot1[grep(plots_list_re[index+54], rownames(var_plot1)), ])),
		group8 = list(name = plots_list[index+63], reference = meas[meas_trait, index+63], modeled = (var_plot1[grep(plots_list_re[index+63], rownames(var_plot1)), ]))
	)
  # Extract all reference and modeled values, handling "N/A" entries
	all_values <- unlist(lapply(data_group, function(x) c(x$reference, x$modeled)))
	all_values[all_values == "N/A"] <- NA	# Replace "N/A" with NA
	all_values <- as.numeric(all_values)	# Convert to numeric

  # Determine y-axis limits for plotting
	y_min <- min(all_values, na.rm = TRUE)
	y_max <- max(all_values, na.rm = TRUE)
	if ((y_min-yranges_offset) < 0) { y_min <- yranges_offset }
	y_range <- c(y_min - yranges_offset, y_max + yranges_offset)
	#y_range <- c(0, 70)

  # Initialize an empty plot with specified parameters
	plot(1, type = "n", xlim = c(0.5, length(data_group) + 0.5), cex = main_fs, cex.main = title_fs, cex.lab = labels_fs, cex.axis = axis_fs, ylim = y_range, xaxt = 'n', ylab = ylabel, xlab = "", main = group_title)
  # Add grid lines to the plot
	grid(nx = NA, ny = NULL, col = "lightgray", lty = "dotted")

  # Plot modeled and reference values for each group
	for (i in seq_along(data_group)) {
  	group <- data_group[[i]]
  	points(rep(i, length(group$modeled)), group$modeled, col = "black", pch = 19, cex = main_fs)
    # Plot reference value as red point
  	points(i, group$reference, col = "red", pch = 19, cex = main_fs)
	}

  # Customize the x-axis with group names
	axis(1, at = 1:length(data_group), labels = sub("^[^-]*-", "", sapply(data_group, `[[`, "name")), cex.axis = axis_fs*1.2)

  # Return a message indicating the group has been plotted
	return(cat(group_title,"plotted \n"))
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Function: plot_get_group_nutnet
# Purpose:  Retrieve data for NutNet groups over multiple time points
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

plot_get_group_nutnet <- function(indexa, indexb, indexc, meas, var_plot1) {

  # Define data for the first group (indexa) across different dates
	data_group_a = list(
		may04 = list(name = plots_list[indexa], reference = meas[meas_trait, indexa], modeled = (var_plot1[grep(plots_list_re[indexa], rownames(var_plot1)), ])),
		may24 = list(name = plots_list[indexa+9], reference = meas[meas_trait, indexa+9], modeled = (var_plot1[grep(plots_list_re[indexa+9], rownames(var_plot1)), ])),
		jun07 = list(name = plots_list[indexa+18], reference = meas[meas_trait, indexa+18], modeled = (var_plot1[grep(plots_list_re[indexa+18], rownames(var_plot1)), ])),
		jun21 = list(name = plots_list[indexa+27], reference = meas[meas_trait, indexa+27], modeled = (var_plot1[grep(plots_list_re[indexa+27], rownames(var_plot1)), ])),
		jul06 = list(name = plots_list[indexa+36], reference = meas[meas_trait, indexa+36], modeled = (var_plot1[grep(plots_list_re[indexa+36], rownames(var_plot1)), ])),
		jul20 = list(name = plots_list[indexa+45], reference = meas[meas_trait, indexa+45], modeled = (var_plot1[grep(plots_list_re[indexa+45], rownames(var_plot1)), ])),
		sep20 = list(name = plots_list[indexa+54], reference = meas[meas_trait, indexa+54], modeled = (var_plot1[grep(plots_list_re[indexa+54], rownames(var_plot1)), ])),
		oct11 = list(name = plots_list[indexa+63], reference = meas[meas_trait, indexa+63], modeled = (var_plot1[grep(plots_list_re[indexa+63], rownames(var_plot1)), ]))
		)

  # Repeat the same for the second group (indexb)
	data_group_b = list(
		may04 = list(name = plots_list[indexb], reference = meas[meas_trait, indexb], modeled = (var_plot1[grep(plots_list_re[indexb], rownames(var_plot1)), ])),
		may24 = list(name = plots_list[indexb+9], reference = meas[meas_trait, indexb+9], modeled = (var_plot1[grep(plots_list_re[indexb+9], rownames(var_plot1)), ])),
		jun07 = list(name = plots_list[indexb+18], reference = meas[meas_trait, indexb+18], modeled = (var_plot1[grep(plots_list_re[indexb+18], rownames(var_plot1)), ])),
		jun21 = list(name = plots_list[indexb+27], reference = meas[meas_trait, indexb+27], modeled = (var_plot1[grep(plots_list_re[indexb+27], rownames(var_plot1)), ])),
		jul06 = list(name = plots_list[indexb+36], reference = meas[meas_trait, indexb+36], modeled = (var_plot1[grep(plots_list_re[indexb+36], rownames(var_plot1)), ])),
		jul20 = list(name = plots_list[indexb+45], reference = meas[meas_trait, indexb+45], modeled = (var_plot1[grep(plots_list_re[indexb+45], rownames(var_plot1)), ])),
		sep20 = list(name = plots_list[indexb+54], reference = meas[meas_trait, indexb+54], modeled = (var_plot1[grep(plots_list_re[indexb+54], rownames(var_plot1)), ])),
		oct11 = list(name = plots_list[indexb+63], reference = meas[meas_trait, indexb+63], modeled = (var_plot1[grep(plots_list_re[indexb+63], rownames(var_plot1)), ]))
		)

  # Repeat for the third group (indexc)
	data_group_c = list(
		may04 = list(name = plots_list[indexc], reference = meas[meas_trait, indexc], modeled = (var_plot1[grep(plots_list_re[indexc], rownames(var_plot1)), ])),
		may24 = list(name = plots_list[indexc+9], reference = meas[meas_trait, indexc+9], modeled = (var_plot1[grep(plots_list_re[indexc+9], rownames(var_plot1)), ])),
		jun07 = list(name = plots_list[indexc+18], reference = meas[meas_trait, indexc+18], modeled = (var_plot1[grep(plots_list_re[indexc+18], rownames(var_plot1)), ])),
		jun21 = list(name = plots_list[indexc+27], reference = meas[meas_trait, indexc+27], modeled = (var_plot1[grep(plots_list_re[indexc+27], rownames(var_plot1)), ])),
		jul06 = list(name = plots_list[indexc+36], reference = meas[meas_trait, indexc+36], modeled = (var_plot1[grep(plots_list_re[indexc+36], rownames(var_plot1)), ])),
		jul20 = list(name = plots_list[indexc+45], reference = meas[meas_trait, indexc+45], modeled = (var_plot1[grep(plots_list_re[indexc+45], rownames(var_plot1)), ])),
		sep20 = list(name = plots_list[indexc+54], reference = meas[meas_trait, indexc+54], modeled = (var_plot1[grep(plots_list_re[indexc+54], rownames(var_plot1)), ])),
		oct11 = list(name = plots_list[indexc+63], reference = meas[meas_trait, indexc+63], modeled = (var_plot1[grep(plots_list_re[indexc+63], rownames(var_plot1)), ]))
		)

  # Combine all three groups into a single list
	data_group <- c(data_group_a, data_group_b, data_group_c)

  # Return the combined data group
	return(data_group)
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Function: plot_group_scat_uni_2sets_ggplot2_opt
# Purpose:  Generate a scatter plot comparing two data sets using ggplot2
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

plot_group_scat_uni_2sets_ggplot2_opt <- function(grp1, grp2, grp_title, title_g1, title_g2, group_label, x_text, y_text, title_fs, labels_fs, axis_fs, annotate_fs, round_prec) {
  # Helper function to process group data
  process_group <- function(group) {
    modeled_data <- as.numeric(ifelse(group$modeled == "N/A", NA, group$modeled)) # Convert modeled data to numeric, handling "N/A" entries
    clean_modeled <- modeled_data[!is.na(modeled_data)]
    averaged_modeled <- mean(clean_modeled, na.rm = TRUE)   # Calculate the average of modeled data
    reference <- as.numeric(ifelse(group$reference == "N/A", NA, group$reference))  # Get reference value
    return(c(averaged_modeled, reference))
  }
  
  # Process data for both groups
  processed1 <- t(sapply(grp1, process_group))
  processed2 <- t(sapply(grp2, process_group))
  
  # Extract averaged modeled values and references
  averaged_modeled1 <- processed1[, 1]
  references1 <- processed1[, 2]
  averaged_modeled2 <- processed2[, 1]
  references2 <- processed2[, 2]
  
  # Determine common range for plotting
  common_range <- range(c(references1, references2, averaged_modeled1, averaged_modeled2), na.rm = TRUE)
  common_range <- c(common_range[1] * 0.9, common_range[2] * 1.2)
  
  # Create data frames for ggplot
  df1 <- data.frame(references = references1, averaged_modeled = averaged_modeled1, source = title_g1)
  df2 <- data.frame(references = references2, averaged_modeled = averaged_modeled2, source = title_g2)
  
  # Remove rows with NaN values in references or averaged_modeled
  df1 <- df1[complete.cases(df1), ]
  df2 <- df2[complete.cases(df2), ]

  # Calculate linear models and statistics
  summary_lm1 <- summary(lm(averaged_modeled1 ~ references1))
  summary_lm2 <- summary(lm(averaged_modeled2 ~ references2))

  # Calculate RMSE and NRMSE
  rmse_value1 <- rmse(references1, averaged_modeled1)
  rmse_value2 <- rmse(references2, averaged_modeled2)

  range1 <- max(references1, na.rm = TRUE) - min(references1, na.rm = TRUE)
  range2 <- max(references2, na.rm = TRUE) - min(references2, na.rm = TRUE)

  nrmse_value1 <- rmse_value1 / range1
  nrmse_value2 <- rmse_value2 / range2

	# Remove NA values from both datasets simultaneously
	valid_indices1 <- complete.cases(references1, averaged_modeled1)
	valid_indices2 <- complete.cases(references2, averaged_modeled2)

  # Output statistics to console
  cat(title_g1, rmse_value1, nrmse_value1, summary_lm1$r.squared, "\n")
  cat(title_g2, rmse_value2, nrmse_value2, summary_lm2$r.squared, "\n")
 
  # Update x_text and y_text with Unicode escape sequences
  x_text <- gsub("μ", "\u03bc", x_text)
  y_text <- gsub("μ", "\u03bc", y_text)
  
  # Combine data frames
  combined_df <- rbind(df1, df2)
  # Combine titles for the plot
	combo_title <- paste0(main_title, "       ", grp_title)
 
  # Create the ggplot2 object
  p <- ggplot() +
    # Plot data points for both groups
    geom_point(data = df1, aes(x = references, y = averaged_modeled, color = source), size = cex) +
    geom_point(data = df2, aes(x = references, y = averaged_modeled, color = source), size = cex) +
    # Add 1:1 line
    geom_segment(aes(x = common_range[1] * 1.1, y = common_range[1] * 1.1, xend = common_range[2] * 0.9, yend = common_range[2] * 0.9), 
                 color = "black", linetype = "dashed", linewidth = 1.2) +  # 1:1 line with limits
    # Add lines of best fit for both groups
    geom_smooth(data = df1, method = "lm", aes(x = references, y = averaged_modeled), color = "darkgreen", linewidth = 1.2, se = FALSE) +  # Line of best fit for df1
    geom_smooth(data = df2, method = "lm", aes(x = references, y = averaged_modeled), color = "blue", linewidth = 1.2, se = FALSE) +  # Line of best fit for df2
    # Set labels and titles
    labs(title = combo_title, x = x_text, y = y_text, color = "") +
    # Set coordinate ranges
    coord_cartesian(xlim = common_range, ylim = common_range) +  # Set x and y ranges
    # Customize colors
    scale_color_manual(values = setNames(c("darkgreen", "blue"), c(title_g1, title_g2))) +
    guides(color = guide_legend(title = NULL)) +
    # Set theme
    theme_classic() +
    theme(
      plot.title = element_text(size = title_fs, face = "bold", hjust = 0.5),
#			plot.subtitle = element_text(size = title_fs * 0.8, hjust = 0.5, margin = margin(b = 10)),  # Style for the second title
      axis.title.x = element_text(size = labels_fs, margin = margin(t = 10)),
      axis.title.y = element_text(size = labels_fs, margin = margin(r = 10)),
      axis.text.x = element_text(size = axis_fs),
      axis.text.y = element_text(size = axis_fs),
      plot.margin = margin(1, 1, 1, 1, "cm"),  # Adjust the margins as needed
      panel.grid.major = element_line(color = "gray", linewidth = 0.4), # Add major grid lines
      panel.grid.minor = element_line(color = "gray", linewidth = 0.2),  # Add minor grid lines
      legend.position = c(0.985, 0.9999),  # Position legend inside plot, upper right corner
			legend.text = element_text(size=18),
      legend.justification = c("right", "top")  # Adjust justification to align to upper right
    ) 
  # Return the ggplot object  
	return(p)
}

