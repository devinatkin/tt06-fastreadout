`timescale 1ns / 1ns

module tb_top;

    // Inputs
    reg [7:0] ui_in;
    reg [7:0] uio_in;
    reg ena;
    reg running_sim;
    reg clk;
    reg rst_n;

    // Row Shift Register Inputs
    wire DATA_IN1;
    wire RCLK_1;
    wire LOAD_1;

    assign DATA_IN1 = ui_in[0];
    assign RCLK_1 = ui_in[1];
    assign LOAD_1 = ui_in[2];

    // Outputs
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;


    integer valid_test_count = 0;

    // Instantiate the Unit Under Test (UUT)
    tt_um_devinatkin_fastreadout uut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock generation
    always #10 clk = ~clk;

    integer file;

    integer k;
    parameter bits_per_pixel = 5;
    parameter pixels = 8;
    reg [(bits_per_pixel*pixels):0] input_level = 0;

    // Reset Input Registers
    initial begin
        ui_in[1] = 1'b0;
        #10;
        ui_in[1] = 1'b1;
        #10;
    end

    // Stimulus
    initial begin
        if (uut.bits_per_pixel != bits_per_pixel) begin
            $display("Error: uut.bits_per_pixel is not equal to bits_per_pixel, %0d != %0d", uut.bits_per_pixel, bits_per_pixel);
            $finish;
        end
        if (uut.pixels != pixels) begin
            $display("Error: uut.pixels is not equal to pixels, %0d != %0d", uut.pixels, pixels);
            $finish;
        end
        // Initialize Inputs
        file = $fopen("sim_out/tb_top_output.txt", "w");
        clk = 1'b0;
        rst_n = 1'b0;
        ena = 1'b1;
        k = 0;
        running_sim = 1'b0;
        #20;

        #20;
        rst_n = 1'b1;
        ena = 1'b1;
        #20;
        running_sim = 1'b1;

        // Test 1 (Test the output with 0 input values)
        $display("Test 1 (Test the output with 0 input values)");
        $fwrite(file, "%0t - Test 1 (Test the output with 0 input values)\n",$time);
        #1000000;
        $fwrite(file, "%0t - Test 1 (Test the output with 0 input values) - Passed\n",$time);

        // Test 2 (Test the output with incrementing input values)
        $display("Test 2 (Test the output with incrementing input values)");
        $fwrite(file, "%0t - Test 2 (Test the output with incrementing input values)\n", $time);

        for (input_level = 0; input_level < 2**(bits_per_pixel*pixels); input_level = input_level + 1) begin
            $display("Testing - Input Level = %0d", input_level);
            $fwrite(file, "%0t - Testing - Input Level = %0d\n", $time, input_level);
            // Shift in the current light level
            for (k = 0; k< (bits_per_pixel*pixels); k = k + 1) begin
                // Toggle DATA_IN
                ui_in[0] = input_level[k];
                // Toggle RCLK high
                ui_in[1] = 1'b0;
                #20;
                ui_in[1] = 1'b1;
                #20;
            end
            // Toggle LOAD high
            ui_in[2] = 1'b1;
            ui_in[1] = 1'b0;
            #20;
            ui_in[1] = 1'b1;
            #20;
            ui_in[1] = 1'b0;
            ui_in[2] = 1'b0;

            #5000;
        end
        $display("Test 2 (Test the output with incrementing input values) - Passed");
        $fwrite(file, "%0t - Test 2 (Test the output with incrementing input values) - Passed\n", $time);

        //TODO Implement top level tests
        $display("All tests passed (tb_top.v)");
        $display("Valid Test Count (Output Register Matches)= %0d", valid_test_count);
        $fclose(file);
        $finish;
    end

    // Measure the time between pulses on the uio_out
    // These come from the frequency modules and should be at frequency of the output signal
    // The counter is then intended to convert those and calculate the frequencies.
    time last_pulse_out[7:0];
    reg [7:0] prev_uio_out;
    integer i;
    reg [7:0] valid_output_values;

    initial begin
        
        for (i = 0; i < 8; i = i + 1) begin
            last_pulse_out[i] = $time;
        end

        prev_uio_out = 8'b0;
        valid_output_values = 8'b0;
        i = 0;
    end
    
    always @(posedge clk) begin
        for (i = 0; i < 8; i = i + 1) begin
            if (uio_out[i] && !prev_uio_out[i]) begin // Check for positive edge
                $fwrite(file, "%0t - Period Pulse Out %0d  = %0t\n",$time, i, ($time - last_pulse_out[i]));
                last_pulse_out[i] = $time;
                valid_output_values[i] = 0;
            end
        end
        prev_uio_out = uio_out;
    end

    // Meaure the outputs of the uo_out, these are from the parallel to serial shift register
    parameter output_size = 12;
    reg [output_size-1:0] uo_out_values [7:0];
    reg [$clog2(output_size):0] input_counter [7:0];

    initial begin
        if (uut.counter_bits != output_size) begin
            $display("Error: uut.counter_bits is not equal to output_size, %0d != %0d", uut.counter_bits, output_size);
            $finish;
        end
        for (i = 0; i < 8; i = i + 1) begin
            uo_out_values[i] = 0;
            input_counter[i] = 0;
        end
    end

    generate
        genvar j;
        for (j = 0; j < 8; j = j + 1) begin : gen_loop
            always @(posedge clk) begin
                if (running_sim == 1'b1) begin
                    uo_out_values[j] = {uo_out[j] , uo_out_values[j][output_size-1:1]};
                    input_counter[j] = input_counter[j] + 1;
                    if(input_counter[j] == output_size) begin


                        if (valid_output_values[j] == 1) begin
                            if (uo_out_values[j] !== uut.row_loop[j].output_inst_row.data_in) begin
                                $display("Output %0d = %0d", j, uo_out_values[j]);
                                $display("Expected Output %0d = %0d", j, uut.row_loop[j].output_inst_row.data_in);
                                $error("Test failed at i = %0d", j);
                                $finish; // Terminate simulation
                            end
                            valid_test_count = valid_test_count + 1;

                            $fwrite(file, "%0t - Output %0d = %0d\n", $time, j, uo_out_values[j]);
                        end


                        input_counter[j] = 0;
                        uo_out_values[j] = 0;
                        valid_output_values[j] = 1'b1;
                    end 

                    
                end
            end
        end
    endgenerate
endmodule