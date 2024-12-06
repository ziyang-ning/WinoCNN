module output_mem_top (
    input logic mem_clk,
    input logic clk, // clk from the controller

    input logic [511:0] scan_in,
    input logic [7:0] scan_addr,
    input [1:0] scan_mode,
    output logic [511:0] scan_out,

    // inputs from the PEs
    // input bypass to the output memory
    input logic [7:0] PE_addr_1_in,
    input logic [7:0] PE_addr_2_in,
    input logic PE_package_1_valid_in,
    input logic PE_package_2_valid_in,
    // PE don's need to send the data to memory
    // input logic [511:0] PE_data_1_in,
    // input logic [511:0] PE_data_2_in,

    // inputs from the CIM, write back the result to the memory
    input logic [7:0] CIM_addr_1_in,
    input logic [7:0] CIM_addr_2_in,
    input logic CIM_package_1_valid_in,
    input logic CIM_package_2_valid_in,
    input logic [511:0] CIM_data_1_in,
    input logic [511:0] CIM_data_2_in,


    // output to the CIM, the result read from the memory
    output logic [511:0] CIM_data_1_out,
    output logic [511:0] CIM_data_2_out,
    output logic [7:0] CIM_addr_1_out, // use for debug
    output logic [7:0] CIM_addr_2_out, // use for debug
    output logic CIM_package_1_valid_out,
    output logic CIM_package_2_valid_out

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

    scan_mode_t local_scan_mode_reg;
    // make sure the packet valid bit will be open for one mem_clk cycle
    always_ff @(posedge mem_clk) begin
        local_scan_mode_reg <= local_scan_mode;
    end

    logic CIM_package_1_valid_in_reg;
    logic CIM_package_2_valid_in_reg;

    always_ff @(posedge mem_clk) begin
        CIM_package_1_valid_in_reg <= CIM_package_1_valid_in;
        CIM_package_2_valid_in_reg <= CIM_package_2_valid_in;
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

        CIM_package_1_valid_out = (local_scan_mode_reg == 2'b10) && (PE_package_1_valid_in == 1'b1);
        CIM_package_2_valid_out = (local_scan_mode_reg == 2'b10) && (PE_package_2_valid_in == 1'b1);
        CIM_data_1_out = 512'b0;
        CIM_data_2_out = 512'b0;
        CIM_addr_1_out = 7'b0;
        CIM_addr_2_out = 7'b0;
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

                // package_1_valid_out = 1'b0;
                // package_2_valid_out = 1'b0;
                CIM_data_1_out = 512'b0;
                CIM_data_2_out = 512'b0;
                CIM_addr_1_out = 7'b0;
                CIM_addr_2_out = 7'b0;
                scan_out = 512'b0;
            end
            LOAD: begin
                // get input from the PEs, read the address
                sram_clk = mem_clk;
                sram_WEN_1 = 1'b1;
                sram_WEN_2 = 1'b1;
                sram_addr_1 = PE_package_1_valid_in ? PE_addr_1_in : 7'b0;
                sram_addr_2 = PE_package_2_valid_in ? PE_addr_2_in : 7'b0;
                sram_input_1 = 512'b0;
                sram_input_2 = 512'b0;

                // package_1_valid_out = (local_scan_mode_reg == 1'b1);
                // package_2_valid_out = (local_scan_mode_reg == 1'b1);
                CIM_data_1_out = sram_output_1;
                CIM_data_2_out = sram_output_2;
                CIM_addr_1_out = PE_addr_1_in;
                CIM_addr_2_out = PE_addr_2_in;
                scan_out = 512'b0;
            end
            WRITE: begin
                sram_clk = mem_clk;
                // should not write into the sram if the package is not valid
                // write the package from CIM to the memory
                sram_WEN_1 = ~CIM_package_1_valid_in_reg;
                sram_WEN_2 = ~CIM_package_2_valid_in_reg;
                sram_addr_1 = CIM_package_1_valid_in_reg ? CIM_addr_1_in : 7'b0;
                sram_addr_2 = CIM_package_2_valid_in_reg ? CIM_addr_2_in : 7'b0;
                sram_input_1 = CIM_package_1_valid_in_reg ? CIM_data_1_in : 512'b0;
                sram_input_2 = CIM_package_2_valid_in_reg ? CIM_data_2_in : 512'b0;

                // package_1_valid_out = (local_scan_mode_reg == 1'b1);
                // package_2_valid_out = (local_scan_mode_reg == 1'b1);
                CIM_data_1_out = sram_output_1;
                CIM_data_2_out = sram_output_2;
                CIM_addr_1_out = PE_addr_1_in;
                CIM_addr_2_out = PE_addr_2_in;
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

                // package_1_valid_out = 1'b0;
                // package_2_valid_out = 1'b0;
                CIM_data_1_out = 512'b0;
                CIM_data_2_out = 512'b0;
                CIM_addr_1_out = 7'b0;
                CIM_addr_2_out = 7'b0;
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

