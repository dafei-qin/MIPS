module freq_division(sysclk, reset, clk);
  input sysclk, reset;
  output reg clk;
  reg [26:0] counter;

initial begin
  counter <= 0;
  clk <= 0;
end

  always @(posedge sysclk or negedge reset)
  begin
    if (~reset)
      begin
        counter <= 0;
        clk <= 0;
      end
    else
      begin
        if (counter == 2 - 1)
        begin
          counter <= 0;
          clk <= ~clk;
        end
        else counter <= counter + 1;
      end
  end
endmodule
