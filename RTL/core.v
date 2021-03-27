module core(rs2_val_sx, alu_addr, mem_we_in, pc_out, clk, ext_reset, mem_out, instruction);
	input clk;
	input ext_reset;
	wire reset;
	//Wires

	//Register File
	wire reg_we;
	wire [31:0] instruction_mux_out;
	wire [4:0] rs1, rs2, rd;
	wire [31:0] rd_val, rs1_val, rs2_val;
	wire [1:0] rd_sel;

	//Memory
	input [31:0] mem_out, instruction; //Data Memory Output, Insn Mem Output
	output [31:0] rs2_val_sx, alu_addr; //Data Memory Input, Address Input
	output [3:0] mem_we_in; //Input to Data Memory - Write Enable
	output [31:0] pc_out;
	assign pc_out = pc;
	assign alu_addr = alu_out;
	
	wire [31:0] rs2_val_sx, mem_out_sx, delayed_addr;
	wire [2:0] sx_size;
	wire mem_we;
	wire [4:0] delayed_rd;

	wire delayed_load, stall;

	//Program Counter
	wire [31:0] pc, pc_add_out, pc_add_in, pc_mux_out, new_pc_in;
	wire pc_next_sel, pc_add_sel;

	//ALU
	wire [31:0] alu_out, mux_a_out, mux_b_out, imm_x;
	wire [3:0] alu_func;
	wire eq, a_lt_b, a_lt_ub, mux_a_sel, mux_b_sel;

	//Crypto
	wire [19:0] crypto_insn;
	wire [31:0] crypto_mux_out, crypto_rd;
	wire is_scalar_crypto;

	//Datapath

	//Register File
	register_bank register_file(
	.clk 	 (clk)		,
	.rst_n	 (reset)	,  // Reset Neg
	.reg_we	 (reg_we)	,
	.rs1	 (rs1)		,  // Address of r1 Read
	.rs2     (rs2)		,  // Address of r2 Read
	.rd		 (rd)		,  // Addres of Write Register
	.rd_val	 (crypto_mux_out)	,  // Data to write
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

	mbr_sx_load mem_to_reg(
	.sx(mem_out_sx)			, 
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
	.lxx_in(stall)					, 
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
	
	mux32two pc_mux(
	.i0 (pc_add_out), .i1(alu_out), .sel(pc_next_sel), .out(pc_mux_out));
	
	mux32two stall_mux(
	.i0 (pc_mux_out), .i1 (pc), .sel (stall), .out (new_pc_in));	
	
	program_counter pc_latch(
		.D(new_pc_in),.clk(clk),.rst(reset),.Q(pc));


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

	wire sysi_o;

	control_unit core_control(
	.imm_val(imm_x)			, 
	.rs1(rs1)				, 
	.rs2(rs2)				, 
	.rd(rd)					, 
	.mux_a_sel(mux_a_sel)	, 
	.mux_b_sel(mux_b_sel)	,	 
	.alu_func(alu_func)		, 
	.is_scalar_crypto(is_scalar_crypto),
	.rd_sel(rd_sel)			, 
	.reg_we(reg_we), 
	.pc_add_sel(pc_add_sel)	, 
	.pc_next_sel(pc_next_sel), 
	.mem_we(mem_we)			, 
	.sx_size(sx_size)		, 
	.stall(stall)			, 
	.sysi_o(sysi_o)			,
	.eq(eq) 				, 
	.a_lt_b(a_lt_b)			, 
	.a_lt_ub(a_lt_ub)		,	 
	.instruction(instruction_mux_out), 
	.clk(clk)				, 
	.rst(reset)			, 
	.delayed_load(delayed_load), 
	.delayed_rd(delayed_rd),
	.crypto_instruction(crypto_insn)
	);


	//If any system function is called, it generates a reset
	assign reset = ext_reset & !sysi_o;

	//Scalar Crypto
	mux32two crypto_mux(
	.i0 (rd_val), .i1 (crypto_rd), .sel (is_scalar_crypto), .out (crypto_mux_out));

	riscv_crypto_fu crypto_fu(
	.rs1(rs1_val), 
	.rs2(rs2_val), 
	.instruction(crypto_insn), 
	.rd(crypto_rd)
	);

endmodule

