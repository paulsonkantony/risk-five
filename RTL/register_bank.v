module register_bank(
	clk 	,
	rst_n	,  // Reset Neg
	reg_we	,
	rs1		,  // Address of r1 Read
	rs2		,  // Address of r2 Read
	rd		,  // Addres of Write Register
	rd_val	,  // Data to write
	rs1_val	,  // Output register 1
	rs2_val	   // Output register 2
);
	
	input rst_n, clk, reg_we;  
	input [4:0]	rs1, rs2, rd;
	input [31:0] rd_val;
	output [31:0]	rs1_val;
	output [31:0]	rs2_val;
	
	// Internal
	reg [31:0] regFile[0:31]; //Little Endian
	
	// Assign 0 if R0 else assign value od register
	assign rs1_val = (rs1 == 5'b0) ? 32'b0 : regFile[rs1];
	assign rs2_val = (rs2 == 5'b0) ? 32'b0 : regFile[rs2];

	integer j;
		
	always @ (posedge clk) 
	begin 
		// Async Reset (reset=0)
		if ( !rst_n ) 
			begin
				for (j=0; j < 32; j=j+1) 
					begin
						if(j==2)
							regFile[j] <= 32'hFFFFFFFF; //Descending Stack Pointer - Set to end of memory
						else
							regFile[j] <= 32'b0; //reset array
					end
			end 
		// Write Operation (clk=1)
		else
			begin
				if(reg_we)
				begin
					regFile[rd] <= rd_val;
				end
			end
	end
	
endmodule
