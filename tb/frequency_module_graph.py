import matplotlib.pyplot as plt
import sys
from collections import defaultdict
import statistics

def process_file(file_path):
    # Parse the data
    data = defaultdict(list)
    with open(file_path, 'r') as file:
        lines = file.readlines()
        for line in lines:
            parts = line.split(',')
            if len(parts) == 3:
                light_level = int(parts[0].split()[-1])
                frequency = float(parts[2].split('=')[-1])
                data[light_level].append(frequency)

    # Calculate the mode frequency for each light level
    mode_frequencies = {}
    for light_level, frequencies in data.items():
        try:
            mode_frequency = statistics.mode(frequencies)
            mode_frequencies[light_level] = [mode_frequency]
        except statistics.StatisticsError:
            mode_frequencies[light_level] = list(set(frequencies))

    return dict(sorted(mode_frequencies.items()))

def plot_frequency_vs_light(levels, frequencies, filename):
    frequencies_khz = [freq / 1000 for freq in frequencies]  # Convert frequencies to kHz
    plt.figure(figsize=(10, 6))
    plt.plot(levels, frequencies_khz, marker='o', linestyle='-', color='blue')
    plt.title('Light Level vs. Mode Frequency')
    plt.xlabel('Light Level')
    plt.ylabel('Mode Frequency (kHz)')
    plt.yscale('log')  # Set y-axis to logarithmic scale
    plt.grid(True)
    plt.savefig(filename, format='jpg')
    plt.close()

def plot_period_vs_light(levels, periods, filename):
    periods_microseconds = [period * 1e6 for period in periods]  # Convert periods to microseconds
    plt.figure(figsize=(10, 6))
    plt.plot(levels, periods_microseconds, marker='o', linestyle='-', color='red')
    plt.title('Light Level vs. Mode Period')
    plt.xlabel('Light Level')
    plt.ylabel('Mode Period (microseconds)')
    plt.grid(True)
    plt.savefig(filename, format='jpg')
    plt.close()

def main():
    if len(sys.argv) != 4:
        print("Usage: python script.py <path_to_text_file> <path_to_period_vs_light_graph> <path_to_frequency_vs_light_graph>")
        sys.exit(1)
    
    file_path = sys.argv[1]
    period_v_light_file_path = sys.argv[2]
    frequency_v_light_file_path = sys.argv[3]

    data = process_file(file_path)

    light_levels = list(data.keys())
    mode_frequencies_hz = [mode[0] for mode in data.values()]
    periods_seconds = [1 / freq if freq != 0 else 0 for freq in mode_frequencies_hz]

    plot_frequency_vs_light(light_levels, mode_frequencies_hz, frequency_v_light_file_path)
    plot_period_vs_light(light_levels, periods_seconds, period_v_light_file_path)
    print(f"Graphs have been saved as '{frequency_v_light_file_path}' and '{period_v_light_file_path}'.")

if __name__ == "__main__":
    main()
