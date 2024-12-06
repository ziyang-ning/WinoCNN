module top(

    // input clk,
    input mem_clk,
    input reset,
    input clk_reset,

    input logic [3:0] total_id,
    input logic [7:0] total_od,
    input logic [8:0] total_width,
    input logic [8:0] total_height,
    input logic total_size_type,
    input logic wen,

    input input_mem_scan_mode,
    input [1:0] output_mem_scan_mode,
    // two output share the same scan_mode, but different from input scan_mode
    input [7:0] scan_addr,
    // four sram share the same scan_address
    input [511:0] data_mem_scan_in,
    input [511:0] weight_mem_scan_in,

    output [511:0] output_mem1_scan_out,
    output [511:0] output_mem2_scan_out,

    output logic conv_completed

);

    logic clk;
    always_ff @(posedge mem_clk or posedge clk_reset) begin
        if (clk_reset) clk <= 0;
        else clk <= ~clk;
    end

    logic [7:0] weight_od1;
    logic [3:0] weight_id;
    logic [7:0] input_addr_1;
    logic [7:0] input_addr_2;
    logic size_type;
    logic [7:0] block_cnt;
    logic [3:0] current_id;
    logic input_request;

    logic signed [13:0] data_tile_1_ctrl [5:0][5:0];
    logic signed [13:0] data_tile_2_ctrl [5:0][5:0];
    logic [7:0] data_addr_1_ctrl;
    logic [7:0] data_addr_2_ctrl;
    logic data_valid_1_ctrl;
    logic data_valid_2_ctrl;
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
    logic [7:0] result_address_0;
    logic [7:0] result_address_1;
    logic [7:0] result_address_2;
    logic [7:0] result_address_3;
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

        .weight_od1_o(weight_od1),

        .input_addr_o_1(input_addr_1),
        .input_addr_o_2(input_addr_2),
        .size_type_o(size_type),
        .block_cnt_o(block_cnt),
        .current_id_o(current_id),
        .input_request_o(input_request),

        .conv_completed(conv_completed)
    );


    weight_mem_controller_top weight_mem_controller_top_0(
        .clk(clk),
        .reset(reset),

        .total_od_i(total_od),
        .weight_od1_i(weight_od1),
        .weight_id_i(current_id),
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

        .input_addr_i_1(input_addr_1),
        .input_addr_i_2(input_addr_2),
        .size_type_i(size_type),
        .block_cnt_i(block_cnt),
        .current_id_i(current_id),
        .input_request_i(input_request),

        .scan_in(data_mem_scan_in),
        .scan_mode(input_mem_scan_mode),
        .scan_addr(scan_addr),

        .result_tile_o_1(data_tile_1_ctrl),
        .result_tile_o_2(data_tile_2_ctrl),
        .pe_data_addr_o_1(data_addr_1_ctrl),
        .pe_data_addr_o_2(data_addr_2_ctrl),
        .data_valid_o_1(data_valid_1_ctrl),
        .data_valid_o_2(data_valid_2_ctrl),
        .size_type_o(size_type_ctrl),
        .block_cnt_o(block_cnt_ctrl)
    );

    PE pe_0(
        .clk(clk),
        .reset(reset),

        .data_tile_i(data_tile_1_ctrl),
        .data_valid_i(data_valid_1_ctrl),
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
        .data_valid_i(data_valid_2_ctrl),
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

    CIM_mem_top CIM_mem_top_0(
        .mem_clk(mem_clk),
        .clk(clk),

        .PE_tile_i_1(result_tile_0),
        .PE_addr_i_1(result_address_0),
        .PE_valid_i_1(result_valid_0),

        .PE_tile_i_2(result_tile_1),
        .PE_addr_i_2(result_address_1),
        .PE_valid_i_2(result_valid_1),

        .scan_in(512'b0),
        .scan_addr(scan_addr),
        .scan_mode(output_mem_scan_mode),
        .scan_out(output_mem1_scan_out)
    );

    CIM_mem_top CIM_mem_top_1(
        .mem_clk(mem_clk),
        .clk(clk),

        .PE_tile_i_1(result_tile_2),
        .PE_addr_i_1(result_address_2),
        .PE_valid_i_1(result_valid_2),

        .PE_tile_i_2(result_tile_3),
        .PE_addr_i_2(result_address_3),
        .PE_valid_i_2(result_valid_3),

        .scan_in(512'b0),
        .scan_addr(scan_addr),
        .scan_mode(output_mem_scan_mode),
        .scan_out(output_mem2_scan_out)
    );


endmodule
