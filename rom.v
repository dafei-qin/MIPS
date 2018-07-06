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
		3: data <= 32'h21490064;
		4: data <= 32'h112affff;
	endcase
endmodule
