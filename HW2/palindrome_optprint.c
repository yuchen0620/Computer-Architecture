#include <stdint.h>
#include<stdio.h>
#include <stdbool.h>
#include <inttypes.h>

typedef uint64_t ticks;
static inline ticks getticks(void)
{
    uint64_t result;
    uint32_t l, h, h2;
    asm volatile(
        "rdcycleh %0\n"
        "rdcycle %1\n"
        "rdcycleh %2\n"
        "sub %0, %0, %2\n"
        "seqz %0, %0\n"
        "sub %0, zero, %0\n"
        "and %1, %1, %0\n"
        : "=r"(h), "=r"(l), "=r"(h2));
    result = (((uint64_t) h) << 32) | ((uint64_t) l);
    return result;
}


// count how many zeros forwards input number
uint16_t count_leading_zeros(uint64_t x)
{
    x |= (x >> 1);
    x |= (x >> 2);
    x |= (x >> 4);
    x |= (x >> 8);
    x |= (x >> 16);
    x |= (x >> 32);

    /* count ones (population count) */
    x -= ((x >> 1) & 0x5555555555555555 );
    x = ((x >> 2) & 0x3333333333333333) + (x & 0x3333333333333333);
    x = ((x >> 4) + x) & 0x0f0f0f0f0f0f0f0f;
    x += (x >> 8);
    x += (x >> 16);
    x += (x >> 32);

    return (64 - (x & 0x7f));
}

bool palindrome_detected(uint64_t x){
    
    /* tempX = left half of input x (use to reverse and check) */
    uint16_t clz = count_leading_zeros(x);
    uint64_t nob = (64 - clz);
    uint64_t checkEven = nob & 1;
    uint64_t tempX = (x >> (nob >> 1));
    tempX = (tempX >> checkEven);
    
    /* tempY = right half of input x */
    uint64_t leftShiftNum = (nob >> 1) + checkEven + clz;
    
    uint64_t tempY = (x << leftShiftNum);
    tempY = (tempY >> leftShiftNum);

    /* reverse tempX */
    uint64_t revTempX = 0x0;
    
    while (tempX >>= 1)
    {
        revTempX = ((revTempX << 1) | (tempX & 1));               
    }
    return revTempX == tempY;   
}


int main(){
    ticks t0 = getticks();
    uint64_t testA = 0x0000000000000000; 
    uint64_t testB = 0x0000000000000001; 
    uint64_t testC = 0x00000C0000000003; 
    uint64_t testD = 0x0F000000000000F0; 
    
    printf("%d",palindrome_detected(testA));    
    printf("%d",palindrome_detected(testB));
    printf("%d",palindrome_detected(testC));
    printf("%d",palindrome_detected(testD));
    
    ticks t1 = getticks();
    printf("elapsed cycle: %" PRIu64 "\n", t1 - t0);
     
    return 0;
}
