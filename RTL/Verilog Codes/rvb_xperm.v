module rvb_xperm (xperm_valid, op_xperm_n, op_xperm_b,rs1,rs2,res);

	input xperm_valid, op_xperm_b, op_xperm_n;
	input [31:0] rs1, rs2;

	output reg [31:0] res ;

	integer sz_log2;

	reg [31:0] sz, mask;
	reg [31:0] pos;

	assign sz_log2 = op_xperm_n ? 2 :
	                 op_xperm_b ? 3 :
	                 0 ; 

	assign sz = 1 << sz_log2 ;
	assign mask = (1 << sz) - 1;

	integer i;
	assign res = 0;
	
	always @*
	begin
	for (i = 0; i < 32; i = i + sz) 
		begin
		    assign pos = ((rs2 >> i) & mask) << sz_log2;
		    if (pos < 32) 
		    	begin 
				res = res | ((rs1 >> pos) & mask) << i;
		        end
		 end
	end
endmodule
