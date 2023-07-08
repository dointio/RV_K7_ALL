

#include <stdint.h>

// #include "../include/gpio.h"
// #include "../include/utils.h"

#define GPIO_REG(addr) (*((volatile uint32_t *)addr))

int main()
{
    unsigned int gpio_val = 1;
    unsigned int gpio_ptr = 0x10012000;
    unsigned int i = 1;
    unsigned int j = 1;
    GPIO_REG(gpio_ptr) = gpio_val;
    while (1) {
        for(i=0; i<500; i++) {
            for(j=0; j<1700; j++) {
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

