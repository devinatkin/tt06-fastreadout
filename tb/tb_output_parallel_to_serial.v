`timescale 1ns / 1ps

module output_parallel_to_serial_tb;

parameter WIDTH_INPUT = 128;
reg CLK;
reg RST_N;
reg [WIDTH_INPUT-1:0] data_in;
wire data_out;

// Instantiate the Module Under Test (MUT)
output_parallel_to_serial #(
    .WIDTH_INPUT(WIDTH_INPUT)
) MUT (
    .CLK(CLK),
    .RST_N(RST_N),
    .data_in(data_in),
    .data_out(data_out)
);

// Clock generation
initial begin
    CLK = 0;
    forever #10 CLK = ~CLK; // Generate a clock with a period of 20 ns
end

integer i;

// Test Stimuli
initial begin
    // Initialize Inputs
    RST_N = 0; // Assert reset
    data_in = 0;
    i = 0;
    #100; // Wait for 100 ns to simulate reset duration
    RST_N = 1; // De-assert reset
    data_in = 128'hA5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5; // Example data
    $display("Test started (output_parallel_to_serial_tb.v)");
    for (i = 0; i < WIDTH_INPUT; i = i + 1) begin
        #20; // Wait for 20 ns
        
        if (data_in[i] !== data_out) begin
            $error("Test failed at i = %0d", i);
            $finish; // Terminate simulation
        end
    end
    for (i = 0; i < WIDTH_INPUT; i = i + 1) begin
        #20; // Wait for 20 ns
        
        if (data_in[i] !== data_out) begin
            $error("Test failed at i = %0d", i);
            $finish; // Terminate simulation
        end
    end
    $display("All tests passed (output_parallel_to_serial_tb.v)");

    #100; // Additional delay before ending simulation
    $finish; // Terminate simulation
end


endmodule
