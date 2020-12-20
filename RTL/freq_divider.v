module frequency_divider_by2 (out_clk,clk);
	output reg out_clk;
	input clk ;
	always @(posedge clk)
		begin
			out_clk <= ~out_clk;	
		end
endmodule
 