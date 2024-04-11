`timescale 1ns/1ps

module tb_frequency_counter();

    // Parameters
    parameter CLOCK_FREQ = 50_000_000; // 50 MHz
    parameter CLOCK_PERIOD = 1000 / (CLOCK_FREQ / 1_000_000); // Clock period in nanoseconds
    parameter COUNTER_BITS = 16; // Number of bits in the counter
    // Inputs
    reg CLK;
    reg RST_N;
    reg FREQ_IN;

    // Outputs
    wire [31:0] TIME_HIGH;
    wire [31:0] TIME_LOW;
    wire [31:0] PERIOD;
    wire PULSE;
    integer i;
    integer j;
    integer previous_j;
    // Instantiate the Unit Under Test (UUT)
    frequency_counter #(
        .COUNTER_BITS(COUNTER_BITS)
    ) uut (
        .CLK(CLK),
        .RST_N(RST_N),
        .FREQ_IN(FREQ_IN),
        .TIME_HIGH(TIME_HIGH),
        .TIME_LOW(TIME_LOW),
        .PERIOD(PERIOD),
        .PULSE(PULSE)
    );

    // Clock generation
    initial begin
        CLK = 0;
        forever #(CLOCK_PERIOD/2) CLK = ~CLK;
    end

    // Reset logic
    initial begin
        RST_N = 0;
        #100;                // Apply reset for 100 ns
        RST_N = 1;
    end

    // Stimulus: Simulate FREQ_IN signal
    initial begin
        // Initialize FREQ_IN
        FREQ_IN = 0;
        previous_j = 0;
        // Wait for reset deassertion
        @(posedge RST_N);

        $display("Starting test");
        // Test from time low/high 0 to 2^^31 - 1 clock cycles
        for (i = 1; i < 300; i = i + 1) begin
            for (j = 1; j < 300; j = j + 1) begin
                FREQ_IN = 0;

                #(i * CLOCK_PERIOD);
                FREQ_IN = 1;
                // Wait for j clock cycles
                #(j * CLOCK_PERIOD);
                
                $display("TIME_LOW: %d, TIME_HIGH: %d, PERIOD: %d", TIME_LOW, TIME_HIGH, PERIOD);
                // Check the output values
                if (TIME_LOW != i) begin
                    $error("TIME_LOW: Expected %d, Got %d", i, TIME_LOW);
                    $finish;
                end

                // TIME_HIGH will be for the previous cycle becuase it is updated on CLK posedge
                if (TIME_HIGH != (previous_j)) begin 
                    $error("TIME_HIGH: Expected %d, Got %d", j, TIME_HIGH);
                    $finish;
                end
                previous_j = j;
            end
        end

        
        // Add more patterns as needed to thoroughly test the counter

        // Finish simulation
        #(CLOCK_PERIOD*100);
        $finish;
    end


endmodule
