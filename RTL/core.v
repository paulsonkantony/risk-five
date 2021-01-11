module core(clk,reset);
	input clk;
	input reset;	
	//Wires

	//Register File
	wire reg_we;
	wire [31:0] instruction, instruction_mux_out;
	wire [4:0] rs1, rs2, rd;
	wire [31:0] rd_val, rs1_val, rs2_val;
	wire [1:0] rd_sel;

	//Memory
	wire [31:0] mem_sx, mem_out, rs2_val_sx, mem_out_sx, delayed_addr;
	wire [2:0] sx_size;
	wire [3:0] mem_we_in;
	wire mem_we;
	wire [4:0] delayed_rd;

	wire delayed_load, load_o;

	//Program Counter
	wire [31:0] pc,pc_add_out, pc_add_in, pc_mux_out, pc_in;
	wire [1:0] pc_next_sel;
	wire pc_add_sel;

	//ALU
	wire [31:0] alu_out, mux_a_out, mux_b_out, imm_x;
	wire [3:0] alu_func;
	wire eq, a_lt_b, a_lt_ub, mux_a_sel, mux_b_sel;

	//Datapath

	//Register File
	register_bank register_file(
	.clk 	 (clk)		,
	.rst_n	 (reset)	,  // Reset Neg
	.reg_we	 (reg_we)	,
	.rs1	 (rs1)		,  // Address of r1 Read
	.rs2     (rs2)		,  // Address of r2 Read
	.rd		 (rd)		,  // Addres of Write Register
	.rd_val	 (rd_val)	,  // Data to write
	.rs1_val (rs1_val)	,  // Output register 1
	.rs2_val (rs2_val)	   // Output register 2
	);
	
	mux32four rd_mux(
	.i0(alu_out)		,
	.i1(imm_x)			,
	.i2(pc_add_out)		,
	.i3(mem_out_sx)		,
	.sel(rd_sel)		,
	.out(rd_val)
	);

	
	//Memory
	memory mem( 
	.dout(mem_out)		, 
	.insn(instruction)	,
	.addr(alu_out)		, 
	.insn_addr(pc)		, 
	.clk(clk)			, 
	.din(rs2_val_sx)	, 
	.mem_we(mem_we_in)
	);

	mbr_sx_load mem_to_reg(
	.sx(mem_sx)			, 
	.mbr(mem_out)		, 
	.size(sx_size)		, 
	.delayed_addr(delayed_addr)
	);
	
	mbr_sx_store reg_to_mem(
	.sx(rs2_val_sx)		, 
	.w_en(mem_we_in)	,	 
	.mbr(rs2_val)		, 
	.size(sx_size)		, 
	.mem_we(mem_we)		, 
	.addr(alu_out)
	);

	load_stall stall_unit(
	.delayed_rd(delayed_rd)			, 
	.delayed_addr(delayed_addr)	, 
	.delayed_load(delayed_load)		, 
	.lxx_in(load_o)					, 
	.rd(instruction[11:7]) 			, 
	.alu_out(alu_out) 				, 
	.clk(clk) 						, 
	.rst(reset)
	);


	//Program Counter
	mux32two pc_add_mux(
	.i0 (32'h4), .i1 (imm_x), .sel (pc_add_sel), .out (pc_add_in));
	
	add32 pc_adder (
	.sum (pc_add_out), .A (pc), .B(pc_add_in));
	
	mux32three pc_mux(
	.i0 (pc_add_out), .i1(alu_out), .i2(32'h0), .sel(pc_next_sel), .out(pc_mux_out));
	
	mux32two stall_mux(
	.i0 (pc_mux_out), .i1 (pc), .sel (load_o), .out (pc_in));	
	
	program_counter pc_latch(
	.D(pc_in),.clk(clk),.reset(reset),.Q(pc));


	//ALU
	mux32two alu_a_mux(
	.i0 (rs1_val), .i1 (pc), .sel (mux_a_sel), .out (mux_a_out));
	
	mux32two alu_b_mux (
	.i0 (rs2_val), .i1 (imm_x), .sel (mux_b_sel), .out (mux_b_out));
	
	alu core_alu(
	.alu_out(alu_out)	, 
	.eq(eq)				, 
	.a_lt_b(a_lt_b)		, 
	.a_lt_ub(a_lt_ub)	, 
	.func(alu_func)		, 
	.A(mux_a_out)		, 
	.B(mux_b_out)
	);

	//Control Unit
	parameter NOP_STALL = 32'b00000000000000000000000000010011; // no operation signal which is equivalent to addi x0, x0, 0

	mux32two instruction_mux(
	.i0 (instruction), .i1 (NOP_STALL), .sel (delayed_load), .out (instruction_mux_out));


	control_unit core_control(
	.imm_val(imm_x)			, 
	.rs1(rs1)				, 
	.rs2(rs2)				, 
	.rd(rd)					, 
	.mux_a_sel(mux_a_sel)	, 
	.mux_b_sel(mux_b_sel)	,	 
	.alu_func(alu_func)		, 
	.rd_sel(rd_sel)			, 
	.reg_we(reg_we), 
	.pc_add_sel(pc_add_sel)	, 
	.pc_next_sel(pc_next_sel), 
	.mem_we(mem_we)			, 
	.sx_size(sx_size)		, 
	.load_o(load_o)			, 
	.EQ(eq) 				, 
	.a_lt_b(a_lt_b)			, 
	.a_lt_ub(a_lt_ub)		,	 
	.instruction(instruction_mux_out), 
	.clk(clk)				, 
	.rst(reset)			, 
	.delayed_load(delayed_load), 
	.delayed_rd(delayed_rd)
	);

endmodule

