module main_controller(

    input clk,
    input reset,

    // off-chip input
    input logic [3:0] total_id_i,
    input logic [7:0] total_od_i,
    input logic [8:0] total_width_i,
    input logic [8:0] total_height_i,
    input logic total_size_type_i,
    input logic wen_i, // the enable signal to change the off-chip input

    // output to the weight controller
    output logic [7:0] weight_od1_o,

    // output to the data controller
    output logic [7:0] input_addr_o_1,
    output logic [7:0] input_addr_o_2,
    output logic size_type_o,
    output logic [7:0] block_cnt_o,
    output logic [3:0] current_id_o,
    output logic input_request_o,

    // off-chip output
    output logic conv_completed
);

    // definition of the local reg to store off-chip input
    logic [3:0] total_id_reg;
    logic [7:0] total_od_reg;
    logic [8:0] total_width_reg;
    logic [8:0] total_height_reg;
    logic total_size_type_reg;
    logic [7:0] block_width;
    logic [7:0] block_height;
    logic loop_finished;

    always_comb begin
        case(total_width_reg)
            0, 1, 2, 3, 4, 5, 6: block_width = 1;
            7, 8, 9, 10, 11, 12: block_width = 2;
            13, 14, 15, 16, 17, 18: block_width = 3;
            19, 20, 21, 22, 23, 24: block_width = 4;
            25, 26, 27, 28, 29, 30: block_width = 5;
            31, 32, 33, 34, 35, 36: block_width = 6;
            37, 38, 39, 40, 41, 42: block_width = 7;
            43, 44, 45, 46, 47, 48: block_width = 8;
            49, 50, 51, 52, 53, 54: block_width = 9;
            55, 56, 57, 58, 59, 60: block_width = 10;
            default: block_width = 1;
        endcase
        case(total_height_reg)
            0, 1, 2, 3, 4, 5, 6: block_height = 1;
            7, 8, 9, 10, 11, 12: block_height = 2;
            13, 14, 15, 16, 17, 18: block_height = 3;
            19, 20, 21, 22, 23, 24: block_height = 4;
            25, 26, 27, 28, 29, 30: block_height = 5;
            31, 32, 33, 34, 35, 36: block_height = 6;
            37, 38, 39, 40, 41, 42: block_height = 7;
            43, 44, 45, 46, 47, 48: block_height = 8;
            49, 50, 51, 52, 53, 54: block_height = 9;
            55, 56, 57, 58, 59, 60: block_height = 10;
            default: block_height = 1;
        endcase
    end

    // store the off-chip input into local reg
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            total_id_reg  <= 0;
            total_od_reg  <= 0;
            total_width_reg  <= 0;
            total_height_reg  <= 0;
            total_size_type_reg <= 0;
        end else begin
            if (wen_i) begin
                total_id_reg  <= total_id_i;
                total_od_reg  <= total_od_i;
                total_width_reg  <= total_width_i;
                total_height_reg  <= total_height_i;
                total_size_type_reg <= total_size_type_i;
            end else begin
                total_id_reg  <= total_id_reg;
                total_od_reg  <= total_od_reg;
                total_width_reg  <= total_width_reg;
                total_height_reg  <= total_height_reg;
                total_size_type_reg <= total_size_type_reg;
            end
        end
    end

    assign size_type_o = total_size_type_reg;

    logic [7:0] od1_counter;
    logic [7:0] od2_counter;
    assign od2_counter = od1_counter + 1;

    // FSM for the main controller
    // four states: prepare, start, complete, finish
    
    typedef enum logic [1:0] {
        PREPARE,
        COMPLETE,
        FINISH
    } state_t;

    state_t state, next_state;
    always_comb begin
        next_state = state;
        case(state)
            PREPARE: begin
                if (loop_finished) begin
                    next_state = COMPLETE;
                end
            end
            COMPLETE: begin
                if (od2_counter >= total_od_reg - 1) begin
                    next_state = FINISH;
                end else begin
                    next_state = PREPARE;
                end
            end
            FINISH: begin
                next_state = FINISH;
            end
        endcase
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= PREPARE;
        end else begin
            state <= next_state;
        end
    end

    logic [15:0] max_block;

    assign block_cnt_o = block_width * block_height;
    assign max_block = block_cnt_o * total_id_reg;

    always_ff @(posedge clk or posedge reset) begin
        if (reset || state == FINISH) begin
            input_addr_o_1 <= 0;
            input_addr_o_2 <= 1;
            loop_finished <= 0;
            input_request_o <= 0;
            current_id_o <= 0;
        end else begin
            if (current_id_o + 1 < total_id_reg) begin
                input_addr_o_1 <= input_addr_o_1;
                input_addr_o_2 <= input_addr_o_2;
                loop_finished <= loop_finished;
                input_request_o <= 1;
                current_id_o <= current_id_o + 1;
            end
            else if (loop_finished) begin
                input_addr_o_1 <= 0;
                input_addr_o_2 <= 1;
                loop_finished <= 0;
                input_request_o <= 1;
                current_id_o <= 0;
            end
            else if ((input_addr_o_1 + 3 == max_block) && input_request_o) begin
                input_addr_o_1 <= max_block - 1;
                input_addr_o_2 <= 8'b11111111;
                loop_finished <= 1;
                input_request_o <= 1;
                current_id_o <= 0;
            end
            else if (state != FINISH && input_request_o) begin
                input_addr_o_1 <= input_addr_o_1 + 2;
                input_addr_o_2 <= input_addr_o_2 + 2;
                if (input_addr_o_1 + 4 == max_block) loop_finished <= 1;
                else loop_finished <= 0;
                input_request_o <= 1;
                current_id_o <= 0;
            end
            else begin
                input_addr_o_1 <= 0;
                input_addr_o_2 <= 1;
                loop_finished <= loop_finished;
                input_request_o <= ~loop_finished;
                current_id_o <= 0;
            end
        end
    end


    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            od1_counter <= 0;
        end else begin
            if (state == COMPLETE) begin
                if (od2_counter >= total_od_reg - 1) begin
                    od1_counter <= 0;
                end else begin
                    od1_counter <= od1_counter + 2;
                end
            end else begin
                od1_counter <= od1_counter;
            end
        end
    end

    always_comb begin
        weight_od1_o = od1_counter;
        conv_completed = (state == FINISH);
    end

endmodule