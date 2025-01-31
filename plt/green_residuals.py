import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script: green_residuals.py
# Purpose: Generate scatter plots of vegetation trait residuals against Green Area Ratio
#          for different experimental groups, including linear regression trends.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Load the CSV file containing residuals and Green Area Ratio data into a DataFrame
df = pd.read_csv('../data/plots_green_ratio_residuals_python.csv')

# Define the experimental groups and their corresponding column names in the DataFrame
groups = {
    'IGM': ['Green_area_ratio_IGM', 'Cab_IGM', 'Car_IGM', 'LAI_IGM', 'LMA_IGM'],
    'EGM': ['Green_area_ratio_EGM', 'Cab_EGM', 'Car_EGM', 'LAI_EGM', 'LMA_EGM'],
    'EGG': ['Green_area_ratio_EGG', 'Cab_EGG', 'Car_EGG', 'LAI_EGG', 'LMA_EGG'],
    'NutNet_C_1': ['Green_area_ratio_NutNet_C_1', 'Cab_NutNet_C_1', 'Car_NutNet_C_1', 'LAI_NutNet_C_1', 'LMA_NutNet_C_1'],
    'NutNet_C_2': ['Green_area_ratio_NutNet_C_2', 'Cab_NutNet_C_2', 'Car_NutNet_C_2', 'LAI_NutNet_C_2', 'LMA_NutNet_C_2'],
    'NutNet_C_3': ['Green_area_ratio_NutNet_C_3', 'Cab_NutNet_C_3', 'Car_NutNet_C_3', 'LAI_NutNet_C_3', 'LMA_NutNet_C_3'],
    'NutNet_NPK_1': ['Green_area_ratio_NutNet_NPK_1', 'Cab_NutNet_NPK_1', 'Car_NutNet_NPK_1', 'LAI_NutNet_NPK_1', 'LMA_NutNet_NPK_1'],
    'NutNet_NPK_2': ['Green_area_ratio_NutNet_NPK_2', 'Cab_NutNet_NPK_2', 'Car_NutNet_NPK_2', 'LAI_NutNet_NPK_2', 'LMA_NutNet_NPK_2'],
    'NutNet_NPK_3': ['Green_area_ratio_NutNet_NPK_3', 'Cab_NutNet_NPK_3', 'Car_NutNet_NPK_3', 'LAI_NutNet_NPK_3', 'LMA_NutNet_NPK_3']
}

# Define the variables (traits) to plot against Green Area Ratio
variables = ['Cab', 'Car', 'LAI', 'LMA']

# Function to concatenate NutNet data across multiple plots
def concatenate_nutnet_data(df, prefix):
    """
    Concatenate data from NutNet plots (1, 2, and 3) for a given treatment prefix.
    
    Parameters:
    df (DataFrame): The DataFrame containing the data.
    prefix (str): The prefix of the treatment group ('NutNet_C' or 'NutNet_NPK').

    Returns:
    Tuple of Series: Concatenated data for Green Area Ratio, Cab, Car, LAI, and LMA.
    """
    # Concatenate Green Area Ratio data across plots 1, 2, and 3
    green_area_ratio = pd.concat([df[f'Green_area_ratio_{prefix}_{i}'] for i in range(1, 4)], ignore_index=True)
    # Concatenate Cab (chlorophyll content) residuals
    cab = pd.concat([df[f'Cab_{prefix}_{i}'] for i in range(1, 4)], ignore_index=True)
    # Concatenate Car (carotenoids) residuals
    car = pd.concat([df[f'Car_{prefix}_{i}'] for i in range(1, 4)], ignore_index=True)
    # Concatenate LAI (Leaf Area Index) residuals
    lai = pd.concat([df[f'LAI_{prefix}_{i}'] for i in range(1, 4)], ignore_index=True)
    # Concatenate LMA (Leaf Mass per Area) residuals
    lma = pd.concat([df[f'LMA_{prefix}_{i}'] for i in range(1, 4)], ignore_index=True)
    return green_area_ratio, cab, car, lai, lma

# Concatenate data for NutNet Control (C) and NutNet NPK treatment groups
nutnet_c_data = concatenate_nutnet_data(df, 'NutNet_C')
nutnet_npk_data = concatenate_nutnet_data(df, 'NutNet_NPK')

# Add the concatenated NutNet data to the groups dictionary for plotting
groups['NutNet_C'] = nutnet_c_data
groups['NutNet_NPK'] = nutnet_npk_data

