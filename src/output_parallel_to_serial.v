module output_parallel_to_serial #(
    parameter WIDTH_INPUT = 128
)(
    input wire CLK,
    input wire RST_N,
    input wire [(WIDTH_INPUT-1):0] data_in,
    output reg data_out
);

    // A Demux is used to select the correct output
    // From the data_in and pass it to the data_out
    reg[$clog2(WIDTH_INPUT):0] bit_select;

    always @(posedge CLK) begin
        if (~RST_N) begin
            bit_select <= 0;
            data_out <= 0;
        end else begin
            if(bit_select == WIDTH_INPUT-1) begin
                bit_select <= 0;
            end else begin
                bit_select <= bit_select + 1;
            end
            data_out <= data_in[bit_select];
        end
    end
endmodule
