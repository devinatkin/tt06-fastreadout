`timescale 1ns / 1ps

module repeated_add_multiplier_tb;

    // Parameters of the DUT
    parameter WIDTH_IN = 8;
    parameter WIDTH_OUT = 16;
    parameter CLK_PERIOD = 20;
    // Testbench Variables
    reg CLK;
    reg RST_N;
    reg [WIDTH_IN-1:0] multiplicand;
    reg [WIDTH_IN-1:0] multiplier;
    wire [WIDTH_OUT-1:0] product;

    integer i, j;

    //Start of multiplication time
    time startMultiplication = 0;
    time endMultiplication = 0;
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

    always #(CLK_PERIOD/2) CLK = ~CLK;

    // Initial Block for Setup and Stimulus
    initial begin
        // Initialize Inputs
        RST_N = 0; multiplicand = 0; multiplier = 0;

        // Reset the system
        #(10 * CLK_PERIOD); // Wait for 10 clock cycles

        RST_N = 1; // Release reset

        // Loop through all possible values of multiplicand and multiplier 0 to 255
        // After each set value of multiplicand and multiplier, wait for multiplier+1 number of clock cycles
        
        for(i = 0; i < 256; i = i + 1) begin
            for(j = 0; j < 256; j = j + 1) begin
                multiplicand = i;
                multiplier = j;
                // Display the values of multiplicand and multiplier
                $display("Time=%t, Multiplicand=%d, Multiplier=%d", $time, multiplicand, multiplier);
                // Start the multiplication time
                startMultiplication = $realtime;

                // Wait for the product to be correct
                while (product != multiplicand * multiplier) begin
                    #1;
                end

                // End the multiplication time
                endMultiplication = $realtime;

                // Display the time taken for multiplication
                $display("Time=%t, Multiplication Time=%t", $time, endMultiplication - startMultiplication);
                // Calculate the number of clock cycles taken for multiplication
                $display("Time=%t, Clock Cycles=%d", $time, (endMultiplication - startMultiplication) / CLK_PERIOD);
            end
        end
        // End simulation
        #500;
        $finish;
    end


endmodule
