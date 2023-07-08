

#include <stdint.h>

// #include "../include/gpio.h"
// #include "../include/utils.h"

#define GPIO_REG(addr) (*((volatile uint32_t *)addr))

static int cordic_cos(int ang)
{
    int cosres;
    asm volatile(
        ".insn r 0x7b, 6, 6, %0, %1, x0"
            : "=r"(cosres)
            : "r"(ang)
    );
    return cosres;
}

int main()
{
    unsigned int gpio_val = 1;
    unsigned int gpio_ptr = 0x10012000;
    unsigned int i = 1;
    unsigned int j = 1;
    GPIO_REG(gpio_ptr) = gpio_val;
    int angle = 45<<16;
    int a_cos_res = 0xf2;
    a_cos_res = cordic_cos(angle);
    while (1) {
        for(i=0; i<30; i++) {
            for(j=0; j<20; j++) {
            }
        }
        if(gpio_val == 16) {
            gpio_val = 1;
        }
        else {
            gpio_val = gpio_val << 1;
        }
        GPIO_REG(gpio_ptr) = gpio_val;
    }
}

