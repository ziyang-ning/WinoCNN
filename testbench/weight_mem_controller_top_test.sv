module data_mem_top_test;
    logic clk;
    logic reset;
    logic [7:0] total_od_i;
    logic [7:0] weight_od1_i;
    logic [3:0] weight_id_i;
    logic weight_main_valid_i;

    logic [511:0] scan_in;
    logic scan_mode;
    logic [7:0] scan_addr;

    logic signed [11:0] result_tile_o_1 [5:0][5:0];
    logic signed [11:0] result_tile_o_2 [5:0][5:0];
    logic weight_valid_o_1;
    logic weight_valid_o_2;
    logic [7:0] weight_od1_o;
    logic [7:0] weight_od2_o;


    weight_mem_controller_top weight_mem_controller_top_0 (
        .clk(clk),
        .reset(reset),
        .total_od_i(total_od_i),
        .weight_od1_i(weight_od1_i),
        .weight_id_i(weight_id_i),
        .weight_main_valid_i(weight_main_valid_i),
        .scan_in(scan_in),
        .scan_mode(scan_mode),
        .scan_addr(scan_addr),
        .result_tile_o_1(result_tile_o_1),
        .result_tile_o_2(result_tile_o_2),
        .weight_valid_o_1(weight_valid_o_1),
        .weight_valid_o_2(weight_valid_o_2),
        .weight_od1_o(weight_od1_o),
        .weight_od2_o(weight_od2_o)
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

        total_od_i = 8'h25;
        weight_od1_i = 8'h0;
        weight_id_i = 4'h0;
        weight_main_valid_i = 1'b0;



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
        weight_main_valid_i = 1'b1;       
        weight_od1_i = 8'h2;
        weight_id_i = 4'h0;

        @(negedge clk);
        weight_main_valid_i = 1'b0;       
        weight_od1_i = 8'h2;
        weight_id_i = 4'h0;


        @(negedge clk);
        weight_main_valid_i = 1'b1;       
        weight_od1_i = 8'h1;
        weight_id_i = 4'h1;

        @(negedge clk);
        weight_main_valid_i = 1'b0;       
        weight_od1_i = 8'h1;
        weight_id_i = 4'h1;
        #50;


        $display("Pass!");
        $finish;
    end

endmodule
