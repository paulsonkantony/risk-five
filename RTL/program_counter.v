module program_counter(D, clk, rst, en, Q);
	
	input  [31:0] D;
	input  clk;
	input  rst;
	input  en;
	output reg [31:0] Q; 

	always @(posedge clk)
		begin
			if (!rst) // Active Low Reset
				Q <= 32'b0;
			else if (en)
				Q <= D;
		end
		
endmodule