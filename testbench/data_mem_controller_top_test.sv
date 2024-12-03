


module data_mem_top_test;
    logic clk;
    logic reset;

    logic [3:0] input_id_i;
    logic input_prepare_i;
    logic [7:0] block_width_i;
    logic [7:0] block_height_i;
    logic size_type_i;  


    logic [511:0] scan_in;
    logic scan_mode;
    logic [7:0] scan_addr;

    logic signed [13:0] result_tile_o_1 [5:0][5:0];
    logic signed [13:0] result_tile_o_2 [5:0][5:0];
    logic [7:0] pe_data_addr_o_1;
    logic [7:0] pe_data_addr_o_2;
    logic data_valid_o;
    logic size_type_o;
    logic [7:0] block_cnt;

    logic loop_finished_o;



    data_mem_controller_top data_mem_controller_top_1 (
        .clk(clk),
        .reset(reset),

        .input_id_i(input_id_i),
        .input_prepare_i(input_prepare_i),
        .block_width_i(block_width_i),
        .block_height_i(block_height_i),
        .size_type_i(size_type_i),

        .scan_in(scan_in),
        .scan_mode(scan_mode),
        .scan_addr(scan_addr),

        .loop_finished_o(loop_finished_o),

        .result_tile_o_1(result_tile_o_1),
        .result_tile_o_2(result_tile_o_2),
        .pe_data_addr_o_1(pe_data_addr_o_1),
        .pe_data_addr_o_2(pe_data_addr_o_2),
        .data_valid_o(data_valid_o),
        .size_type_o(size_type_o),
        .block_cnt(block_cnt)
    );


    always begin
        #5 clk = ~clk;  
    end

    initial begin
        clk = 1;
        reset = 1;

        scan_mode = 0;
        scan_in = 512'h0;
        scan_addr = 8'h0;

        input_id_i = 4'h0;
        input_prepare_i = 1'b0;
        block_width_i = 8'd5;
        block_height_i = 8'd5;
        size_type_i = 1'b0;




        @(posedge clk);
        reset = 0;
        scan_mode = 1'b1; 

        for (int i = 0; i < 128; i++) begin
            scan_in = 0;
            scan_addr = i;
            #10;
        end

        for (int i = 0; i < 128; i++) begin
            scan_in = i;
            scan_addr = i;
            #10;
        end

        // in testbench mush give input at negedge
        // but if it is a reg, it's OK to give input at posedge

        @(negedge clk);
        scan_mode = 1'b0;
        input_id_i = 4'h0;
        input_prepare_i = 1'b1;
        block_width_i = 8'd5;
        block_height_i = 8'd5;
        size_type_i = 1'b0;

        #300;

        @(negedge clk);
        scan_mode = 1'b0;
        input_id_i = 4'h2;
        input_prepare_i = 1'b1;
        block_width_i = 8'd5;
        block_height_i = 8'd5;
        size_type_i = 1'b0;     
    

        #300;
        $display("Pass!");
        $finish;
    end

endmodule



// module data_mem_controller_top (
//     // clock here also work as scan_clk
//     input logic clk,
//     input logic reset,

//     // input from main controller
//     input logic [3:0] input_id_i,
//     input logic input_prepare_i,
//     input logic [7:0] block_width_i,
//     input logic [7:0] block_height_i,
//     input logic size_type_i,

//     // scan related inputs
//     input logic [511:0] scan_in,
//     input logic scan_mode,
//     input logic [7:0] scan_addr, 

//     // output to the main controller
//     output logic loop_finished_o,

//     // outputs to PE arrays
//     output logic signed [13:0] result_tile_o_1 [5:0][5:0],
//     output logic signed [13:0] result_tile_o_2 [5:0][5:0],
//     output logic [7:0] pe_data_addr_o_1,
//     output logic [7:0] pe_data_addr_o_2,
//     output logic data_valid_o,
//     output logic size_type_o,
//     output logic [7:0] block_cnt


// );
