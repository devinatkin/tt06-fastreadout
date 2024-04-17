# Makefile for testing with iverilog and vvp

# Define the compiler and simulator
IVL = iverilog -g2012
VVP = vvp

# Output directory for simulation files
OUT_DIR = sim_out

# Create the output directory if it doesn't exist
$(shell mkdir -p $(OUT_DIR))

# All source files (excluding testbenches)
SOURCES = src/tt_um_devinatkin_fastreadout.v src/shift_register.v src/output_parallel_to_serial.v src/repeated_add_multiplier.v src/frequency_module.v src/frequency_counter.v

# Phony targets
.PHONY: all clean

all: tb_top tb_shift_register tb_image_input tb_repeated_add_multiplier tb_frequency_module tb_frequency_counter tb_frequency_measure

tb_top: 
	$(IVL) -o $(OUT_DIR)/$@.vvp $(SOURCES) tb/tb_top.v 
	$(VVP) $(OUT_DIR)/$@.vvp
	python3 tb/graph_top_outputs.py sim_out/tb_top_output.txt sim_out

tb_shift_register: 
	$(IVL) -o $(OUT_DIR)/$@.vvp src/shift_register.v tb/tb_shift_register.v
	$(VVP) $(OUT_DIR)/$@.vvp

tb_image_input:
	python3 tb/Image2Register.py --image_path tb/Image_Test_Input.png --output_path $(OUT_DIR)/Image_Test_Input.txt
	$(IVL) -Ptb_image_input.IMAGE_FILE=\"$(OUT_DIR)/Image_Test_Input.txt\" -Ptb_image_input.OUTPUT_FILE=\"$(OUT_DIR)/verilog_out.txt\" -o $(OUT_DIR)/$@.vvp src/shift_register.v tb/tb_image_input.v
	$(VVP) $(OUT_DIR)/$@.vvp
	python3 tb/Register2Image.py -input_file $(OUT_DIR)/verilog_out.txt -compare_file tb/Image_Test_Input.png

tb_image_input_frequency_measure:
	python3 tb/Image2Register.py --image_path tb/Image_Test_Input.png --output_path $(OUT_DIR)/Image_Test_Input.txt
	$(IVL) -Ptb_image_input_frequency_measure.IMAGE_FILE=\"$(OUT_DIR)/Image_Test_Input.txt\" -Ptb_image_input_frequency_measure.OUTPUT_FILE=\"$(OUT_DIR)/verilog_out_frequency_measure.txt\" -o $(OUT_DIR)/$@.vvp src/shift_register.v src/frequency_module.v src/repeated_add_multiplier.v src/frequency_counter.v tb/tb_image_input_frequency_measure.v
	$(VVP) $(OUT_DIR)/$@.vvp

tb_repeated_add_multiplier:
	$(IVL) -o $(OUT_DIR)/$@.vvp src/repeated_add_multiplier.v tb/tb_repeated_add_multiplier.v
	$(VVP) $(OUT_DIR)/$@.vvp
	python3 tb/repeated_add_multiplier_graph.py $(OUT_DIR)/repeated_add_multiplier.txt $(OUT_DIR)/repeated_add_multiplier_tb.png

tb_frequency_module:
	$(IVL) -o $(OUT_DIR)/$@.vvp src/frequency_module.v src/repeated_add_multiplier.v tb/tb_frequency_module.v
	$(VVP) $(OUT_DIR)/$@.vvp
	python3 tb/frequency_module_graph.py $(OUT_DIR)/frequency_module_tb.txt $(OUT_DIR)/period_vs_light.png $(OUT_DIR)/frequency_vs_light.png

tb_frequency_counter:
	$(IVL) -o $(OUT_DIR)/$@.vvp src/frequency_counter.v tb/tb_frequency_counter.v
	$(VVP) $(OUT_DIR)/$@.vvp

tb_frequency_measure:
	$(IVL) -o $(OUT_DIR)/$@.vvp src/frequency_counter.v src/frequency_module.v src/repeated_add_multiplier.v tb/tb_frequency_measure.v
	$(VVP) $(OUT_DIR)/$@.vvp
	python3 tb/frequency_measure_graph.py $(OUT_DIR)/frequency_measure_tb.txt $(OUT_DIR)/frequency_measure_tb.png

tb_output_parallel_to_serial:
	$(IVL) -o $(OUT_DIR)/$@.vvp src/output_parallel_to_serial.v tb/tb_output_parallel_to_serial.v
	$(VVP) $(OUT_DIR)/$@.vvp

clean:
	@echo Cleaning up...
	rm -rf $(OUT_DIR)