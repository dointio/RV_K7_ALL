#include <am.h>
#include <riscv/riscv.h>
#include <klib.h>

static Context* (*user_handler)(Event, Context*) = NULL;

Context* __am_irq_handle(Context *c) {
  // uint32_t inc4 = 0;
  // printf("mmm:%s\n", (char*)(0x830134e0));
  if (user_handler) {
    Event ev = {0};
    
  #if __riscv_xlen == 32
    switch (c->mcause) {
      case 0xb: ev.event = EVENT_YIELD; inc4 = 4; break;
      default: ev.event = EVENT_ERROR; break;
    }
  #else
    switch (c->mcause) {
      // case 0xb: ev.event = EVENT_YIELD; inc4 = 4; break;
      case 0xb: ev.event = EVENT_SYSCALL; /*inc4 = 4;*/ break;
      default: ev.event = EVENT_ERROR; break;
    }
  #endif

    c = user_handler(ev, c);
    assert(c != NULL);
  }
  // c->mepc += inc4;
  return c;
}

extern void __am_asm_trap(void);

bool cte_init(Context*(*handler)(Event, Context*)) {
  // initialize exception entry
  asm volatile("csrw mtvec, %0" : : "r"(__am_asm_trap));

  // register event handler
  user_handler = handler;

  return true;
}

#define ROUNDUP(a, sz)      ((((uintptr_t)a) + (sz) - 1) & ~((sz) - 1))
#define ROUNDDOWN(a, sz)    ((((uintptr_t)a)) & ~((sz) - 1))

Context *kcontext(Area kstack, void (*entry)(void *), void *arg) {
  void *contextPtr = kstack.end-sizeof(Context);
  Context *cptr = (Context*)(ROUNDDOWN(contextPtr, sizeof(long long)));
  cptr->mepc = (uintptr_t)entry;
  //o: a0=x10(a0 store arg ptr)
  cptr->gpr[10] = (uintptr_t)arg;
  //o: end
  cptr->mcause = 0;
#if __riscv_xlen == 32
  cptr->mstatus = 0x1800;
#else
  cptr->mstatus = 0xa0001800;
#endif
  return cptr;
}

Context *ucontext(AddrSpace *as, Area ustack, void *entry){
  void *contextPtr = ustack.end-sizeof(Context);
  Context *cptr = (Context*)(ROUNDDOWN(contextPtr, sizeof(long long)));
  cptr->mepc = (uintptr_t)entry;
  cptr->mcause = 0;
#if __riscv_xlen == 32
  cptr->mstatus = 0x1800;
#else
  cptr->mstatus = 0xa0001800;
#endif
  return cptr;
}

void yield() {
  asm volatile("li a7, 1; ecall");
  // asm volatile("li a7, -1; ecall");
}

bool ienabled() {
  return false;
}

void iset(bool enable) {
}
