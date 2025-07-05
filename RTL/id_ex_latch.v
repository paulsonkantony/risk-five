module id_ex_latch(

	 rs1_val_out, rs2_val_out,
	 imm_x_out,
	 rs1_out, rs2_out, rd_out,
	 pc_out,

	 mux_a_sel_out, mux_b_sel_out, alu_func_out, rd_sel_out, reg_we_out,
     is_scalar_crypto_out, is_bitmanip_out, crypto_instruction_out, bitmanip_instruction_out, sha3_instruction_out,
	 mem_we_out, mem_re_out, sx_size_out, sysi_o_out,

	 rs1_val_in, rs2_val_in,
	 imm_x_in,
	 rs1_in, rs2_in, rd_in,
	 pc_in,
	 
	 mux_a_sel_in, mux_b_sel_in, alu_func_in, rd_sel_in, reg_we_in,
     is_scalar_crypto_in, is_bitmanip_in, crypto_instruction_in, bitmanip_instruction_in, sha3_instruction_in,
	 mem_we_in, mem_re_in, sx_size_in, sysi_o_in, 
	 
	 clk, rst, en);

	input clk, rst, en;

	input [31:0] rs1_val_in, rs2_val_in, imm_x_in, pc_in;
    input [4:0]  rs1_in, rs2_in, rd_in;

	input is_scalar_crypto_in;
    input is_bitmanip_in;

    input [22:0] bitmanip_instruction_in;
    input [19:0] crypto_instruction_in;
    input [9:0]  sha3_instruction_in;

    input sysi_o_in;

    input [3:0] alu_func_in;
    input [2:0] sx_size_in;
    input [1:0] rd_sel_in;
    input mux_a_sel_in, mux_b_sel_in, reg_we_in, mem_we_in, mem_re_in;

    output reg [31:0] rs1_val_out, rs2_val_out, imm_x_out, pc_out;
    output reg [4:0]  rs1_out, rs2_out, rd_out;
	
	output reg is_scalar_crypto_out;
    output reg is_bitmanip_out;

    output reg [22:0] bitmanip_instruction_out;
    output reg [19:0] crypto_instruction_out;
    output reg [9:0]  sha3_instruction_out;

    output reg sysi_o_out;

    output reg [3:0] alu_func_out;
    output reg [2:0] sx_size_out;
    output reg [1:0] rd_sel_out;
    output reg mux_a_sel_out, mux_b_sel_out, reg_we_out, mem_we_out, mem_re_out;

	always @(posedge clk)
	begin
		if (!rst) // Active Low Reset

			begin
				pc_out   <= 32'b0;
				rs1_val_out <= 32'b0;
				rs2_val_out <= 32'b0;
				imm_x_out <= 32'b0;

				rs1_out <= 5'b0;
				rs2_out <= 5'b0;
				rd_out <= 5'b0;

				is_scalar_crypto_out <= 1'b0;
				is_bitmanip_out <= 1'b0;

				bitmanip_instruction_out <= 23'b0;
				crypto_instruction_out <= 20'b0;
				sha3_instruction_out <= 9'b0;

				sysi_o_out <= 1'b0;

				alu_func_out <= 4'b0;
				sx_size_out <= 3'b0;
				rd_sel_out <= 2'b0;

				mux_a_sel_out <= 1'b0;
				mux_b_sel_out <= 1'b0;
				reg_we_out <= 1'b0;
				mem_we_out <= 1'b0;
				mem_re_out <= 1'b0;
			end
		
		else if (en)

			begin
				pc_out   <= pc_in;
				rs1_val_out <= rs1_val_in;
				rs2_val_out <= rs2_val_in;
				imm_x_out <= imm_x_in;

				rs1_out <= rs1_in;
				rs2_out <= rs2_in;
				rd_out <= rd_in;

				is_scalar_crypto_out <= is_scalar_crypto_in;
				is_bitmanip_out <= is_bitmanip_in;

				bitmanip_instruction_out <= bitmanip_instruction_in;
				crypto_instruction_out <= crypto_instruction_in;
				sha3_instruction_out <= sha3_instruction_in;

				sysi_o_out <= sysi_o_in;

				alu_func_out <= alu_func_in;
				sx_size_out <= sx_size_in;
				rd_sel_out <= rd_sel_in;

				mux_a_sel_out <= mux_a_sel_in;
				mux_b_sel_out <= mux_b_sel_in;
				reg_we_out <= reg_we_in;
				mem_we_out <= mem_we_in;
				mem_re_out <= mem_re_in;
			end
	end

endmodule