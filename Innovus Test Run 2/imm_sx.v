module imm_sx(imm_x, insn);
	input [31:0] insn;
	output [31:0] imm_x;

	wire [6:0] opcode = insn[6:0];

	parameter OPCODE_U_LUI 	= 7'b0110111,
     		OPCODE_U_AUIPC 	= 7'b0010111,
     		OPCODE_J_JAL 	= 7'b1101111,
     		OPCODE_I_JALR	= 7'b1100111,
     		OPCODE_B_BRANCH = 7'b1100011,
     		OPCODE_I_LOAD 	= 7'b0000011,
     		OPCODE_S_STORE 	= 7'b0100011,  
     		OPCODE_I_IMM 	= 7'b0010011;
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
