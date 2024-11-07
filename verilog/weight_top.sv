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
    output logic weight_finished_o,

    // output to the memory, 18 elements in total
    output logic [15:0] weight_addr_o,
    output logic weight_request_o,

    // input from the memory 
    input logic signed [15:0] weight_data_i[17:0],
    input logic weight_valid_i,

    // output to the PE arrays
    output logic signed [15:0] result_tile_o_1 [5:0][5:0],
    output logic signed [15:0] result_tile_o_2 [5:0][5:0]
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
    // four states: prepare, ready, start, finished
    // prepare: start to prepare the buffer
    // ready: the buffer is ready
    // start: start calculating the weight tile
    // finished: open the valid bit and send data into the PE arrays
    typedef enum logic [1:0] {
        PREPARE = 2'b00,
        READY = 2'b01,
        START = 2'b10,
        FINISHED = 2'b11
    } weight_state_t;

    weight_state_t weight_state, next_weight_state;
    logic weight_received, weight_calculated;

    always_comb begin
        next_weight_state = weight_state;
        case(weight_state)
            PREPARE: begin
                if (weight_received) begin
                    next_weight_state = READY;
                end
            end
            READY: begin
                if (weight_start_i) begin
                    next_weight_state = START;
                end
            end
            START: begin
                if (weight_calculated) begin
                    next_weight_state = FINISHED;
                end
            end
            FINISHED: begin
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
                weight_finished_o = 1'b0;
            end
            READY: begin
                weight_ready_o = 1'b1;
                weight_request_o = 1'b0;
                weight_finished_o = 1'b0;
            end
            START: begin
                weight_ready_o = 1'b0;
                weight_request_o = 1'b0;
                weight_finished_o = 1'b0;
            end
            FINISHED: begin
                weight_ready_o = 1'b0;
                weight_request_o = 1'b0;
                weight_finished_o = 1'b1;
            end
        endcase
    end

    logic signed [15:0] weight_raw_1[2:0][2:0];
    logic signed [15:0] weight_raw_2[2:0][2:0];

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            weight_raw_1 <= '{default:'0};
            weight_raw_2 <= '{default:'0};
            weight_received <= 1'b0;
            weight_calculated <= 1'b0;
        end else begin
            if (weight_valid_i && weight_state == PREPARE) begin
                weight_raw_1 <= weight_data_i[8:0];    //TODO: Check whether this is valid
                weight_raw_2 <= weight_data_i[17:9];
                weight_received <= 1'b1;
            end
            else weight_received <= 1'b0;

            if (weight_state == START) weight_calculated <= 1'b1;
            else weight_calculated <= 1'b0;
        end
    end

    logic signed [15:0] intermediate_result_1 [0:5][0:2];
    logic signed [15:0] intermediate_result_2 [0:5][0:2];
    logic signed [15:0] g [0:5][0:2];       //TODO: finish G
    
    always_comb begin
        for (int i = 0; i < 6; i=i+1) begin
            for (int j = 0; j < 3; j=j+1) begin
                intermediate_result_1[i][j] = 0;
                intermediate_result_2[i][j] = 0;
                for (int k = 0; k < 3; k=k+1) begin
                    intermediate_result_1[i][j] = intermediate_result_1[i][j] + weight_raw_1[k][j] * g[i][k];
                    intermediate_result_2[i][j] = intermediate_result_2[i][j] + weight_raw_2[k][j] * g[i][k];
                end
            end
        end
    end

    always_comb begin
        for (int i = 0; i < 6; i=i+1) begin
            for (int j = 0; j < 6; j=j+1) begin
                result_tile_o_1[i][j] = 0;
                result_tile_o_2[i][j] = 0;
                for (int k = 0; k < 3; k=k+1) begin
                    result_tile_o_1[i][j] = result_tile_o_1[i][j] + intermediate_result_1[i][k] * g[j][k];
                    result_tile_o_2[i][j] = result_tile_o_2[i][j] + intermediate_result_2[i][k] * g[j][k];
                end
            end
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
