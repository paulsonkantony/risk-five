module mux32three(i0,i1,i2,sel,out);
	input [31:0] i0,i1,i2;
	input [1:0] sel;
	output [31:0] out;
	
	assign out = (sel==2'b10) ? i2 :
                 (sel==2'b01) ? i1 :   
                 i0;

endmodule