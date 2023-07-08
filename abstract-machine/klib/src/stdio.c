#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

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

char* itoa(int num, char *str)
{
  int strLength = 0;
  int neg = 0;
  int data = 0;
  if((num < 0)){
    *str = '-';
    str++;
    neg = 1;
  }
  //low bit
  data = num%10;
  if(neg){
    data = -data;
  }
  aNumtoStr(str+strLength, data, 10);
  strLength++;
  data = num/10;
  if(neg){
    data = -data;
  }
  if(data == 0){
    str[strLength] = '\0';
    return (str-neg);
  }

  //second bit
  aNumtoStr(str+strLength, data%10, 10);
  strLength++;
  //loop test
  data=data/10;
  while(data != 0){
    aNumtoStr(str+strLength, data % 10, 10);
    strLength++;
    data=data/10;
  }
  char buf_c;
  for(int i=0; i<strLength/2; i++){
    buf_c = *(str+i);
    *(str+i) = *(str+strLength-i-1);
    *(str+strLength-i-1) = buf_c;
  }
  *(str+strLength) = '\0';
  return (str-neg);
}

char* litoa(int64_t num, char *str)
{
  int strLength = 0;
  int neg = 0;
  int64_t data = 0;
  if((num < 0)){
    *str = '-';
    str++;
    neg = 1;
  }
  //low bit
  data = num%10;
  if(neg){
    data = -data;
  }
  aNumtoStr(str+strLength, data, 10);
  strLength++;
  data = num/10;
  if(neg){
    data = -data;
  }
  if(data == 0){
    str[strLength] = '\0';
    return (str-neg);
  }

  //second bit
  aNumtoStr(str+strLength, data%10, 10);
  strLength++;
  //loop test
  data=data/10;
  while(data != 0){
    aNumtoStr(str+strLength, data % 10, 10);
    strLength++;
    data=data/10;
  }
  char buf_c;
  for(int i=0; i<strLength/2; i++){
    buf_c = *(str+i);
    *(str+i) = *(str+strLength-i-1);
    *(str+strLength-i-1) = buf_c;
  }
  *(str+strLength) = '\0';
  return (str-neg);
}

char* utoa(uint32_t num, char *str)
{
  int strLength = 0;
  aNumtoStr(str+strLength, num%16, 16);
  strLength++;
  num = num>>4;
  if(num == 0){
    str[strLength] = '\0';
    return str;
  }
  while(num != 0){
    aNumtoStr(str+strLength, num % 16, 16);
    strLength++;
    num=num>>4;
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
    num=num>>4;
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

int vsprintf(char *out, const char *fmt, va_list ap) {
  char* p;
  char tmp[64];
  int64_t buf_int;
  char* buf_cptr;

  for (p = out; *fmt; fmt++)
  {
      if (*fmt != '%')
      {
          *p++ = *fmt;
          continue;
      }

      fmt++;

      switch (*fmt)
      {
          case 'l':
              if(*(fmt+1) == 'd'){
                fmt++;
                buf_int = va_arg(ap, int64_t);
                litoa(buf_int, tmp);
                strcpy(p, tmp);
                p += strlen(tmp);
              }
              else if(*(fmt+1) == 'x'){
                fmt++;
                buf_int = va_arg(ap, int64_t);
                lutoa(buf_int, tmp);
                strcpy(p, tmp);
                p += strlen(tmp);
              }
              else{
                *p++ = '%';
                *p++ = 'l';
              }
              break;
          case 'x':
              buf_int = va_arg(ap, int);
              utoa(buf_int, tmp);
              strcpy(p, tmp);
              p += strlen(tmp);
              break;
          case 'd':
              buf_int = va_arg(ap, int);
              itoa(buf_int, tmp);
              strcpy(p, tmp);
              p += strlen(tmp);
              break;
          case 'p':
              void *addr = va_arg(ap, void*);
              uint64_t u = (uint64_t)addr;
              lutoa(u, tmp);
              strcpy(p, tmp);
              p += strlen(tmp);
              break;
          case 's':
              buf_cptr = va_arg(ap, char*);
              strcpy(p, buf_cptr);
              p += strlen(buf_cptr);
              break;
          default:
              break;
      }
  }
  *p = '\0';
  return (p - out);
  // panic("Not implemented");
}

int printf(const char *fmt, ...) {
  int i = 0;
  char tmp[64];
  int64_t buf_int;
  char* buf_cptr;
  va_list ap;
  va_start(ap, fmt);
  
  for (; *fmt; fmt++)
  {
      if(*fmt == '\0'){
        break;
      }
      if (*fmt != '%')
      {
          i++;
          putch(*fmt);
          continue;
      }
      fmt++;
      switch (*fmt)
      {
          case 'l':
              if(*(fmt+1) == 'd'){
                fmt++;
                buf_int = va_arg(ap, int64_t);
                litoa(buf_int, tmp);
                i += strlen(tmp);
                for(int j=0;j<strlen(tmp);j++){
                  putch(tmp[j]);
                }
              }
              else if(*(fmt+1) == 'x'){
                fmt++;
                buf_int = va_arg(ap, int64_t);
                lutoa(buf_int, tmp);
                i += strlen(tmp);
                for(int j=0;j<strlen(tmp);j++){
                  putch(tmp[j]);
                }
              }
              else{
                putch('%');
                putch('l');
                i += 2;
              }
              break;
          case 'x':
              buf_int = va_arg(ap, int);
              utoa(buf_int, tmp);
              i += strlen(tmp);
              for(int j=0;j<strlen(tmp);j++){
                putch(tmp[j]);
              }
              break;
          case 'd':
              buf_int = va_arg(ap, int);
              itoa(buf_int, tmp);
              i += strlen(tmp);
              for(int j=0;j<strlen(tmp);j++){
                putch(tmp[j]);
              }
              break;
          case 's':
              buf_cptr = va_arg(ap, char*);
              i += strlen(buf_cptr);
              for(int j=0;j<strlen(buf_cptr);j++){
                putch(buf_cptr[j]);
              }
              break;
          case 'p':
              void *p = va_arg(ap, void*);
              uint64_t u = (uint64_t)p;
              lutoa(u, tmp);
              i += strlen(tmp);
              for(int j=0; j<strlen(tmp); j++){
                putch(tmp[j]);
              }
              break;
          default:
              i++;
              putch('%');
              break;
      }
  }
  return i; 
  // panic("Not implemented");
}

int sprintf(char *out, const char *fmt, ...) {
  int i; 
  char buf[256]; 

  va_list arg;
  va_start(arg, fmt); 
  i = vsprintf(buf, fmt, arg); 
  for(int j=0; j<i; j++){
    out[j] = buf[j];
  }
  
  out[i] = '\0';
  return i; 
  // panic("Not implemented");
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}


#endif
