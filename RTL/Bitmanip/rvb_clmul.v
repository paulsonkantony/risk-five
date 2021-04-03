module rvb_clmul (
	// control signals
	input         clock,          // positive edge clock
	input         reset,          // synchronous reset
	
	// data input
	output        din_ready,      // core accepts input
	input  [31:0] din_rs1,        // value of 1st argument
	input  [31:0] din_rs2,        // value of 2nd argument
	input         op_clmul,
	input         op_clmulh,
	
	// data output
	output        dout_valid,     // output is valid
	output [31:0] dout_rd,         // output value
	output 		  busy_out,
	output [3:0]  state_out
);
	// 13 12  3   Function
	// --------   --------
	//  0  1  0   CLMUL
	//  1  0  0   CLMULR
	//  1  1  0   CLMULH


	reg busy;
	assign busy_out = busy;

	reg [3:0] state;
	assign state_out = state;
	
	reg [31:0] A, B, X;
	reg funct_h;

	wire [31:0] next_X = (X << 8) ^
			(B[31] ? A << 7 : 0) ^ (B[30] ? A << 6 : 0) ^
			(B[29] ? A << 5 : 0) ^ (B[28] ? A << 4 : 0) ^
			(B[27] ? A << 3 : 0) ^ (B[26] ? A << 2 : 0) ^
			(B[25] ? A << 1 : 0) ^ (B[24] ? A << 0 : 0);

	function [31:0] bitrev;
		input [31:0] in;
		integer i;
		begin
			for (i = 0; i < 32; i = i+1)
				bitrev[i] = in[31-i];
		end
	endfunction

	assign din_ready = (!busy || dout_valid) && reset && (op_clmulh || op_clmul);
	assign dout_valid = !state && busy && reset;

	reg [31:0] dout_rd_reg;
	assign dout_rd = dout_rd_reg;
	
	always @* begin
		dout_rd_reg = X;
		if (funct_h) begin
			dout_rd_reg = dout_rd_reg >> 1;
		end
	end

	always @(posedge clock or negedge reset) begin
		if (dout_valid) begin
			busy <= 0;
		end
		if (!state) begin
			if (din_ready) begin
				funct_h <= op_clmulh;
				A <= op_clmulh ? bitrev(din_rs1) : din_rs1;
				B <= op_clmulh ? bitrev(din_rs2) : din_rs2;
				busy <= 1;
				state <= 4;
			end
		end else begin
			X <= next_X;
			B <= B << 8;
			state <= state - 1;
		end
		if (!reset) begin
			busy <= 0;
			state <= 0;
		end
	end
endmodule