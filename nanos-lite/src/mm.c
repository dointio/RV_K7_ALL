#include <memory.h>

static void *pf = NULL;
static void *pf_end = NULL;

void* new_page(size_t nr_page) {
  //r: from end of heap
  // pf_end -= (nr_page * PGSIZE);
  // return pf_end;
  //r: from start of heap
  void *old_p = pf;
  pf += (nr_page * PGSIZE);
  printf("New page:%p to %p\n", old_p, pf);
  return old_p;
}

#ifdef HAS_VME
static void* pg_alloc(int n) {
  int a= (n+PGSIZE-1)/PGSIZE;
  void *p = new_page(a);
  memset(p, 0, n);
  return p;
}
#endif

void free_page(void *p) {
  panic("not implement yet");
}

/* The brk() system call handler. */
int mm_brk(uintptr_t brk) {
  return 0;
}

void init_mm() {
  pf = (void *)ROUNDUP(heap.start, PGSIZE);
  Log("free physical pages starting from %p", pf);

  //r: zxp
  pf_end = heap.end;
  //r: end

#ifdef HAS_VME
  vme_init(pg_alloc, free_page);
#endif
}
