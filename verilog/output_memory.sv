module output_mem_top (
    input logic mem_clk,
    input logic clk, // clk from the controller

    input logic [511:0] scan_in,
    input logic [7:0] scan_addr,
    input [1:0] scan_mode,
    output logic [511:0] scan_out,

    // inputs from the controllers
    input logic [7:0] addr_1_in,
    input logic [7:0] addr_2_in,
    input logic package_1_valid_in,
    input logic package_2_valid_in,
    input logic [511:0] data_1_in,
    input logic [511:0] data_2_in,

    output logic [511:0] data_1_out,
    output logic [511:0] data_2_out,
    output logic [7:0] addr_1_out, // use for debug
    output logic [7:0] addr_2_out, // use for debug
    output logic package_1_valid_out,
    output logic package_2_valid_out

);

    typedef enum logic [1:0] { 
        SCAN_IN,
        LOAD,
        WRITE,
        SCAN_OUT
    } scan_mode_t;


    scan_mode_t local_scan_mode; // use to distinguish the load and write mode
    always_comb begin
        if (scan_mode == 2'b0) begin
            local_scan_mode = SCAN_IN;
        end else if (scan_mode == 2'b11) begin
            local_scan_mode = SCAN_OUT;
        end else begin
            if (clk == 1'b1) begin
                local_scan_mode = LOAD;
            end else begin
                local_scan_mode = WRITE;
            end
        end
    end

    // declare the SRAM wires
    logic sram_clk;
    logic sram_WEN_1;
    logic sram_WEN_2;
    logic [6:0] sram_addr_1;
    logic [6:0] sram_addr_2;
    logic [511:0] sram_input_1;
    logic [511:0] sram_input_2;
    logic [511:0] sram_output_1; // output
    logic [511:0] sram_output_2; // output

    always_comb begin
        // init all outputs to 0

        sram_clk = 1'b0;
        sram_WEN_1 = 1'b0;
        sram_WEN_2 = 1'b0;
        sram_addr_1 = 7'b0;
        sram_addr_2 = 7'b0;
        sram_input_1 = 512'b0;
        sram_input_2 = 512'b0;

        package_1_valid_out = 1'b0;
        package_2_valid_out = 1'b0;
        data_1_out = 512'b0;
        data_2_out = 512'b0;
        addr_1_out = 7'b0;
        addr_2_out = 7'b0;
        scan_out = 512'b0;


        case (local_scan_mode)
            SCAN_IN: begin
                sram_clk = clk;
                sram_WEN_1 = 1'b0; // only write into the first port
                sram_WEN_2 = 1'b1;
                sram_addr_1 = scan_addr;
                sram_addr_2 = 7'b0;
                sram_input_1 = scan_in;
                sram_input_2 = 512'b0;

                package_1_valid_out = 1'b0;
                package_2_valid_out = 1'b0;
                data_1_out = 512'b0;
                data_2_out = 512'b0;
                addr_1_out = 7'b0;
                addr_2_out = 7'b0;
                scan_out = 512'b0;
            end
            LOAD: begin
                sram_clk = mem_clk;
                sram_WEN_1 = 1'b1;
                sram_WEN_2 = 1'b1;
                sram_addr_1 = package_1_valid_in ? addr_1_in : 7'b0;
                sram_addr_2 = package_2_valid_in ? addr_2_in : 7'b0;
                sram_input_1 = 512'b0;
                sram_input_2 = 512'b0;

                package_1_valid_out = package_1_valid_in;
                package_2_valid_out = package_2_valid_in;
                data_1_out = sram_output_1;
                data_2_out = sram_output_2;
                addr_1_out = addr_1_in;
                addr_2_out = addr_2_in;
                scan_out = 512'b0;
            end
            WRITE: begin
                sram_clk = mem_clk;
                // should not write into the sram if the package is not valid
                sram_WEN_1 = ~package_1_valid_in;
                sram_WEN_2 = ~package_2_valid_in;
                sram_addr_1 = package_1_valid_in ? addr_1_in : 7'b0;
                sram_addr_2 = package_2_valid_in ? addr_2_in : 7'b0;
                sram_input_1 = package_1_valid_in ? data_1_in : 512'b0;
                sram_input_2 = package_2_valid_in ? data_2_in : 512'b0;

                package_1_valid_out = package_1_valid_in;
                package_2_valid_out = package_2_valid_in;
                data_1_out = sram_output_1;
                data_2_out = sram_output_2;
                addr_1_out = addr_1_in;
                addr_2_out = addr_2_in;
                scan_out = 512'b0;

            end
            SCAN_OUT: begin
                sram_clk = clk;
                sram_WEN_1 = 1'b1;
                sram_WEN_2 = 1'b1;
                sram_addr_1 = scan_addr;
                sram_addr_2 = 7'b0;
                sram_input_1 = 512'b0;
                sram_input_2 = 512'b0;

                package_1_valid_out = 1'b0;
                package_2_valid_out = 1'b0;
                data_1_out = 512'b0;
                data_2_out = 512'b0;
                addr_1_out = 7'b0;
                addr_2_out = 7'b0;
                scan_out = sram_output_1;
            end

        endcase


    end

    // CE is just the clk
    // CSB should be low, otherwise the data and address inputs are disabled
    // OEB should be low, otherwise the output will be z state
    // WEB = 0, write enable, WEB = 1, read enable
    SRAM output_SRAM(
        .CE1(sram_clk),
        .CE2(sram_clk),
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

