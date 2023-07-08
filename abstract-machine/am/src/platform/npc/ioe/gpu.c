#include <am.h>
#include <npc.h>
#include <klib.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

int width_s, high_s;

void __am_gpu_init() {
  printf("\33[1;31mNote!!!For sim,I close vga in am lib, if use vga in nemu/npc,you need to change here!!\33[0m\n");
  // width_s = ((inl(VGACTL_ADDR)>>16)&0xffff);
  // high_s = inl(VGACTL_ADDR)&0xffff;
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, .has_accel = false,
    .width = ((inl(VGACTL_ADDR)>>16)&0xffff), .height = inl(VGACTL_ADDR)&0xffff,
    .vmemsz = 0
  };
  // printf("W: %d, H: %d\n", cfg->width, cfg->height);
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  if (ctl->sync) {
    outl(SYNC_ADDR, 1);
  }
  if(ctl->w == 0 || ctl->h == 0){
    return;
  }
  int k = 0;
  for(int i=0; i<ctl->h; i++){
    for(int j=0; j<ctl->w; j++){
      outl(FB_ADDR+(((i+ctl->y)*width_s)+ctl->x+j)*4, *(((int32_t*)(ctl->pixels))+k));
      // printf("X:%d, Y:%d! K: %d\n", ctl->x+j, (i+ctl->y), k);
      k++;
    }
  }

}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
