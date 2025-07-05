module add32_jump(sum, A, B, jal_r);

	input  [31:0] A, B;
	input jal_r;
	output [31:0] sum;
	
	assign sum = jal_r ? ((A + B) & 32'hFFFFFFFE): A+B;

endmodule