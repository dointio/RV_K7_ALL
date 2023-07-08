#include "common.h"
#include <memory/paddr.h>
#include <isa.h>
#include <cpu/cpu.h>


void init_rand();
void init_mem();

void def_nemu_init()
{
  init_rand();
  init_mem();
}

//o: direction: 0,to dut; 1,to ref
void def_nemu_memcpy(uint64_t addr, void *buf, uint64_t n, bool direction)
{
    uint8_t *ptr_buf = buf;
    uint64_t i=0;
    if(direction){
        for(i=0; i<n; i++){
            paddr_write(addr, 1, *ptr_buf);
            ptr_buf++;
            addr += 1;
        }
    }
    else{
        for(i=0; i<n; i++){
            *ptr_buf = (uint8_t)paddr_read(addr, 1);
            ptr_buf++;
            addr += 1;
        }
    }
}

//o: direction=0,to dut; direction=1,to ref
void def_nemu_regcpy(void *dut, bool direction)
{
    int i = 0;
    word_t* regptr=dut;
    if(direction){
        for(i=0; i<32; i++){
            cpu.gpr[i] = *regptr;
            regptr++;
        }
    }
    else{
        for(i=0; i<32; i++){
            *regptr = cpu.gpr[i];
            regptr++;
        }
    }
}


void def_nemu_exec(uint64_t n){
    cpu_exec(n);
}

