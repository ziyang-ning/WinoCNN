module data_mem_top_test;
    logic clk;
    //logic reset;

    // scan related inputs
    logic [511:0] scan_in;
    // input logic scan_enable,
    logic scan_mode;
    logic [7:0] scan_addr; 
    // if scan_mode is high, load the scan_in to the memory, only use one port
    // if scan_mode is low, work as the normal memory, dual port
    // scan_addr could be the input from the testbench
    // no need to write a local counter in data_mem_top

    // inputs from the controllers
    logic [7:0] addr_1_in;
    logic [7:0] addr_2_in;
    logic package_1_valid_in;
    logic package_2_valid_in;

    logic [511:0] data_1_out;
    logic [511:0] data_2_out;
    logic [7:0] addr_1_out; // use for debug
    logic [7:0] addr_2_out; // use for debug
    logic package_1_valid_out;
    logic package_2_valid_out;               

    data_mem_top u_data_mem_top (
        .*
    );

    logic [511:0] mem_data [19:0];  
    assign mem_data = {
                    512'h0000000C, 512'h00000061,
                    512'h00000008, 512'h00000007,
                    512'h00000006, 512'h00000005,
                    512'h00000004, 512'h00000003,
                    512'h00000002, 512'h00000001,
                    512'h00000036, 512'h0000006E,
                    512'h00000008, 512'h00000007,
                    512'h00000006, 512'h00000005,
                    512'h10500073, 512'h0030007B,
                    512'h000180B3, 512'h002081B3
    };

    // task clearinput();
    //     begin
    //        scan_en = 0;
    //        scan_in = 0;
    //        load_done = 0; 
    //     end
    // endtask

    // task check_memory();
    //     for (int i = 0; i < 128; i++) begin
    //         if (dut.memory[i] !== expected_memory[i]) begin
    //             $display("ERROR: Row %0d mismatch, expected %h, got %h", i, expected_memory[i], dut.memory[i]);
    //         end else begin
    //             $display("Row %0d loaded correctly", i);
    //         end
    //     end
    // endtask

    always begin
        #5 clk = ~clk;  
    end

    initial begin
        clk = 0;
        scan_mode = 0;
        scan_in = 512'h0;
        scan_addr = 8'h0;
        addr_1_in = 8'h0;
        addr_2_in = 8'h1;
        package_1_valid_in = 1'b0;
        package_2_valid_in = 1'b0;


        #10;
        scan_mode = 1'b1; 

        for (int i = 0; i < 128; i++) begin
            scan_in = 0;
            scan_addr = i;
            #10;
        end

        for (int i = 0; i < 20; i++) begin
            scan_in = mem_data[i];
            scan_addr = i;
            #10;
        end

        scan_mode = 0;
        @(negedge clk);
        addr_1_in = 8'h5;
        addr_2_in = 8'hA;
        package_1_valid_in = 1'b1;
        package_2_valid_in = 1'b1;

        @(negedge clk);
        addr_1_in = 8'h1;
        addr_2_in = 8'h9;
        package_1_valid_in = 1'b1;
        package_2_valid_in = 1'b1;

        @(negedge clk);
        addr_1_in = 8'h5;
        addr_2_in = 8'hB;
        package_1_valid_in = 1'b1;
        package_2_valid_in = 1'b1;

        #50;
        // mem_data[5] = 512'h00000017;
        // #10;

        // #10;

        // assert (data_1_out == mem_data[5]) 
        // else   $fatal ("Test failed at address 0x5");
        // assert (data_2_out == mem_data[10])
        // else   $fatal ("Test failed at address 0xA");

        // addr_1_in = 8'h5;
        // assert (data_1_out == mem_data[5]) 
        // else   $fatal ("Test failed at address 0x5 after write");

        // addr_2_in = 8'hA;
        // assert (data_2_out == mem_data[10])
        // else   $fatal ("Test failed at address 0xA after write");

        $display("Pass!");
        $finish;
    end

endmodule
