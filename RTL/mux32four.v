module mux32four(i0,i1,i2,i3,sel,out);
	input [31:0] i0,i1,i2,i3;
	input [1:0] sel;
	output [31:0] out;
	
	assign out = (sel==2'b11) ? i3 : 
                 (sel==2'b10) ? i2 :
                 (sel==2'b01) ? i1 :   
                 i0;	

endmodule