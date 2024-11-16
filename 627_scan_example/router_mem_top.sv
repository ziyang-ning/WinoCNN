// `include "router_def.svh"

//---------- INSTANCE TEMPLATE -----------//
//   router_top #(
//     .ROUTER_ID(5'b00000)
//     ) router_instance (
//         .clock(clock),
//         .reset(reset),
//         .d_in(),         
//         .d_valid_in(),
//         .d_ready_out(),
//         .d_out(),         
//         .d_valid_out(),
//         .d_ready_in(),
//         .d_test(),       
//         .send_en(),   
//         .d_source_out()
//     );
    
module router_mem_top #(
    parameter ROUTER_ID = 5'b00000
) (
    input logic clock,
    input logic reset,

    // Data router channel
    // Slave: recieve packet and respond
    input DATA_PACKET  [3:0] d_in ,
    input logic [3:0] d_valid_in,
    output logic [3:0] d_ready_out ,

    // Master: route packets to next router
    output DATA_PACKET [3:0] d_out ,
    output logic [3:0] d_valid_out,
    input logic [3:0] d_ready_in,
    input scan_clk,
    input scan_in,
    input scan_enable,
    input scan_mode,
    input [9:0] user_addr,
    input user_memid,
    output logic [7:0] user_readout

    // // Test signals
    // input DATA_PACKET d_test,
    // input logic send_en,
    // output logic [`ROUTER_REGION - 1:0] d_source_out

);

    DATA_PACKET mem_d_in;
    logic mem_d_valid_in;
    logic mem_d_ready_out;

    DATA_PACKET mem_d_out;
    logic mem_d_valid_out;
    logic mem_d_ready_in;


    //----- MEM -----//
    logic [`DATA_WIDTH - 1:0] Q,D;
    logic [9:0] A;
    logic CEN;
    logic WEN;

    logic sel_imem;
    logic [31:0] data_imem;
    logic [8:0] scan_addr;
    assign user_readout = user_memid ? Q[7:0] : 8'b10101010;


    logic [31:0] sram_d;
    logic [9:0] sram_addr;
    assign sram_d = scan_mode ? data_imem : WEN ? 32'hdeadbeef : D; 
    assign sram_addr = scan_mode ? {1'b0, scan_addr} : user_memid ? user_addr : A;
    logic sram_CEN;
    assign sram_CEN = CEN && reset;
    logic sram_WEN;
    assign sram_WEN = WEN && sel_imem;
    logic sram_clk;
    assign sram_clk = scan_enable ? scan_clk : !clock;


    router_mem  #(
        .ROUTER_ID(ROUTER_ID)
    ) router_instance (
        .clock(clock),
        .reset(reset),
        .d_in({d_in,mem_d_out}),
        .d_valid_in({d_valid_in,mem_d_valid_out}),
        .d_ready_out({d_ready_out,mem_d_ready_in}),
        .d_out({d_out,mem_d_in}),
        .d_valid_out({d_valid_out,mem_d_valid_in}),
        .d_ready_in({d_ready_in,mem_d_ready_out})
    );   

    router2mem router2mem_instance0 (
        .clock(clock),
        .reset(reset),
        .d_in(mem_d_in),
        .d_valid_in(mem_d_valid_in),
        .d_ready_out(mem_d_ready_out),

        .d_out(mem_d_out),
        .d_valid_out(mem_d_valid_out),
        .d_ready_in(mem_d_ready_in),
        .Q(Q),
        .CEN(CEN),
        .WEN(WEN),
        .A(A),
        .D(D)
    );

    mem_loader mem_loader_0(
		.scan_in(scan_in),
		.scan_clk(scan_clk),
		.scan_enable(scan_enable),
		.reset(reset),
		.sel_out(sel_imem),
		.data_out(data_imem),
		.addr(scan_addr)
	);

    SRAM1024_32 sram_inst0(
        .Q(Q),
        .CLK(sram_clk),
        .CEN(sram_CEN),
        .WEN(sram_WEN),
        .A(sram_addr),
        .D(sram_d)
    );

endmodule