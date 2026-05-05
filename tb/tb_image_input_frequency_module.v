`timescale 1ns / 1ns

module tb_image_input_frequency_module;

    parameter IMAGE_SIZE   = 1024;
    parameter INPUT_BITS   = 8;
    parameter CLOCK_FREQ   = 50_000_000;
    parameter LOW_FREQ     = 20_000;
    parameter HIGH_FREQ    = 20_000_000;
    parameter PERIOD       = 20;

    parameter IMAGE_FILE   = "tb/output.txt";
    parameter OUTPUT_FILE  = "tb/frequency_module_verilog_output.txt";

    parameter MAX_WAIT_CYCLES = 500000;

    reg clk;
    reg reset_n;

    reg  [INPUT_BITS-1:0] pixel_in [0:IMAGE_SIZE-1];
    wire [IMAGE_SIZE-1:0] freq_out_values;

    reg  [IMAGE_SIZE-1:0] period_measured;
    reg  [IMAGE_SIZE-1:0] freq_out_prev;

    integer rise_count [0:IMAGE_SIZE-1];
    integer first_rise_cycle [0:IMAGE_SIZE-1];
    integer second_rise_cycle [0:IMAGE_SIZE-1];

    time first_rise_time [0:IMAGE_SIZE-1];
    time second_rise_time [0:IMAGE_SIZE-1];
    time measured_period [0:IMAGE_SIZE-1];

    time row_start_time;
    integer image_file;
    integer output_file;
    integer scan_rc;

    integer row;
    integer col;
    integer k;
    integer cycle_count;

    reg [INPUT_BITS-1:0] temp_pixel;

    // ----------------------------------------------------------------
    // DUT instances
    // ----------------------------------------------------------------
    genvar gi;
    generate
        for (gi = 0; gi < IMAGE_SIZE; gi = gi + 1) begin : freq_module_inst
            frequency_module #(
                .CLOCK_FREQ(CLOCK_FREQ),
                .LOW_FREQ(LOW_FREQ),
                .HIGH_FREQ(HIGH_FREQ),
                .INPUT_BITS(INPUT_BITS)
            ) freq_module (
                .CLK(clk),
                .RST_N(reset_n),
                .INPUT_VALUE(pixel_in[gi]),
                .FREQ_OUT(freq_out_values[gi])
            );
        end
    endgenerate

    // ----------------------------------------------------------------
    // Clock
    // ----------------------------------------------------------------
    initial begin
        clk = 0;
        forever #(PERIOD/2) clk = ~clk;
    end


    // ----------------------------------------------------------------
    // Main stimulus
    // ----------------------------------------------------------------
    initial begin
        $dumpfile("tb_image_input_frequency_module.vcd");
        $dumpvars(0, tb_image_input_frequency_module);
        $display("Image Output Testbench started successfully");
        $display("IMAGE_FILE  = %s", IMAGE_FILE);
        $display("OUTPUT_FILE = %s", OUTPUT_FILE);

        reset_n = 0;
        cycle_count = 0;
        period_measured = {IMAGE_SIZE{1'b0}};
        freq_out_prev = {IMAGE_SIZE{1'b0}};

        for (k = 0; k < IMAGE_SIZE; k = k + 1) begin
            rise_count[k]        = 0;
            first_rise_cycle[k]  = -1;
            second_rise_cycle[k] = -1;
            first_rise_time[k]   = 0;
            second_rise_time[k]  = 0;
            measured_period[k]   = 0;

            // Initialize pixel inputs to 0
            pixel_in[k] = 0;
        end

        image_file = $fopen(IMAGE_FILE, "r");
        if (image_file == 0) begin
            $display("Error opening image file");
            $fatal;
        end

        output_file = $fopen(OUTPUT_FILE, "w");
        if (output_file == 0) begin
            $display("Error opening output file");
            $fatal;
        end

        // Reset
        repeat (5) @(posedge clk);
        reset_n = 1;
        repeat (2) @(posedge clk);

        // Read each row
        for (row = 0; row < IMAGE_SIZE; row = row + 1) begin
            row_start_time = $time;
            $display("Reading row %0d", row);

            // Read one row of pixels
            for (col = 0; col < IMAGE_SIZE; col = col + 1) begin
                scan_rc = $fscanf(image_file, "%h", temp_pixel);
                if (scan_rc != 1) begin
                    $display("Error reading file at row %0d col %0d", row, col);
                    $fatal;
                end

                pixel_in[col] = temp_pixel;
                // $display("  pixel_in[%0d] = %0h", col, pixel_in[col]);
            end

            // Let inputs propagate
            @(posedge clk);

            // Clear row-specific measurement tracking
            period_measured = {IMAGE_SIZE{1'b0}};
            freq_out_prev   = freq_out_values;
            cycle_count     = 0;

            for (k = 0; k < IMAGE_SIZE; k = k + 1) begin
                rise_count[k]        = 0;
                first_rise_cycle[k]  = -1;
                second_rise_cycle[k] = -1;
                first_rise_time[k]   = 0;
                second_rise_time[k]  = 0;
                measured_period[k]   = 0;
            end

            $display("Waiting for two rising edges from every pixel on row %0d", row);
            // The checks below will wait until all pixels have produced two rising edges or until a timeout occurs
            while ((period_measured !== {IMAGE_SIZE{1'b1}}) && (cycle_count < MAX_WAIT_CYCLES)) begin
                @(posedge clk);
                cycle_count <= cycle_count + 1;

                for (k = 0; k < IMAGE_SIZE; k = k + 1) begin
                    if (freq_out_values[k] && !freq_out_prev[k]) begin
                        if (rise_count[k] == 0) begin
                            rise_count[k]       = 1;
                            first_rise_cycle[k] = cycle_count;
                            first_rise_time[k]  = $time;

                        end
                        else if (rise_count[k] == 1) begin
                            rise_count[k]         = 2;
                            second_rise_cycle[k]  = cycle_count;
                            second_rise_time[k]   = $time;
                            measured_period[k]    = $time - first_rise_time[k];
                            period_measured[k]    = 1'b1;

                            // $display("Pixel %0d produced 2 rising edges: input = %0h, first_rise_cycle = %0d, second_rise_cycle = %0d, first_rise_time = %0t, second_rise_time = %0t, measured_period = %0t",
                            //          k, pixel_in[k], first_rise_cycle[k], second_rise_cycle[k],
                            //          first_rise_time[k], second_rise_time[k], measured_period[k]);
                        end
                        
                    end

                end
                freq_out_prev = freq_out_values;
            end

            $display("Finished waiting for row %0d after %0d cycles", row, cycle_count);

            if (period_measured !== {IMAGE_SIZE{1'b1}}) begin
                $display("Timeout on row %0d after %0d cycles", row, cycle_count);
                for (k = 0; k < IMAGE_SIZE; k = k + 1) begin
                    if (!period_measured[k]) begin
                        $display("  Pixel %0d did not produce two rising edges, input = %0h, rise_count = %0d",
                                 k, pixel_in[k], rise_count[k]);
                    end
                end
                $fatal;
            end

            // Log measured period for each pixel
            $fwrite(output_file, "ROW %0d - START_TIME=%0t\n", row, row_start_time);
            for (k = 0; k < IMAGE_SIZE; k = k + 1) begin
                $fwrite(output_file,
                    "PIXEL %0d INPUT=%0h FIRST_RISE_CYCLE=%0d SECOND_RISE_CYCLE=%0d FIRST_RISE_TIME=%0t SECOND_RISE_TIME=%0t PERIOD=%0t\n",
                    k, pixel_in[k],
                    first_rise_cycle[k], second_rise_cycle[k],
                    first_rise_time[k], second_rise_time[k],
                    measured_period[k]);
            end

            $fwrite(output_file, "\n");

            $display("Finished row %0d", row);
        end

        $fclose(image_file);
        $fclose(output_file);

        $display("Image Output Testbench finished successfully at %0t", $time);
        $finish;
    end

endmodule