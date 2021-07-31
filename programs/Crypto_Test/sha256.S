# Initial Hash Constants    are stored in data_mem[  0] to data_mem[  7]
# Hash Round Constants      are stored in data_mem[ 10] to data_mem[ 73]
# Preprocessed Message Bits are stored in data_mem[100] to data_mem[116]

message_scheduling_init:
addi a0, x0, 464 # 116*4
addi a1, x0, 456 # 114*4
addi a2, x0, 436 # 109*4
addi a3, x0, 404 # 101*4
addi a4, x0, 400 # 100*4

jal x1, message_schedule

addi s0, x0, 17 # count     = 17
addi s1, x0, 64 # count_end = 64

message_loop:
addi a0, a0, 4
addi a1, a1, 4
addi a2, a2, 4
addi a3, a3, 4
addi a4, a4, 4

jal x1, message_schedule

addi s0, s0, 1
beq s0, s1, message_schedule_finish
j message_loop

message_schedule:
addi t0, x0, 0
# SIGMA1(W[t-2])
lw t1, 0(a1)
sha256sig1 t1, t1
add t0, t0, t1
# W[t-7]
lw t1, 0(a2)
add t0, t0, t1
# SIGMA0(W[t-15])
lw t1, 0(a3)
sha256sig0 t1, t1
add t0, t0, t1
# W[t-16]
lw t1, 0(a4)
add t0, t0, t1

sw t0, 0(a0)
ret

message_schedule_finish:
addi t0, x0, 0
addi t1, x0, 0
addi a0, x0, 0
addi a1, x0, 0
addi a2, x0, 0
addi a3, x0, 0
addi a4, x0, 0

initial_hash:
addi t6, x0, 0

lw a0,  0(t6)
lw a1,  4(t6)
lw a2,  8(t6)
lw a3, 12(t6)
lw a4, 16(t6)
lw a5, 20(t6)
lw a6, 24(t6)
lw a7, 28(t6)

addi s0, x0, 0  # count     = 0
addi s1, x0, 64 # count_end = 64

addi s2, x0, 40  # 10*4
addi s3, x0, 400 # 100*4

hash_loop:
lw s4, 0(s2)
lw s5, 0(s3)

jal x1, calculate_ch
jal x1, calculate_maj

sha256sum0 t2, a0
sha256sum1 t3, a4

add t4, a7, t3
add t4, t4, t0
add t4, t4, s4
add t4, t4, s5

add t5, t1, t2

mv a7, a6	   # h
mv a6, a5	   # g
mv a5, a4	   # f
add a4, a3, t4 # e
mv a3, a2	   # d
mv a2, a1	   # c
mv a1, a0	   # b
add a0, t4, t5 # a

addi s2, s2, 4
addi s3, s3, 4
addi s0, s0, 1
beq s0, s1, hash_finish
j hash_loop

calculate_ch:
and t0, a4, a5
not t6, a4
and t6, t6, a6
xor t0, t0, t6
ret

calculate_maj:
and t1, a0, a1
and t6, a0, a2
xor t1, t1, t6
and t6, a1, a2
xor t1, t1, t6
ret

hash_finish:
lw t6,  0(x0)
add a0, a0, t6
lw t6,  4(x0)
add a1, a1, t6
lw t6,  8(x0)
add a2, a2, t6
lw t6, 12(x0)
add a3, a3, t6
lw t6, 16(x0)
add a4, a4, t6
lw t6, 20(x0)
add a5, a5, t6
lw t6, 24(x0)
add a6, a6, t6
lw t6, 28(x0)
add a7, a7, t6

end_loop:
jal x0, end_loop