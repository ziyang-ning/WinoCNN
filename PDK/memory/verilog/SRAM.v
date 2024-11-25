/*********************************************************************
*  saed_mc : SRAM Verilog description                              *
*  ---------------------------------------------------------------   *
*  Filename      : /home/wenjieg/Desktop/class/WinoCNN/PDK/memory/mc_work/SRAM.v                         *
*  SRAM name     : SRAM                                              *
*  Word width    : 512   bits                                        *
*  Word number   : 128                                               *
*  Adress width  : 7     bits                                        *
*  ---------------------------------------------------------------   *
*  Creation date : Fri November 22 2024                              *
*********************************************************************/

`timescale 1ns/100fs

`define numAddr 7
`define numWords 128
`define wordLength 512


module SRAM (A1,A2,CE1,CE2,WEB1,WEB2,OEB1,OEB2,CSB1,CSB2,I1,I2,O1,O2);

input 				CE1;
input 				CE2;
input 				WEB1;
input 				WEB2;
input 				OEB1;
input 				OEB2;
input 				CSB1;
input 				CSB2;

input 	[6:0] 		A1;
input 	[6:0] 		A2;
input 	[511:0] 	I1;
input 	[511:0] 	I2;
output 	[511:0] 	O1;
output 	[511:0] 	O2;

reg    	[511:0]   	memory[127:0];
reg  	[511:0]	data_out1;
reg  	[511:0]	data_out2;
reg 	[511:0] 	O1;
reg  	[511:0]	O2;
	
wire 				RE1;
wire 				RE2;	
wire 				WE1;	
wire 				WE2;

and u1 (RE1, ~CSB1,  WEB1);
and u2 (WE1, ~CSB1, ~WEB1);
and u3 (RE2, ~CSB2,  WEB2);
and u4 (WE2, ~CSB2, ~WEB2);

//Primary ports

always @ (posedge CE1) 
	if (RE1)
		data_out1 = memory[A1];
	else 
	   if (WE1)
		memory[A1] = I1;
		

always @ (data_out1 or OEB1)
	if (!OEB1) 
		O1 = data_out1;
	else
		O1 = 512'bz;

//Dual ports	
always @ (posedge CE2)
  	if (RE2)
		data_out2 = memory[A2];
  	else 
	   if (WE2)
		memory[A2] = I2;
		
always @ (data_out2 or OEB2)
	if (!OEB2) 
		O2 = data_out2;
	else
		O2 = 512'bz;

endmodule