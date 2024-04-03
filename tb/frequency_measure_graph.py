import re
import matplotlib.pyplot as plt
import sys

def extract_data_and_plot(file_path, output_image_path):
    # Load the content of the file
    with open(file_path, 'r') as file:
        content = file.read()

    # Define regex pattern to extract period and light level
    pattern = r'PERIOD =\s+([0-9]+), light_level =\s+([0-9]+)'

    # Find all matches
    matches = re.findall(pattern, content)

    # Convert matches to dictionary {light_level: period}, taking the last period value for each light level
    data = {int(light_level): int(period) for period, light_level in matches}

    # Sort the data by light level
    sorted_light_levels = sorted(data.keys())
    sorted_periods = [data[level] for level in sorted_light_levels]

    # Plotting
    plt.figure(figsize=(10, 6))
    plt.plot(sorted_light_levels, sorted_periods, marker='o', linestyle='-', color='b')
    plt.title('Light Level vs. Period')
    plt.xlabel('Light Level')
    plt.ylabel('Period (Clock Cycles)')
    plt.grid(True)
    
    # Save the plot as a JPG file
    plt.savefig(output_image_path, format='jpg')
    plt.close()  # Close the plot to free memory

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python script.py <input_file_path> <output_image_path>")
    else:
        input_file_path = sys.argv[1]
        output_image_path = sys.argv[2]
        extract_data_and_plot(input_file_path, output_image_path)
