module hazard_det_unit(
	stall, 
	if_id_rs1, 
	if_id_rs2, 
	if_id_branch_o, 
	id_ex_reg_we, 
	id_ex_mem_re, 
	id_ex_rd, 
	ex_mem_mem_re,
	ex_mem_rd,
	if_id_jalr, 
	ID_is_crypto,
	ID_is_bitmanip,
	ID_sha3_instruction
	);

	input [4:0] if_id_rs1, if_id_rs2, id_ex_rd, ex_mem_rd;
	input id_ex_mem_re, id_ex_reg_we, if_id_branch_o, ex_mem_mem_re, if_id_jalr, ID_is_crypto, ID_is_bitmanip;
	input [9:0] ID_sha3_instruction;
	output stall;

	wire rd_is_zero      = id_ex_rd  == 0;
	wire rs1_from_memory = if_id_rs1 == id_ex_rd;
	wire rs2_from_memory = if_id_rs2 == id_ex_rd;

	wire ex_rd_is_zero   = rd_is_zero;
	wire mem_rd_is_zero  = ex_mem_rd == 0;
	wire rs1_from_ex  = rs1_from_memory;
	wire rs2_from_ex  = rs2_from_memory;
	wire rs1_from_mem = if_id_rs1 == ex_mem_rd;
	wire rs2_from_mem = if_id_rs2 == ex_mem_rd;

	wire sha3_acc = ID_is_crypto && ID_is_bitmanip && ID_sha3_instruction[8:7] == 2'b0;

	assign stall = ((id_ex_mem_re | ((if_id_branch_o | if_id_jalr | sha3_acc) && id_ex_reg_we)) && ~rd_is_zero && (rs1_from_memory | (rs2_from_memory && ~if_id_jalr))) | (((if_id_branch_o | if_id_jalr| sha3_acc) && ex_mem_mem_re) && ~mem_rd_is_zero && (rs1_from_mem | (rs2_from_mem && ~if_id_jalr))) ? 1'b0 :
				   1'b1 ;
/*
		assign stall = ((id_ex_mem_re | (if_id_branch_o && id_ex_reg_we)) && ~rd_is_zero && (rs1_from_memory | rs2_from_memory)) | ((if_id_branch_o && ex_mem_mem_re) && ~mem_rd_is_zero && (rs1_from_mem | rs2_from_mem)) ? 1'b0 :
				   1'b1 ;
*/


endmodule