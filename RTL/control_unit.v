module control_unit
	(imm_val, rs1, rs2, rd, mux_a_sel, mux_b_sel, alu_func, rd_sel, reg_we, pc_add_sel, pc_next_sel, 
	 mem_we, sx_size, load_o, EQ, a_lt_b, a_lt_ub, instruction, clk, rst, delayed_load, delayed_rd );

	input EQ, a_lt_b, a_lt_ub;
    input [31:0] instruction;
    input clk, rst;

    input delayed_load;
    input [4:0] delayed_rd;
	
    wire func7;
    wire [4:0] opcode;
    wire [2:0] func3;

    output [31:0] imm_val;
    output [4:0] rs1, rs2, rd;


    wire fn3_0_o, fn3_1_o, fn3_2_o, fn3_3_o, fn3_4_o, fn3_5_o, fn3_6_o, fn3_7_o;
    output load_o;
    wire lui_o, auipc_o, jal_o, jalr_o, branch_o, store_o, imm_o, alu_o, sysi_o;
    wire eq_o, neq_o, lt_o, ltu_o, ge_o, geu_o;
    wire add_o, sub_o, sll_o, slt_o, sltu_o, xor_o, srl_o, sra_o, or_o, and_o, alu_jalr_o;
    wire mem_byte, mem_half, mem_word, mem_byte_u, mem_half_u;
    wire reg_we_temp;

	output [3:0] alu_func;
	output reg [2:0] sx_size;
	output [1:0] rd_sel, pc_next_sel;
	output mux_a_sel, mux_b_sel, pc_add_sel, reg_we, mem_we;

    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd = delayed_load? delayed_rd : instruction[11:7];

    assign func7 = instruction[30];
    assign func3 = instruction[14:12];
    assign opcode = instruction[6:2];

    imm_sx gen_imm(.imm_x(imm_val), .insn(instruction));

	//Opcodes

	parameter OPCODE_U_LUI 	= 5'b01101,
     		OPCODE_U_AUIPC 	= 5'b00101,
     		OPCODE_J_JAL 	= 5'b11011,
     		OPCODE_I_JALR	= 5'b11001,
     		OPCODE_B_BRANCH = 5'b11000,
     		OPCODE_I_LOAD 	= 5'b00000,
     		OPCODE_S_STORE 	= 5'b01000,  
     		OPCODE_I_IMM 	= 5'b00100,
     		OPCODE_R_ALU 	= 5'b01100,
            OPCODE_I_SYSTEM = 5'b11100;

    assign lui_o    = (opcode==OPCODE_U_LUI);
    assign auipc_o  = (opcode==OPCODE_U_AUIPC);
    assign jal_o    = (opcode==OPCODE_J_JAL);
    assign jalr_o   = (opcode==OPCODE_I_JALR);
    assign branch_o = (opcode==OPCODE_B_BRANCH);
    assign load_o   = (opcode==OPCODE_I_LOAD);
    assign store_o  = (opcode==OPCODE_S_STORE);
    assign imm_o    = (opcode==OPCODE_I_IMM);
    assign alu_o    = (opcode==OPCODE_R_ALU);
    assign sysi_o   = (opcode==OPCODE_I_SYSTEM);

 
    /*func3
    parameter FUNCT3_JARL = 3'b000;

    //  B_BRANCH
    parameter FUNCT3_BEQ 	 = 3'b000,
     		FUNCT3_BNE 	 = 3'b001,
     		FUNCT3_BLT 	 = 3'b100,
     		FUNCT3_BGE 	 = 3'b101,
     		FUNCT3_BLTU 	 = 3'b110,
     		FUNCT3_BGEU 	 = 3'b111;

    // I_LOAD
    parameter FUNCT3_LB 	= 3'b000,
     		FUNCT3_LH 	= 3'b001,
     		FUNCT3_LW 	= 3'b010,
     		FUNCT3_LBU 	= 3'b100,
     		FUNCT3_LHU 	= 3'b101;

    //  S_STORES
    parameter FUNCT3_SB = 3'b000,
     		FUNCT3_SH 	= 3'b001,
     		FUNCT3_SW 	= 3'b010;

    //  I_IMM
    parameter FUNCT3_ADDI	 = 3'b000,
     		FUNCT3_SLTI 	 = 3'b010,
     		FUNCT3_SLTIU 	 = 3'b011,
     		FUNCT3_XORI 	 = 3'b100,
     		FUNCT3_ORI 	     = 3'b110,
     		FUNCT3_ANDI 	 = 3'b111,
     		FUNCT3_SLLI 	 = 3'b001,
     		FUNCT3_SRLI_SRAI = 3'b101;

    //  R_ALU
    parameter FUNCT3_ADD_SUB = 3'b000,
     		FUNCT3_SLL   	 = 3'b001,
     		FUNCT3_SLT 	     = 3'b010,
     		FUNCT3_SLTU 	 = 3'b011,
     		FUNCT3_XOR 	     = 3'b100,
     		FUNCT3_SRL_SRA 	 = 3'b101,
     		FUNCT3_OR 	     = 3'b110,
     		FUNCT3_AND 	     = 3'b111; */

    assign fn3_0_o = func3 == 3'b000;
    assign fn3_1_o = func3 == 3'b001;
    assign fn3_2_o = func3 == 3'b010;
    assign fn3_3_o = func3 == 3'b011;
    assign fn3_4_o = func3 == 3'b100;
    assign fn3_5_o = func3 == 3'b101;
    assign fn3_6_o = func3 == 3'b110;
    assign fn3_7_o = func3 == 3'b111;

    assign eq_o     = branch_o & fn3_0_o & EQ ;
    assign neq_o    = branch_o & fn3_1_o & (!EQ);
    assign lt_o     = branch_o & fn3_4_o & a_lt_b;
    assign ge_o     = branch_o & fn3_5_o & (!a_lt_b);
    assign ltu_o    = branch_o & fn3_6_o & a_lt_ub;
    assign geu_o    = branch_o & fn3_7_o & (!a_lt_ub);

    assign add_o    = jal_o|auipc_o|branch_o|load_o|store_o|(alu_o&fn3_0_o&!func7)|(imm_o&fn3_0_o);
    assign sub_o    = (alu_o&fn3_0_o&func7);
    assign sll_o    = (alu_o&fn3_1_o)|(imm_o&fn3_1_o);
    assign slt_o    = (alu_o&fn3_2_o)|(imm_o&fn3_2_o);
    assign sltu_o   = (alu_o&fn3_3_o)|(imm_o&fn3_3_o); 
    assign xor_o    = (alu_o&fn3_4_o)|(imm_o&fn3_4_o);  
    assign srl_o    = (alu_o&fn3_5_o&!func7)|(imm_o&fn3_5_o&!func7);
    assign sra_o    = (alu_o&fn3_5_o&func7)|(imm_o&fn3_5_o&func7);
    assign or_o     = (alu_o&fn3_6_o)|(imm_o&fn3_7_o);
    assign and_o    = (alu_o&fn3_6_o)|(imm_o&fn3_7_o);
    assign alu_jalr_o = jalr_o; //Add and then trim

    assign mem_byte = (load_o&fn3_0_o)|(store_o&fn3_0_o); 
    assign mem_half = (load_o&fn3_1_o)|(store_o&fn3_1_o);  
    assign mem_word = (load_o&fn3_2_o)|(store_o&fn3_2_o); 
    assign mem_byte_u = (load_o&fn3_4_o);  
    assign mem_half_u = (load_o&fn3_5_o); 

    // ALU FUNC values 		
    parameter func_ADD  	= 4'b0000, 
		func_SUB 	= 4'b0001,  
		func_SLL 	= 4'b0010,
		func_SLT  	= 4'b0011,
		func_SLTU 	= 4'b0100,
		func_XOR 	= 4'b0101,
		func_SRL	= 4'b0110,
		func_SRA 	= 4'b0111,
		func_OR  	= 4'b1000,
		func_AND 	= 4'b1001,
		func_ADD_JALR =4'b1010;

    parameter bit8  = 3'b000,
        bit_u8  = 3'b001,
        bit16   = 3'b010,
        bit_u16 = 3'b011,
        bit32   = 3'b100;

    //reg [31:0] nop_stall = 32'b00000000000000000000000000010011; // no operation signal which is equivalent to addi x0, x0, 0
    //assign nop_o = instruction==NOP;

    //MUX Selects
    assign mux_a_sel = (jal_o|lui_o|auipc_o|branch_o)? 1 : 0; 
    assign mux_b_sel = (lui_o|auipc_o|jal_o|jalr_o|branch_o|load_o|store_o|imm_o)? 1 : 0; 
    
    assign pc_next_sel = (sysi_o) ? 2'b10 :
                         (jalr_o) ? 2'b01 : 
                         2'b0;
                         //All CSR, EBREAK and ECALL goes to one interrupt. Resets PC.
    
    assign pc_add_sel = (jal_o|eq_o|neq_o|lt_o|ltu_o|ge_o|geu_o)? 1 : 0;
    
    assign reg_we_temp = (lui_o|auipc_o|jal_o|jalr_o|alu_o|imm_o|delayed_load)? 1 : 0; 
    assign reg_we = reg_we_temp & |rd & rst; //Disable if rd=0
    
    assign mem_we = store_o;

    assign rd_sel = (delayed_load)  ? 2'b11 : 
                    (lui_o)         ? 2'b01 :
                    (jalr_o|jal_o)  ? 2'b10 :   
                    2'b0;
    
    always @(posedge load_o or posedge store_o)
        begin
            sx_size =  mem_byte ? bit8 :   
                       mem_half ? bit16 :
                       mem_word ? bit32 :
                       mem_byte_u ? bit_u8 :   
                       mem_half_u ? bit_u16 :
                       3'b0;                        //Memory Formatting
        end


    assign alu_func =   (add_o)     ? func_ADD :   
                        (sub_o)     ? func_SUB :
                        (sll_o)     ? func_SLL :
                        (slt_o)     ? func_SLT :   
                        (sltu_o)    ? func_SLTU :
                        (xor_o)     ? func_XOR :
                        (srl_o)     ? func_SRL :
                        (sra_o)     ? func_SRA :
                        (or_o)      ? func_OR :
                        (and_o)     ? func_AND :
                        (jalr_o)    ? func_ADD_JALR :
                        4'b0; 


//INCOMPLETE
endmodule
    