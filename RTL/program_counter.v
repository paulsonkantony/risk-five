module program_counter(D,clk,rst,Q);
	input [31:0] D; // Data input 
	input clk; // clock input 
	input rst;
	output reg [31:0] Q; // output Q 
	always @(posedge clk or negedge rst)
	begin
		if (!reset) 
			Q<=32'b0;
		else
		begin
			if(clk)
				Q<=D
		end
	end  
endmodule 
