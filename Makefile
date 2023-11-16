# Makefile for testing with iverilog and vvp

# Define the compiler and simulator
IVL = iverilog -g2012
VVP = vvp

# Output directory for simulation files
OUT_DIR = sim_out

# Create the output directory if it doesn't exist
$(shell mkdir -p $(OUT_DIR))

# All source files (excluding testbenches)
SOURCES = src/tt_um_devinatkin_fastreadout.v src/shift_register.v

# Phony targets
.PHONY: all clean

all: tb_top tb_shift_register

tb_top: 
	$(IVL) -o $(OUT_DIR)/$@.vvp $(SOURCES) tb/tb_top.v
	$(VVP) $(OUT_DIR)/$@.vvp

tb_shift_register: 
	$(IVL) -o $(OUT_DIR)/$@.vvp src/shift_register.v tb/tb_shift_register.v
	$(VVP) $(OUT_DIR)/$@.vvp

tb_image_input: 
	$(IVL) -o $(OUT_DIR)/$@.vvp src/shift_register.v tb/tb_image_input.v
	$(VVP) $(OUT_DIR)/$@.vvp

clean:
	@echo Cleaning up...
	rm -rf $(OUT_DIR)