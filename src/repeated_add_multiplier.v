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
    reg [WIDTH_IN-1:0] counter;
    reg [WIDTH_IN-1:0] add;
    always @(posedge CLK) begin
        if (!RST_N) begin
            sum <= 0;
            product <= 0;
            counter <= 0;
            add <= 0;
        end else begin
            // The inner count will count the number of times the multiplier is added to the sum
            // When the inner counter is equal to zero the sum will be set to the output product

            if (counter == 0) begin
                product <= sum; // Set the product to the sum
                sum <= 0;
                if (multiplier > multiplicand) begin
                    add <= multiplier;
                    counter <= multiplicand;
                end else begin
                    counter <= multiplier;
                    add <= multiplicand;
                end

            end else begin
                sum <= sum + add;
                counter <= counter - 1;
            end
        end
    end

endmodule
