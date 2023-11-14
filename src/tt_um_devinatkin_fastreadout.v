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

    // Initial Verilog Code (Basically Garbage)
    reg [7:0] sum;       // Sum of ui_in and uio_in
    assign uo_out = sum; // Assign the sum to the output
    
    // Configure uio_oe to set the uio_in as inputs (active low)
    assign uio_oe = 8'b0;

    // Clocked Adder Logic with Synchronous Reset
    always @(posedge clk) begin
        if (!rst_n) begin
            sum <= 8'b0;
        end else if (ena) begin
            sum <= ui_in + uio_in;  // Capture the sum if enabled
        end
    end
endmodule