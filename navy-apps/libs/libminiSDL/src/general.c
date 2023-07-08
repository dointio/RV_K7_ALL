#include <NDL.h>

int SDL_Init(uint32_t flags) {
  return NDL_Init(flags);
}

void SDL_Quit() {
  NDL_Quit();
}

char *SDL_GetError() {
  return "Navy does not support SDL_GetError()";
}

int SDL_SetError(const char* fmt, ...) {
  printf("Unimplement! SDL_SetError\n");
  return -1;
}

int SDL_ShowCursor(int toggle) {
  printf("Unimplement! SDL_ShowCursor\n");
  return 0;
}

void SDL_WM_SetCaption(const char *title, const char *icon) {
  // printf("\33[1;31m");
  // printf("Use Function implemented! File:%s, Line:%s\n", __FILE__, __LINE__);
  // printf("\33[0m]");
}
