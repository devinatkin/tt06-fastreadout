import re
import sys

import matplotlib.pyplot as plt

def graph_top_output_periods(file_path, output_path):
    for i in range(8):
        time_values = []
        output_values = []
        with open(file_path, 'r') as file:
            for line in file:
                match = re.search(r'\d+ - Period Pulse Out %d\s+=\s+(\d+)' % i, line)
                if match:

                    # Extract the value from the line
                    value = float(line.split('=')[1].strip())
                    output_values.append(value)

                    # Keep track of the time (The value to the left of the - is the time in ns)
                    time_values.append(int(line.split('-')[0].strip()))

        # Plot the values over time
        plt.clf()
        plt.plot(time_values, output_values)
        plt.xlabel('Time')
        plt.ylabel(f"{i} Value")
        plt.title(f"Graph of {i} over Time")
        plt.savefig(f"{output_path}/PeriodPulseOut_{i}.png")

def graph_top_output_values(file_path, output_path):
    for i in range(8):
        time_values = []
        output_values = []
        with open(file_path, 'r') as file:
            for line in file:
                # 2052290 - Output 0 = 3126
                match = re.search(r'\d+ - Output %d\s+=\s+(\d+)' % i, line)
                if match:

                    # Extract the value from the line
                    value = float(line.split('=')[1].strip())
                    output_values.append(value)

                    # Keep track of the time (The value to the left of the - is the time in ns)
                    time_values.append(int(line.split('-')[0].strip()))

        # Plot the values over time
        plt.clf()
        plt.plot(output_values)
        plt.xlabel('Time')
        plt.ylabel(f"{i} Value")
        plt.title(f"Graph of {i} over Time")
        plt.savefig(f"{output_path}/OutputGraph_{i}.png")


def main():
    file_path = sys.argv[1]
    output_path = sys.argv[2]
    graph_top_output_periods(file_path, output_path)
    graph_top_output_values(file_path, output_path)

if __name__ == "__main__":
    main()
