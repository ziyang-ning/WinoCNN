module PE(
    input logic clk,
    input logic reset,

    // input tile fixed to be 6*6
    input logic signed [7:0] input_tile [0:35],
    input logic input_valid,
    // assume max H/W to be 512
    input logic [8:0] input_low_weight_index,
    input logic [8:0] input_high_weight_index,
    input logic [8:0] input_low_height_index,
    input logic [8:0] input_high_height_index,    


    input logic signed [7:0] weight_tile [0:8],
    input logic weight_valid,
    input logic weight_size,
    input logic [7:0] weight_dimen, // assume max OD = 128

    // assume the output 12 bits, the memory address is 16 bits
    output logic signed [11:0] output_tile [0:35],
    output logic signed [15:0] output_addr [0:35],

    output logic [7:0] input_tile_reg [0:35],
    output logic [7:0] weight_tile_reg [0:8]
    
);


endmodule