module riscv_crypto_fu_ssha256 (rs1, op_ssha256_sig0, op_ssha256_sig1, op_ssha256_sum0, op_ssha256_sum1, rd);

input [31:0] rs1      ; // Source register 1. Low 32 bits.

input op_ssha256_sig0 ; // SHA256 Sigma 0
input op_ssha256_sig1 ; // SHA256 Sigma 1
input op_ssha256_sum0 ; // SHA256 Sum 0
input op_ssha256_sum1 ; // SHA256 Sum 1

output [31:0] rd ; // Result.

wire [31:0] ssha256_sig0, ssha256_sig1, ssha256_sum0, ssha256_sum1;

//
// Local/internal parameters and useful defines:
// ------------------------------------------------------------

`define ROR32(a,b) ((a >> b) | (a << 32-b))
`define SRL32(a,b) ((a >> b)              )

//
// Instruction logic
// ------------------------------------------------------------

// Single cycle instructions.

assign ssha256_sig0 = `ROR32(rs1, 7) ^ `ROR32(rs1,18) ^ `SRL32(rs1, 3);

assign ssha256_sig1 = `ROR32(rs1,17) ^ `ROR32(rs1,19) ^ `SRL32(rs1,10);

assign ssha256_sum0 = `ROR32(rs1, 2) ^ `ROR32(rs1,13) ^ `ROR32(rs1,22);

assign ssha256_sum1 = `ROR32(rs1, 6) ^ `ROR32(rs1,11) ^ `ROR32(rs1,25);

assign rd=
    {32{op_ssha256_sig0}} & ssha256_sig0    |
    {32{op_ssha256_sig1}} & ssha256_sig1    |
    {32{op_ssha256_sum0}} & ssha256_sum0    |
    {32{op_ssha256_sum1}} & ssha256_sum1    ;

//
// Clean up macro definitions
// ------------------------------------------------------------

`undef ROR32
`undef SRL32

endmodule
