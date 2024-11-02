module weight_controller (
    // include bot the controller and the weight buffer
    input clk;
    input reset;

    // off-chip input
    input [7:0] total_id_i;
    input [7:0] total_od_i;
    input logic total_size_type_i,
    input logic wen_i, // the enable signal to change the off-chip input

    // input from the main controller
    input logic [7:0] weight_od1_i,
    input logic [7:0] weight_od2_i,
    input logic [3:0] weight_id_i,
    input logic weight_prepare_i,
    input logic weight_start_i,

    // output to the main controller
    output logic [7:0] weight_ready_o,

    // output to the memory, 18 elements in total
    output logic [15:0] weight_addr_o[17:0],

    // input from the memory 
    input logic [15:0] weight_data_i[17:0],
    input logic [15:0] weight_addr_i[17:0],
    input logic weight_valid_i[17:0],

);

    // definition of the local reg to store off-chip input
    logic [3:0] total_id_reg;
    logic [7:0] total_od_reg;
    logic total_size_type_reg;

    // store the off-chip input into local reg
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            total_id_reg  <= 0;
            total_od_reg  <= 0;
            total_size_type_reg <= 0;
        end else begin
            if (wen_i) begin
                total_id_reg  <= total_id_i;
                total_od_reg  <= total_od_i;
                total_size_type_reg <= total_size_type_i;
            end else begin
                total_id_reg  <= total_id_reg;
                total_od_reg  <= total_od_reg;
                total_size_type_reg <= total_size_type_reg;
            end
        end
    end

    // FSM of the weight controller
    // four states: prepare, ready, start, null
    // prepare: start to prepare the buffer
    // ready: the buffer is ready
    // start: open the valid bit and send data into the PE arrays
    // null: do nothing
    typedef enum logic [1:0] {
        PREPARE = 2'b00,
        READY = 2'b01,
        START = 2'b10,
        NULL = 2'b11
    } weight_state_t;

    weight_state_t weight_state, next_weight_state;






endmodule




module weight_trans_buffer ();
    // calculate the input from the weight buffer, store the data in local reg

    // input from the weight buffer

    // output to the PE arrays


endmodule




module weight_top ();

endmodule