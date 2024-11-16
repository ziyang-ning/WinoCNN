`timescale 1ns/100ps


module testbench;
    logic [9:0] user_addr;
    logic [3:0] user_memid;
    logic [3:0] [7:0] user_readout;
    
    logic scan_clk;
    logic scan_in;
    logic [15:0] scan_enable;
    logic scan_mode;

    logic clock_proc0;
    logic clock_proc1;
    logic clock_proc2;
    logic clock_proc3;
    logic clock_proc4;
    logic clock_proc5;
    logic clock_proc6;
    logic clock_proc7;
    logic clock_proc8;
    logic clock_proc9;
    logic clock_proc10;
    logic clock_proc11;

    logic clock_router;
    logic reset;
    DATA_PACKET [15:0] d_in;
    logic [15:0] d_valid_in;
    logic [15:0] d_ready_in;
    logic [15:0] d_ready_out;
    logic [15:0] d_valid_out;
    DATA_PACKET [15:0] d_out;

    logic [1:0] clock_control [11:0];
    logic [`XLEN-1:0] if_id_NPC [11:0];
    logic if_valid_inst_out [11:0];
    logic [`XLEN-1:0] mem_result_out [11:0];
    logic stop [11:0];
    logic [`XLEN-1:0] asyn_mem_stage_data [11:0];
    logic asyn_mem_stage_valid [11:0];

    logic mem_stage_asyn_data_req [11:0];
    logic [4:0] mem_stage_asyn_req_id [11:0];
    logic [4:0] core_id [11:0];
    logic core_id_valid [11:0];
    logic proc2router_request [11:0];
    logic proc2router_ack [11:0];
    logic router2proc_ack [11:0];
    logic router2proc_request [11:0];
    logic [8:0] proc2Imem_addr [11:0];
    logic [`XLEN-1:0] Imem2proc_data [11:0];

    // 0 to 1
    DATA_PACKET d_core0_to_core1;
    logic d_valid_core0_to_core1;
    logic d_ready_core0_to_core1;

    // 0 to 4
    DATA_PACKET d_core0_to_core4;
    logic d_valid_core0_to_core4;
    logic d_ready_core0_to_core4;

    // 1 to 0
    DATA_PACKET d_core1_to_core0;
    logic d_valid_core1_to_core0;
    logic d_ready_core1_to_core0;

    // 1 to 2
    DATA_PACKET d_core1_to_core2;
    logic d_valid_core1_to_core2;
    logic d_ready_core1_to_core2;

    // 1 to 5
    DATA_PACKET d_core1_to_core5;
    logic d_valid_core1_to_core5;
    logic d_ready_core1_to_core5;

    // 2 to 1
    DATA_PACKET d_core2_to_core1;
    logic d_valid_core2_to_core1;
    logic d_ready_core2_to_core1;

    // 2 to 3
    DATA_PACKET d_core2_to_core3;
    logic d_valid_core2_to_core3;
    logic d_ready_core2_to_core3;

    // 2 to 6
    DATA_PACKET d_core2_to_core6;
    logic d_valid_core2_to_core6;
    logic d_ready_core2_to_core6;

    // 3 to 2
    DATA_PACKET d_core3_to_core2;
    logic d_valid_core3_to_core2;
    logic d_ready_core3_to_core2;

    // 3 to 7
    DATA_PACKET d_core3_to_core7;
    logic d_valid_core3_to_core7;
    logic d_ready_core3_to_core7;

    // 4 to 0
    DATA_PACKET d_core4_to_core0;
    logic d_valid_core4_to_core0;
    logic d_ready_core4_to_core0;

    // 4 to 5
    DATA_PACKET d_core4_to_core5;
    logic d_valid_core4_to_core5;
    logic d_ready_core4_to_core5;

    // 4 to 8
    DATA_PACKET d_core4_to_core8;
    logic d_valid_core4_to_core8;
    logic d_ready_core4_to_core8;

    // 5 to 4
    DATA_PACKET d_core5_to_core4;
    logic d_valid_core5_to_core4;
    logic d_ready_core5_to_core4;

    // 5 to 1
    DATA_PACKET d_core5_to_core1;
    logic d_valid_core5_to_core1;
    logic d_ready_core5_to_core1;

    // 5 to 6
    DATA_PACKET d_core5_to_core6;
    logic d_valid_core5_to_core6;
    logic d_ready_core5_to_core6;

    // 5 to 9
    DATA_PACKET d_core5_to_core9;
    logic d_valid_core5_to_core9;
    logic d_ready_core5_to_core9;

    // 6 to 5
    DATA_PACKET d_core6_to_core5;
    logic d_valid_core6_to_core5;
    logic d_ready_core6_to_core5;

    // 6 to 2
    DATA_PACKET d_core6_to_core2;
    logic d_valid_core6_to_core2;
    logic d_ready_core6_to_core2;

    // 6 to 7
    DATA_PACKET d_core6_to_core7;
    logic d_valid_core6_to_core7;
    logic d_ready_core6_to_core7;

    // 6 to 10
    DATA_PACKET d_core6_to_core10;
    logic d_valid_core6_to_core10;
    logic d_ready_core6_to_core10;

    // 7 to 6
    DATA_PACKET d_core7_to_core6;
    logic d_valid_core7_to_core6;
    logic d_ready_core7_to_core6;

    // 7 to 3
    DATA_PACKET d_core7_to_core3;
    logic d_valid_core7_to_core3;
    logic d_ready_core7_to_core3;

    // 7 to 11
    DATA_PACKET d_core7_to_core11;
    logic d_valid_core7_to_core11;
    logic d_ready_core7_to_core11;

    // 8 to 4
    DATA_PACKET d_core8_to_core4;
    logic d_valid_core8_to_core4;
    logic d_ready_core8_to_core4;

    // 8 to 9
    DATA_PACKET d_core8_to_core9;
    logic d_valid_core8_to_core9;
    logic d_ready_core8_to_core9;

    // 8 to 12
    DATA_PACKET d_core8_to_core12;
    logic d_valid_core8_to_core12;
    logic d_ready_core8_to_core12;

    // 9 to 8
    DATA_PACKET d_core9_to_core8;
    logic d_valid_core9_to_core8;
    logic d_ready_core9_to_core8;

    // 9 to 5
    DATA_PACKET d_core9_to_core5;
    logic d_valid_core9_to_core5;
    logic d_ready_core9_to_core5;

    // 9 to 10
    DATA_PACKET d_core9_to_core10;
    logic d_valid_core9_to_core10;
    logic d_ready_core9_to_core10;

    // 9 to 13
    DATA_PACKET d_core9_to_core13;
    logic d_valid_core9_to_core13;
    logic d_ready_core9_to_core13;

    // 10 to 9
    DATA_PACKET d_core10_to_core9;
    logic d_valid_core10_to_core9;
    logic d_ready_core10_to_core9;

    // 10 to 6
    DATA_PACKET d_core10_to_core6;
    logic d_valid_core10_to_core6;
    logic d_ready_core10_to_core6;

    // 10 to 11
    DATA_PACKET d_core10_to_core11;
    logic d_valid_core10_to_core11;
    logic d_ready_core10_to_core11;

    // 10 to 14
    DATA_PACKET d_core10_to_core14;
    logic d_valid_core10_to_core14;
    logic d_ready_core10_to_core14;

    // 11 to 10
    DATA_PACKET d_core11_to_core10;
    logic d_valid_core11_to_core10;
    logic d_ready_core11_to_core10;

    // 11 to 7
    DATA_PACKET d_core11_to_core7;
    logic d_valid_core11_to_core7;
    logic d_ready_core11_to_core7;

    // 11 to 15
    DATA_PACKET d_core11_to_core15;
    logic d_valid_core11_to_core15;
    logic d_ready_core11_to_core15;

    // 12 to 8
    DATA_PACKET d_core12_to_core8;
    logic d_valid_core12_to_core8;
    logic d_ready_core12_to_core8;

    // 12 to 13
    DATA_PACKET d_core12_to_core13;
    logic d_valid_core12_to_core13;
    logic d_ready_core12_to_core13;

    // 13 to 12
    DATA_PACKET d_core13_to_core12;
    logic d_valid_core13_to_core12;
    logic d_ready_core13_to_core12;

    // 13 to 9
    DATA_PACKET d_core13_to_core9;
    logic d_valid_core13_to_core9;
    logic d_ready_core13_to_core9;

    // 13 to 14
    DATA_PACKET d_core13_to_core14;
    logic d_valid_core13_to_core14;
    logic d_ready_core13_to_core14;

    // 14 to 13
    DATA_PACKET d_core14_to_core13;
    logic d_valid_core14_to_core13;
    logic d_ready_core14_to_core13;

    // 14 to 10
    DATA_PACKET d_core14_to_core10;
    logic d_valid_core14_to_core10;
    logic d_ready_core14_to_core10;

    // 14 to 15
    DATA_PACKET d_core14_to_core15;
    logic d_valid_core14_to_core15;
    logic d_ready_core14_to_core15;

    // 15 to 14
    DATA_PACKET d_core15_to_core14;
    logic d_valid_core15_to_core14;
    logic d_ready_core15_to_core14;

    // 15 to 11
    DATA_PACKET d_core15_to_core11;
    logic d_valid_core15_to_core11;
    logic d_ready_core15_to_core11;



    string program_memory_file;
	string writeback_output_file;
	string pipeline_output_file;

    logic test_core;
    assign test_core = 0;



    full_proc_mem_top proc(
        .user_addr(user_addr),
        .user_memid(user_memid),
        .user_readout(user_readout),
        .scan_enable(scan_enable),
        .scan_clk(scan_clk),
        .scan_in(scan_in),
        .scan_mode(scan_mode),
        .clock_proc0(clock_proc0),
        .clock_proc1(clock_proc1),
        .clock_proc2(clock_proc2),
        .clock_proc3(clock_proc3),
        .clock_proc4(clock_proc4),
        .clock_proc5(clock_proc5),
        .clock_proc6(clock_proc6),
        .clock_proc7(clock_proc7),
        .clock_proc8(clock_proc8),
        .clock_proc9(clock_proc9),
        .clock_proc10(clock_proc10),
        .clock_proc11(clock_proc11),

        .clock_router(clock_router),
        .reset(reset),

        .d_in(d_in),
        .d_valid_in(d_valid_in),
        .d_ready_in(d_ready_in),
        .d_ready_out(d_ready_out),
        .d_valid_out(d_valid_out),
        .d_out(d_out),

        .clock_control(clock_control),
        .if_id_NPC(if_id_NPC),
        .if_valid_inst_out(if_valid_inst_out),
        .mem_result_out(mem_result_out),
        .stop(stop),
        .asyn_mem_stage_data(asyn_mem_stage_data),
        .asyn_mem_stage_valid(asyn_mem_stage_valid),

        .mem_stage_asyn_data_req(mem_stage_asyn_data_req),
        .mem_stage_asyn_req_id(mem_stage_asyn_req_id),
        .core_id(core_id),
        .core_id_valid(core_id_valid),
        .proc2router_request(proc2router_request),
        .proc2router_ack(proc2router_ack),
        .router2proc_ack(router2proc_ack),
        .router2proc_request(router2proc_request),

        .proc2Imem_addr(proc2Imem_addr),
        .Imem2proc_data(Imem2proc_data),

        .d_core0_to_core1(d_core0_to_core1),
        .d_valid_core0_to_core1(d_valid_core0_to_core1),
        .d_ready_core0_to_core1(d_ready_core0_to_core1),

        .d_core0_to_core4(d_core0_to_core4),
        .d_valid_core0_to_core4(d_valid_core0_to_core4),
        .d_ready_core0_to_core4(d_ready_core0_to_core4),

        .d_core1_to_core0(d_core1_to_core0),
        .d_valid_core1_to_core0(d_valid_core1_to_core0),
        .d_ready_core1_to_core0(d_ready_core1_to_core0),

        .d_core1_to_core2(d_core1_to_core2),
        .d_valid_core1_to_core2(d_valid_core1_to_core2),
        .d_ready_core1_to_core2(d_ready_core1_to_core2),

        .d_core1_to_core5(d_core1_to_core5),
        .d_valid_core1_to_core5(d_valid_core1_to_core5),
        .d_ready_core1_to_core5(d_ready_core1_to_core5),

        .d_core2_to_core1(d_core2_to_core1),
        .d_valid_core2_to_core1(d_valid_core2_to_core1),
        .d_ready_core2_to_core1(d_ready_core2_to_core1),

        .d_core2_to_core3(d_core2_to_core3),
        .d_valid_core2_to_core3(d_valid_core2_to_core3),
        .d_ready_core2_to_core3(d_ready_core2_to_core3),

        .d_core2_to_core6(d_core2_to_core6),
        .d_valid_core2_to_core6(d_valid_core2_to_core6),
        .d_ready_core2_to_core6(d_ready_core2_to_core6),

        .d_core3_to_core2(d_core3_to_core2),
        .d_valid_core3_to_core2(d_valid_core3_to_core2),
        .d_ready_core3_to_core2(d_ready_core3_to_core2),

        .d_core3_to_core7(d_core3_to_core7),
        .d_valid_core3_to_core7(d_valid_core3_to_core7),
        .d_ready_core3_to_core7(d_ready_core3_to_core7),

        .d_core4_to_core0(d_core4_to_core0),
        .d_valid_core4_to_core0(d_valid_core4_to_core0),
        .d_ready_core4_to_core0(d_ready_core4_to_core0),

        .d_core4_to_core5(d_core4_to_core5),
        .d_valid_core4_to_core5(d_valid_core4_to_core5),
        .d_ready_core4_to_core5(d_ready_core4_to_core5),

        .d_core4_to_core8(d_core4_to_core8),
        .d_valid_core4_to_core8(d_valid_core4_to_core8),
        .d_ready_core4_to_core8(d_ready_core4_to_core8),

        .d_core5_to_core4(d_core5_to_core4),
        .d_valid_core5_to_core4(d_valid_core5_to_core4),
        .d_ready_core5_to_core4(d_ready_core5_to_core4),

        .d_core5_to_core1(d_core5_to_core1),
        .d_valid_core5_to_core1(d_valid_core5_to_core1),
        .d_ready_core5_to_core1(d_ready_core5_to_core1),

        .d_core5_to_core6(d_core5_to_core6),
        .d_valid_core5_to_core6(d_valid_core5_to_core6),
        .d_ready_core5_to_core6(d_ready_core5_to_core6),

        .d_core5_to_core9(d_core5_to_core9),
        .d_valid_core5_to_core9(d_valid_core5_to_core9),
        .d_ready_core5_to_core9(d_ready_core5_to_core9),

        .d_core6_to_core5(d_core6_to_core5),
        .d_valid_core6_to_core5(d_valid_core6_to_core5),
        .d_ready_core6_to_core5(d_ready_core6_to_core5),

        .d_core6_to_core2(d_core6_to_core2),
        .d_valid_core6_to_core2(d_valid_core6_to_core2),
        .d_ready_core6_to_core2(d_ready_core6_to_core2),

        .d_core6_to_core7(d_core6_to_core7),
        .d_valid_core6_to_core7(d_valid_core6_to_core7),
        .d_ready_core6_to_core7(d_ready_core6_to_core7),

        .d_core6_to_core10(d_core6_to_core10),
        .d_valid_core6_to_core10(d_valid_core6_to_core10),
        .d_ready_core6_to_core10(d_ready_core6_to_core10),

        .d_core7_to_core6(d_core7_to_core6),
        .d_valid_core7_to_core6(d_valid_core7_to_core6),
        .d_ready_core7_to_core6(d_ready_core7_to_core6),

        .d_core7_to_core3(d_core7_to_core3),
        .d_valid_core7_to_core3(d_valid_core7_to_core3),
        .d_ready_core7_to_core3(d_ready_core7_to_core3),

        .d_core7_to_core11(d_core7_to_core11),
        .d_valid_core7_to_core11(d_valid_core7_to_core11),
        .d_ready_core7_to_core11(d_ready_core7_to_core11),

        .d_core8_to_core4(d_core8_to_core4),
        .d_valid_core8_to_core4(d_valid_core8_to_core4),
        .d_ready_core8_to_core4(d_ready_core8_to_core4),

        .d_core8_to_core9(d_core8_to_core9),
        .d_valid_core8_to_core9(d_valid_core8_to_core9),
        .d_ready_core8_to_core9(d_ready_core8_to_core9),

        .d_core8_to_core12(d_core8_to_core12),
        .d_valid_core8_to_core12(d_valid_core8_to_core12),
        .d_ready_core8_to_core12(d_ready_core8_to_core12),

        .d_core9_to_core8(d_core9_to_core8),
        .d_valid_core9_to_core8(d_valid_core9_to_core8),
        .d_ready_core9_to_core8(d_ready_core9_to_core8),

        .d_core9_to_core5(d_core9_to_core5),
        .d_valid_core9_to_core5(d_valid_core9_to_core5),
        .d_ready_core9_to_core5(d_ready_core9_to_core5),

        .d_core9_to_core10(d_core9_to_core10),
        .d_valid_core9_to_core10(d_valid_core9_to_core10),
        .d_ready_core9_to_core10(d_ready_core9_to_core10),

        .d_core9_to_core13(d_core9_to_core13),
        .d_valid_core9_to_core13(d_valid_core9_to_core13),
        .d_ready_core9_to_core13(d_ready_core9_to_core13),

        .d_core10_to_core9(d_core10_to_core9),
        .d_valid_core10_to_core9(d_valid_core10_to_core9),
        .d_ready_core10_to_core9(d_ready_core10_to_core9),

        .d_core10_to_core6(d_core10_to_core6),
        .d_valid_core10_to_core6(d_valid_core10_to_core6),
        .d_ready_core10_to_core6(d_ready_core10_to_core6),

        .d_core10_to_core11(d_core10_to_core11),
        .d_valid_core10_to_core11(d_valid_core10_to_core11),
        .d_ready_core10_to_core11(d_ready_core10_to_core11),

        .d_core10_to_core14(d_core10_to_core14),
        .d_valid_core10_to_core14(d_valid_core10_to_core14),
        .d_ready_core10_to_core14(d_ready_core10_to_core14),

        .d_core11_to_core10(d_core11_to_core10),
        .d_valid_core11_to_core10(d_valid_core11_to_core10),
        .d_ready_core11_to_core10(d_ready_core11_to_core10),

        .d_core11_to_core7(d_core11_to_core7),
        .d_valid_core11_to_core7(d_valid_core11_to_core7),
        .d_ready_core11_to_core7(d_ready_core11_to_core7),

        .d_core11_to_core15(d_core11_to_core15),
        .d_valid_core11_to_core15(d_valid_core11_to_core15),
        .d_ready_core11_to_core15(d_ready_core11_to_core15),

        .d_core12_to_core8(d_core12_to_core8),
        .d_valid_core12_to_core8(d_valid_core12_to_core8),
        .d_ready_core12_to_core8(d_ready_core12_to_core8),

        .d_core12_to_core13(d_core12_to_core13),
        .d_valid_core12_to_core13(d_valid_core12_to_core13),
        .d_ready_core12_to_core13(d_ready_core12_to_core13),

        .d_core13_to_core12(d_core13_to_core12),
        .d_valid_core13_to_core12(d_valid_core13_to_core12),
        .d_ready_core13_to_core12(d_ready_core13_to_core12),

        .d_core13_to_core9(d_core13_to_core9),
        .d_valid_core13_to_core9(d_valid_core13_to_core9),
        .d_ready_core13_to_core9(d_ready_core13_to_core9),

        .d_core13_to_core14(d_core13_to_core14),
        .d_valid_core13_to_core14(d_valid_core13_to_core14),
        .d_ready_core13_to_core14(d_ready_core13_to_core14),

        .d_core14_to_core13(d_core14_to_core13),
        .d_valid_core14_to_core13(d_valid_core14_to_core13),
        .d_ready_core14_to_core13(d_ready_core14_to_core13),

        .d_core14_to_core10(d_core14_to_core10),
        .d_valid_core14_to_core10(d_valid_core14_to_core10),
        .d_ready_core14_to_core10(d_ready_core14_to_core10),

        .d_core14_to_core15(d_core14_to_core15),
        .d_valid_core14_to_core15(d_valid_core14_to_core15),
        .d_ready_core14_to_core15(d_ready_core14_to_core15),

        .d_core15_to_core14(d_core15_to_core14),
        .d_valid_core15_to_core14(d_valid_core15_to_core14),
        .d_ready_core15_to_core14(d_ready_core15_to_core14),

        .d_core15_to_core11(d_core15_to_core11),
        .d_valid_core15_to_core11(d_valid_core15_to_core11),
        .d_ready_core15_to_core11(d_ready_core15_to_core11)
    );

    always begin
		#5;
		clock_router = ~clock_router;
	end

    always begin
        #2;
        scan_clk = ~scan_clk;
    end

    always begin
		#8;
		clock_proc0 = ~clock_proc0;
	end

    always begin
		#12;
		clock_proc1 = ~clock_proc1;
	end                              //clock define

    always begin
        #11;
        clock_proc2 = ~clock_proc2;
    end

    always begin
        #9;
        clock_proc3 = ~clock_proc3;
    end

    always begin
        #11;
        clock_proc4 = ~clock_proc4;
    end

    always begin
        #10;
        clock_proc5 = ~clock_proc5;
    end

    always begin
        #9;
        clock_proc6 = ~clock_proc6;
    end

    always begin
        #11;
        clock_proc7 = ~clock_proc7;
    end

    always begin
        #10;
        clock_proc8 = ~clock_proc8;
    end

    always begin
        #11;
        clock_proc9 = ~clock_proc9;
    end

    always begin
        #10;
        clock_proc10 = ~clock_proc10;
    end 

    always begin
        #8;
        clock_proc11 = ~clock_proc11;
    end


    logic [607:0] inst_0;
    assign inst_0 = {
                    32'h10500073, 32'h6030063F,
                    32'h002081B3, 32'h0000810B,
                    32'h000180B3, 32'h002081B3,
                    32'h0001010B, 32'h000180B3,
                    32'h002081B3, 32'h0006015B,
                    32'h0240061F, 32'h000600DB,
                    32'h0200061F, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h0000002B
                    };

    logic [543:0] inst_1;
    assign inst_1 = {
                    32'h10500073, 32'h0030007B,
                    32'h000180B3, 32'h002081B3,
                    32'h0001810B, 32'h000180B3,
                    32'h002081B3, 32'h0006815B,
                    32'h0240069F, 32'h000680DB,
                    32'h0200069F, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h0010002B
                    };

    logic [415:0] inst_2;
    assign inst_2 = {
                    32'h10500073, 32'h0030007B,
                    32'h002081B3, 32'h0007015B,
                    32'h0240071F, 32'h000700DB,
                    32'h0200071F, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h0020002B
                    };

    logic [415:0] inst_3;
    assign inst_3 = {
                    32'h10500073, 32'h003000FB,
                    32'h002081B3, 32'h0007815B,
                    32'h0240079F, 32'h000780DB,
                    32'h0200079F, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h0030002B
                    };


    logic [1247:0] inst_4;
    assign inst_4 = {

                    32'h10500073, 32'h58A0063F,
                    32'h02940533, 32'h027304B3,
                    32'h02520433, 32'h00000033,
                    32'h00000033, 32'h0003838B,
                    32'h0003030B, 32'h0002828B,
                    32'h00000033, 32'h00000033,
                    32'h004003FB, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h0040037B,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h004002FB, 32'h00400213,
                    32'h00400093, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h0040002B
                    };

    logic [1247:0] inst_5;
    assign inst_5 = {
                    32'h10500073, 32'h58A006BF,
                    32'h02940533, 32'h027304B3,
                    32'h02520433, 32'h00000033,
                    32'h00000033, 32'h0003838B,
                    32'h0003030B, 32'h00000033,
                    32'h00000033, 32'h005003FB,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h0050037B, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h0050027B,
                    32'h0002020B, 32'h00500293,
                    32'h00500093, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h0050002B
                    };

    logic [1247:0] inst_6;
    assign inst_6 = {
                    32'h10500073, 32'h58A0073F,
                    32'h02940533, 32'h027304B3,
                    32'h02520433, 32'h00000033,
                    32'h00000033, 32'h0003838B,
                    32'h00000033, 32'h00000033,
                    32'h006003FB, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h006002FB,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h0060027B, 32'h0002828B,
                    32'h0002020B, 32'h00600313,
                    32'h00600093, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h0060002B
                    };

    logic [1119:0] inst_7;
    assign inst_7 = {
                    32'h10500073, 32'h58A007BF,
                    32'h02940533, 32'h027304B3,
                    32'h02520433, 32'h0070037B,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h007002FB, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h0070027B,
                    32'h0003030B, 32'h0002828B,
                    32'h0002020B, 32'h00700393,
                    32'h00700093, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h0070002B
                    };
    logic [607:0] inst_8;
    assign inst_8 = {
                    32'h10500073, 32'h5070063F,
                    32'h006283B3, 32'h02410333,
                    32'h023082B3, 32'h0006025B,
                    32'h0180061F, 32'h000601DB,
                    32'h0100061F, 32'h0006015B,
                    32'h0040061F, 32'h000600DB,
                    32'h0000061F, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h0080002B
                    };

    logic [607:0] inst_9;
    assign inst_9 = {
                    32'h10500073, 32'h507006BF,
                    32'h006283B3, 32'h02410333,
                    32'h023082B3, 32'h0006825B,
                    32'h01C0069F, 32'h000681DB,
                    32'h0140069F, 32'h0006815B,
                    32'h0040069F, 32'h000680DB,
                    32'h0000069F, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h0090002B 
                    };

    logic [607:0] inst_10;
    assign inst_10 = {
                    32'h10500073, 32'h5070073F,
                    32'h006283B3, 32'h02410333,
                    32'h023082B3, 32'h0007025B,
                    32'h0180071F, 32'h000701DB,
                    32'h0100071F, 32'h0007015B,
                    32'h00C0071F, 32'h000700DB,
                    32'h0080071F, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00A0002B
                    };

    logic [607:0] inst_11;
    assign inst_11 = {
                    32'h10500073, 32'h507007BF,
                    32'h006283B3, 32'h02410333,
                    32'h023082B3, 32'h0007825B,
                    32'h01C0079F, 32'h000781DB,
                    32'h0140079F, 32'h0007815B,
                    32'h00C0079F, 32'h000780DB,
                    32'h0080079F, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00000033, 32'h00000033,
                    32'h00B0002B
                    };

    logic [319:0] load_data_12;
    assign load_data_12 = {
                    32'h00000017, 32'h00000057,
                    32'h00000008, 32'h00000007,
                    32'h00000006, 32'h00000005,
                    32'h00000004, 32'h00000003,
                    32'h00000002, 32'h00000001
                    };

    logic [319:0] load_data_13;
    assign load_data_13 = {
                    32'h0000000C, 32'h00000061,
                    32'h00000008, 32'h00000007,
                    32'h00000006, 32'h00000005,
                    32'h00000004, 32'h00000003,
                    32'h00000002, 32'h00000001
                    };

    logic [319:0] load_data_14;
    assign load_data_14 = {
                    32'h00000036, 32'h0000006E,
                    32'h00000008, 32'h00000007,
                    32'h00000006, 32'h00000005,
                    32'h00000004, 32'h00000003,
                    32'h00000002, 32'h00000001
                    };

    logic [319:0] load_data_15;
    assign load_data_15 = {
                    32'h00000048, 32'h0000002C,
                    32'h00000008, 32'h00000007,
                    32'h00000006, 32'h00000005,
                    32'h00000004, 32'h00000003,
                    32'h00000002, 32'h00000001
                    };


    
    logic [31:0] index0;
    logic [31:0] index1;
    logic [31:0] index2;
    logic [31:0] index3;
    logic [31:0] index4;
    logic [31:0] index5;
    logic [31:0] index6;
    logic [31:0] index7;
    logic [31:0] index8;
    logic [31:0] index9;
    logic [31:0] index10;
    logic [31:0] index11;
    logic [31:0] index12;
    logic [31:0] index13;
    logic [31:0] index14;
    logic [31:0] index15;


	always @(posedge scan_clk) begin
        // 0
		if ($time < 9000) begin
			if (reset) begin
                index0 <= #1 0;
                index1 <= #1 0;
                index2 <= #1 0;
                index3 <= #1 0;
                index4 <= #1 0;
                index5 <= #1 0;
                index6 <= #1 0;
                index7 <= #1 0;
				index8 <= #1 0;
                index9 <= #1 0;
                index10 <= #1 0;
                index11 <= #1 0;
                index12 <= #1 0;
                index13 <= #1 0;
                index14 <= #1 0;
                index15 <= #1 0;
				scan_in <= #1 0;
				scan_enable[0] <= #1 0;
			end
			else begin
				scan_enable[0] <= #1 1;
				scan_in <= #1 inst_0[index0];
				index0 <= #1 index0 + 1;
			end
		end

        // 1
        else if ($time >= 10000 && $time < 19000) begin
            if (reset) begin
				index1 <= #1 0;
				scan_in <= #1 0;
				scan_enable[1] <= #1 0;
			end
			else begin
				scan_enable[1] <= #1 1;
				scan_in <= #1 inst_1[index1];
				index1 <= #1 index1 + 1;
			end
        end

        // 2
        else if ($time >= 20000 && $time < 29000) begin
            if (reset) begin
                index2 <= #1 0;
                scan_in <= #1 0;
                scan_enable[2] <= #1 0;
            end
            else begin
                scan_enable[2] <= #1 1;
                scan_in <= #1 inst_2[index2];
                index2 <= #1 index2 + 1;
            end
        end

        // 3
        else if ($time >= 30000 && $time < 39000) begin
            if (reset) begin
                index3 <= #1 0;
                scan_in <= #1 0;
                scan_enable[3] <= #1 0;
            end
            else begin
                scan_enable[3] <= #1 1;
                scan_in <= #1 inst_3[index3];
                index3 <= #1 index3 + 1;
            end
        end

        // 4
        else if ($time >= 40000 && $time < 49000) begin
            if (reset) begin
                index4 <= #1 0;
                scan_in <= #1 0;
                scan_enable[4] <= #1 0;
            end
            else begin
                scan_enable[4] <= #1 1;
                scan_in <= #1 inst_4[index4];
                index4 <= #1 index4 + 1;
            end
        end

        // 5
        else if ($time >= 50000 && $time < 59000) begin
            if (reset) begin
                index5 <= #1 0;
                scan_in <= #1 0;
                scan_enable[5] <= #1 0;
            end
            else begin
                scan_enable[5] <= #1 1;
                scan_in <= #1 inst_5[index5];
                index5 <= #1 index5 + 1;
            end
        end

        // 6
        else if ($time >= 60000 && $time < 69000) begin
            if (reset) begin
                index6 <= #1 0;
                scan_in <= #1 0;
                scan_enable[6] <= #1 0;
            end
            else begin
                scan_enable[6] <= #1 1;
                scan_in <= #1 inst_6[index6];
                index6 <= #1 index6 + 1;
            end
        end

        // 7
        else if ($time >= 70000 && $time < 79000) begin
            if (reset) begin
                index7 <= #1 0;
                scan_in <= #1 0;
                scan_enable[7] <= #1 0;
            end
            else begin
                scan_enable[7] <= #1 1;
                scan_in <= #1 inst_7[index7];
                index7 <= #1 index7 + 1;
            end
        end

        // 8
        else if ($time >= 80000 && $time < 89000) begin
            if (reset) begin
                index8 <= #1 0;
                scan_in <= #1 0;
                scan_enable[8] <= #1 0;
            end
            else begin
                scan_enable[8] <= #1 1;
                scan_in <= #1 inst_8[index8];
                index8 <= #1 index8 + 1;
            end
        end

        // 9
        else if ($time >= 90000 && $time < 99000) begin
            if (reset) begin
                index9 <= #1 0;
                scan_in <= #1 0;
                scan_enable[9] <= #1 0;
            end
            else begin
                scan_enable[9] <= #1 1;
                scan_in <= #1 inst_9[index9];
                index9 <= #1 index9 + 1;
            end
        end

        // 10
        else if ($time >= 100000 && $time < 109000) begin
            if (reset) begin
                index10 <= #1 0;
                scan_in <= #1 0;
                scan_enable[10] <= #1 0;
            end
            else begin
                scan_enable[10] <= #1 1;
                scan_in <= #1 inst_10[index10];
                index10 <= #1 index10 + 1;
            end
        end

        // 11
        else if ($time >= 110000 && $time < 119000) begin
            if (reset) begin
                index11 <= #1 0;
                scan_in <= #1 0;
                scan_enable[11] <= #1 0;
            end
            else begin
                scan_enable[11] <= #1 1;
                scan_in <= #1 inst_11[index11];
                index11 <= #1 index11 + 1;
            end
        end

        // 12
        else if ($time >= 120000 && $time < 129000) begin
            if (reset) begin
                index12 <= #1 0;
                scan_in <= #1 0;
                scan_enable[12] <= #1 0;
            end
            else begin
                scan_enable[12] <= #1 1;
                scan_in <= #1 load_data_12[index12];
                index12 <= #1 index12 + 1;
            end
        end

        // 13
        else if ($time >= 130000 && $time < 139000) begin
            if (reset) begin
                index13 <= #1 0;
                scan_in <= #1 0;
                scan_enable[13] <= #1 0;
            end
            else begin
                scan_enable[13] <= #1 1;
                scan_in <= #1 load_data_13[index13];
                index13 <= #1 index13 + 1;
            end
        end

        // 14
        else if ($time >= 140000 && $time < 149000) begin
            if (reset) begin
                index14 <= #1 0;
                scan_in <= #1 0;
                scan_enable[14] <= #1 0;
            end
            else begin
                scan_enable[14] <= #1 1;
                scan_in <= #1 load_data_14[index14];
                index14 <= #1 index14 + 1;
            end
        end

        // 15
        else if ($time >= 150000 && $time < 159000) begin
            if (reset) begin
                index15 <= #1 0;
                scan_in <= #1 0;
                scan_enable[15] <= #1 0;
            end
            else begin
                scan_enable[15] <= #1 1;
                scan_in <= #1 load_data_15[index15];
                index15 <= #1 index15 + 1;
            end
        end
        
       
		else begin
			scan_enable <= #1 0;
		end
	end


    initial begin
        
        clock_proc0 = 0;
        clock_proc1 = 0;
        clock_proc2 = 0;
        clock_proc3 = 0;
        clock_proc4 = 0;
        clock_proc5 = 0;
        clock_proc6 = 0;
        clock_proc7 = 0;
        clock_proc8 = 0;
        clock_proc9 = 0;
        clock_proc10 = 0;
        clock_proc11 = 0;

        user_addr = 0;
        user_memid = 0;
    

        clock_router = 0;
        reset = 0;
        d_in = 0;
        d_valid_in = 0;
        d_ready_in = 0;
        reset = 1;
        scan_mode = 0;
        scan_clk = 0;
        scan_enable = 0;
        scan_in = 0;
        @(posedge clock_router);
        @(posedge clock_router);
        @(posedge clock_router);
        @(posedge clock_router);
        @(posedge clock_router);
        @(posedge clock_router);
        @(posedge clock_router);
        @(posedge clock_router);
        @(posedge clock_router);
        @(posedge scan_clk);
        #1;
        reset = 0;
        scan_mode = 1;
        #159995
        scan_mode = 0;
        #5000
        @(posedge clock_router);
        user_addr = 12;
        user_memid = 1;
        @(posedge clock_router);
        user_addr = 11;
        @(posedge clock_router);
        user_addr = 10;
        @(posedge clock_router);
        user_addr = 10;
        user_memid = 2;
        @(posedge clock_router);
        user_addr = 11;
        @(posedge clock_router);
        user_addr = 10;
        user_memid = 4;
        @(posedge clock_router);
        user_addr = 11;
        @(posedge clock_router);
        user_addr = 10;
        user_memid = 8;
        @(posedge clock_router);
        user_addr = 11;
        @(posedge clock_router);
        user_memid = 10;
        


        #200
        $finish;

        // $finish;
    end

endmodule