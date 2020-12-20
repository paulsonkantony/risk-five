module register_bank(
	rst_n		,  // Reset Neg
	rd_clk		,
	rs1		,  // Address of r1 Read
	rs2		,  // Address of r2 Read
	rd		,  // Addres of Write Register
	rd_val		,  // Data to write
	rs1_val	   	,  // Output register 1
	rs2_val		   // Output register 2
);
	
	input rst_n, rd_clk;  
	input [4:0]	rs1, rs2, rd;
	input [31:0] rd_val;
	
	output [31:0]	rs1_val;
	output [31:0]	rs2_val;
	
	// Internal
	reg [31:0] regFile[0:31];
	
	// Assign 0 if R0 else assign value od register
	assign rs1_val = (rs1 == 5'b0) ? 32'b0 : regFile[rs1];
	assign rs2_val = (rs2 == 5'b0) ? 32'b0 : regFile[rs2];

	integer j;
		
	always @ (posedge rd_clk or negedge rst_n) 
	begin 
		// Async Reset (reset=0)
		if ( !rst_n ) 
			begin
				for (j=0; j < 32; j=j+1) 
					begin
						regFile[j] <= 32'b0; //reset array
					end
			end 
		// Write Operation (rd_clk=1)
		else if ( rd_clk ) 
			begin
				regFile[rd] <= rd_val;
			end
	end
	
endmodule