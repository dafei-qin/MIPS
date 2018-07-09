`timescale 1ns/1ps

module Peripheral (reset,clk,rd,wr,addr,wdata,rdata,led,switch,digi,irqout,uartin,uartout);
input reset,clk;
input rd,wr;
input [31:0] addr;
input [31:0] wdata;
output [31:0] rdata;
reg [31:0] rdata;

output [7:0] led;
reg [7:0] led;
input [7:0] switch;
output [11:0] digi;
reg [11:0] digi;
output irqout;

wire myclk;
input uartin;
output uartout;
reg [4:0] uartcon;
wire [7:0] uart_rx;
reg [7:0] uart_tx;
reg [7:0] uart_data;
wire rx_status;
wire tx_status;
reg txen;
reg rxreset;
reg txreset;
wire istxfree;

reg [31:0] TH,TL;
reg [2:0] TCON;
assign irqout = TCON[2];

initial begin
	TH = 32'b0;
	TL = 32'b0;
	TCON = 3'b0;
	led = 8'b0;
	digi = 12'b0;
	uartcon = 5'b0;
	uart_tx = 32'b0;
	txen = 0;
	rxreset = 1;
	txreset = 1;
end

always@(*) begin
	if(rd) begin
		case(addr)
			32'h40000000: rdata <= TH;
			32'h40000004: rdata <= TL;
			32'h40000008: rdata <= {29'b0,TCON};
			32'h4000000C: rdata <= {24'b0,led};
			32'h40000010: rdata <= {24'b0,switch};
			32'h40000014: rdata <= {20'b0,digi};
			32'h40000018: rdata <= {24'b0,uart_tx};
			32'h4000001C: rdata <= {24'b0,uart_data};
			32'h40000020: rdata <= {27'b0,uartcon};
			default: rdata <= 32'b0;
		endcase
	end
	else
		rdata <= 32'b0;
end

always@(negedge reset or posedge clk) begin
	if(~reset) begin
		TH <= 32'b0;
		TL <= 32'b0;
		TCON <= 3'b0;
		led <= 8'b0;
		digi <= 12'b0;
		uartcon <= 5'b0;
		uart_tx <= 8'b0;
	end
	else begin
		if(TCON[0]) begin	//timer is enabled
			if(TL==32'hffffffff) begin
				TL <= TH;
				if(TCON[1]) TCON[2] <= 1'b1;		//irq is enabled
				else TCON[2] <= 1'b0;
			end
			else begin
			TL <= TL + 1;
			TCON[2] <= 1'b0;
			end
		end

		if(rx_status)uartcon[3] <= rx_status;			//接受完成标志

		if(uartcon[1] && uartcon[3])begin
			if(rxreset)begin
			uart_data <= uart_rx;
			rxreset <= 0;
			end
		end
		else rxreset <= 1;

		uartcon[4] <= istxfree;			//发送模块空闲状态

		if(tx_status)uartcon[2] <= 1;

		if(~uartcon[0]) txen<= 0;

		if(uartcon[0] && ~uartcon[2])txen <= 1;

		if(uartcon[0] && uartcon[2])begin
			if(txreset)txreset <= 0;
		end
		else txreset <= 1;

		if(wr) begin
			case(addr)
				32'h40000000: TH <= wdata;
				32'h40000004: TL <= wdata;
				32'h40000008: TCON <= wdata[2:0];
				32'h4000000C: led <= wdata[7:0];
				32'h40000014: digi <= wdata[11:0];
				32'h40000018: uart_tx <= wdata[7:0];
				32'h40000020: uartcon <= wdata[4:0];
				default: ;
			endcase
		end
	end
end

uartclk myuartclk(clk,reset,myclk);
receiver myreceiver(uartcon[1],myclk,rxreset,uartin,uart_rx,rx_status);
sender mysender(uart_tx,txen,clk,reset,tx_status,uartout,istxfree);
endmodule
