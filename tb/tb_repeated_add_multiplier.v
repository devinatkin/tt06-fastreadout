`timescale 1ns / 1ps

module repeated_add_multiplier_tb;

    // Parameters of the DUT
    parameter WIDTH_IN = 8;
    parameter WIDTH_OUT = 16;

    // Testbench Variables
    reg CLK;
    reg RST_N;
    reg [WIDTH_IN-1:0] multiplicand;
    reg [WIDTH_IN-1:0] multiplier;
    wire [WIDTH_OUT-1:0] product;

    // Instantiate the DUT
    repeated_add_multiplier #(
        .WIDTH_IN(WIDTH_IN),
        .WIDTH_OUT(WIDTH_OUT)
    ) DUT (
        .CLK(CLK),
        .RST_N(RST_N),
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .product(product)
    );

    // Clock Generation
    initial CLK = 0;
    always #10 CLK = ~CLK; // Generate a clock with a period of 20 ns

    // Initial Block for Setup and Stimulus
    initial begin
        // Initialize Inputs
        RST_N = 0; multiplicand = 0; multiplier = 0;

        // Reset the system
        #100; 
        RST_N = 1; // Release reset

        // Test Case 1: Simple Multiplication
        #20; multiplicand = 3; multiplier = 4; // Expect product = 12 after some cycles

        // Test Case 2: Zero Multiplication
        #100; multiplicand = 0; multiplier = 5; // Expect product = 0

        // Test Case 3: Multiplication with Maximum Values
        #100; multiplicand = 8'hFF; multiplier = 8'hFF; // Test with maximum possible values for 8-bit input

        // Add more test cases as needed

        // End simulation
        #500;
        $finish;
    end

    // Monitoring
    initial begin
        $monitor("Time=%t, Reset=%b, Multiplicand=%d, Multiplier=%d, Product=%d", $time, RST_N, multiplicand, multiplier, product);
    end

endmodule
