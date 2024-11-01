module PE(
    input logic clk,
    input logic reset,


    // requirement for input[ID][H][W] and weigth [ID][OD][k][k]
    // ID could be small, up to 16, 4 bits
    // H and W could be up to 512, 9 bits
    // OD could be up to 128, 8 bits


    // input from top PE or Itrans
    // only need to know the first element index of input tile
    input logic signed [15:0] data_tile_i [0:5][0:5], // change to 16 bits
    input logic data_valid_i,
    input logic [8:0] data_x_index_i,
    input logic [8:0] data_y_index_i,


    // input from left PE or Wtrans
    input logic signed [15:0] weight_tile_i [0:2][0:2],
    input logic weight_valid_i,
    input logic weight_size_type_i, // 0 stands for 1*1,6*6 and 1 stands for 3*3,4*4
    input logic [7:0] weight_od_i, // assume max OD = 128


    // output directly to memory
    // assume the output 12 bits
    // may the output to 3 parts, OD, i and j
    output logic signed [15:0] result_tile_o [0:5][0:5],
    output logic signed [15:0] result_od_o [0:5][0:5],
    output logic signed [15:0] result_i_o [0:5][0:5],
    output logic signed [15:0] result_j_o [0:5][0:5],


    // outputs to bottom PE
    output logic [15:0] data_tile_reg_o [0:5][0:5],
    output logic data_valid_o,
    output logic [8:0] data_x_index_o,
    output logic [8:0] data_y_index_o,

    // outputs to right PE
    output logic [15:0] weight_tile_reg_o [0:2][0:2],
    output logic weight_valid_o,
    output logic weight_size_type_o,
    output logic [7:0] weight_od_o
    
);


    // Step 1A: store data from top PE into reg
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            data_tile_reg_o <= '{default:'0};
            data_valid_o <= 0;
            data_x_index_o <= 0;
            data_y_index_o <= 0;
        end else begin
            if (data_valid_i) begin
                weight_tile_reg_o <= weight_tile_i;
                data_valid_o <= 1;  
                data_x_index_o <= data_x_index_i;
                data_y_index_o <= data_y_index_i;
            end 
            else begin
                data_tile_reg_o <= '{default:'0};
                data_valid_o <= 0;
                data_x_index_o <= 0;
                data_y_index_o <= 0;
            end
        end
    end

    // Step 1B: store weight from left PE into reg
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            weight_tile_reg_o <= '{default:'0};
            weight_valid_o <= 0;
            weight_size_type_o <= 0;
            weight_od_o <= 0;
        end else begin
            if (weight_valid_i) begin
                weight_tile_reg_o <= weight_tile_i;
                weight_valid_o <= 1;  
                weight_size_type_o <= weight_size_type_i;
                weight_od_o <= weight_od_i;
            end 
            else begin
                weight_tile_reg_o <= '{default:'0};
                weight_valid_o <= 0;
                weight_size_type_o <= 0;
                weight_od_o <= 0;
            end
        end
    end



    // Step 2: Compute dot product when both input and weight tiles are valid
    logic signed [11:0] dot_product_result [0:5][0:5];
    int i, j, k;
    always_comb begin
        if (input_valid && weight_valid)
            for (i = 0; i < 6; i=i+1)
                for (j = 0; j < 6; j=j+1)
                    dot_product_result[i][j] = input_tile[i][j] * weight_tile[i][j];
    end

    // Step 3: Compute AT*dot_product*A

    // Define the Winograd transformation matrices for A and A^T
    logic signed [11:0] at1 [0:5][0:5] = '{
        '{ 12'd1,  12'd0,  12'd0,  12'd0,   12'd1,  12'd0 },
        '{ 12'd1,  12'd0,  12'd0,  12'd0,   12'd1,  12'd0 },
        '{ 12'd1,  12'd0,  12'd0,  12'd0,   12'd1,  12'd0 },
        '{ 12'd1,  12'd0,  12'd0,  12'd0,   12'd1,  12'd0 },
        '{ 12'd1,  12'd0,  12'd0,  12'd0,   12'd1,  12'd0 },
        '{ 12'd1,  12'd0,  12'd0,  12'd0,   12'd1,  12'd0 }
    };

    logic signed [11:0] a1 [0:5][0:5] = '{
        '{ 12'd1,  12'd0,  12'd0,  12'd0,   12'd1,  12'd0 },
        '{ 12'd1,  12'd0,  12'd0,  12'd0,   12'd1,  12'd0 },
        '{ 12'd1,  12'd0,  12'd0,  12'd0,   12'd1,  12'd0 },
        '{ 12'd1,  12'd0,  12'd0,  12'd0,   12'd1,  12'd0 },
        '{ 12'd1,  12'd0,  12'd0,  12'd0,   12'd1,  12'd0 },
        '{ 12'd1,  12'd0,  12'd0,  12'd0,   12'd1,  12'd0 }
    };

    logic signed [11:0] at3 [0:5][0:3] = '{
        '{ 12'd1,  12'd0,  12'd0,  12'd0,   12'd1,  12'd0 },
        '{ 12'd1,  12'd0,  12'd0,  12'd0,   12'd1,  12'd0 },
        '{ 12'd1,  12'd0,  12'd0,  12'd0,   12'd1,  12'd0 },
        '{ 12'd1,  12'd0,  12'd0,  12'd0,   12'd1,  12'd0 }
    };

    logic signed [11:0] a3 [0:5][0:3] = '{
        '{ 12'd1,  12'd0,  12'd0,  12'd0},
        '{ 12'd1,  12'd0,  12'd0,  12'd0},
        '{ 12'd1,  12'd0,  12'd0,  12'd0},
        '{ 12'd1,  12'd0,  12'd0,  12'd0},
        '{ 12'd1,  12'd0,  12'd0,  12'd0},
        '{ 12'd1,  12'd0,  12'd0,  12'd0},
    };

    // Intermediate result for AT * dot_product
    logic signed [19:0] intermediate_result [0:5][0:5];

    // Step 3a: Compute AT * dot_product based on weight_size
    // index in this step is wrong! need to change
    always_comb begin
        for (i = 0; i < 6; i=i+1) begin
            for (j = 0; j < 6; j=j+1) begin
                intermediate_result[i][j] = 0;
                for (k = 0; k < 6; k=k+1) begin
                    if (size_type == 1) begin
                        intermediate_result[i][j] += AT3[i][k] * dot_product_result[k][j];
                    end else begin
                        intermediate_result[i][j] += AT1[i][k] * dot_product_result[k][j];
                    end
                end
            end
        end
    end

    // Step 3b: Compute (AT * dot_product) * A to get the final 4x4 output
    always_comb begin
        for (i = 0; i < 6; i=i+1) begin
            for (j = 0; j < 6; j=j+1) begin
                output_tile[i][j] = 0;
                for (k = 0; k < 6; k=k+1) begin
                    if (size_type == 1) begin
                        output_tile[i][j] += intermediate_result[i][k] * A3[k][j];
                    end else begin
                        output_tile[i][j] += intermediate_result[i][k] * A1[k][j];
                    end
                end
            end
        end
    end


    

endmodule
