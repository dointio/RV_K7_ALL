#ifndef __SYSCALL_H__
#define __SYSCALL_H__

enum {
  SYS_exit,
  SYS_yield, //1
  SYS_open,
  SYS_read, //3
  SYS_write,
  SYS_kill,
  SYS_getpid,
  SYS_close,
  SYS_lseek, //8
  SYS_brk,
  SYS_fstat,
  SYS_time,
  SYS_signal,
  SYS_execve,
  SYS_fork,
  SYS_link,
  SYS_unlink,
  SYS_wait,
  SYS_times,
  SYS_gettimeofday
};

#endif
