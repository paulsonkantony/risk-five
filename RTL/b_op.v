module b_op(pc_next_sel, rs1_val, rs2_val, jal, jal_r, branch_o, fn3, reset);

	input [31:0] rs1_val, rs2_val;
	input [7:0] fn3;
	input jal, jal_r, branch_o;
	input reset;

	wire eq, a_lt_b, a_lt_ub, eq_o, neq_o, lt_o, ge_o, ltu_o, geu_o;

	wire fn3_0_o, fn3_1_o, fn3_4_o, fn3_5_o, fn3_6_o, fn3_7_o;
	// wire fn3_2_o, fn3_3_o;

	assign fn3_0_o = fn3[0];
	assign fn3_1_o = fn3[1];
	// assign fn3_2_o = fn3[2];
	// assign fn3_3_o = fn3[3];
	assign fn3_4_o = fn3[4];
	assign fn3_5_o = fn3[5];
	assign fn3_6_o = fn3[6];
	assign fn3_7_o = fn3[7];

	output pc_next_sel;

    assign eq      = rs1_val == rs2_val;
    assign a_lt_b  = $signed(rs1_val) < $signed(rs2_val);
    assign a_lt_ub = rs1_val < rs2_val;

    assign eq_o     = branch_o & fn3_0_o & eq ;
    assign neq_o    = branch_o & fn3_1_o & (!eq);
    assign lt_o     = branch_o & fn3_4_o & a_lt_b;
    assign ge_o     = branch_o & fn3_5_o & (!a_lt_b);
    assign ltu_o    = branch_o & fn3_6_o & a_lt_ub;
    assign geu_o    = branch_o & fn3_7_o & (!a_lt_ub);

	assign pc_next_sel = (eq_o | neq_o | lt_o | ge_o | ltu_o | geu_o | jal | jal_r) & reset ;

endmodule