# f2 8a 62 02 82 fc 7c 5c e2 fc ec cc 2c 2c 0c 4c 8c 8c 4c 6c 4c 8c fc d2 1c 6c 5c 02 e2 82 4a 56 0e 3e 09 41 da e6 9a ca

from PIL import Image

print("Reading file...")
# Open the file and read each hex byte "f2 8a 62 02 82 fc 7c"
with open('verilog_output.txt', 'r') as f:
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

img.show()