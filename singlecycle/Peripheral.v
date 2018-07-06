`timescale 1ns/1ps

module Peripheral (reset,clk,rd,wr,addr,wdata,rdata,led,switch,digi,irqout,rec,rx_data1,rx_data2,tx_data,tx_en);
input reset,clk;
input rd,wr;
input [31:0] addr;
input [31:0] wdata;
output [31:0] rdata;
reg [31:0] rdata;
input [1:0] rec;
input [7:0] rx_data1;
input [7:0] rx_data2;
output reg [7:0] tx_data;
output [7:0] led;
reg [7:0] led;
input [7:0] switch;
output [11:0] digi;
reg [11:0] digi;
output irqout;
output reg tx_en;
reg [31:0] TH,TL;
reg [2:0] TCON;
assign irqout = TCON[2];

always@(*) begin
	if(rd) begin
		case(addr)
			32'h40000000: rdata <= TH;			
			32'h40000004: rdata <= TL;			
			32'h40000008: rdata <= {29'b0,TCON};				
			32'h4000000C: rdata <= {24'b0,led};			
			32'h40000010: rdata <= {24'b0,switch};
			32'h40000014: rdata <= {20'b0,digi};
			32'h40000018: rdata <= {30'b0,rec};
			32'h4000001C: rdata <= {24'b0,rx_data1};
			32'h40000020: rdata <= {24'b0,rx_data2};
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
		tx_en<=1'b0;
		tx_data<=8'd0;
	end
	else begin
		if(TCON[0]) begin	//timer is enabled
			if(TL==32'hffffffff) begin
				TL <= TH;
				if(TCON[1]) TCON[2] <= 1'b1;		//irq is enabled
			end
			else TL <= TL + 1;
		end
		
		if(wr) begin
			case(addr)
				32'h40000000: TH <= wdata;
				32'h40000004: TL <= wdata;
				32'h40000008: TCON <= wdata[2:0];		
				32'h4000000C: led <= wdata[7:0];			
				32'h40000014: digi <= wdata[11:0];
				32'h40000024: begin tx_data <= wdata[7:0]; tx_en <= 1'b1; end
				default: ;
			endcase				
		end
		else if( tx_en )
			tx_en<=1'b0;
	end
end
endmodule

