`timescale 1ns / 1ps

module tb_image_input_frequency_measure #(parameter IMAGE_SIZE = 1024, IMAGE_FILE= "tb/output.txt", OUTPUT_FILE = "tb/verilog_output.txt") ;

    // Parameters
    // Width of the shift register is 8-bits per pixel
    parameter INPUT_BITS = 8;
    parameter counter_bits = 16;
    localparam WIDTH = IMAGE_SIZE * INPUT_BITS;
    parameter CLOCK_FREQ = 50_000_000; // Clock frequency in Hz
    parameter LOW_FREQ = 10_001;
    parameter HIGH_FREQ = 20_000_000;
    
    // Clock period definitions
    parameter PERIOD = 20;

    // Inputs
    reg clk;
    reg reset_n;
    reg shift_in;
    reg load;
    reg [WIDTH-1:0] data_in;
    reg [7:0] temp;
  
    // Outputs
    wire [WIDTH-1:0] data_out;

    wire [IMAGE_SIZE-1:0] freq_out_values;

    wire [(IMAGE_SIZE*counter_bits)-1:0] TIME_HIGH;
    wire [(IMAGE_SIZE*counter_bits)-1:0] TIME_LOW;
    wire [(IMAGE_SIZE*counter_bits)-1:0] TIME_PERIOD;

    reg [(IMAGE_SIZE*counter_bits)-1:0] temp_out;

    // File
    integer file;
    integer output_file;

    // Instantiate the Shift Registers module (Data Out will be Fed into the Frequency Modules)
    shift_register #(.WIDTH(WIDTH)) data_shift_in (
        .clk(clk),
        .reset_n(reset_n),
        .shift_in(shift_in),
        .load(load),
        .data_out(data_out)
    );

    // Instantiate the Frequency Modules
    genvar i;
    generate
        for (i = 0; i < IMAGE_SIZE; i = i + 1) begin : freq_module_inst
            frequency_module #(
                .CLOCK_FREQ(CLOCK_FREQ),
                .LOW_FREQ(LOW_FREQ),
                .HIGH_FREQ(HIGH_FREQ),
                .INPUT_BITS(INPUT_BITS)
            ) freq_module (
                .CLK(clk),
                .RST_N(reset_n),
                .INPUT_VALUE(data_out[(INPUT_BITS*i) + (INPUT_BITS-1) : (INPUT_BITS*i)]),
                .FREQ_OUT(freq_out_values[i])
            );
        end
    endgenerate

    // Instantiate the Frequency Counter Modules
    generate
        for (i = 0; i < IMAGE_SIZE; i = i + 1) begin : freq_counter_inst
                frequency_counter #(
                    .COUNTER_BITS(counter_bits)
                    ) freq_count (
                    .CLK(clk),
                    .RST_N(reset_n),
                    .FREQ_IN(freq_out_values[i]),
                    .TIME_HIGH(TIME_HIGH[(i*counter_bits)+(counter_bits-1):(i*counter_bits)]),
                    .TIME_LOW(TIME_LOW[(i*counter_bits)+(counter_bits-1):(i*counter_bits)]),
                    .PERIOD(TIME_PERIOD[(i*counter_bits)+(counter_bits-1):(i*counter_bits)])
                );
        end

    endgenerate

    // Initial stimulus
    initial begin
        $display("Image Output Testbench started successfully");
        // Initialize inputs
        clk = 0;
        reset_n = 0;
        shift_in = 0;
        load = 0;
        data_in = 0;

        // Wait for 40 ns for global reset to finish
        #40;
        reset_n = 1;

        // Open the file
        file = $fopen(IMAGE_FILE, "r");
        if (file == 0) begin
            $display("Error opening file: %s", IMAGE_FILE);
            $fatal;
        end

        // Open the output file
        output_file = $fopen(OUTPUT_FILE, "w");
        if (output_file == 0) begin
            $display("Error opening output file");
            $fatal;
        end
        // The File is formatted as IMAGE_SIZE 8-bit hex values per line, with IMAGE_SIZE lines
        // Each element is a pixel seperated by a space

        // Start testing

        // For each line
        for (int i = 0; i < IMAGE_SIZE; i = i + 1) begin
            // Read in the next line
            $display("Reading line %d", i);
            for (int j = 0; j < IMAGE_SIZE; j = j + 1) begin
                if (!$fscanf(file, "%h ", temp)) begin
                    $display("Error reading file");
                    $fatal;
                end
                data_in = {data_in[WIDTH-9:0], temp};
                
            end

            // Shift in the line
            for (int j = IMAGE_SIZE*8 - 1; j >= 0; j = j - 1) begin
                // Shift in 1 into the ith position
                shift_in = data_in[j];
                #PERIOD;
            end

            // Load the line
            load = 1;
            #PERIOD;
            load = 0;
            
            $display("Simulating line %d", i);
            // Wait for all the freq_out to complete (with a lowest frequency being 8khz, wait at least 0.5ms)
            #(500_000);

            $display("Finished simulating line %d", i);
            // Write the line to the output file


            // Check that the data_out is correct i.e. it maches the data_in
            // This check is after the shift register load
            if (data_out != data_in) begin
                $display("Error: data_out does not match data_in");
                $display("data_in: %b", data_in);
                $display("data_out: %b", data_out);
                $fatal;
            end

            // Output the TIME_PERIOD values to the output file
            temp_out = TIME_PERIOD;
            $display("Writing Line # %d", i);


            $fwrite(output_file, "Line # %d: ", i);
            for (int j = 0; j < IMAGE_SIZE; j = j + 1) begin
                $fwrite(output_file, "%h ", temp_out[(counter_bits-1):0]);
                temp_out = temp_out >> counter_bits;
            end
            $fwrite(output_file, "\n");
            $display("Finished # %d \n", i);
        end


        // End of test
        $display("Image Output Testbench finished successfully");
        $finish;
    end

    // Clock generation
    always #10 clk = ~clk;

    // Dump variables to VCD file
    // initial begin
    //     $dumpfile("tb_image_input_frequency_measure.vcd");
    //     $dumpvars(0, tb_image_input_frequency_measure);
    // end

endmodule