module weight_mem_controller_top (
    // clock here also work as scan_clk
    input logic clk,
    input logic reset,

    // input from main controller
    input logic [7:0] total_od_i,
    input logic [7:0] weight_od1_i,
    input logic [3:0] weight_id_i,
    input logic weight_main_valid_i,

    // scan related inputs
    input logic [511:0] scan_in,
    input logic scan_mode,
    input logic [7:0] scan_addr, 

    // outputs to PE arrays
    output logic signed [11:0] result_tile_o_1 [5:0][5:0],
    output logic signed [11:0] result_tile_o_2 [5:0][5:0],
    output logic weight_valid_o_1,
    output logic weight_valid_o_2,
    output logic [7:0] weight_od1_o,
    output logic [7:0] weight_od2_o


);
    // output of controller
    logic [7:0] weight_addr_o_1;
    logic [7:0] weight_addr_o_2;
    logic weight_package_1_valid_o;
    logic weight_package_2_valid_o;

    // output of sram
    logic [511:0] data_1_out;
    logic [511:0] data_2_out;
    logic [7:0] addr_1_out;
    logic [7:0] addr_2_out;
    logic package_1_valid_out;
    logic package_2_valid_out;

    // defination of two modules
    weight_controller weight_controller_inst (
        .clk(clk),
        .reset(reset),
        .total_od_i(total_od_i),
        .weight_od1_i(weight_od1_i),
        .weight_id_i(weight_id_i),
        .weight_main_valid_i(weight_main_valid_i),
        .weight_addr_o_1(weight_addr_o_1),
        .weight_addr_o_2(weight_addr_o_2),
        .weight_package_1_valid_o(weight_package_1_valid_o),
        .weight_package_2_valid_o(weight_package_2_valid_o),
        .weight_data_i_1(data_1_out),
        .weight_data_i_2(data_2_out),
        .weight_addr_i_1(addr_1_out),
        .weight_addr_i_2(addr_2_out),
        .weight_valid_i_1(package_1_valid_out),
        .weight_valid_i_2(package_2_valid_out),
        .result_tile_o_1(result_tile_o_1),
        .result_tile_o_2(result_tile_o_2),
        .weight_valid_o_1(weight_valid_o_1),
        .weight_valid_o_2(weight_valid_o_2),
        .weight_od1_o(weight_od1_o),
        .weight_od2_o(weight_od2_o)
    );

    data_mem_top data_mem_top_inst (
        .clk(clk),
        .reset(reset),
        .scan_in(scan_in),
        .scan_mode(scan_mode),
        .scan_addr(scan_addr),
        .addr_1_in(weight_addr_o_1),
        .addr_2_in(weight_addr_o_2),
        .package_1_valid_in(weight_package_1_valid_o),
        .package_2_valid_in(weight_package_2_valid_o),
        .data_1_out(data_1_out),
        .data_2_out(data_2_out),
        .addr_1_out(addr_1_out),
        .addr_2_out(addr_2_out),
        .package_1_valid_out(package_1_valid_out),
        .package_2_valid_out(package_2_valid_out)
    );

endmodule




