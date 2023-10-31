#include <stdio.h>
#include <stdint.h>
uint16_t count_leading_zeros(uint64_t x)
{
    x |= (x >> 1);
    x |= (x >> 2);
    x |= (x >> 4);
    x |= (x >> 8);
    x |= (x >> 16);
    x |= (x >> 32);
       
    /* count ones (population count) */
    x -= ((x >> 1) & 0x5555555555555555  );
    x = ((x >> 2) & 0x3333333333333333) + (x & 0x3333333333333333 );
    x = ((x >> 4) + x) & 0x0f0f0f0f0f0f0f0f;
    x += (x >> 8);
    x += (x >> 16);
    x += (x >> 32);

    return (64 - (x & 0x7f));
}

uint64_t generate_bitmask(uint64_t x)
{
    
    uint16_t leading_zeros = count_leading_zeros(x); 
    if (leading_zeros==64) return 0;
    return 0xffffffffffffffff >> leading_zeros;
}
int main()
{   
    uint64_t test_data[] = {0, 4, 0x8000000000000000};
    for (int i = 0; i < 3; i++){
        printf("The reslut of %llx is %llx\n", test_data[i], generate_bitmask(test_data[i]));
    }
}


