  module insn_mem (insn, insn_addr);

	//read_addr and write_addr combined
	input [31:0] insn_addr;
	output [31:0] insn;

	reg [31:0] mem [0:1023]; 

	assign insn = mem[insn_addr[11:2]];
		       

endmodule
