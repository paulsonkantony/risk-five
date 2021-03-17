module core_tb;
 reg clk;
 reg reset;
 integer k;
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
 		repeat (10)
 			begin
 				#20 clk = 1; 
 				#20 clk = 0;
 			end
	end 


 //Register and Memory Initialisation
 initial
 	begin
 	
 	for (k=0; k<31; k=k+1)
 		rv32i.register_file.regFile[k] = k;
 	
 	for (k=0; k< 1024; k=k+1) 
		begin
 			rv32i.insn_memory.mem[k] = 32'b0;
 			rv32i.data_memory.mem[k] = 32'b0;
  		end

	rv32i.insn_memory.mem[0] = 32'b00000011001000001000000010010011; // ADDI x1,x1,50
 	rv32i.insn_memory.mem[1] = 32'b00000001010000010000000100010011; // ADDI x2,x2,20
 	rv32i.insn_memory.mem[2] = 32'b01000000001000001000000110110011; // ADD x3,x1,x2
 	// should have the answer decimal 30 (00...0011110)

 	end
 
	//Monitoring
	initial
		begin
			$monitor ("R1: %4d, R2: %4d, R3: %4d", rv32i.register_file.regFile[1], rv32i.register_file.regFile[2], rv32i.register_file.regFile[3]);
			#400 $finish;
		end

endmodule