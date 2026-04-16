import matplotlib.pyplot as plt
import sys
from collections import defaultdict
import statistics

def process_file(file_path):
    data = defaultdict(list)
    freq_clock_hz = None

    with open(file_path, 'r') as file:
        lines = file.readlines()

        # --- Parse clock frequency from first line ---
        if lines:
            first_line = lines[0]
            if "Clock Frequency" in first_line:
                freq_clock_hz = float(first_line.split(':')[-1].split()[0])
                print(f"Parsed clock frequency: {freq_clock_hz} Hz")

        # --- Parse rest of data ---
        for line in lines[1:]:  # skip first line
            parts = line.split(',')
            if len(parts) == 3:
                light_level = int(parts[0].split()[-1])
                frequency = float(parts[2].split('=')[-1])
                data[light_level].append(frequency)

    # Mode calculation stays the same
    mode_frequencies = {}
    for light_level, frequencies in data.items():
        try:
            mode_frequency = statistics.mode(frequencies)
            mode_frequencies[light_level] = [mode_frequency]
        except statistics.StatisticsError:
            mode_frequencies[light_level] = list(set(frequencies))

    return dict(sorted(mode_frequencies.items())), freq_clock_hz

def plot_frequency_vs_light(levels, frequencies, filename):
    frequencies_khz = [freq / 1000 for freq in frequencies]  # Convert Hz to kHz

    plt.figure(figsize=(10, 6))
    plt.plot(levels, frequencies_khz, marker='o', linestyle='-')
    plt.title('Light Level vs. Mode Frequency')
    plt.xlabel('Light Level')
    plt.ylabel('Mode Frequency (kHz)')
    plt.yscale('log')
    plt.grid(True)
    plt.savefig(filename, format='jpg')
    plt.close()

def plot_period_vs_light(levels, periods, filename, freq_clock_hz):
    periods_microseconds = [period * 1e6 for period in periods]
    clock_counts = [period * freq_clock_hz for period in periods]

    fig, ax1 = plt.subplots(figsize=(10, 6))

    # Primary y-axis: period in microseconds
    ax1.plot(levels, periods_microseconds, marker='o', linestyle='-')
    ax1.set_title('Light Level vs. Mode Period')
    ax1.set_xlabel('Light Level')
    ax1.set_ylabel('Mode Period (microseconds)')
    ax1.grid(True)

    # Secondary y-axis: equivalent frequency clock count
    ax2 = ax1.twinx()
    ax2.set_ylabel('Equivalent Frequency Clock Count')

    # Match the axis scaling to the first axis
    y1_min, y1_max = ax1.get_ylim()
    ax2.set_ylim(
        (y1_min * 1e-6) * freq_clock_hz,
        (y1_max * 1e-6) * freq_clock_hz
    )

    plt.savefig(filename, format='jpg')
    plt.close()

def main():
    if len(sys.argv) != 4:
        print(
            "Usage: python script.py <path_to_text_file> "
            "<path_to_period_vs_light_graph> "
            "<path_to_frequency_vs_light_graph> "
        )
        sys.exit(1)

    file_path = sys.argv[1]
    period_v_light_file_path = sys.argv[2]
    frequency_v_light_file_path = sys.argv[3]

    data, freq_clock_hz = process_file(file_path)

    light_levels = list(data.keys())
    mode_frequencies_hz = [mode[0] for mode in data.values()]
    periods_seconds = [1 / freq if freq != 0 else 0 for freq in mode_frequencies_hz]

    plot_frequency_vs_light(light_levels, mode_frequencies_hz, frequency_v_light_file_path)
    plot_period_vs_light(light_levels, periods_seconds, period_v_light_file_path, freq_clock_hz)

    print(
        f"Graphs have been saved as '{frequency_v_light_file_path}' "
        f"and '{period_v_light_file_path}'."
    )

if __name__ == "__main__":
    main()