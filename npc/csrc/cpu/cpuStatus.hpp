#ifndef __CPUSTATUS_HPP__
#define __CPUSTATUS_HPP__

#include "common.hpp"

extern uint64_t *cpu_gpr_t;
extern uint64_t *cpu_curDispCnt;
extern uint64_t *cpu_curDispPC;
extern uint32_t *cpu_curDispInst;

CPURunState getCPURunState();
void setCPURunState(CPURunState s);
uint64_t getCPU_PC();
uint64_t getCPU_CNT();
uint32_t getCPU_INST();
void updateCPUState();


void dump_gpr();
void dump_dispInfo();
uint64_t isa_reg_str2val(const char *s, bool *success);

#endif
