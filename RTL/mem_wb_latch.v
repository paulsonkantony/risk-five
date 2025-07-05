module mem_wb_latch(

	 imm_x_out,
	 pc_out,
	 alu_out,
	 data_mem_out,

	 rd_sel_out, reg_we_out,
	 sysi_o_out,

	 rd_out,

	 imm_x_in,
	 pc_in,
	 alu_in,
	 data_mem_in,
	 
	 rd_sel_in, reg_we_in,
     sysi_o_in,

     rd_in, 
	 
	 clk, rst, en);

	input clk, rst, en;

	input [31:0] imm_x_in, pc_in, alu_in, data_mem_in;
    input sysi_o_in;
    input [1:0] rd_sel_in;
    input reg_we_in;
    input [4:0] rd_in;

    output reg [31:0] imm_x_out, pc_out, alu_out, data_mem_out;
    output reg sysi_o_out;
    output reg [1:0] rd_sel_out;
    output reg reg_we_out;
    output reg [4:0] rd_out;

	always @(posedge clk)
	begin
		if (!rst) // Active Low Reset

			begin
				pc_out       <= 32'b0;
				imm_x_out    <= 32'b0;
				alu_out      <= 32'b0;
				data_mem_out <= 32'b0;

				sysi_o_out <= 1'b0;
				rd_sel_out <= 2'b0;

				reg_we_out <= 1'b0;
				rd_out <= 5'b0;
			end
		
		else if (en)

			begin
				pc_out       <= pc_in;
				alu_out      <= alu_in;
				imm_x_out    <= imm_x_in;
				data_mem_out <= data_mem_in;

				sysi_o_out <= sysi_o_in;
				rd_sel_out <= rd_sel_in;

				reg_we_out <= reg_we_in;

				rd_out <= rd_in;
			end
	end

endmodule