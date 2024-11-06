module weight_controller (
    // include bot the controller and the weight buffer
    input logic clk,
    input logic reset,

    // off-chip input
    input logic [7:0] total_id_i,
    input logic [7:0] total_od_i,
    input logic total_size_type_i,
    input logic wen_i, // the enable signal to change the off-chip input

    // input from the main controller
    input logic [7:0] weight_od1_i,
    input logic [7:0] weight_od2_i,
    input logic [3:0] weight_id_i,
    input logic weight_prepare_i,
    input logic weight_start_i,

    // output to the main controller
    output logic weight_ready_o,

    // output to the memory, 18 elements in total
    output logic [15:0] weight_addr_o,
    output logic weight_request_o,

    // input from the memory 
    input logic [15:0] weight_data_i[17:0],
    input logic weight_valid_i

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

    always_comb begin
        next_weight_state = weight_state;
        case(weight_state)
            PREPARE: begin
                if (weight_ready_o) begin
                    next_weight_state = READY;
                end
            end
            READY: begin
                if (weight_start_i) begin
                    next_weight_state = START;
                end
            end
            START: begin
                if (weight_prepare_i) begin
                    next_weight_state = PREPARE;
                end
            end
        endcase
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            weight_state <= PREPARE;
        end else begin
            weight_state <= next_weight_state;
        end
    end

    always_comb begin
        weight_addr_o = weight_od1_i + total_od_reg * weight_id_i;

        case(weight_state)
            PREPARE: begin
                weight_ready_o = 1'b0;
                weight_request_o = 1'b1;
            end
            READY: begin
                weight_ready_o = 1'b1;
                weight_request_o = 1'b0;
            end
            START: begin
                weight_ready_o = 1'b0;
                weight_request_o = 1'b0;
            end
        endcase
    end

    logic [15:0] weight_raw[17:0];

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            weight_raw <= '{default:'0};
        end else begin
            if (weight_valid_i) weight_raw <= weight_data_i;
        end
    end

endmodule




module weight_trans_buffer ();
    // calculate the input from the weight buffer, store the data in local reg

    // input from the weight buffer

    // output to the PE arrays


endmodule




module weight_top ();

endmodule