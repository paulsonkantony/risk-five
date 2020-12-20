module core(clk);
	input clk;
	
	//Wires

	//Register File
	wire rd_clk, reset;
	wire [31:0] instruction;
	wire [31:0] rd_val, rs1_val, rs2_val;
	wire [1:0] rd_sel;

	//Memory
	wire [31:0] mem_sx, mem_out, addr, rs2_val_sx;
	wire [2:0] sx_size;
	wire mem_clk, addr_sel;

	//Program Counter
	wire [31:0] pc,pc_adder_out, pc_alu_out, pc_mux_out;
	wire pc_clk, pc_alu_sel, pc_next_sel;

	//Instruction Register
	wire [31:0] imm_x;
	wire insn_clk;

	//ALU
	wire [31:0] alu_out, mux_a, mux_b;
	wire [3:0] alu_func;
	wire eq, a_lt_b, a_lt_ub, alu_a_sel, alu_b_sel;

	//Datapath

	//Register File
	register_bank register_file(
	.rst_n(reset)			,  // Reset Neg
	.rd_clk(rd_clk)			,
	.rs1(instruction[19:15])	,  // Address of r1 Read
	.rs2(instruction[24:20])	,  // Address of r2 Read
	.rd (instruction[11:7])		,  // Addres of Write Register
	.rd_val	(rd_val)		,  // Data to write
	.rs1_val(rs1_val)	   	,  // Output register 1
	.rs2_val(rs2_val)		   // Output register 2
	);
	mux32three	rd_mux(.i0(pc_alu_out),.i1(alu_out),.i2(mem_sx),.sel(rd_sel),.out(rd_val));

	//Memory
	memory	  mem 	      (.dout(mem_out), .addr(addr), .clk(mem_clk), .din(rs2_val_sx));
	mbr_sx	  mem_to_reg  (.sx(mem_sx), .mbr(mem_out), .size(sx_size));
	mbr_sx	  reg_to_mem  (.sx(rs2_val_sx), .mbr(rs2_val), .size(sx_size));
	mux32two  mem_mux     (.i0 (pc_alu_out),.i1 (alu_out),.sel (pc_next_sel),.out (pc_mux_out));

	//Program Counter
	mux32two	pc_alu_mux 	(.i0 (imm_x),.i1 (32'h4),.sel (pc_alu_sel),.out (pc_adder_out));
	add32 		pc_adder 	(.sum (pc_alu_out),.A (pc_adder_out), .B (pc));
	mux32two 	pc_mux 		(.i0 (pc_alu_out),.i1 (alu_out),.sel (pc_next_sel),.out (pc_mux_out));
	dff 		pc_latch 	(.D(pc_mux_out),.clk(pc_clk),.reset(reset),.Q(pc));

	//Instruction Register
	dff    insn_latch (.D(mem_out),.clk(insn_clk),.reset(reset),.Q(instruction));
	imm_sx gen_imm	  (.imm_x(imm_x), .insn(instruction));

	//ALU
	mux32two alu_a_mux (.i0 (rs1_val),.i1 (pc),.sel (alu_a_sel),.out (mux_a));
	mux32two alu_b_mux (.i0 (rs2_val),.i1 (imm_x),.sel (alu_b_sel),.out (mux_b));
	alu 	 core_alu  (.alu_out(alu_out), .eq(eq), .a_lt_b(a_lt_b), .a_lt_ub(a_lt_ub), 
						.func(alu_func), .A(mux_a), .B(mux_b));

	//Control Unit
	control_unit core_control 
	(.func(alu_func), .addr_sel(addr_sel), .rd_sel(rd_sel), .alu_a_sel(alu_a_sel), .alu_b_sel(alu_b_sel), 
	 .pc_alu_sel(pc_alu_sel), .pc_next_sel(pc_next_sel), 
	 .mem_clk(mem_clk), .rd_clk(rd_clk), .pc_clk(pc_clk), .insn_clk(insn_clk), .sx_size(sx_size), .reset(reset),
	 .EQ(eq), .a_lt_b(a_lt_b), .a_lt_ub(a_lt_ub), .opcode(opcode), .func3(func3), .func7(func7),.clk(clk));

endmodule

