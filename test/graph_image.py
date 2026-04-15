from pathlib import Path
import re
from PIL import Image

INPUT = "Verilog_Frequency_Output_Test1.txt"
OUTPUT = "output.png"

text = Path(INPUT).read_text()

# Extract rows
lines = [line for line in text.splitlines() if line.strip()]

parsed_rows = []
for line in lines:
    row = re.findall(r'(?<![#\w])([0-9A-Fa-f]{4})(?![\w])', line)
    if row:
        parsed_rows.append([int(v, 16) for v in row])

if not parsed_rows:
    raise ValueError("No valid data found")

# --- Key fix here ---
row_lengths = [len(r) for r in parsed_rows]
width = min(row_lengths)   # force consistent width
height = len(parsed_rows)

print(f"Using width={width}, height={height}")
print(f"Row lengths (sample): {row_lengths[:10]} ...")

# Normalize rows
flat = []
for r in parsed_rows:
    if len(r) >= width:
        flat.extend(r[:width])  # trim
    else:
        flat.extend(r + [0]*(width - len(r)))  # pad if needed

# Convert to black/white
pixels = [255 if n > 0 else 0 for n in flat]

img = Image.new("L", (width, height))
img.putdata(pixels)
img.save(OUTPUT)

print(f"Saved {OUTPUT}")