`timescale 1ns / 1ps

module frequency_measure_tb;

    parameter CLOCK_FREQ = 50_000_000; // Clock frequency in Hz
    parameter LOW_FREQ = 1_000.333;
    parameter HIGH_FREQ = 20_000_000;
    parameter INPUT_BITS = 8;

    reg CLK;
    reg RST_N;
    reg [INPUT_BITS-1:0] light_level;
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
    ) frequency_generation (
        .CLK(CLK),
        .RST_N(RST_N),
        .INPUT_VALUE(light_level),
        .FREQ_OUT(FREQ_OUT)
    );

    // Outputs
    wire [31:0] TIME_HIGH;
    wire [31:0] TIME_LOW;
    wire [31:0] PERIOD;
    wire PULSE;
    // Instantiate the Unit Under Test (UUT)
    frequency_counter frequency_measurement (
        .CLK(CLK),
        .RST_N(RST_N),
        .FREQ_IN(FREQ_OUT),
        .TIME_HIGH(TIME_HIGH),
        .TIME_LOW(TIME_LOW),
        .PERIOD(PERIOD),
        .PULSE(PULSE)
    );

    // Clock generation
    initial CLK = 0;
    always #10 CLK = ~CLK; // 50MHz Clock, period = 20ns

    // Test scenarios
    initial begin
        // Initialize and reset
        RST_N = 0;
        light_level = 0;
        #200; // Wait for a reset
        RST_N = 1;

        // Light Level Variation Test
        for(i = 0; i < 256; i = i + 1) begin
            light_level = i;
            #1;
            @(posedge PULSE);
            @(posedge PULSE);
            @(posedge PULSE);
            @(posedge PULSE);

        end

        $finish; // End simulation
    end

    integer file;

    initial begin
        file = $fopen("sim_out/frequency_measure_tb.txt", "w");
    end
    always @(posedge PULSE) begin
            $fwrite(file, "At time %t, TIME_HIGH = %d, TIME_LOW = %d, PERIOD = %d, light_level = %d\n", $time, TIME_HIGH, TIME_LOW, PERIOD, light_level);

    end
    final begin
        $fclose(file);
    end

endmodule
