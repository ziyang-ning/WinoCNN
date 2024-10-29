module PE(
    input logic clk,
    input logic reset,

    // input tile fixed to be 6*6
    input logic signed [7:0] input_tile [0:35],
    input logic input_valid,
    // assume max H/W to be 512, 9 bits
    input logic [8:0] input_low_weight_index,
    input logic [8:0] input_high_weight_index,
    input logic [8:0] input_low_height_index,
    input logic [8:0] input_high_height_index,

    // id and total height and width to help calculate addr
    input logic [3:0] id,
    input logic [8:0] total_height,
    input logic [8:0] total_width,


    input logic signed [7:0] weight_tile [0:35],
    input logic weight_valid,
    input logic weight_size, // 0 stands for 1 and 1 stands for 3
    input logic [7:0] od, // assume max OD = 128


    // assume the output 12 bits, the memory address is 16 bits
    // output to memory
    output logic signed [11:0] output_tile [0:35],
    output logic signed [15:0] output_addr [0:35],


    // outputs to next PE
    output logic [7:0] output_input_tile_reg [0:35],
    output logic output_input_tile_valid,
    output logic [7:0] output_weight_tile_reg [0:35]
    output logic output_weight_tile_valid,    
);

    // Step 1: Store input and weight tiles in output registers and update valid signals
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < 36; i++) begin
                output_input_tile_reg[i] <= 0;
            end
            for (int j = 0; j < 36; j++) begin
                output_weight_tile_reg[j] <= 0;
            end
            output_input_tile_valid <= 0;
            output_weight_tile_valid <= 0;
        end else begin
            // Update output input tile register and valid signal
            output_input_tile_valid <= 0;
            output_weight_tile_valid <= 0;
            if (input_valid) begin
                for (int i = 0; i < 36; i++) begin
                    output_input_tile_reg[i] <= input_tile[i];
                end
                output_input_tile_valid <= 1;  // Set valid signal to 1 when data is updated
            end 

            // Update output weight tile register and valid signal
            if (weight_valid) begin
                for (int j = 0; j < 36; j++) begin
                    output_weight_tile_reg[j] <= weight_tile[j];
                end
                output_weight_tile_valid <= 1;  // Set valid signal to 1 when data is updated
            end 
        end
    end

    // Step 2: Compute dot product when both input and weight tiles are valid
    logic signed [11:0] dot_product_result [0:35],
    always_comb begin
        dot_product_result = 0;
        if (output_input_tile_valid && output_weight_tile_valid) begin
            for (int i = 0; i < 36; i++) begin
                dot_product_result += output_input_tile_reg[i] * output_weight_tile_reg[i];
            end
        end
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
        for (int i = 0; i < 6; i++) begin
            for (int j = 0; j < 6; j++) begin
                intermediate_result[i][j] = 0;
                for (int k = 0; k < 6; k++) begin
                    if (weight_size == 1) begin
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
        for (int i = 0; i < 6; i++) begin
            for (int j = 0; j < 6; j++) begin
                output_tile[i][j] = 0;
                for (int k = 0; k < 6; k++) begin
                    if (weight_size == 1) begin
                        output_tile[i][j] += intermediate_result[i][k] * A3[k][j];
                    end else begin
                        output_tile[i][j] += intermediate_result[i][k] * A1[k][j];
                    end
                end
            end
        end
    end

    // [OD][temp2][temp3]
    logic [8:0] temp1 [35:0]; 
    logic [8:0] temp2 [35:0]; 
    logic [8:0] temp3 [35:0]; 
    always_comb begin 
        for (int i = 0; i < 35; i++){
            temp1[i] = od,
            temp2[i] = 
        }
    end
    

endmodule