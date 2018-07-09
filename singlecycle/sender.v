module sender(
input [7:0] TX_DATA,
input TX_EN,
input sysclk,
input reset,
output reg TX_STATUS,
output reg UART_TX,
output reg sendstatus
);

reg [7:0]tempdata;
reg [3:0]digit;
reg [13:0]count;
initial begin
	sendstatus<=0;
	TX_STATUS<=0;
	UART_TX<=1;
	tempdata<=8'b00000000;
	digit<=0;
	count<=0;
end

always@(posedge sysclk or negedge reset)
begin
	if(~reset)begin
		tempdata<=0;
		digit<=0;
		count<=0;
		sendstatus<=0;
		UART_TX<=1;
		TX_STATUS<=0;
	end
	else begin
		if((~sendstatus)&&TX_EN)begin
			sendstatus<=1;
			tempdata<=TX_DATA;
		end
		else if(sendstatus)begin
			TX_STATUS<=~sendstatus;
			if(count==5208)begin
				count<=0;
				case(digit)
				4'd0:begin
					UART_TX<=1'b0;
					TX_STATUS<=0;
				end
				4'd1:UART_TX<=tempdata[0];
				4'd2:UART_TX<=tempdata[1];
				4'd3:UART_TX<=tempdata[2];
				4'd4:UART_TX<=tempdata[3];
				4'd5:UART_TX<=tempdata[4];
				4'd6:UART_TX<=tempdata[5];
				4'd7:UART_TX<=tempdata[6];
				4'd8:UART_TX<=tempdata[7];
				4'd9:begin UART_TX<=1'b1;TX_STATUS<=1;end
				4'd10:begin
					sendstatus<=0;digit<=0;TX_STATUS<=0;
				end
        endcase
				digit<=digit+1;
			end
			else count<=count+1;
		end
	end
end
endmodule
