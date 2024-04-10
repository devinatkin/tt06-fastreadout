module frequency_counter #(
    parameter COUNTER_BITS = 32
)(
    input wire CLK,          // System Clock
    input wire RST_N,        // Reset, active low
    input wire FREQ_IN,     // Frequency output from frequency_module to measure
    output reg [COUNTER_BITS-1:0] TIME_HIGH,  // Time in high state, in clock cycles
    output reg [COUNTER_BITS-1:0] TIME_LOW,   // Time in low state, in clock cycles
    output reg [COUNTER_BITS-1:0] PERIOD,      // Period of the frequency signal, in clock cycles
    output reg PULSE          // Pulse output, high for one clock cycle when the period is complete
);

// Internal signals to keep track of the current state and previous state of FREQ_IN
reg previous_freq_in;
// Temporal registers to calculate times and period
reg [COUNTER_BITS-1:0] high_counter, low_counter;

always @(posedge CLK) begin
    if (!RST_N) begin
        // Reset logic
        previous_freq_in <= 0;
        high_counter <= 0;
        low_counter <= 0;
        TIME_HIGH <= 0;
        TIME_LOW <= 0;
        PERIOD <= 0;
        PULSE <= 0;
    end else begin
        // Count high or low time based on the current state of FREQ_IN
        if (FREQ_IN == 1'b1) begin
            high_counter <= high_counter + 1;
            if (previous_freq_in == 1'b0) begin
                // Transition from low to high
                TIME_LOW <= low_counter;
                low_counter <= 0;  // Reset low counter after transition
            end
            PULSE <= 0;  // Reset pulse signal if not at the end of the period
        end else begin
            low_counter <= low_counter + 1;
            if (previous_freq_in == 1'b1) begin
                // Transition from high to low
                TIME_HIGH <= high_counter;
                high_counter <= 0;  // Reset high counter after transition
                PERIOD <= TIME_HIGH + TIME_LOW;  // Update period at the end of high state
                PULSE <= 1;  // Generate pulse at the end of the period
            end else begin
                PULSE <= 0;  // Reset pulse signal if not at the end of the period
            end
            
        end
        previous_freq_in <= FREQ_IN;  // Update the previous state for the next clock cycle

    end
end

endmodule
