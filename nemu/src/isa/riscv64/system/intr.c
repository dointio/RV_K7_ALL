/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <isa.h>
#include <debug.h>

word_t isa_raise_intr(word_t NO, vaddr_t epc) {
  /* TODO: Trigger an interrupt/exception with ``NO''.
   * Then return the address of the interrupt/exception vector.
  */
#ifdef CONFIG_ETRACE
#ifdef CONFIG_ISA64
  log_excp_write("Excp! MCAUSE:%lx", NO);
  log_write("Excp! MCAUSE:%lx", NO);
#else
  log_excp_write("Excp! MCAUSE:%x", NO);
  log_write("Excp! MCAUSE:%x", NO);
#endif
#endif
  cpu.mcause = NO;
  cpu.mepc = epc;
  cpu.mstatus &= ~0x80;
  cpu.mstatus |= ((cpu.mstatus&0x8)<<4);
  cpu.mstatus &= ~0x8;
  if(NO & ((uint64_t)1<<63)){
    // uint64_t excpCode = NO & (~((uint64_t)1<<63));
    // uint64_t iloacl = 1<<excpCode;
    // if (cpu.mie & iloacl){
    //   cpu.mip |= iloacl;
    // }
    // if(excpCode>=0 && excpCode < 4){
        
    // }
    // else {
      Assert(0, "Error! Don't implement interrupt!!\n");
    // }
  }
  else {
    if(NO == 0xb){

    }
    else{
      Assert(0, "Error! Don't implement exception!!\n");
    }
  }
  return cpu.mtvec;
}

vaddr_t isa_mret_intr()
{
  cpu.mstatus &= ~0x8;
  cpu.mstatus |= ((cpu.mstatus&0x80) >> 4);
  return cpu.mepc;
}

word_t isa_query_intr() {
  return INTR_EMPTY;
}
