.data
test: .word 0,0,0,4,0x80000000,0 # data1=0, data2=4, data3=0x80000000000000000
str1: .string "The reslut of "
str2: .string " is "
str3: .string " "
str4: .string "\n"    
.text
main:
    la a2, test
    li t4, 3

loop:
    lw a1, 0(a2)
    lw a0, 4(a2)
    jal ra, generateBitmask
    
    # Print the result to console
    mv t0, a0
    mv t1, a1
    lw a1, 0(a2)
    lw a0, 4(a2)
    jal ra, printResult
    
    # Loop control
    addi a2, a2, 8
    addi t4, t4, -1
    bnez t4,loop
    
    # Exit program
    li a7, 10
    ecall
    
generateBitmask:
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, clz
    
    # return 0xffffffffffffffff >> leading_zeros;
    li t0, 32
    bge a0, t0, leading_zeros_bigger_32    
    # leading_zeros_smaller_32
    li t2,0xffffffff # high32bit  
    srl a1, t2, a0
    li a0, 0xffffffff # low32bit
    lw ra,0(sp)  
    addi sp, sp,4 
    jr ra
    
    leading_zeros_bigger_32:
        addi a0, a0, -32
        li t2, 0xffffffff # low32bit
        srl a0, t2, a0
        li a1, 0 # high32bit              
        lw ra,0(sp)  
        addi sp, sp,4 
        jr ra
                          
clz:
    
    # x |= (x>>1)   
    srli t1, a0, 1
    slli t2, a1, 31
    or t1, t1, t2
    srli t2, a1, 1
    or a0, a0, t1
    or a1, a1, t2
    
    # x |= (x>>2)   
    srli t1, a0, 2
    slli t2, a1, 30
    or t1, t1, t2
    srli t2, a1, 2
    or a0, a0, t1
    or a1, a1, t2
    
    # x |= (x>>4)
    srli t1, a0, 4
    slli t2, a1, 28
    or t1, t1, t2
    srli t2, a1, 4
    or a0, a0, t1
    or a1, a1, t2
    
    # x |= (x>>8)
    srli t1, a0, 8
    slli t2, a1, 24
    or t1, t1, t2
    srli t2, a1, 8
    or a0, a0, t1
    or a1, a1, t2
    
    # x |= (x>>16)
    srli t1, a0, 16
    slli t2, a1, 16
    or t1, t1, t2
    srli t2, a1, 16
    or a0, a0, t1
    or a1, a1, t2
    
    # x |= (x>>32)
    or a0, a0, a1
    
    # x -= ((x >> 1) & 0x5555555555555555)
    srli t0, a0, 1
    slli t1, a1, 31
    or t0, t0, t1
    li t2, 0x55555555
    and t0, t0 ,t2
    srli t1, a1, 1
    and t1, t1, t2
    sub a0, a0, t0
    sub a1, a1, t1
    
    # x = ((x >> 2) & 0x3333333333333333) + (x & 0x3333333333333333)
    srli t0, a0, 2
    slli t1, a1, 30
    or t0, t0, t1
    li t2, 0x33333333
    and t0, t0, t2
    srli t1, a1, 2
    and t1, t1, t2
    and a0, a0, t2
    and a1, a1, t2
    add a0, a0, t0
    add a1, a1, t1

    
    # x = ((x >> 4) + x) & 0x0f0f0f0f
    srli t0, a0, 4
    slli t1, a1, 28
    or t0, t0, t1
    srli t1, a1, 4
    add a0, a0, t0
    add a1, a1, t1
    li t0, 0x0f0f0f0f
    and a0, a0, t0
    and a1, a1, t0
        
    # x += (x >> 8)
    srli t0, a0, 8
    slli t1, a1, 24
    or t0, t0, t1
    srli t1, a1, 8
    add a0, a0, t0
    add a1, a1, t1
    
    # x += (x >> 16)
    srli t0, a0, 16
    slli t1, a1, 16
    or t0, t0, t1
    srli t1, a1, 16
    add a0, a0, t0
    add a1, a1, t1
    
    # x += (x >> 32)
    add a0, a0, a1    
    
    # return (64 - (x & 0x7f))
    li t0, 0x7f
    and a0, a0, t0
    li t0, 64
    sub a0, t0, a0
    ret
    
# t0: low 32bit of bitmask
# t1: high 32bit of bitmask
# a0: low 32bit of input
# a1: high 32bit of input
printResult:
    mv t2, a0
    mv t3, a1   
    la a0, str1
    li a7, 4
    ecall
    mv a0, t3
    li a7, 35
    ecall
    la a0, str3
    li a7, 4
    ecall 
    mv a0, t2
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
    mv a0, t0
    li a7, 35
    ecall
    la a0, str4
    li a7, 4
    ecall
    ret