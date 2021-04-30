  module insn_mem (insn, insn_addr);

	//read_addr and write_addr combined
	input [31:0] insn_addr;
	output [31:0] insn;	 
	reg [31:0] mem [0:1023];
	
	`ifndef TESTING
	integer k;
	
	always @*
	begin
		for(k=0; k<1024; k=k+1)
		begin
			mem[k] = 32'b0;
		end
	end
	`endif

	assign insn = mem[insn_addr[11:2]];
		       

endmodule
