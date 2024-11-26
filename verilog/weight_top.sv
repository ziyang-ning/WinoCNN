module weight_controller (

    // off-chip input
    input logic [7:0] total_od_i,

    // input from the main controller
    input logic [7:0] weight_od1_i,
    input logic [3:0] weight_id_i,

    // output to the memory, 18 elements in total
    output logic [7:0] weight_addr_o,

    // input from the memory 
    input logic signed [11:0] weight_data_i_1[5:0][5:0],
    input logic signed [11:0] weight_data_i_2[5:0][5:0],

    // output to the PE arrays
    output logic signed [11:0] result_tile_o_1 [5:0][5:0],
    output logic signed [11:0] result_tile_o_2 [5:0][5:0]
);

    assign weight_addr_o = weight_od1_i + total_od_i * weight_id_i;

    assign result_tile_o_1 = weight_data_i_1;
    assign result_tile_o_2 = weight_data_i_2;
    
    
endmodule




module weight_trans_buffer ();
    // calculate the input from the weight buffer, store the data in local reg

    // input from the weight buffer

    // output to the PE arrays


endmodule




module weight_top ();

endmodule
