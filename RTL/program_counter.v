module program_counter(D,clk,rst,Q);
	input [31:0] D; // Data input 
	input clk; // clock input 
	input rst;
	output reg [31:0] Q; // output Q 
	always @(posedge clk)
	begin
		if (!rst) 
			Q<=32'b0;
		else
			Q<=D;
	end  
endmodule 
