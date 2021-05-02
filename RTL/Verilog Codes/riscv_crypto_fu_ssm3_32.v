module riscv_crypto_fu_ssm3 (rs1, op_ssm3_p0, op_ssm3_p1, rd);

input [31:0] rs1 ; // Source register 1. Low 32 bits.

input op_ssm3_p0 ; // SSM3 P0
input op_ssm3_p1 ; // SSM3 P1

output [31:0] rd ; // Result.

//
// Local/internal parameters and useful defines:
// ------------------------------------------------------------

`define ROL32(a,b) ((a << b) | (a >> 32-b))

//
// Instruction logic
// ------------------------------------------------------------

// Single cycle instructions.

wire [31:0] ssm3_p0, ssm3_p1; 

assign ssm3_p0 = rs1 ^ `ROL32(rs1,  9) ^ `ROL32(rs1,17);

assign ssm3_p1 = rs1 ^ `ROL32(rs1, 15) ^ `ROL32(rs1,23);

assign rd =
    {32{op_ssm3_p0}} & ssm3_p0    |
    {32{op_ssm3_p1}} & ssm3_p1    ;

//
// Clean up macro definitions
// ------------------------------------------------------------

`undef ROL32

endmodule

