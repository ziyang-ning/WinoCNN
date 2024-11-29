module PE_tb;

    // Clock and reset signals
    logic clk;
    logic reset;

    // Inputs to the PE
    logic signed [13:0] data_tile_i [0:5][0:5];
    logic data_valid_i;
    logic [8:0] data_x_index_i;
    logic [8:0] data_y_index_i;

    logic signed [11:0] weight_tile_i [0:5][0:5];
    logic weight_valid_i;
    logic weight_size_type_i;
    logic [7:0] weight_od_i;

    // Outputs from the PE
    logic signed [11:0] result_tile_o [0:5][0:5];
    logic signed [7:0] result_od_o;
    logic signed [8:0] result_i_o [0:5][0:5];
    logic signed [8:0] result_j_o [0:5][0:5];
    logic signed result_valid_o;

    logic signed [13:0] data_tile_reg_o [0:5][0:5];
    logic data_valid_o;
    logic [8:0] data_x_index_o;
    logic [8:0] data_y_index_o;

    logic signed [11:0] weight_tile_reg_o [0:5][0:5];
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


    // task load_tile_from_file(
    //     input string file_name,
    //     input int bit_width, // Added argument for bit width
    //     output logic signed [13:0] tile [0:5][0:5]
    // );
    //     int file;
    //     int row, col;
    //     int value;
    //     file = $fopen(file_name, "r");
    //     if (file == 0) begin
    //         $fatal("Error: Could not open file %s", file_name);
    //     end
    //     for (row = 0; row < 6; row++) begin
    //         for (col = 0; col < 6; col++) begin
    //             if (!$feof(file)) begin
    //                 $fscanf(file, "%d", value);
    //                 tile[row][col] = value >>> (14 - bit_width); // Adjust value width
    //             end else begin
    //                 $fatal("Error: Unexpected end of file in %s", file_name);
    //             end
    //         end
    //     end
    //     $fclose(file);
    // endtask

    // Stimulus
    int file;
    int row, col;
    int value;
    logic signed [13:0] tile [0:5][0:5];
    logic signed [11:0] tile_2 [0:5][0:5];
    initial begin
        // Initialize inputs

        $monitor("[0]: %d %d %d %d %d %d \n [1]: %d %d %d %d %d %d \n [2]: %d %d %d %d %d %d \n \
[3]: %d %d %d %d %d %d \n [4]: %d %d %d %d %d %d \n [5]: %d %d %d %d %d %d \n",                                      
        result_tile_o[0][0], result_tile_o[0][1],result_tile_o[0][2],result_tile_o[0][3],result_tile_o[0][4],result_tile_o[0][5],
        result_tile_o[1][0], result_tile_o[1][1],result_tile_o[1][2],result_tile_o[1][3],result_tile_o[1][4],result_tile_o[1][5],
        result_tile_o[2][0], result_tile_o[2][1],result_tile_o[2][2],result_tile_o[2][3],result_tile_o[2][4],result_tile_o[2][5],
        result_tile_o[3][0], result_tile_o[3][1],result_tile_o[3][2],result_tile_o[3][3],result_tile_o[3][4],result_tile_o[3][5],
        result_tile_o[4][0], result_tile_o[4][1],result_tile_o[4][2],result_tile_o[4][3],result_tile_o[4][4],result_tile_o[4][5],
        result_tile_o[5][0], result_tile_o[5][1],result_tile_o[5][2],result_tile_o[5][3],result_tile_o[5][4],result_tile_o[5][5]
        );
        reset = 1;
        data_valid_i = 0;
        weight_valid_i = 0;
        data_x_index_i = 0;
        data_y_index_i = 0;
        weight_od_i = 0;
        weight_size_type_i = 0;

        // Load data and weights from files


        
        file = $fopen("./matlab_data_out/1in_U.txt", "r");
        for (row = 0; row < 6; row++) begin
            for (col = 0; col < 6; col++) begin
                    $fscanf(file, "%d", tile[row][col]);
            end
        end
        $fclose(file);


        // load_tile_from_file ("../matlab_data_out/in_V.txt", 12, weight_tile_i);

        
        file = $fopen("./matlab_data_out/in_V.txt", "r");
        for (row = 0; row < 6; row++) begin
            for (col = 0; col < 6; col++) begin
                    $fscanf(file, "%d", tile_2[row][col]);
            end
        end
        $fclose(file);


        data_tile_i = tile;
        weight_tile_i = tile_2;
        // Reset de-assertion
        #20 reset = 0;

        // Apply data and weight tiles
        data_valid_i = 1;
        weight_valid_i = 1;
        data_x_index_i = 9'd10;
        data_y_index_i = 9'd15;
        weight_od_i = 8'd3;
        weight_size_type_i = 1'b1; // filter is 3*3 (I don't think this var do anything?)

        // Load example data into the data and weight tiles
        // for (int i = 0; i < 6; i++) begin
        //     for (int j = 0; j < 6; j++) begin
        //         data_tile_i[i][j] = 2; // Example pattern
        //     end
        // end
        
        // for (int i = 0; i < 6; i++) begin
        //     for (int j = 0; j < 6; j++) begin
        //         weight_tile_i[i][j] = 3; // Example pattern
        //     end
        // end

        // Hold input signals for a few cycles
        //#40;
        //data_valid_i = 0;
        //weight_valid_i = 0;

        // Wait and observe output
        #5000;
        $finish;
    end

endmodule