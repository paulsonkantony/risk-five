module memory (dout, addr, clk, din);

	//read_addr and write_addr combined
	input [31:0] addr, din;
	input clk;
	output [31:0] dout;

	reg [31:0] mem [1023:0];

	assign dout = mem[addr];

	always @(posedge clk) 
		begin
			if(clk)
				begin
					mem[addr]<=din;
				end
		end       

endmodule
