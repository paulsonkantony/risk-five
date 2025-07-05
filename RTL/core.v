module core(rs2_val_sx, alu_addr, mem_we_in, IF_pc, clk, ext_reset, mem_out, instruction);

	input clk, ext_reset; // External Reset is from TB
	wire  reset;

	//Memory
	input [31:0] mem_out, instruction; //Data Memory Output, Insn Mem Output
	output [31:0] rs2_val_sx, alu_addr; //Data Memory Input, Address Input
	output [3:0] mem_we_in; //Input to Data Memory - Write Enable

	output [31:0] IF_pc; //Input to the Instruction Memorty

	//////////////////// WIRES ///////////////////////

	// IF Stage

	wire [31:0] IF_pc, IF_pc_4, IF_insn, IF_pc_new;
	wire ID_hazard;

	// IF_ID_Latch

	wire [31:0] ID_pc, ID_insn;
	wire IF_ID_Flush, ID_pc_next_sel;

	// ID Stage

	wire [4:0]  ID_rs1, ID_rs2, ID_rd;
	wire [31:0] ID_imm_x, ID_rs1_val, ID_rs2_val;
 
    wire [7:0] ID_fn3;
    
    wire ID_is_scalar_crypto;
    wire ID_is_bitmanip;

    wire [22:0] ID_bitmanip_instruction;
    wire [19:0] ID_crypto_instruction;
    wire [9:0] ID_sha3_instruction;

    wire ID_sysi_o;

    wire [3:0] ID_alu_func;
    wire [2:0] ID_sx_size;
    wire [1:0] ID_rd_sel;
    wire ID_mux_a_sel, ID_mux_b_sel, ID_reg_we, ID_mem_we, ID_mem_re;

    wire ID_jal_o, ID_jalr_o, ID_branch_o;

    wire [31:0] ID_jump_mux_out, ID_jump_adder_out; 

    wire [7:0] ID_fn3_mux_out;
    
    wire ID_is_scalar_crypto_mux_out;
    wire ID_is_bitmanip_mux_out;

    wire [22:0] ID_bitmanip_instruction_mux_out;
    wire [19:0] ID_crypto_instruction_mux_out;
    wire [9:0] ID_sha3_instruction_mux_out;

    wire ID_sysi_o_mux_out;

    wire [3:0] ID_alu_func_mux_out;
    wire [2:0] ID_sx_size_mux_out;
    wire [1:0] ID_rd_sel_mux_out;
    wire ID_mux_a_sel_mux_out, ID_mux_b_sel_mux_out, ID_reg_we_mux_out, ID_mem_we_mux_out, ID_mem_re_mux_out;

    wire ID_jal_o_mux_out, ID_jalr_o_mux_out, ID_branch_o_mux_out;

    wire [31:0] fwd_a_mux_branch_out, fwd_b_mux_branch_out;
	wire [1:0]  fwd_a_branch, fwd_b_branch;
    
    // ID_EX_Latch

    wire [4:0]  EX_rd;
	wire [4:0]  EX_rs1, EX_rs2;
	wire [31:0] EX_imm_x, EX_rs1_val, EX_rs2_val, EX_pc;
    
    wire EX_is_scalar_crypto;
    wire EX_is_bitmanip;

    wire [22:0] EX_bitmanip_instruction;
    wire [19:0] EX_crypto_instruction;
    wire [9:0] EX_sha3_instruction;

    wire [1:0] alu_out_mux_sel;

    wire EX_sysi_o;

    wire [3:0] EX_alu_func;
    wire [2:0] EX_sx_size;
    wire [1:0] EX_rd_sel;
    wire EX_mux_a_sel, EX_mux_b_sel, EX_reg_we, EX_mem_we, EX_mem_re;


	//EX Stage

	wire [31:0] fwd_a_mux_out, fwd_b_mux_out, EX_mux_a_out, EX_mux_b_out, EX_alu_mux_out;

	wire [1:0] fwd_a, fwd_b;

	wire [31:0] EX_alu_out, EX_crypto_out, EX_bitmanip_out, EX_sha3_out;

	// EX_MEM_Latch

	wire [4:0]  MEM_rd, MEM_rs2;
	wire [31:0] MEM_imm_x, MEM_alu_out, MEM_pc, MEM_rs2_val;
    
    wire MEM_sysi_o;

    wire [2:0] MEM_sx_size;
    wire [1:0] MEM_rd_sel;
    wire MEM_reg_we, MEM_mem_we, MEM_mem_re;

    //Memory

	wire [31:0] MEM_mem_out, rs2_sw_in;
	wire fwd_sw;

	//MEM_WB_Latch

	wire [4:0]  WB_rd;
	wire [31:0] WB_imm_x, WB_alu_out, WB_pc, WB_rs2_val, WB_mem_out;
    
    wire WB_sysi_o;
    wire [1:0] WB_rd_sel;
    wire WB_reg_we;

    //WB

	wire [31:0] rd_mux_out;


	//////////////////// CONNECTIONS ///////////////////////


	// IF Stage

	program_counter pc_latch(
		.D(IF_pc_new), 
		.clk(clk), 
		.rst(reset), 
		.en(ID_hazard), 
		.Q(IF_pc));
	
	add32 pc_adder (
		.sum (IF_pc_4), 
		.A (IF_pc), 
		.B(4));

	assign IF_insn = instruction ;

	// IF_ID_Latch

	//assign IF_ID_Flush = ID_pc_next_sel | reset;

	nor IF_ID_Flush_gate(IF_ID_Flush, ~reset, ID_pc_next_sel & ID_hazard);

	if_id_latch IF_ID(
		.pc_in(IF_pc), 
		.insn_in(IF_insn), 
		.clk(clk), 
		.rst(IF_ID_Flush), 
		.en(ID_hazard), 
		.pc_out(ID_pc), 
		.insn_out(ID_insn)
	);

	// ID Stage

 	control_unit core_control(
 		.imm_val	(ID_imm_x), 
 		.rs1 		(ID_rs1), 
 		.rs2 		(ID_rs2), 
 		.rd 		(ID_rd), 
 		.mux_a_sel 	(ID_mux_a_sel), 
 		.mux_b_sel 	(ID_mux_b_sel), 
 		.alu_func   (ID_alu_func), 
 		.rd_sel     (ID_rd_sel), 
 		.reg_we     (ID_reg_we),
     	.is_scalar_crypto (ID_is_scalar_crypto), 
     	.is_bitmanip (ID_is_bitmanip), 
     	.crypto_instruction (ID_crypto_instruction), 
     	.bitmanip_instruction (ID_bitmanip_instruction),
     	.sha3_instruction (ID_sha3_instruction),
	 	.mem_we 	(ID_mem_we), 
	 	.mem_re 	(ID_mem_re), 
	 	.sx_size 	(ID_sx_size), 
	 	.sysi_o 	(ID_sysi_o), 
	 	.fn3 		(ID_fn3),
	 	.jal_o 		(ID_jal_o), 
	 	.jalr_o 	(ID_jalr_o), 
	 	.branch_o 	(ID_branch_o),
	 	.instruction(ID_insn), 
	 	.clk		(clk), 
	 	.rst 		(reset)
 		);
	
	b_op branch_control(
		.pc_next_sel(ID_pc_next_sel), 
		.rs1_val    (fwd_a_mux_branch_out), 
		.rs2_val    (fwd_b_mux_branch_out),
		.jal 		(ID_jal_o),  
		.jal_r 	    (ID_jalr_o),  
		.branch_o 	(ID_branch_o), 
		.fn3 		(ID_fn3),
		.reset      (reset)
		);

	register_bank register_file(
		.clk 	 (clk)		,
		.rst_n	 (reset)	,  // Reset Neg
		.reg_we	 (WB_reg_we)	,
		.rs1	 (ID_rs1)		,  // Address of r1 Read
		.rs2     (ID_rs2)		,  // Address of r2 Read
		.rd		 (WB_rd)		,  // Addres of Write Register
		.rd_val	 (rd_mux_out)	,  // Data to write
		.rs1_val (ID_rs1_val)	,  // Output register 1
		.rs2_val (ID_rs2_val)	   // Output register 2
	);

	mux32two jump_mux(
		.i0		(ID_pc), 
		.i1 	(fwd_a_mux_branch_out), 
		.sel 	(ID_jalr_o), 
		.out 	(ID_jump_mux_out)
		);

	add32_jump jump_adder (
		.sum (ID_jump_adder_out), .A (ID_jump_mux_out), .B(ID_imm_x), .jal_r(ID_jalr_o));

    hazard_det_unit hazard_control(
    	.stall(ID_hazard), 
    	.if_id_rs1(ID_rs1), 
    	.if_id_rs2(ID_rs2),
    	.id_ex_mem_re(EX_mem_re), 
    	.id_ex_rd(EX_rd),
    	.if_id_branch_o(ID_branch_o), 
    	.id_ex_reg_we(EX_reg_we),
    	.ex_mem_mem_re(MEM_mem_re),
    	.ex_mem_rd(MEM_rd),
    	.if_id_jalr(ID_jalr_o),
    	.ID_is_crypto(ID_is_scalar_crypto),
		.ID_is_bitmanip(ID_is_bitmanip),
		.ID_sha3_instruction(ID_sha3_instruction)
    	);

	mux_control hazard_mux(
		.mux_a_sel_out(ID_mux_a_sel_mux_out), 
		.mux_b_sel_out(ID_mux_b_sel_mux_out), 
		.alu_func_out(ID_alu_func_mux_out), 
		.rd_sel_out(ID_rd_sel_mux_out), 
		.reg_we_out(ID_reg_we_mux_out),
     	.is_scalar_crypto_out(ID_is_scalar_crypto_mux_out), 
     	.is_bitmanip_out(ID_is_bitmanip_mux_out), 
     	.crypto_instruction_out(ID_crypto_instruction_mux_out), 
     	.bitmanip_instruction_out(ID_bitmanip_instruction_mux_out),
     	.sha3_instruction_out(ID_sha3_instruction_mux_out),
	 	.mem_we_out(ID_mem_we_mux_out), 
	 	.mem_re_out(ID_mem_re_mux_out), 
	 	.sx_size_out(ID_sx_size_mux_out), 
	 	.sysi_o_out(ID_sysi_o_mux_out),

	 	.mux_a_sel_in(ID_mux_a_sel), 
	 	.mux_b_sel_in(ID_mux_b_sel), 
	 	.alu_func_in(ID_alu_func), 
	 	.rd_sel_in(ID_rd_sel), 
	 	.reg_we_in(ID_reg_we),
     	.is_scalar_crypto_in(ID_is_scalar_crypto), 
     	.is_bitmanip_in(ID_is_bitmanip), 
     	.crypto_instruction_in(ID_crypto_instruction), 
     	.bitmanip_instruction_in(ID_bitmanip_instruction),
     	.sha3_instruction_in(ID_sha3_instruction),	
	 	.mem_we_in(ID_mem_we), 
	 	.mem_re_in(ID_mem_re), 
	 	.sx_size_in(ID_sx_size),  
	 	.sysi_o_in(ID_sysi_o), 
	 	.sel(~ID_hazard)
	 	);

	mux32three fwd_a_mux_branch(
	.i0 (ID_rs1_val), 
	.i1 (MEM_alu_out), 
	.i2 (rd_mux_out), 
	.sel (fwd_a_branch), 
	.out (fwd_a_mux_branch_out)
	);

	mux32three fwd_b_mux_branch(
	.i0 (ID_rs2_val), 
	.i1 (MEM_alu_out), 
	.i2 (rd_mux_out), 
	.sel (fwd_b_branch), 
	.out (fwd_b_mux_branch_out)
	);

	forwarding_unit_branch forwarding_control_branch(
	.fwd_a(fwd_a_branch), 
	.fwd_b(fwd_b_branch), 
	.id_ex_rs1(ID_rs1), 
	.id_ex_rs2(ID_rs2), 
	.ex_mem_rd(MEM_rd), 
	.mem_wb_rd(WB_rd),
	.ex_mem_reg_we(MEM_reg_we), 
	.mem_wb_reg_we(WB_reg_we), 
	.branch_o(ID_branch_o), 
	.jalr_o(ID_jalr_o)
	);


	// ID_EX_Latch

	id_ex_latch ID_EX(

		.rs1_val_out(EX_rs1_val), 
		.rs2_val_out(EX_rs2_val),
		.imm_x_out(EX_imm_x),
		.rs1_out(EX_rs1), 
		.rs2_out(EX_rs2), 
		.rd_out(EX_rd),
		.pc_out(EX_pc),

		.mux_a_sel_out(EX_mux_a_sel), 
		.mux_b_sel_out(EX_mux_b_sel), 
		.alu_func_out(EX_alu_func), 
		.rd_sel_out(EX_rd_sel), 
		.reg_we_out(EX_reg_we),
	    .is_scalar_crypto_out(EX_is_scalar_crypto), 
	    .is_bitmanip_out(EX_is_bitmanip), 
	    .crypto_instruction_out(EX_crypto_instruction), 
	    .bitmanip_instruction_out(EX_bitmanip_instruction),
	    .sha3_instruction_out(EX_sha3_instruction),
		.mem_we_out(EX_mem_we), 
		.mem_re_out(EX_mem_re), 
		.sx_size_out(EX_sx_size), 
		.sysi_o_out(EX_sysi_o),

		.rs1_val_in(ID_rs1_val), 
		.rs2_val_in(ID_rs2_val),
		.imm_x_in(ID_imm_x),
		.rs1_in(ID_rs1), 
		.rs2_in(ID_rs2), 
		.rd_in(ID_rd),
		.pc_in(ID_pc),
		 
		.mux_a_sel_in(ID_mux_a_sel_mux_out), 
		.mux_b_sel_in(ID_mux_b_sel_mux_out), 
		.alu_func_in(ID_alu_func_mux_out),
		.rd_sel_in(ID_rd_sel_mux_out), 
		.reg_we_in(ID_reg_we_mux_out),
	 	.is_scalar_crypto_in(ID_is_scalar_crypto_mux_out), 
	 	.is_bitmanip_in(ID_is_bitmanip_mux_out), 
	 	.crypto_instruction_in(ID_crypto_instruction_mux_out), 
	 	.bitmanip_instruction_in(ID_bitmanip_instruction_mux_out),
	 	.sha3_instruction_in(ID_sha3_instruction_mux_out),
	 	.mem_we_in(ID_mem_we_mux_out), 
	 	.mem_re_in(ID_mem_re_mux_out), 
	 	.sx_size_in(ID_sx_size_mux_out), 
	 	.sysi_o_in(ID_sysi_o_mux_out),
		 
		.clk(clk), 
		.rst(reset), 
		.en(1'b1)
	
	);


	//EX Stage

	mux32three fwd_a_mux(
	.i0 (EX_rs1_val), 
	.i1 (MEM_alu_out), 
	.i2 (rd_mux_out), 
	.sel (fwd_a), 
	.out (fwd_a_mux_out)
	);

	mux32three fwd_b_mux(
	.i0 (EX_rs2_val), 
	.i1 (MEM_alu_out), 
	.i2 (rd_mux_out), 
	.sel (fwd_b), 
	.out (fwd_b_mux_out)
	);


	//ALU
	mux32two alu_a_mux(
	.i0 (fwd_a_mux_out), 
	.i1 (EX_pc), 
	.sel (EX_mux_a_sel), 
	.out (EX_mux_a_out)
	);
	
	mux32two alu_b_mux (
	.i0 (fwd_b_mux_out), 
	.i1 (EX_imm_x), 
	.sel (EX_mux_b_sel), 
	.out (EX_mux_b_out)
	);
	
	alu core_alu(
	.alu_out(EX_alu_out)	, 
	.func(EX_alu_func)		, 
	.A(EX_mux_a_out)		, 
	.B(EX_mux_b_out)
	);

	riscv_crypto_fu crypto_fu(
	.rs1(fwd_a_mux_out), 
	.rs2(fwd_b_mux_out), 
	.instruction(EX_crypto_instruction), 
	.rd(EX_crypto_out)
	);

	riscv_sha3_fu sha3_fu(
	.clk(clk), 
	.rst(reset),
	.func(EX_sha3_instruction), 
	.rs1_val(fwd_a_mux_out), 
	.rs2_val(fwd_b_mux_out), 
	.rd_val(EX_sha3_out)
	);

	//////////////////////####################### Why clock and reset for bitmanip?

	bitmanip_top bitmanip_fu(
	.rs1(fwd_a_mux_out), 
	.rs2(fwd_b_mux_out), 
	.instruction(EX_bitmanip_instruction), 
	.rd(EX_bitmanip_out), 
	.clk(clk), 
	.rst(reset)
	);

	assign alu_out_mux_sel = {EX_is_bitmanip, EX_is_scalar_crypto};

	wire [31:0] EX_alu_mux_out_temp;

	mux32four alu_out_mux(
	.i0 (EX_alu_out), 
	.i1 (EX_crypto_out), 
	.i2 (EX_bitmanip_out),
	.i3 (EX_sha3_out), 
	.sel (alu_out_mux_sel), 
	.out (EX_alu_mux_out_temp)
	);

	mux32two alu_out_mux_new (
	.i0 (EX_alu_mux_out_temp), 
	.i1 (EX_imm_x), 
	.sel (EX_rd_sel == 2'b01), 
	.out (EX_alu_mux_out)
	);

	forwarding_unit forwarding_control(
	.fwd_a(fwd_a), 
	.fwd_b(fwd_b), 
	.id_ex_rs1(EX_rs1), 
	.id_ex_rs2(EX_rs2), 
	.ex_mem_rd(MEM_rd), 
	.mem_wb_rd(WB_rd),
	.ex_mem_reg_we(MEM_reg_we), 
	.mem_wb_reg_we(WB_reg_we)
	);

	// EX_MEM_Latch

    ex_mem_latch EX_MEM(

		.imm_x_out(MEM_imm_x),
		.pc_out(MEM_pc),
		.alu_out(MEM_alu_out),
		.rs2_val_out(MEM_rs2_val),

		.rd_sel_out(MEM_rd_sel), 
		.reg_we_out(MEM_reg_we),
		.mem_we_out(MEM_mem_we), 
		.sx_size_out(MEM_sx_size), 
		.sysi_o_out(MEM_sysi_o),
		.mem_re_out(MEM_mem_re),

		.rd_out(MEM_rd),
		.rs2_out(MEM_rs2),

		.imm_x_in(EX_imm_x),
		.pc_in(EX_pc),
		.alu_in(EX_alu_mux_out),
		.rs2_val_in(fwd_b_mux_out),
		 
		.rd_sel_in(EX_rd_sel), 
		.reg_we_in(EX_reg_we),
	    .mem_we_in(EX_mem_we),
	    .mem_re_in(EX_mem_re), 
	    .sx_size_in(EX_sx_size), 
	    .sysi_o_in(EX_sysi_o), 

	    .rd_in(EX_rd),
	    .rs2_in(EX_rs2),
		 
		.clk(clk), 
		.rst(reset), 
		.en(1'b1)
	
	);

	//Memory

	forwarding_unit_sw forwarding_control_sw(
		.fwd_a(fwd_sw), 
		.ex_mem_rs2(MEM_rs2), 
		.mem_wb_rd(WB_rd), 
		.mem_wb_reg_we(WB_reg_we)
	);

	mux32two mbr_sx_store_mux(
		.i1 (rd_mux_out), 
		.i0 (MEM_rs2_val), 
		.sel (fwd_sw), 
		.out (rs2_sw_in)
	);

	assign alu_addr = MEM_alu_out;

	mbr_sx_load mem_to_reg(
	.sx(MEM_mem_out)			, 
	.mbr(mem_out)		, //Coming In
	.size(MEM_sx_size)		, 
	.delayed_addr(MEM_alu_out)
	);
	

	mbr_sx_store reg_to_mem(
	.sx(rs2_val_sx)		, //Going Out
	.w_en(mem_we_in)	, //Going Out
	.mbr(rs2_sw_in)		, 
	.size(MEM_sx_size)		, 
	.mem_we(MEM_mem_we)		, 
	.addr(MEM_alu_out)
	);


	//MEM_WB_Latch

	mem_wb_latch MEM_WB(

		.imm_x_out(WB_imm_x),
		.pc_out(WB_pc),
		.alu_out(WB_alu_out),
		.data_mem_out(WB_mem_out),

		.rd_sel_out(WB_rd_sel), 
		.reg_we_out(WB_reg_we),
		.sysi_o_out(WB_sysi_o),

		.rd_out(WB_rd),

		.imm_x_in(MEM_imm_x),
		.pc_in(MEM_pc),
		.alu_in(MEM_alu_out),
		.data_mem_in(MEM_mem_out),
		
		.rd_sel_in(MEM_rd_sel), 
		.reg_we_in(MEM_reg_we),
	    .sysi_o_in(MEM_sysi_o), 

	    .rd_in(MEM_rd),
	 
	 	.clk(clk), 
		.rst(reset), 
		.en(1'b1)
	
	);


	mux32four rd_mux(
		.i0(WB_alu_out), 
		.i1(WB_imm_x), 
		.i2(WB_pc+4), 
		.i3(WB_mem_out), 
		.sel(WB_rd_sel), 
		.out(rd_mux_out)
	);

	mux32two pc_mux(
	.i1 (ID_jump_adder_out), 
	.i0 (IF_pc_4), 
	.sel (ID_pc_next_sel), 
	.out (IF_pc_new)  
	);

	//assign reset = ~(~ext_reset | WB_sysi_o);

	nor reset_gate(reset, ~ext_reset, WB_sysi_o);

endmodule