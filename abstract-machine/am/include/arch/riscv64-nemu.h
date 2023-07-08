#ifndef ARCH_H__
#define ARCH_H__

struct Context {
  // TODO: fix the order of these members to match trap.S
  // uintptr_t mepc, mcause, gpr[32], mstatus;
  
  uintptr_t gpr[32];
  uintptr_t mcause;
  uintptr_t mstatus;
  uintptr_t mepc;
  void *pdir;
};

// #define GPRA0 gpr[10]
// #define GPRA1 gpr[11] 
// #define GPRA2 gpr[12]
// #define GPRA3 gpr[13]
// #define GPRA4 gpr[14]
// #define GPRA5 gpr[15]
// #define GPRA6 gpr[16]
// #define GPRA7 gpr[17]

#define GPR1 gpr[17] // a7
#define GPR2 gpr[10]
#define GPR3 gpr[11]
#define GPR4 gpr[12]
#define GPRx gpr[10]
#define MEPC mepc
#endif
