#include <stdio.h>
#include <stdint.h>
uint16_t count_leading_zeros(uint32_t x)
{
    x |= (x >> 1);
    x |= (x >> 2);
    x |= (x >> 4);
    x |= (x >> 8);
    x |= (x >> 16);

    /* count ones (population count) */
    x -= ((x >> 1) & 0x55555555  );
    x = ((x >> 2) & 0x33333333) + (x & 0x33333333 );
    x = ((x >> 4) + x) & 0x0f0f0f0f;
    x += (x >> 8);
    x += (x >> 16);
   
    return (32 - (x & 0x3f));
}

uint32_t generate_bitmask(uint32_t x)
{
    uint32_t leading_zeros = count_leading_zeros(x);
    if (leading_zeros==0) return 0xffffffff;
    return (1 << (32 - leading_zeros)) - 1 ;
}
int main()
{   
    uint32_t test_data[] = {0, 4, 0x80000000};
    for (int i = 0; i < 3; i++){
        printf("The reslut of %x is %x\n", test_data[i],generate_bitmask(test_data[i]));
    }
}


