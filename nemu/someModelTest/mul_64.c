#include <stdio.h>
#include <stdint.h>

uint64_t mul64_l(uint64_t a, uint64_t b)
{
    uint64_t a_l = a & 0xffffffff;
    uint64_t a_h = (a>>32)&0xffffffff;
    uint64_t b_l = b & 0xffffffff;
    uint64_t b_h = (b>>32)&0xffffffff;
    uint64_t num1 = a_l * b_l;
    uint64_t num2 = (a_h * b_l) << 32;
    uint64_t num3 = (b_h * a_l) << 32;
    
    return (num1 + num2 + num3);
}

uint64_t mul64_h(uint64_t a, uint64_t b)
{
    uint64_t a_l = a & 0xffffffff;
    uint64_t a_h = (a>>32)&0xffffffff;
    uint64_t b_l = b & 0xffffffff;
    uint64_t b_h = (b>>32)&0xffffffff;
    uint64_t num1 = a_h * b_h;
    uint64_t num2 = (a_h * b_l) >> 32;
    uint64_t num3 = (b_h * a_l) >> 32;
    
    return (num1 + num2 + num3);
}

int main()
{
    uint64_t a, b;
    a = 2000000000000000001;
    b = 40000000000000000;

    printf("Answer1: %16lx, answer2: %16lx\n", mul64_h(a, b), mul64_l(a, b));
    printf("Answer1: %lu, answer2: %lu\n", mul64_h(a, b), mul64_l(a, b));
}