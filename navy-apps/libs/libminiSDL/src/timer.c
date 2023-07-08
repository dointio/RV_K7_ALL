#include <NDL.h>
#include <sdl-timer.h>
#include <stdio.h>

SDL_TimerID SDL_AddTimer(uint32_t interval, SDL_NewTimerCallback callback, void *param) {
  printf("Unimplement! SDL_AddTimer\n");
  return NULL;
}

int SDL_RemoveTimer(SDL_TimerID id) {
  //r: typedef void* SDL_TimerID; 
  printf("Unimplement! SDL_RemoveTimer\n");
  return 1;
}

uint32_t SDL_GetTicks() {
  return NDL_GetTicks();
  // return 0;
}

void SDL_Delay(uint32_t ms) {
  uint32_t now = NDL_GetTicks();
  while(NDL_GetTicks()-now < (ms));
}
