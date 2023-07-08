#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
  size_t i = 0;
  if(s == NULL){
    return 0;
  }
  while(*s != '\0'){
    i++;
    s++;
  }
  return i;
  // panic("Not implemented");
}

char *strcpy(char *dst, const char *src) {
  char* p = dst;
  while(*src != '\0'){
    *p = *src;
    p++;
    src++;
  }
  *p = '\0';
  return dst;
  // panic("Not implemented");
}

char *strncpy(char *dst, const char *src, size_t n) {
  size_t i;
  for(i=0; i<n; i++){
    dst[i] = src[i];
  }
  return dst;
  // panic("Not implemented");
}

char *strcat(char *dst, const char *src) {
  char* p = dst;
  while(*p != '\0'){
    p++;
  }
  strcpy(p, src);
  return dst;
  // panic("Not implemented");
}

int strcmp(const char *s1, const char *s2) {
  while((*s1 != '\0') && (*s2 != '\0')){
    if(*s1 == *s2){
      s1++;
      s2++;
    }
    else if(*s1 < *s2){
      return -1;
    }
    else{
      return 1;
    }
  }
  if(*s1 == '\0'){
    if(*s2 == '\0'){
      return 0;
    }
    else{
      return -1;
    }
  }
  else {
    return 1;
  }
  // panic("Not implemented");
}

int strncmp(const char *s1, const char *s2, size_t n) {
  size_t i;
  for(i=0; i<n; i++){
    if(*s1 == *s2){
      if(*s1 == '\0'){
        return 0;
      }
      else {
        s1++;
        s2++;
      }
    }
    else if(*s1 < *s2){
      return -1;
    }
    else{
      return 1;
    }
  }
  return 0;
  // panic("Not implemented");
}

void *memset(void *s, int c, size_t n) {
  size_t i;
  char *p = s;
  for(i=0; i<n; i++){
    *p = c;
    p++;
  }
  return s;
  // panic("Not implemented");
}

void *memmove(void *dst, const void *src, size_t n) {
  // size_t i;
  // char *src_p = (char*)src;
  // char *dst_p = (char*)dst;
  // for(i=0; i<n; i++){
  //   *dst_p = *src_p;
  //   dst_p++;
  //   src_p++;
  // }
  // return dst;
  panic("Not implemented");
  //need malloc to finish it;
  //or used a big char arrary as buffer,but....
}

void *memcpy(void *out, const void *in, size_t n) {
  size_t i=0;
  char *o_c = (char*)out;
  char *in_c = (char*)in;
  for(i = 0; i < n; i++){
    o_c[i] = in_c[i];
  }
  return out;
  // panic("Not implemented");
}

int memcmp(const void *s1, const void *s2, size_t n) {
  size_t i;
  uint8_t *s1_p = (uint8_t*)s1;
  uint8_t *s2_p = (uint8_t*)s2;
  for(i=0; i<n; i++){
    if(*s1_p == *s2_p){
      s1_p++;
      s2_p++;
    }
    else if(*s1_p < *s2_p){
      return -1;
    }
    else{
      return 1;
    }
  }
  return 0;
  // panic("Not implemented");
}

#endif
