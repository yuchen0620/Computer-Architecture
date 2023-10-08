.data
test: .word 0,4,0x80000000
str1: .string "The reslut of "
str2: .string " is "
str3: .string "\n"    
.text
main:
    la a2, test
    li t3, 3

loop:
    lw a0, 0(a2)
    jal ra, generateBitmask
    
    # Print the result to console
    # t0: input value
    # t1: bitmask
    lw t0, 0(a2)
    mv t1, a0
               
    la a0, str1
    li a7, 4
    ecall
    mv a0, t0
    li a7, 35
    ecall
    la a0, str2
    li a7, 4
    ecall   
    mv a0, t1
    li a7, 35
    ecall
    la a0, str3
    li a7, 4
    ecall
    
    # Loop control
    addi a2, a2, 4
    addi t3, t3, -1
    bnez t3,loop
    
    # Exit program
    li a7, 10
    ecall
    
generateBitmask:

    mv s0, ra
    jal ra, clz   
    # return (1 << (32 - leading_zeros)) - 1;
    li t0, 32
    sub t0, t0, a0
    li t1, 1
    sll a0, t1, t0
    addi a0, a0, -1
    jalr x0, s0, 0
    
clz:
    # x |= (x>>1)
    srli t0, a0, 1
    or a0, t0, a0
    
    # x |= (x>>2)
    srli t0, a0, 2
    or a0, t0, a0
    
    # x |= (x>>4)
    srli t0, a0, 4
    or a0, t0, a0 
    
    # x |= (x>>8)
    srli t0, a0, 8
    or a0, t0, a0 
    
    # x |= (x>>16)
    srli t0, a0, 16
    or a0, t0, a0 
    
    # x -= ((x >> 1) & 0x55555555)
    srli t0, a0, 1
    li t1, 0x55555555
    and t0, t0, t1
    sub a0, a0, t0
    
    # x = ((x >> 2) & 0x33333333) + (x & 0x33333333)
    srli t0, a0, 2
    li t1, 0x33333333
    and t0, t0, t1
    and t2, a0, t1
    add a0, t0, t2
    
    # x = ((x >> 4) + x) & 0x0f0f0f0f
    srli t0, a0, 4
    add t0, t0, a0
    li t1, 0x0f0f0f0f
    and a0, t0, t1
    
    # x += (x >> 8);
    srli t0, a0, 8
    add a0, a0, t0
    
    # x += (x >> 16);
    srli t0, a0, 16
    add a0, a0, t0
    
    # return (32 - (x & 0x3f))
    li t0, 0x3f
    and a0, a0, t0
    li t0, 32
    sub a0, t0, a0
    ret
    
