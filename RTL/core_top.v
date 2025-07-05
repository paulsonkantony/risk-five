module core_top(clk,reset);
	
	input clk;
	input reset;

	wire [31:0] mem_out; //Data Memory Output
	wire [31:0] rs2_val_sx, alu_addr; //Data Memory Input, Address Input
	wire [3:0]  mem_we_in; //Input to Data Memory - Write Enable
	wire [31:0] instruction;
	wire [31:0] pc_out;


    core main_core(
    .rs2_val_sx(rs2_val_sx), 
    .alu_addr(alu_addr), 
    .mem_we_in(mem_we_in), 
    .IF_pc(pc_out), 
    .clk(clk), 
    .ext_reset(reset), 
    .mem_out(mem_out), 
    .instruction(instruction)
    );
	

	data_mem data_memory( 
	.dout(mem_out)		, 
	.addr(alu_addr)		, 
	.clk(clk)			, 
	.din(rs2_val_sx)	, 
	.mem_we(mem_we_in)
	);

	
	insn_mem insn_memory( 
	.insn(instruction)	,
	.insn_addr(pc_out)		
	);

endmodule