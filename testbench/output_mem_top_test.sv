module output_mem_top_test;
    logic mem_clk;
    logic clk;

    logic [511:0] scan_in;
    logic [7:0] scan_addr;
    logic [1:0] scan_mode;
    logic [511:0] scan_out;

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


    output_mem_top u_output_mem_top (
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


    always begin
        #10 clk = ~clk;  
    end

    always begin
        #5 mem_clk = ~mem_clk;  
    end

    initial begin
        clk = 0;
        mem_clk = 0;
        scan_mode = 0;
        scan_in = 512'h0;
        scan_addr = 8'h0;
        data_1_in = '0;
        data_2_in = '0;
        addr_1_in = 8'h0;
        addr_2_in = 8'h1;
        package_1_valid_in = 1'b0;
        package_2_valid_in = 1'b0;

        #10;
        scan_mode = 2'b0;      

        for (int i = 0; i < 128; i++) begin
            scan_in = 0;
            scan_addr = i;
            #10;
        end

        scan_mode = 2'b1; // start load and store
        @(negedge mem_clk);
        addr_1_in = 8'h5;
        addr_2_in = 8'hA;
        package_1_valid_in = 1'b1;
        package_2_valid_in = 1'b1;

        @(negedge mem_clk);
        addr_1_in = 8'h1;
        addr_2_in = 8'h9;
        package_1_valid_in = 1'b1;
        package_2_valid_in = 1'b1;

        @(negedge mem_clk);
        addr_1_in = 8'h5;
        addr_2_in = 8'hB;
        package_1_valid_in = 1'b1;
        package_2_valid_in = 1'b1;

        #40;
        scan_mode = 2'b11;
        // start to scan out

        $finish;

    end














endmodule

// module output_mem_top (
//     input logic mem_clk,
//     input logic clk, // clk from the controller

//     input logic [511:0] scan_in,
//     input logic [7:0] scan_addr,
//     input [1:0] scan_mode,
//     output logic [511:0] scan_out,

//     // inputs from the controllers
//     input logic [7:0] addr_1_in,
//     input logic [7:0] addr_2_in,
//     input logic package_1_valid_in,
//     input logic package_2_valid_in,
//     input logic [511:0] data_1_in,
//     input logic [511:0] data_2_in,

//     output logic [511:0] data_1_out,
//     output logic [511:0] data_2_out,
//     output logic [7:0] addr_1_out, // use for debug
//     output logic [7:0] addr_2_out, // use for debug
//     output logic package_1_valid_out,
//     output logic package_2_valid_out

// );
// endmodule