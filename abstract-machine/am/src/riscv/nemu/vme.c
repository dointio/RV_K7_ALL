#include <am.h>
#include <nemu.h>
#include <klib.h>

static AddrSpace kas = {};
static void* (*pgalloc_usr)(int) = NULL;
static void (*pgfree_usr)(void*) = NULL;
static int vme_enable = 0;

static Area segments[] = {      // Kernel memory mappings
  NEMU_PADDR_SPACE
};

#define USER_SPACE RANGE(0x40000000, 0x80000000)

// #define MAP_DEBUG


static inline void set_satp(void *pdir) {
  uintptr_t mode = 1ul << (__riscv_xlen - 1);
  asm volatile("csrw satp, %0" : : "r"(mode | ((uintptr_t)pdir >> 12)));
}

static inline uintptr_t get_satp() {
  uintptr_t satp;
  asm volatile("csrr %0, satp" : "=r"(satp));
  return satp << 12;
}

bool vme_init(void* (*pgalloc_f)(int), void (*pgfree_f)(void*)) {
  pgalloc_usr = pgalloc_f;
  pgfree_usr = pgfree_f;

  kas.ptr = pgalloc_f(PGSIZE);

  int i;
  for (i = 0; i < LENGTH(segments); i ++) {
    void *va = segments[i].start;
#ifdef MAP_DEBUG
    printf("VME_%d\n", i);
#endif
    for (; va < segments[i].end; va += PGSIZE) {
      map(&kas, va, va, 0);
    }
  }

  set_satp(kas.ptr);
  vme_enable = 1;

  return true;
}

void protect(AddrSpace *as) {
  PTE *updir = (PTE*)(pgalloc_usr(PGSIZE));
  as->ptr = updir;
  as->area = USER_SPACE;
  as->pgsize = PGSIZE;
  // map kernel space
  memcpy(updir, kas.ptr, PGSIZE);
}

void unprotect(AddrSpace *as) {
}

void __am_get_cur_as(Context *c) {
  c->pdir = (vme_enable ? (void *)get_satp() : NULL);
}

void __am_switch(Context *c) {
  if (vme_enable && c->pdir != NULL) {
    set_satp(c->pdir);
  }
}

#ifdef __ISA_RISCV64__
  #define VPN_ADDR(tiaomu)  (((tiaomu>>10)&0xfffffffffff) << 12)
  #define VPN2_IDX(vaddr)   (((vaddr>>30)&0x1ff) << 3)
  #define VPN1_IDX(vaddr)   (((vaddr>>21)&0x1ff) << 3)
  #define VPN0_IDX(vaddr)   (((vaddr>>12)&0x1ff) << 3)
#else
  #error EEEEE
#endif


void map(AddrSpace *as, void *va, void *pa, int prot) {
  assert(as->ptr);
  if(as->area.start == NULL && as->area.end == NULL){//r: new as
    as->area.start = va;
    as->area.start = va + PGSIZE;
  }
  else if((uintptr_t)va < (uintptr_t)(as->area.start)){
    as->area.start = va;
  }
  else if((uintptr_t)va >= (uintptr_t)(as->area.end)){
    as->area.end = va + PGSIZE;
  }
  // else{
  //   printf("Error!Va:0x%p, Vp:0x%p\n", va, pa);
  //   panic("AbsMach--map:map vaddr is conflict!");
  // }
  as->pgsize++;
  uintptr_t virAddr = (uintptr_t)va;
  uintptr_t pyAddr = (uintptr_t)pa;
#ifdef MAP_DEBUG
  printf("Map:Va:0x%lx, Pa:0x%lx, VPN2_TAB_Ptr:%p\n", virAddr, pyAddr, as->ptr);
#endif
  uintptr_t ptr_ = VPN_ADDR(*(uintptr_t*)(  ((uintptr_t)(as->ptr)) + VPN2_IDX(virAddr) ));
  uintptr_t old_ptr_ = (uintptr_t)NULL;
#ifdef MAP_DEBUG
  printf("\tVPN1_Tab_Ptr is 0x%lx, Idx:%ld\n", ptr_, VPN2_IDX(virAddr));
#endif
  if(ptr_ == (uintptr_t)NULL){ //vpn1_table not exit
    
    ptr_ = (uintptr_t)pgalloc_usr(PGSIZE);
    *(uintptr_t*)( ((uintptr_t)(as->ptr))+VPN2_IDX(virAddr) ) = ((ptr_>>12)<<10);
    old_ptr_ = ptr_; //r: vpn1 ptr
    ptr_ = (uintptr_t)pgalloc_usr(PGSIZE);
    *(uintptr_t*)(old_ptr_ + VPN1_IDX(virAddr)) = ((ptr_>>12)<<10);
    *(uintptr_t*)(ptr_ + VPN0_IDX(virAddr)) = ((pyAddr >> 12)<<10);
  }
  else{
    
    old_ptr_ = ptr_; //r: vpn1 ptr
    ptr_ = VPN_ADDR(*(uintptr_t*)( ptr_ + VPN1_IDX(virAddr) ));
#ifdef MAP_DEBUG
    printf("\tVPN0_Tab_Ptr is 0x%lx, Idx:%ld\n", ptr_, VPN1_IDX(virAddr));
#endif
    if(ptr_ == (uintptr_t)NULL){ //vpn0_table not exit
      ptr_ = (uintptr_t)pgalloc_usr(PGSIZE);
      *(uintptr_t*)(old_ptr_ + VPN1_IDX(virAddr)) = ((ptr_>>12)<<10);
    }    
    *(uintptr_t*)(ptr_ + VPN0_IDX(virAddr)) = ((pyAddr >> 12)<<10);
    // printf("\tVPN0_Tab_Ptr is 0x%lx, Idx:%ld\n", ptr_, VPN1_IDX(virAddr));
  }
}

// Context *ucontext(AddrSpace *as, Area kstack, void *entry) {
//   return NULL;
// }
