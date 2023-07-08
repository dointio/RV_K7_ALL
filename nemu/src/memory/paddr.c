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

#include <memory/host.h>
#include <memory/paddr.h>
#include <device/mmio.h>
#include <isa.h>

#if   defined(CONFIG_PMEM_MALLOC)
static uint8_t *pmem = NULL;
#else // CONFIG_PMEM_GARRAY
static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {};
#endif

uint8_t* guest_to_host(paddr_t paddr) { return pmem + paddr - CONFIG_MBASE; }
paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + CONFIG_MBASE; }

static word_t pmem_read(paddr_t addr, int len) {
  word_t ret = host_read(guest_to_host(addr), len);
  return ret;
}

static void pmem_write(paddr_t addr, int len, word_t data) {
  host_write(guest_to_host(addr), len, data);
}

static void out_of_bound(paddr_t addr) {
  panic("address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD,
      addr, PMEM_LEFT, PMEM_RIGHT, cpu.pc);
}

void init_mem() {
#if   defined(CONFIG_PMEM_MALLOC)
  pmem = malloc(CONFIG_MSIZE);
  assert(pmem);
#endif
#ifdef CONFIG_MEM_RANDOM
  uint32_t *p = (uint32_t *)pmem;
  int i;
  for (i = 0; i < (int) (CONFIG_MSIZE / sizeof(p[0])); i ++) {
    p[i] = rand();
  }
#endif
  Log("physical memory area [" FMT_PADDR ", " FMT_PADDR "]", PMEM_LEFT, PMEM_RIGHT);
}

//r:zxp add paddr_fetch
word_t paddr_fetch(paddr_t addr, int len) {
  word_t rVal;
  if (likely(in_pmem(addr))) {
    rVal = pmem_read(addr, len);
    return rVal;
  }
  out_of_bound(addr);
  return 0;
}

word_t paddr_read(paddr_t addr, int len) {
  word_t rVal;
  if (likely(in_pmem(addr))) {
    rVal = pmem_read(addr, len);
#ifdef CONFIG_MTRACE
#ifdef CONFIG_ISA64
  log_mem_write("MemRd! Addr:0x%lx, Len:%d, Data:%ld(0x%lx, %c)\n", (int64_t)addr, len, rVal, rVal, (char)rVal);
  log_write("MemRd! Addr:0x%lx, Len:%d, Data:0x%ld(0x%lx, %c)\n", (int64_t)addr, len, rVal, rVal, (char)rVal);
#else
  log_mem_write("MemRd! Addr:0x%x, Len:%d, Data:%ld(0x%x, %c)\n", (int32_t)addr, len, rVal, rVal, (char)rVal);
  log_write("MemRd! Addr:0x%x, Len:%d, Data:%ld(0x%x, %c)\n", (int32_t)addr, len, rVal, rVal, (char)rVal);
#endif
#endif
    return rVal;
  }
  IFDEF(CONFIG_DEVICE, 
  {
    rVal = mmio_read(addr, len);
#ifdef CONFIG_DTRACE
#ifdef CONFIG_ISA64
  log_pes_write("PesRd! Addr:0x%lx, Len:%d, Data:%ld(0x%lx, %c)\n", (int64_t)addr, len, rVal, rVal, (char)rVal);
  log_write("PesRd! Addr:0x%lx, Len:%d, Data:0x%ld(0x%lx, %c)\n", (int64_t)addr, len, rVal, rVal, (char)rVal);
#else
  log_pes_write("PesRd! Addr:0x%x, Len:%d, Data:%ld(0x%x, %c)\n", (int32_t)addr, len, rVal, rVal, (char)rVal);
  log_write("PesRd! Addr:0x%x, Len:%d, Data:%ld(0x%x, %c)\n", (int32_t)addr, len, rVal, rVal, (char)rVal);
#endif
#endif
    return rVal;
  });
  out_of_bound(addr);
  return 0;
}

void paddr_write(paddr_t addr, int len, word_t data) {
  if (likely(in_pmem(addr))) { 
#ifdef CONFIG_MTRACE
#ifdef CONFIG_ISA64
  log_mem_write("MemWr! Addr:0x%lx, Len:%d, Data:%ld(0x%lx, %c)\n", (int64_t)addr, len, (int64_t)data, (int64_t)data, (char)data);
  log_write("MemWr! Addr:0x%lx, Len:%d, Data:%ld(0x%lx, %c)\n", (int64_t)addr, len, (int64_t)data, (int64_t)data, (char)data);
#else
  log_mem_write("MemWr! Addr:0x%x, Len:%d, Data:%d(0x%x, %c)\n", (int32_t)addr, len, (int32_t)data, (int32_t)data, (char)data);
  log_write("MemWr! Addr:0x%x, Len:%d, Data:%d(0x%x, %c)\n", (int32_t)addr, len, (int32_t)data, (int32_t)data, (char)data);
#endif
#endif
    pmem_write(addr, len, data); 
    return; 
  }
  IFDEF(CONFIG_DEVICE, {
#ifdef CONFIG_DTRACE
#ifdef CONFIG_ISA64
  log_pes_write("PesWr! Addr:0x%lx, Len:%d, Data:%ld(0x%lx, %c)\n", (int64_t)addr, len, (int64_t)data, (int64_t)data, (char)data);
  log_write("PesWr! Addr:0x%lx, Len:%d, Data:%ld(0x%lx, %c)\n", (int64_t)addr, len, (int64_t)data, (int64_t)data, (char)data);
#else
  log_pes_write("PesWr! Addr:0x%x, Len:%d, Data:%d(0x%x, %c)\n", (int32_t)addr, len, (int32_t)data, (int32_t)data, (char)data);
  log_write("PesWr! Addr:0x%x, Len:%d, Data:%d(0x%x, %c)\n", (int32_t)addr, len, (int32_t)data, (int32_t)data, (char)data);
#endif
#endif
    mmio_write(addr, len, data); 
    return;
  });
  out_of_bound(addr);
}
