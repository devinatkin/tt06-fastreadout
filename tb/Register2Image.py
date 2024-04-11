""" Read the output of the Verilog simulation and convert it to an image

Compare that image to the original image to see if the Verilog code is working correctly

The input file is a text file with the following format:
f2 8a 62 02 82 fc 7c 5c e2 fc ec cc 2c 2c 0c 4c 8c 8c 4c 6c 4c 8c fc d2 1c 6c 5c 02 e2 82 4a 56 0e 3e 09 41 da e6 9a ca
"""
from PIL import Image
import argparse

def extract_image(image_file):
    print("Reading file...")
    # Open the file and read each hex byte "f2 8a 62 02 82 fc 7c"
    with open(image_file, 'r') as f:
        data = f.read().replace('\n', ' ').split(' ')
        data = [x for x in data if x != '']
        data = [int("0x" + x, 16) for x in data]

    # Create a new image with size 1024x1024
    img = Image.new('L', (1024, 1024))

    # Loop through each byte of data and set the corresponding pixel value in the image
    for i in range(min(len(data), 1024*1024)):
        # Convert the byte to an integer
        pixel_value = int.from_bytes(data[i:i+1], byteorder='big')
        # Set the pixel value in the image
        x = i % 1024
        y = i // 1024
        img.putpixel((x,y), pixel_value)
    
    return img

def compare_images(img1, img2, grayscale=True):
    """
    Compare the two images and return (True, Rotation) if they match
    Return (False, None) if they do not match

    img1: PIL Image
    img2: PIL Image

    
    """
    # Convert the images to grayscale
    if grayscale:
        img1 = img1.convert('L')
        img2 = img2.convert('L')

    # Compare the two images
    if img1 == img2:
        return (True, 0)
    else:
        # Rotate the image 90 degrees and compare again
        img2 = img2.rotate(90)
        if img1 == img2:
            return (True, 90)
        else:
            # Rotate the image 180 degrees and compare again
            img2 = img2.rotate(90)
            if img1 == img2:
                return (True, 180)
            else:
                # Rotate the image 270 degrees and compare again
                img2 = img2.rotate(90)
                if img1 == img2:
                    return (True, 270)
                else:
                    return (False, None)

if __name__ == "__main__":
    # Parse the command line arguments
    parser = argparse.ArgumentParser(description='Convert a text file to an image')
    parser.add_argument('-input_file', type=str, help='path to input file', default='verilog_output.txt')
    parser.add_argument('-compare_file', type=str, help='path to compare file')
    parser.add_argument('-show', action='store_true', help='show the image')
    args = parser.parse_args()

    # Extract the image from the input file
    img = extract_image(args.input_file)

    if args.show:
        img.show()

    # Compare the image to the compare file
    if args.compare_file:
        compare_img = Image.open(args.compare_file)
        result, rotation = compare_images(img, compare_img)

        if result:
            print("Images match")
            print("Rotation: {}".format(rotation))
            img.save("sim_out/matched_image.png")
        else:
            print("Images do not match")
            # Save the mismatched image
            img.save("sim_out/mismatched_image.png")

            raise ValueError("Images do not match")