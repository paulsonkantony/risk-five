module ex_mem_latch(

	 imm_x_out,
	 pc_out,
	 alu_out,
	 rs2_val_out,

	 rd_sel_out, reg_we_out,
	 mem_we_out, mem_re_out, sx_size_out, sysi_o_out,

	 rd_in,
	 rs2_in,

	 imm_x_in,
	 pc_in,
	 alu_in,
	 rs2_val_in,
	 
	 rd_sel_in, reg_we_in,
     mem_we_in, mem_re_in, sx_size_in, sysi_o_in, 

     rd_out,
     rs2_out,
	 
	 clk, rst, en);

	input clk, rst, en;

	input [31:0] imm_x_in, pc_in, alu_in, rs2_val_in;

    input sysi_o_in;

    input [2:0] sx_size_in;
    input [1:0] rd_sel_in;
    input reg_we_in, mem_we_in, mem_re_in;

    input [4:0] rd_in, rs2_in;

    output reg [31:0] imm_x_out, pc_out, alu_out, rs2_val_out;
    
    output reg sysi_o_out;

    output reg [2:0] sx_size_out;
    output reg [1:0] rd_sel_out;
    output reg reg_we_out, mem_we_out, mem_re_out;

    output reg [4:0] rd_out, rs2_out;

	always @(posedge clk)
	begin
		if (!rst) // Active Low Reset

			begin
				pc_out   <= 32'b0;
				imm_x_out <= 32'b0;
				alu_out <= 32'b0;
				rs2_val_out <= 32'b0;

				sysi_o_out <= 1'b0;

				sx_size_out <= 3'b0;
				rd_sel_out <= 2'b0;

				reg_we_out <= 1'b0;
				mem_we_out <= 1'b0;
				mem_re_out <= 1'b0;

				rd_out <= 5'b0;
				rs2_out <= 5'b0;
			end
		
		else if (en)

			begin
				pc_out   <= pc_in;
				alu_out <= alu_in;
				imm_x_out <= imm_x_in;
				rs2_val_out <= rs2_val_in;

				sysi_o_out <= sysi_o_in;

				sx_size_out <= sx_size_in;
				rd_sel_out <= rd_sel_in;

				reg_we_out <= reg_we_in;
				mem_we_out <= mem_we_in;
				mem_re_out <= mem_re_in;

				rd_out <= rd_in;
				rs2_out <= rs2_in;

			end
	end


endmodule