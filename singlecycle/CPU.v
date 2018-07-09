/*
Project: CPU Integration Module
Time   : 18/07
*/

module CPU(sysclk, reset, switch, led, digi_out0, digi_out1, digi_out2, digi_out3, uart_rx, uart_tx);
	input wire sysclk, reset;
	input wire [7:0] switch;
	input wire uart_rx;
	output wire [7:0] led;
	output wire uart_tx;
	output [6:0] digi_out0; //0: CG - CA
	output [6:0] digi_out1; //1: CG - CA
	output [6:0] digi_out2; //2: CG - CA
	output [6:0] digi_out3; //3: CG - CA

	//reg
	reg [4:0] AddrC;
	reg [31:0] PC;
	reg [31:0] PC_NEXT;

	//wire
	wire Regwr, ALUSrc1, ALUSrc2, MemWr, MenRd, EXTOp, LUOp, IRQ, IRQ_Control, Sign, clk;
	wire [1:0] RegDst, MemToReg;
	wire [2:0] PCSrc;
	wire [4:0] Shamt, Rd, Rt, Rs;
	wire [5:0] ALUFun;
	//wire [7:0] tx_data, rx_data1, rx_data2;
	wire [11:0] digi;
	wire [15:0] Imm16;
	wire [31:0] PC_Plus_4, ConBA, Instruction, JT, Data_Bus_A, Data_Bus_B, Data_Bus_C, Branch_Target, ALUIn1, ALUIn2, ALUOut, LUOut, EXTOut, ReadData0, ReadData1, ReadData;

	//parameters
	parameter ILLOP = 32'h80000004;
	parameter XADR = 32'h80000008;
	parameter Xp = 5'd26;
	parameter Ra = 5'd31;

	//frequence division
	freq_division freq_division1(.sysclk(sysclk), .reset(reset), .clk(clk));

	//PC Caculate
	always @(posedge clk or negedge reset) begin
		if(~reset)
			PC <= 32'h80000000; //If reset:  Kernel State
		else
			PC <= PC_NEXT;
	end

	//PC_Plus_4
	//ps: Remain the check fit PC[31] unchanged
	assign PC_Plus_4[31] = PC[31];
	assign PC_Plus_4[30:0] = PC[30:0] + 31'd4;

	//Branch_Target
	assign Branch_Target = ALUOut[0] ? ConBA : PC_Plus_4;

	//ConBA: Conditional Branch Addr
	assign ConBA[31] = PC_Plus_4[31];
	assign ConBA[30:0] = PC_Plus_4[30:0] + {EXTOut[28:0], 2'b00};

	//PC_NEXT
	always @(*) begin
		case(PCSrc)
			3'd0: PC_NEXT = PC_Plus_4;
			3'd1: PC_NEXT = Branch_Target;
			3'd2: PC_NEXT = JT;
			3'd3: PC_NEXT = Data_Bus_A;
			3'd4: PC_NEXT = ILLOP;
			default: PC_NEXT = XADR;
		endcase
	end

	//Instruction
	ROM rom1(.addr(PC), .data(Instruction));

	//JT
	assign JT = {PC_Plus_4[31:28], Instruction[25:0], 2'b00};

	//Imm16
	assign Imm16 = Instruction[15:0];

	//Shamt
	assign Shamt = Instruction[10:6];

	//Rd
	assign Rd = Instruction[15:11];

	//Rt
	assign Rt = Instruction[20:16];

	//Rs
	assign Rs = Instruction[25:21];

	//Control signals generation
	Control Control1(.OpCode(Instruction[31:26]), .Funct(Instruction[5:0]), .IRQ(IRQ_Control), .PCSrc(PCSrc), .RegDst(RegDst), .RegWr(Regwr), .ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2),
		.ALUFun(ALUFun), .MemWr(MemWr), .MemRd(MenRd), .MemToReg(MemToReg), .EXTOp(EXTOp), .LUOp(LUOp), .Sign(Sign));

	//AddrC
	always @(*) begin
		case(RegDst)
			2'd0: AddrC = Rd;
			2'd1: AddrC = Rt;
			2'd2: AddrC = Ra;
			2'd3: AddrC = Xp;
		endcase
	end

	//Data_Bus_A, Data_Bus_B
	RegFile RegFile1(.reset(reset), .clk(clk), .addr1(Rs), .data1(Data_Bus_A), .addr2(Rt), .data2(Data_Bus_B), .wr(Regwr), .addr3(AddrC), .data3(Data_Bus_C));

	//ALUIn1
	assign ALUIn1 = ALUSrc1 ? {27'd0, Shamt} : Data_Bus_A;

	//ALUIn2
	assign ALUIn2 = ALUSrc2 ? LUOut : Data_Bus_B;

	//ALUOut
	ALU ALU1(.A(ALUIn1), .B(ALUIn2), .ALUFun(ALUFun), .Sign(Sign), .Z(ALUOut));

	//LUOut
	assign LUOut = LUOp ? {Imm16, 16'd0} : EXTOut;

	//EXTOut
	assign EXTOut = {EXTOp ? {16{Imm16[15]}} : 16'd0, Imm16};

	//ReadData0: Read data memory
	DataMem DataMem1(.reset(reset), .clk(clk), .rd(MenRd), .wr(MemWr), .addr(ALUOut), .wdata(Data_Bus_B), .rdata(ReadData0));

	//ReadData1 & led & digi & IRQ: Read peripheral memory
	Peripheral Peripheral1(.reset(reset), .clk(sysclk), .rd(MenRd), .wr(MemWr), .addr(ALUOut), .wdata(Data_Bus_B) , .rdata(ReadData1), .led(led), .switch(switch), .digi(digi), .irqout(IRQ), .uartin(uart_rx), .uartout(uart_tx));

	//IRQ_Control: When check fit(PC[31]) = 1, interruption is disabled
	assign IRQ_Control = IRQ & (~PC[31]);

	//digitube_scan
	digitube_scan digitube_scan1(.digi_in(digi), .digi_out1(digi_out0), .digi_out2(digi_out1), .digi_out3(digi_out2), .digi_out4(digi_out3));

	/*
	//UART
	UARTRec R1(.uart_rx(uart_rx), .sysclk(sysclk), .reset(reset), .rx_data1(rx_data1), .rx_data2(rx_data2), .rec(rec));
	UARTSnd S1(.sysclk(sysclk), .reset(reset), .tx_data(tx_data), .tx_en(tx_en), .uart_tx(uart_tx));
	*/

	//ReadData
	assign ReadData = ALUOut[30] ? ReadData1 : ReadData0;

	//Data_Bus_C
	assign Data_Bus_C = (MemToReg == 2'b00) ? ALUOut : (MemToReg == 2'b01) ? ReadData : (MemToReg == 2'b10) ? PC_Plus_4 : PC;

endmodule
