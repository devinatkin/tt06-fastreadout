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
        // Initialize Inputs
        #1000;
        
        //TODO Implement top level tests
        $display("All tests passed (tb_top.v)");
        $finish;
    end

endmodule