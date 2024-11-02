module main_controller(

    input clk,
    input reset,

    // off-chip input
    input logic [3:0] total_id_i,
    input logic [7:0] total_od_i,
    input logic [8:0] total_weight_i,
    input logic [8:0] total_height_i,
    input logic wen_i, // the enable signal to change the off-chip input


    // input from the weight controller
    input logic weight_ready_i,

    // input from the data controller
    input logic data_ready_i,
    input logic data_complete_i,

    // output to the weight controller
    output logic [7:0] weight_od1_o,
    output logic [7:0] weight_od2_o,
    output logic [3:0] weight_id_o,
    output logic weight_prepare_o,
    output logic weight_start_o,

    // output to the data controller
    output logic [3:0] data_id_o,
    output logic data_prepare_o,
    output logic data_start_o,

    // off-chip output
    output logic conv_completed

);


    // definition of the local reg to store off-chip input
    logic [3:0] total_id_reg;
    logic [7:0] total_od_reg;
    logic [8:0] total_weight_reg;
    logic [8:0] total_height_reg;
   
    // definition of counter to count the od1, od2 and id
    logic [7:0] od1_counter;
    logic [7:0] od2_counter;
    logic [3:0] id_counter;
    assign od2_counter = od1_counter + 1;

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

    // store the off-chip input into local reg
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            total_id_reg  <= 0;
            total_od_reg  <= 0;
            total_weight_reg  <= 0;
            total_height_reg  <= 0;
        end else begin
            if (wen_i) begin
                total_id_reg  <= total_id_i;
                total_od_reg  <= total_od_i;
                total_weight_reg  <= total_weight_i;
                total_height_reg  <= total_height_i;
            end else begin
                total_id_reg  <= total_id_reg;
                total_od_reg  <= total_od_reg;
                total_weight_reg  <= total_weight_reg;
                total_height_reg  <= total_height_reg;
            end
        end

    end


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
                if (data_ready_i && weight_ready_i) begin
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
                weight_prepare_o = 1;
                data_start_count = 0;
                weight_start_o = 0;
            end
            START: begin
                data_prepare_o = 0;
                weight_prepare_o = 0;
                data_start_count = 1;
                weight_start_o = 1;
            end
            COMPLETE: begin
                data_prepare_o = 0;
                weight_prepare_o = 0;
                data_start_count = 0;
                weight_start_o = 0;
            end
            FINISH: begin
                data_prepare_o = 0;
                weight_prepare_o = 0;
                data_start_count = 0;
                weight_start_o = 0;
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