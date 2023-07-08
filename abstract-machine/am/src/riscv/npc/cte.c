#include <am.h>
#include <klib.h>

static Context* (*user_handler)(Event, Context*) = NULL;

Context* __am_irq_handle(Context *c) {
  // uint32_t inc4 = 0;

  if (user_handler) {
    Event ev = {0};
    
  #if __riscv_xlen == 32
    switch (c->mcause) {
      case 0xb: ev.event = EVENT_YIELD; break;
      default: ev.event = EVENT_ERROR; break;
    }
  #else
    switch (c->mcause) {
      case 0xb: ev.event = EVENT_YIELD; break;
      case 0x8000000000000003: ev.event = EVENT_IRQ_SOFT; break;
      case 0x8000000000000007: ev.event = EVENT_IRQ_TIMER; break;
      case 0x800000000000000b: ev.event = EVENT_IRQ_IODEV; break;
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

Context *kcontext(Area kstack, void (*entry)(void *), void *arg) {
  return NULL;
}

void yield() {
  asm volatile("li a7, -1; ecall");
}

bool ienabled() {
  uint32_t mstatus_d;
  asm volatile("csrr %0, mstatus" : "=r"(mstatus_d));
  if(mstatus_d & (1<<3)){
    return true;
  }
  else{
    return false;
  }
}

void iset(bool enable) {
  if(enable) {
    asm volatile("csrsi mstatus, %0" : : "i"(1<<3));
  }
  else {
    asm volatile("csrci mstatus, %0" : : "i"(1<<3));
  }  
}

bool     ienabled_soft  (void)
{
  uint32_t mstatus_d;
  asm volatile("csrr %0, mie" : "=r"(mstatus_d));
  if(mstatus_d & (1<<3)){
    return true;
  }
  else{
    return false;
  }
}

void     iset_soft      (bool enable)
{
  if(enable) {
    asm volatile("csrsi mie, %0" : : "i"(1<<3));
  }
  else {
    asm volatile("csrci mie, %0" : : "i"(1<<3));
  } 
}

bool     ienabled_timer (void)
{
  uint32_t mstatus_d;
  asm volatile("csrr %0, mie" : "=r"(mstatus_d));
  if(mstatus_d & (1<<7)){
    return true;
  }
  else{
    return false;
  }
}

void     iset_timer     (bool enable)
{
  if(enable) {
    asm volatile("csrs  mie, %0" : : "r"(1<<7));
  }
  else {
    asm volatile("csrc  mie, %0" : : "r"(1<<7));
  } 
}

bool     ienabled_ext   (void)
{
  uint32_t mstatus_d;
  asm volatile("csrr %0, mie" : "=r"(mstatus_d));
  if(mstatus_d & (1<<11)){
    return true;
  }
  else{
    return false;
  }
}

void     iset_ext       (bool enable)
{
  if(enable) {
    asm volatile("csrs  mie, %0" : : "r"(1<<11));
  }
  else {
    asm volatile("csrc  mie, %0" : : "r"(1<<11));
  } 
}
