`timescale 1ns/1ns

module cpu_tb;
reg sysclk;
reg reset;
reg [7:0]switch;
reg uart_rx;
wire [7:0]led;
wire [6:0]digi_out0;
wire [6:0]digi_out1;
wire [6:0]digi_out2;
wire [6:0]digi_out3;
wire uart_tx;

initial begin
  sysclk <= 0;
  reset <= 0;
  switch <= 8'b1;
  uart_rx <= 1;
  #20 reset <= 1;
  #104167 uart_rx<=0;
	#104167 uart_rx<=1;
	#104167 uart_rx<=0;
	#104167 uart_rx<=1;
	#104167 uart_rx<=0;
	#104167 uart_rx<=1;
	#104167 uart_rx<=0;
	#104167 uart_rx<=1;
	#104167 uart_rx<=0;
	#104167 uart_rx<=1;
	#104167 uart_rx<=1;
	#104167 uart_rx<=1;
	#104167 uart_rx<=1;
	#104167 uart_rx<=1;

  #104167 uart_rx<=0;
	#104167 uart_rx<=0;
	#104167 uart_rx<=1;
	#104167 uart_rx<=0;
	#104167 uart_rx<=1;
	#104167 uart_rx<=0;
	#104167 uart_rx<=1;
	#104167 uart_rx<=0;
	#104167 uart_rx<=0;
	#104167 uart_rx<=1;
	#104167 uart_rx<=1;
	#104167 uart_rx<=1;
	#104167 uart_rx<=1;
	#104167 uart_rx<=1;
end

always #10 sysclk <= ~sysclk;

CPU mycpu(sysclk, reset, switch, led, digi_out0, digi_out1, digi_out2, digi_out3, uart_rx, uart_tx);
endmodule
