module forwarding_unit_sw(fwd_a, ex_mem_rs2, mem_wb_rd, mem_wb_reg_we);

    input [4:0] ex_mem_rs2, mem_wb_rd;
    input mem_wb_reg_we;

    output fwd_a;

    wire mem_wb_write_bit, mem_wb_write_zero;

    wire forward_from_mem_wb_base;

    assign mem_wb_write_bit  = mem_wb_reg_we == 1;    
    assign mem_wb_write_zero = mem_wb_rd == 0;
    assign mem_wb_write_rs2  = mem_wb_rd == ex_mem_rs2;

    //SW Hazard

    //ADDI x1, x0, 32
    //SW   x1, 0(x0)

    assign forward_from_mem_wb_base = mem_wb_write_bit && ~mem_wb_write_zero;

    assign fwd_a = forward_from_mem_wb_base && mem_wb_write_rs2 ? 1'b1 : 1'b0;

endmodule

