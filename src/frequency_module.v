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
    parameter HIGH_FREQ = 20_000_000,
    parameter INPUT_BITS = 8
)(
    input wire CLK,
    input wire RST_N,
    input wire [INPUT_BITS-1:0] INPUT_VALUE,
    output reg FREQ_OUT
);

    localparam COUNTER_SIZE = $clog2($rtoi(CLOCK_FREQ/(2*LOW_FREQ)));
    localparam integer MAX_COUNTER_VALUE = $rtoi($floor(CLOCK_FREQ/(2*LOW_FREQ)));
    localparam integer MIN_COUNTER_VALUE = $rtoi($floor(CLOCK_FREQ/(2*HIGH_FREQ)));
    localparam [INPUT_BITS-1:0] COUNTER_SET_STEP = $rtoi((MAX_COUNTER_VALUE - MIN_COUNTER_VALUE) / ((2 ** INPUT_BITS)-1));
    reg [COUNTER_SIZE-1:0] counter;
    reg [COUNTER_SIZE-1:0] counter_set;

    reg [COUNTER_SIZE-1:0] counter_set_step;
    
    repeated_add_multiplier #(
        .WIDTH_IN(INPUT_BITS),
        .WIDTH_OUT(COUNTER_SIZE)
    ) multiplier_inst (
        .CLK(CLK),
        .RST_N(RST_N),
        .multiplicand(COUNTER_SET_STEP),
        .multiplier(INPUT_VALUE),
        .product(counter_set_step)
    );

    always @(posedge CLK) begin
        if(!RST_N) begin
            counter <= 0;
            counter_set <= 0;
            FREQ_OUT <= 0;
        end else begin    
            if (counter == counter_set) begin
                FREQ_OUT <= !FREQ_OUT;
                counter_set <= MAX_COUNTER_VALUE - counter_set_step;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
