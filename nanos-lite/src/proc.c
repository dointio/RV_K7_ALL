#include <proc.h>

#define MAX_NR_PROC 4

static PCB pcb[MAX_NR_PROC] __attribute__((used)) = {};
static PCB pcb_boot = {};
PCB *current = NULL;

void switch_boot_pcb() {
  current = &pcb_boot;
}

void hello_fun(void *arg) {
  int j = 1;
  while (1) {
    // Log("Hello World from Nanos-lite with arg '%s' for the %dth time!", (uintptr_t)arg, j);
    j ++;
    yield();
  }
}

void context_kload(PCB *pcb, void (*entry)(void *),  void *arg);
bool context_uload(PCB *pcb, const char *filename, char *const argv[], char *const envp[]);
void naive_uload(PCB *pcb, const char *filename);
char test_arg1[] = "/bin/nterm";
char test_arg2[] = "/bin/exec-test";
char *system_args[4] = {test_arg1, NULL};
char envp_one[] = "PATH=/bin:/usr:/usr/bin";
char *system_envp[5] = {envp_one, NULL};
void init_proc() {
  context_kload(&pcb[0], hello_fun, "hello,thread_one !");
  // context_uload(&pcb[1], "/bin/nslider");
  // context_uload(&pcb[1], "/bin/nslider", NULL, NULL);
  // context_uload(&pcb[1], "/bin/pal", system_args, NULL);
  // context_uload(&pcb[1], "/bin/exec-test", system_args, NULL);
  // context_uload(&pcb[1], "/bin/menu", NULL, NULL);
  context_uload(&pcb[1], "/bin/nterm", NULL, system_envp);
  switch_boot_pcb();
  // naive_uload(NULL, "/bin/hello");
  // naive_uload(NULL, "/bin/file-test");
  // naive_uload(NULL, "/bin/timer-test-zxp");
  // naive_uload(NULL, "/bin/event-test");
  // naive_uload(NULL, "/bin/bmp-test");
  // naive_uload(NULL, "/bin/nslider");
  // naive_uload(NULL, "/bin/menu");
  // naive_uload(NULL, "/bin/bird");
  // naive_uload(NULL, "/bin/pal");
  Log("Initializing processes...");

  // load program here

}

Context* schedule(Context *prev) {
  // printf("fff:%p\n", current);
  // printf("fff:%p\n", prev);
  // printf("NIMa:%p\n", pcb[1].cp);
  //save the contxt pointer
  current->cp = prev;
  //always select pcb[0]
  // current = &pcb[0];
  current = (current == &pcb[0]) ? &pcb[1] : &pcb[0];
  // printf("Entry1:%lx\n", pcb[0].cp->mepc);
  // printf("NIMa:%p\n", pcb[1].cp);
  // printf("Entry2:%lx\n", pcb[1].cp->mepc);
  //then return the new context
  return current->cp;
}
