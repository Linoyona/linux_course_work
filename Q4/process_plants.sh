#!/bin/bash

# Define log file
LOG_FILE="plant_processing.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to handle errors
log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: $1" | tee -a "$LOG_FILE"
    exit 1
}

# Check if CSV file exists
if [ $# -ne 1 ]; then
    log_error "Usage: $0 <csv_file_path>"
fi

CSV_FILE="$1"

if [ ! -f "$CSV_FILE" ]; then
    log_error "CSV file not found: $CSV_FILE"
fi

log_message "Starting plant data processing with CSV file: $CSV_FILE"

# Define venv directory outside repository
VENV_DIR="../plant_venv"

# Check if venv exists, create if not
if [ ! -d "$VENV_DIR" ]; then
    log_message "Creating new virtual environment at $VENV_DIR"
    python3 -m venv "$VENV_DIR" || log_error "Failed to create virtual environment"
else
    log_message "Virtual environment already exists at $VENV_DIR"
fi

# Activate virtual environment
log_message "Activating virtual environment"
source "$VENV_DIR/bin/activate" || log_error "Failed to activate virtual environment"

# Check and install required packages
log_message "Checking and installing required packages"
pip install --quiet matplotlib numpy pandas || log_error "Failed to install required packages"

# Check if Python script exists
PYTHON_SCRIPT="plant_plot.py"
if [ ! -f "$PYTHON_SCRIPT" ]; then
    log_error "Python script not found: $PYTHON_SCRIPT"
fi

# Create temp modified version of the Python script
TMP_PYTHON_SCRIPT="temp_plant_plot.py"
log_message "Creating temporary modified Python script"

# Create modified Python script that accepts output directory parameter
cat > "$TMP_PYTHON_SCRIPT" << 'EOF'
import argparse
import matplotlib.pyplot as plt
import os

# הגדרת פונקציה לקבלת פרמטרים
def plot_data(plant, height_data, leaf_count_data, dry_weight_data, output_dir):
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    # Scatter Plot - Height vs Leaf Count
    plt.figure(figsize=(10, 6))
    plt.scatter(height_data, leaf_count_data, color='b')
    plt.title(f'Height vs Leaf Count for {plant}')
    plt.xlabel('Height (cm)')
    plt.ylabel('Leaf Count')
    plt.grid(True)
    plt.savefig(f"{output_dir}/{plant}_scatter.png")
    plt.close()  # Close the plot to prepare for the next one
    
    # Histogram - Distribution of Dry Weight
    plt.figure(figsize=(10, 6))
    plt.hist(dry_weight_data, bins=5, color='g', edgecolor='black')
    plt.title(f'Histogram of Dry Weight for {plant}')
    plt.xlabel('Dry Weight (g)')
    plt.ylabel('Frequency')
    plt.grid(True)
    plt.savefig(f"{output_dir}/{plant}_histogram.png")
    plt.close()  # Close the plot to prepare for the next one
    
    # Line Plot - Plant Height Over Time
    weeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5']  # Time points for the data
    plt.figure(figsize=(10, 6))
    plt.plot(weeks, height_data, marker='o', color='r')
    plt.title(f'{plant} Height Over Time')
    plt.xlabel('Week')
    plt.ylabel('Height (cm)')
    plt.grid(True)
    plt.savefig(f"{output_dir}/{plant}_line_plot.png")
    plt.close()  # Close the plot
    
    print(f"Generated plots for {plant}:")
    print(f"Scatter plot saved as {output_dir}/{plant}_scatter.png")
    print(f"Histogram saved as {output_dir}/{plant}_histogram.png")
    print(f"Line plot saved as {output_dir}/{plant}_line_plot.png")

# פונקציה לקליטת פרמטרים
def main():
    parser = argparse.ArgumentParser(description='Generate plots for plant data')
    parser.add_argument('--plant', type=str, required=True, help='The name of the plant')
    parser.add_argument('--height', type=float, nargs='+', required=True, help='Height data (in cm)')
    parser.add_argument('--leaf_count', type=int, nargs='+', required=True, help='Leaf count data')
    parser.add_argument('--dry_weight', type=float, nargs='+', required=True, help='Dry weight data (in grams)')
    parser.add_argument('--output_dir', type=str, required=True, help='Output directory for saving plots')
    
    args = parser.parse_args()
    
    # קריאה לפונקציה עם הנתונים שהוזנו
    plot_data(args.plant, args.height, args.leaf_count, args.dry_weight, args.output_dir)

if __name__ == "__main__":
    main()
EOF

# Skip header line and process each CSV line
log_message "Processing plant data from CSV file"
tail -n +2 "$CSV_FILE" | while IFS=, read -r plant height leaf_weight dry_weight || [[ -n "$plant" ]]; do
    # Clean up input values by removing quotes
    plant=$(echo "$plant" | tr -d '"')
    height=$(echo "$height" | tr -d '"')
    leaf_count=$(echo "$leaf_weight" | tr -d '"')
    dry_weight=$(echo "$dry_weight" | tr -d '"')
    
    log_message "Processing plant: $plant"
    
    # Create directory for the plant if it doesn't exist
    PLANT_DIR="${plant// /_}"  # Replace spaces with underscores
    mkdir -p "$PLANT_DIR" || log_error "Failed to create directory for $plant"
    
    # Run Python script with parameters from CSV
    log_message "Running Python script for $plant with params: height=$height, leaf_count=$leaf_count, dry_weight=$dry_weight, output_dir=$PLANT_DIR"
    
    python "$TMP_PYTHON_SCRIPT" --plant "$plant" --height $height --leaf_count $leaf_count --dry_weight $dry_weight --output_dir "$PLANT_DIR"
    
    # Check if Python script executed successfully
    if [ $? -eq 0 ]; then
        log_message "Python script executed successfully for $plant"
        log_message "Files saved directly to $PLANT_DIR directory"
        log_message "Processing completed for $plant"
    else
        log_error "Python script failed for $plant"
    fi
done

# Clean up temporary Python script
log_message "Removing temporary Python script"
rm "$TMP_PYTHON_SCRIPT"

log_message "All plant data processing completed successfully"

# Deactivate virtual environment
deactivate
log_message "Virtual environment deactivated"
