module CIM_mem_top (
    input logic mem_clk,
    input logic clk, // clk from the controller


    // PE inputs
    input logic signed [11:0] PE_tile_i_1 [0:5][0:5],
    input logic [7:0] PE_addr_i_1,
    input logic PE_valid_i_1,

    input logic signed [11:0] PE_tile_i_2 [0:5][0:5],
    input logic [7:0] PE_addr_i_2,
    input logic PE_valid_i_2,

    // off-chip inputs
    input logic [511:0] scan_in,
    input logic [7:0] scan_addr,
    input [1:0] scan_mode,
    output logic [511:0] scan_out


);
    // wires
    logic [511:0] CIM_data_i_1;
    logic [511:0] CIM_data_i_2;
    logic [7:0] CIM_addr_i_1;
    logic [7:0] CIM_addr_i_2;
    logic CIM_valid_i_1;
    logic CIM_valid_i_2;

    logic [511:0] CIM_data_o_1;
    logic [511:0] CIM_data_o_2;
    logic [7:0] CIM_addr_o_1;
    logic [7:0] CIM_addr_o_2;
    logic CIM_valid_o_1;
    logic CIM_valid_o_2;
    



    output_mem_top output_mem_top_1 (
        .mem_clk(mem_clk),
        .clk(clk),
        .scan_in(scan_in),
        .scan_addr(scan_addr),
        .scan_mode(scan_mode),
        .scan_out(scan_out),

        .PE_addr_1_in(PE_addr_i_1),
        .PE_addr_2_in(PE_addr_i_2),
        .PE_package_1_valid_in(PE_valid_i_1),
        .PE_package_2_valid_in(PE_valid_i_2),

        .CIM_addr_1_in(CIM_addr_i_1),
        .CIM_addr_2_in(CIM_addr_i_2),
        .CIM_package_1_valid_in(CIM_valid_i_1),
        .CIM_package_2_valid_in(CIM_valid_i_2),
        .CIM_data_1_in(CIM_data_i_1),
        .CIM_data_2_in(CIM_data_i_2),

        .CIM_data_1_out(CIM_data_o_1),
        .CIM_data_2_out(CIM_data_o_2),
        .CIM_addr_1_out(CIM_addr_o_1),
        .CIM_addr_2_out(CIM_addr_o_2),
        .CIM_package_1_valid_out(CIM_valid_o_1),
        .CIM_package_2_valid_out(CIM_valid_o_2)
    );


    CIM CIM_1 (
        .PE_tile_i(PE_tile_i_1),
        .PE_addr_i(PE_addr_i_1),
        .PE_valid_i(PE_valid_i_1),

        .memory_data_i(CIM_data_o_1),
        .memory_addr_i(CIM_addr_o_1),
        .memory_valid_i(CIM_valid_o_1),

        .result_o(CIM_data_i_1),
        .result_valid_o(CIM_valid_i_1),
        .result_addr_o(CIM_addr_i_1)
    );

    CIM CIM_2 (
        .PE_tile_i(PE_tile_i_2),
        .PE_addr_i(PE_addr_i_2),
        .PE_valid_i(PE_valid_i_2),

        .memory_data_i(CIM_data_o_2),
        .memory_addr_i(CIM_addr_o_2),
        .memory_valid_i(CIM_valid_o_2),

        .result_o(CIM_data_i_2),
        .result_valid_o(CIM_valid_i_2),
        .result_addr_o(CIM_addr_i_2)
    );


endmodule

