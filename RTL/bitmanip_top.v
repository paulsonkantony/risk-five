module bitmanip_top (rd, rs1, rs2, instruction, clk, rst);

input clk, rst;

input [31:0] rs1 ; // Source register 1
input [31:0] rs2 ; // Source register 2

input [22:0] instruction;

wire op_clmul, op_clmulh, op_xperm_n, op_xperm_b, op_ror, op_rol, op_rori, op_andn, op_orn, op_xnor,
    op_pack, op_packu, op_packh, op_grevi, op_shfl, op_unshfl;

wire [31:0] imm;

output [31:0] rd;   

assign imm = {{25{1'b0}},instruction[22:16]};

assign op_clmul   = instruction[15];
assign op_clmulh  = instruction[14];
assign op_xperm_n = instruction[13];
assign op_xperm_b = instruction[12]; 
assign op_ror     = instruction[11];
assign op_rol     = instruction[10]; 
assign op_rori    = instruction[9];
assign op_andn    = instruction[8];
assign op_orn     = instruction[7]; 
assign op_xnor    = instruction[6]; 
assign op_pack    = instruction[5]; 
assign op_packu   = instruction[4]; 
assign op_packh   = instruction[3]; 
assign op_grevi   = instruction[2]; 
assign op_shfl    = instruction[1]; 
assign op_unshfl  = instruction[0]; 


//
// Local/internal parameters and useful defines:
// ------------------------------------------------------------

`define GATE_INPUTS(LEN,SEL,SIG) ({LEN{SEL}} & SIG[LEN-1:0])

`define ROR32(a,b) ((a >> b) | (a << 32-b))
`define ROL32(a,b) ((a << b) | (a >> 32-b))

//
// ROTATE LEFT/RIGHT
// ------------------------------------------------------------

wire [31:0] rotate_result;
wire [31:0] rotate_shamt;

wire rotate_valid;
assign rotate_valid = op_ror | op_rol | op_rori ;

assign rotate_shamt = (op_ror|op_rol)  ? (rs2 & 31) :
                      (op_rori)        ? (imm & 31) : 
                      0 ;

assign rotate_result = (op_ror|op_rori) ? `ROR32(rs1, rotate_shamt) :
                       (op_rol) ? `ROL32(rs1, rotate_shamt) :
                       0 ;


//
// NEGATED GATES
// ------------------------------------------------------------

wire [31:0] negated_result ;
wire negated_valid;

assign negated_valid = op_andn | op_orn | op_xnor ;

assign negated_result = op_andn ? rs1 & ~rs2 :
                       op_orn ? rs1 | ~rs2 :
                       op_xnor ? rs1 ^ ~rs2 :
                       0 ;


//
// PACK/ PACKU/ PACKH
// ------------------------------------------------------------

wire [31:0] pack_result ;

wire pack_valid;
assign pack_valid = op_pack | op_packu | op_packh ;

assign pack_result = op_pack ? {rs2[15:0], rs1[15:0]} :
		     op_packu ? {rs2[31:16], rs1[31:16]} :
                     op_packh ? {16'b0, rs2[7:0], rs1[7:0]} :
                     0 ;

//
// GREVI
// ------------------------------------------------------------

wire [31:0] grevi_result ;

wire grevi_valid;
assign grevi_valid = op_grevi ;

wire [31:0]  g1, g2, g3, g4, g5, g6; // Intermediate Signals

wire [4:0] grevi_shamt = grevi_valid ? imm[4:0] & 31 : 0 ;

assign g1 =  rs1 ;
assign g2 = (grevi_shamt & 1)  ? ((g1 & 32'h55555555) <<  1) | ((g1 & 32'hAAAAAAAA) >>  1) : g1 ;  
assign g3 = (grevi_shamt & 2)  ? ((g2 & 32'h33333333) <<  2) | ((g2 & 32'hCCCCCCCC) >>  2) : g2 ;
assign g4 = (grevi_shamt & 4)  ? ((g3 & 32'h0F0F0F0F) <<  4) | ((g3 & 32'hF0F0F0F0) >>  4) : g3 ;
assign g5 = (grevi_shamt & 8)  ? ((g4 & 32'h00FF00FF) <<  8) | ((g4 & 32'hFF00FF00) >>  8) : g4 ;
assign g6 = (grevi_shamt & 16) ? ((g5 & 32'h0000FFFF) << 16) | ((g5 & 32'hFFFF0000) >> 16) : g5 ;

assign grevi_result = g6 ;


//
// XPERM
// ------------------------------------------------------------

wire [31:0] xperm_result ;

wire xperm_valid;
assign xperm_valid = op_xperm_b | op_xperm_n ;

wire [31:0] xperm_rs1, xperm_rs2;

assign xperm_rs1 = `GATE_INPUTS(32, xperm_valid, rs1) ;
assign xperm_rs2 = `GATE_INPUTS(32, xperm_valid, rs2) ;

wire [31:0] res ;

rvb_xperm i_rvb_xperm(
  .xperm_valid(xperm_valid),
  .op_xperm_n(op_xperm_n), 
  .op_xperm_b(op_xperm_b),
  .rs1(xperm_rs1),
  .rs2(xperm_rs2),
  .res(res)
  );

assign xperm_result = res ;


//
// SHFL / UNSHFL
// ------------------------------------------------------------


wire [31:0] shfl_result ; //ZIP/UNZIP 

wire shfl_valid;
assign shfl_valid = op_shfl | op_unshfl ; //ZIP/UNZIP

// function [31:0] shuffle32_stage;
//     input [31:0] src, maskL, maskR, N ;
//     reg [31:0] temp; //Local Variable
//     begin
//         temp = src & ~(maskL | maskR);
//         shuffle32_stage = temp | ((src << N) & maskL) | ((src >> N) & maskR);
//     end
// endfunction 

// wire [31:0] s1, s2, s3, s4, s5; //Intermediate Results
// wire [3:0] shfl_shamt;

// assign s1 = rs1 ;

// assign s2 = (shfl_shamt & 8 & op_shfl)      ? shuffle32_stage(s1, 32'h00ff0000, 32'h0000ff00, 8) : 
//             (shfl_shamt & 1 & op_unshfl)    ? shuffle32_stage(s1, 32'h44444444, 32'h22222222, 1) : 
//             s1 ;  

// assign s3 = (shfl_shamt & 4 & op_shfl)      ? shuffle32_stage(s2, 32'h0f000f00, 32'h00f000f0, 4) : 
//             (shfl_shamt & 2 & op_unshfl)    ? shuffle32_stage(s2, 32'h30303030, 32'h0c0c0c0c, 2) : 
//             s2 ;

// assign s4 = (shfl_shamt & 2 & op_shfl)      ? shuffle32_stage(s3, 32'h30303030, 32'h0c0c0c0c, 2) : 
//             (shfl_shamt & 4 & op_unshfl)    ? shuffle32_stage(s3, 32'h0f000f00, 32'h00f000f0, 4) : 
//             s3 ;

// assign s5 = (shfl_shamt & 1 & op_shfl)      ? shuffle32_stage(s4, 32'h44444444, 32'h22222222, 1) : 
//             (shfl_shamt & 8 & op_unshfl)    ? shuffle32_stage(s4, 32'h00ff0000, 32'h0000ff00, 8) : 
//             s4 ;

// assign shfl_result = s5 ;

assign shfl_result = op_shfl ? {rs1[31] ,rs1[15] ,rs1[30] ,rs1[14] ,rs1[29] ,rs1[13] ,rs1[28] ,rs1[12] ,rs1[27] ,rs1[11] ,rs1[26] ,rs1[10] ,rs1[25] ,rs1[9] ,rs1[24] ,rs1[8] ,rs1[23] ,rs1[7] ,rs1[22] ,rs1[6] ,rs1[21] ,rs1[5] ,rs1[20] ,rs1[4] ,rs1[19] ,rs1[3] ,rs1[18] ,rs1[2] ,rs1[17] ,rs1[1] ,rs1[16] ,rs1[0]} :
                     {rs1[31] ,rs1[29] ,rs1[27] ,rs1[25] ,rs1[23] ,rs1[21] ,rs1[19] ,rs1[17] ,rs1[15] ,rs1[13] ,rs1[11] ,rs1[9] ,rs1[7] ,rs1[5] ,rs1[3] ,rs1[1] ,rs1[30] ,rs1[28] ,rs1[26] ,rs1[24] ,rs1[22] ,rs1[20] ,rs1[18] ,rs1[16] ,rs1[14] ,rs1[12] ,rs1[10] ,rs1[8] ,rs1[6] ,rs1[4] ,rs1[2] ,rs1[0]} ;


//
// CLMUL/ CLMULH
// ------------------------------------------------------------


wire clmul_valid ;
wire [31:0] clmul_rs1 , clmul_rs2, clmul_result ;

assign clmul_rs1 = `GATE_INPUTS(32, clmul_valid, rs1) ;
assign clmul_rs2 = `GATE_INPUTS(32, clmul_valid, rs2) ;

assign clmul_valid = op_clmul | op_clmulh ;

rvb_clmul i_rvb_clmul (

    // data input
    .clmul_valid(clmul_valid),
    .op_clmul(op_clmul),
    .op_clmulh(op_clmulh),
    .rs1(clmul_rs1),           // value of 1st argument
    .rs2(clmul_rs2),           // value of 2nd argument
    
    // data output
    .rd(clmul_result)       // output value
);


//
// Result multiplexing.
// ------------------------------------------------------------

assign rd   =
    {32{rotate_valid    }} & rotate_result  |
    {32{negated_valid   }} & negated_result |
    {32{pack_valid      }} & pack_result    |
    {32{grevi_valid     }} & grevi_result   |
    {32{xperm_valid     }} & xperm_result   |
    {32{shfl_valid      }} & shfl_result    |
    {32{clmul_valid     }} & clmul_result   ;


//
// Clean up macro definitions
// ------------------------------------------------------------

`undef GATE_INPUTS 
`undef ROR32
`undef ROL32

endmodule