# PROSAIL_R_flexpool


## Overview

This project involves simulating and processing hyperspectral data using the PROSAIL canopy reflectance model, identifying and removing noisy spectra, applying spline smoothing, and predicting selected plant functional traits: chlorophyll content (Cab) / carotenoids content (Car) / LAI / LMA using random forest models. The scripts provided facilitate data preprocessing, modeling, and prediction tasks essential for analyzing hyperspectral datasets. Also, tools for the model outputs visualization are provided.

## Repository Structure

### Scripts

- `main.R` Main script that performs PROSAIL simulations, data preprocessing, noise removal, spline smoothing, and prepares data for modeling.

- `functions.R` Contains utility functions used across scripts for variable information display, prediction, RMSE calculation, data selection by date, and PCA transformation.

- `functions_plots.R` Contains utility functions for plotting scripts.

- `pred_Cab.R`/`pred_Car.R`/`pred_LAI.R`/`pred_LMA.R` Script that trains a random forest model to predict Cab (chlorophyll content) / Car (carotenoids content) / LAI / LMA and makes predictions on test data.

- `main_PCA.R` Is very similar to the `main.R` but contains a block to apply PCA to the data.

- `main_ranger.R` Is a similar to the `main.R` script but focused on the *ranger* sunction usage instead of the *randomForest*. The *ranger* library is a parallel realization of the *randomForest* that allows to utilize multiple processors for the model training. Therefore, this process requires a lot (**A LOT**) less time. The script has the similar logic as the `main.R`. Look into the `main.R` for the comments.

- `parameter_list.R` is a constructor for the PROSAIL input variable *parameter_list*.

- `plot_prediction_GCEF.R` Generates "vertical" scatter plots comparing observed and predicted trait values for the GCEF study sites.

- `plot_prediction_NutNet.R` Generates "vertical" scatter plots comparing observed and predicted trait values for the GCEF study sites.

- `plot_scatter_combined_all_aggr.R` Generates all scatter plots comparing observed and predicted trait values. This is the script that generated plots for the manuscript.

- `spectra_quantiles.R` Generates mean and quantile plot of the observed and simulated spectra.

- `scatter_plot_data_retr.R` Extracts the data for the plots: creates *.csv* files for NutNet NPK, Control, GCEF IGM, EGM, EGG study sites for each trait with observed and predicted values.

- `plt/green_residuals.plt` Generates a big panel plot with scatter plots of green area percentage vs model prediction errors. GNUPLOT code.

- `plt/green_residuals.py` The same as above. Python code. The final version that was used to generate plot for the manuscript.

### Directories

- `data/` Directory containing input data files such as observed reflectances and soil spectra.

- `RData/` Directory where processed data and model outputs are saved. This directory is not synced with the GitLab because it contains heavy binaries. Please, create it before use the scripts.

- `plt/` Directory for auxillary plotting scripts (not in R).

- `plots/` Directory where generated plots are saved.


## Dependencies

The scripts require the following R packages:

- `hsdar`: For handling hyperspectral data.

- `randomForest`: For building random forest models.

- `crayon`: For colored console output.

- `prosail`: For PROSAIL canopy reflectance modeling.

- `tidyverse`: For data manipulation and visualization.

- `smooth`: For smoothing functions.

- `ggplot2` For plots.

- `patchwork` For combining multiple plots.

- `grid` For grid-based graphics.

- `Metrics` For calculating statistical metrics like RMSE and R-squared.

Install the packages using:

`install.packages(c("randomForest", "crayon", "prosail", "tidyverse", "smooth", "ggplot2", "patchwork", "grid", "Metrics"))`

Unfortunately, *hsdar* package is no longer available in the official R repo.

Make sure that  *Rscript* can be found in this path: `/usr/bin/env`. Otherwise, update the shebang in the scripts!


## Data Preparation

Ensure the following data files are available in the data/ directory:

