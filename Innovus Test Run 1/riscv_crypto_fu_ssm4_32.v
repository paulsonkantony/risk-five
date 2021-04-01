module riscv_crypto_fu_ssm4 (rs1, rs2, bs, op_ssm4_ks, op_ssm4_ed, result);

input [31:0] rs1 ; // Source register 1
input [31:0] rs2 ; // Source register 2
input [ 1:0] bs  ; // Byte select

input op_ssm4_ks ; // Do ssm4.ks instruction
input op_ssm4_ed ; // Do ssm4.ed instruction

output [31:0] result; // Writeback result


// Always finish in a single cycle.

//
// SBOX Byte select
// ------------------------------------------------------------

wire [7:0] in_bytes [3:0];
wire [7:0] sbox_in, sbox_out;
wire [31:0] l;

assign in_bytes[0]  = rs2[ 7: 0];
assign in_bytes[1]  = rs2[15: 8];
assign in_bytes[2]  = rs2[23:16];
assign in_bytes[3]  = rs2[31:24];

assign sbox_in = in_bytes[bs];

assign l       = {24'b0, sbox_out};

//
// ED Instruction
// ------------------------------------------------------------

wire [31:0] l_ed1, l_ed2;

assign l_ed1   = l     ^  (l << 8) ^ (l << 2) ^  (l << 18);
assign l_ed2   = l_ed1 ^ ((l     & 32'h3F) << 26) ^
                              ((l     & 32'hC0) << 10) ;

//
// KS Instruction
// ------------------------------------------------------------

wire [31:0] l_ks1, l_ks2;

assign l_ks1   = l     ^ ((l & 32'h7) << 29) ^ ((l & 32'hFE) << 7);
assign l_ks2   = l_ks1 ^ ((l     & 32'h01) << 23) ^
                              ((l     & 32'hF8) << 13) ;

//
// Rotate and XOR result
// ------------------------------------------------------------

wire [31:0] rot_in, rot_out;

assign rot_in = op_ssm4_ks ? l_ks2 : l_ed2;

assign rot_out =
    {32{bs == 2'b00}} & {rot_in                      } |
    {32{bs == 2'b01}} & {rot_in[23:0], rot_in[31:24] } |
    {32{bs == 2'b10}} & {rot_in[15:0], rot_in[31:16] } |
    {32{bs == 2'b11}} & {rot_in[ 7:0], rot_in[31: 8] } ;

assign result = rot_out ^ rs1 ;

//
// Submodule - SBox
riscv_crypto_sm4_sbox i_sm4_sbox (
    .in (sbox_in ),
    .out(sbox_out)
);

endmodule
