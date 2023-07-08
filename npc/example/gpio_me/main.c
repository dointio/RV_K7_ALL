

#include <stdint.h>

// #include "../include/gpio.h"
// #include "../include/utils.h"

#define GPIO_REG(addr) (*((volatile uint32_t *)addr))
#define UART_REG(addr) (*((volatile uint32_t *)addr))
static inline uint8_t  inb(uintptr_t addr) { return *(volatile uint8_t  *)addr; }
static inline uint16_t inw(uintptr_t addr) { return *(volatile uint16_t *)addr; }
static inline uint32_t inl(uintptr_t addr) { return *(volatile uint32_t *)addr; }

static inline void outb(uintptr_t addr, uint8_t  data) { *(volatile uint8_t  *)addr = data; }
static inline void outw(uintptr_t addr, uint16_t data) { *(volatile uint16_t *)addr = data; }
static inline void outl(uintptr_t addr, uint32_t data) { *(volatile uint32_t *)addr = data; }
void halt(int code) {
  asm volatile("mv a0, %0; ebreak" : :"r"(code));
  while (1);
}

#define MAX_PIX_CNT 800*600


int main()
{
    unsigned int gpio_val = 1;
    uint64_t addr_off = 800*300;
    uint32_t data_off = 0;
    uint32_t data_off_2 = 0;
    uint64_t gpio_ptr = 0xa0012000;
    unsigned int i = 1;
    unsigned int j = 1;
    GPIO_REG(gpio_ptr) = gpio_val;
    data_off = 0x00ff00;

    while (1) {
        data_off_2 += 0xf0;
        if(data_off_2 > 0xffff){
            data_off_2 = 0;
        } 
        while(1) {
            outl(0xf0000000+(addr_off<<2), data_off + data_off_2);
            if(addr_off == 600*100-1){
                data_off = 0x0000ff;
            }
            else if(addr_off == 600*200-1){
                data_off = 0xff0000;
            }
            else if(addr_off == 600*300-1){
                data_off = 0x00ff00;
            }
            else if(addr_off == 800*400-1){
                data_off = 0x0000ff;
            }
            else if(addr_off == 800*500-1){
                data_off = 0xff0000;
            }
            else if(addr_off == 800*600-1){
                data_off = 0x00ff00;
            }
            addr_off += 1;
            if(addr_off >= MAX_PIX_CNT){
                addr_off = 0;
                break;
            }
        }
    //     // for(i=0; i<400; i++) {
    //     //     for(j=0; j<400; j++) {
    //     //     }
    //     // }
        if(gpio_val == 16) {
            gpio_val = 1;
        }
        else {
            gpio_val = gpio_val << 1;
        }
        GPIO_REG(gpio_ptr) = gpio_val;
    }
    halt(1);
}
