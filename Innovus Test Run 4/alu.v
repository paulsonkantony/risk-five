module alu(alu_out, eq, a_lt_b, a_lt_ub, func, A, B);
	
	input [3:0] func;
	input [31:0] A;
	input [31:0] B;
	output [31:0] alu_out; 
	output eq, a_lt_b, a_lt_ub;

	wire add_o, sub_o, sll_o, slt_o, sltu_o, xor_o, srl_o, sra_o, or_o, and_o, alu_jalr_o;
	
    parameter func_ADD  	= 4'b0000, 
		func_SUB 	= 4'b0001,  
		func_SLL	= 4'b0010,
		func_SLT  	= 4'b0011,
		func_SLTU 	= 4'b0100,
		func_XOR 	= 4'b0101,
		func_SRL 	= 4'b0110,
		func_SRA 	= 4'b0111,
		func_OR  	= 4'b1000,
		func_AND 	= 4'b1001,
		func_ADD_JALR =4'b1010;

	wire [4:0] shamt = B[4:0];
	
	assign eq = A==B;
	assign a_lt_b = $signed(A) < $signed(B);
	assign a_lt_ub = A<B;

    assign add_o = func==func_ADD;
    assign sub_o = func==func_SUB;
    assign sll_o = func==func_SLL;
    assign slt_o = func==func_SLT;
    assign sltu_o = func==func_SLTU;
    assign xor_o = func==func_XOR;
    assign srl_o = func==func_SRL;
    assign sra_o = func==func_SRA;
    assign or_o = func==func_OR;
    assign and_o = func==func_AND;
    assign alu_jalr_o = func==func_ADD_JALR;

	assign alu_out = add_o ? A + B :   
                	sub_o ? A - B :
                	sll_o ? A << shamt :
                	slt_o ? ($signed(A) < $signed(B) ? {{32-1{1'b0}},1'b1} : 0) :   
                	sltu_o ? (A < B ? {{32-1{1'b0}},1'b1} : 0) :
                	xor_o ? A ^ B :
                	srl_o ? A >> shamt :
                	sra_o ? $signed(A) >>> shamt:   
                	or_o ? A | B :
                	and_o ? A & B :
                	alu_jalr_o ? (A + B)& 32'hFFFFFFFE : 
                	32'b0;


endmodule