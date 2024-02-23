// The Frequency Module in this circumstance acts as a pretend pixel with the 8-bits input representing
// a light level on a pixel. The pixel cell at a higher level will output both a row and column
// based on a select input. 

// The frequency module will take
// The System CLK as input
// The System RST_N as input
// The pixel 'light' input as INPUT

// Parameters defining the
// low light frequency, LOW_FREQ
// high light frequency, HIGH_FREQ
// input clock frequency, CLK

// The operation of this module will be as follows

// Counter Register will be large enough to toggle at the low frequency considering the clk speed.
// bit count will be Max(LOG_2(CLK/LOW_FREQ))

// The register will be set starting at the LOW_FREQ value for light = 0
// The value will then be decreased based on increases to the light value.
// Such that at Light_Max 2^Size of Light Input the output is roughly at the high frequency.
// The counter value at maximum light value will be Max(LOG_2(CLK/HIGH_FREQ))

// The counter set value will need to change by
// ((Max(LOG_2(CLK/LOW_FREQ)) - Max(LOG_2(CLK/HIGH_FREQ))) / 2 ^ Light_Max

module frequency_module #(
    parameter CLOCK_FREQ = 50_000_000, // Clock Frequency in Hz
    parameter LOW_FREQ = 1_000,
    parameter HIGH_FREQ = 20_000_000
    parameter INPUT_BITS = 8
)(
    input wire CLK,
    input wire RST_N,
    input wire [INPUT_BITS-1:0] INPUT,
    output reg FREQ_OUT
);

    localparam COUNTER_SIZE = $clog2(CLOCK_FREQ/LOW_FREQ);
    localparam MAX_COUNTER_VALUE = $floor(CLOCK_FREQ/LOW_FREQ);
    localparam MIN_COUNTER_VALUE = $max()

endmodule
