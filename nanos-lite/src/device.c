#include <common.h>

#if defined(MULTIPROGRAM) && !defined(TIME_SHARING)
# define MULTIPROGRAM_YIELD() yield()
#else
# define MULTIPROGRAM_YIELD()
#endif

#define NAME(key) \
  [AM_KEY_##key] = #key,

static const char *keyname[256] __attribute__((used)) = {
  [AM_KEY_NONE] = "NONE",
  AM_KEYS(NAME)
};

size_t serial_write(const void *buf, size_t offset, size_t len) {
  for(size_t i=0; i<len; i++){
    putch(*(char*)(buf+i));
  }
  return len;
  // return 0;
}

size_t events_read(void *buf, size_t offset, size_t len) {
  //o: this struct equal:bool and int
  static AM_INPUT_KEYBRD_T keybuf = {false, AM_KEY_NONE};
  if(keybuf.keycode == AM_KEY_NONE){
    keybuf = io_read(AM_INPUT_KEYBRD);
  }
  if(keybuf.keycode == AM_KEY_NONE){
    // strcpy(buf, keyname[keybuf.keycode]);
    return 0;
  }
  else {
    
    // uint32_t keyname_len = strlen(keyname[keybuf.keycode]);
    // uint32_t key_all_len = keyname_len+3+1; //r:kd or ku + space + key_name + '\0'
    // if(key_all_len > len){
    //   //r:kd or ku + space + key_name + '\0',if len not enough, return 0;
    //   return 0;
    // }
    // else{
    //   *(char*)buf = 'k';
    //   *(char*)(buf+1) = keybuf.keydown ? 'd' : 'u';
    //   *(char*)(buf+2) = ' ';
    //   strcpy(buf+3, keyname[keybuf.keycode]);
    //   *(char*)(buf +3 +keyname_len) = '\n';
    //   keybuf.keycode = AM_KEY_NONE;
    //   return key_all_len;
    // }
    if(len < 2){
      return 0;
    }
    else{
      *(char*)buf = keybuf.keydown ? 'd' : 'u';
      buf++;
      *(uint8_t*)buf = keybuf.keycode;
      keybuf.keycode = AM_KEY_NONE;
      return 2; 
    }
  }
  // return 0;
}

// static char dispinfo_c[100] = "WIDTH: 0000\nHEIGHT: 0000";
static char dispinfo_w[6] = "";
static char dispinfo_h[6] = "";
static char dispinfo_all[] = "WIDTH:      \nHEIGHT:      \n";
size_t dispinfo_read(void *buf, size_t offset, size_t len) {
  if(len >= (strlen(dispinfo_all)+1)){
    size_t w_c = strlen(dispinfo_w);
    size_t h_c = strlen(dispinfo_h);
    strcpy(buf, dispinfo_all);//six space
    strncpy(buf+6, dispinfo_w, w_c);
    strncpy(buf+20, dispinfo_h, h_c);
    // printf("Rd_dispInfo:\n%s\n", buf);
    return 28;
  }
  else {
    return 0;
  }
}

size_t fb_write(const void *buf, size_t offset, size_t len) {
  // AM_GPU_STREAM_DRAW_T st_draw;
  // st_draw.len = len;
  // st_draw.offset = offset;
  // st_draw.pixels = buf;
  // st_draw.sync = true;
  io_write(AM_GPU_STREAM_DRAW, offset, buf, len, true);
  return len;
}

void init_device() {
  Log("Initializing devices...");
  ioe_init();
  AM_GPU_CONFIG_T gpu_info;
  gpu_info = io_read(AM_GPU_CONFIG);
  sprintf(dispinfo_w, "%d", gpu_info.width);
  sprintf(dispinfo_h, "%d", gpu_info.height);
  // char str_test[100];
  // dispinfo_read(str_test, 0, 100);
}
