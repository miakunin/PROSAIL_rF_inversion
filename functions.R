# functions.R
# Functions used in main.R

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Function: var_info
# Purpose:  Display variable information in a formatted manner
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

var_info <- function(x) {
	cat(crayon::bold(crayon::cyan(deparse(substitute(x)))), "features: \n")
	cat("is", class(x), "with \n")
	cat(nrow(x), "rows and \n")
	cat(ncol(x), "columns", "\n")
	cat("length is", length(x), "\n \n")
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Function: predict_var
# Purpose:  Make predictions using a random forest model and save the output
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

predict_var <- function(var_name, output_name, rf_var, pred_data, save_file) {
	pred <- predict(rf_var, data=pred_data)
	output_name <- data.frame(var_name = as.numeric(pred$prediction), row.names = spectra_names)
	save(output_name, file="save_file")
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Function: calculate_rmse
# Purpose:  Calculate the Root Mean Square Error between observed and predicted values
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

calculate_rmse <- function(observed, predicted) {
  # Calculate residuals
  residuals <- observed - predicted
  
  # Compute RMSE
  sqrt(mean(residuals^2))
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Lists: plots_list_re and plots_list
# Purpose:  Store regular expressions and names for specific plot patterns
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# List of regular expressions for matching plot names with dates
plots_list_re <- c("^igm.*05\\.04$", "^egg.*05\\.04$", "^egm.*05\\.04$", "^b1p02c.*05\\.04$", "^b2p09c.*05\\.04$", "^b3p19c.*05\\.04$", "^b1p04npk.*05\\.04$", "^b2p10npk.*05\\.04$", "^b3p23npk.*05\\.04$", 
								"^igm.*05\\.24$", "^egg.*05\\.24$", "^egm.*05\\.24$", "^b1p02c.*05\\.24$", "^b2p09c.*05\\.24$", "^b3p19c.*05\\.24$", "^b1p04npk.*05\\.24$", "^b2p10npk.*05\\.24$", "^b3p23npk.*05\\.24$", 
								"^igm.*06\\.07$", "^egg.*06\\.07$", "^egm.*06\\.07$", "^b1p02c.*06\\.07$", "^b2p09c.*06\\.07$", "^b3p19c.*06\\.07$", "^b1p04npk.*06\\.07$", "^b2p10npk.*06\\.07$", "^b3p23npk.*06\\.07$", 
								"^igm.*06\\.21$", "^egg.*06\\.21$", "^egm.*06\\.21$", "^b1p02c.*06\\.21$", "^b2p09c.*06\\.21$", "^b3p19c.*06\\.21$", "^b1p04npk.*06\\.21$", "^b2p10npk.*06\\.21$", "^b3p23npk.*06\\.21$", 
								"^igm.*07\\.06$", "^egg.*07\\.06$", "^egm.*07\\.06$", "^b1p02c.*07\\.06$", "^b2p09c.*07\\.06$", "^b3p19c.*07\\.06$", "^b1p04npk.*07\\.06$", "^b2p10npk.*07\\.06$", "^b3p23npk.*07\\.06$", 
								"^igm.*07\\.20$", "^egg.*07\\.20$", "^egm.*07\\.20$", "^b1p02c.*07\\.20$", "^b2p09c.*07\\.20$", "^b3p19c.*07\\.20$", "^b1p04npk.*07\\.20$", "^b2p10npk.*07\\.20$", "^b3p23npk.*07\\.20$", 
								"^igm.*09\\.20$", "^egg.*09\\.20$", "^egm.*09\\.20$", "^b1p02c.*09\\.20$", "^b2p09c.*09\\.20$", "^b3p19c.*09\\.20$", "^b1p04npk.*09\\.20$", "^b2p10npk.*09\\.20$", "^b3p23npk.*09\\.20$", 
								"^igm.*10\\.11$", "^egg.*10\\.11$", "^egm.*10\\.11$", "^b1p02c.*10\\.11$", "^b2p09c.*10\\.11$", "^b3p19c.*10\\.11$", "^b1p04npk.*10\\.11$", "^b2p10npk.*10\\.11$", "^b3p23npk.*10\\.11$")

# Corresponding list of plot names with dates
plots_list <- c("igm-1_5-2023-05-04", "egg-1_3-2023-05-04", "egm-1_1-2023-05-04", "b1p02c-2023-05-04", "b2p09c-2023-05-04", "b3p19c-2023-05-04", "b1p04npk-2023-05-04", "b2p10npk-2023-05-04", "b3p23npk-2023-05-04", 
								"igm-1_5-2023-05-24", "egg-1_3-2023-05-24", "egm-1_1-2023-05-24", "b1p02c-2023-05-24", "b2p09c-2023-05-24", "b3p19c-2023-05-24", "b1p04npk-2023-05-24", "b2p10npk-2023-05-24", "b3p23npk-2023-05-24",
								"igm-1_5-2023-06-07", "egg-1_3-2023-06-07", "egm-1_1-2023-06-07", "b1p02c-2023-06-07", "b2p09c-2023-06-07", "b3p19c-2023-06-07", "b1p04npk-2023-06-07", "b2p10npk-2023-06-07", "b3p23npk-2023-06-07",
								"igm-1_5-2023-06-21", "egg-1_3-2023-06-21", "egm-1_1-2023-06-21", "b1p02c-2023-06-21", "b2p09c-2023-06-21", "b3p19c-2023-06-21", "b1p04npk-2023-06-21", "b2p10npk-2023-06-21", "b3p23npk-2023-06-21",
								"igm-1_5-2023-07-06", "egg-1_3-2023-07-06", "egm-1_1-2023-07-06", "b1p02c-2023-07-06", "b2p09c-2023-07-06", "b3p19c-2023-07-06", "b1p04npk-2023-07-06", "b2p10npk-2023-07-06", "b3p23npk-2023-07-06",
								"igm-1_5-2023-07-20", "egg-1_3-2023-07-20", "egm-1_1-2023-07-20", "b1p02c-2023-07-20", "b2p09c-2023-07-20", "b3p19c-2023-07-20", "b1p04npk-2023-07-20", "b2p10npk-2023-07-20", "b3p23npk-2023-07-20",
								"igm-1_5-2023-09-20", "egg-1_3-2023-09-20", "egm-1_1-2023-09-20", "b1p02c-2023-09-20", "b2p09c-2023-09-20", "b3p19c-2023-09-20", "b1p04npk-2023-09-20", "b2p10npk-2023-09-20", "b3p23npk-2023-09-20",
								"igm-1_5-2023-10-11", "egg-1_3-2023-10-11", "egm-1_1-2023-10-11", "b1p02c-2023-10-11", "b2p09c-2023-10-11", "b3p19c-2023-10-11", "b1p04npk-2023-10-11", "b2p10npk-2023-10-11", "b3p23npk-2023-10-11") 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Vector: obs_dates
# Purpose:  Store patterns of observation dates for data selection
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

obs_dates <- c("05\\.04$", "05\\.24$", "06\\.07$", "*06\\.21$", "07\\.06$", "07\\.20$", "09\\.20$", "10\\.11$")


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Function: pick_data_date
# Purpose:  Select data rows that match a specific date pattern
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

pick_data_date <- function(date, data) {
	selected_rows <- grep(date, rownames(data), value = TRUE)
	new_data <- data[selected_rows, ]
	return(new_data)
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Function: do_pca
# Purpose:  Perform PCA on the data and project onto principal components
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

do_pca <- function(data) {
	n2 <- length(data)				# Number of variables (columns) in the data

	# Perform PCA with centering and scaling
	pca.observ <- prcomp(data, center=T, scale=T)  # prosail_spectra2 = spectra
	
	# Initialize an empty matrix to store PCA-transformed data
	pca.observ.train <- matrix(NA,dim(data)[1],n2) # empty matrix for rescaled spectra

  # 'pca.prosail' should be calculated earlier in the script
  # Assuming 'pca.prosail' contains scale and center attributes
  
  # Loop over each observation to project onto the principal components

  for (k in 1:nrow(data)) {
    # Scale the data using 'pca.prosail' parameters and multiply by PCA loadings
    scaled_data <- scale(data[k, 1:n2], scale = pca.prosail$scale, center = pca.prosail$center)
    
    # Project onto the first five principal components
    pca_projection <- scaled_data %*% pca.observ$rotation[, 1:5]
    
    # Store the projected data
    pca.observ.train[k, ] <- pca_projection
  }
  
  # Return the PCA-transformed data
  return(pca.observ.train)
}
