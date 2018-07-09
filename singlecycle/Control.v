/*
Project: Control Unit
Time   : 18/07
*/

module Control(OpCode, Funct, IRQ, PCSrc, RegDst, RegWr, ALUSrc1, ALUSrc2, ALUFun, Sign, MemWr, MemRd, MemToReg, EXTOp, LUOp);
	input wire [5:0] OpCode;
	input wire [5:0] Funct;
	input wire IRQ;
	output wire [2:0] PCSrc;
	output wire [1:0] RegDst;
	output wire RegWr, ALUSrc1, ALUSrc2;
	output wire [5:0] ALUFun;
	output wire Sign, MemWr, MemRd;
	output wire [1:0] MemToReg;
	output wire EXTOp, LUOp;

	//PCSrc_ONE:PCSrc = 1; RegDst_ZERO:RegDst = 0; MemToReg_ZERO:MemToReg = 0;
	wire PCSrc_ONE, RegDst_ZERO, MemToReg_ZERO;
	assign PCSrc_ONE = (OpCode == 6'h01) || (OpCode >= 6'h04 && OpCode <= 6'h07);
	assign RegDst_ZERO = (OpCode == 6'h00) && ((Funct == 6'h0) || (Funct == 6'h2) || (Funct == 6'h3) || (Funct == 6'h2a) || (Funct >= 6'h20 && Funct <= 6'h27));
	assign MemToReg_ZERO = (OpCode == 6'h0f) || (OpCode == 6'h2b) || (OpCode >= 6'h8 && OpCode <= 6'hc);
	assign ALUSrc2 = MemToReg_ZERO || (OpCode == 6'h23);

	//Signals Generation including interrupt processing

	//1. PCSrc Signal Generation
	assign PCSrc = IRQ ? 3'd4 :
	PCSrc_ONE ? 3'd1 :
	(OpCode == 6'h02 || OpCode == 6'h03) ? 3'd2 :
	(OpCode == 6'h00 && (Funct == 6'h08 || Funct == 6'h09)) ? 3'd3 :
	(ALUSrc2 | RegDst_ZERO) ? 3'd0 :
	3'd5;

	//2. RegWr Signal Generation
	assign RegWr= IRQ || (~(PCSrc_ONE||OpCode == 6'h2b||OpCode == 6'h02||(OpCode == 6'h00 && Funct==6'h08)));

	//3. RegDst Signal Generation
	assign RegDst = IRQ ? 2'd3 :
	(OpCode == 6'h03) ? 2'd2 :
	(ALUSrc2 || (OpCode == 6'h0 && Funct == 6'h9)) ? 2'd1 :
	RegDst_ZERO ? 2'd0 :
	2'd3;

	//4. MemRd & MemWr Signal Generation
	assign MemRd = (~IRQ) && (OpCode == 6'h23) ;
	assign MemWr = (~IRQ) && (OpCode == 6'h2b) ;

	//5. MemToReg Signal Generation
	assign MemToReg = IRQ ? 2'd3 :
	(OpCode == 6'h23) ? 2'd1 :
	(RegDst_ZERO | MemToReg_ZERO) ? 2'd0 :
	(OpCode == 6'h3 || (OpCode == 6'h0 && Funct == 6'h09)) ? 2'd2 :
	2'd3;

	//6. ALUSrc1 Signal Generation
	assign ALUSrc1= (OpCode == 6'h00) && (Funct==6'h00||Funct==6'h02||Funct==6'h03) ;

	//7. EXTop && LUOp Signal Generation
	assign EXTOp= ~(OpCode == 6'h0c) ;
	assign LUOp= (OpCode == 6'h0f) ;

	//8. Sign Signal Generation
	assign Sign = ~(OpCode == 6'h0 && (Funct == 6'h21||Funct == 6'h23||Funct == 6'h09||Funct == 6'h0b)) ;

	//9. ALUFun Signal Generation
	assign ALUFun =
		((OpCode == 6'h0) && (Funct == 6'h22||Funct == 6'h23))? 6'b000001:
		(OpCode == 6'h0c || (OpCode == 6'h0 && Funct == 6'h24))? 6'b011000:
		(OpCode == 6'h0 && Funct == 6'h25)? 6'b011110:
		(OpCode == 6'h0 && Funct == 6'h26)? 6'b010110:
		(OpCode == 6'h0 && Funct == 6'h27)? 6'b010001:
		(OpCode == 6'h0 && Funct == 6'h25)? 6'b011110:
		(OpCode == 6'h0 && Funct == 6'h00)? 6'b100000:
		(OpCode == 6'h0 && Funct == 6'h02)? 6'b100001:
		(OpCode == 6'h0 && Funct == 6'h03)? 6'b100011:
		((OpCode == 6'h0 && Funct == 6'h2a)||OpCode == 6'h0a||OpCode == 6'hb)? 6'b110101:
		(OpCode == 6'h4)? 6'b110011:
		(OpCode == 6'h5)? 6'b110001:
		(OpCode == 6'h6)? 6'b111101:
		(OpCode == 6'h7)? 6'b111111:
		(OpCode == 6'h1)? 6'b111011:
		6'b0;

endmodule
