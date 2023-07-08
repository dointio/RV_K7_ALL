#include <NDL.h>
#include <SDL.h>

#define keyname(k) #k,

static const char *keyname[] = {
  "NONE",
  _KEYS(keyname)
};

static uint8_t key_state[512] = {

};

int SDL_PushEvent(SDL_Event *ev) {
  printf("Unimplement! SDL_PushEvent\n");
  return 0;
}

int SDL_PollEvent(SDL_Event *ev) {
  char buf[20];
  if(NDL_PollEvent(buf, 20) != 0){
      if(buf[0] == 'd'){  ev->type = SDL_KEYDOWN;  }
      else{ ev->type = SDL_KEYUP;  }
      ev->key.keysym.sym = buf[1];
      //r: update key_state
      key_state[buf[1]] = (buf[0] == 'd') ? 1 : 0;
      return 1;
  }
  return 0;
}

int SDL_WaitEvent(SDL_Event *event) {
  char buf[20];
  while(1){
    if(NDL_PollEvent(buf, 20) != 0){
      if(buf[0] == 'd'){  event->type = SDL_KEYDOWN;  }
      else{ event->type = SDL_KEYUP;  }
      event->key.keysym.sym = buf[1];
      key_state[buf[1]] = (buf[0] == 'd') ? 1 : 0;
      break;
    }
  }
  return 0;
}

int SDL_PeepEvents(SDL_Event *ev, int numevents, int action, uint32_t mask) {
  printf("Unimplement! SDL_PeepEvents\n");
  return 0;
}

uint8_t* SDL_GetKeyState(int *numkeys) {
  // return NULL;
  return key_state;
}
