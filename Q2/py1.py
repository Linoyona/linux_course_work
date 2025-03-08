import numpy as np

with open('requirements.txt', 'r') as f:
    lines = f.readlines()
    for line in lines:
        if 'arr=' in line:
            arr_str = line.split('=')[1].strip()
            arr = eval(arr_str)

mean_value = np.mean(arr)
std_dev = np.std(arr)

print(f"Mean of the array: {mean_value}")
print(f"Standard Deviation of the array: {std_dev}")

