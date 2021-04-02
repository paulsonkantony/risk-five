module add32(sum, A, B);
	input [31:0] A, B;
	output [31:0] sum;
	assign sum = A + B;
endmodule