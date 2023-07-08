#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/time.h>

static int evtdev = -1;
static int fbdev = -1;
static int screen_w = 0, screen_h = 0; //r: bu gan yong.....
static int screen_zxp_w = 0, screen_zxp_h = 0;
static int screen_w_off = 0, screen_h_off = 0;

static uint32_t time_now=0;
static uint32_t time_init=0;
static int fd_events = 0;

// int _gettimeofday(struct timeval *tv, struct timezone *tz);
uint32_t NDL_GetTicks() {
  struct timeval tval;
  // _gettimeofday(&tval, NULL);
  gettimeofday(&tval, NULL);
  time_now = tval.tv_sec*1000 + tval.tv_usec/1000;
  return time_now-time_init;
}

// int _read(int fd, void *buf, size_t count);
#include <fcntl.h>
int NDL_PollEvent(char *buf, int len) {
  //r: flags and others is not used now?! the two para is trans dirct to nanos syscall!
  int retval = read(fd_events, buf, len);
  return retval;
  //r: return read cnt, if not key input, return 0;
}

void NDL_OpenCanvas(int *w, int *h) {
  if(*w == 0){
    *w = screen_zxp_w;
  }
  if(*h == 0){
    *h = screen_zxp_h;
  }

  if (getenv("NWM_APP")) { //r: ?????????what's this????????
    int fbctl = 4;
    fbdev = 5;
    screen_w = *w; screen_h = *h;
    char buf[64];
    int len = sprintf(buf, "%d %d", screen_w, screen_h);
    // let NWM resize the window and create the frame buffer
    write(fbctl, buf, len);
    while (1) {
      // 3 = evtdev
      int nread = read(3, buf, sizeof(buf) - 1);
      if (nread <= 0) continue;
      buf[nread] = '\0';
      if (strcmp(buf, "mmap ok") == 0) break;
    }
    close(fbctl);
  }//r: ???for native test???? used native lib???

  // else{ //r: need else branck??????
    screen_w = *w;
    screen_h = *h;
    screen_w_off = (screen_zxp_w-screen_w)/2;
    screen_h_off = (screen_zxp_h-screen_h)/2;
    // printf("OpenCanvas!%d, %d, %d, %d\n", screen_w, screen_h, screen_zxp_w, screen_zxp_h);
  // }
}

void NDL_DrawRect(uint32_t *pixels, int x, int y, int w, int h) {
  // printf("%d, %d, %d, %d\n", x, y, w, h);
  if(w == 0 || h == 0){
    return;
  }
  int fd_screen = open("/dev/fb", 0, 0);
  int st_x = x+screen_w_off;
  int st_y = y+screen_h_off;
  lseek(fd_screen, (st_y*screen_zxp_w+st_x)*4, SEEK_SET);
  for(int i=0; i<h; i++){
    write(fd_screen, (pixels+i*w), w*4);
    lseek(fd_screen, (screen_zxp_w-w)*4, SEEK_CUR);
  }
}

void NDL_OpenAudio(int freq, int channels, int samples) {
  printf("Unimplement! NDL_OpenAudio\n");
}

void NDL_CloseAudio() {
  printf("Unimplement! NDL_CloseAudio\n");
}

int NDL_PlayAudio(void *buf, int len) {
  printf("Unimplement! NDL_PlayAudio\n");
  return 0;
}

int NDL_QueryAudio() {
  printf("Unimplement! NDL_QueryAudio\n");
  return 0;
}

int NDL_Init(uint32_t flags) {
  if (getenv("NWM_APP")) {
    printf("getEnv:NWM_APP!!!\n");
    evtdev = 3;
  }
  time_init = NDL_GetTicks();
  fd_events = open("/dev/events", 0, 0);
  //r: get dispinfo, and recorde(st) 
  int fd_dispinfo = open("/proc/dispinfo", 0, 0);
  char disp_info_str[50];
  int rlen = read(fd_dispinfo, (void*)disp_info_str, 50);
  int orecorde = 0;
  int i = 0;
  for(; i<rlen; i++){
    if(disp_info_str[i] == ':'){
      orecorde = 1;
    }
    else if(disp_info_str[i] == '\n'){
      break;
    }
    else if(orecorde && disp_info_str[i]>='0' && disp_info_str[i] <= '9'){
      screen_zxp_w *= 10;
      screen_zxp_w += disp_info_str[i]-'0';
    }
  }
  orecorde = 0;
  i++;
  for(; i<rlen; i++){
    if(disp_info_str[i] == ':'){
      orecorde = 1;
    }
    else if(disp_info_str[i] == '\n'){
      break;
    }
    else if(orecorde && disp_info_str[i]>='0' && disp_info_str[i] <= '9'){
      screen_zxp_h *= 10;
      screen_zxp_h += disp_info_str[i]-'0';
    }
  }
  close(fd_dispinfo);
  // printf("NDL!ScreenW:%d, H:%d\n", screen_zxp_w, screen_zxp_h);
  //r: get dispinfo, and recorde(end)
  return 0;
}

void NDL_Quit() {
  close(fd_events);
}
