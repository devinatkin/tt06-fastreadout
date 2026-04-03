from __future__ import annotations

import re
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd


def parse_one_hot_output_file(filepath: str | Path) -> pd.DataFrame:
    filepath = Path(filepath)
    text = filepath.read_text(encoding="utf-8")

    shift_pattern = re.compile(
        r"Shifting in Binary Value:\s*([01]{40})(.*?)(?=Shifting in Binary Value:|\Z)",
        re.DOTALL,
    )

    signal_pattern = re.compile(
        r"Signal\s+(\d+)\s+Timing Analysis:\s*"
        r"Cycle\s+\d+:\s*HIGH=(\d+)\s+LOW=(\d+)\s+TOTAL=(\d+)\s+DUTY=([0-9.]+)"
    )

    rows = []

    for shift_match in shift_pattern.finditer(text):
        binary_value = shift_match.group(1)
        block = shift_match.group(2)

        # One-hot index (LSB = bit 0)
        try:
            input_bit = binary_value[::-1].index("1")
        except ValueError:
            input_bit = None

        for signal_match in signal_pattern.finditer(block):
            rows.append(
                {
                    "input_bit": input_bit,
                    "signal": int(signal_match.group(1)),
                    "high": int(signal_match.group(2)),
                    "low": int(signal_match.group(3)),
                    "total": int(signal_match.group(4)),
                    "duty": float(signal_match.group(5)),
                }
            )

    df = pd.DataFrame(rows).sort_values(["input_bit", "signal"]).reset_index(drop=True)
    return df


def ensure_output_dir():
    out = Path("plots")
    out.mkdir(exist_ok=True)
    return out


def save_heatmap(df: pd.DataFrame, metric: str, outdir: Path):
    pivot = df.pivot(index="signal", columns="input_bit", values=metric).sort_index()

    plt.figure(figsize=(14, 4))
    plt.imshow(pivot.values, aspect="auto", interpolation="nearest")
    plt.colorbar(label=metric.upper())
    plt.xlabel("Input bit")
    plt.ylabel("Signal")
    plt.title(f"{metric.upper()} heatmap")
    plt.yticks(range(len(pivot.index)), pivot.index)
    plt.tight_layout()

    filepath = outdir / f"{metric}_heatmap.png"
    plt.savefig(filepath, dpi=200)
    plt.close()


def save_signal_lines(df: pd.DataFrame, metric: str, outdir: Path):
    plt.figure(figsize=(14, 5))

    for signal in sorted(df["signal"].unique()):
        sub = df[df["signal"] == signal].sort_values("input_bit")
        plt.plot(sub["input_bit"], sub[metric], marker="o", label=f"S{signal}")

    plt.xlabel("Input bit")
    plt.ylabel(metric.upper())
    plt.title(f"{metric.upper()} vs input bit")
    plt.grid(True)
    plt.legend(ncol=2, fontsize=8)
    plt.tight_layout()

    filepath = outdir / f"{metric}_lines.png"
    plt.savefig(filepath, dpi=200)
    plt.close()


def save_dominant_signal(df: pd.DataFrame, metric: str, outdir: Path):
    idx = df.groupby("input_bit")[metric].idxmax()
    dominant = df.loc[idx].sort_values("input_bit")

    plt.figure(figsize=(14, 4))
    plt.plot(dominant["input_bit"], dominant["signal"], marker="o")
    plt.xlabel("Input bit")
    plt.ylabel("Dominant signal")
    plt.title(f"Dominant signal ({metric})")
    plt.grid(True)
    plt.tight_layout()

    filepath = outdir / f"{metric}_dominant.png"
    plt.savefig(filepath, dpi=200)
    plt.close()


def main():
    filepath = "one_hot_bit_output.txt"  # change if needed
    outdir = ensure_output_dir()

    df = parse_one_hot_output_file(filepath)

    # --- Focus on TOTAL (your main interest) ---
    save_heatmap(df, metric="total", outdir=outdir)
    save_signal_lines(df, metric="total", outdir=outdir)
    save_dominant_signal(df, metric="total", outdir=outdir)

    # Optional: keep these if you want comparison later
    # save_heatmap(df, metric="duty", outdir=outdir)
    # save_signal_lines(df, metric="duty", outdir=outdir)

    print(f"Plots saved to: {outdir.resolve()}")


if __name__ == "__main__":
    main()