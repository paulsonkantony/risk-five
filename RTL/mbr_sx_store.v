module mbr_sx_store(sx, w_en, mbr, size, mem_we, addr);
	input [31:0] mbr, addr;
	input [2:0] size;
    input mem_we;
	output [31:0] sx;
    output [3:0] w_en;


	wire mem_byte, mem_half, mem_word;
	
    parameter bit8  = 3'b0,
            bit16   = 3'b010,
            bit32   = 3'b100;

    assign mem_byte = size==bit8; 
    assign mem_half = size==bit16; 
    assign mem_word = size==bit32;

    // write enable signal for Main Memory. Each bit represents a byte masking. When the value is 1, the corresponding masked byte is  tten. When the value is 0, the corresponding byte is not written.
    assign w_en[0] = mem_we & ( ( mem_byte &    ~(|addr[1:0])      ) | (mem_half & ~(|addr[1:0]))        | (mem_word & ~(|addr[1:0])) ) & ~addr[31];
    assign w_en[1] = mem_we & ( ( mem_byte & (~addr[1] &  addr[0]) ) | (mem_half & ~(|addr[1:0]))        | (mem_word & ~(|addr[1:0])) ) & ~addr[31];
    assign w_en[2] = mem_we & ( ( mem_byte & ( addr[1] & ~addr[0]) ) | (mem_half & (addr[1] & ~addr[0])) | (mem_word & ~(|addr[1:0])) ) & ~addr[31];
    assign w_en[3] = mem_we & ( ( mem_byte & ( addr[1] &  addr[0]) ) | (mem_half & (addr[1] & ~addr[0])) | (mem_word & ~(|addr[1:0])) ) & ~addr[31];


    // first byte of input data to Main Memory port
    assign sx[7:0]   = mbr[7:0];

    // second byte of input data to Main Memory port
    assign sx[15:8]  = mem_byte ? mbr[7:0] :
                        mbr[15:8];

    // third byte of input data to Main Memory port
    assign sx[23:16] = mem_word ? mbr[23:16] :
                        mbr[7:0];

    // fourth byte of input data to Main Memory port
    assign sx[31:24] = mem_byte ? mbr[7:0] :
                        mem_word ? mbr[31:24] :
                        mbr[15:8];


endmodule