import matplotlib.pyplot as plt
import os

plant = "Rose"
height_data = [50, 55, 60, 65, 70]
leaf_count_data = [35, 40, 45, 50, 55]
dry_weight_data = [2.0, 2.0, 2.1, 2.1, 3.0]

output_dir = '4_1'
os.makedirs(output_dir, exist_ok=True)

print(f"Plant: {plant}")
print(f"Height data: {height_data} cm")
print(f"Leaf count data: {leaf_count_data}")
print(f"Dry weight data: {dry_weight_data} g")

plt.figure(figsize=(10, 6))
plt.scatter(height_data, leaf_count_data, color='b')
plt.title(f'Height vs Leaf Count for {plant}')
plt.xlabel('Height (cm)')
plt.ylabel('Leaf Count')
plt.grid(True)
plt.savefig(f"{output_dir}/{plant}_scatter.png")
plt.close()

plt.figure(figsize=(10, 6))
plt.hist(dry_weight_data, bins=5, color='g', edgecolor='black')
plt.title(f'Histogram of Dry Weight for {plant}')
plt.xlabel('Dry Weight (g)')
plt.ylabel('Frequency')
plt.grid(True)
plt.savefig(f"{output_dir}/{plant}_histogram.png")
plt.close()

weeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5']
plt.figure(figsize=(10, 6))
plt.plot(weeks, height_data, marker='o', color='r')
plt.title(f'{plant} Height Over Time')
plt.xlabel('Week')
plt.ylabel('Height (cm)')
plt.grid(True)
plt.savefig(f"{output_dir}/{plant}_line_plot.png")
plt.close()

print(f"Generated plots for {plant}:")
print(f"Scatter plot saved as {output_dir}/{plant}_scatter.png")
print(f"Histogram saved as {output_dir}/{plant}_histogram.png")
print(f"Line plot saved as {output_dir}/{plant}_line_plot.png")
