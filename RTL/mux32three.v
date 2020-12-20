module mux32three(i0,i1,i2,sel,out);
	input [31:0] i0,i1,i2;
	input [1:0] sel;
	output [31:0] out;
	reg [31:0] out;
	always @ (i0 or i1 or i2 or sel)
		begin
			case (sel)
				2'b00: out = i0;
				2'b01: out = i1;
				2'b10: out = i2;
				default: out = 32'b0;
			endcase
		end
endmodule