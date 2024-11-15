
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
    output logic input_request_o,

    // input from the memory 
    input logic signed [15:0] input_data_i[5:0][5:0],
    input logic input_valid_i,

    // output to the PE arrays
    output logic signed [15:0] result_tile_o_1 [5:0][5:0],
    output logic signed [15:0] result_tile_o_2 [5:0][5:0]
);

    // definition of the local reg to store off-chip input    
    logic [7:0] total_id_reg;
    logic size_type_reg, input_sel;
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

    logic signed [15:0] input_raw_1[5:0][5:0];
    logic signed [15:0] input_raw_2[5:0][5:0];
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            buffer_ready <= 0;
            input_calculated <= 0;
            input_addr_x_o <= 0;
            input_addr_y_o <= 0;
            prefetch_cnt <= 0;
            input_sel <= 0;
        end else begin
            if (weight_valid_i && weight_state == PREPARE) begin
                if (input_sel == 0) input_raw_1 <= input_data_i;
                else input_raw_2 <= input_data_i;
                buffer_ready <= 1'b1;
                input_sel <= ~input_sel;
            end
            else buffer_ready <= 1'b0;

            if (input_state == START) input_calculated <= 1;
            else input_calculated <= 0;

            if (size_type_i) begin
                if (input_addr_y_o + 4 < input_length_reg) 
                    input_addr_y_o <= input_addr_y_o + 4;
                else if (input_addr_x_o + 4 < input_width_reg) begin
                    input_addr_y_o <= 0;
                    input_addr_x_o <= input_addr_x_o + 4;
                end
                else begin 
                    input_addr_y_o <= 0;
                    input_addr_x_o <= 0;
                end
            end
            else begin
                if (input_addr_y_o + 6 < input_length_reg) 
                    input_addr_y_o <= input_addr_y_o + 6;
                else if (input_addr_x_o + 6 < input_width_reg) begin
                    input_addr_y_o <= 0;
                    input_addr_x_o <= input_addr_x_o + 6;
                end
                else begin 
                    input_addr_y_o <= 0;
                    input_addr_x_o <= 0;
                end
            end
        end
    end



    logic signed [15:0] intermediate_result_1 [0:5][0:5];
    logic signed [15:0] intermediate_result_2 [0:5][0:5];
    logic signed [2:0] bt [0:5][0:5];
    
    assign bt[0][0] = 'd3;
    assign bt[0][1] = 'd0;
    assign bt[0][2] = -'d4;
    assign bt[0][3] = 'd0;
    assign bt[0][4] = 'd1;
    assign bt[0][5] = 'd0;
    
    assign bt[1][0] = 'd0;
    assign bt[1][1] = -'d3;
    assign bt[1][2] = -'d3;
    assign bt[1][3] = 'd1;
    assign bt[1][4] = 'd1;
    assign bt[1][5] = 'd0;
    
    assign bt[2][0] = 'd0;
    assign bt[2][1] = 'd3;
    assign bt[2][2] = -'d3;
    assign bt[2][3] = -'d1;
    assign bt[2][4] = 'd1;
    assign bt[2][5] = 'd0;
    
    assign bt[3][0] = 'd0;
    assign bt[3][1] = -'d2;
    assign bt[3][2] = -'d1;
    assign bt[3][3] = 'd2;
    assign bt[3][4] = 'd1;
    assign bt[3][5] = 'd0;
    
    assign bt[4][0] = 'd0;
    assign bt[4][1] = 'd2;
    assign bt[4][2] = -'d1;
    assign bt[4][3] = -'d2;
    assign bt[4][4] = 'd1;
    assign bt[4][5] = 'd0;
    
    assign bt[5][0] = 'd0;
    assign bt[5][1] = 'd3;
    assign bt[5][2] = 'd0;
    assign bt[5][3] = -'d4;
    assign bt[5][4] = 'd0;
    assign bt[5][5] = 'd1;

    always_comb begin
        for (int i = 0; i < 6; i=i+1) begin
            for (int j = 0; j < 6; j=j+1) begin
                intermediate_result_1[i][j] = 0;
                intermediate_result_2[i][j] = 0;
                for (int k = 0; k < 6; k=k+1) begin
                    if (bt[i][k] == -'d4) begin
                        intermediate_result_1[i][j] = intermediate_result_1[i][j] - (input_raw_1[k][j] <<< 2) - input_raw_1[k][j];
                        intermediate_result_2[i][j] = intermediate_result_2[i][j] - (input_raw_2[k][j] <<< 2) - input_raw_2[k][j];
                    end
                    else if (bt[i][k] < 0) begin
                        intermediate_result_1[i][j] = intermediate_result_1[i][j] - (input_raw_1[k][j] <<< (-bt[i][k] - 1));
                        intermediate_result_2[i][j] = intermediate_result_2[i][j] - (input_raw_2[k][j] <<< (-bt[i][k] - 1));
                    end
                    else begin
                        intermediate_result_1[i][j] = intermediate_result_1[i][j] + (input_raw_1[k][j] <<< (bt[i][k] - 1));
                        intermediate_result_2[i][j] = intermediate_result_2[i][j] + (input_raw_2[k][j] <<< (bt[i][k] - 1));
                    end
                end
            end
        end
    end

    always_comb begin
        for (int i = 0; i < 6; i=i+1) begin
            for (int j = 0; j < 6; j=j+1) begin
                result_tile_o_1[i][j] = 0;
                result_tile_o_2[i][j] = 0;
                for (int k = 0; k < 6; k=k+1) begin
                    if (bt[j][k] == -'d4) begin
                        result_tile_o_1[i][j] = result_tile_o_1[i][j] - (intermediate_result_1[i][k] <<< 2) - intermediate_result_1[i][k];
                        result_tile_o_2[i][j] = result_tile_o_2[i][j] - (intermediate_result_2[i][k] <<< 2) - intermediate_result_2[i][k];
                    end
                    else if (bt[j][k] < 0) begin
                        result_tile_o_1[i][j] = result_tile_o_1[i][j] - (intermediate_result_1[i][k] <<< (-bt[j][k] - 1));
                        result_tile_o_2[i][j] = result_tile_o_2[i][j] - (intermediate_result_2[i][k] <<< (-bt[j][k] - 1));
                    end
                    else begin
                        result_tile_o_1[i][j] = result_tile_o_1[i][j] + (intermediate_result_1[i][k] <<< (bt[j][k] - 1));
                        result_tile_o_2[i][j] = result_tile_o_2[i][j] + (intermediate_result_2[i][k] <<< (bt[j][k] - 1));
                    end
                end
            end
        end
    end

    
endmodule


module data_buffer ();

endmodule


module data_trans ();

endmodule


module data_top ();

endmodule

