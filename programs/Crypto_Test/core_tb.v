module core_tb;

 `define TESTING

 reg clk;
 reg reset;
 integer k;
 reg [31:0] cycles;
 core_top rv32i (clk, reset);

 wire [31:0] pc = rv32i.main_core.pc;
 wire [31:0] new_pc = rv32i.main_core.new_pc_in;
 wire [31:0] instruction = rv32i.main_core.instruction_mux_out;
 wire [31:0] alu_a = rv32i.main_core.mux_a_out;
 wire [31:0] alu_b = rv32i.main_core.mux_b_out;
 wire [31:0] alu_out = rv32i.main_core.alu_out;
 wire [31:0] r0 = rv32i.main_core.register_file.regFile[0];
 wire [31:0] r1 = rv32i.main_core.register_file.regFile[1];
 wire [31:0] r2 = rv32i.main_core.register_file.regFile[2];
 wire [31:0] r3 = rv32i.main_core.register_file.regFile[3];


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
		#25 reset =1;
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

    //Initial Hash Values
    rv32i.data_memory.mem[0] = 32'h6a09e667;
    rv32i.data_memory.mem[1] = 32'hbb67ae85;
    rv32i.data_memory.mem[2] = 32'h3c6ef372;
    rv32i.data_memory.mem[3] = 32'ha54ff53a;
    rv32i.data_memory.mem[4] = 32'h510e527f;
    rv32i.data_memory.mem[5] = 32'h9b05688c;
    rv32i.data_memory.mem[6] = 32'h1f83d9ab;
    rv32i.data_memory.mem[7] = 32'h5be0cd19;

    //Round Constants
    rv32i.data_memory.mem[10] = 32'h428a2f98;
    rv32i.data_memory.mem[11] = 32'h71374491;
    rv32i.data_memory.mem[12] = 32'hb5c0fbcf;
    rv32i.data_memory.mem[13] = 32'he9b5dba5;
    rv32i.data_memory.mem[14] = 32'h3956c25b;
    rv32i.data_memory.mem[15] = 32'h59f111f1;
    rv32i.data_memory.mem[16] = 32'h923f82a4;
    rv32i.data_memory.mem[17] = 32'hab1c5ed5;
    rv32i.data_memory.mem[18] = 32'hd807aa98;
    rv32i.data_memory.mem[19] = 32'h12835b01;
    rv32i.data_memory.mem[20] = 32'h243185be;
    rv32i.data_memory.mem[21] = 32'h550c7dc3;
    rv32i.data_memory.mem[22] = 32'h72be5d74;
    rv32i.data_memory.mem[23] = 32'h80deb1fe;
    rv32i.data_memory.mem[24] = 32'h9bdc06a7;
    rv32i.data_memory.mem[25] = 32'hc19bf174;
    rv32i.data_memory.mem[26] = 32'he49b69c1;
    rv32i.data_memory.mem[27] = 32'hefbe4786;
    rv32i.data_memory.mem[28] = 32'h0fc19dc6;
    rv32i.data_memory.mem[29] = 32'h240ca1cc;
    rv32i.data_memory.mem[30] = 32'h2de92c6f;
    rv32i.data_memory.mem[31] = 32'h4a7484aa;
    rv32i.data_memory.mem[32] = 32'h5cb0a9dc;
    rv32i.data_memory.mem[33] = 32'h76f988da;
    rv32i.data_memory.mem[34] = 32'h983e5152;
    rv32i.data_memory.mem[35] = 32'ha831c66d;
    rv32i.data_memory.mem[36] = 32'hb00327c8;
    rv32i.data_memory.mem[37] = 32'hbf597fc7;
    rv32i.data_memory.mem[38] = 32'hc6e00bf3;
    rv32i.data_memory.mem[39] = 32'hd5a79147;
    rv32i.data_memory.mem[40] = 32'h06ca6351;
    rv32i.data_memory.mem[41] = 32'h14292967;
    rv32i.data_memory.mem[42] = 32'h27b70a85;
    rv32i.data_memory.mem[43] = 32'h2e1b2138;
    rv32i.data_memory.mem[44] = 32'h4d2c6dfc;
    rv32i.data_memory.mem[45] = 32'h53380d13;
    rv32i.data_memory.mem[46] = 32'h650a7354;
    rv32i.data_memory.mem[47] = 32'h766a0abb;
    rv32i.data_memory.mem[48] = 32'h81c2c92e;
    rv32i.data_memory.mem[49] = 32'h92722c85;
    rv32i.data_memory.mem[50] = 32'ha2bfe8a1;
    rv32i.data_memory.mem[51] = 32'ha81a664b;
    rv32i.data_memory.mem[52] = 32'hc24b8b70;
    rv32i.data_memory.mem[53] = 32'hc76c51a3;
    rv32i.data_memory.mem[54] = 32'hd192e819;
    rv32i.data_memory.mem[55] = 32'hd6990624;
    rv32i.data_memory.mem[56] = 32'hf40e3585;
    rv32i.data_memory.mem[57] = 32'h106aa070;
    rv32i.data_memory.mem[58] = 32'h19a4c116;
    rv32i.data_memory.mem[59] = 32'h1e376c08;
    rv32i.data_memory.mem[60] = 32'h2748774c;
    rv32i.data_memory.mem[61] = 32'h34b0bcb5;
    rv32i.data_memory.mem[62] = 32'h391c0cb3;
    rv32i.data_memory.mem[63] = 32'h4ed8aa4a;
    rv32i.data_memory.mem[64] = 32'h5b9cca4f;
    rv32i.data_memory.mem[65] = 32'h682e6ff3;
    rv32i.data_memory.mem[66] = 32'h748f82ee;
    rv32i.data_memory.mem[67] = 32'h78a5636f;
    rv32i.data_memory.mem[68] = 32'h84c87814;
    rv32i.data_memory.mem[69] = 32'h8cc70208;
    rv32i.data_memory.mem[70] = 32'h90befffa;
    rv32i.data_memory.mem[71] = 32'ha4506ceb;
    rv32i.data_memory.mem[72] = 32'hbef9a3f7;
    rv32i.data_memory.mem[73] = 32'hc67178f2;

    //Message

    //"hello world" padded to 512 bits

    // 68 65 6c 6c
    // 6f 20 77 6f
    // 72 6c 64 80
    // 0  0  0  0
    // 0  0  0  0
    // 0  0  0  0
    // 0  0  0  0
    // 0  0  0  0
    // 0  0  0  0
    // 0  0  0  0
    // 0  0  0  0
    // 0  0  0  0
    // 0  0  0  0
    // 0  0  0  0
    // 0  0  0  0
    // 0  0  0  58

    rv32i.data_memory.mem[100] = 32'h68656c6c;
    rv32i.data_memory.mem[101] = 32'h6f20776f;
    rv32i.data_memory.mem[102] = 32'h726c6480;

    rv32i.data_memory.mem[115] = 32'h00000058;


  	/* Instruction Memory Initialisations HERE */

	$readmemh("mem.bin",rv32i.insn_memory.mem);

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
            $display("instr: %b %b %b %b %b %b", instruction[31:25], instruction[24:20], instruction[19:15], instruction[14:12], instruction[11:7], instruction[6:0]);
            $display("instr: %x", instruction);

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
