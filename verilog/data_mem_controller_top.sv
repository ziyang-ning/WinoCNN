module data_mem_controller_top (
    // clock here also work as scan_clk
    input logic clk,
    input logic reset,

    // input from main controller
    input logic [7:0] input_addr_i_1,
    input logic [7:0] input_addr_i_2,
    input logic size_type_i,
    input logic [7:0] block_cnt_i,
    input logic [3:0] current_id_i,
    input logic input_request_i,

    // scan related inputs
    input logic [511:0] scan_in,
    input logic scan_mode,
    input logic [7:0] scan_addr, 

    // outputs to PE arrays
    output logic signed [13:0] result_tile_o_1 [5:0][5:0],
    output logic signed [13:0] result_tile_o_2 [5:0][5:0],
    output logic [7:0] pe_data_addr_o_1,
    output logic [7:0] pe_data_addr_o_2,
    output logic data_valid_o_1,
    output logic data_valid_o_2,
    output logic size_type_o,
    output logic [7:0] block_cnt_o


);
    // output of controller
    logic [7:0] input_addr_o_1;
    logic [7:0] input_addr_o_2;
    logic input_request_o;

    // output of sram
    logic [511:0] data_1_out;
    logic [511:0] data_2_out;
    logic [7:0] addr_1_out;
    logic [7:0] addr_2_out;
    logic input_valid_i;
    logic package_2_valid_out;

    // defination of two modules
    data_controller data_controller_inst (
        .clk(clk),
        .reset(reset),

        .input_addr_i_1(input_addr_i_1),
        .input_addr_i_2(input_addr_i_2),
        .size_type_i(size_type_i),
        .block_cnt_i(block_cnt_i),
        .current_id_i(current_id_i),
        .input_request_i(input_request_i),

        .input_addr_o_1(input_addr_o_1),
        .input_addr_o_2(input_addr_o_2),
        .input_request_o(input_request_o),
        .input_data_i_1(data_1_out),
        .input_data_i_2(data_2_out),
        .input_valid_i(input_valid_i),

        .result_tile_o_1(result_tile_o_1),
        .result_tile_o_2(result_tile_o_2),
        .pe_data_addr_o_1(pe_data_addr_o_1),
        .pe_data_addr_o_2(pe_data_addr_o_2),
        .data_valid_o_1(data_valid_o_1),
        .data_valid_o_2(data_valid_o_2),
        .size_type_o(size_type_o),
        .block_cnt_o(block_cnt_o)
    );

    data_mem_top data_mem_top_inst (
        .clk(clk),
        .reset(reset),
        .scan_in(scan_in),
        .scan_mode(scan_mode),
        .scan_addr(scan_addr),
        .addr_1_in(input_addr_o_1),
        .addr_2_in(input_addr_o_2),
        .package_1_valid_in(input_request_o),
        .package_2_valid_in(input_request_o),

        .data_1_out(data_1_out),
        .data_2_out(data_2_out),
        .addr_1_out(addr_1_out),
        .addr_2_out(addr_2_out),
        .package_1_valid_out(input_valid_i),
        .package_2_valid_out(package_2_valid_out)
    );

endmodule




