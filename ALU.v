module ALU(A, B, ALUFun, Sign, Z, S, V);
input [31:0] A,B;
input [5:0] ALUFun;
input Sign;
output[31:0] Z;
output S, V;

reg [31:0] Z;
wire [31:0] A, B, R1, R2, R3, R4;
wire [5:0] ALUFun;
wire Sign, Zero, V, N, S;
ADD_SUB S1(Sign, A, B, ALUFun[0], Zero, V, N, R1);
CMP S2(Zero, V, N, ALUFun[3:1], S);
Logic S3(A, B, ALUFun[3:0], R3);
Shift S4(A[4:0], B, ALUFun[1:0], R4);
always @(*)
	case(ALUFun[5:4])
		2'b00: Z <= R1;
		2'b11: Z <= R1;
		2'b01: Z <= R3;
		2'b10: Z <= R4;
	endcase
endmodule

module ADD_SUB(Sign, A, B, ALUFun, Zero, V, N, R);
input Sign, ALUFun;
input [31:0] A, B;
output Zero, V, N;
output reg[31:0] R;
wire Sign, Zero, V, N;
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
assign N =  (~ALUFun && Sign
				&& 
				(
					((A[31] == B[31]) && A[31]) 
					|| 
					((A[31] == ~B[31]) && R[31])
				)
			) 
			|| 
			(ALUFun
				&&
				(
					(Sign 
						&&
						(
							((A[31] == B[31]) && R[31])
							||
							((A[31] == ~B[31]) && A[31])	
						) 
					) 
					|| 
					(~Sign
						&&
						(
							(~A[31] && B[31]) 
							||
							((A[31] && B[31]) && R[31])
							||
							((~A[31] && ~B[31]) && R[31])
						)
					)
				)
			);

endmodule

module CMP(Zero, V, N, ALUFun, S);
input Zero, V, N;
input [2:0] ALUFun;
output reg S;

wire Zero, V, N;
wire [2:0] ALUFun;

parameter aluEQ = 3'b001;
parameter aluNEQ = 3'b000;
parameter aluLT = 3'b010;
parameter aluLEZ = 3'b110;
parameter aluLTZ = 3'b101;
parameter aluGTZ = 3'b111;

always @(*)
	case(ALUFun)
		aluEQ: 	S <= Zero;
		aluNEQ: S <= ~Zero;
		aluLT: 	S <= N;
		aluLEZ: S <= (N || Zero);
		aluLTZ: S <= N;
		aluGTZ: S <= ~(N || Zero);
	endcase
endmodule

module Logic(A, B, ALUFun, R);
input [31:0] A, B;
input [3:0] ALUFun;
output reg [31:0] R;

parameter AND = 4'b1000;
parameter OR  = 4'b1110;
parameter XOR = 4'b0110;
parameter NOR = 4'b0001;
parameter A_   = 4'b1010;

always @(*)
	case(ALUFun)
		AND: R <= A & B;
		OR:  R <= A | B;
		XOR: R <= A ^ B;
		NOR: R <= ~(A|B);
		A_:  R <= A;
	endcase
endmodule

module Shift(A, B, ALUFun, R);
input [31:0] B;
input [4:0] A;
input [1:0] ALUFun;
output [31:0] R;

wire [31:0] B, R, R_16, R_8, R_4, R_2;
wire [4:0] A;
wire [1:0] ALUFun;
parameter SLL = 2'b00;
parameter SRL = 2'b01;
parameter SRA = 2'b11;
/*
always@(*)
	case(ALUFun)
		SLL: R<= B << A[4:0];
		SRL: R<= B >> A[4:0];
		SRA: R<= B >>> A[4:0];
	endcase
	*/
Shift16 a(A[4], B, ALUFun, R_16);
Shift8 b(A[3], R_16, ALUFun, R_8);
Shift4 c(A[2], R_8, ALUFun, R_4);
Shift2 d(A[1], R_4, ALUFun, R_2);
Shift1 e(A[0], R_2, ALUFun, R);
endmodule

module Shift16(A_4, B, ALUFun, R);
input [31:0] B;
input [1:0] ALUFun;
input A_4;
output [31:0] R;
wire [31:0] B, R;
wire[1:0] ALUFun;
wire A_4;
parameter SLL = 2'b00;
parameter SRL = 2'b01;
parameter SRA = 2'b11;

assign R = (A_4 && (ALUFun == SLL))?{B[15:0], 16'b0000000000000000}:
			(A_4 && (ALUFun == SRL))?{16'b0000000000000000, B[31:16]}:
			(A_4 && (ALUFun == SRA))?{{16{B[31]}}, B[31:16]}:
			B;
endmodule

module Shift8(A_3, B, ALUFun, R);
input [31:0] B;
input [1:0] ALUFun;
input A_3;
output [31:0] R;
wire [31:0] B, R;
wire[1:0] ALUFun;
wire A_3;
parameter SLL = 2'b00;
parameter SRL = 2'b01;
parameter SRA = 2'b11;

assign R = (A_3 && (ALUFun == SLL))?{B[23:0], 8'b00000000}:
			(A_3 && (ALUFun == SRL))?{8'b00000000, B[31:8]}:
			(A_3 && (ALUFun == SRA))?{{8{B[31]}}, B[31:8]}:
			B;
endmodule

module Shift4(A_2, B, ALUFun, R);
input [31:0] B;
input [1:0] ALUFun;
input A_2;
output [31:0] R;
wire [31:0] B, R;
wire[1:0] ALUFun;
wire A_2;
parameter SLL = 2'b00;
parameter SRL = 2'b01;
parameter SRA = 2'b11;

assign R = (A_2 && (ALUFun == SLL))?{B[27:0], 4'b0000}:
			(A_2 && (ALUFun == SRL))?{4'b0000, B[31:4]}:
			(A_2 && (ALUFun == SRA))?{{4{B[31]}}, B[31:4]}:
			B;
endmodule

module Shift2(A_1, B, ALUFun, R);
input [31:0] B;
input [1:0] ALUFun;
input A_1;
output [31:0] R;
wire [31:0] B, R;
wire[1:0] ALUFun;
wire A_1;
parameter SLL = 2'b00;
parameter SRL = 2'b01;
parameter SRA = 2'b11;

assign R = (A_1 && (ALUFun == SLL))?{B[29:0], 2'b00}:
			(A_1 && (ALUFun == SRL))?{2'b00, B[31:2]}:
			(A_1 && (ALUFun == SRA))?{{2{B[31]}}, B[31:2]}:
			B;
endmodule

module Shift1(A_0, B, ALUFun, R);
input [31:0] B;
input [1:0] ALUFun;
input A_0;
output [31:0] R;
wire [31:0] B, R;
wire[1:0] ALUFun;
wire A_0;
parameter SLL = 2'b00;
parameter SRL = 2'b01;
parameter SRA = 2'b11;

assign R = (A_0 && (ALUFun == SLL))?{B[30:0], 1'b0}:
			(A_0 && (ALUFun == SRL))?{1'b0, B[31:1]}:
			(A_0 && (ALUFun == SRA))?{{1{B[31]}}, B[31:1]}:
			B;
endmodule