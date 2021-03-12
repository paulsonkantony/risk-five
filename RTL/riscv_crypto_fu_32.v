module riscv_crypto_fu (rs1, rs2, instruction, rd);

input [31:0] rs1   ; // Source register 1
input [31:0] rs2   ; // Source register 2

input [19:0] instruction;

wire op_saes32_encs ,op_saes32_encsm,op_saes32_decs,op_saes32_decsm,
        op_ssha256_sig0,op_ssha256_sig1,op_ssha256_sum0,op_ssha256_sum1, 
        op_ssha512_sum0r, op_ssha512_sum1r ,op_ssha512_sig0l,op_ssha512_sig0h ,op_ssha512_sig1l,op_ssha512_sig1h ,
        op_ssm3_p0 ,op_ssm3_p1 , op_ssm4_ks ,op_ssm4_ed;

wire [1:0] imm;

output [31:0] rd;	

assign imm = instruction[19:18];

assign op_saes32_encs   = instruction[17]; // AES Encrypt SBox
assign op_saes32_encsm  = instruction[16]; // AES Encrypt SBox + MixCols
assign op_saes32_decs   = instruction[15]; // AES Decrypt SBox
assign op_saes32_decsm  = instruction[14]; // AES Decrypt SBox + MixCols
assign op_ssha256_sig0  = instruction[13]; // SHA256 Sigma 0
assign op_ssha256_sig1  = instruction[12]; // SHA256 Sigma 1
assign op_ssha256_sum0  = instruction[11]; // SHA256 Sum 0
assign op_ssha256_sum1  = instruction[10]; // SHA256 Sum 1
assign op_ssha512_sum0r = instruction[9]; // SHA512 Sum 0
assign op_ssha512_sum1r = instruction[8]; // SHA512 Sum 1
assign op_ssha512_sig0l = instruction[7]; // SHA512 Sigma 0 low
assign op_ssha512_sig0h = instruction[6]; // SHA512 Sigma 0 high
assign op_ssha512_sig1l = instruction[5]; // SHA512 Sigma 1 low
assign op_ssha512_sig1h = instruction[4]; // SHA512 Sigma 1 high
assign op_ssm3_p0       = instruction[3]; // SSM3 P0
assign op_ssm3_p1       = instruction[2]; // SSM3 P1
assign op_ssm4_ks       = instruction[1]; // SSM4 KeySchedule
assign op_ssm4_ed       = instruction[0]; // SSM4 Encrypt/Decrypt

//
// Local/internal parameters and useful defines:
// ------------------------------------------------------------

`define GATE_INPUTS(LEN,SEL,SIG) ({LEN{SEL}} & SIG[LEN-1:0])

//
// SHA256 Instructions
// ------------------------------------------------------------

wire        ssha256_valid ;
wire [31:0] ssha256_rs1   ;
wire [31:0] ssha256_result;

assign ssha256_rs1   = `GATE_INPUTS(32,ssha256_valid, rs1);
assign ssha256_valid = op_ssha256_sig0 || op_ssha256_sig1 || op_ssha256_sum0 || op_ssha256_sum1 ;

    riscv_crypto_fu_ssha256 i_riscv_crypto_fu_ssha256(
        .rs1            (ssha256_rs1     ), // Source register 1. 32-bits.
        .op_ssha256_sig0(op_ssha256_sig0 ), // SHA256 Sigma 0
        .op_ssha256_sig1(op_ssha256_sig1 ), // SHA256 Sigma 1
        .op_ssha256_sum0(op_ssha256_sum0 ), // SHA256 Sum 0
        .op_ssha256_sum1(op_ssha256_sum1 ), // SHA256 Sum 1
        .rd             (ssha256_result  )  // Result
    );


//
// SHA512 Instructions
// ------------------------------------------------------------

wire        ssha512_valid ;
wire [31:0] ssha512_rs1, ssha512_rs2, ssha512_result ;

assign ssha512_rs1 = `GATE_INPUTS(32, ssha512_valid, rs1) ;
assign ssha512_rs2 = `GATE_INPUTS(32, ssha512_valid, rs2) ;

