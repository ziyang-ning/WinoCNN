module weight_controller (

    input logic clk,
    input logic reset,
    // off-chip input
    input logic [7:0] total_od_i,

    // input from the main controller
    input logic [7:0] weight_od1_i,
    input logic [3:0] weight_id_i,

    // output to the memory, 18 elements in total
    output logic [11:0] weight_addr_o,

    // input from the memory 
    input logic signed [11:0] weight_data_i_1[5:0][5:0],
    input logic signed [11:0] weight_data_i_2[5:0][5:0],
    input logic weight_valid_i,

    // output to the PE arrays
    output logic signed [11:0] result_tile_o_1 [5:0][5:0],
    output logic signed [11:0] result_tile_o_2 [5:0][5:0],
    output logic weight_valid_o,
    output logic [7:0] weight_od1_o,
    output logic [7:0] weight_od2_o
);

    assign weight_addr_o = weight_od1_i + total_od_i * weight_id_i;

    logic [7:0] weight_od1_reg;
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            result_tile_o_1 <= '{default:'0};
            result_tile_o_2 <= '{default:'0};
            weight_valid_o <= 0;
            weight_od1_reg <= 0;
            weight_od1_o <= 0;
            weight_od2_o <= 0;
        end
        else begin
            if (weight_valid_i) begin
                result_tile_o_1 <= weight_data_i_1;
                result_tile_o_2 <= weight_data_i_2;
                weight_valid_o <= 1;
                weight_od1_reg <= weight_od1_i;
                weight_od1_o <= weight_od1_reg;
                weight_od2_o <= weight_od1_reg + 1;
            end
        end
    end
    
endmodule


/*

module weight_trans_buffer ();
    // calculate the input from the weight buffer, store the data in local reg

    // input from the weight buffer

    // output to the PE arrays


endmodule




module weight_top ();

endmodule

*/
