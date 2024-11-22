module memory_reader #(
    parameter WORD_WIDTH  = 512;
    parameter NUM_ROWS = 128;
)(    
    input logic clock,
    input logic reset,
    input logic scan_en,
    input logic [7:0] row_counter_in,
    output logic [WORD_WIDTH-1:0] data_out,
    output logic read_done
);

    logic [WORD_WIDTH-1:0] memory [NUM_ROWS-1:0];
    logic [7:0] row_counter;

    always_ff (posedge clock) begin
        if (reset) begin
                row_counter <= '0;
                data_out <= '0;
                read_done <= '0;
            end else if (scan_en) begin
                data_out <= memory[row_counter_in]; 
                if (row_counter_in < NUM_ROWS - 1) begin
                    read_done <= 1'b0; 
                end else begin
                    read_done <= 1'b1;
                end
            end
    end
endmodule