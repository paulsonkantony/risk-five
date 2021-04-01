module load_stall(delayed_rd, delayed_addr, delayed_load, lxx_in, rd, alu_out, clk, rst);

	input lxx_in, clk, rst;
	input [4:0] rd;
	input [31:0] alu_out;

	output reg [4:0] delayed_rd;
	output reg [31:0] delayed_addr;
	output reg delayed_load;

	always @(posedge clk)
	begin
		delayed_load <= lxx_in & rst;
		delayed_rd <= rd;
		delayed_addr <= alu_out;
	end

endmodule