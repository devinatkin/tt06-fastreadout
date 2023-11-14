module tb_top;

    // Inputs
    reg [7:0] ui_in;
    reg [7:0] uio_in;
    reg ena;
    reg clk;
    reg rst_n;

    // Outputs
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    // Instantiate the Unit Under Test (UUT)
    tt_um_devinatkin_fastreadout uut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Reset generation
    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        #10 rst_n = 1'b1;
    end

    // Stimulus
    initial begin
        // Test 1: ui_in = 8'b00000001, uio_in = 8'b00000010, ena = 1
        
        ui_in = 8'b00000001;
        uio_in = 8'b00000010;
        ena = 1;
        #20;
        if (uo_out !== 8'b00000011 ) $error("Test 1 failed");

        // Test 2: ui_in = 8'b11111111, uio_in = 8'b00000000, ena = 1
        ui_in = 8'b11111111;
        uio_in = 8'b00000000;
        ena = 1;
        #20;
        if (uo_out !== 8'b11111111) $error("Test 2 failed");

        // Test 3: ui_in = 8'b00000000, uio_in = 8'b11111111, ena = 1
        ui_in = 8'b00000000;
        uio_in = 8'b11111111;
        ena = 1;
        #20;
        if (uo_out !== 8'b11111111 ) $error("Test 3 failed");

        // Test 4: ui_in = 8'b00000000, uio_in = 8'b00000000, ena = 0
        ui_in = 8'b00000000;
        uio_in = 8'b00000000;
        ena = 1;
        #20;
        if (uo_out !== 8'b00000000 ) $error("Test 4 failed");

        // Test 5: ui_in = 8'b00000000, uio_in = 8'b00000000, ena = 1
        ui_in = 8'b00000000;
        uio_in = 8'b00000000;
        ena = 1;
        #20;
        if (uo_out !== 8'b00000000 ) $error("Test 5 failed");

        // Test 6: ui_in = 8'b11111111, uio_in = 8'b11111111, ena = 1
        ui_in = 8'b11111111;
        uio_in = 8'b11111111;
        ena = 1;
        #20;
        if (uo_out !== 8'b11111110 ) $error("Test 6 failed");

        $display("All tests passed");
        $finish;
    end

endmodule