# Adjust plot parameters for better readability (e.g., font size)
plt.rcParams.update({'font.size': 16})

# Create a grid of subplots with 4 rows and 5 columns
# Rows correspond to variables (Cab, Car, LAI, LMA)
# Columns correspond to experimental groups
fig, axes = plt.subplots(4, 5, figsize=(25, 20))

# Function to plot each scatter plot with a linear regression trend line
def plot_scatter(ax, x, y, group_name, var_name, var_title, y_label):
    """
    Plot a scatter plot of trait residuals against Green Area Ratio,
    including a linear regression trend line if applicable.

    Parameters:
    ax (Axes): Matplotlib Axes object to plot on.
    x (Series or array-like): Data for x-axis (Green Area Ratio).
    y (Series or array-like): Data for y-axis (trait residuals).
    group_name (str): Name of the experimental group.
    var_name (str): Name of the variable being plotted (e.g., 'Cab').
    var_title (str): Title for the plot (displayed at the top).
    y_label (str): Label for the y-axis.
    """
    # Plot the data points as a scatter plot
    ax.scatter(x, y, s=60)
    ax.set_xlabel('Green Area Ratio')
    ax.set_ylabel(y_label)
    ax.set_title(var_title, fontsize=20)  # Set plot title if provided

    # Optionally, add grid lines
    # ax.grid(True)

    # Add the group name inside the plot area, positioned at the top-left
    ax.text(0.05, 0.95, f'{group_name}', transform=ax.transAxes, fontsize=14,
            verticalalignment='top', bbox=dict(boxstyle='round,pad=0.3', edgecolor='black', facecolor='white'))
  
    # Add a linear regression trend line if there is sufficient data
    if len(x) > 0 and len(y) > 0:  # Ensure there is data to plot
        x = np.array(x, dtype=float)
        y = np.array(y, dtype=float)
        mask = ~np.isnan(x) & ~np.isnan(y)  # Exclude NaN values
        if np.sum(mask) > 1:  # Need at least 2 data points to fit a line
            # Perform linear regression (least squares fit)
            m, b = np.polyfit(x[mask], y[mask], 1)  # Slope (m) and intercept (b)
            # Plot the fitted line over the data points
            ax.plot(x, m * x + b, color='red', linewidth=3)

# Remove individual NutNet plot entries from the groups dictionary
# since we are using the concatenated data for NutNet_C and NutNet_NPK
keys_to_remove = ['NutNet_C_1', 'NutNet_C_2', 'NutNet_C_3', 'NutNet_NPK_1', 'NutNet_NPK_2', 'NutNet_NPK_3']
for key in keys_to_remove:
    if key in groups:
        del groups[key]

# Print the keys of the groups dictionary to confirm the groups being plotted
print(list(groups.keys()))

# Loop over variables (rows) and groups (columns) to create the grid of plots
for row, var_name in enumerate(variables):
    for col, (group_name, columns) in enumerate(groups.items()):
        # Extract data for Green Area Ratio and the current variable
        if group_name in ['NutNet_C', 'NutNet_NPK']:
            # For concatenated NutNet data, unpack the tuples
            green_area_ratio, cab, car, lai, lma = columns
        else:
            # For other groups, extract data from the DataFrame using column names
            green_area_ratio = df[columns[0]]
            cab = df[columns[1]]
            car = df[columns[2]]
            lai = df[columns[3]]
            lma = df[columns[4]]

        # Set y-axis label only for the first column
        if col == 0:
            y_label = 'Residuals'
        else:
            y_label = ""

        # Set variable title only for the middle column (column index 2)
        if col == 2:
            var_title = f'{var_name}'
        else:
            var_title = ""

        # Get the data for the current variable by converting var_name to lowercase
        # and accessing the corresponding variable (e.g., 'Cab' -> 'cab')
        variable_data = eval(var_name.lower())  # Assumes 'cab', 'car', 'lai', 'lma' are defined

        # Plot the scatter plot on the appropriate subplot
        plot_scatter(axes[row, col], green_area_ratio, variable_data, group_name, var_name, var_title, y_label)

# Adjust layout to prevent subplot labels and titles from overlapping
plt.tight_layout(rect=[0, 0.01, 1, 0.99])

# Save the figure to a file with specified format and resolution
plt.savefig('../plots/residuals_green_ratio_0407_python.png', format='png', dpi=400)

