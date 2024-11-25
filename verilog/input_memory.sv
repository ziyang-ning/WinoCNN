module data_mem_top (
    // clock here also work as scan_clk
    input logic clk,
    input logic reset,

    // scan related inputs
    input logic [511:0] scan_in,
    input logic scan_enable,
    input logic scan_mode,
    // if scan_mode is high, load the scan_in to the memory, only use one port
    // if scan_mode is low, work as the normal memory, dual port

    // inputs from the controllers
    input logic [7:0] addr_1_in,
    input logic [7:0] addr_2_in,
    input logic addr_1_valid_in,
    input logic addr_2_valid_in,

    output logic [511:0] data_1_out,
    output logic [511:0] data_2_out,
    output logic [7:0] addr_1_out, // use for debug
    output logic [7:0] addr_2_out, // use for debug
    output logic data_1_valid_out,
    output logic data_2_valid_out,

);
    // if scan_enable is high, load the scan_in to the memory, only use one port
    // use a counter to get the addr that we want to load the scan_in
    logic [7:0] scan_addr; // counter for the addr
    always_ff @(posedge clk) begin
        if (reset || ~scan_enable) begin    
            scan_addr <= 7'b0;
        end
        else if (~reset && scan_enable) begin
            scan_addr <= scan_addr + 7'b1;
        end
    end


    // declare the SRAM wires
    logic sram_CEN_1;
    logic sram_CEN_2;
    logic sram_WEN_1;
    logic sram_WEN_2;
    logic [6:0] sram_addr_1;
    logic [6:0] sram_addr_2;
    logic [511:0] sram_d_1;
    logic [511:0] sram_d_2;
    logic [511:0] sram_q_1;
    logic [511:0] sram_q_2;

    // wires need to change later
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
        .I1(sram_d_1),
        .I2(sram_d_2),
        // I is only useful when scan_in
        .O1(sram_q_1),
        .O2(sram_q_2),
    );


endmodule


// CE is just the clk
// CSB should be low, otherwise the data and address inputs are disabled
// OEB should be low, otherwise the output will be z state
// WEB = 0, write enable, WEB = 1, read enable