module weight_controller (

    input logic clk,
    input logic reset,
    // off-chip input
    input logic [7:0] total_od_i,

    // input from the main controller
    input logic [7:0] weight_od1_i,
    input logic [3:0] weight_id_i,
    input logic weight_main_valid_i,

    // output to the memory, 18 elements in total
    output logic [7:0] weight_addr_o_1,
    output logic [7:0] weight_addr_o_2,
    output logic weight_package_1_valid_o,
    output logic weight_package_2_valid_o,

    // input from the memory 
    input logic signed [511:0] weight_data_i_1,
    input logic signed [511:0] weight_data_i_2,
    input logic [7:0] weight_addr_i_1,
    input logic [7:0] weight_addr_i_2,
    input logic weight_valid_i_1,
    input logic weight_valid_i_2,

    // output to the PE arrays
    output logic signed [11:0] result_tile_o_1 [5:0][5:0],
    output logic signed [11:0] result_tile_o_2 [5:0][5:0],
    output logic weight_valid_o_1,
    output logic weight_valid_o_2,
    output logic [7:0] weight_od1_o,
    output logic [7:0] weight_od2_o
);

    logic signed [11:0] result_tile_reg_1 [5:0][5:0];
    logic signed [11:0] result_tile_reg_2 [5:0][5:0];
    logic signed [11:0] result_tile_reg_2_delay [5:0][5:0];
    logic weight_valid_reg_1;
    logic weight_valid_reg_2;
    logic weight_valid_reg_2_delay;
    logic [7:0] weight_od1_reg;
    logic [7:0] weight_od2_reg;
    logic [7:0] weight_od2_reg_delay;

    // addr and valid come from sram, the sram delayed by one cycle
    assign weight_addr_o_1 = weight_od1_i + total_od_i * weight_id_i;
    assign weight_addr_o_2 = (weight_od1_i + 1) + total_od_i * weight_id_i;
    assign weight_valid_reg_1 = weight_valid_i_1;
    assign weight_valid_reg_2 = weight_valid_i_2;
    assign weight_package_1_valid_o = weight_main_valid_i;
    assign weight_package_2_valid_o = weight_main_valid_i;
    
    // od needs to be delayed by one cycle in weight controller
    always_ff @(posedge clk) begin
        weight_od1_reg <= weight_od1_i;
        weight_od2_reg <= weight_od1_i + 1;
    end

    always_comb begin
        result_tile_reg_1 = '{default:'0};
        for (int i = 0; i < 6; i++) begin
            for (int j = 0; j < 6; j++) begin
                result_tile_reg_1[i][j] = weight_data_i_1[(i * 6 + j) * 12 +: 12];
            end
        end
    end

    always_comb begin
        result_tile_reg_2 = '{default:'0};
        for (int i = 0; i < 6; i++) begin
            for (int j = 0; j < 6; j++) begin
                result_tile_reg_2[i][j] = weight_data_i_2[(i * 6 + j) * 12 +: 12];
            end
        end
    end

    always_ff @(posedge clk) begin
        result_tile_o_1 <= result_tile_reg_1;
        result_tile_o_2 <= result_tile_reg_2_delay;
        result_tile_reg_2_delay <= result_tile_reg_2;
        weight_valid_o_1 <= weight_valid_reg_1;
        weight_valid_o_2 <= weight_valid_reg_2_delay;
        weight_valid_reg_2_delay <= weight_valid_reg_2;
        weight_od1_o <= weight_od1_reg;
        weight_od2_o <= weight_od2_reg_delay;
        weight_od2_reg_delay <= weight_od2_reg;
    end

    
    // always_ff @(posedge clk or posedge reset) begin
    //     if (reset) begin
    //         result_tile_o_1 <= '{default:'0};
    //         result_tile_o_2 <= '{default:'0};
    //         weight_valid_o <= 0;
    //         weight_od1_o <= 0;
    //         weight_od2_o <= 0;
    //     end
    //     else begin
    //         if (weight_valid_i) begin
    //             result_tile_o_1 <= weight_data_i_1;
    //             result_tile_o_2 <= weight_data_i_2;
    //             weight_valid_o <= 1;
    //             weight_od1_o <= weight_od1_i;
    //             weight_od2_o <= weight_od1_i + 1;
    //         end
    //     end
    // end
    
endmodule


