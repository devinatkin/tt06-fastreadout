import matplotlib.pyplot as plt
import numpy as np
import argparse

def parse_data_line(line):
    """
    Parses a single line of the data file and returns a dictionary with the multiplier,
    multiplicand, and clock cycles extracted.
    """
    parts = line.split(',')
    data = {}
    for part in parts:
        key, value = part.strip().split('=')
        data[key.strip()] = int(value.strip())
    return data

def read_data_file(file_path):
    """
    Reads the data file line by line, parses each line using parse_data_line function,
    and returns a list of dictionaries containing the data.
    """
    data = []
    with open(file_path, 'r') as file:
        for line in file:
            if line.strip():  # Ensure the line is not empty
                data.append(parse_data_line(line))
    return data

def bar3dgraph(data, filename='output.png'):
    # Extracting X, Y, and Z values
    x_vals = [d["Multiplier"] for d in data]
    y_vals = [d["Multiplicand"] for d in data]
    z_vals = [d["Clock Cycles"] for d in data]

    # Since the Y values are the same in this sample, we'll use unique values for plotting
    x_unique = np.unique(x_vals)
    y_unique = np.unique(y_vals)
    z_vals_np = np.array(z_vals)

    # Creating a meshgrid for the X and Y coordinates
    x, y = np.meshgrid(x_unique, y_unique)

    # Reshaping Z to match the dimensions of X and Y
    z = z_vals_np.reshape(len(y_unique), len(x_unique))

    # Plotting
    fig = plt.figure(figsize=(10, 7))
    ax = fig.add_subplot(111, projection='3d')

    # Using a bar3d plot
    ax.bar3d(x.flatten(), y.flatten(), np.zeros_like(z.flatten()), 1, 1, z.flatten(), shade=True)

    ax.set_xlabel('Multiplier')
    ax.set_ylabel('Multiplicand')
    ax.set_zlabel('Clock Cycles')

    # Setting titles for better clarity
    plt.title('3D Bar Graph of Clock Cycles by Multiplier and Multiplicand')
    plt.savefig(filename)
    

def main(file_path, output_png):
    # Read and parse the data
    data = read_data_file(file_path)
    
    print(f"Outputting 3D bar graph to: {output_png}")
    bar3dgraph(data, output_png)
    
    # Calculate mean, median, mode, and max values for Clock Cycles
    clock_cycles = [d["Clock Cycles"] for d in data]
    mean = np.mean(clock_cycles)
    median = np.median(clock_cycles)
    max_value = np.max(clock_cycles)

    # Output the calculated values
    print(f"Mean: {mean}")
    print(f"Median: {median}")
    print(f"Max: {max_value}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate 3D bar graph of clock cycles by multiplier and multiplicand.')
    parser.add_argument('file_path', type=str, help='Path to the data file')
    parser.add_argument('output_png', type=str, help='Path to the output PNG file')
    args = parser.parse_args()

    main(args.file_path, args.output_png)
