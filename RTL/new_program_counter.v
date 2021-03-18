module new_program_counter(D,reset,Q);
	input [31:0] D; // Data input 
	input reset; // asynchronous active low reset 
	output reg [31:0] Q; // output Q 
	always @(negedge reset) 
	begin
		if (!reset) 
			Q<=32'b0;
	end
	always @(D) 
	begin
		Q<=D;
	end
endmodule 
