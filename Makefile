# Makefile for testing with iverilog and vvp

# Define the compiler and simulator
IVL = iverilog -g2012
VVP = vvp

# Output directory for simulation files
OUT_DIR = sim_out

# Create the output directory if it doesn't exist
$(shell mkdir -p $(OUT_DIR))

# All source files (excluding testbenches)
SOURCES = src/tt_um_devinatkin_fastreadout.v src/shift_register.v src/repeated_add_multiplier.v src/frequency_module.v

# Phony targets
.PHONY: all clean

all: tb_top tb_shift_register tb_image_input tb_repeated_add_multiplier

tb_top: 
	$(IVL) -o $(OUT_DIR)/$@.vvp $(SOURCES) tb/tb_top.v
	$(VVP) $(OUT_DIR)/$@.vvp

tb_shift_register: 
	$(IVL) -o $(OUT_DIR)/$@.vvp src/shift_register.v tb/tb_shift_register.v
	$(VVP) $(OUT_DIR)/$@.vvp

tb_image_input:
	python3 tb/Image2Register.py --image_path tb/Image_Test_Input.png --output_path $(OUT_DIR)/Image_Test_Input.txt
	$(IVL) -Ptb_image_input.IMAGE_FILE=\"$(OUT_DIR)/Image_Test_Input.txt\" -Ptb_image_input.OUTPUT_FILE=\"$(OUT_DIR)/verilog_out.txt\" -o $(OUT_DIR)/$@.vvp src/shift_register.v tb/tb_image_input.v
	$(VVP) $(OUT_DIR)/$@.vvp
	python3 tb/Register2Image.py -input_file $(OUT_DIR)/verilog_out.txt -compare_file tb/Image_Test_Input.png

tb_repeated_add_multiplier:
	$(IVL) -o $(OUT_DIR)/$@.vvp src/repeated_add_multiplier.v tb/tb_repeated_add_multiplier.v
	$(VVP) $(OUT_DIR)/$@.vvp

clean:
	@echo Cleaning up...
	rm -rf $(OUT_DIR)