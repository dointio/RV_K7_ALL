#define SDL_malloc  malloc
#define SDL_free    free
#define SDL_realloc realloc

#define SDL_STBIMAGE_IMPLEMENTATION
#include "SDL_stbimage.h"

SDL_Surface* IMG_Load_RW(SDL_RWops *src, int freesrc) {
  assert(src->type == RW_TYPE_MEM);
  assert(freesrc == 0);
  return NULL;
}

SDL_Surface* IMG_Load(const char *filename) {
  FILE *imgfile = fopen(filename, "r");
  if(imgfile != NULL){
    fseek(imgfile, 0, SEEK_END);
    long n = ftell(imgfile);
    void *buf = malloc(n);
    printf("LogSuccess:%ld!\n", n);
    fseek(imgfile, 0, SEEK_SET);
    fread(buf, sizeof(char), n, imgfile);
    SDL_Surface *s_ptr = STBIMG_LoadFromMemory(buf, n);
    free(buf);
    fclose(imgfile);
    return s_ptr;
  }
  printf("LogError!File: %s\n", filename);
  return NULL;
}

int IMG_isPNG(SDL_RWops *src) {
  return 0;
}

SDL_Surface* IMG_LoadJPG_RW(SDL_RWops *src) {
  return IMG_Load_RW(src, 0);
}

char *IMG_GetError() {
  return "Navy does not support IMG_GetError()";
}
