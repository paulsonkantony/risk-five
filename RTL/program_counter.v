module program_counter(D,clk,Q);
	input [31:0] D; // Data input 
	input clk; // clock input 
	output reg [31:0] Q; // output Q 
	always @(posedge clk) 
	 	Q <= D;  
endmodule 