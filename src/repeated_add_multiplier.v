module repeated_add_multiplier #(
    parameter WIDTH_IN = 8,
    parameter WIDTH_OUT = 16

)(
    input wire CLK,
    input wire RST_N,
    input wire [WIDTH_IN-1:0] multiplicand,
    input wire [WIDTH_IN-1:0] multiplier,
    output reg [WIDTH_OUT-1:0] product
);

    reg [WIDTH_OUT-1:0] sum;
    reg [WIDTH_IN-1:0] inner_counter;

    always @(posedge CLK) begin
        if (!RST_N) begin
            sum <= 0;
            inner_counter <= 0;
            product <= 0;
        end else begin
            // The inner count will count the number of times the multiplier is added to the sum
            // When the inner counter is equal to zero the sum will be set to the output product

            if (inner_counter == 0) begin
                product <= sum; // Set the product to the sum
                sum <= 0; // Reset the sum
                inner_counter <= multiplier; // Set the inner counter to the multiplier

            end else begin
                sum <= sum + multiplicand;
                inner_counter <= inner_counter - 1;
            end
        end
    end

endmodule