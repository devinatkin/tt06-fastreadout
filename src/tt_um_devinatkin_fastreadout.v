module tt_um_devinatkin_fastreadout
(
    input  logic [7:0] ui_in,    // Dedicated inputs - Inputs to the Shift Register
    output logic [7:0] uo_out,   // Dedicated outputs - Outputs from the Packet Router
    input  logic [7:0] uio_in,   // IOs: Bidirectional Input path
    output logic [7:0] uio_out,  // IOs: Bidirectional Output path - Outputs from the Packet Router
    output logic [7:0] uio_oe,   // IOs: Bidirectional Enable path
    input  logic       ena,      // will go high when the design is enabled
    input  logic       clk,      // clock
    input  logic       rst_n     // reset_n - low to reset
);
    // 8-bits per pixel, 128 pixels
    localparam pixels = 128;
    localparam bits_per_pixel = 8;
    localparam SHIFT_WIDTH = pixels * bits_per_pixel;

    // Frequency Module Parameters
    parameter CLOCK_FREQ = 50_000_000;
    parameter LOW_FREQ = 1_000;
    parameter HIGH_FREQ = 20_000_000;
    parameter INPUT_BITS = 8;

    // Row Shift Register Inputs
    wire DATA_IN1 = ui_in[0];
    wire RCLK_1 = ui_in[1];
    wire LOAD_1 = ui_in[2];

    // Row Shift Register - Data Output
    wire [SHIFT_WIDTH-1:0] ROW_DATA;
    wire [pixels-1:0] PIXEL_ROW_DATA;

    // Column Shift Register Inputs
    wire DATA_IN2 = ui_in[3];
    wire RCLK_2 = ui_in[4];
    wire LOAD_2 = ui_in[5];

    // Column Shift Register - Data Output
    wire [SHIFT_WIDTH-1:0] COL_DATA;
    wire [pixels-1:0] PIXEL_COL_DATA;

    // Initial Verilog Code (Basically Garbage)
    reg [7:0] sum;       // Sum of ui_in and uio_in
    assign uo_out = sum; // Assign the sum to the output
    
    // Configure uio_oe to set the uio_in as inputs (active low)
    assign uio_oe = 8'b0;
    assign uio_out = 8'b0;
    

    // Row Data Flow Path
    // Outside of the chip
    // - Data is shifted in to the row shift register
    // Shift Register
    // - Data is loaded into the shift register
    // - Data is fed directly into the frequency module
    // Frequency Module
    // - The frequency module will output a frequency based on the input data
    // Frequency Counter
    // - The frequency counter will measure the frequency of the output from the frequency module
    // - The frequency counter will output the time high, time low, and period of the frequency signal
    // Output Module (Not Implemented)
    // - The output module will take the time high, time low, and period of the frequency signal
    // - The output module will make them available on the chip output pins
    shift_register #(.WIDTH(SHIFT_WIDTH)) Row_Register_input (
        .clk(RCLK_1),
        .reset_n(rst_n),
        .shift_in(DATA_IN1),
        .load(LOAD_1),
        .data_out(ROW_DATA)
    );

    genvar i;
    generate
        for (i = 0; i < pixels; i = i + 1) begin : row_loop
            frequency_module #(
                .CLOCK_FREQ(CLOCK_FREQ),
                .LOW_FREQ(LOW_FREQ),
                .HIGH_FREQ(HIGH_FREQ),
                .INPUT_BITS(INPUT_BITS)
             
            ) pretend_row_pixel (
                .CLK(CLK),
                .RST_N(RST_N),
                .INPUT_VALUE(ROW_DATA[i:i+(bits_per_pixel-1)]),
                .freq_out(PIXEL_ROW_DATA[i])
            );

            frequency_counter #(
                .CLOCK_FREQ(CLOCK_FREQ)
            ) row_counter (
                .CLK(CLK),
                .RST_N(RST_N),
                .FREQ_IN(PIXEL_ROW_DATA[i]),
                .TIME_HIGH(),
                .TIME_LOW(),
                .PERIOD()
            );
        end
    endgenerate

    // Column Data Flow Path
    // Outside of the chip
    // - Data is shifted in to the column shift register
    // Shift Register
    // - Data is loaded into the shift register
    // - Data is fed directly into the frequency module
    // Frequency Module
    // - The frequency module will output a frequency based on the input data
    // Frequency Counter
    // - The frequency counter will measure the frequency of the output from the frequency module
    // - The frequency counter will output the time high, time low, and period of the frequency signal
    // Output Module (Not Implemented)
    // - The output module will take the time high, time low, and period of the frequency signal
    // - The output module will make them available on the chip output pins

    shift_register #(.WIDTH(SHIFT_WIDTH)) Col_Register_input (
        .clk(RCLK_2),
        .reset_n(rst_n),
        .shift_in(DATA_IN2),
        .load(LOAD_2),
        .data_out(COL_DATA)
    );

    generate
        for (i = 0; i < pixels; i = i + 1) begin : col_loop
            frequency_module #(
                .CLOCK_FREQ(CLOCK_FREQ),
                .LOW_FREQ(LOW_FREQ),
                .HIGH_FREQ(HIGH_FREQ),
                .INPUT_BITS(INPUT_BITS)
            ) pretend_col_pixel (
                .CLK(CLK),
                .RST_N(RST_N),
                .INPUT_VALUE(COL_DATA[i:i+(bits_per_pixel-1)]),
                .freq_out(PIXEL_COL_DATA[i])
            );

            frequency_counter #(
                .CLOCK_FREQ(CLOCK_FREQ)
            ) col_counter (
                .CLK(CLK),
                .RST_N(RST_N),
                .FREQ_IN(PIXEL_COL_DATA[i]),
                .TIME_HIGH(),
                .TIME_LOW(),
                .PERIOD()
            );
        end

    endgenerate

    // Clocked Adder Logic with Synchronous Reset
    always @(posedge clk) begin
        if (!rst_n) begin
            sum <= 8'b0;
        end else if (ena) begin
            sum <= ui_in + uio_in;  // Capture the sum if enabled
        end
    end
endmodule