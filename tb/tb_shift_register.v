module tb_shift_register;

    // Parameters
    localparam WIDTH = 512;

    // Inputs
    reg clk;
    reg reset_n;
    reg shift_in;
    reg load;
    reg [WIDTH-1:0] data_in;

    // Outputs
    wire [WIDTH-1:0] data_out;

    // Instantiate the Unit Under Test (UUT)
    shift_register #(.WIDTH(WIDTH)) uut (
        .clk(clk),
        .reset_n(reset_n),
        .shift_in(shift_in),
        .load(load),
        .data_out(data_out)
    );

    // Clock period definitions
    parameter PERIOD = 10;

    // Initial stimulus
    initial begin
        $display("Shift Register Testbench started successfully");
        // Initialize inputs
        clk = 0;
        reset_n = 0;
        shift_in = 0;
        load = 0;

        // Wait for 100 ns for global reset to finish
        #100;
        reset_n = 1;
        // Start testing
        for (int i = 0; i < WIDTH; i = i + 1) begin
            // Shift in 1 into the ith position
            shift_in = 1;
            #PERIOD;
            shift_in = 0;

            // Wait for the shifting to finish (i-1 cycles)
            for (int j = 0; j < i; j = j + 1) begin
                #PERIOD;
            end

            // Load the shift register
            load = 1;
            #PERIOD;
            load = 0;

            // Check the output has one 1 in the ith position
            if (data_out[i] != 1) begin
                $display("Testbench failed at finishi = %d", i);
                $fatal;
            end
            // Check that the rest of the output is 0
            for (int j = i + 1; j < WIDTH; j = j + 1) begin
                if (data_out[j] != 0) begin
                    $display("Testbench failed at j = %d", j);
                    $fatal;
                end
            end
            
            #PERIOD;
        end

        // End of test
        $display("Shift Register Testbench finished successfully");
        $finish;
    end

    // Clock generation
    always #5 clk = ~clk;

endmodule