#include <am.h>
#include <nemu.h>
#include <klib.h>

#define KEYDOWN_MASK 0x8000

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  // kbd->keydown = 0;
  // kbd->keycode = AM_KEY_NONE;
  uint32_t keyVal = inl(KBD_ADDR);
  if(keyVal & KEYDOWN_MASK){
    kbd->keydown = 1;
  }
  else{
    kbd->keydown = 0;
  }
  kbd->keycode = keyVal & 0x7fff;
}