- `BL.dry_spec.RData`: Soil spectrum data required for PROSAIL simulations.
- `reflectances_obs_0504-1011_all.csv`: Observed reflectance data (with wavelengths 350-399 nm already removed).
- `measurements_0504-1011_all.csv`: Contains observed measurements for traits like *Cab*, *Car*, *LAI*, and *LMA*.

## Scripts and Usage

### `parameter_list.R`

**Purpose:** Creates a PROSAIL input variable - *parameter_list*. Change the ranges of the input variable to your taste. To check the size of the input variable the script can be used in standalone mode.

**Usage:**

Run the script from the command line:

	./parameter_list.R


### `main.R`

**Purpose:** Performs PROSAIL simulations, processes observed data, identifies and removes noisy spectra, applies spline smoothing, and prepares data for modeling.

**Usage:**

Run the script from the command line:

	./main.R [your_working_directory]

**Key Steps:**

- PROSAIL Simulation:

	- Checks if a previous simulation exists; if not, performs a new simulation using parameter_list and saves the results.

- Data Reading and Preprocessing:
	- Reads observed reflectance data and wavelengths.
	- Defines spectral ranges to exclude specific wavelengths.
	- Removes specified ranges from both PROSAIL spectra and observed data.

- Noise Identification:
	- Identifies spectra with values outside the [0, 1] range.
	- Removes noisy spectra from the dataset.

- Spline Smoothing:
	- Applies smoothing splines to the observed data to reduce noise.

- Data Preparation:
	- Aligns column names between observed and simulated data.
	- Prepares data structures for modeling.

- Saving Processed Data:
	- Saves the processed data to `RData/$your_working_directory/PROSAIL_done_RF_ready.RData`.

### `functions.R`

**Purpose:** Provides utility functions used in data processing and modeling.

**Functions:**

- `var_info(x)`: 
Displays information about variable x.


Thre rest of the functions are not used in the script.

### `pred_Cab.R`

**Purpose:** Trains a random forest model to predict chlorophyll content (Cab), or Car/LAI/LMA and makes predictions on test data.

**Usage:**

Run the script from the command line, optionally specifying a data directory:

	./pred_Cab.R [data_directory]

**Key Steps:**

- Loading Data:
	- Loads preprocessed data from PROSAIL_done_RF_ready.RData.

- Model Training:
	- Trains a random forest model (rf_Cab/rf_Car/rf_LMA/rf_LAI) using the training data.

- Prediction:
	- Uses the trained model to predict Cab/Car/LAI/LMA values on test data.

- Saving Results:
	- Saves the trained model and predictions to the specified data directory.

### `plot_prediction_GCEF.R`

**Purpose:** Generates plots comparing observed and predicted trait values for the GCEF experiment.

**Usage:**

    ./plot_prediction_GCEF.R [trait]

Replace [trait] with *Cab*, *Car*, *LAI*, or *LMA*.

If no trait is specified, it defaults to *Cab*.

**Key Steps:**

- Loading Data:
    - Loads prediction data and measurement data.
- Trait Selection:
    - Determines which trait to plot based on the command-line argument.
- Plot Configuration:
    - Sets up font sizes and plot appearance parameters.
- Data Grouping:
    - Organizes data into groups (IGM, EGG, EGM) for plotting.
- Plotting:
    - Generates plots for each group, comparing observed and predicted values.
- Saving Plots:
    - Saves the plots to the plots/ directory with appropriate filenames.

### `plot_prediction_NutNet.R`

**Purpose:** Generates plots comparing observed and predicted trait values for the NutNet experiment. It works similar to `plot_prediction_GCEF.R`.


### `plot_scatter_combined_all_aggr.R`

**Purpose:** Generates a panel plot of the scatter plots for all the data.

**Usage:** 

    ./plot_scatter_combined_all_aggr.R

**Key Steps:**

- Loading Data:
    - Loads prediction data and measurement data.
- Plot Configuration:
    - Sets up font sizes and plot appearance parameters.
- Data Grouping:
    - Organizes data into groups (IGM, EGG+EGM, NutNet Control, NutNet NPK) for plotting.
