#include <stdio.h>
#include <SDL2/SDL.h>

int main()
{
    SDL_Event event;
    while(1){
        while (SDL_PollEvent(&event)) {
            printf("device_keyevent\n");
            switch (event.type) {
                case SDL_QUIT:
                    break;
                // If a key was pressed
                case SDL_KEYDOWN:
                case SDL_KEYUP:
                    printf("hhh\n");
                    break;
                default: break;
            }
        }
    }
}