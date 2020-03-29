/************************************************************\
 **  Copyright (c) 2011-2021 Anlogic, Inc.
 **  All Right Reserved.
\************************************************************/
/************************************************************\
 ** Log	:	This file is generated by Anlogic IP Generator.
 ** File	:	D:/work/Verilog/VIDEO_SQU_TG/TANG_PRiMER/prj/al_ip/REGRAM.v
 ** Date	:	2020 03 29
 ** TD version	:	4.4.433
\************************************************************/

`timescale 1ns / 1ps

module REGRAM ( doa, dia, addra, clka, wea, rsta );

	output [7:0] doa;

	input  [7:0] dia;
	input  [7:0] addra;
	input  wea;
	input  clka;
	input  rsta;




	EG_LOGIC_BRAM #( .DATA_WIDTH_A(8),
				.ADDR_WIDTH_A(8),
				.DATA_DEPTH_A(256),
				.DATA_WIDTH_B(8),
				.ADDR_WIDTH_B(8),
				.DATA_DEPTH_B(256),
				.MODE("SP"),
				.REGMODE_A("NOREG"),
				.WRITEMODE_A("NORMAL"),
				.RESETMODE("SYNC"),
				.IMPLEMENT("9K"),
				.DEBUGGABLE("YES"),
				.PACKABLE("NO"),
				.FORCE_KEEP("ON"),
				.INIT_FILE("NONE"),
				.FILL_ALL("00000000"))
			inst(
				.dia(dia),
				.dib({8{1'b0}}),
				.addra(addra),
				.addrb({8{1'b0}}),
				.cea(1'b1),
				.ceb(1'b0),
				.ocea(1'b0),
				.oceb(1'b0),
				.clka(clka),
				.clkb(1'b0),
				.wea(wea),
				.web(1'b0),
				.bea(1'b0),
				.beb(1'b0),
				.rsta(rsta),
				.rstb(1'b0),
				.doa(doa),
				.dob());


endmodule