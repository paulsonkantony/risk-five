module control_unit
	(func, addr_sel, rd_sel, alu_a_sel, alu_b_sel, pc_alu_sel, pc_next_sel, 
	 mem_clk, rd_clk, pc_clk, insn_clk, sx_size, reset,
	 EQ, a_lt_b, a_lt_ub, opcode, func3, func7,clk);

	input EQ, a_lt_b, a_lt_ub, func7;
	input [6:0] opcode;
	input [2:0] func3;
    input clk;
	
	output [3:0] func;
	output [2:0] sx_size;
	output [1:0] rd_sel;
	output addr_sel, alu_a_sel, alu_b_sel, pc_alu_sel, pc_next_sel, reset;
	output mem_clk, rd_clk, pc_clk, insn_clk;

	//Opcodes

	parameter OPCODE_U_LUI 	= 7'b0110111,
     		OPCODE_U_AUIPC 	= 7'b0010111,
     		OPCODE_J_JAL 	= 7'b1101111,
     		OPCODE_I_JALR	= 7'b1100111,
     		OPCODE_B_BRANCH = 7'b1100011,
     		OPCODE_I_LOAD 	= 7'b0000011,
     		OPCODE_S_STORE 	= 7'b0100011,  
     		OPCODE_I_IMM 	= 7'b0010011,
     		OPCODE_R_ALU 	= 7'b0110011;

    //func3
    parameter FUNCT3_JARL = 3'b000;

    ////  B_BRANCH
    parameter FUNCT3_BEQ 	 = 3'b000,
     		FUNCT3_BNE 	 = 3'b001,
     		FUNCT3_BLT 	 = 3'b100,
     		FUNCT3_BGE 	 = 3'b101,
     		FUNCT3_BLTU 	 = 3'b110,
     		FUNCT3_BGEU 	 = 3'b111;

    // I_LOAD
    parameter FUNCT3_LB 	= 3'b000,
     		FUNCT3_LH 	= 3'b001,
     		FUNCT3_LW 	= 3'b010,
     		FUNCT3_LBU 	= 3'b100,
     		FUNCT3_LHU 	= 3'b101;

    //  S_STORES
    parameter FUNCT3_SB = 3'b000,
     		FUNCT3_SH 	= 3'b001,
     		FUNCT3_SW 	= 3'b010;

    //  I_IMM
    parameter FUNCT3_ADDI	= 3'b000,
     		FUNCT3_SLTI 	= 3'b010,
     		FUNCT3_SLTIU 	= 3'b011,
     		FUNCT3_XORI 	= 3'b100,
     		FUNCT3_ORI 	= 3'b110,
     		FUNCT3_ANDI 	= 3'b111,
     		FUNCT3_SLLI 	= 3'b001,
     		FUNCT3_SRLI_SRAI= 3'b101;

    //  R_ALU
    parameter FUNCT3_ADD_SUB 	= 3'b000,
     		FUNCT3_SLL   	= 3'b001,
     		FUNCT3_SLT 	= 3'b010,
     		FUNCT3_SLTU 	= 3'b011,
     		FUNCT3_XOR 	= 3'b100,
     		FUNCT3_SRL_SRA 	= 3'b101,
     		FUNCT3_OR 	= 3'b110,
     		FUNCT3_AND 	= 3'b111;

    // ALU FUNC values 		
    parameter func_ADD  	= 0, 
		func_SUB 	= 1,  
		func_SLLI 	= 2,
		func_SLT  	= 3,
		func_SLTU 	= 4,
		func_XOR 	= 5,
		func_SRLI 	= 6,
		func_SRA 	= 7,
		func_OR  	= 8,
		func_AND 	= 9,
		func_B      	=10;

    
    //Clock Generation - rd and mem clk are triggered when needed
    wire clk_div;
    frequency_divider_by2 CD(clk_div,clk); //2 cycles to complete one instruction
    
    assign pc_clk = clk_div ;
    assign insn_clk = ~clk_div;

//INCOMPLETE
endmodule
    