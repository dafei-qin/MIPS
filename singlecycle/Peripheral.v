`timescale 1ns/1ps

module Peripheral (reset,clk,rd,wr,addr,wdata,rdata,led,switch,digi,irqout,uartout,uartin);
input reset,clk;
input rd,wr;
input uartin;
input [31:0] addr;
input [31:0] wdata;
output [31:0] rdata;
reg [31:0] rdata;
output uartout;
output [7:0] led;
reg [7:0] led;
input [7:0] switch;
output [11:0] digi;
reg [11:0] digi;
output irqout;
reg uartout;

reg [31:0] TH,TL;
reg [2:0] TCON;
assign irqout = TCON[2];
assign uartout = UART_OUT;
assign UART_IN = uartin
reg [7:0] UART_TXD;
wire [7:0] UART_RXD;
reg [4:0] UART_CON;
wire [4:0] UART_CONOUT;
wire UART_OUT;
reg UART_IN;

always@(*) begin
	if(rd) begin
		case(addr)
			32'h40000000: rdata <= TH;
			32'h40000004: rdata <= TL;
			32'h40000008: rdata <= {29'b0,TCON};
			32'h4000000C: rdata <= {24'b0,led};
			32'h40000010: rdata <= {24'b0,switch};
			32'h40000014: rdata <= {20'b0,digi};
			32'h4000001C: rdata <= {23'b0,UART_RXD};
			32'h40000020: rdata <= {26'b0,UART_CON};
			default: rdata <= 32'b0;
		endcase
	end
	else
		rdata <= 32'b0;
end

module

always@(negedge reset or posedge clk) begin
	if(~reset) begin
		TH <= 32'b0;
		TL <= 32'b0;
		TCON <= 3'b0;
	end
	else begin
		if(TCON[0]) begin	//timer is enabled
			if(TL==32'hffffffff) begin
				TL <= TH;
				if(TCON[1]) TCON[2] <= 1'b1;		//irq is enabled
			end
			else TL <= TL + 1;
		end

	if(~reset) begin
		UART_TXD <= 32'b0;
		UART_CON <= 32'b0;
	end
	else begin
		if(UART_CONOUT[0] and ~UART_CONOUT[4])
			begin
				UART_CON <= 0;
			end
		else if(UART_CONOUT[1] and UART_CONOUT[3])
			begin
				UART_CON[1] <= 0;
				UART_CON[3] <= 0;
			end
	end


		if(wr) begin
			case(addr)
				32'h40000000: TH <= wdata;
				32'h40000004: TL <= wdata;
				32'h40000008: TCON <= wdata[2:0];
				32'h4000000C: led <= wdata[7:0];
				32'h40000014: digi <= wdata[11:0];
				32'h40000018: UART_TXD <= wdata[7:0];
				32'h40000020: UART_CON <= wdata[4:0];
				default: ;
			endcase
		end
	end
end

Uart myuart(reset,clk,UART_TXD,UART_RXD,UART_CON,UART_CONOUT,UART_OUT,UART_IN);

endmodule
