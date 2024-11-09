
module data_controller (
    // include bot the controller and the input buffer
    input logic clk,
    input logic reset,

    // off-chip input
    input logic [7:0] total_id_i,
    input logic size_type_i,
    input logic [15:0] input_length_i,
    input logic [15:0] input_width_i,
    input logic wen_i, // the enable signal to change the off-chip input

    // input from the main controller
    input logic [3:0] input_id_i,
    input logic input_prepare_i,
    input logic input_start_i,

    // output to the main controller
    output logic input_ready_o,
    output logic input_finished_o,

    // output to the memory
    output logic [15:0] input_addr_x_o,
    output logic [15:0] input_addr_y_o,
    output logic [1:0] prefetch_type,         // 00 for initialize, 01 for two colomns, 10 for one colomn (boundary), 11 for one row
    output logic input_request_o,

    // input from the memory 
    input logic signed [15:0] input_data_i[11:0],
    input logic input_valid_i,

    // output to the PE arrays
    output logic signed [15:0] result_tile_o_1 [5:0][5:0],
    output logic signed [15:0] result_tile_o_2 [5:0][5:0]
);

    // definition of the local reg to store off-chip input
    logic signed [15:0] input_buffer [5:0][6:0];
    logic direction;         // 0 for going right, 1 for going left
    logic [2:0] pointer_y;
    logic [1:0] prefetch_cnt;



    
    logic [7:0] total_id_reg;
    logic size_type_reg;
    logic [15:0] input_length_reg;
    logic [15:0] input_width_reg;

    // store the off-chip input into local reg
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            total_id_reg  <= 0;
            size_type_reg <= 0;
            input_length_reg <= 0;
            input_width_reg <= 0;
        end 
        else if (wen_i) begin
            total_id_reg  <= total_id_i;
            size_type_reg <= size_type_i;
            input_length_reg <= input_length_i;
            input_width_reg <= input_width_i;
        end 
    end

    typedef enum logic [1:0] {
        PREPARE = 2'b00,
        READY = 2'b01,
        START = 2'b10,
        FINISHED = 2'b11
    } input_state_t;

    input_state_t input_state, next_input_state;
    logic buffer_ready, input_calculated;

    always_comb begin
        next_input_state = input_state;
        case(input_state)
            PREPARE: begin
                if (buffer_ready) begin
                    next_input_state = READY;
                end
            end
            READY: begin
                if (input_start_i) begin
                    next_input_state = START;
                end
            end
            START: begin
                if (input_calculated) begin
                    next_input_state = FINISHED;
                end
            end
            FINISHED: begin
                if (input_prepare_i) begin
                    next_input_state = PREPARE;
                end
            end
        endcase
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            input_state <= PREPARE;
        else 
            input_state <= next_input_state;
    end

    always_comb begin
        case(input_state)
            PREPARE: begin
                input_ready_o = 1'b0;
                input_request_o = 1'b1;
                input_finished_o = 1'b0;
            end
            READY: begin
                input_ready_o = 1'b1;
                input_request_o = 1'b0;
                input_finished_o = 1'b0;
            end
            START: begin
                input_ready_o = 1'b0;
                input_request_o = 1'b0;
                input_finished_o = 1'b0;
            end
            FINISHED: begin
                input_ready_o = 1'b0;
                input_request_o = 1'b0;
                input_finished_o = 1'b1;
            end
        endcase
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            direction <= 0;
            pointer_y <= 0;
            buffer_ready <= 0;
            input_calculated <= 0;
            prefetch_type <= 2'b00;
            input_addr_x_o <= 0;
            input_addr_y_o <= 0;
            prefetch_cnt <= 0;
        end else begin
            if (prefetch_type == 2'b00 && weight_state == PREPARE) begin
                if (prefetch_cnt < 3) begin
                    prefetch_cnt <= prefetch_cnt + 1;
                    input_addr_y_o <= input_addr_y_o + 2;
                    buffer_ready <= 0;
                end
                else begin
                    prefetch_cnt <= 0;
                    input_addr_y_o <= input_addr_y_o + 1;
                    prefetch_type <= 2'b10;
                    buffer_ready <= 0;
                end
            end
            if (prefetch_type == 2'b10 && weight_state == PREPARE) buffer_ready <= 1;

            if (weight_state == START) input_calculated <= 1;
            else input_calculated <= 0;
        end
    end

    
endmodule


module data_buffer ();

endmodule


module data_trans ();

endmodule


module data_top ();

endmodule

