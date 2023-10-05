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

int main()
{   
    int y = count_leading_zeros(0);
    printf("%d",y);
}