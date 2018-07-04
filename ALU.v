module ALU(A, B, ALUFun, Sign, Z);
input [31:0] A,B;
input [5:0] ALUFun;
input Sign;
output[31:0] Z;
reg [31:0] Z;
wire [31:0] A, B, R1, R2, R3, R4;
wire [5:0] ALUFun;
wire Sign, Zero, V, N;
ADD_SUB S1(Sign, A, B, ALUFun[0], Zero, V, N, R1);
CMP S2(Zero, V, N, ALUFun[3:1], R2);
Logic S3(A, B, ALUFun[3:0], R3);
Shift S4(A, B, ALUFun[1:0], R4);
always @(*)
	case(ALUFun[5:4])
		2'b00: Z <= R1;
		2'b11: Z <= R2;
		2'b01: Z <= R3;
		2'b10: Z <= R4;
	endcase
endmodule

module ADD_SUB(S, A, B, ALUFun, Zero, V, N, R);
input S, ALUFun;
input [31:0] A, B;
output Zero, V, N;
output reg[31:0] R;
wire Zero, V, N;
wire [31:0] A, B;
always @(*)
	case(ALUFun)
		0: R <= A + B;
		1: R <= A + ~B + 1;
	endcase

assign Zero = (R == 0);
assign V = (Sign) && (
				(
					(~ALUFun) 
					&&
					(
						(A[31] && B[31] && ~R[31]) 
						|| 
						(~A[31] && ~B[31] && R[31]) 
					)
				)
				||
				(
					(ALUFun) 
					&&
					(
						(~A[31] && B[31] && R[31]) 
						|| 
						(A[31] && ~B[31] && ~R[31])
					)
				)
			);
endmodule

module CMP(Zero, V, N, ALUFun, R);
input Zero, V, N;
input [2:0] ALUFun;
output reg [31:0] R;
wire Zero, V, N;
wire [2:0] ALUFun;
endmodule

module Logic(A, B, ALUFun, R);
input [31:0] A, B;
input [3:0] ALUFun;
output reg [31:0] R;
endmodule

module Shift(A, B, ALUFun, R);
input [31:0] A, B;
input [1:0] ALUFun;
output reg [31:0] R;
endmodule

