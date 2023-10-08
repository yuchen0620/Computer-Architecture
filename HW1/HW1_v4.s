.data
test: .word 0,4,0x80000000
str1: .string "The reslut of "
str2: .string " is "
str3: .string "\n"    
.text
main:
    la a2, test
    lw a0, 0(a2)
    jal ra, generateBitmask
    lw a0, 4(a2)
    jal ra, generateBitmask
    lw a0, 8(a2)
    jal ra, generateBitmask
    
    # Exit program
    li a7, 10
    ecall   
    
generateBitmask:
    mv s0, ra
    mv a1, a0 #store input value
    jal ra, clz 
      
    # return (1 << (32 - leading_zeros)) - 1;
    li t0, 32
    sub t0, t0, a0
    li t1, 1
    sll a0, t1, t0
    addi a0, a0, -1
    
    # Print the result to console
    # a1: input value
    # t1: bitmask
    mv t1, a0              
    la a0, str1
    li a7, 4
    ecall
    mv a0, a1
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
    
