module top_test;
    integer file_data;
    integer file_weight;
    integer file_out1;
    integer file_out2;
    integer scan_data;
    integer scan_weight;
    
    logic clk;
    logic mem_clk;
    logic reset;

    logic [3:0] total_id;
    logic [7:0] total_od;
    logic [8:0] total_width;
    logic [8:0] total_height;
    logic total_size_type;
    logic wen;

    logic input_mem_scan_mode;
    logic [1:0] output_mem_scan_mode;
    logic [7:0] scan_addr;
    logic [511:0] data_mem_scan_in;
    logic [511:0] weight_mem_scan_in;

    logic [511:0] output_mem1_scan_out;
    logic [511:0] output_mem2_scan_out;

    logic conv_completed;

    top top_0 (
        .clk(clk),
        .mem_clk(mem_clk),
        .reset(reset),

        .total_id(total_id),
        .total_od(total_od),
        .total_width(total_width),
        .total_height(total_height),
        .total_size_type(total_size_type),
        .wen(wen),

        .input_mem_scan_mode(input_mem_scan_mode),
        .output_mem_scan_mode(output_mem_scan_mode),
        .scan_addr(scan_addr),
        .data_mem_scan_in(data_mem_scan_in),
        .weight_mem_scan_in(weight_mem_scan_in),

        .output_mem1_scan_out(output_mem1_scan_out),
        .output_mem2_scan_out(output_mem2_scan_out),

        .conv_completed(conv_completed)
    );


    always begin
        #10 clk = ~clk;  
    end

    always begin
        #5 mem_clk = ~mem_clk;  
    end

    initial begin
        file_data = $fopen("test1/data_scan_in.txt", "r");
        file_weight = $fopen("test1/weight_scan_in.txt", "r");
        file_out1 = $fopen("test1/output_mem1_scan_out.txt", "w");
        file_out2 = $fopen("test1/output_mem2_scan_out.txt", "w");

        clk = 1;
        mem_clk = 1;
        reset = 1;

        input_mem_scan_mode = 0;
        output_mem_scan_mode = 2'b00;
        data_mem_scan_in = 512'h0;
        weight_mem_scan_in = 512'h0;
        scan_addr = 8'h0;

        total_id = 2;
        total_od = 4;
        total_width = 9'd30;
        total_height = 9'd30;
        total_size_type = 1'b0;
        wen = 0;


        @(negedge clk);
        input_mem_scan_mode = 1;
        for (int i = 0; i < 128; i++) begin
            scan_data = $fscanf(file_data, "%d\n", data_mem_scan_in);
            scan_weight = $fscanf(file_weight, "%d\n", weight_mem_scan_in);
            scan_addr = i;
            #20;
        end

        @(posedge clk);
        reset = 0;
        input_mem_scan_mode = 0;
        output_mem_scan_mode = 2'b01;
        wen = 1;

        #4000;


        @(posedge clk);
        // scan out all value from SRAM to a txt file
        output_mem_scan_mode = 2'b11;
        for(int i = 0; i < 128; i++) begin
            scan_addr = i;
            #20;
            $fwrite(file_out1, "Address %0d: %h\n", i, output_mem1_scan_out);
            $fwrite(file_out2, "Address %0d: %h\n", i, output_mem2_scan_out);
        end

        $fclose(file_data);
        $fclose(file_weight);
        $fclose(file_out1);
        $fclose(file_out2);

        $finish;


    end














endmodule
