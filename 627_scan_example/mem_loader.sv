`timescale 1 ns/1 ps
module mem_loader(
    input scan_in,
    input scan_clk,
    input scan_enable,
    input reset,
    output logic sel_out, 
    output logic [31:0] data_out,
    output logic [8:0] addr
);
    logic reset_reg;
    logic [31:0] scan_chain;
    logic [4:0] counter;

    assign data_out = scan_chain;

    always_ff @(posedge scan_clk) begin
        reset_reg <= reset;
    end

    always_ff @(negedge scan_clk) begin
        if (reset || ~scan_enable) begin
            counter <=  5'b11111;
            scan_chain <=  0;
        end
        else begin
            scan_chain[30:0] <=  #1 scan_chain[31:1];
            scan_chain[31] <=  #1 scan_in;
            counter <=  counter + 5'b1;
        end
    end


    always_ff @(posedge scan_clk) begin
        if (reset || ~scan_enable) begin    
            addr <= #1 0;
        end
        else if (counter == 5'b11111 && ~reset && scan_enable) begin
            addr <= #1  addr + 9'b1;
        end
    end

    always_ff @(negedge scan_clk) begin
        sel_out <=  ~(counter == 5'b11110 && ~reset && ~reset_reg && scan_enable);
    end

endmodule