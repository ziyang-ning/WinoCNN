module controller_top_test;

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
    logic [7:0] scan_addr;
    logic [511:0] data_mem_scan_in;
    logic [511:0] weight_mem_scan_in;
    logic conv_completed;



    controller_top top_0 (
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
        .scan_addr(scan_addr),
        .data_mem_scan_in(data_mem_scan_in),
        .weight_mem_scan_in(weight_mem_scan_in),
        .conv_completed(conv_completed)    

    );

    always begin
        #5 clk = ~clk;  
    end

    initial begin
        clk = 1;
        mem_clk = 1;
        reset = 1;

        input_mem_scan_mode = 1;
        data_mem_scan_in = 512'h1;
        weight_mem_scan_in = 512'h1;
        scan_addr = 8'h0;

        total_id = 2;
        total_od = 4;
        total_width = 9'd30;
        total_height = 9'd30;
        total_size_type = 1'b0;
        wen = 0;

        #20;
        @(negedge clk);
        reset = 1;
        input_mem_scan_mode = 1'b1; 

        for (int i = 0; i < 128; i++) begin
            data_mem_scan_in = i;
            weight_mem_scan_in = i;
            scan_addr = i;
            #10;
        end

        @(posedge clk);
        reset = 0;
        input_mem_scan_mode = 0;
        wen = 1;

        #4000;
        $finish;


    end





endmodule


