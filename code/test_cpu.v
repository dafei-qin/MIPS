
module test_cpu();
	
	reg reset;
	reg clk;
	
	CPU cpu1(reset, clk);
	
	initial begin
	$dumpfile("test.vcd");
	$dumpvars(0, test_cpu);
		reset = 1;
		clk = 1;
		#100 reset = 0;
	#5000 $finish;
	end
	
	always #50 clk = ~clk;
		
endmodule
