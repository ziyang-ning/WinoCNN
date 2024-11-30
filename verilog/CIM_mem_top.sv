module CIM_mem_top (
    input logic mem_clk,
    input logic clk, // clk from the controller


    // PE inputs
    input logic signed [11:0] PE_tile_i_1 [0:5][0:5],
    input logic [7:0] PE_od_i_1,
    input logic PE_addr_i_1,
    input logic PE_valid_i_1,

    input logic signed [11:0] PE_tile_i_2 [0:5][0:5],
    input logic [7:0] PE_od_i_2,
    input logic PE_addr_i_2,
    input logic PE_valid_i_2,

    // off-chip inputs
    input logic [511:0] scan_in,
    input logic [7:0] scan_addr,
    input [1:0] scan_mode,
    output logic [511:0] scan_out


);

    // Internal variables

    logic [7:0] addr_1_in;
    logic [7:0] addr_2_in;
    logic package_1_valid_in;
    logic package_2_valid_in;
    logic [511:0] data_1_in;
    logic [511:0] data_2_in;

    logic [511:0] data_1_out;
    logic [511:0] data_2_out;
    logic [7:0] addr_1_out;
    logic [7:0] addr_2_out;
    logic package_1_valid_out;
    logic package_2_valid_out;

    logic [511:0] result_o_1;
    logic result_valid_o_1;
    logic [7:0] result_addr_o_1;

    logic [511:0] result_o_2;
    logic result_valid_o_2;
    logic [7:0] result_addr_o_2;

    logic [511:0] PE_tile_i_1_512;
    logic [511:0] PE_tile_i_2_512;

    always_comb begin
        // adjust PE_tile_i_1 into PE_tile_i_1_512
        PE_tile_i_1_512 = 512'b0;
        for (int i = 0; i < 6; i++) begin
            for (int j = 0; j < 6; j++) begin
                PE_tile_i_1_512[(i * 6 + j) * 12 +: 12] = PE_tile_i_1[i][j];
            end
        end
    end

    always_comb begin
        // adjust PE_tile_i_2 into PE_tile_i_2_512
        PE_tile_i_2_512 = 512'b0;
        for (int i = 0; i < 6; i++) begin
            for (int j = 0; j < 6; j++) begin
                PE_tile_i_2_512[(i * 6 + j) * 12 +: 12] = PE_tile_i_2[i][j];
            end
        end
    end

    always_comb begin
        if (clk == 1) begin
            // sram input from PE
            addr_1_in = PE_addr_i_1;
            addr_2_in = PE_addr_i_2;
            package_1_valid_in = 1;
            package_2_valid_in = 1;
            data_1_in = PE_tile_i_1_512;
            data_2_in = PE_tile_i_2_512;


        end else begin 
            // sram input from CIM
            addr_1_in = result_addr_o_1;
            addr_2_in = result_addr_o_2;
            package_1_valid_in = result_valid_o_1;
            package_2_valid_in = result_valid_o_2;
            data_1_in = result_o_1;
            data_2_in = result_o_2;

        end

    end


    output_mem_top output_mem_top_1(
        .mem_clk(mem_clk),
        .clk(clk),

        .scan_in(scan_in),
        .scan_addr(scan_addr),
        .scan_mode(scan_mode),
        .scan_out(scan_out),

        .addr_1_in(addr_1_in),
        .addr_2_in(addr_2_in),
        .package_1_valid_in(package_1_valid_in),
        .package_2_valid_in(package_2_valid_in),
        .data_1_in(data_1_in),
        .data_2_in(data_2_in),

        .data_1_out(data_1_out),
        .data_2_out(data_2_out),
        .addr_1_out(addr_1_out),
        .addr_2_out(addr_2_out),
        .package_1_valid_out(package_1_valid_out),
        .package_2_valid_out(package_2_valid_out)
    );


    CIM CIM_1(
        .PE_tile_i(PE_tile_i_1),
        .PE_od_i(PE_od_i_1),
        .PE_addr_i(PE_addr_i_1),
        .PE_valid_i(PE_valid_i_1),

        .memory_data_i(data_1_out),
        .memory_addr_i(addr_1_out),
        .memory_valid_i(package_1_valid_out),

        .result_o(result_o_1),
        .result_valid_o(result_valid_o_1),
        .result_addr_o(result_addr_o_1)
    );

    CIM CIM_2(
        .PE_tile_i(PE_tile_i_2),
        .PE_od_i(PE_od_i_2),
        .PE_addr_i(PE_addr_i_2),
        .PE_valid_i(PE_valid_i_2),

        .memory_data_i(data_2_out),
        .memory_addr_i(addr_2_out),
        .memory_valid_i(package_2_valid_out),

        .result_o(result_o_2),
        .result_valid_o(result_valid_o_2),
        .result_addr_o(result_addr_o_2)
    );

endmodule



