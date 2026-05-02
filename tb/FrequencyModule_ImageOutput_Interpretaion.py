#!/usr/bin/env python3

import argparse
import re
from pathlib import Path

import numpy as np
from PIL import Image


ROW_RE = re.compile(r"ROW\s+(\d+)\s+-\s+START_TIME=(\d+)")
PIXEL_RE = re.compile(r"PIXEL\s+(\d+)\s+.*?PERIOD=(\d+)")


def read_periods(input_path: Path, width: int, height: int) -> np.ndarray:
    image = np.full((height, width), np.nan, dtype=np.float64)

    current_row = None

    with input_path.open("r", encoding="utf-8") as f:
        for line in f:
            row_match = ROW_RE.search(line)
            if row_match:
                current_row = int(row_match.group(1))
                continue

            pixel_match = PIXEL_RE.search(line)
            if pixel_match and current_row is not None:
                col = int(pixel_match.group(1))
                period = int(pixel_match.group(2))

                if 0 <= current_row < height and 0 <= col < width:
                    image[current_row, col] = period

    missing = np.isnan(image).sum()
    if missing:
        raise ValueError(
            f"Missing PERIOD values for {missing} pixels. "
            f"Parsed {width * height - missing} out of {width * height}."
        )

    return image


def normalize_to_uint8(values: np.ndarray) -> np.ndarray:
    min_val = np.min(values)
    max_val = np.max(values)

    if max_val == min_val:
        return np.zeros_like(values, dtype=np.uint8)

    normalized = (values - min_val) / (max_val - min_val)
    return (normalized * 255).astype(np.uint8)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--width", type=int, default=1024)
    parser.add_argument("--height", type=int, default=1024)
    parser.add_argument("--invert", action="store_true")

    args = parser.parse_args()

    periods = read_periods(args.input, args.width, args.height)
    pixels = normalize_to_uint8(periods)

    if args.invert:
        pixels = 255 - pixels

    image = Image.fromarray(pixels, mode="L")
    image.save(args.output)

    print(f"Saved image to {args.output}")
    print(f"Period range: {np.min(periods)} to {np.max(periods)}")


if __name__ == "__main__":
    main()