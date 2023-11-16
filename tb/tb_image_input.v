module tb_image_input #(parameter IMAGE_SIZE = 1024, IMAGE_FILE= "tb/output.txt", OUTPUT_FILE = "tb/verilog_output.txt") ;

    // Parameters
    // Width of the shift register is 8-bits per pixel
    localparam WIDTH = IMAGE_SIZE * 8;

    // Inputs
    reg clk;
    reg reset_n;
    reg shift_in;
    reg load;
    reg [WIDTH-1:0] data_in;
    reg [7:0] temp;
    reg [WIDTH-1:0] temp_out;
    // Outputs
    wire [WIDTH-1:0] data_out;

    // File
    integer file;
    integer output_file;
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
        $display("Image Output Testbench started successfully");
        // Initialize inputs
        clk = 0;
        reset_n = 0;
        shift_in = 0;
        load = 0;
        data_in = 0;

        // Wait for 100 ns for global reset to finish
        #100;
        reset_n = 1;

        // Open the file
        file = $fopen(IMAGE_FILE, "r");
        if (file == 0) begin
            $display("Error opening file: %s", IMAGE_FILE);
            $fatal;
        end

        // Open the output file
        output_file = $fopen(OUTPUT_FILE, "w");
        if (output_file == 0) begin
            $display("Error opening output file");
            $fatal;
        end
        // The File is formatted as IMAGE_SIZE 8-bit hex values per line, with IMAGE_SIZE lines
        // Each element is a pixel seperated by a space

        // Start testing

        // For each line
        for (int i = 0; i < IMAGE_SIZE; i = i + 1) begin
            // Read in the next line
            for (int j = 0; j < IMAGE_SIZE; j = j + 1) begin
                if (!$fscanf(file, "%h ", temp)) begin
                    $display("Error reading file");
                    $fatal;
                end
                data_in = {data_in[WIDTH-9:0], temp};
                
            end

            // Shift in the line
            for (int j = IMAGE_SIZE*8 - 1; j >= 0; j = j - 1) begin
                // Shift in 1 into the ith position
                shift_in = data_in[j];
                #PERIOD;
            end

            // Load the line
            load = 1;
            #PERIOD;
            load = 0;
            // $display("Line # %d \n %b", i, data_out);
            // Write the line to the output file


            // Check that the data_out is correct i.e. it maches the data_in
            if (data_out != data_in) begin
                $display("Error: data_out does not match data_in");
                $display("data_in: %b", data_in);
                $display("data_out: %b", data_out);
                $fatal;
            end

            temp_out = data_out;
            for (int j = 0; j < IMAGE_SIZE; j = j + 1) begin

                $fwrite(output_file, "%h ", temp_out[7:0]);
                temp_out = temp_out >> 8;
            end
        end


        // End of test
        $display("Image Output Testbench finished successfully");
        $finish;
    end

    // Clock generation
    always #5 clk = ~clk;

endmodule