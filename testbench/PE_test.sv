module PE_tb;

    // Clock and reset signals
    logic clk;
    logic reset;

    // Inputs to the PE
    logic signed [15:0] data_tile_i [0:5][0:5];
    logic data_valid_i;
    logic [8:0] data_x_index_i;
    logic [8:0] data_y_index_i;

    logic signed [15:0] weight_tile_i [0:5][0:5];
    logic weight_valid_i;
    logic weight_size_type_i;
    logic [7:0] weight_od_i;

    // Outputs from the PE
    logic signed [15:0] result_tile_o [0:5][0:5];
    logic signed [7:0] result_od_o;
    logic signed [8:0] result_i_o [0:5][0:5];
    logic signed [8:0] result_j_o [0:5][0:5];
    logic signed result_valid_o;

    logic signed [15:0] data_tile_reg_o [0:5][0:5];
    logic data_valid_o;
    logic [8:0] data_x_index_o;
    logic [8:0] data_y_index_o;

    logic signed [15:0] weight_tile_reg_o [0:5][0:5];
    logic weight_valid_o;
    logic weight_size_type_o;
    logic [7:0] weight_od_o;

    // Instantiate the PE module
    PE uut (
        .clk(clk),
        .reset(reset),
        .data_tile_i(data_tile_i),
        .data_valid_i(data_valid_i),
        .data_x_index_i(data_x_index_i),
        .data_y_index_i(data_y_index_i),
        .weight_tile_i(weight_tile_i),
        .weight_valid_i(weight_valid_i),
        .weight_size_type_i(weight_size_type_i),
        .weight_od_i(weight_od_i),
        .result_tile_o(result_tile_o),
        .result_od_o(result_od_o),
        .result_i_o(result_i_o),
        .result_j_o(result_j_o),
        .result_valid_o(result_valid_o),
        .data_tile_reg_o(data_tile_reg_o),
        .data_valid_o(data_valid_o),
        .data_x_index_o(data_x_index_o),
        .data_y_index_o(data_y_index_o),
        .weight_tile_reg_o(weight_tile_reg_o),
        .weight_valid_o(weight_valid_o),
        .weight_size_type_o(weight_size_type_o),
        .weight_od_o(weight_od_o)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Stimulus
    initial begin
        // Initialize inputs
        reset = 1;
        data_valid_i = 0;
        weight_valid_i = 0;
        data_x_index_i = 0;
        data_y_index_i = 0;
        weight_od_i = 0;
        weight_size_type_i = 0;
        
        // Reset de-assertion
        #20 reset = 0;

        // Apply data and weight tiles
        data_valid_i = 1;
        weight_valid_i = 1;
        data_x_index_i = 9'd10;
        data_y_index_i = 9'd15;
        weight_od_i = 8'd3;
        weight_size_type_i = 1'b0; // Testing with 1*1, 6*6 size

        // Load example data into the data and weight tiles
        for (int i = 0; i < 6; i++) begin
            for (int j = 0; j < 6; j++) begin
                data_tile_i[i][j] = 2; // Example pattern
            end
        end
        
        for (int i = 0; i < 6; i++) begin
            for (int j = 0; j < 6; j++) begin
                weight_tile_i[i][j] = 3; // Example pattern
            end
        end

        // Hold input signals for a few cycles
        #40;
        data_valid_i = 0;
        weight_valid_i = 0;

        // Wait and observe output
        #100;
        $finish;
    end

endmodule