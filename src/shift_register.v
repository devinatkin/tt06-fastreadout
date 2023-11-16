module shift_register #(parameter WIDTH = 512) (
    input wire clk,
    input wire reset_n,
    input wire shift_in,
    input wire load,
    input wire [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);

    reg [WIDTH-1:0] shift_reg;

    always @(posedge clk) begin
        if (!reset_n) begin
            shift_reg <= 'd0;
        end else begin
            if (load) begin
                data_out <= shift_reg;
                shift_reg <= 'd0;
            end else begin
                shift_reg <= {shift_reg[WIDTH-2:0], shift_in};
            end
        end
    end

    always @(posedge clk) begin

    end

endmodule