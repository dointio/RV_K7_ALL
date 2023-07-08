#include <proc.h>
#include <elf.h>
#include "fs.h"

#ifdef __LP64__
# define Elf_Ehdr Elf64_Ehdr
# define Elf_Phdr Elf64_Phdr
#else
# define Elf_Ehdr Elf32_Ehdr
# define Elf_Phdr Elf32_Phdr
#endif

#if defined(__ISA_X86__)
# define EXPECT_MTYPE EM_X86_64
#elif defined(__ISA_AM_NATIVE__)
# define EXPECT_MTYPE EM_X86_64
#elif defined(__ISA_MIPS32__)
# define EXPECT_MTYPE EM_MIPS_RS3_LE
#elif defined(__ISA_RISCV32__) || defined(__ISA_RISCV64__)
# define EXPECT_MTYPE EM_RISCV
#elif defined(__ISA_LOONGARCH32R__)
# error Unsupported ISA
#else
# error Unsupported ISA
#endif

// size_t ramdisk_write(const void *buf, size_t offset, size_t len);
// size_t ramdisk_read(void *buf, size_t offset, size_t len);

static uintptr_t loader(PCB *pcb, const char *filename) {
  // TODO();
  Elf_Ehdr elf_header;
  //r: ver1 read fix file on staddr of disk
  // ramdisk_read(&elf_header, 0, sizeof(elf_header));
  // printf("Magic:%x\n", *(uint32_t*)elf_header.e_ident);
  // uint64_t poff = elf_header.e_phoff;
  // printf("Poff:0x%lx\n", poff);
  // Elf_Phdr elf_phdr;
  // for(int i=0; i<elf_header.e_phnum; i++){

  //   ramdisk_read(&elf_phdr, 0+poff+(i*elf_header.e_phentsize), sizeof(elf_phdr));
  //   printf("Segment_ID:%d, Off:0x%lx, FS:0x%lx, MS:0x%lx, VirA:0x%lx\n", i, 
  //     elf_phdr.p_offset, elf_phdr.p_filesz, elf_phdr.p_memsz, elf_phdr.p_vaddr);
  //   if(elf_phdr.p_type == PT_LOAD){
  //     ramdisk_read((void*)(elf_phdr.p_vaddr), elf_phdr.p_offset, elf_phdr.p_memsz);
  //     if(elf_phdr.p_memsz > elf_phdr.p_filesz){
  //       for(int i=0; i<(elf_phdr.p_memsz-elf_phdr.p_filesz); i++){
  //         *((char*)(elf_phdr.p_vaddr+elf_phdr.p_filesz+i)) = 0;
  //       }
  //     }
  //   }
  // }
  
  //r: ver2 read file by name!
  int fp = fs_open(filename, 0, 0);//o: if no file, ret -1
  // assert(fp);
  if(fp < 0){
    return (uintptr_t)NULL;
  }
  fs_read(fp, &elf_header, sizeof(elf_header));
  // printf("Magic:%x\n", *(uint32_t*)elf_header.e_ident);
  Elf_Phdr elf_phdr;
  // fs_lseek(fp, elf_header.e_phoff, SEEK_SET);
  for(int i=0; i<elf_header.e_phnum; i++){
    fs_lseek(fp, elf_header.e_phoff+(i*elf_header.e_phentsize),SEEK_SET);
    fs_read(fp, &elf_phdr, sizeof(elf_phdr));
    // printf("Segment_ID:%d, Off:0x%lx, FS:0x%lx, MS:0x%lx, VirA:0x%lx\n", i, 
    //   elf_phdr.p_offset, elf_phdr.p_filesz, elf_phdr.p_memsz, elf_phdr.p_vaddr);
    if(elf_phdr.p_type == PT_LOAD){
      fs_lseek(fp, elf_phdr.p_offset, SEEK_SET);
      fs_read(fp, (void*)elf_phdr.p_vaddr, elf_phdr.p_memsz);
      if(elf_phdr.p_memsz > elf_phdr.p_filesz){
        for(int i=0; i<(elf_phdr.p_memsz-elf_phdr.p_filesz); i++){
          *((char*)(elf_phdr.p_vaddr+elf_phdr.p_filesz+i)) = 0;
        }
      }
    }
  }
  return elf_header.e_entry;
  // return 0;
}

void naive_uload(PCB *pcb, const char *filename) {
  uintptr_t entry = loader(pcb, filename);
  Log("Jump to entry = %p", entry);
  ((void(*)())entry) ();
}



//o: kload
void context_kload(PCB *pcb, void (*entry)(void *),  void *arg)
{
  Area area = {pcb->stack, pcb->stack+STACK_SIZE};
  
  pcb->cp = kcontext(area, entry, arg);
  // printf("CPPtr: %p\n", pcb->cp);
  // printf("Kload, addr:%p\n", entry);
  // printf("StackSize:: st: %p, end: %p\n", area.start, area.end);
}

