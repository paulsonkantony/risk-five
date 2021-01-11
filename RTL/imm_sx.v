module imm_sx(imm_x, insn);
	input [31:0] insn;
	output [31:0] imm_x; //To assign in always block - reg

	wire [4:0] opcode = insn[6:2];

	parameter lui 		= 5'b01101,
			auipc 		= 5'b00101,
			jal 		= 5'b11011,
			jalr 		= 5'b11001,
			btype 		= 5'b11000,
			load_itype	= 5'b00000,
			stype 		= 5'b01000,
			op_itype	= 5'b00100; //last two bits are always 11

	parameter OPCODE_U_LUI 	= 5'b01101,
     		OPCODE_U_AUIPC 	= 5'b00101,
     		OPCODE_J_JAL 	= 5'b11011,
     		OPCODE_I_JALR	= 5'b11001,
     		OPCODE_B_BRANCH = 5'b11000,
     		OPCODE_I_LOAD 	= 5'b00000,
     		OPCODE_S_STORE 	= 5'b01000,  
     		OPCODE_I_IMM 	= 5'b00100;
     		//OPCODE_R_ALU 	= 5'b01100,
            //OPCODE_I_SYSTEM = 5'b11100;

    assign lui_o        = (opcode==OPCODE_U_LUI);
    assign auipc_o      = (opcode==OPCODE_U_AUIPC);
    assign jal_o        = (opcode==OPCODE_J_JAL);
    assign jalr_o       = (opcode==OPCODE_I_JALR);
    assign branch_o     = (opcode==OPCODE_B_BRANCH);
    assign load_o       = (opcode==OPCODE_I_LOAD);
    assign store_o      = (opcode==OPCODE_S_STORE);
    assign imm_o        = (opcode==OPCODE_I_IMM);
    //assign alu_o        = (opcode==OPCODE_R_ALU);
    //assign sysi_o       = (opcode==OPCODE_I_SYSTEM);	

    assign imm_x = (lui_o|auipc_o) 		? {insn[31:12], {12{1'b0}}} :   
                   branch_o	 			? {{19{insn[31]}}, insn[31], insn[7],insn[30:25],insn[11:8], 1'b0} :
                   (jalr_o|load_o|imm_o)? {{20{insn[31]}}, insn[31:20]} :
                   jal_o 				? {{11{insn[31]}}, insn[31], insn[19:12], insn[20], insn[30:21], 1'b0} :   
                   store_o 				? {{20{insn[31]}}, insn[31:25], insn[11:7]} :
                   32'b0;


endmodule
