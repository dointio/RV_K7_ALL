#include <stdint.h>
#include <stdlib.h>
#include <assert.h>

static inline void outb(uintptr_t addr, uint8_t  data) { *(volatile uint8_t  *)addr = data; }

int main(int argc, char *argv[], char *envp[]);
extern char **environ;
void call_main(uintptr_t *args) {
  // printf("ArgsPtr:%p\n", args);
  int argc = *args;
  char **argv = (char**)(args+1);
  char **envp = (char**)(argv + argc + 1);
  environ = envp;
  // printf("ArgCnt:%d\n", argc);
  // printf("Envp1:%s\n", *envp);
  // printf("Arg1:%s\n", (char*)(*argv));
  // printf("Arg1:%s\n", (char*)(*(argv+1)));

  exit(main(argc, argv, envp));
  assert(0);

  // char *empty[] =  {NULL };
  // environ = empty;
  // exit(main(0, empty, empty));
  // assert(0);
}
