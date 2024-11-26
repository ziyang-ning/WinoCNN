module memory_loader_test;
    logic clock;
    logic reset;
    logic scan_en;
    logic [511:0] scan_in;          
    logic load_done;                

    memory_loader #(
        .WORD_WIDTH(512),
        .NUM_ROWS(128),
        .DATA_WIDTH(512)  
    ) dut (
        .*
    );

    logic [511:0] expected_memory [127:0];  

    task clearinput();
        begin
           scan_en = 0;
           scan_in = 0;
           load_done = 0; 
        end
    endtask

    task check_memory();
        for (int i = 0; i < 128; i++) begin
            if (dut.memory[i] !== expected_memory[i]) begin
                $display("ERROR: Row %0d mismatch, expected %h, got %h", i, expected_memory[i], dut.memory[i]);
            end else begin
                $display("Row %0d loaded correctly", i);
            end
        end
    endtask

    always begin
        #5 clock = ~clock;  
    end

    initial begin
        clock = 0;
        reset = 0;
        clearinput();

        #10;
        reset = 1;

        $readmemh("memory_data.txt", expected_memory);

        #10;
        scan_en = 1'b1;  
        #10;
        scan_en = 1'b0;  

        for (int row = 0; row < 128; row++) begin
            scan_in = expected_memory[row]; 
            #10;  
        end

        #10;
        scan_en = 1;

        check_memory();

        #100;
        $finish;
    end

endmodule
