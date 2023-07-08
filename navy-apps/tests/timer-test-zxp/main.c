#include "stdio.h"
#include "assert.h"
#include <NDL.h>

int main() {
  uint32_t time_ms;
  uint32_t tick_cnt=0;
  NDL_Init(NULL);
  while(1){
    if(NDL_GetTicks() - time_ms > 1000){
        tick_cnt++;
        printf("Cnt!%u\n", tick_cnt);
        time_ms = NDL_GetTicks();
    }
    if(tick_cnt>10){
        break;
    }
  }
  

  return 0;
}

