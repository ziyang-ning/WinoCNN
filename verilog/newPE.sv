module PE(
    input logic clk,
    input logic reset,


    // requirement for input[ID][H][W] and weigth [ID][OD][k][k]
    // ID could be small, up to 16, 4 bits
    // H and W could be up to 512, 9 bits
    // OD could be up to 128, 8 bits


    // input from top PE or Itrans
    // only need to know the first element index of input tile
    input logic signed [13:0] data_tile_i [0:5][0:5], // change to 16 bits
    input logic data_valid_i,
    input logic [8:0] data_x_index_i,
    input logic [8:0] data_y_index_i,


    // input from left PE or Wtrans
    input logic signed [11:0] weight_tile_i [0:5][0:5],
    input logic weight_valid_i,
    input logic weight_size_type_i, // 0 stands for 1*1,6*6 and 1 stands for 3*3,4*4 //TODO:do we need this?
    input logic [7:0] weight_od_i, // assume max OD = 128   //TODO:do we need this?


    // output directly to memory
    // assume the output 12 bits
    // may the output to 3 parts, OD, i and j
    output logic signed [11:0] result_tile_o [0:5][0:5],
    output logic signed [7:0] result_od_o,
    output logic signed [8:0] result_i_o [0:5][0:5],
    output logic signed [8:0] result_j_o [0:5][0:5],
    output logic signed result_valid_o,


    // outputs to bottom PE
    output logic signed [13:0] data_tile_reg_o [0:5][0:5],
    output logic data_valid_o,
    output logic [8:0] data_x_index_o,
    output logic [8:0] data_y_index_o,


    // outputs to right PE
    output logic signed [11:0] weight_tile_reg_o [0:5][0:5],
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
                data_tile_reg_o <= data_tile_i;
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


    //TODO:: ADD address calculation and pass it along through the pipline


    // Step 2: Compute dot product when both input and weight tiles are valid
    // VERY IMPORTANT: use the data in output_reg to calculate!!!!
    logic signed [15:0] dot_product [0:5][0:5];
    logic signed [25:0] mult_result;        //added for safety 
    always_comb begin
        if (data_valid_o && weight_valid_o) begin
            for (int i = 0; i < 6; i=i+1) begin
                for (int j = 0; j < 6; j=j+1) begin
                    mult_result = data_tile_reg_o[i][j] * weight_tile_reg_o[i][j];
                    dot_product[i][j] = (mult_result) >>> 7;
                end
            end
        end else begin
            dot_product = '{default:'0};
        end
    end
    
    logic dot_product_valid;
    logic signed [15:0] dot_product_regs [0:5][0:5];
    always_ff @( posedge clk or posedge reset ) begin
        if (reset) begin
            dot_product_regs <= '{default:'0};
            dot_product_valid <= 0;
        end else begin
            if (data_valid_o && weight_valid_o) begin
                dot_product_regs <= dot_product;
                dot_product_valid <= 1;
            end
            else begin
                dot_product_regs <= '{default:'0};
                dot_product_valid <= 0;
            end
        end
    end

    // logic signed [15:0] dot_product [0:5][0:5];
    
    // logic dot_product_valid;
    // always_ff @( posedge clk or posedge reset ) begin
    //     if (reset) begin
    //         dot_product <= '{default:'0};
    //         dot_product_valid <= 0;
    //     end else begin
    //         if (data_valid_o && weight_valid_o) begin
    //             for (int i = 0; i < 6; i=i+1) begin
    //                 for (int j = 0; j < 6; j=j+1) begin
    //                     dot_product[i][j] = data_tile_reg_o[i][j] * weight_tile_reg_o[i][j];
    //                 end
    //             end
    //             dot_product_valid <= 1;
    //         end
    //         else begin
    //             dot_product <= '{default:'0};
    //             dot_product_valid <= 0;
    //         end
    //     end
    // end

    // Step 3: Compute AT*dot_product*A

    // Define the Winograd transformation matrices for A and A^T
    logic signed [3:0] at [0:5][0:5];

    assign at[0][0] = 'd1;
    assign at[0][1] = 'd1;
    assign at[0][2] = 'd1;
    assign at[0][3] = 'd1;
    assign at[0][4] = 'd1;
    assign at[0][5] = 'd0;
    
    assign at[1][0] = 'd0;
    assign at[1][1] = 'd1;
    assign at[1][2] = -'d1;
    assign at[1][3] = 'd2;
    assign at[1][4] = -'d2;
    assign at[1][5] = 'd0;
    
    assign at[2][0] = 'd0;
    assign at[2][1] = 'd1;
    assign at[2][2] = 'd1;
    assign at[2][3] = 'd3;
    assign at[2][4] = 'd3;
    assign at[2][5] = 'd0;
    
    assign at[3][0] = 'd0;
    assign at[3][1] = 'd1;
    assign at[3][2] = -'d1;
    assign at[3][3] = 'd4;
    assign at[3][4] = -'d4;
    assign at[3][5] = weight_size_type_i;
    
    assign at[4][0] = 'd0;
    assign at[4][1] = 'd1;
    assign at[4][2] = 'd1;
    assign at[4][3] = 'd5;
    assign at[4][4] = 'd5;
    assign at[4][5] = 'd0;
    
    assign at[5][0] = 'd0;
    assign at[5][1] = 'd1;
    assign at[5][2] = -'d1;
    assign at[5][3] = 'd6;
    assign at[5][4] = -'d6;
    assign at[5][5] = 'd1;
    

    // Intermediate result for AT * dot_product
    logic signed [15:0] intermediate_result [0:5][0:5];

    // Step 3a: Compute AT * dot_product based on weight_size
    // index in this step is wrong! need to change
    // since dot_product has default value, we can use it to calculate even invalid
    always_comb begin
        for (int i = 0; i < 6; i=i+1) begin
            for (int j = 0; j < 6; j=j+1) begin
                intermediate_result[i][j] = 0;
                for (int k = 0; k < 6; k=k+1) begin
                    if (at[i][k] > 0) intermediate_result[i][j] = intermediate_result[i][j] + (dot_product_regs[k][j] <<< (at[i][k] - 1));
                    else if (at[i][k] < 0) intermediate_result[i][j] = intermediate_result[i][j] - (dot_product_regs[k][j] <<< (-at[i][k] - 1));
                end
            end
        end
    end

    logic signed [15:0] intermediate_result_regs [0:5][0:5];
    logic intermediate_result_valid;

    always_ff @( posedge clk or posedge reset ) begin
        if (reset) begin
            intermediate_result_regs <= '{default:'0};
            intermediate_result_valid <= 0;
        end else begin
            if (dot_product_valid) begin
                intermediate_result_regs <= intermediate_result;
                intermediate_result_valid <= 1;
            end
            else begin
                intermediate_result_regs <= '{default:'0};
                intermediate_result_valid <= 0;
            end
        end
    end


    // Step 3b: Compute (AT * dot_product) * A to get the final 4x4 output
    always_comb begin
        for (int i = 0; i < 6; i=i+1) begin
            for (int j = 0; j < 6; j=j+1) begin
                result_tile_o[i][j] = 0;
                for (int k = 0; k < 6; k=k+1) begin
                    if (at[j][k] > 0) result_tile_o[i][j] = result_tile_o[i][j] + (intermediate_result[i][k] <<< (at[j][k] - 1));
                    else if (at[j][k] < 0) result_tile_o[i][j] = result_tile_o[i][j] - (intermediate_result[i][k] <<< (-at[j][k] - 1));
                end
            end
        end
    end

    logic signed [15:0] result_tile_o_regs [0:5][0:5];
    logic result_valid_o;

    always_ff @( posedge clk or posedge reset ) begin
        if (reset) begin
            result_tile_o_regs <= '{default:'0};
            result_valid_o <= 0;
        end else begin
            if (dot_product_valid) begin
                result_tile_o_regs <= result_tile_o;
                result_valid_o <= 1;
            end
            else begin
                result_tile_o_regs <= '{default:'0};
                result_valid_o <= 0;
            end
        end
    end

    // Step 4: other output the result to memory
    // assign result_valid_o = data_valid_o && weight_valid_o;
    assign result_od_o = weight_od_o;

    // calculate result_i_o
    always_comb begin
        if (result_valid_o) begin
            for (int i = 0; i < 6; i=i+1) begin
                for (int j = 0; j < 6; j=j+1) begin
                    result_i_o[i][j] = data_x_index_o + i;
                end
            end
        end else begin
            result_i_o = '{default:'0};
        end
    end

    // calculate result_j_o
    always_comb begin
        if (result_valid_o) begin
            for (int i = 0; i < 6; i=i+1) begin
                for (int j = 0; j < 6; j=j+1) begin
                    result_j_o[i][j] = data_y_index_o + j;
                end
            end
        end else begin
            result_j_o = '{default:'0};
        end
    end


    

endmodule
