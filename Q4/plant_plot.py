import argparse
import matplotlib.pyplot as plt
import os

# הגדרת פונקציה לקבלת פרמטרים
def plot_data(plant, height_data, leaf_count_data, dry_weight_data):
    # Create output directory if it doesn't exist
    output_dir = "4_2"
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
    
    args = parser.parse_args()
    
    # קריאה לפונקציה עם הנתונים שהוזנו
    plot_data(args.plant, args.height, args.leaf_count, args.dry_weight)

if __name__ == "__main__":
    main()
