`timescale 1ns/1ps
module ROM (addr,data);
input [31:0] addr;
output [31:0] data;
reg [31:0] data;
localparam ROM_SIZE = 32;
reg [31:0] ROM_DATA[ROM_SIZE-1:0];
always@(*)
	case(addr[10:2])
		0: data <= 32'h08000003;
		1: data <= 32'h08000003;
		2: data <= 32'h08000003;
		3: data <= 32'h012a4022;
		4: data <= 32'h012a4020;
		5: data <= 32'h08000006;
		6: data <= 32'h012a4026;
		7: data <= 32'had49ff9c;
		8: data <= 32'h000a4d00;
		9: data <= 32'h2151ff9c;
		10: data <= 32'h0520fff9;
		11: data <= 32'h03e00008;
		12: data <= 32'h0080f809;
		13: data <= 32'h014b482a;
		14: data <= 32'h00000000;
	endcase
endmodule
