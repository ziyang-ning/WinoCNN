module data_mem_top (
    // clock here also work as scan_clk
    input logic clk,
    //input logic reset,

    // scan related inputs
    input logic [511:0] scan_in,
    // input logic scan_enable,
    input logic scan_mode,
    input logic [7:0] scan_addr, 
    // if scan_mode is high, load the scan_in to the memory, only use one port
    // if scan_mode is low, work as the normal memory, dual port
    // scan_addr could be the input from the testbench
    // no need to write a local counter in data_mem_top

    // inputs from the controllers
    input logic [7:0] addr_1_in,
    input logic [7:0] addr_2_in,
    input logic package_1_valid_in,
    input logic package_2_valid_in,

    output logic [511:0] data_1_out,
    output logic [511:0] data_2_out,
    output logic [7:0] addr_1_out, // use for debug
    output logic [7:0] addr_2_out, // use for debug
    output logic package_1_valid_out,
    output logic package_2_valid_out

);

    // declare the SRAM wires
    logic sram_WEN_1;
    logic sram_WEN_2;
    logic [6:0] sram_addr_1;
    logic [6:0] sram_addr_2;
    logic [511:0] sram_input_1;
    logic [511:0] sram_input_2;
    logic [511:0] sram_output_1; // output
    logic [511:0] sram_output_2; // output

    always_comb begin 
        sram_WEN_1 = ~scan_mode;
        sram_WEN_2 = 1; // never write to the second port
        sram_addr_1 = scan_mode ? scan_addr: addr_1_in;
        sram_addr_2 = scan_mode ? scan_addr: addr_2_in;
        sram_input_1 = scan_mode ? scan_in: sram_input_1;
        sram_input_2 = scan_mode ? scan_in: sram_input_2;

        // bypass signal, because sram read is a comb logic
        package_1_valid_out = package_1_valid_in;
        package_2_valid_out = package_2_valid_in;
        data_1_out = sram_output_1;
        data_2_out = sram_output_2;
        addr_1_out = addr_1_in;
        addr_2_out = addr_2_in;
    end

    // CE is just the clk
    // CSB should be low, otherwise the data and address inputs are disabled
    // OEB should be low, otherwise the output will be z state
    // WEB = 0, write enable, WEB = 1, read enable
    SRAM data_SRAM(
        .CE1(clk),
        .CE2(clk),
        .WEB1(sram_WEN_1),
        .WEB2(sram_WEN_2),
        .OEB1(1'b0),
        .OEB2(1'b0),
        .CSB1(1'b0),
        .CSB2(1'b0),
        .A1(sram_addr_1),
        .A2(sram_addr_2),
        .I1(sram_input_1),
        .I2(sram_input_2),
        .O1(sram_output_1),
        .O2(sram_output_2)
    );


endmodule

