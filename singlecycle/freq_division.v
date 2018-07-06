/*
Project: freq_division
Time   : 18/07
*/

module freq_division(sysclk, reset, clk);
	input sysclk, reset;
	output reg clk;

	reg [26:0] counter;

	//Half frquence division
	always @(posedge clk or negedge reset) begin
		if (~reset) begin
			counter <= 0;
			clk <= 0;	
		end
		else begin
			if(counter == 1) begin
				counter <= 0;
				clk <= ~clk;
			end
			else begin
				counter <= counter + 1;
			end
		end
	end

endmodule