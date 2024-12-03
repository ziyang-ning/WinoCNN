
module data_controller (
    // include bot the controller and the input buffer
    input logic clk,
    input logic reset,

    // input from the main controller
    input logic [3:0] input_id_i,
    input logic input_prepare_i,
    input logic [7:0] block_width_i,
    input logic [7:0] block_height_i,
    input logic size_type_i,

    // output to the main controller
    output logic loop_finished_o,

    // output to the memory
    output logic [7:0] input_addr_o_1,
    output logic [7:0] input_addr_o_2,
    output logic input_request_o,

    // input from the memory 
    input logic signed [7:0] input_data_i_1[5:0][5:0],
    input logic signed [7:0] input_data_i_2[5:0][5:0],
    input logic input_valid_i,

    // output to the PE arrays
    output logic signed [13:0] result_tile_o_1 [5:0][5:0],
    output logic signed [13:0] result_tile_o_2 [5:0][5:0],
    output logic [7:0] pe_data_addr_o_1,
    output logic [7:0] pe_data_addr_o_2,
    output logic data_valid_o,
    output logic size_type_o,
    output logic [7:0] block_cnt
);

    logic [15:0] max_block;

    assign block_cnt = block_width_i * block_height_i;
    assign max_block = block_cnt * (input_id_i + 1);
    assign size_type_o = size_type_i;

    logic signed [7:0] input_raw_1[5:0][5:0];
    logic signed [7:0] input_raw_2[5:0][5:0];
    logic input_valid_reg;
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            input_addr_o_1 <= 0;
            input_addr_o_2 <= 1;
            loop_finished_o <= 0;
            input_request_o <= 1;
            input_raw_1 <= '{default:'0};
            input_raw_2 <= '{default:'0};
            input_valid_reg <= 0;
        end else begin
            if (input_valid_i && input_request_o) begin
                input_raw_1 <= input_data_i_1;
                input_raw_2 <= input_data_i_2;
                input_valid_reg <= 1;
            end
            else begin
                input_raw_1 <= '{default:'0};
                input_raw_2 <= '{default:'0};
                input_valid_reg <= 0;
            end

            if (loop_finished_o && input_request_o) input_request_o <= 0;
            if (input_prepare_i && ~input_request_o) input_request_o <= 1;

            if (loop_finished_o) begin
                input_addr_o_1 <= block_cnt * input_id_i;
                input_addr_o_2 <= block_cnt * input_id_i + 1;
                loop_finished_o <= 0;
            end
            else if (input_addr_o_1 + 3 == max_block) begin
                input_addr_o_1 <= max_block - 1;
                input_addr_o_2 <= 8'b11111111;
                loop_finished_o <= 1;
            end
            else begin
                input_addr_o_1 <= input_addr_o_1 + 2;
                input_addr_o_2 <= input_addr_o_2 + 2;
                if (input_addr_o_1 + 4 == max_block) loop_finished_o <= 1;
            end
        end
    end

    logic signed [10:0] intermediate_result_1 [0:5][0:5];
    logic signed [10:0] intermediate_result_2 [0:5][0:5];
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

    logic signed [10:0] intermediate_result_regs_1 [0:5][0:5];
    logic signed [10:0] intermediate_result_regs_2 [0:5][0:5];
    logic [7:0] data_addr_1a;
    logic [7:0] data_addr_2a;
    logic intermediate_valid;

    always_ff @( posedge clk or posedge reset ) begin
        if (reset) begin
            intermediate_result_regs_1 <= '{default:'0};
            intermediate_result_regs_2 <= '{default:'0};
            data_addr_1a <= 0;
            data_addr_2a <= 0;
            intermediate_valid <= 0;
        end 
        else begin
            if (input_valid_reg) begin
                intermediate_result_regs_1 <= intermediate_result_1;
                intermediate_result_regs_2 <= intermediate_result_2;
                data_addr_1a <= input_addr_o_1;
                data_addr_2a <= input_addr_o_2;
                intermediate_valid <= 1;
            end
            else begin
                intermediate_result_regs_1 <= '{default:'0};
                intermediate_result_regs_2 <= '{default:'0};
                data_addr_1a <= 0;
                data_addr_2a <= 0;
                intermediate_valid <= 0;
            end
        end
    end

    logic signed [13:0] result_regs_1 [0:5][0:5];
    logic signed [13:0] result_regs_2 [0:5][0:5];

    always_comb begin
        for (int i = 0; i < 6; i=i+1) begin
            for (int j = 0; j < 6; j=j+1) begin
                result_regs_1[i][j] = 0;
                result_regs_2[i][j] = 0;
                for (int k = 0; k < 6; k=k+1) begin
                    if (bt[j][k] == -'d4) begin
                        result_regs_1[i][j] = result_regs_1[i][j] - (intermediate_result_regs_1[i][k] <<< 2) - intermediate_result_regs_1[i][k];
                        result_regs_2[i][j] = result_regs_2[i][j] - (intermediate_result_regs_2[i][k] <<< 2) - intermediate_result_regs_2[i][k];
                    end
                    else if (bt[j][k] < 0) begin
                        result_regs_1[i][j] = result_regs_1[i][j] - (intermediate_result_regs_1[i][k] <<< (-bt[j][k] - 1));
                        result_regs_2[i][j] = result_regs_2[i][j] - (intermediate_result_regs_2[i][k] <<< (-bt[j][k] - 1));
                    end
                    else begin
                        result_regs_1[i][j] = result_regs_1[i][j] + (intermediate_result_regs_1[i][k] <<< (bt[j][k] - 1));
                        result_regs_2[i][j] = result_regs_2[i][j] + (intermediate_result_regs_2[i][k] <<< (bt[j][k] - 1));
                    end
                end
            end
        end
    end



    always_ff @( posedge clk or posedge reset ) begin
        if (reset) begin
            result_tile_o_1 <= '{default:'0};
            result_tile_o_2 <= '{default:'0};
            pe_data_addr_o_1 <= 0;
            pe_data_addr_o_2 <= 0;
            data_valid_o <= 0;
        end 
        else begin
            if (intermediate_valid) begin
                result_tile_o_1 <= result_regs_1;
                result_tile_o_2 <= result_regs_2;
                pe_data_addr_o_1 <= data_addr_1a;
                pe_data_addr_o_2 <= data_addr_2a;
                data_valid_o <= 1;
            end
            else begin
                result_tile_o_1 <= '{default:'0};
                result_tile_o_2 <= '{default:'0};
                pe_data_addr_o_1 <= 0;
                pe_data_addr_o_2 <= 0;
                data_valid_o <= 0;
            end
        end
    end
    
endmodule
