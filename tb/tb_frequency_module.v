`timescale 1ns / 1ps

module frequency_module_tb;

    parameter CLOCK_FREQ = 50_000_000; // Clock frequency in Hz
    parameter LOW_FREQ = 1_000;
    parameter HIGH_FREQ = 20_000_000;
    parameter INPUT_BITS = 8;

    reg CLK;
    reg RST_N;
    reg [INPUT_BITS-1:0] INPUT;
    wire FREQ_OUT;

    // Instantiate the DUT
    frequency_module #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .LOW_FREQ(LOW_FREQ),
        .HIGH_FREQ(HIGH_FREQ),
        .INPUT_BITS(INPUT_BITS)
    ) DUT (
        .CLK(CLK),
        .RST_N(RST_N),
        .INPUT(INPUT),
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
        integer i;
        for(i = 0; i < 256; i = i + 1) begin
            INPUT = i;
            #1000; // Wait time between light level changes
        end

        $finish; // End simulation
    end

    // Monitoring
    initial begin
        $monitor("Time=%t, Reset=%b, Light Level=%d, Freq Out=%b", $time, RST_N, INPUT, FREQ_OUT);
    end

endmodule
