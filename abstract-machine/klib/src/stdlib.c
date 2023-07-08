#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)
static unsigned long int next = 1;

int rand(void) {
  // RAND_MAX assumed to be 32767
  next = next * 1103515245 + 12345;
  return (unsigned int)(next/65536) % 32768;
}

void srand(unsigned int seed) {
  next = seed;
}

int abs(int x) {
  return (x < 0 ? -x : x);
}

int atoi(const char* nptr) {
  int x = 0;
  while (*nptr == ' ') { nptr ++; }
  while (*nptr >= '0' && *nptr <= '9') {
    x = x * 10 + *nptr - '0';
    nptr ++;
  }
  return x;
}

//r: we assume the max length data type is long long!
typedef long long Align_malloc;
static size_t roud_ = sizeof(long long);

union header_malloc
{
  struct{
    union header_malloc *nxt;
    uint64_t size;
  }s;
  Align_malloc x;
};
static size_t roud_header_size =  (
                                    (sizeof(union header_malloc)+(sizeof(long long)-1)) /sizeof(long long)
                                  ) * sizeof(long long);

static void *allocPtr = NULL;
static void *allocedPtr = NULL;



void *malloc(size_t size) {
  // On native, malloc() will be called during initializaion of C runtime.
  // Therefore do not call panic() here, else it will yield a dead recursion:
  //   panic() -> putchar() -> (glibc) -> malloc() -> panic()
#if !(defined(__ISA_NATIVE__) && defined(__NATIVE_USE_KLIB__))
  if(allocPtr == NULL){
    allocPtr =(void*) ROUNDUP(heap.start, roud_);
    printf("Heap.start: %lx, Heap.end: %lx\n", heap.start, heap.end);
    ((union header_malloc*)allocPtr)->s.nxt = NULL;
    ((union header_malloc*)allocPtr)->s.size = (heap.end -allocPtr -roud_header_size);
  }
  // size = (size>=sizeof(union header_malloc) ? size : sizeof(union header_malloc));
  size  = (size_t)ROUNDUP(size, roud_);
  union header_malloc *now = allocPtr;
  union header_malloc *old = NULL; 
  union header_malloc *buf = NULL;
  while(1){
    if(now == NULL){
      return NULL;
    }
    else if(now->s.size >= size){
      if(now->s.size > size + roud_header_size){//r: the block can be split!
        buf = ((void*)now)+size+roud_header_size;
        if(old == NULL)
          allocPtr = buf;
        else
          old->s.nxt = buf;
        buf->s.nxt = now->s.nxt;
        buf->s.size = now->s.size -size -roud_header_size;
        now->s.nxt = allocedPtr;
        now->s.size = size;
        allocedPtr = now;
        // printf("Allow! Ptr: %lx, Size: %lx, HeaderSize: %lx, End: %lx\n", (uint64_t)now, size, 
        //   roud_header_size, (uint64_t)now+size+roud_header_size-1);
      }
      else{
        if(old == NULL)
          allocPtr = now->s.nxt;
        else
          old->s.nxt = now->s.nxt;
        now->s.nxt = allocedPtr;
        allocedPtr = now;
        // printf("Allow! Ptr: %lx, Size: %lx, HeaderSize: %lx, End: %lx\n", (uint64_t)now, size, 
        //   roud_header_size, (uint64_t)now+size+roud_header_size-1);
      }
      break;
    }
    else{
      old = now;
      now = now->s.nxt;
    }
  }
  assert(allocedPtr + size + roud_header_size < heap.end);
  return allocedPtr + roud_header_size;
  // panic("Not implemented");
#endif
  return NULL;
}

void free(void *ptr) {
  if(ptr == NULL){
    return;
  }
  ptr -= roud_header_size;
  printf("Want Free, Addr: %lx\n", (uint64_t)ptr);
  union header_malloc *now = allocedPtr;
  union header_malloc *old = NULL;
  while(1){
    if(now == NULL){
      return;
    }
    else if(now == ptr){
      printf("Find!\n");
      if(old == NULL){
        allocedPtr = (void*)(((union header_malloc*)allocedPtr)->s.nxt);
        now->s.nxt = allocPtr;
        allocPtr = now;
        // printf("Free! Ptr: %lx, Size: %lx, HeaderSize: %lx, End: %lx\n", (uint64_t)now, now->s.size, 
        //   roud_header_size, (uint64_t)now+now->s.size+roud_header_size-1);
      }
      else{
        old->s.nxt = now->s.nxt;
        now->s.nxt = allocPtr;
        allocPtr = now;
        // printf("Free! Ptr: %lx, Size: %lx, HeaderSize: %lx, End: %lx\n", (uint64_t)now, now->s.size, 
        //   roud_header_size, (uint64_t)now+now->s.size+roud_header_size-1);
      }
      break;
    }
    else{
      // printf("Old: %lx, Now: %lx, Now.nxt: %lx!\n", (uint64_t)old, (uint64_t)now, (uint64_t)now->s.nxt);
      old = now;
      now = now->s.nxt;
    }
  }
}

#endif
