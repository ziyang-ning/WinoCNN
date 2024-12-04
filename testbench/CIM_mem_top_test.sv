module CIM_mem_top_test;
    logic mem_clk;
    logic clk; // clk from the controller


    // PE inputs
    logic signed [11:0] PE_tile_i_1 [0:5][0:5];
    logic [7:0] PE_od_i_1;
    logic [7:0] PE_addr_i_1;
    logic PE_valid_i_1;
    logic signed [11:0] PE_tile_i_2 [0:5][0:5];
    logic [7:0] PE_od_i_2;
    logic [7:0] PE_addr_i_2;
    logic PE_valid_i_2;

    // off-chip inputs
    logic [511:0] scan_in;
    logic [7:0] scan_addr;
    logic [1:0] scan_mode;
    logic [511:0] scan_out;    

    integer file;            

    CIM_mem_top dut (
        .*
    ); 

    always begin
        #10 clk = ~clk;  
    end

    always begin
        #5 mem_clk = ~mem_clk;
    end

    initial begin
        clk = 1;
        mem_clk = 1;

        scan_mode = 0;
        scan_in = 512'h0;
        scan_addr = 8'h0;
        
        PE_valid_i_1 = 0;
        PE_valid_i_2 = 0;

        PE_addr_i_1 = 8'h0;
        PE_addr_i_2 = 8'h0;

        PE_od_i_1 = 8'h0;
        PE_od_i_2 = 8'h1;



        file = $fopen("output/sram_scan_out.txt", "w");
        

        @(posedge clk);
        scan_mode = 2'b0;
        for (int i = 0; i < 128; i++) begin
            scan_in = i;
            scan_addr = i;
            #20;
        end


        @(posedge clk);
        scan_mode = 2'b1;
        for(int i = 0; i < 6; i++) begin
            for(int j = 0; j < 6; j++) begin
                PE_tile_i_1[i][j] = 12'hCC;
                PE_tile_i_2[i][j] = 12'hDD;
                PE_addr_i_1 = 8'h3;
                PE_addr_i_2 = 8'h4;
                PE_valid_i_1 = 1;
                PE_valid_i_2 = 1;
            end
        end
        
        @(posedge clk);
        for(int i = 0; i < 6; i++) begin
            for(int j = 0; j < 6; j++) begin
                PE_tile_i_1[i][j] = 12'hAA;
                PE_tile_i_2[i][j] = 12'hBB;
                PE_addr_i_1 = 8'h5;
                PE_addr_i_2 = 8'h6;
                PE_valid_i_1 = 1;
                PE_valid_i_2 = 1;
            end
        end

        @(posedge clk);
        for(int i = 0; i < 6; i++) begin
            for(int j = 0; j < 6; j++) begin
                PE_tile_i_1[i][j] = 12'hAA;
                PE_tile_i_2[i][j] = 12'hBB;
                PE_addr_i_1 = 8'h5;
                PE_addr_i_2 = 8'h6;
                PE_valid_i_1 = 0;
                PE_valid_i_2 = 0;
            end
        end

        #100
        @(posedge clk);
        // scan out all value from SRAM to a txt file
        scan_mode = 2'b11;
        for(int i = 0; i < 128; i++) begin
            scan_addr = i;
            #20;
            // $fwrite(file, "Address %0d: %h\n", i, scan_out);
            $fwrite(file, "%h\n", scan_out);
        end

        $fclose(file);

        #100;
        $finish;
    end

endmodule
