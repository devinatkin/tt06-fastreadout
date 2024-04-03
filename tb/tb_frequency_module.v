`timescale 1ns / 1ps

module frequency_module_tb;

    parameter CLOCK_FREQ = 50_000_000; // Clock frequency in Hz
    parameter LOW_FREQ = 1_000.333;
    parameter HIGH_FREQ = 20_000_000;
    parameter INPUT_BITS = 8;

    reg CLK;
    reg RST_N;
    reg [INPUT_BITS-1:0] INPUT;
    wire FREQ_OUT;

    integer i;
    integer freq_change_count = 0;
    reg prev_freq_out = 0;
    // Instantiate the DUT
    frequency_module #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .LOW_FREQ(LOW_FREQ),
        .HIGH_FREQ(HIGH_FREQ),
        .INPUT_BITS(INPUT_BITS)
    ) DUT (
        .CLK(CLK),
        .RST_N(RST_N),
        .INPUT_VALUE(INPUT),
        .FREQ_OUT(FREQ_OUT)
    );

    // Clock generation
    initial CLK = 0;
    always #10 CLK = ~CLK; // 50MHz Clock, period = 20ns

    // Test scenarios
    initial begin
        // Initialize and reset
        RST_N = 0;
        INPUT = 0;
        #200; // Wait for a reset
        RST_N = 1;

        // Light Level Variation Test
        for(i = 0; i < 256; i = i + 1) begin
            INPUT = i;
            #4000; // Wait time between light level changes



            while (freq_change_count < 12) begin
                #10;
                if (FREQ_OUT != prev_freq_out) begin
                    freq_change_count = freq_change_count + 1;
                    prev_freq_out = FREQ_OUT;
                end
            end
            freq_change_count = 0;
        end

        $finish; // End simulation
    end

    // Calculate the Output Frequency vs Light Level
    time last_posedge_time = 0;
    real time_in_seconds = 0;
    integer file;

    initial begin
        file = $fopen("sim_out/frequency_module_tb.txt", "w");
    end
    always @(posedge FREQ_OUT) begin
        if (last_posedge_time != 0) begin
            time_in_seconds = ($time - last_posedge_time) / 1e9;
            $fwrite(file, "Light %d, Time=%f, Frequency=%f\n", INPUT, $realtime, 1.0 / time_in_seconds);
        end
        last_posedge_time = $time;
    end
    final begin
        $fclose(file);
    end


endmodule
