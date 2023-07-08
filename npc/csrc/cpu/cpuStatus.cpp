#include "common.hpp"
#include <verilated_dpi.h>
#include "dpi_import.hpp"

uint64_t *cpu_gpr_t = NULL;
uint64_t *cpu_curDispCnt;
uint64_t *cpu_curDispPC;
uint32_t *cpu_curDispInst;


// CPURunState cpuState = Running;
CPUState cpuState = {.runState = Running};

CPURunState getCPURunState(){
  return cpuState.runState;
}

void setCPURunState(CPURunState s){
  cpuState.runState = s;
}

uint64_t getCPU_PC(){return cpuState.pc;}
uint64_t getCPU_CNT(){return cpuState.cnt;}
uint32_t getCPU_INST(){return cpuState.inst;}
void updateCPUState(){
  getInstrCntDisp((uint32_t*)(&(cpuState.cnt)));
  getInstCurrentDisp((uint32_t*)(&(cpuState.inst)));
  getPCCurrentDisp((uint32_t*)(&(cpuState.pc)));
}

const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

void dump_dispInfo()
{
  printf("%lu, 0x%lx, 0x%x\n", *cpu_curDispCnt, *cpu_curDispPC, *cpu_curDispInst);
}

extern "C" {
  void set_gpr_ptr(const svOpenArrayHandle r) {
    cpu_gpr_t = (uint64_t *)(((VerilatedDpiOpenVar*)r)->datap());
  }

  void set_disp_ptr(svBitVecVal* a, svBitVecVal* b, svBitVecVal* c) {
    cpu_curDispCnt = (uint64_t*) a;
    cpu_curDispPC = (uint64_t*) b;
    cpu_curDispInst = (uint32_t*) c;
    // cpu_curDispCnt = (uint64_t*)(((VerilatedDpiOpenVar*)a)->datap());
    // cpu_curDispPC = (uint64_t*)(((VerilatedDpiOpenVar*)b)->datap());
    // cpu_curDispInst = (uint32_t*)(((VerilatedDpiOpenVar*)c)->datap());
    dump_dispInfo();
  }
}

// 一个输出RTL中通用寄存器的值的示例
void dump_gpr() {
  int i;
  for (i = 0; i < 32; i++) {
    printf("gpr[%d] = 0x%lx\n", i, cpu_gpr_t[i]);
  }
}



uint64_t isa_reg_str2val(const char *s, bool *success) {
  int i =0;
  for(i=0; i<32; i++){
    if(strcmp(regs[i], s+1) == 0){//why +1? jump $
      // printf("Val: %d(0x%x)\n", gpr(i), gpr(i));
      return cpu_gpr_t[i];
    }
  }
  if(strcmp("$pc", s) == 0){
    return getCPU_PC();
  }
  printf("Err! Reg name %s Mismatch!\n", s+1);
  // assert(0);
  return 0;
}

