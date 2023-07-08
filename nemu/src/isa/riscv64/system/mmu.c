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
#include <memory/vaddr.h>
#include <memory/paddr.h>

// word_t satp; //63:60,MODE   59:44,ASID    43:0,PPN
#define SATP_MODE (cpu.satp >> 60)
#define SATP_PPN  ((cpu.satp & ((1ul<<44)-1)) << 12)
int isa_mmu_check(vaddr_t vaddr, int len, int type)
{
  if(SATP_MODE == 8){ //Sv39
    return MMU_TRANSLATE;
  }
  else if(SATP_MODE == 9){ //Sv48, not used
    return MMU_DIRECT;
  }
  else{ //No Translation and Protection
    return MMU_DIRECT;
  }
}

#define VPN_ADDR(tiaomu)  (((tiaomu>>10)&0xfffffffffff) << 12)
#define VPN2_IDX(vaddr)   (((vaddr>>30)&0x1ff) << 3)
#define VPN1_IDX(vaddr)   (((vaddr>>21)&0x1ff) << 3)
#define VPN0_IDX(vaddr)   (((vaddr>>12)&0x1ff) << 3)
paddr_t isa_mmu_translate(vaddr_t vaddr, int len, int type) {
  word_t tiaomu2 = paddr_read(SATP_PPN + VPN2_IDX(vaddr), 8);
  word_t tiaomu1 = paddr_read(VPN_ADDR(tiaomu2) + VPN1_IDX(vaddr), 8);
  word_t tiaomu0 = paddr_read(VPN_ADDR(tiaomu1) + VPN0_IDX(vaddr), 8);
  return VPN_ADDR(tiaomu0) + (vaddr & 0xfff);
  // return MEM_RET_FAIL;
}
