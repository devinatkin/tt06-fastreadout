import re
import os
import matplotlib.pyplot as plt
from collections import defaultdict

# === CONFIG ===
FILENAME = "counting_tests.txt"
PLOT_DIR = "plots"

os.makedirs(PLOT_DIR, exist_ok=True)

# totals[signal][input_value] = list of TOTALs
totals = defaultdict(lambda: defaultdict(list))

current_signal = None
current_input_value = None

# === REGEX PATTERNS ===
shifted_pattern = re.compile(r"Shifted value\s+([01]+)\s+for signal\s+(\d+)")
total_pattern = re.compile(r"TOTAL=([0-9.]+)")

# === PARSE FILE ===
with open(FILENAME, "r") as f:
    for line in f:
        line = line.strip()

        match = shifted_pattern.search(line)
        if match:
            binary_str = match.group(1)
            current_input_value = int(binary_str, 2)   # binary -> integer
            current_signal = int(match.group(2))
            continue

        match = total_pattern.search(line)
        if match and current_signal is not None and current_input_value is not None:
            total_val = float(match.group(1))
            totals[current_signal][current_input_value].append(total_val)

# === AVERAGE TOTALS IF DUPLICATES EXIST ===
avg_totals = {}

for signal, values_dict in totals.items():
    avg_totals[signal] = {}
    for input_value, total_list in values_dict.items():
        avg_totals[signal][input_value] = sum(total_list) / len(total_list)

# === COMBINED PLOT ===
plt.figure(figsize=(12, 7))

for signal in sorted(avg_totals.keys()):
    x = sorted(avg_totals[signal].keys())
    y = [avg_totals[signal][v] for v in x]
    plt.plot(x, y, marker='o', label=f"S{signal}")

plt.xlabel("Input value")
plt.ylabel("TOTAL")
plt.title("TOTAL vs input value")
plt.legend()
plt.grid(True)

combined_path = os.path.join(PLOT_DIR, "all_signals_total.png")
plt.tight_layout()
plt.savefig(combined_path)
plt.close()

# === INDIVIDUAL SIGNAL PLOTS ===
for signal in sorted(avg_totals.keys()):
    x = sorted(avg_totals[signal].keys())
    y = [avg_totals[signal][v] for v in x]

    plt.figure(figsize=(8, 5))
    plt.plot(x, y, marker='o')
    plt.xlabel("Input value")
    plt.ylabel("TOTAL")
    plt.title(f"S{signal}: TOTAL vs input value")
    plt.grid(True)

    filename = os.path.join(PLOT_DIR, f"signal_{signal}_total.png")
    plt.tight_layout()
    plt.savefig(filename)
    plt.close()

print(f"Plots saved in: {PLOT_DIR}/")