#include <common.h>
#include "proc.h"
#include "syscall.h"
#include "fs.h"

#define GPRret c->GPRx

Context* do_syscall(Context *c) {
  uintptr_t a[4];
  a[0] = c->GPR1;
  a[1] = c->GPR2;
  a[2] = c->GPR3;
  a[3] = c->GPR4;
  
  c->MEPC += 4; // // //r: it need to be set in the abstract-machine!!!
  switch (a[0]) {
    case SYS_exit:
      Context* sys_execve(const char *filename, char *const argv[], char *const envp[], Context *prev);
      c = sys_execve("/bin/nterm", NULL, system_envp, c);
      break;
    case SYS_yield:
      GPRret = 0;
      Context* schedule(Context *prev);
      c = schedule(c);
      break;
    case SYS_brk:
      GPRret = 0;
      break;
    case SYS_write:
      GPRret = fs_write(a[1], (void*)a[2], a[3]);
      c = schedule(c);
      break;
    case SYS_read:
      GPRret = fs_read(a[1], (void*)a[2], a[3]);
      c = schedule(c);
      break;
    case SYS_open:
      GPRret = fs_open((char*)a[1], a[2], a[3]);
      c = schedule(c);
      break;
    case SYS_close:
      GPRret = fs_close(a[1]);
      c = schedule(c);
      break;
    case SYS_lseek:
      GPRret = fs_lseek(a[1], a[2], a[3]);
      break;
    case SYS_execve:
      Context* sys_execve(const char *filename, char *const argv[], char *const envp[], Context *prev);
      c = sys_execve((const char*)a[1], (void*)a[2], (void*)a[3], c);
      break;
    case SYS_gettimeofday:
      AM_TIMER_UPTIME_T t = io_read(AM_TIMER_UPTIME);
      GPRret = t.us;
      break;

    default: panic("Unhandled syscall ID = %d", a[0]);
  }
  return c;
}
