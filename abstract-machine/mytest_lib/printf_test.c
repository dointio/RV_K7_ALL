
#include <stdio.h>
#include <inttypes.h>
void aNumtoStr(char *str, int a, int hexdec){
  if(hexdec == 10){
    *str = (char)(a+48);
  }
  // else if(hexdec == 16)
  else{
    if(a<10){
      *str = (char)(a+48);
    }
    else{
      *str = (char)(a+97-10);
    }
  }
}

char* lutoa(uint64_t num, char *str)
{
  int strLength = 0;
  aNumtoStr(str+strLength, num%16, 16);
  strLength++;
  num = num/16;
  if(num == 0){
    str[strLength] = '\0';
    return str;
  }
  while(num != 0){
    aNumtoStr(str+strLength, num % 16, 16);
    strLength++;
    num=num/16;
  }
  char buf_c;
  for(int i=0; i<strLength/2; i++){
    buf_c = *(str+i);
    *(str+i) = *(str+strLength-i-1);
    *(str+strLength-i-1) = buf_c;
  }
  *(str+strLength) = '\0';
  return str;
}

void main(void)
{
    char a[158];
    lutoa(0x8000000000000003, a);
    printf("%s\n", a);
}

