#include <iostream>
#include <verilated_dpi.h>
#include "dpi_import.hpp"
#include <SDL2/SDL.h>

static SDL_Renderer *renderer = NULL;
static SDL_Texture *texture = NULL;

// extern "C" void screen_init(const svLogicVecVal* width, const svLogicVecVal* height, const svOpenArrayHandle data);
// extern "C" void screen_sync();

uint32_t screen_w;
uint32_t screen_h;

uint32_t *screen_buf_ptr;
#ifdef OPEN_VIRSCREEN
extern "C" {
  void screen_init(const svLogicVecVal *width,
                          const svLogicVecVal *height, const svOpenArrayHandle data)
  {
    screen_buf_ptr = (uint32_t*)(((VerilatedDpiOpenVar*)data)->datap());
    screen_w = width->aval;
    screen_h = height->aval;
    SDL_Window *window = NULL;
    char title[128];
    sprintf(title, "NPC-VGA");
    SDL_Init(SDL_INIT_VIDEO);
    SDL_CreateWindowAndRenderer(
        screen_w,
        screen_h,
        0, &window, &renderer);
    SDL_SetWindowTitle(window, title);
    texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888,
                                SDL_TEXTUREACCESS_STATIC, screen_w, screen_h);
  }

  void update_screen()
  {
    // SDL_Rect rect = {.x=*((int*)vmem), .y=*(((int*)vmem)+1)};
    SDL_UpdateTexture(texture, NULL, (screen_buf_ptr /*+4*4*/), screen_w * sizeof(uint32_t));
    SDL_RenderClear(renderer);
    SDL_RenderCopy(renderer, texture, NULL, NULL);
    SDL_RenderPresent(renderer);
  }

  void screen_sync()
  {
    printf("Update\n");
    update_screen();
  }
}
#else
extern "C" {
  void screen_gpu_init(const svLogicVecVal *width,
                          const svLogicVecVal *height, const svOpenArrayHandle data)
  {
    printf("W:%d H:%d\n", width->aval, height->aval);
    screen_buf_ptr = (uint32_t*)(((VerilatedDpiOpenVar*)data)->datap());
    screen_w = width->aval;
    screen_h = height->aval;
    SDL_Window *window = NULL;
    char title[128];
    sprintf(title, "NPC-VGA");
    SDL_Init(SDL_INIT_VIDEO);
    SDL_CreateWindowAndRenderer(
        screen_w,
        screen_h,
        0, &window, &renderer);
    SDL_SetWindowTitle(window, title);
    texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888,
                                SDL_TEXTUREACCESS_STATIC, screen_w, screen_h);
  }

  void update_screen_gpu()
  {
    // SDL_Rect rect = {.x=*((int*)vmem), .y=*(((int*)vmem)+1)};
    SDL_UpdateTexture(texture, NULL, (screen_buf_ptr /*+4*4*/), screen_w * sizeof(uint32_t));
    SDL_RenderClear(renderer);
    SDL_RenderCopy(renderer, texture, NULL, NULL);
    SDL_RenderPresent(renderer);
  }
}
#endif
