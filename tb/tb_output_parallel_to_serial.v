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

// Test Stimuli
initial begin
    // Initialize Inputs
    RST_N = 0; // Assert reset
    data_in = 0;

    #100; // Wait for 100 ns to simulate reset duration
    RST_N = 1; // De-assert reset
    data_in = 128'hA5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5; // Example data
    #20; // Wait for 20 ns to ensure the data is stable
    data_in = 128'h00000000000000000000000000000000; // Example data
    #12800; // Wait for the entire data to be shifted out (128 bits * 10ns)

    // You can add more test cases here with different `data_in` values

    #100; // Additional delay before ending simulation
    $finish; // Terminate simulation
end

// Optional: Monitor Outputs
initial begin
    $monitor("Time = %t, Reset = %b, Data Out = %b", $time, RST_N, data_out);
end

endmodule
