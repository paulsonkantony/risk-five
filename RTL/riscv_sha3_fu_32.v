module riscv_sha3_fu (clk, rst, func, rs1_val, rs2_val, rd_val);
  
	input clk, rst;
	input [9:0] func; 
	input [31:0] rs1_val, rs2_val;
	output [31:0] rd_val;

	`define ROL64(a,b) ((a << b) | (a >> (64-b)))

	reg [63:0] temp;

	wire [63:0] in = {rs2_val, rs1_val} ;

	wire [6:0] imm = func[6:0];
	wire [1:0] op  = func[8:7];
	wire	   en  = func[9];
	
	assign rd_val = op == 2'b10 ? temp[31:0] : temp[63:32] ;

	always@(posedge clk)
	begin
		if (!rst) // Active Low Reset
			temp <= 64'b0;		
		else if (op == 2'b00 && en)
			temp <= temp ^ in;
		else if (op == 2'b01 && en)
			temp <= `ROL64(temp, (imm & 63));
		//else if (op == 2'b10 && en)
		//	temp <= temp;
		else if (op == 2'b11 && en)
			temp <= 64'b0;
		else
			temp <= temp;
	end

endmodule