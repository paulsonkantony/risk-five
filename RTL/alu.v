module alu(alu_out, eq, a_lt_b, a_lt_ub, func, A, B);
	
	input [3:0] func;
	//input [4:0] shamt; //Use external direct shamt or take from the MUX? - From MUX - Less arguments but have to contract B though
	//input sub_sra;
	input [31:0] A;
	input [31:0] B;
	output reg [31:0] alu_out;
	output eq, a_lt_b, a_lt_ub;

    	//Don't send sub_sra => Compute function from control fsm
	//wire [4:0] func_op
	//assign func_op = {sub_sra, func};
	
	parameter func_ADD  	= 0, 
		  func_SUB 	= 1,  
		  func_SLLI 	= 2,
		  func_SLT  	= 3,
		  func_SLTU 	= 4,
		  func_XOR 	= 5,
		  func_SRLI 	= 6,
		  func_SRA 	= 7,
		  func_OR  	= 8,
		  func_AND 	= 9,
		  func_B      	=10;

	wire [4:0] shamt = B[4:0];
	
	assign eq = A==B;
	assign a_lt_b = $signed(A) < $signed(B);
	assign a_lt_ub = A<B;

	always @ *
	begin
		case(func)
			func_ADD:  alu_out = A + B;               // Add B to A and place the result into alu_out
			func_SUB:  alu_out = A - B;               // Subtract B from A and place the result into alu_out
			func_SLLI: alu_out = A << shamt;		  // shoft A left by the by the lower 5 bits in B and place the result into alu_out
			func_SLT:  alu_out = $signed(A) < $signed(B) ? {{32-1{1'b0}},1'b1} : 0;	// Set alu_out to 1 if A is less than B, otherwise set alu_out to 0 (signed)
			func_SLTU: alu_out = A < B ? {{32-1{1'b0}},1'b1} : 0;			  // Set alu_out to 1 if A is less than B, otherwise set alu_out to 0 (unsigned)
			func_XOR:  alu_out = A ^ B;               // Set alu_out to the bitwise XOR of A and B
			func_SRLI: alu_out = A >> shamt;		  // shift A right by the by the lower 5 bits in B and place the result into alu_out
			func_SRA:  alu_out = $signed(A) >>> shamt;// shift A right by the by the lower 5 bits in B and place the result into alu_out while retaining the sign
			func_OR:   alu_out = A | B;               // Set alu_out to the bitwise OR of A and B
			func_AND:  alu_out = A & B;               // Set alu_out to the bitwise AND of A and B
			func_B:	   alu_out = B;					  // Select B
			default:   alu_out = 0;
		endcase		
	end


endmodule