- Plotting:
    - Generates scatter plots for each group, comparing observed and predicted values.
- Saving Plots:
    - Saves the plots to the plots/ directory with appropriate filenames.

### `plot_parameters.R`

**Purpose:** Contains strings variables that are used by the `plot_scatter_combined_all_aggr` to set working directory and plot names. If you need to make adjustments, e.g. make a plot with different name of from other data source, this is the place where you should set it.

### `functions_plots.R`

**Purpose:** Contains custom functions used for plotting data in the corresponding scripts.

**Functions:**

- `plot_group_only_one(index, var_plot1, meas, group_title)`:
    - Plots data for a single group across multiple time points.

- `plot_get_group_nutnet(indexa, indexb, indexc, meas, var_plot1)`:

    - Retrieves and prepares data for NutNet groups over multiple time points.

- `plot_group_scat_uni_2sets_ggplot2_opt(grp1, grp2, ...)`:

    - Generates a scatter plot comparing two data sets using ggplot2.

**Usage:**

These functions are called within the plotting scripts to generate consistent and customized plots.


### `scatter_plot_data_retr.R`

**Purpose:** Generates .csv files with observation and predicted values of the plant traits per each study site.

**Usage:**

    ./scatter_plot_data_retr.R

**How it works:**

    The scripts extracts the data from predictions and observations and groups per date. Output files was used to generate the resulting scatter plot.

    Adjust variable `folder` according to the place where your data is located.


### `spectra_quantiles.R`

**Purpose:** Generates a plot with lines that correspond to mean observed spectra and mean simulated spectra and also shows their quantiles.

**Usage:**

    ./spectra_quantiles.R


## Directory structure

- Input Data (`data/`):
	- `BL.dry_spec.RData`
	- `reflectances_obs_0504-1011_all.csv`
    - `measurements_0504-1011_all.csv`
    - some other datasets

- Processed Data and Outputs (`RData/`):
	- `$your_working_directory/PROSAIL_done_RF_ready.RData`: Contains processed data ready for modeling.
	- `$your_working_directory/rf_Cab.RData`: Trained random forest model for Cab.
	- `$your_working_directory/predictions_Cab.RData`: Predictions made by the random forest model.

- Auxillary plotting scripts (`plt/`):
    - `green_residuals.plt`
    - `green_residuals.py` these two scripts are for plotting a big panel plot with green grass fraction vs model errors. Python script is the latest version.


## Running the Workflow

1. Prepare the Environment:
	- Ensure all required packages are installed.
	- Place the input data files in the `data/` directory.
2. Run the main script:
	- Execute `main.R` to perform simulations and data preprocessing.

	`./main.R [your_working_directory]`

3. Train the Random Forest Model:
	- Execute `pred_Cab/Car/LAI/LMA.R`, specifying the data directory if necessary.

	`./pred_Cab.R [your_working_directory]`

4. Review Outputs:
    - Trained models and predictions will be saved in the specified `RData/` subdirectory.
    - Use the predictions for further analysis or visualization.

5. Generate plots:
    - Execute plot functions.

## Notes

- Data Files:
	- Ensure that the data files match the expected format, especially column names and structures.
	- The observed reflectance data should have wavelengths as row names or a dedicated column.

- Parameters in Scripts:
	- You may need to adjust parameters such as *spectra_ranges*, *ranges_to_delete*, and smoothing degrees of freedom (*df*) based on your data.

- Custom Functions:
	- The `functions.R` script contains functions that assume certain variables (e.g., `pca.prosail`, `spectra_names`) are defined in the global environment. Make sure these are properly initialized in your scripts.

- Random Forest Parameters:
	- In `pred_Cab/Car/LAI/LMA.R`, the *mtry* parameter in `randomForest()` is set to 256. Adjust this value based on the number of predictor variables in your dataset.

- Error Handling:
	- The scripts assume the presence of certain variables and files. Implement additional error checking as needed.


