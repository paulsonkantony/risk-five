module rvb_xperm (xperm_valid, sz_log2, sz, mask, rs1,rs2,res);

	input xperm_valid;
	input [31:0] rs1, rs2;

	input [2:0] sz_log2;
	input [31:0] sz, mask;

	output reg [31:0] res;
	
		
	integer i, pos;
	

		always @ (xperm_valid)
		begin		
		if(xperm_valid)
		begin
		if(sz == 4)
		begin		
		for (i = 0; i < 32; i = i + 4) 
		    begin
		        pos = ((rs2 >> i) & mask) << sz_log2;
		        if (pos < 32) 
		            begin 
		               res = res | ((rs1 >> pos) & mask) << i;
		            end
		    end
		end 
		else
		begin
		for (i = 0; i < 32; i = i + 8) 
		    begin
		        pos = ((rs2 >> i) & mask) << sz_log2;
		        if (pos < 32) 
		            begin 
		                res = res | ((rs1 >> pos) & mask) << i;
		            end
		    end
		end
		end	
		end
endmodule
