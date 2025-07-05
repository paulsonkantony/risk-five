 module forwarding_unit_branch(fwd_a, fwd_b, id_ex_rs1, id_ex_rs2, ex_mem_rd, mem_wb_rd, ex_mem_reg_we, mem_wb_reg_we, branch_o, jalr_o);

    input [4:0] id_ex_rs1, id_ex_rs2, ex_mem_rd, mem_wb_rd;
    input ex_mem_reg_we, mem_wb_reg_we, branch_o, jalr_o;

    output[1:0] fwd_a, fwd_b;

    wire ex_mem_write_bit, mem_wb_write_bit, ex_mem_write_zero, mem_wb_write_zero;

    wire forward_from_ex_mem_base, forward_from_mem_wb_base;

    assign ex_mem_write_bit = ex_mem_reg_we == 1;
    assign mem_wb_write_bit = mem_wb_reg_we == 1;
    
    assign ex_mem_write_zero =  ex_mem_rd == 0;
    assign mem_wb_write_zero =  mem_wb_rd == 0;

    assign ex_mem_write_rs1 =  ex_mem_rd == id_ex_rs1;
    assign ex_mem_write_rs2 =  ex_mem_rd == id_ex_rs2;
    assign mem_wb_write_rs1 =  mem_wb_rd == id_ex_rs1;
    assign mem_wb_write_rs2 =  mem_wb_rd == id_ex_rs2;



    // 1. EX hazard:
    // if (EX/MEM.RegWrite and (EX/MEM.RegisterRd ≠ 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRs1)) 
    //     ForwardA = 10
    // if (EX/MEM.RegWrite and (EX/MEM.RegisterRd ≠ 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRs2)) 
    //     ForwardB = 10
    
    // 2. MEM hazard:
    // if (
    //     MEM/WB.RegWrite and (MEM/WB.RegisterRd ≠ 0) and not(EX/MEM.RegWrite and (EX/MEM.RegisterRd ≠ 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRs1)) and 
    //     (MEM/WB.RegisterRd = ID/EX.RegisterRs1)
    //     ) 
    //     ForwardA = 01
    // if (
    //     MEM/WB.RegWrite and (MEM/WB.RegisterRd ≠ 0) and not(EX/MEM.RegWrite and (EX/MEM.RegisterRd ≠ 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRs2)) and 
    //     (MEM/WB.RegisterRd = ID/EX.RegisterRs2)
    //     ) 
    //     ForwardB = 01

    // CHECK CONDITION


    assign forward_from_ex_mem_base = ex_mem_write_bit && ~ex_mem_write_zero;
    assign forward_from_mem_wb_base = mem_wb_write_bit && ~mem_wb_write_zero;

    assign fwd_a = forward_from_mem_wb_base && mem_wb_write_rs1 && ~(forward_from_ex_mem_base & ex_mem_write_rs1) && (branch_o|jalr_o) ? 2'b10 :
                   forward_from_ex_mem_base && ex_mem_write_rs1 && (branch_o|jalr_o) ? 2'b01 :
                   2'b00;

    assign fwd_b = forward_from_mem_wb_base && mem_wb_write_rs2 && ~(forward_from_ex_mem_base & ex_mem_write_rs2) && (branch_o|jalr_o) ? 2'b10 :
                   forward_from_ex_mem_base && ex_mem_write_rs2 && (branch_o|jalr_o) ? 2'b01 :
                   2'b00;

endmodule

