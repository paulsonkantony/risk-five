module riscv_crypto_fu_ssha512 (rs1, rs2,
op_ssha512_sum0r, op_ssha512_sum1r, op_ssha512_sig0l, op_ssha512_sig0h, op_ssha512_sig1l, op_ssha512_sig1h, rd);

input [31:0] rs1; // Source register 1.
input [31:0] rs2; // Source register 1.

input op_ssha512_sum0r; // RV32 SHA512 Sum 0
input op_ssha512_sum1r; // RV32 SHA512 Sum 1
input op_ssha512_sig0l; // RV32 SHA512 Sigma 0 low
input op_ssha512_sig0h; // RV32 SHA512 Sigma 0 high
input op_ssha512_sig1l; // RV32 SHA512 Sigma 1 low
input op_ssha512_sig1h; // RV32 SHA512 Sigma 1 high

output [31:0] rd;                // Result.

wire [31:0] ssha512_sum0r, ssha512_sum1r, ssha512_sig0l, ssha512_sig0h, ssha512_sig1l, ssha512_sig1h;

//
// Local/internal parameters and useful defines:
// ------------------------------------------------------------

`define ROR32(a,b) ((a >> b) | (a << 32-b))
`define SRL32(a,b) ((a >> b)              )
`define SLL32(a,b) ((a << b)              )

//
// Instruction logic
// ------------------------------------------------------------

// Single cycle instructions.
assign ssha512_sum0r = `SLL32(rs1,25)^`SLL32(rs1,30)^`SRL32(rs1,28)^
                                `SLL32(rs2, 7)^`SLL32(rs2, 2)^`SLL32(rs2,24);
    
assign ssha512_sum1r = `SLL32(rs1,23)^`SLL32(rs1,14)^`SRL32(rs1,18)^
                                `SLL32(rs2, 9)^`SLL32(rs2,18)^`SLL32(rs2,14);
    
assign ssha512_sig0l = `SRL32(rs1, 1)^`SRL32(rs1, 7)^`SRL32(rs1, 8)^
                                `SLL32(rs2,31)^`SLL32(rs2,25)^`SLL32(rs2,24);
    
assign ssha512_sig0h = `SRL32(rs1, 1)^`SRL32(rs1, 7)^`SRL32(rs1, 8)^
                                `SLL32(rs2,31)               ^`SLL32(rs2,24);
    
assign ssha512_sig1l = `SRL32(rs1, 3)^`SRL32(rs1, 6)^`SRL32(rs1,19)^
                                `SLL32(rs2,29)^`SLL32(rs2,26)^`SLL32(rs2,13);
    
assign ssha512_sig1h = `SRL32(rs1, 3)^`SRL32(rs1, 6)^`SRL32(rs1,19)^
                                `SLL32(rs2,29)               ^`SLL32(rs2,13);

assign rd =
        {32{op_ssha512_sig0l}} & ssha512_sig0l   |
        {32{op_ssha512_sig0h}} & ssha512_sig0h   |
        {32{op_ssha512_sig1l}} & ssha512_sig1l   |
        {32{op_ssha512_sig1h}} & ssha512_sig1h   |
        {32{op_ssha512_sum0r}} & ssha512_sum0r   |
        {32{op_ssha512_sum1r}} & ssha512_sum1r   ;
        

//
// Clean up macro definitions
// ------------------------------------------------------------

`undef ROR32
`undef SRL32
`undef SLL32


endmodule
