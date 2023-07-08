#include <amtest.h>

Context *simple_trap(Event ev, Context *ctx) {
  switch(ev.event) {
    case EVENT_IRQ_TIMER:
      putch('t'); putch('\n'); 
      uint64_t time_val = io_read(AM_TIMER_UPTIME).us;
      // printf("T:%ld\n", time_val);
      io_write(AM_TIMER_CMP_W, time_val+20);
      break;
    case EVENT_IRQ_IODEV:
      putch('d'); putch('\n'); break;
    case EVENT_YIELD:
      putch('y'); putch('\n'); break;
    default:
      printf("%d\n", ev.event);
      break;
  }
  return ctx;
}

void hello_intr() {
  printf("Hello, AM World @ " __ISA__ "\n");
  printf("  t = timer, d = device, y = yield\n");
  io_read(AM_INPUT_CONFIG);
  // asm volatile("csrci mstatus, %0" : : "i"(1<<3));
  // asm volatile("csrci counterstop, %0" : : "i"(1<<3));
  asm volatile ("csrw 0xbff , %0" : : "i"(1<<1));
  // iset(1);
  // iset_soft(1);
  // iset_timer(1);
  // iset_ext(1);
  // if(ienabled()){
  //   printf("Open mie_all!\n");
  // }
  // if(ienabled_soft()){
  //   printf("Open mie_soft!\n");
  // }
  // if(ienabled_timer()){
  //   printf("Open mie_timer!\n");
  // }
  // if(ienabled_ext()){
  //   printf("Open mie_ext!\n");
  // }
  // // while (1) {
  //   io_write(AM_TIMER_CMP_W, 5);    
  //   for (volatile int i = 0; i < 1000; i++) ;
  //   yield();
  // // }
}
