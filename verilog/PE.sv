module PE(
    input logic clk,
    input logic reset,

    // input tile fixed to be 6*6
    input logic signed [7:0] input_tile [0:5][0:5],
    input logic input_valid,
    // assume max H/W to be 512, 9 bits
    input logic [8:0] input_weight_index,
    input logic [8:0] input_height_index,

    // id and total height and width to help calculate addr
    input logic [3:0] id,
    input logic [8:0] total_height,
    input logic [8:0] total_width,


    input logic signed [7:0] weight_tile [0:2][0:2],
    input logic weight_valid,
    input logic size_type, // 0 stands for 1*1,6*6 and 1 stands for 3*3,4*4
    input logic [7:0] od, // assume max OD = 128


    // assume the output 12 bits, the memory address is 16 bits
    // output to memory
    output logic signed [11:0] output_tile [0:5][0:5],
    output logic signed [15:0] output_addr [0:5][0:5],


    // outputs to next PE
    output logic [7:0] output_input_tile_reg [0:5][0:5],
    output logic output_input_tile_valid,
    output logic [7:0] output_weight_tile_reg [0:5][0:5],
    output logic output_weight_tile_valid,
    output logic [8:0] input_weight_index_o,
    output logic [8:0] input_weight_index_o
);

    assign input_weight_index_o = input_weight_index;
    assign input_weight_index_o = input_height_index;
    // Step 1: Store input and weight tiles in output registers and update valid signals
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            output_input_tile_reg <= '{default:'0};
            output_weight_tile_reg <= '{default:'0};
            output_input_tile_valid <= 0;
            output_weight_tile_valid <= 0;
        end else begin
            // Update output input tile register and valid signal
            if (input_valid) begin
                output_input_tile_reg <= input_tile;
                output_input_tile_valid <= 1;  // Set valid signal to 1 when data is updated
            end 
            else output_input_tile_valid <= 0;

            // Update output weight tile register and valid signal
            if (weight_valid) begin
                output_weight_tile_reg <= weight_tile;
                output_weight_tile_valid <= 1;  // Set valid signal to 1 when data is updated
            end 
            else output_weight_tile_valid <= 0;
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
