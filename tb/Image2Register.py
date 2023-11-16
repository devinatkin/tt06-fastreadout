from PIL import Image
import argparse

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--image_path", type=str, default="Image_Test_Input.png", help="path to image")
    parser.add_argument("--output_path", type=str, default="output.txt", help="path to output test vector")
    parser.add_argument("--col_or_row", type=str, default="col", help="col or row based output vector")
    args = parser.parse_args()
    image_path = args.image_path
    output_path = args.output_path
    col_or_row = args.col_or_row
    with Image.open(image_path) as img:
        img = img.convert('L') # convert to grayscale
        img = img.convert('L').point(lambda x: int(x/256.0 * 256), 'L') # convert to 8-bit grayscale
        
        width, height = img.size
        print("Image size: {}x{}".format(width, height))
        
        if col_or_row == "col":
            with open(output_path, 'w') as f:
                for x in range(width):
                    for y in range(height):
                        pixel = img.getpixel((x, y))
                        # write pixel value in hex
                        f.write("{:02x} ".format(pixel))
                    f.write("\n")
        elif col_or_row == "row":
            with open(output_path, 'w') as f:
                for y in range(height):
                    for x in range(width):
                        pixel = img.getpixel((x, y))
                        # write pixel value in hex
                        f.write("{:02x} ".format(pixel))
                    f.write("\n")
        else:
            raise ValueError("col_or_row must be either 'col' or 'row'")

