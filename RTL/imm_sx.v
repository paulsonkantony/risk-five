module imm_sx(imm_x, insn);
	input [31:0] insn;
	output reg[31:0] imm_x; //To assign in always block - reg

	wire [4:0] opcode = insn[6:2];

	parameter lui 		= 5'b01101,
			auipc 		= 5'b00101,
			jal 		= 5'b11011,
			jalr 		= 5'b11001,
			btype 		= 5'b11000,
			load_itype	= 5'b00000,
			stype 		= 5'b01000,
			op_itype	= 5'b00100; //last two bits are always 11

	always @(insn)
	begin
		case(opcode)
			lui , auipc: 			imm_x = {insn[31:12], {12{1'b0}}}; 
			btype: 				imm_x = {{19{insn[31]}}, insn[31], insn[7],insn[30:25],insn[11:8], 1'b0};
			jalr, load_itype, op_itype: 	imm_x = {{20{insn[31]}}, insn[31:20]};
			jal:				imm_x = {{11{insn[31]}}, insn[31], insn[19:12], insn[20], insn[30:21], 1'b0};
			stype: 				imm_x = {{20{insn[31]}}, insn[31:25], insn[11:7]};
			default: 			imm_x = 32'b0;
		endcase
	end
endmodule
