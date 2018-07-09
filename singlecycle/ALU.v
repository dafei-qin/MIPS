/*
Project: ALU
Time   : 18/07
*/

`timescale 1ns/1ns

module ALU(A, B, ALUFun, Sign, Z);
	input  [31:0] A, B;
	input  [5:0] ALUFun;
	input  Sign;
	output reg [31:0] Z;

	//Part1: ADD/SUB Module

	wire [31:0] A_mod, B_mod;
	//transition for unsigned <-> signed
	assign A_mod[31] = ~(A[31] ^ Sign);
	assign B_mod[31] = ~(B[31] ^ Sign);
	assign A_mod[30:0] = A[30:0];
	assign B_mod[30:0] = B[30:0];

	//If minus, B_mod will be turned into 2-complement format <-> C = -B_mod
	wire [31:0] C;
	assign C = ALUFun[0] ? (~B_mod + 32'b1) : B_mod;

	//add
	wire [31:0] Sum;
	wire Zero, Overflow, Negative;
	assign Sum = A_mod + C;
	assign Zero = (Sum == 32'b0);
	assign Overflow = (A_mod[31] & C[31] & (~Sum[31])) | ((~A_mod[31]) & (~C[31]) & Sum[31]);
	assign Negative = Sum[31];

	//Part2: Compare

	reg Compare;
	always @(*) begin
		case(ALUFun[3:1])
			3'b001: Compare = Zero & (~Overflow);
			3'b000: Compare = ~(Zero & (~Overflow));
			3'b010: Compare = Negative ^ Overflow;
			3'b110: Compare = (A[31] == 32'b0) | (Sign & A[31]);
			3'b101: Compare = Sign & (A[31]);
			3'b111: Compare = ~((A[31] == 32'b0) | (Sign & A[31]));
			default: Compare = 1'b0;
		endcase
	end

	//Part3: Boolean

	reg [31:0] Boolean;
	always @(*) begin
		case(ALUFun[3:1])
			3'b100: Boolean = A & B;
			3'b111: Boolean = A | B;
			3'b011: Boolean = A ^ B;
			3'b000: Boolean = ~(A | B);
			3'b101: Boolean = A;
			default: Boolean = A;
		endcase
	end

	//Part4: Shift

	reg [31:0] Shift;
	always @(*) begin
		case(ALUFun[1:0])
			2'b00: Shift = B << A[4:0];
			2'b01: Shift = B >> A[4:0];
			2'b11: Shift = ({{32{B[31]}},B} >> A[4:0]);
			default: Shift = B;
		endcase
	end

	//Part5: Output
	always @(*) begin
		case(ALUFun[5:4])
			2'b00: Z = Sum;
			2'b11: begin Z[0] = Compare; Z[31:1] = 31'b0; end
			2'b01: Z = Boolean;
			2'b10: Z = Shift;
		endcase
	end

endmodule