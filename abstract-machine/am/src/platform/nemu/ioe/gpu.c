#include <am.h>
#include <nemu.h>
#include <klib.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

int width_s, high_s;

void __am_gpu_init() {
  // printf("\33[1;31mNote!!!For sim,I \33[1;33mclose vga\33[1;31m in am lib, if use vga in nemu/npc,you need to change here!!\33[0m\n");
  width_s = ((inl(VGACTL_ADDR)>>16)&0xffff);
  high_s = inl(VGACTL_ADDR)&0xffff;
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, .has_accel = false,
    .width = ((inl(VGACTL_ADDR)>>16)&0xffff), .height = inl(VGACTL_ADDR)&0xffff,
    .vmemsz = 0
  };
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
      k++;
    }
  }
  
}

void __am_gpu_stream_draw(AM_GPU_STREAM_DRAW_T *ctl)
{
  if (ctl->sync){
    outl(SYNC_ADDR, 1);
  }
  if(ctl->len == 0){
    return;
  }
  size_t i=0;
  size_t off_p = ctl->offset;
  const void *input_p = ctl->pixels;
  while(1){
    if((i+off_p >= (width_s*high_s)*4) || (i >= ctl->len)){
      break;
    }
    outl(FB_ADDR+i+off_p, (*(uint32_t*)(input_p+i)));
    i+=4;
  }
  
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
