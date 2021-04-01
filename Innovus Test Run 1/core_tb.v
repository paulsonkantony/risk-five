module core_tb;
 reg clk;
 reg reset;
 integer k;
 reg [9:0] cycles;
 core rv32i (clk, reset);
 
 wire [31:0] pc = rv32i.pc;
 wire [31:0] new_pc = rv32i.pc_in;
 wire [31:0] instruction = rv32i.instruction_mux_out; 
 wire [31:0] alu_a = rv32i.mux_a_out; 
 wire [31:0] alu_b = rv32i.mux_b_out; 
 wire [31:0] alu_out = rv32i.alu_out; 
 wire [31:0] r0 = rv32i.register_file.regFile[0]; 
 wire [31:0] r1 = rv32i.register_file.regFile[1]; 
 wire [31:0] r2 = rv32i.register_file.regFile[2];  
 wire [31:0] r3 = rv32i.register_file.regFile[3]; 


 always @(posedge clk or negedge reset) 
 begin
 	if(~reset) begin
 		 cycles <= 0;
 	end else begin
 		 cycles <= cycles+1 ;
 	end
 end

 initial #12000 $finish;
 
 //Reset at beginning
 initial
 	begin
	 	reset=1;
		#5 reset =0;
		#5 reset =1;
	end 

 //Clock Generation
 initial
 	begin
	 	clk = 0;
 		repeat (100)
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
  	//rv32i.data_memory.mem[65] = 7;
    	//rv32i.data_memory.mem[66] = 2;



  	/* Instruction Memory Initialisations HERE */

	$readmemh("mem.bin",rv32i.insn_memory.mem);

	//for (k = 0; k < 200; k = k + 1) begin
	//    $display ("TEST %d: %x", k, rv32i.insn_memory.mem[k]);
	//end
 	
 	end
 
	//Monitoring
	always @(posedge clk)
		begin

			$display();
            $display("cycle: %d", cycles);
            $display("pc:\t %x", pc);
            $display("instr: %b %b %b %b %b %b", instruction[31:25], instruction[24:20], instruction[19:15], instruction[14:12], instruction[11:7], instruction[6:0]);

			$display();
            $write("x0:  ");
            for(k = 0; k < 8; k=k+1 ) begin
                $write("%h ", rv32i.register_file.regFile[k]);
            end

			$display();
            $write("x8:  ");
            for(k = 8; k < 16; k=k+1 ) begin
                $write("%h ", rv32i.register_file.regFile[k]);
            end

			$display();
            $write("x16: ");
            for(k = 16; k < 24; k=k+1 ) begin
                $write("%h ", rv32i.register_file.regFile[k]);
            end

			$display();
            $write("x24: ");
            for(k = 24; k < 32; k=k+1 ) begin
                $write("%h ", rv32i.register_file.regFile[k]);
            end
            $display();
	        	
		end

endmodule
