module rvb_clmul (clmul_valid, op_clmul, op_clmulh, rs1, rs2, rd);
	
	// data input
	input clmul_valid, op_clmul, op_clmulh;
	input  [31:0] rs1;        // value of 1st argument
	input  [31:0] rs2;        // value of 2nd argument
	
	// data output
	output reg [31:0] rd;         // output value
	

	// 13 12  3   Function
	// --------   --------
	//  0  1  0   CLMUL
	//  1  1  0   CLMULH


integer i;
assign rd = 0;
	
	always @*
	begin
	for (i = 0; i < 32; i = i + 1)
		begin
		if(op_clmul)
		begin
		if ((rs2 >> i) & 1)
		   begin
		   rd = rd ^ rs1 << i;
		   end
		end
		else
		begin
		if ((rs2 >> i) & 1)
			begin
			rd = rd ^ rs1 >> (32-i);
			end
		end
		end
	end
endmodule