static uint64_t getArgsEnvpSize(char *const argv[], char *const envp[], uint64_t *argc, uint64_t *envpc, uint64_t *len_head, uint64_t *len_strArea){
  uint32_t cnt_a = 0;
  uint32_t cnt_e = 0;
  uint64_t lenCnt_head = 0;
  uint64_t lenCnt_strArea = 0;
  *argc = 0;
  *envpc = 0;
  //o: for args
  if(argv != NULL){
    while(1){
      if(argv[cnt_a] == NULL){
        lenCnt_head += sizeof(void*); //r:NULL also need be add to param list
        break;
      }
      else{
        // printf("Ptr:%p\n", argv[cnt_a]);
        // printf("Arg:%s\n", argv[cnt_a]);
        lenCnt_strArea += strlen(argv[cnt_a]) + 1;
        lenCnt_head += sizeof(void*);
        cnt_a ++;
        (*argc)++;
      }
    }
  }
  else {
    lenCnt_head += sizeof(void*); //r: for NULL
  }
  
  //o: for envp
  if(envp != NULL){
    while(1){
      if(envp[cnt_e] == NULL){
        lenCnt_head += sizeof(void*);//r:NULL also need be add to param list
        break;
      }
      else{
        // printf("Ptr:%p\n", envp[cnt_e]);
        // printf("Envp:%s\n", envp[cnt_e]);
        lenCnt_strArea += strlen(envp[cnt_e]) + 1;
        lenCnt_head += sizeof(void*);
        cnt_e ++;
        (*envpc)++;
      }
    }
  }
  else{
    lenCnt_head += sizeof(void*); //r: for NULL
  }
  
  lenCnt_head += sizeof(void*); //r: +sizeof(uintptr_t) for argc
  if(len_head != NULL){
    *len_head = lenCnt_head;
  }
  if(len_strArea != NULL){
    *len_strArea = lenCnt_strArea;
  }
  return lenCnt_head + lenCnt_strArea; //r: return size of all
}

static void* setArgEnvpList(void *st, char *const argv[], char *const envp[], uint64_t argc, uint64_t envpc, uint64_t headSize){
  void **st_head = (void**)ROUNDDOWN(st, sizeof(void*));
  void *st_str = (void*)((uint64_t)st_head + headSize);
  *(void**)st_head = (void*)((uintptr_t)argc);
  void *oldForRet = (void*)st_head;
  st_head++;
  uint64_t i = 0;
  for(i=0; i<argc; i++){
    *(st_head++) = st_str;
    strcpy(st_str, argv[i]);
    st_str += strlen(argv[i])+1;
  }
  *(st_head++) = NULL;
  for(i=0; i<envpc; i++){
    *(st_head++) = st_str;
    strcpy(st_str, envp[i]);
    st_str += strlen(envp[i]) + 1;
  }
  *(st_head++) = NULL;
  return oldForRet;
}

bool context_uload(PCB *pcb, const char *filename, char *const argv[], char *const envp[]){
  uintptr_t entry = loader(pcb, filename);
  if(entry == (uintptr_t)NULL){
    return false;
  }

  void *page_start = new_page(8); 
  void *page_end = (page_start + (8*PGSIZE));
  uint64_t argc_now, envpc_now, headSize_now, size_all;
  size_all = getArgsEnvpSize(argv, envp, &argc_now, &envpc_now, &headSize_now, NULL);
  printf("Sizeof(void*):%ld\n", sizeof(void*));
  printf("SizeAll:%ld, Argc:%ld, Envpc:%d, headSize:%ld\n", size_all, argc_now, envpc_now, headSize_now);

  void *arg_ptr = setArgEnvpList((page_end - size_all), argv, envp, argc_now, envpc_now, headSize_now);
  Area area = {page_start, arg_ptr};
  pcb->cp = ucontext(NULL, area, (void*)entry);
  pcb->cp->gpr[10] = (uintptr_t)arg_ptr;
  pcb->cp->GPRx = (uintptr_t)arg_ptr;
  printf("CPPtr: %p\n", pcb->cp);
  printf("Entry:%lx\n", pcb->cp->MEPC);
  printf("StackSize:: st: %p, end: %p\n", area.start, area.end);
  
  return true;
}


//r: zxp
//r: if success, ret new thread context ptr, if failed, return null!
Context* sys_execve(const char *filename, char *const argv[], char *const envp[], Context *prev){
  current->cp = prev;
  if(!context_uload(current, filename, argv, envp)){
    // current->cp->gpr[10] = -1; 
    current->cp->GPRx = -2; //r: return false!!! //file no exit ret -2!
  }
  return current->cp;
}
