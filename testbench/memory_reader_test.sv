module memory_reader_test;
    logic clock;
    logic reset;
    logic scan_en;
    logic [7:0] row_counter_in;
    logic [511:0] data_out;
    logic scan_done;

    memory_reader #(
        .WORD_WIDTH(512),
        .NUM_ROWS(128)
    ) dut (
        .*
    );

    task clearinput();
        begin
           scan_en = 0;
           row_counter_in = 0;
        end
    endtask

    always begin
        #5 clock = ~clock; 
    end

    initial begin
        clock = 0;
        reset = 0;
        clearinput();
        
        $display("\033[32mApplying reset\033[0m");
        #10;
        reset = 1;
        
        $display("\033[32mStarting scan-out process\033[0m");
        
        integer file;
        file = $fopen("scanned_data.txt", "w");
        
        for (int i = 0; i < NUM_ROWS; i++) begin
            row_counter_in = i;
            scan_en = 1; 
            
            wait(scan_done);
            
            $fwrite(file, "Row %0d: %h\n", i, data_out);
            $display("Scanned Row %0d: %h", i, data_out);
            
            scan_en = 0;
            #10; 
        end
        
        $fclose(file);
        $display("\033[32m@@ Testbench completed.\033[0m");
        $finish;
    end

endmodule
