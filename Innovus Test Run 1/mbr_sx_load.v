module mbr_sx_load(sx, mbr, size, delayed_addr);
	input [31:0] mbr, delayed_addr;
	input [2:0] size;
	output [31:0] sx; 

	wire mem_byte, mem_half, mem_word, mem_byte_u, mem_half_u;
	
    parameter bit8  = 3'b000,
        bit_u8  = 3'b001,
        bit16   = 3'b010,
        bit_u16 = 3'b011,
        bit32   = 3'b100;

    assign mem_byte = size==bit8; 
    assign mem_half = size==bit16; 
    assign mem_word = size==bit32; 
    assign mem_byte_u = size==bit_u8;   
    assign mem_half_u = size==bit_u16;  

    assign sx = mem_byte    & delayed_addr[1:0]==2'b00 ? {{24{mbr[7]}},mbr[7:0]} :
                mem_byte    & delayed_addr[1:0]==2'b01 ? {{24{mbr[15]}},mbr[15:8]} :
                mem_byte    & delayed_addr[1:0]==2'b10 ? {{24{mbr[23]}},mbr[23:16]} :
                mem_byte    & delayed_addr[1:0]==2'b11 ? {{24{mbr[31]}},mbr[31:24]} : 
                mem_half    & delayed_addr[1]==1'b0    ? {{16{mbr[15]}},mbr[15:0]} :
                mem_half    & delayed_addr[1]==1'b1    ? {{16{mbr[31]}},mbr[31:16]} :
                mem_word                                  ? mbr :
                mem_byte_u  & delayed_addr[1:0]==2'b00 ? {{24{1'b0}}, mbr[7:0]} :
                mem_byte_u  & delayed_addr[1:0]==2'b01 ? {{24{1'b0}}, mbr[15:8]} :
                mem_byte_u  & delayed_addr[1:0]==2'b10 ? {{24{1'b0}}, mbr[23:16]} :
                mem_byte_u  & delayed_addr[1:0]==2'b11 ? {{24{1'b0}}, mbr[31:24]} : 
                mem_half_u  & delayed_addr[1]==1'b0    ? {{16{1'b0}}, mbr[15:0]} :
                mem_half_u  & delayed_addr[1]==1'b1    ? {{16{1'b0}}, mbr[31:16]} : 
                'bx;    


endmodule