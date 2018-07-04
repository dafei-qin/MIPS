`timescale 1ns/1ps
module Shift_tb;
reg [31:0] B;
reg [4:0]  A;
reg [5:0]  ALUFun;
wire [31:0] R;
Shift16 test(A[4], B, ALUFun[1:0], R);

initial begin
	A = 5'b10000;
	B = 32'b10000000000000000000000000000000;
	ALUFun = 6'b100000;
	#1
	ALUFun = 6'b100001;
	#1
	ALUFun = 6'b100011;
	#1
	B = 32'b00000000000000000010000000000000;
	ALUFun = 6'b100000;
end
endmodule