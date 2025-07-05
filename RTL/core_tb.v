module core_tb;

 `define TESTING

 reg clk;
 reg reset;
 integer k;
 reg [31:0] cycles;
 core_top rv32i (clk, reset);
 
 wire [31:0] pc = rv32i.main_core.IF_pc;
 // wire [31:0] new_pc = rv32i.main_core.new_pc_in;
 wire [31:0] instruction = rv32i.main_core.instruction; 
 // wire [31:0] alu_a = rv32i.main_core.mux_a_out; 
 // wire [31:0] alu_b = rv32i.main_core.mux_b_out; 
 // wire [31:0] alu_out = rv32i.main_core.alu_out; 
 // wire [31:0] r0 = rv32i.main_core.register_file.regFile[0]; 
 // wire [31:0] r1 = rv32i.main_core.register_file.regFile[1]; 
 // wire [31:0] r2 = rv32i.main_core.register_file.regFile[2];  
 // wire [31:0] r3 = rv32i.main_core.register_file.regFile[3]; 


 always @(posedge clk or negedge reset) 
 begin
 	if(~reset) begin
 		 cycles <= 0;
 	end else begin
 		 cycles <= cycles+1 ;
 	end
 end

 initial #120000000 $finish;
 
 //Reset at beginning
 initial
 	begin
	 	reset=1;
		#5 reset =0;
		#45 reset =1;
	end 

 //Clock Generation
 initial
 	begin
	 	clk = 0;
 		forever
 			begin
 				#20 clk = 1; 
 				#20 clk = 0;
 			end
	end 


 //Memory Initialisation
 initial
 	begin
 	
     	for (k=0; k< 1024; k=k+1) 
    		begin
     			rv32i.insn_memory.mem[k] = 32'b0;
     			rv32i.data_memory.mem[k] = 32'b0;
      		end

      	 /* Data Memory Initialisations HERE */

        //Padded State

        rv32i.data_memory.mem[0]  = 32'h997b5853;
        rv32i.data_memory.mem[1]  = 32'h00000001;
        rv32i.data_memory.mem[2]  = 32'h00000000;
        rv32i.data_memory.mem[3]  = 32'h00000000;
        rv32i.data_memory.mem[4]  = 32'h00000000;
        rv32i.data_memory.mem[5]  = 32'h00000000;
        rv32i.data_memory.mem[6]  = 32'h00000000;
        rv32i.data_memory.mem[7]  = 32'h00000000;
        rv32i.data_memory.mem[8]  = 32'h00000000;
        rv32i.data_memory.mem[9]  = 32'h00000000;
        rv32i.data_memory.mem[10] = 32'h00000000;
        rv32i.data_memory.mem[11] = 32'h00000000;
        rv32i.data_memory.mem[12] = 32'h00000000;
        rv32i.data_memory.mem[13] = 32'h00000000;
        rv32i.data_memory.mem[14] = 32'h00000000;
        rv32i.data_memory.mem[15] = 32'h00000000;
        rv32i.data_memory.mem[16] = 32'h00000000;
        rv32i.data_memory.mem[17] = 32'h00000000;
        rv32i.data_memory.mem[18] = 32'h00000000;
        rv32i.data_memory.mem[19] = 32'h00000000;
        rv32i.data_memory.mem[20] = 32'h00000000;
        rv32i.data_memory.mem[21] = 32'h00000000;
        rv32i.data_memory.mem[22] = 32'h00000000;
        rv32i.data_memory.mem[23] = 32'h00000000;
        rv32i.data_memory.mem[24] = 32'h00000000;
        rv32i.data_memory.mem[25] = 32'h00000000;
        rv32i.data_memory.mem[26] = 32'h00000000;
        rv32i.data_memory.mem[27] = 32'h00000000;
        rv32i.data_memory.mem[28] = 32'h00000000;
        rv32i.data_memory.mem[29] = 32'h00000000;
        rv32i.data_memory.mem[30] = 32'h00000000;
        rv32i.data_memory.mem[31] = 32'h00000000;
        rv32i.data_memory.mem[32] = 32'h00000000;
        rv32i.data_memory.mem[33] = 32'h80000000;
        rv32i.data_memory.mem[34] = 32'h00000000;
        rv32i.data_memory.mem[35] = 32'h00000000;
        rv32i.data_memory.mem[36] = 32'h00000000;
        rv32i.data_memory.mem[37] = 32'h00000000;
        rv32i.data_memory.mem[38] = 32'h00000000;
        rv32i.data_memory.mem[39] = 32'h00000000;
        rv32i.data_memory.mem[40] = 32'h00000000;
        rv32i.data_memory.mem[41] = 32'h00000000;
        rv32i.data_memory.mem[42] = 32'h00000000;
        rv32i.data_memory.mem[43] = 32'h00000000;
        rv32i.data_memory.mem[44] = 32'h00000000;
        rv32i.data_memory.mem[45] = 32'h00000000;
        rv32i.data_memory.mem[46] = 32'h00000000;
        rv32i.data_memory.mem[47] = 32'h00000000;
        rv32i.data_memory.mem[48] = 32'h00000000;
        rv32i.data_memory.mem[49] = 32'h00000000;
 

        //Round Constants
        
        rv32i.data_memory.mem[200] = 32'h00000001;
        rv32i.data_memory.mem[201] = 32'h00000000; 
        rv32i.data_memory.mem[202] = 32'h00008082;
        rv32i.data_memory.mem[203] = 32'h00000000; 
        rv32i.data_memory.mem[204] = 32'h0000808a;
        rv32i.data_memory.mem[205] = 32'h80000000;
        rv32i.data_memory.mem[206] = 32'h80008000;
        rv32i.data_memory.mem[207] = 32'h80000000; 
        rv32i.data_memory.mem[208] = 32'h0000808b;
        rv32i.data_memory.mem[209] = 32'h00000000; 
        rv32i.data_memory.mem[210] = 32'h80000001;
        rv32i.data_memory.mem[211] = 32'h00000000;
        rv32i.data_memory.mem[212] = 32'h80008081;
        rv32i.data_memory.mem[213] = 32'h80000000; 
        rv32i.data_memory.mem[214] = 32'h00008009;
        rv32i.data_memory.mem[215] = 32'h80000000; 
        rv32i.data_memory.mem[216] = 32'h0000008a;
        rv32i.data_memory.mem[217] = 32'h00000000;
        rv32i.data_memory.mem[218] = 32'h00000088;
        rv32i.data_memory.mem[219] = 32'h00000000; 
        rv32i.data_memory.mem[220] = 32'h80008009;
        rv32i.data_memory.mem[221] = 32'h00000000; 
        rv32i.data_memory.mem[222] = 32'h8000000a;
        rv32i.data_memory.mem[223] = 32'h00000000;
        rv32i.data_memory.mem[224] = 32'h8000808b;
        rv32i.data_memory.mem[225] = 32'h00000000; 
        rv32i.data_memory.mem[226] = 32'h0000008b;
        rv32i.data_memory.mem[227] = 32'h80000000; 
        rv32i.data_memory.mem[228] = 32'h00008089;
        rv32i.data_memory.mem[229] = 32'h80000000;
        rv32i.data_memory.mem[230] = 32'h00008003;
        rv32i.data_memory.mem[231] = 32'h80000000; 
        rv32i.data_memory.mem[232] = 32'h00008002;
        rv32i.data_memory.mem[233] = 32'h80000000; 
        rv32i.data_memory.mem[234] = 32'h00000080;
        rv32i.data_memory.mem[235] = 32'h80000000;
        rv32i.data_memory.mem[236] = 32'h0000800a;
        rv32i.data_memory.mem[237] = 32'h00000000; 
        rv32i.data_memory.mem[238] = 32'h8000000a;
        rv32i.data_memory.mem[239] = 32'h80000000; 
        rv32i.data_memory.mem[240] = 32'h80008081;
        rv32i.data_memory.mem[241] = 32'h80000000;
        rv32i.data_memory.mem[242] = 32'h00008080;
        rv32i.data_memory.mem[243] = 32'h80000000; 
        rv32i.data_memory.mem[244] = 32'h80000001;
        rv32i.data_memory.mem[245] = 32'h00000000; 
        rv32i.data_memory.mem[246] = 32'h80008008;
        rv32i.data_memory.mem[247] = 32'h80000000;

      	/* Instruction Memory Initialisations HERE */

    	$readmemh("scratch_bin_working.bin",rv32i.insn_memory.mem);

    	//for (k = 0; k < 200; k = k + 1) begin
    	//    $display ("TEST %d: %x", k, rv32i.main_core.insn_memory.mem[k]);
    	//end
 	
 	end
 
	//Monitoring
	always @(negedge clk)
		begin

			$display();
            $display("cycle: %d", cycles);
            $display("pc:\t %x", pc);
            $display("pc:\t %d", pc/4);
            $display("instr: %b %b %b %b %b %b", instruction[31:25], instruction[24:20], instruction[19:15], instruction[14:12], instruction[11:7], instruction[6:0]);
            $display("instr: %h", instruction);

			$display();
            $write("x0:  ");
            for(k = 0; k < 8; k=k+1 ) begin
                $write("%h ", rv32i.main_core.register_file.regFile[k]);
            end

			$display();
            $write("x8:  ");
            for(k = 8; k < 16; k=k+1 ) begin
                $write("%h ", rv32i.main_core.register_file.regFile[k]);
            end

			$display();
            $write("x16: ");
            for(k = 16; k < 24; k=k+1 ) begin
                $write("%h ", rv32i.main_core.register_file.regFile[k]);
            end

			$display();
            $write("x24: ");
            for(k = 24; k < 32; k=k+1 ) begin
                $write("%h ", rv32i.main_core.register_file.regFile[k]);
            end
            $display();
	        	
		end

endmodule