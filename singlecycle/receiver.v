module uartclk(
input	sysclk,
input reset,
output reg clk
);
reg [9:0]timecount;
initial begin
clk<=0;
timecount<=0;
end

always @(posedge sysclk or negedge reset)begin
	if(~reset)begin
		timecount<=0;
		clk<=0;
	end
	else begin
		if(timecount==10'd325)begin
			timecount<=0;
			clk<=~clk;
			end
		else timecount<=timecount+1;
	end
end
endmodule

module receiver(
  input rxenable,
	input clk,
	input reset,
	input uart,
	output reg [7:0]rxdata,
	output reg rxstatus
);
reg [3:0]state;
reg [3:0]count;
reg [7:0]temp;
initial begin
	rxdata<=8'b00000000;
	rxstatus<=0;
	state<=4'd0;
	count<=4'd0;
	temp<=8'd0;
end
always @(posedge clk or negedge reset )begin

	if(~reset)begin
		rxdata<=8'b00000000;
		rxstatus<=0;
		state<=4'd0;
		count<=4'd0;
		temp<=8'd0;
	end
	else begin
		if((state==4'd0) && (rxenable))begin
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
				temp[7]<=uart;
			end
		end
		else if(state==10)begin
			if(count!=6)begin
				count<=count+1;
			end
			else begin
				state<=state+1;
				count<=0;
				rxdata<=temp;
				rxstatus<=1;
			end
		end
		else if(state==11)begin
			state<=0;
			count<=0;
			rxstatus<=0;
		end
		else begin
			state<=0;
			count<=0;
		end
	end
end

endmodule
