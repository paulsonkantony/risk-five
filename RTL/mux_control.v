module mux_control(mux_a_sel_out, mux_b_sel_out, alu_func_out, rd_sel_out, reg_we_out,
     is_scalar_crypto_out, is_bitmanip_out, crypto_instruction_out, bitmanip_instruction_out, sha3_instruction_out,
	 mem_we_out, mem_re_out, sx_size_out, sysi_o_out,
	 mux_a_sel_in, mux_b_sel_in, alu_func_in, rd_sel_in, reg_we_in,
     is_scalar_crypto_in, is_bitmanip_in, crypto_instruction_in, bitmanip_instruction_in, sha3_instruction_in,
	 mem_we_in, mem_re_in, sx_size_in, sysi_o_in, sel);
	
	input sel;
    
    output is_scalar_crypto_out;
    output is_bitmanip_out;

    output [22:0] bitmanip_instruction_out;
    output [19:0] crypto_instruction_out;
    output [9:0] sha3_instruction_out;

    output sysi_o_out;

    output [3:0] alu_func_out;
    output [2:0] sx_size_out;
    output [1:0] rd_sel_out;
    output mux_a_sel_out, mux_b_sel_out, reg_we_out, mem_we_out, mem_re_out;

    input is_scalar_crypto_in;
    input is_bitmanip_in;

    input [22:0] bitmanip_instruction_in;
    input [19:0] crypto_instruction_in;
    input [9:0] sha3_instruction_in;

    input sysi_o_in;

    input [3:0] alu_func_in;
    input [2:0] sx_size_in;
    input [1:0] rd_sel_in;
    input mux_a_sel_in, mux_b_sel_in, reg_we_in, mem_we_in, mem_re_in;

    assign bitmanip_instruction_out = sel ? 0 : bitmanip_instruction_in;
    assign crypto_instruction_out = sel ? 0 : crypto_instruction_in;
    assign sha3_instruction_out = sel ? 0 : sha3_instruction_in;
    assign alu_func_out = sel ? 0 : alu_func_in;
    assign sx_size_out = sel ? 0 : sx_size_in;
    assign rd_sel_out = sel ? 0 : rd_sel_in;

    assign sysi_o_out = sel ? 0 : sysi_o_in;
	assign is_scalar_crypto_out = sel ? 0 : is_scalar_crypto_in;
	assign is_bitmanip_out = sel ? 0 : is_bitmanip_in;

	assign mux_a_sel_out = sel ? 0 : mux_a_sel_in;
	assign mux_b_sel_out = sel ? 0 : mux_b_sel_in;
	assign reg_we_out = sel ? 0 : reg_we_in;
	assign mem_we_out = sel ? 0 : mem_we_in;
	assign mem_re_out = sel ? 0 : mem_re_in;

endmodule