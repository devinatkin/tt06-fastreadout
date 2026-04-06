import re
import os
import matplotlib.pyplot as plt
from collections import defaultdict

# === CONFIG ===
FILENAME = "counting_tests.txt"
PLOT_DIR = "plots"

# === SETUP OUTPUT DIRECTORY ===
os.makedirs(PLOT_DIR, exist_ok=True)

# === DATA STRUCTURE ===
data = defaultdict(list)

current_test_value = None
current_signal = None

# === REGEX PATTERNS ===
test_value_pattern = re.compile(r"Testing value:\s*(\d+)")
signal_pattern = re.compile(r"Shifted value\s+\d+\s+for signal\s+(\d+)")
duty_pattern = re.compile(r"DUTY=([0-9.]+)")

# === PARSE FILE ===
with open(FILENAME, "r") as f:
    for line in f:
        line = line.strip()

        match = test_value_pattern.search(line)
        if match:
            current_test_value = int(match.group(1))
            continue

        match = signal_pattern.search(line)
        if match:
            current_signal = int(match.group(1))
            continue

        match = duty_pattern.search(line)
        if match and current_test_value is not None and current_signal is not None:
            duty = float(match.group(1))
            data[current_signal].append((current_test_value, duty))

# === SORT DATA ===
for signal in data:
    data[signal].sort(key=lambda x: x[0])

# === 1. COMBINED PLOT ===
plt.figure()

for signal, values in sorted(data.items()):
    x = [v[0] for v in values]
    y = [v[1] for v in values]
    plt.plot(x, y, label=f"Signal {signal}")

plt.xlabel("Test Value")
plt.ylabel("Duty Cycle")
plt.title("Duty Cycle vs Test Value (All Signals)")
plt.legend()
plt.grid(True)

combined_path = os.path.join(PLOT_DIR, "all_signals.png")
plt.tight_layout()
plt.savefig(combined_path)
plt.close()

# === 2. INDIVIDUAL SIGNAL PLOTS ===
for signal, values in sorted(data.items()):
    x = [v[0] for v in values]
    y = [v[1] for v in values]

    plt.figure()
    plt.plot(x, y)

    plt.xlabel("Test Value")
    plt.ylabel("Duty Cycle")
    plt.title(f"Signal {signal} Duty Cycle")
    plt.grid(True)

    filename = os.path.join(PLOT_DIR, f"signal_{signal}.png")
    plt.tight_layout()
    plt.savefig(filename)
    plt.close()

print(f"Plots saved in: {PLOT_DIR}/")