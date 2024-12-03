module controller_top(

    input clk,
    input mem_clk,
    input reset,

    input logic [3:0] total_id,
    input logic [7:0] total_od,
    input logic [8:0] total_width,
    input logic [8:0] total_height,
    input logic total_size_type,
    input logic wen,

    input input_mem_scan_mode,
    // input [1:0] output_mem_scan_mode,
    // two output share the same scan_mode, but different from input scan_mode
    input [7:0] scan_addr,
    // four sram share the same scan_address
    input [511:0] data_mem_scan_in,
    input [511:0] weight_mem_scan_in,
    // input [511:0] output_mem1_scan_in,
    // input [511:0] output_mem2_scan_in,
    // don't need to scan_in the output memory, 0 is enough

    //output [511:0] output_mem1_scan_out,
    //output [511:0] output_mem2_scan_out,

    output logic conv_completed

);

    logic loop_finished;
    logic [7:0] weight_od1;
    logic [3:0] weight_id;
    logic [7:0] block_width;
    logic [7:0] block_height;
    logic [3:0] data_id;
    logic data_prepare;
    logic size_type;

    logic signed [13:0] data_tile_1_ctrl [5:0][5:0];
    logic signed [13:0] data_tile_2_ctrl [5:0][5:0];
    logic [7:0] data_addr_1_ctrl;
    logic [7:0] data_addr_2_ctrl;
    logic data_valid_ctrl;
    logic size_type_ctrl;
    logic [7:0] block_cnt_ctrl;

    logic signed [11:0] weight_tile_1_ctrl [5:0][5:0];
    logic signed [11:0] weight_tile_2_ctrl [5:0][5:0];
    logic weight_valid_1_ctrl;
    logic weight_valid_2_ctrl;
    logic [7:0] weight_od1_ctrl;
    logic [7:0] weight_od2_ctrl;

    logic signed [11:0] result_tile_0 [5:0][5:0];
    logic signed [11:0] result_tile_1 [5:0][5:0];
    logic signed [11:0] result_tile_2 [5:0][5:0];
    logic signed [11:0] result_tile_3 [5:0][5:0];
    logic [11:0] result_address_0;
    logic [11:0] result_address_1;
    logic [11:0] result_address_2;
    logic [11:0] result_address_3;
    logic result_valid_0;
    logic result_valid_1;
    logic result_valid_2;
    logic result_valid_3;

    logic signed [13:0] data_tile_02 [5:0][5:0];
    logic [7:0] data_addr_02;
    logic data_valid_02;
    logic size_type_02;
    logic [7:0] block_cnt_02;
    logic signed [13:0] data_tile_13 [5:0][5:0];
    logic [7:0] data_addr_13;
    logic data_valid_13;
    logic size_type_13;
    logic [7:0] block_cnt_13;
    logic signed [13:0] data_tile_2 [5:0][5:0];
    logic [7:0] data_addr_2;
    logic data_valid_2;
    logic size_type_2;
    logic [7:0] block_cnt_2;
    logic signed [13:0] data_tile_3 [5:0][5:0];
    logic [7:0] data_addr_3;
    logic data_valid_3;
    logic size_type_3;
    logic [7:0] block_cnt_3;

    logic signed [11:0] weight_tile_01 [5:0][5:0];
    logic weight_valid_01;
    logic [7:0] weight_od_01;
    logic signed [11:0] weight_tile_23 [5:0][5:0];
    logic weight_valid_23;
    logic [7:0] weight_od_23;
    logic signed [11:0] weight_tile_1 [5:0][5:0];
    logic weight_valid_1;
    logic [7:0] weight_od_1;
    logic signed [11:0] weight_tile_3 [5:0][5:0];
    logic weight_valid_3;
    logic [7:0] weight_od_3;
    

    main_controller main(
        .clk(clk),
        .reset(reset),

        .total_id_i(total_id),
        .total_od_i(total_od),
        .total_width_i(total_width),
        .total_height_i(total_height),
        .total_size_type_i(total_size_type),
        .wen_i(wen),
        
        .loop_finished_i(loop_finished),

        .weight_od1_o(weight_od1),
        .weight_id_o(weight_id),

        .block_width_o(block_width),
        .block_height_o(block_height),
        .data_id_o(data_id),
        .data_prepare_o(data_prepare),
        .size_type_o(size_type),

        .conv_completed(conv_completed)
    );


    weight_mem_controller_top weight_mem_controller_top_0(
        .clk(clk),
        .reset(reset),

        .total_od_i(total_od),
        .weight_od1_i(weight_od1),
        .weight_id_i(weight_id),
        .weight_main_valid_i(wen),

        .scan_in(weight_mem_scan_in),
        .scan_mode(input_mem_scan_mode),
        .scan_addr(scan_addr),

        .result_tile_o_1(weight_tile_1_ctrl),
        .result_tile_o_2(weight_tile_2_ctrl),
        .weight_valid_o_1(weight_valid_1_ctrl),
        .weight_valid_o_2(weight_valid_2_ctrl),
        .weight_od1_o(weight_od1_ctrl),
        .weight_od2_o(weight_od2_ctrl)
    );

    data_mem_controller_top data_mem_controller_top_0(
        .clk(clk),
        .reset(reset),

        .input_id_i(data_id),
        .input_prepare_i(data_prepare),
        .block_width_i(block_width),
        .block_height_i(block_height),
        .size_type_i(size_type),

        .scan_in(data_mem_scan_in),
        .scan_mode(input_mem_scan_mode),
        .scan_addr(scan_addr),

        .loop_finished_o(loop_finished),

        .result_tile_o_1(data_tile_1_ctrl),
        .result_tile_o_2(data_tile_2_ctrl),
        .pe_data_addr_o_1(data_addr_1_ctrl),
        .pe_data_addr_o_2(data_addr_2_ctrl),
        .data_valid_o(data_valid_ctrl),
        .size_type_o(size_type_ctrl),
        .block_cnt(block_cnt_ctrl)
    );

    PE pe_0(
        .clk(clk),
        .reset(reset),

        .data_tile_i(data_tile_1_ctrl),
        .data_valid_i(data_valid_ctrl),
        .data_addr_i(data_addr_1_ctrl),
        .size_type_i(size_type_ctrl),
        .block_cnt_i(block_cnt_ctrl),

        .weight_tile_i(weight_tile_1_ctrl),
        .weight_valid_i(weight_valid_1_ctrl),
        .weight_od_i(weight_od1_ctrl),

        .result_tile_o(result_tile_0),
        .result_address_o(result_address_0),
        .result_valid_o(result_valid_0),

        .data_tile_reg_o(data_tile_02),
        .data_valid_o(data_valid_02),
        .data_addr_o(data_addr_02),
        .size_type_o(size_type_02),
        .block_cnt_o(block_cnt_02),

        .weight_tile_reg_o(weight_tile_01),
        .weight_valid_o(weight_valid_01),
        .weight_od_o(weight_od_01)
    );

    PE pe_1(
        .clk(clk),
        .reset(reset),

        .data_tile_i(data_tile_2_ctrl),
        .data_valid_i(data_valid_ctrl),
        .data_addr_i(data_addr_2_ctrl),
        .size_type_i(size_type_ctrl),
        .block_cnt_i(block_cnt_ctrl),

        .weight_tile_i(weight_tile_01),
        .weight_valid_i(weight_valid_01),
        .weight_od_i(weight_od_01),

        .result_tile_o(result_tile_1),
        .result_address_o(result_address_1),
        .result_valid_o(result_valid_1),

        .data_tile_reg_o(data_tile_13),
        .data_valid_o(data_valid_13),
        .data_addr_o(data_addr_13),
        .size_type_o(size_type_13),
        .block_cnt_o(block_cnt_13),

        .weight_tile_reg_o(weight_tile_1),
        .weight_valid_o(weight_valid_1),
        .weight_od_o(weight_od_1)
    );

    PE pe_2(
        .clk(clk),
        .reset(reset),

        .data_tile_i(data_tile_02),
        .data_valid_i(data_valid_02),
        .data_addr_i(data_addr_02),
        .size_type_i(size_type_02),
        .block_cnt_i(block_cnt_02),

        .weight_tile_i(weight_tile_2_ctrl),
        .weight_valid_i(weight_valid_2_ctrl),
        .weight_od_i(weight_od2_ctrl),

        .result_tile_o(result_tile_2),
        .result_address_o(result_address_2),
        .result_valid_o(result_valid_2),

        .data_tile_reg_o(data_tile_2),
        .data_valid_o(data_valid_2),
        .data_addr_o(data_addr_2),
        .size_type_o(size_type_2),
        .block_cnt_o(block_cnt_2),

        .weight_tile_reg_o(weight_tile_23),
        .weight_valid_o(weight_valid_23),
        .weight_od_o(weight_od_23)
    );

    PE pe_3(
        .clk(clk),
        .reset(reset),

        .data_tile_i(data_tile_13),
        .data_valid_i(data_valid_13),
        .data_addr_i(data_addr_13),
        .size_type_i(size_type_13),
        .block_cnt_i(block_cnt_13),

        .weight_tile_i(weight_tile_23),
        .weight_valid_i(weight_valid_23),
        .weight_od_i(weight_od_23),

        .result_tile_o(result_tile_3),
        .result_address_o(result_address_3),
        .result_valid_o(result_valid_3),

        .data_tile_reg_o(data_tile_3),
        .data_valid_o(data_valid_3),
        .data_addr_o(data_addr_3),
        .size_type_o(size_type_3),
        .block_cnt_o(block_cnt_3),

        .weight_tile_reg_o(weight_tile_3),
        .weight_valid_o(weight_valid_3),
        .weight_od_o(weight_od_3)
    );

 

endmodule


