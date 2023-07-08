#include <nterm.h>
#include <stdarg.h>
#include <unistd.h>
#include <SDL.h>
#include <string.h>
#include <malloc.h>

char handle_key(SDL_Event *ev);

static void sh_printf(const char *format, ...) {
  static char buf[256] = {};
  va_list ap;
  va_start(ap, format);
  int len = vsnprintf(buf, 256, format, ap);
  va_end(ap);
  term->write(buf, len);
}

static void sh_banner() {
  sh_printf("Built-in Shell in NTerm (NJU Terminal)\n\n");
}

static void sh_prompt() {
  sh_printf("sh> ");
}

//r: run cmd here!
#define MAX_CMD_ARGC 10
static void sh_handle_cmd(const char *cmd) {
  // char *buf = (char*)malloc(strlen(cmd)+1);
  char buf[256];
  strcpy(buf, cmd);
  char *argv[MAX_CMD_ARGC+1]; //max param cnt = MAX_CMD_ARGC
  char *p = strtok(buf, " ");
  int i = 0;
  if(p){//r: the first cmd is app name, it's also the arg_1
    argv[i++] = p;
  }
  else{ //cmd is empty
    //o: no exec
    return;
  }
  while(p = strtok(NULL, " ")){
    argv[i++] = p;
    if(i > MAX_CMD_ARGC){
      sh_printf("Args is so long(greater than %d), cannot run cmd", MAX_CMD_ARGC);
      return;
    }
  }
  argv[i] = nullptr;

  // printf("Buf:%s\n", buf);
  // for(int j=0; j<i; j++){
  //   printf("Ptr:%p\n", argv[j]);
  //   printf("Arg_%d: %s\n", j, argv[j]);
  // }

  // char *arg_list[] = {"echo", "hello", NULL};
  if(execvp(buf, argv) < 0){
    sh_printf("Cmd Exec Failed! Please Check your cmd!\n");
  }

  // if(execvp(cmd, nullptr) < 0){
  //   sh_printf("Cmd Exec Failed! Please Check your cmd!\n");
  // }
}

void builtin_sh_run() {
  sh_banner();
  sh_prompt();

  while (1) {
    SDL_Event ev;
    if (SDL_PollEvent(&ev)) {
      if (ev.type == SDL_KEYUP || ev.type == SDL_KEYDOWN) {
        const char *res = term->keypress(handle_key(&ev));
        if (res) {
          sh_handle_cmd(res);
          sh_prompt();
        }
      }
    }
    refresh_terminal();
  }
}
