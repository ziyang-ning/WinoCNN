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


    // input from the data controller
    input logic data_ready_i,
    input logic data_complete_i,

    // output to the weight controller
    output logic [7:0] weight_od1_o,
    output logic [7:0] weight_od2_o,
    output logic [3:0] weight_id_o,

    // output to the data controller
    output logic [7:0] block_width_o,
    output logic [7:0] block_height_o,
    output logic [3:0] data_id_o,
    output logic data_prepare_o,
    output logic data_start_o,

    // off-chip output
    output logic conv_completed

);


    // definition of the local reg to store off-chip input
    logic [3:0] total_id_reg;
    logic [7:0] total_od_reg;
    logic [8:0] total_width_reg;
    logic [8:0] total_height_reg;
    logic total_size_type_reg;

    assign block_width_o = total_size_type_reg ? (total_width_reg[0:1] > 0 ? (total_width_reg >> 2) + 1 : (total_width_reg >> 2))
                                              : (total_width_reg[0:1] > 0 ? (total_width_reg >> 2) + 1 : (total_width_reg >> 2));
    always_comb begin
        if (total_size_type_reg) begin
            block_width_o = total_width_reg[0:1] > 0 ? (total_width_reg >> 2) + 1 : (total_width_reg >> 2);
            block_height_o = total_height_reg[0:1] > 0 ? (total_height_reg >> 2) + 1 : (total_height_reg >> 2);
        end
        else begin
            case(total_width_reg)
                0, 1, 2, 3, 4, 5, 6: block_width_o = 1;
                7, 8, 9, 10, 11, 12: block_width_o = 2;
                13, 14, 15, 16, 17, 18: block_width_o = 3;
                19, 20, 21, 22, 23, 24: block_width_o = 4;
                25, 26, 27, 28, 29, 30: block_width_o = 5;
                31, 32, 33, 34, 35, 36: block_width_o = 6;
                37, 38, 39, 40, 41, 42: block_width_o = 7;
                43, 44, 45, 46, 47, 48: block_width_o = 8;
                49, 50, 51, 52, 53, 54: block_width_o = 9;
                55, 56, 57, 58, 59, 60: block_width_o = 10;
                default: block_width_o = 1;
            endcase
            case(total_height_reg)
                0, 1, 2, 3, 4, 5, 6: block_height_o = 1;
                7, 8, 9, 10, 11, 12: block_height_o = 2;
                13, 14, 15, 16, 17, 18: block_height_o = 3;
                19, 20, 21, 22, 23, 24: block_height_o = 4;
                25, 26, 27, 28, 29, 30: block_height_o = 5;
                31, 32, 33, 34, 35, 36: block_height_o = 6;
                37, 38, 39, 40, 41, 42: block_height_o = 7;
                43, 44, 45, 46, 47, 48: block_height_o = 8;
                49, 50, 51, 52, 53, 54: block_height_o = 9;
                55, 56, 57, 58, 59, 60: block_height_o = 10;
                default: block_height_o = 1;
            endcase
        end
    end

    // store the off-chip input into local reg
    always_ff @(posedge clk or pose dge reset) begin
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

    // definition of counter to count the od1, od2 and id
    logic [7:0] od1_counter;
    logic [7:0] od2_counter;
    logic [3:0] id_counter;
    assign od2_counter = od1_counter + 1;

    // FSM for the main controller
    // four states: prepare, start, complete, finish
    
    typedef enum logic [1:0] {
        PREPARE,
        START,
        COMPLETE,
        FINISH
    } state_t;

    state_t state, next_state;
    always_comb begin
        next_state = state;
        case(state)
            PREPARE: begin
                if (data_ready_i) begin
                    next_state = START;
                end
            end
            START: begin
                if (data_complete_i) begin
                    next_state = COMPLETE;
                end
            end
            COMPLETE: begin
                if ((od2_counter >= total_od_reg) && (id_counter >= total_id_reg) && (data_complete_i)) begin
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


    // counter for od1, od2 and id
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            od1_counter <= 0;
            id_counter <= 0;
        end else begin
            if (state == COMPLETE) begin
                if (od2_counter >= total_od_reg) begin
                    // start the next id
                    od1_counter <= 0;
                    id_counter <= id_counter + 1;
                end else begin
                    // still work on the same id
                    od1_counter <= od1_counter + 2;
                end
            end else begin
                od1_counter <= od1_counter;
                id_counter <= id_counter;
            end
        end
    end



    // comb logic for other output
    logic [3:0] data_start_count;
    always_comb begin

        data_id_o = id_counter;
        weight_id_o = id_counter;
        weight_od1_o = od1_counter;
        weight_od2_o = od2_counter;
        conv_completed = (state == FINISH);

        case (state)
            PREPARE: begin
                data_prepare_o = 1;
                data_start_count = 0;
            end
            START: begin
                data_prepare_o = 0;
                data_start_count = 1;
            end
            COMPLETE: begin
                data_prepare_o = 0;
                data_start_count = 0;
            end
            FINISH: begin
                data_prepare_o = 0;
                data_start_count = 0;
            end
        endcase
    end


    // data_start_o should be delay by three cycles for_data_start_count is high
    logic temp_reg1, temp_reg2, temp_reg3;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            temp_reg1 <= 0;
            temp_reg2 <= 0;
            temp_reg3 <= 0;
            data_start_o <= 0;
        end else begin
            temp_reg1 <= data_start_count;
            temp_reg2 <= temp_reg1;
            temp_reg3 <= temp_reg2;
            data_start_o <= temp_reg3;
        end
    end




endmodule