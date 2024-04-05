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
    // 8-bits per pixel, 64 pixels
    localparam pixels = 64;
    localparam bits_per_pixel = 8;
    localparam SHIFT_WIDTH = pixels * bits_per_pixel;

    // Frequency Module Parameters
    parameter CLOCK_FREQ = 50_000_000;
    parameter LOW_FREQ = 1_000.3;
    parameter HIGH_FREQ = 20_000_000;
    parameter INPUT_BITS = 8;

    parameter counter_bits = 16;
    parameter counter_variable_size = counter_bits * pixels;
    parameter number_of_outputs_for_rc = 8;


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

    wire [counter_variable_size-1:0] COL_TIME_HIGH;
    wire [counter_variable_size-1:0] COL_TIME_LOW;
    wire [counter_variable_size-1:0] COL_PERIOD;

    wire [counter_variable_size-1:0] ROW_TIME_HIGH;
    wire [counter_variable_size-1:0] ROW_TIME_LOW;
    wire [counter_variable_size-1:0] ROW_PERIOD;

    wire [7:0] DATA_BUS_COL_OUT;
    wire [7:0] DATA_BUS_ROW_OUT;
    // Configure uio_oe to set the uio_s (active low)
    assign uio_oe = 8'b11111111;
    assign uo_out = DATA_BUS_COL_OUT;
    assign uio_out = DATA_BUS_ROW_OUT;
    

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
                .CLK(clk),
                .RST_N(rst_n),
                .INPUT_VALUE(ROW_DATA[(i*bits_per_pixel)+(bits_per_pixel-1):(i*bits_per_pixel)]),
                .FREQ_OUT(PIXEL_ROW_DATA[i])
            );

            frequency_counter #(
                .COUNTER_BITS(counter_bits)
            ) row_counter (
                .CLK(clk),
                .RST_N(rst_n),
                .FREQ_IN(PIXEL_ROW_DATA[i]),
                .TIME_HIGH(ROW_TIME_HIGH[(i*counter_bits)+(counter_bits-1):(i*counter_bits)]),
                .TIME_LOW(ROW_TIME_LOW[(i*counter_bits)+(counter_bits-1):(i*counter_bits)]),
                .PERIOD(ROW_PERIOD[(i*counter_bits)+(counter_bits-1):(i*counter_bits)])
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
                .CLK(clk),
                .RST_N(rst_n),
                .INPUT_VALUE(COL_DATA[(i*bits_per_pixel)+(bits_per_pixel-1):(i*bits_per_pixel)]),
                .FREQ_OUT(PIXEL_COL_DATA[i])
            );

            frequency_counter #(
                .COUNTER_BITS(counter_bits)
            ) col_counter (
                .CLK(clk),
                .RST_N(rst_n),
                .FREQ_IN(PIXEL_COL_DATA[i]),
                .TIME_HIGH(COL_TIME_HIGH[(i*counter_bits)+(counter_bits-1):(i*counter_bits)]),
                .TIME_LOW(COL_TIME_LOW[(i*counter_bits)+(counter_bits-1):(i*counter_bits)]),
                .PERIOD(COL_PERIOD[(i*counter_bits)+(counter_bits-1):(i*counter_bits)])
            );
        end
    endgenerate
    // Output Column Periods to 8 Column Output Pins (Pixels/ Number of Outputs) Gives the number of parallel to serial outputs
    // Output Row Periods to 8 Row Output Pins (Pixels/ Number of Outputs) Gives the number of parallel to serial outputs
    // Slices will be Number of Pixels / Number of Outputs Pixels per output, and each pixel produces counter bits of data
    localparam pixels_per_output = pixels / number_of_outputs_for_rc;
    localparam bits_per_output = counter_bits * pixels_per_output;
    generate
        for (i = 0; i < 8; i = i + 1) begin : output_loop
            output_parallel_to_serial #(
                .WIDTH_INPUT(bits_per_output)
            ) output_inst_col (
                .CLK(clk),
                .RST_N(rst_n),
                .data_in({COL_PERIOD[(i*bits_per_output)+(bits_per_output-1):(i*bits_per_output)]}),
                .data_out(DATA_BUS_COL_OUT[i])
            );

            output_parallel_to_serial #(
                .WIDTH_INPUT(bits_per_output)
            ) output_inst_row (
                .CLK(clk),
                .RST_N(rst_n),
                .data_in({ROW_PERIOD[(i*bits_per_output)+(bits_per_output-1):(i*bits_per_output)]}),
                .data_out(DATA_BUS_ROW_OUT[i])
            );
        end

    endgenerate


endmodule
