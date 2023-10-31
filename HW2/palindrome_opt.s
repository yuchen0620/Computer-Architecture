.data
test: .word  0x00000000,0x00000000,0x00000000,0x00000001,0x00000C00,0x00000003,0xF0000000,0x000000F0
.text

main:
    la s1, test
    lw a0, 0(s1)
    lw a1, 4(s1)  
    jal ra, palindrome_detected
    li a7, 1
    ecall
    
    lw a0, 8(s1)
    lw a1, 12(s1)  
    jal ra, palindrome_detected
    li a7, 1
    ecall
    
    lw a0, 16(s1)
    lw a1, 20(s1)  
    jal ra, palindrome_detected
    li a7, 1
    ecall
    
    lw a0, 24(s1)
    lw a1, 28(s1)  
    jal ra, palindrome_detected
    li a7, 1
    ecall
       
    # Exit program
    li a7, 10
    ecall
       
palindrome_detected:
    addi sp, sp, -4 
    sw ra, 0(sp)
    jal ra count_leading_zeros
    mv t0, a0
    mv t1, a1
    li t4, 64
    
    sub a2, t4, s0 # a2 = nob = 64 - clz; 
    andi t5, a2, 1  # t5 = checkEven
    srli t4, a2, 1  # t4 = nob >> 1 
    srl t3, t1, t4  # x >> (nob >> 1) (right-half)
    li t6 32
    sub t2, t6 t4 # (32 - nob>>1)
    sll t2, t0, t2 # x >> (nob >> 1) (left-half)
    or t3, t3, t2 # tempX =  x >> (nob >> 1)
    srl t3, t3 , t5  # t3 = tempX

    add t4, t4, t5  # leftShiftNum = (nob>>1) + checkEven 
    add t4, t4, s0  # leftShiftNum += clz
    addi t4, t4, -32
    addi t5, t1, 0
    beq t4,t6, leftShiftNum_equal_32
    sll t2, t1 ,t4 # tempY = (x << leftShiftNum) (left-half);
    srl t5, t2, t4 # tempY = (tempY >> leftShiftNum);
    leftShiftNum_equal_32:
    
    # t2 = reversed number
    li t2, 0    
    li t0, 31
    reverse_loop:
        srli t3, t3, 1 # tempX >>= 1 
        beqz t3, return
        andi t6, t3, 1 
        slli t2, t2, 1
        or t2, t2, t6
        j reverse_loop  
               
    return: 
        beq t2,t5, same # revTempX == tempY
        li a0 0
        lw ra, 0(sp)
        addi sp sp 4
        jr ra
    same:
        li a0 1    
        lw ra, 0(sp)
        addi sp sp 4
        jr ra
        
count_leading_zeros:
    
    mv t1, a1 # t1 = low 32bits
    mv t0, a0 # t0 = high 32bits


    # x |= (x >> 1);
    slli t2, t0, 31 # high 32bits shift left 31
    srli t3, t1, 1 # low 32bits shift right 1
    or t3, t2, t3
    srli t2, t0, 1 # high 32bits shift right 1
    or t0, t0, t2
    or t1, t1, t3
    
    # x |= (x >> 2);
    slli t2, t0, 30
    srli t3, t1, 2
    or t3, t2, t3
    srli t2, t0, 2
    or t0, t0, t2
    or t1, t1, t3
    
    # x |= (x >> 4);
    slli t2, t0, 28
    srli t3, t1, 4
    or t3, t2, t3
    srli t2, t0, 4
    or t0, t0, t2
    or t1, t1, t3
    
    # x |= (x >> 8);
    slli t2, t0, 24
    srli t3, t1, 8
    or t3, t2, t3
    srli t2, t0, 8
    or t0, t0, t2
    or t1, t1, t3
    
    # x |= (x >> 16);
    slli t2, t0, 16
    srli t3, t1, 16
    or t3, t2, t3
    srli t2, t0, 16
    or t0, t0, t2
    or t1, t1, t3
    
    # x |= (x >> 32);
    or t1, t0, t1
    
    # !!!count ones!!!
    # x -= (x>>1) & 0x5555555555555555
    slli t2, t0, 31 # x>>1
    srli t3, t1, 1
    or t3, t2, t3
    srli t2, t0, 1
    li t4, 0x55555555 # & 0x5555555555555555
    and t2, t2, t4
    and t3, t3, t4
    sltu t5, t1, t3 # t5 = borrow bit
    sub t0, t0, t2
    sub t0, t0, t5
    sub t1, t1, t3
    
    # x = ((x >> 2) & 0x3333333333333333) + (x & 0x3333333333333333)
    slli t2, t0, 30 # x>>2
    srli t3, t1, 2
    or t3, t2, t3
    srli t2, t0, 2
    li t4, 0x33333333 # & 0x333333333333333
    and t2, t2, t4
    and t3, t3, t4
    
    and t0, t0, t4 # x & 0x3333333333333333
    and t1, t1, t4
    add t1, t1, t3 # add into x
    sltu t5, t1, t3 # t5 = carry bit
    add t0, t0, t2 
    add t0, t0, t5
    
    # x = ((x >> 4) + x) & 0x0f0f0f0f0f0f0f0f
    slli t2, t0, 28 # (x>>4) + x
    srli t3, t1, 4
    or t3, t2, t3
    srli t2, t0, 4
    add t3, t3, t1
    sltu t5, t3, t1
    add t2, t2, t0
    add t2, t2, t5
    li t4, 0x0f0f0f0f # & 0x0f0f0f0f0f0f0f0f
    and t0, t2, t4
    and t1, t3, t4
    
    # x += (x >> 8)
    slli t2, t0, 24
    srli t3, t1, 8
    or t3, t2, t3
    srli t2, t0, 8
    add t1, t1, t3
    sltu t5, t1, t3 # t5 = carry bit
    add t0, t0, t2
    add t0, t0, t5
    
    # x += (x >> 16)
    slli t2, t0, 16
    srli t3, t1, 16
    or t3, t2, t3
    srli t2, t0, 16
    add t1, t1, t3
    sltu t5, t1, t3 # t5 = carry bit
    add t0, t0, t2
    add t0, t0, t5
    
    # x += (x >> 32)
    mv t2, t0
    add t1, t1, t2
    sltu t5, t1, t2
    add t0, t0, t5
    
    # return (64 - (x & 0x7f))
    andi t1, t1, 0x7f
    li t2, 64
    sub s0, t2, t1 # store clz result in s0
    ret
    

     
    