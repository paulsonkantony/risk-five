module program_counter(D,clk,reset,Q);
input [31:0] D; // Data input 
input clk; // clock input 
input reset; // asynchronous reset low level 
output reg [31:0] Q; // output Q 
always @(posedge clk or negedge reset) 
	begin
		 if(reset==1'b0)
		 	Q <= 32'b0; 
		 else 
		 	Q <= D; 
	end 
endmodule 