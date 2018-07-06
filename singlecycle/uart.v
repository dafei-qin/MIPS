`timescale 1ns/1ps
module Uart (reset,sysclk,UART_TXD,UART_RXD,UART_CON,UART_CONOUT,UART_OUT,UART_IN)
input reset,mclk,sysclk;
output [7:0] UART_RXD;
output [4:0] UART_CONOUT;
output UART_OUT;
input [7:0] UART_TXD;
input [4:0] UART_CON;
input UART_IN;
reg [7:0] UART_RXD;
reg [4:0] UART_CONOUT;
reg UART_OUT;
reg [3:0]state;
reg [3:0]count;
reg [7:0]temp;
reg [4:0]tempcon;
reg [7:0]tempdata;
reg [3:0]digit;
reg [13:0]sendcount;
reg sendstatus;
reg [9:0]timecount;
reg myclk;
initial begin
	UART_RXD <= 8'b0;
	state <= 4'd0;
	count <= 4'd0;
	temp <= 8'd0;
  tempdata <= 8'b0;
	digit <= 4'b0;
  sendcount <= 14'b0;
  UART_OUT <= 0;
  myclk <= 0;
  timecount <= 0;
end

always @(posedge sysclk or negedge reset)begin
	if(~reset)begin
		timecount<=0;
		myclk<=0;
	end
	else begin
		if(timecount==10'd325)begin
			timecount<=0;
			myclk<=~myclk;
			end
		else timecount<=timecount+1;
	end
end

always @(posedge myclk or negedge reset)begin
  tempcon[1] <= UART_CON[1];
  if(~reset)begin
    UART_RXD <= 8'b0;
    tmepcon[3] <= 0;
    state <= 4'd0;
  	count <= 4'd0;
  	temp <= 8'd0;
  end
  else if (UART_CON[1]) begin
		if(state==0)begin
			if(uart==0)begin
				state<=1;
				count<=0;
			end
		end
		else if(state==1)begin
			if(count!=3)
			count<=count+1;
			else begin
				count<=0;
				state<=2;
			end
		end
		else if((state<=9)&&(state>=2))begin
			if(count!=7)begin
				count<=count+1;
			end
			else begin
				state<=state+1;
				count<=0;
				temp<=(temp>>1);
				temp[7]<=UART_IN;
			end
		end
		else if(state==10)begin
			if(count!=6)begin
				count<=count+1;
			end
			else begin
				state<=state+1;
				count<=0;
				UART_RXD<=temp;
				tempcon[3]<=1;
			end
		end
		else if(state==11)begin
			state<=0;
			count<=0;
			tempcon[3]<=0;
		end
		else begin
			state<=0;
			count<=0;
		end
	end
  UART_CONOUT[3] = tempcon[3];
end

always @(posedge sysclk or negedge reset)begin
  if(UART_CON[0])begin
    if(~reset)begin
      tempdata <= 8'b0;
      digit <= 4'b0;
      sendcount <= 14'b0;
      UART_OUT <= 1;
      end
    else begin
      if(~tempcon[4])begin
        tempcon[4] <= 1;
        tempcon[2] <= 0;
        tempdata <= UART_TXD;
      end
      else if(sendcount==5208) begin
        sendcount<=0;
        digit<=digit+1;
        case(digit)
        4'd0:begin
					UART_TX<=1'b0;
					TX_STATUS<=0;
				end
				4'd1:UART_OUT<=tempdata[0];
				4'd2:UART_OUT<=tempdata[1];
				4'd3:UART_OUT<=tempdata[2];
				4'd4:UART_OUT<=tempdata[3];
				4'd5:UART_OUT<=tempdata[4];
				4'd6:UART_OUT<=tempdata[5];
				4'd7:UART_OUT<=tempdata[6];
				4'd8:UART_OUT<=tempdata[7];
				4'd9:UART_OUT<=1'b1;
				4'd10:begin
					tempcon[2]<=1;digit<=0;
          tempcon[4]<=0;
				end endcase
      end
      else sendcount <= sendcount+1;
    end
  end
  UART_CONOUT[2] = tempcon[2];
  UART_CONOUT[4] = tempcon[4];
end
endmodule
