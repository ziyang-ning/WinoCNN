`timescale 1 ns/1 ps
module memory_loader #(
    parameter WORD_WIDTH  = 512;
    parameter NUM_ROWS = 128;
    parameter DATA_WIDTH = 288;
)(
    input logic clock,
    input logic reset,
    input logic scan_en,
    input logic [DATA_WIDTH-1:0] scan_in, 
    output logic [WORD_WIDTH-1:0] memory [NUM_ROWS-1:0],
    output logic load_done
);
    logic [$clog2(NUM_ROWS)-1:0] row_counter;

    initial begin
        load_done = '0;
        row_counter = '0;
        foreach (memory[i]) memory[i] = '0;
    end 

    always_ff @(posedge clock) begin
        if (reset) begin
            load_done <= '0;
            row_counter <= '0;
        end else if (scan_en) begin
            if (row_counter < NUM_ROWS) begin
                memory[row_counter] <= scan_in;
                row_counter <= row_counter + 1'b1;
            end else begin
                    load_done <= 1'b1;
            end
        end
    end
endmodule
