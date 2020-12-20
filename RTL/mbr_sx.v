module mbr_sx(sx, mbr, size);
	input [31:0] mbr;
	input [2:0] size;
	output reg[31:0] sx; //Assign in always block so reg

	parameter bit8	= 0,
		bit_u8 	= 1,
		bit16	= 2,
		bit_u16 = 3,
		bit32 	= 4;

	always @(mbr)
	begin
		case(size)
			bit8	: sx = {{24{mbr[7]}},mbr[7:0]};
			bit_u8 	: sx = {{24{1'b0}},mbr[7:0]};
			bit16	: sx = {{16{mbr[15]}},mbr[15:0]};
			bit_u16 : sx = {{16{1'b0}},mbr[15:0]};
			bit32 	: sx = mbr;
			default : sx = 32'b0;
		endcase
	end
endmodule