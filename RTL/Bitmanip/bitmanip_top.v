module bitmanip_top (rs1, rs2, instruction, rd, clk, rst);

input [31:0] rs1 ; // Source register 1
input [31:0] rs2 ; // Source register 2

input [21:0] instruction;

wire op_clmul, op_clmulh, op_xperm_n, op_xperm_b, op_ror, op_rol, op_rori, op_andn, op_orn, op_xnor,
    op_pack, op_packu, op_packh, op_grevi, op_shfl, op_unshfl;

wire [5:0] imm;

output [31:0] rd;	

assign imm = instruction[21:16];

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

wire [31:0] rotate_result ;
wire [4:0] shamt;

wire rotate_valid;
assign rotate_valid = op_ror | op_rol | op_rori ;

assign rotate_shamt = (op_ror|op_rol)  ? (rs2 & 31) :
                      (op_rori)        ? (imm & 31) : 
                      0 ;

assign rotate_result = (op_ror|op_rori) ? ROR32(rs1, rotate_shamt) :
                       (op_rol) ? ROL32(rs1, rotate_shamt) :
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

wire [31:0] lower, upper;

wire pack_valid;
assign pack_valid = op_pack | op_packu | op_packh ;

assign lower = op_packu ? {16'bx, rs1[31:16]} :
               rs1 ;  

assign upper = op_packu ? {16'bx, rs2[31:16]} :
               rs2

assign pack_result = op_pack | op_packu ? {upper[15:0], lower[15:0]} :
                     op_packh ? {16'b0, rs2[7:0], rs1[7:0]} :
                     0 ;

//
// GREVI
// ------------------------------------------------------------

wire [31:0] grevi_result ;

wire grevi_valid;
assign grevi_valid = op_grevi ;

wire [31:0]  g1, g2, g3, g4, g5, g6; // Intermediate Signals

wire [4:0] grevi_shamt = grevi_valid ? imm & 31 : 0 ;

assign g1 =  rs1 ;
assign g2 = (grevi_shamt & 1)  ? ((g1 & 0x55555555) <<  1) | ((g1 & 0xAAAAAAAA) >>  1) : g1 ;  
assign g3 = (grevi_shamt & 2)  ? ((g2 & 0x33333333) <<  2) | ((g2 & 0xCCCCCCCC) >>  2) : g2 ;
assign g4 = (grevi_shamt & 4)  ? ((g3 & 0x0F0F0F0F) <<  4) | ((g3 & 0xF0F0F0F0) >>  4) : g3 ;
assign g5 = (grevi_shamt & 8)  ? ((g4 & 0x00FF00FF) <<  8) | ((g4 & 0xFF00FF00) >>  8) : g4 ;
assign g6 = (grevi_shamt & 16) ? ((g5 & 0x0000FFFF) << 16) | ((g5 & 0xFFFF0000) >> 16) : g5 ;

assign grevi_result = g6 ;


//
// XPERM
// ------------------------------------------------------------

wire [31:0] xperm_result ;

wire xperm_valid;
assign xperm_valid = op_xperm_b | op_xperm_n ;

reg [31:0] res ;
res = 0;

wire [2:0] sz_log2 = op_xperm_n ? 2 :
                     op_xperm_b ? 3 :
                     0 ; 

wire [31:0] sz = 1 << sz_log2 ;
wire [31:0] mask = (1 << sz) - 1;

integer i, pos;
for (i = 0; i < 32; i = i + sz) 
    begin
        pos = ((rs2 >> i) & mask) << sz_log2;
        if (pos < XLEN) 
            begin 
                res <= res | ((rs1 >> pos) & mask) << i;
            end    
    end

assign xperm_result = res ;


//
// SHFL / UNSHFL
// ------------------------------------------------------------

wire [31:0] shfl_result ;

wire shfl_valid;
assign shfl_valid = op_shfl | op_unshfl ;

function [31:0] shuffle32_stage;
    input [31:0] src, maskL, maskR, N ;
    reg [31:0] temp; //Local Variable
    begin
        temp = src & ~(maskL | maskR);
        shuffle32_stage = temp | ((src << N) & maskL) | ((src >> N) & maskR);
    end
endfunction 

wire [31:0] s1, s2, s3, s4, s5; //Intermediate Results

assign s1 = rs1 ;
assign shfl_shamt = shfl_valid ? rs2 & 15 : 0 ;

assign s2 = (shfl_shamt & 8 & op_shfl)      ? shuffle32_stage(s1, 0x00ff0000, 0x0000ff00, 8) : 
            (shfl_shamt & 1 & op_unshfl)    ? shuffle32_stage(s1, 0x44444444, 0x22222222, 1) : 
            s1 ;  

assign s3 = (shfl_shamt & 4 & op_shfl)      ? shuffle32_stage(s2, 0x0f000f00, 0x00f000f0, 4) : 
            (shfl_shamt & 2 & op_unshfl)    ? shuffle32_stage(s2, 0x30303030, 0x0c0c0c0c, 2) : 
            s2 ;

assign s4 = (shfl_shamt & 2 & op_shfl)      ? shuffle32_stage(s3, 0x30303030, 0x0c0c0c0c, 2) : 
            (shfl_shamt & 4 & op_unshfl)    ? shuffle32_stage(s3, 0x0f000f00, 0x00f000f0, 4) : 
            s3 ;

assign s5 = (shfl_shamt & 1 & op_shfl)      ? shuffle32_stage(s4, 0x44444444, 0x22222222, 1) : 
            (shfl_shamt & 8 & op_unshfl)    ? shuffle32_stage(s4, 0x00ff0000, 0x0000ff00, 8) : 
            s4 ;

assign shfl_result = s5 ;



//
// CLMUL/ CLMULH
// ------------------------------------------------------------


wire        clmul_ready, clmul_out_valid ;
wire [31:0] clmul_rs1 , clmul_rs2, clmul_result ;

assign clmul_rs1 = `GATE_INPUTS(32, clmul_valid, rs1) ;
assign clmul_rs2 = `GATE_INPUTS(32, clmul_valid, rs2) ;

assign clmul_valid = op_clmul | op_clmulh ;

rvb_clmul i_rvb_clmul (
    // control signals
    .clock(clk),                   // positive edge clock - input
    .reset(rst),                   // synchronous reset - input
    // data input
    .din_ready(clmul_ready),       // core accepts input - output
    .din_rs1(clmul_rs1),           // value of 1st argument
    .din_rs2(clmul_rs2),           // value of 2nd argument
    .op_clmul(op_clmul),
    .op_clmulh(op_clmulh),
    // data output
    .dout_valid(clmul_out_valid),  // output is valid - output
    .dout_rd(clmul_result)         // output value
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