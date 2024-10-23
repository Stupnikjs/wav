import pandas as pd
import matplotlib.pyplot as plt
import numpy as np


plt.switch_backend('Agg')
# Read the CSV file
csv_file = '../zig-c-simple/plot.csv'
data = pd.read_csv(csv_file)

# Print the data for debugging
print(data)

# Assuming the CSV has one column of sine wave values
# Generate time values assuming the data is sampled at regular intervals
sampling_rate = 0.1  # e.g., 0.1 seconds between samples
time = np.arange(len(data)) * sampling_rate  # Create time array

# Plot the sine wave
plt.figure(figsize=(10, 6))
plt.plot(time[0:1000], data.iloc[:1000, 0], label='Sine Wave')  # Use iloc to access the first column

# Adding labels and title
plt.xlabel('Time (seconds)')
plt.ylabel('Amplitude')
plt.title('Sine Wave Plot')
plt.legend()
plt.grid(True)

# Display the plot
plt.show()  # This will now work since Agg backend is not used


plt.savefig('sine_wave_plot.png')
