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
#include "local-include/reg.h"

word_t getCSR(uint32_t caddr){
  switch (caddr) {
    case 0x300: return cpu.mstatus;
    case 0x304: return cpu.mie;
    case 0x344: return cpu.mip;
    case 0x305: return cpu.mtvec;
    case 0x341: return cpu.mepc;
    case 0x342: return cpu.mcause;
    case 0x343: return cpu.badaddr;
    default: Assert(0, "Error! Get CSR not implemented! Addr: %x\n", caddr); return 0;
  }
}

void setCSR(uint32_t caddr, word_t val){
  switch (caddr) {
    case 0x300: cpu.mstatus = val; break;
    case 0x304: cpu.mie = val; break;
    case 0x344: cpu.mip= val; break;
    case 0x305: cpu.mtvec= val; break;
    case 0x341: cpu.mepc= val; break;
    case 0x342: cpu.mcause= val; break;
    case 0x343: cpu.badaddr= val; break;
    default: Assert(0, "Error! Get CSR not implemented! Addr: %x\n", caddr); break;
  }
}

const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

void isa_reg_display() {
  int i = 0;
  printf("The Val of Reg is:\n");
  for(i=0; i<32; i++){
    printf("R[%d](%s): %8x", i, regs[i], gpr(i));
    if(i%8==7){
      printf("\n");
    }
    else{
      printf(", ");
    }
  }
}

word_t isa_reg_str2val(const char *s, bool *success) {
  int i =0;
  for(i=0; i<32; i++){
    if(strcmp(regs[i], s+1) == 0){//why +1? jump $
      // printf("Val: %d(0x%x)\n", gpr(i), gpr(i));
      return gpr(i);
    }
  }
  if(strcmp("$pc", s) == 0){
    return cpu.pc;
  }
  printf("Err! Reg name %s Mismatch!\n", s+1);
  // assert(0);
  return 0;
}
