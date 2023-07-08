#include <iostream>
#include <string.h>
#include <readline/readline.h>
#include <readline/history.h>

#include "sim.hpp"
#include "cpuStatus.hpp"
#include "Debug.hpp"
#include "sdb.hpp"
#include "mem.hpp"

bool is_batch_mode = false;

static char* rl_gets() {
  static char *line_read = NULL;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(nemu) ");

  if (line_read && *line_read) {
    add_history(line_read);
  }

  return line_read;
}

static int cmd_c(char *args) {
  cpu_exec(-1);
  return 0;
}

static int cmd_q(char *args) {
  setCPURunState(Quit);
  return -1;
}

static int cmd_help(char *args);

static int cmd_si(char *args) {
  // char *arg = strtok(NULL, " ");
  int num;
  if(args == NULL){//default si 1
    cpu_exec(1);
  }
  else {
    num = atoi(args);
    if(num<=0)
        printf("Si N, N must greater than 0\n");
    else
        cpu_exec(num);
  }
  return 0;
}

static int cmd_info(char *args){
//   char *arg= strtok(NULL, " ");
  if((args == NULL) || (args[0] == 'r')){//default si r
    dump_gpr();
  }
  else{//info w
    // listWatchPoint();
  }
  return 0;
}

static int cmd_x(char *args){
  char *arg= strtok(NULL, " ");
  uint32_t num, addr, i;
  assert((arg != NULL));
  addr = 0;
  while(*arg != '\0'){
    addr <<= 4;
    if((*arg >= '0') && (*arg <= '9')){
      addr += (*arg) & 0xf;
    }
    else if((*arg >= 'a') && (*arg <= 'f')){
      addr += (*arg) - 97 +10;
    }
    else{
      assert(0);
    }
    arg += 1;
  }
  arg= strtok(NULL, " ");
  assert((arg != NULL));
  num = atoi(arg);
  assert(num > 0);
  
  
  printf("Check mem!SAddr:0x%x, Check_size:%d\n", addr, num);
  for(i=0; i<num; i++){
    printf("%d(0x%08x)", (int32_t)paddr_read(addr+i*4, 4), (uint32_t)paddr_read(addr+i*4, 4));
    if(i%10==9){
      printf("\n");
    }
    else{
      printf(", ");
    }
  }
  printf("\n");
  return 0;
}

static int cmd_p(char *args)
{
  bool expr_vld;
  uint64_t res = expr(args, &expr_vld);
#ifdef CONFIG_ISA64
  printf("Note: Get a word val from address is sign expanded to Dwords!\n");
  printf("Val: %ld(0x%08x_%08x)\n", (int64_t)res, (uint32_t)(res>>32), (uint32_t)(res));
#else
  printf("Val: %d(0x%08x)\n", (int32_t)res, (uint32_t)res);
#endif
  return 0;
}

static int cmd_px(char *args)
{
  bool expr_vld;
  printf("Val: 0x%08x\n", (uint32_t)expr(args, &expr_vld));
  return 0;
}

static int cmd_w(char *args){
  // bool expr_vld;
  // printf("Val: %d(0x%016x)\n", expr(args, &expr_vld), expr(args, &expr_vld));
#ifdef CONFIG_WATCHPOINT
  addWatchPoint(args);
#else
  printf("Don't support watchPoint! Pelease make menuconfig if you want to use this func!\n");
#endif
  return 0;
}

static int cmd_d(char *args){
  int idx = atoi(args);
  deleteWatchPoint(idx);
  return 0;
}

static struct {
  const char *name;
  const char *description;
  int (*handler) (char *);
} cmd_table [] = {
  { "help", "Display information about all supported commands", cmd_help },
  { "c", "Continue the execution of the program", cmd_c },
  { "q", "Exit NEMU", cmd_q },

  /* TODO: Add more commands */
  { "si", "step n, defualt n = 1", cmd_si},
  { "info", "dump reg and check point information", cmd_info},
  { "x", "get mem data, hex", cmd_x},
  { "p", "printf expr", cmd_p},
  { "p/x", "printf expr on hex parttern", cmd_px},
  { "w", "Add watchpoint!", cmd_w},
  { "d", "Delete watchpoint!", cmd_d}
};


#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");
  int i;

  if (arg == NULL) {
    /* no argument given */
    for (i = 0; i < NR_CMD; i ++) {
      printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
    }
  }
  else {
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(arg, cmd_table[i].name) == 0) {
        printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
        return 0;
      }
    }
    printf("Unknown command '%s'\n", arg);
  }
  return 0;
}

void sdb_set_batch_mode(bool open) {
  is_batch_mode = open;
}

bool sdb_in_batch_mode(){
  return is_batch_mode;
}

void sdb_mainloop() {
  if (is_batch_mode) {
    cmd_c(NULL);
    return;
  }

  for (char *str; (str = rl_gets()) != NULL; ) {
    char *str_end = str + strlen(str);

    /* extract the first token as the command */
    char *cmd = strtok(str, " ");
    if (cmd == NULL) { continue; }

    /* treat the remaining string as the arguments,
     * which may need further parsing
     */
    char *args = cmd + strlen(cmd) + 1;
    if (args >= str_end) {
      args = NULL;
    }

#ifdef CONFIG_DEVICE
    extern void sdl_clear_event_queue();
    sdl_clear_event_queue();
#endif

    int i;
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
        if (cmd_table[i].handler(args) < 0) { return; }
        break;
      }
    }

    if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
  }
}

extern void init_regex();
extern void init_wp_pool();

void init_sdb() {
  /* Compile the regular expressions. */
  init_regex();

  /* Initialize the watchpoint pool. */
  init_wp_pool();
}


