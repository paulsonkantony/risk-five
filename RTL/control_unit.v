module control_unit
	(imm_val, rs1, rs2, rd, mux_a_sel, mux_b_sel, alu_func, rd_sel, reg_we,
     is_scalar_crypto, is_bitmanip, crypto_instruction, bitmanip_instruction, sha3_instruction,
	 mem_we, mem_re, sx_size, sysi_o, fn3, jal_o, jalr_o, branch_o,
     instruction, clk, rst);

    input [31:0] instruction;
    input clk, rst;

    wire func7;
    wire [6:0] opcode;
    wire [2:0] func3;

    output [31:0] imm_val;
    output [4:0] rs1, rs2, rd;

    output [7:0] fn3;
    
    output is_scalar_crypto;
    output is_bitmanip;

    output [22:0] bitmanip_instruction;
    output [19:0] crypto_instruction;
    output [9:0] sha3_instruction;

    output sysi_o;

    output [3:0] alu_func;
    output [2:0] sx_size;
    output [1:0] rd_sel;
    output mux_a_sel, mux_b_sel, reg_we, mem_we, mem_re;

    output jal_o, jalr_o, branch_o;

    wire fn3_0_o, fn3_1_o, fn3_2_o, fn3_3_o, fn3_4_o, fn3_5_o, fn3_6_o, fn3_7_o;
    wire lui_o, auipc_o, jal_o, jalr_o, branch_o, store_o, imm_o, alu_o, load_o;
    //wire eq_o, neq_o, lt_o, ltu_o, ge_o, geu_o;
    wire add_o, sub_o, sll_o, slt_o, sltu_o, xor_o, srl_o, sra_o, or_o, and_o, alu_jalr_o;
    wire mem_byte, mem_half, mem_word, mem_byte_u, mem_half_u;
    wire reg_we_temp;

    wire scalar_crypto_op, scalar_crypto_op_imm, is_scalar_crypto_hash, is_scalar_crypto_block;

    wire scalar_crypto_sm3, scalar_crypto_sha256, scalar_crypto_sha512, scalar_crypto_sha512_high, scalar_crypto_sha512_low,
         scalar_crypto_aes, scalar_crypto_sm4;

    wire op_saes32_encs ,op_saes32_encsm,op_saes32_decs,op_saes32_decsm,
         op_ssha256_sig0,op_ssha256_sig1,op_ssha256_sum0,op_ssha256_sum1, 
         op_ssha512_sum0r, op_ssha512_sum1r ,op_ssha512_sig0l,op_ssha512_sig0h ,op_ssha512_sig1l,op_ssha512_sig1h ,
         op_ssm3_p0 ,op_ssm3_p1 , op_ssm4_ks ,op_ssm4_ed;
         //op_lut4lo, op_lut4hi;

    wire op_clmul, op_clmulh, op_xperm_n, op_xperm_b, op_ror, op_rol, op_rori, op_andn, op_orn, op_xnor,
         op_pack, op_packu, op_packh, op_grevi, op_shfl, op_unshfl;

    
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd  = instruction[11:7];

    assign func7 = instruction[30];
    assign func3 = instruction[14:12];
    assign opcode = instruction[6:0];

	//Opcodes

	parameter OPCODE_U_LUI 	= 7'b0110111,
     		OPCODE_U_AUIPC 	= 7'b0010111,
     		OPCODE_J_JAL 	= 7'b1101111,
     		OPCODE_I_JALR	= 7'b1100111,
     		OPCODE_B_BRANCH = 7'b1100011,
     		OPCODE_I_LOAD 	= 7'b0000011,
     		OPCODE_S_STORE 	= 7'b0100011,  
     		OPCODE_I_IMM 	= 7'b0010011,
     		OPCODE_R_ALU 	= 7'b0110011,
            OPCODE_I_SYSTEM = 7'b1110011,
            OPCODE_I_FENCE  = 7'b0001111,
            OPCODE_C_SHA3   = 7'b1111111;

    assign lui_o    = (opcode==OPCODE_U_LUI);
    assign auipc_o  = (opcode==OPCODE_U_AUIPC);
    assign jal_o    = (opcode==OPCODE_J_JAL);
    assign jalr_o   = (opcode==OPCODE_I_JALR);
    assign branch_o = (opcode==OPCODE_B_BRANCH);
    assign load_o   = (opcode==OPCODE_I_LOAD);
    assign store_o  = (opcode==OPCODE_S_STORE);
    assign imm_o    = (opcode==OPCODE_I_IMM);
    assign alu_o    = (opcode==OPCODE_R_ALU);
    assign sysi_o   = (opcode==OPCODE_I_SYSTEM) || (opcode==OPCODE_I_FENCE);


    //imm_sx gen_imm(.imm_x(imm_val), .insn(instruction));
    assign imm_val  = (lui_o|auipc_o)      ? {instruction[31:12], {12{1'b0}}} :   
                      branch_o             ? {{19{instruction[31]}}, instruction[31], instruction[7],instruction[30:25],instruction[11:8], 1'b0} :
                      (jalr_o|load_o|imm_o)? {{20{instruction[31]}}, instruction[31:20]} :
                      jal_o                ? {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0} :   
                      store_o              ? {{20{instruction[31]}}, instruction[31:25], instruction[11:7]} :
                      32'b0;

 
    assign fn3_0_o = func3 == 3'b000;
    assign fn3_1_o = func3 == 3'b001;
    assign fn3_2_o = func3 == 3'b010;
    assign fn3_3_o = func3 == 3'b011;
    assign fn3_4_o = func3 == 3'b100;
    assign fn3_5_o = func3 == 3'b101;
    assign fn3_6_o = func3 == 3'b110;
    assign fn3_7_o = func3 == 3'b111;

    assign fn3 = {fn3_7_o, fn3_6_o, fn3_5_o, fn3_4_o, fn3_3_o, fn3_2_o, fn3_1_o, fn3_0_o};

    assign add_o      = jal_o|auipc_o|branch_o|load_o|store_o|(alu_o&fn3_0_o&!func7)|(imm_o&fn3_0_o); //ADD, ADDI
    assign sub_o      = (alu_o&fn3_0_o&func7);                            //SUB
    assign sll_o      = (alu_o&fn3_1_o)|(imm_o&fn3_1_o);                  //SLL, SLLI
    assign slt_o      = (alu_o&fn3_2_o)|(imm_o&fn3_2_o);                  //SLT, SLTI
    assign sltu_o     = (alu_o&fn3_3_o)|(imm_o&fn3_3_o);                  //SLTU, SLTIU
    assign xor_o      = (alu_o&fn3_4_o)|(imm_o&fn3_4_o);                  //XOR, XORI
    assign srl_o      = (alu_o&fn3_5_o&!func7)|(imm_o&fn3_5_o&!func7);    //SRL, SRLI
    assign sra_o      = (alu_o&fn3_5_o&func7)|(imm_o&fn3_5_o&func7);      //SRA, SRAI
    assign or_o       = (alu_o&fn3_6_o)|(imm_o&fn3_6_o);                  //OR, ORI
    assign and_o      = (alu_o&fn3_7_o)|(imm_o&fn3_7_o);                  //AND, ANDI
    assign alu_jalr_o = jalr_o; //Add and then trim

    assign mem_byte   = (load_o&fn3_0_o)|(store_o&fn3_0_o); 
    assign mem_half   = (load_o&fn3_1_o)|(store_o&fn3_1_o);  
    assign mem_word   = (load_o&fn3_2_o)|(store_o&fn3_2_o); 
    assign mem_byte_u = (load_o&fn3_4_o);  
    assign mem_half_u = (load_o&fn3_5_o); 

    // ALU FUNC values 		
    parameter func_ADD = 4'b0000, 
		func_SUB 	  = 4'b0001,  
		func_SLL 	  = 4'b0010,
		func_SLT  	  = 4'b0011,
		func_SLTU 	  = 4'b0100,
		func_XOR 	  = 4'b0101,
		func_SRL	  = 4'b0110,
		func_SRA 	  = 4'b0111,
		func_OR  	  = 4'b1000,
		func_AND 	  = 4'b1001,
		func_ADD_JALR = 4'b1010;

    parameter bit8  = 3'b000,
        bit_u8  = 3'b001,
        bit16   = 3'b010,
        bit_u16 = 3'b011,
        bit32   = 3'b100;

/*
    assign invalid_opcode = !(eq_o|neq_o|lt_o|ltu_o|ge_o|geu_o|
            add_o|sub_o|sll_o|slt_o|sltu_o|xor_o|srl_o|sra_o|or_o|and_o|alu_jalr_o|lui_o| 
            mem_byte|mem_half|mem_word|mem_byte_u|mem_half_u|
            op_saes32_encs|op_saes32_encsm|op_saes32_decs|op_saes32_decsm|
            op_ssha256_sig0|op_ssha256_sig1|op_ssha256_sum0|op_ssha256_sum1| 
            op_ssha512_sum0r|op_ssha512_sum1r|op_ssha512_sig0l|op_ssha512_sig0h|op_ssha512_sig1l|op_ssha512_sig1h|
            op_ssm3_p0|op_ssm3_p1|  
            op_ssm4_ks|op_ssm4_ed)
*/

    wire sha3_op = (opcode==OPCODE_C_SHA3);

    //MUX Selects
    assign mux_a_sel = (lui_o|auipc_o)? 1 : 0; 
    assign mux_b_sel = (lui_o|auipc_o|load_o|store_o|imm_o)? 1 : 0; 
    
    assign reg_we_temp = (lui_o|auipc_o|jal_o|jalr_o|alu_o|imm_o|load_o| sha3_op)? 1 : 0; 
    assign reg_we = reg_we_temp & |rd & rst; //Disable if rd=0
    
    assign mem_we = store_o;
    assign mem_re = load_o;

    assign rd_sel = (load_o)  ? 2'b11 : 
                    (lui_o)         ? 2'b01 :
                    (jalr_o|jal_o)  ? 2'b10 :   
                    2'b00;
    
    assign sx_size = mem_byte ? bit8 :   
                     mem_half ? bit16 :
                     mem_word ? bit32 :
                     mem_byte_u ? bit_u8 :   
                     mem_half_u ? bit_u16 :
                     3'b0;                        //Memory Formatting

    assign alu_func = (add_o)  ? func_ADD :   
                      (sub_o)  ? func_SUB :
                      (sll_o)  ? func_SLL :
                      (slt_o)  ? func_SLT :   
                      (sltu_o) ? func_SLTU :
                      (xor_o)  ? func_XOR :
                      (srl_o)  ? func_SRL :
                      (sra_o)  ? func_SRA :
                      (or_o)   ? func_OR :
                      (and_o)  ? func_AND :
                      4'b0; 


    //SHA3

    wire sha3_acc  = sha3_op && fn3_0_o;
    wire sha3_ror  = sha3_op && fn3_1_o;
    wire sha3_dmpl = sha3_op && fn3_2_o;
    wire sha3_dmph = sha3_op && fn3_3_o;

    wire [1:0] sha3_func = sha3_dmph   ? 2'b11 :
                           sha3_dmpl   ? 2'b10 :
                           sha3_ror    ? 2'b01 :
                           2'b00;

    assign sha3_instruction = {sha3_op, sha3_func, instruction[31:25]};

    //RISCV Crypto

    assign scalar_crypto_op_imm = imm_o & fn3_1_o & instruction[28] & ~(|({instruction[31:29],instruction[27:25]}));
    assign scalar_crypto_op     = alu_o & fn3_0_o & instruction[28] &  (|({instruction[31:29],instruction[27:25]}));
    assign is_scalar_crypto     = scalar_crypto_op | scalar_crypto_op_imm | sha3_op;

    assign is_scalar_crypto_hash = ~instruction[29];
    assign is_scalar_crypto_block = instruction[29];


    assign scalar_crypto_sm3 = instruction[24:22] == 3'b010;
    assign scalar_crypto_sha256 = instruction[24:22] == 3'b000;
    assign scalar_crypto_sha512 = instruction[31:30] == 2'b01;
    assign scalar_crypto_sha512_high = instruction[27];
    assign scalar_crypto_sha512_low  = ~instruction[27];
    
    assign scalar_crypto_sm4 = ~instruction[25];
    assign scalar_crypto_aes = instruction[25];


    assign op_ssm3_p0       = scalar_crypto_op_imm & scalar_crypto_sm3 & instruction[21:20] == 2'b00;// & is_scalar_crypto_hash; //      SSM3 P0
    assign op_ssm3_p1       = scalar_crypto_op_imm & scalar_crypto_sm3 & instruction[21:20] == 2'b01;// & is_scalar_crypto_hash; //      SSM3 P1    

    assign op_ssha256_sum0  = scalar_crypto_op_imm & scalar_crypto_sha256 & instruction[21:20] == 2'b00;// & is_scalar_crypto_hash; //      SHA256 Sum 0
    assign op_ssha256_sum1  = scalar_crypto_op_imm & scalar_crypto_sha256 & instruction[21:20] == 2'b01;// & is_scalar_crypto_hash; //      SHA256 Sum 1
    assign op_ssha256_sig0  = scalar_crypto_op_imm & scalar_crypto_sha256 & instruction[21:20] == 2'b10;// & is_scalar_crypto_hash; //      SHA256 Sigma 0
    assign op_ssha256_sig1  = scalar_crypto_op_imm & scalar_crypto_sha256 & instruction[21:20] == 2'b11;// & is_scalar_crypto_hash; //      SHA256 Sigma 1

    assign op_ssha512_sum0r = scalar_crypto_op & scalar_crypto_sha512 & scalar_crypto_sha512_low  & instruction[26:25] == 2'b00 & is_scalar_crypto_hash; // RV32 SHA512 Sum 0
    assign op_ssha512_sum1r = scalar_crypto_op & scalar_crypto_sha512 & scalar_crypto_sha512_low  & instruction[26:25] == 2'b01 & is_scalar_crypto_hash; // RV32 SHA512 Sum 1
    assign op_ssha512_sig0l = scalar_crypto_op & scalar_crypto_sha512 & scalar_crypto_sha512_low  & instruction[26:25] == 2'b10 & is_scalar_crypto_hash; // RV32 SHA512 Sigma 0 low
    assign op_ssha512_sig0h = scalar_crypto_op & scalar_crypto_sha512 & scalar_crypto_sha512_high & instruction[26:25] == 2'b10 & is_scalar_crypto_hash; // RV32 SHA512 Sigma 0 high
    assign op_ssha512_sig1l = scalar_crypto_op & scalar_crypto_sha512 & scalar_crypto_sha512_low  & instruction[26:25] == 2'b11 & is_scalar_crypto_hash; // RV32 SHA512 Sigma 1 low
    assign op_ssha512_sig1h = scalar_crypto_op & scalar_crypto_sha512 & scalar_crypto_sha512_high & instruction[26:25] == 2'b11 & is_scalar_crypto_hash; // RV32 SHA512 Sigma 1 high

    assign op_saes32_encs   = scalar_crypto_op & is_scalar_crypto_block & scalar_crypto_aes & instruction[27:26] == 2'b01; // RV32 AES Encrypt SBox
    assign op_saes32_encsm  = scalar_crypto_op & is_scalar_crypto_block & scalar_crypto_aes & instruction[27:26] == 2'b00; // RV32 AES Encrypt SBox + MixCols
    assign op_saes32_decs   = scalar_crypto_op & is_scalar_crypto_block & scalar_crypto_aes & instruction[27:26] == 2'b11; // RV32 AES Decrypt SBox
    assign op_saes32_decsm  = scalar_crypto_op & is_scalar_crypto_block & scalar_crypto_aes & instruction[27:26] == 2'b10; // RV32 AES Decrypt SBox + MixCols

    assign op_ssm4_ks       = scalar_crypto_op & is_scalar_crypto_block & scalar_crypto_sm4 & instruction[27:26] == 2'b00; //      SSM4 KeySchedule
    assign op_ssm4_ed       = scalar_crypto_op & is_scalar_crypto_block & scalar_crypto_sm4 & instruction[27:26] == 2'b01; //      SSM4 Encrypt/Decrypt

    wire [1:0] bs;
    
    assign bs = instruction[31:30];

/*
     
    parameter func_saes32_encs = 5'b00000, 
        func_saes32_encsm = 5'b00001,  
        func_saes32_decs  = 5'b00010,
        func_saes32_decsm = 5'b00011,
        func_sha256_sig0  = 5'b00100,
        func_sha256_sig1  = 5'b00101,
        func_sha256_sum0  = 5'b00110,
        func_sha256_sum1  = 5'b00111,
        func_sha512_sum0r = 5'b01000,
        func_sha512_sum1r = 5'b01001,
        func_sha512_sig0l = 5'b01010;
        func_sha512_sig0h = 5'b01011;
        func_sha512_sig1l = 5'b01100;
        func_sha512_sig1h = 5'b01101;
        func_ssm3_p0      = 5'b01110;
        func_ssm3_p1      = 5'b01111;
        func_ssm4_ks      = 5'b10000;
        func_ssm4_ed      = 5'b10001;

*/

    assign crypto_instruction = {
     bs, op_saes32_encs ,op_saes32_encsm,op_saes32_decs,op_saes32_decsm,
     op_ssha256_sig0,op_ssha256_sig1,op_ssha256_sum0,op_ssha256_sum1, 
     op_ssha512_sum0r, op_ssha512_sum1r ,op_ssha512_sig0l,op_ssha512_sig0h ,op_ssha512_sig1l,op_ssha512_sig1h ,
     op_ssm3_p0, op_ssm3_p1,  
     op_ssm4_ks, op_ssm4_ed
    };

//RISC-V Crypto - Bitmanip

    wire zip_unzip = instruction[31:20] == 12'b000010001111;
  
    assign op_clmul     = (alu_o&fn3_1_o) & instruction[27] & instruction[25];
    assign op_clmulh    = (alu_o&fn3_3_o) & instruction[27] & instruction[25];
    assign op_xperm_n   = (alu_o&fn3_2_o) & instruction[29] & instruction[27];
    assign op_xperm_b   = (alu_o&fn3_4_o) & instruction[29] & instruction[27];
    assign op_ror       = (alu_o&fn3_5_o) & instruction[30] & instruction[29];
    assign op_rol       = (alu_o&fn3_1_o) & instruction[30] & instruction[29];
    assign op_rori      = (imm_o&fn3_5_o) & instruction[30] & instruction[29] & ~instruction[27];
    assign op_andn      = (alu_o&fn3_7_o) & instruction[30] ;
    assign op_orn       = (alu_o&fn3_6_o) & instruction[30] ;
    assign op_xnor      = (alu_o&fn3_4_o) & instruction[30] & ~instruction[27] ;
    assign op_pack      = (alu_o&fn3_4_o) & instruction[27] & ~instruction[30];
    assign op_packu     = (alu_o&fn3_4_o) & instruction[30] & instruction[27]; 
    assign op_packh     = (alu_o&fn3_7_o) & instruction[27] ;
    assign op_grevi     = (imm_o&fn3_5_o) & instruction[30] & instruction[29] & instruction[27];
    assign op_shfl      = (imm_o&fn3_1_o) & instruction[27] & zip_unzip ;
    assign op_unshfl    = (imm_o&fn3_5_o) & instruction[27] & zip_unzip;

    assign is_bitmanip = op_clmul | op_clmul | op_clmulh | op_xperm_n | op_xperm_b | 
        op_ror | op_rol | op_rori | op_andn | op_orn | op_xnor | op_pack | op_packu | 
        op_packh | op_grevi | op_shfl | op_unshfl | sha3_op;

    wire [6:0] bitmanip_imm;
    assign bitmanip_imm = instruction[26:20]; 

    assign bitmanip_instruction = {
    bitmanip_imm, 
    op_clmul, 
    op_clmulh, 
    op_xperm_n, 
    op_xperm_b, 
    op_ror, 
    op_rol, 
    op_rori, 
    op_andn, 
    op_orn, 
    op_xnor,
    op_pack, 
    op_packu, 
    op_packh, 
    op_grevi, 
    op_shfl, 
    op_unshfl
    };

    
endmodule