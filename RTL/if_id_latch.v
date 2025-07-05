module if_id_latch(pc_in, insn_in, clk, rst, en, pc_out, insn_out);
	
	input  [31:0] pc_in;
	input  [31:0] insn_in;
	input  clk;
	input  rst;
	input  en;
	output reg [31:0] pc_out;
	output reg [31:0] insn_out;  

	always @(posedge clk)
		begin
			if (!rst) // Active Low Reset
				begin
					pc_out   <= 32'b0;
					insn_out <= 32'b0;
				end
			else if (en)
				begin
					pc_out   <= pc_in;
					insn_out <= insn_in;
				end
		end
		
endmodule