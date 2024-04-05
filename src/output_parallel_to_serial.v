module output_parallel_to_serial #(
    parameter WIDTH_INPUT = 128
)(
    input wire CLK,
    input wire RST_N,
    input wire [(WIDTH_INPUT-1):0] data_in,
    output wire data_out
);

    // Output Module
    // - Takes an input parallel data stream
    // - Outputs a serial data stream

    // - Load the data in into a register
    // - Shift the data through the register
    // - Output the data on the last bit of the register+

    reg [(WIDTH_INPUT-1):0] output_reg;

    always @(posedge CLK) begin
        if (~RST_N) begin
            output_reg <= 0;

        end else begin
            if(output_reg == 0) begin
                output_reg <= data_in;
            end else begin
                output_reg <= output_reg >> 1;
            end
        end
    end

    assign data_out = output_reg[0];
endmodule