assign ssha512_valid = op_ssha512_sum0r || op_ssha512_sum1r ||
                               op_ssha512_sig0l || op_ssha512_sig0h ||
                               op_ssha512_sig1l || op_ssha512_sig1h ;

    riscv_crypto_fu_ssha512 i_riscv_crypto_fu_ssha512 (
        .rs1             (ssha512_rs1     ), // Source register 1. 32-bits.
        .rs2             (ssha512_rs2     ), // Source register 2. 32-bits.
        .op_ssha512_sum0r(op_ssha512_sum0r), // RV32 SHA512 Sum 0
        .op_ssha512_sum1r(op_ssha512_sum1r), // RV32 SHA512 Sum 1
        .op_ssha512_sig0l(op_ssha512_sig0l), // RV32 SHA512 Sigma 0 low
        .op_ssha512_sig0h(op_ssha512_sig0h), // RV32 SHA512 Sigma 0 high
        .op_ssha512_sig1l(op_ssha512_sig1l), // RV32 SHA512 Sigma 1 low
        .op_ssha512_sig1h(op_ssha512_sig1h), // RV32 SHA512 Sigma 1 high
        .rd              (ssha512_result  )  // Result
    );


//
// SM3 instructions:
// ------------------------------------------------------------

wire        ssm3_valid ;
wire [31:0] ssm3_rs1, ssm3_result ;

assign ssm3_rs1     = `GATE_INPUTS(32, ssm3_valid, rs1);

assign ssm3_valid   = op_ssm3_p0 || op_ssm3_p1 ;

    riscv_crypto_fu_ssm3 i_riscv_crypto_fu_ssm3(
        .rs1        (ssm3_rs1     ), // Source register 1. 32-bits.
        .op_ssm3_p0 (op_ssm3_p0   ), // SSM3 P0
        .op_ssm3_p1 (op_ssm3_p1   ), // SSM3 P1
        .rd         (ssm3_result  )  // Result
    );

//
// SSM4 Instructions
// ------------------------------------------------------------

wire        ssm4_valid    ;

wire [1:0]  ssm4_bs;
wire [31:0] ssm4_result, ssm4_rs1, ssm4_rs2;

assign ssm4_rs1 = `GATE_INPUTS(32, ssm4_valid, rs1);
assign ssm4_rs2 = `GATE_INPUTS(32, ssm4_valid, rs2);
assign ssm4_bs  = imm;

assign ssm4_valid = op_ssm4_ks || op_ssm4_ed;

    riscv_crypto_fu_ssm4 i_riscv_crypto_fu_ssm4 (
        .rs1       (ssm4_rs1    ), // Source register 1
        .rs2       (ssm4_rs2    ), // Source register 2
        .bs        (ssm4_bs     ), // Byte select
        .op_ssm4_ks(op_ssm4_ks  ), // Do ssm4.ks instruction
        .op_ssm4_ed(op_ssm4_ed  ), // Do ssm4.ed instruction
        .result    (ssm4_result ) // Writeback result
    );

// AES 32-bit instructions
// ------------------------------------------------------------

wire        saes32_valid    ;

wire [ 1:0] saes32_bs;
wire [31:0] saes32_result, saes32_rs1, saes32_rs2;

assign saes32_rs1 = `GATE_INPUTS(32, saes32_valid, rs1);
assign saes32_rs2 = `GATE_INPUTS(32, saes32_valid, rs2);
assign saes32_bs  = imm ;

assign saes32_valid = op_saes32_encs  || op_saes32_encsm ||
                              op_saes32_decs  || op_saes32_decsm ;

    riscv_crypto_fu_saes32 i_riscv_crypto_fu_aes32 (
        .rs1            (saes32_rs1     ), // Source register 1
        .rs2            (saes32_rs2     ), // Source register 2
        .bs             (saes32_bs      ), // Byte select immediate
        .op_saes32_encs (op_saes32_encs ), // Encrypt SubBytes
        .op_saes32_encsm(op_saes32_encsm), // Encrypt SubBytes + MixColumn
        .op_saes32_decs (op_saes32_decs ), // Decrypt SubBytes
        .op_saes32_decsm(op_saes32_decsm), // Decrypt SubBytes + MixColumn
        .rd             (saes32_result  ) // output register value
    );


//
// Result multiplexing.
// ------------------------------------------------------------

assign rd   =
    {32{ssha256_valid     }} & ssha256_result     |
    {32{ssha512_valid     }} & ssha512_result     |
    {32{saes32_valid      }} & saes32_result      |
    {32{ssm3_valid        }} & ssm3_result        |
    {32{ssm4_valid        }} & ssm4_result        ;


//
// Clean up macro definitions
// ------------------------------------------------------------

`undef GATE_INPUTS 

endmodule