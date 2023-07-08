#include <stdio.h>
#include <stdint.h>
#include <elf.h>
#include <malloc.h>
#include <string.h>


#define CONFIG_ISA64
#ifdef CONFIG_ISA64
# define Elf_Ehdr Elf64_Ehdr
# define Elf_Phdr Elf64_Phdr
# define Elf_Shdr Elf64_Shdr
# define Elf_Sym  Elf64_Sym
# define Elf_ST_TYPE ELF64_ST_TYPE
# define Elf_ST_BIND ELF64_ST_BIND
# define Elf_Word Elf64_Word
# define Elf_Addr Elf64_Addr
# define Elf_Half Elf64_Half
# define Elf_Off  Elf64_Off
#else
# define Elf_Ehdr Elf32_Ehdr
# define Elf_Phdr Elf32_Phdr
# define Elf_Shdr Elf32_Shdr
# define Elf_Sym  Elf32_Sym
# define Elf_ST_TYPE ELF32_ST_TYPE
# define Elf_ST_BIND ELF32_ST_BIND
# define Elf_Word Elf32_Word
# define Elf_Addr Elf32_Addr
# define Elf_Half Elf32_Half
# define Elf_Off  Elf32_Off
#endif

typedef struct FunctionObj{
  char *name;
  Elf_Addr StAddr;
  struct FunctionObj *nxt;
} FunctionObj, *FunctionObjP;
// typedef struct FunctionObj *FunctionObjP;

FunctionObjP mainFuncP=NULL;

void MainFunctionObjInsert(FunctionObjP in){
  FunctionObjP pre = NULL;
  FunctionObjP now = mainFuncP;
  if(mainFuncP == NULL){
    mainFuncP = in;
    mainFuncP->nxt = NULL;
  }
  else{
    while(1){
      if(now == NULL){ //end of mainFuncList
        in->nxt = NULL;
        pre->nxt = in;
        break;
      }
      else if(now->StAddr == in->StAddr){
        // Assert(0, "Error! Elf Check, and addr confict!\n");
        break;
      }
      else if(now->StAddr < in->StAddr){
        pre = now;
        now = now->nxt;
      }
      else{//now.staddr > in.staddr;
        in->nxt = now;
        if(pre == NULL){
          mainFuncP = in;
        }
        else{
          pre->nxt = in;
        }
        break;
      }
    }
  }
}

FunctionObjP find_MainFuncObjList(Elf_Addr addr)
{
  FunctionObjP now = mainFuncP;
  while(1){
    if(now == NULL){
      return NULL;
    }
    else if(addr == now->StAddr){
      return now;
    }
    else if(now->StAddr < addr){
      now = now->nxt;
    }
    else {
      return NULL;
    }
  }
}

void MainElfLoader(const char *file)
{
  FILE *fd = fopen(file, "r");
//   Assert(fd, "Can not open '%s'(MainElf)\n", file);
  //r:get header
  Elf_Ehdr eheader;
  fread(&eheader, sizeof(Elf_Ehdr), 1, fd);
  //r:get shstrsec info
  Elf_Shdr shstrsec;
  fseek(fd, eheader.e_shoff+(eheader.e_shstrndx)*sizeof(Elf_Shdr), SEEK_SET);
  fread(&shstrsec, sizeof(Elf_Shdr), 1, fd);
  Elf_Off shstr_off = shstrsec.sh_offset;
//   printf("shstr_off:%lx, shstr_size:%lx\n", shstr_off, shstrsec.sh_size);
  //r:get shstrsec
  char *shstr_c;
  shstr_c = (char*)malloc(shstrsec.sh_size);
  fseek(fd, shstr_off, SEEK_SET);
  fread(shstr_c, shstrsec.sh_size, 1, fd);
  //r:get symtabsec info and strtabsec info
  Elf_Shdr symtabsec;
  Elf_Shdr strsec;
  Elf_Shdr secObj;
  fseek(fd, eheader.e_shoff, SEEK_SET);
  for(int i = 0; i<eheader.e_shnum; i++){
    fread(&secObj, sizeof(Elf_Shdr), 1, fd);
    if(!strcmp(shstr_c+secObj.sh_name, ".symtab")){
        symtabsec = secObj;
        printf("Main Sym!Off:0x%lx, size:0x%lx\n", symtabsec.sh_offset, symtabsec.sh_size);
    }
    if(!strcmp(shstr_c+secObj.sh_name, ".strtab")){
        strsec = secObj;
        printf("Main Str!Off:0x%lx, size:0x%lx\n", strsec.sh_offset, strsec.sh_size);
    }
  }
  //r:get strsec
  char *str_c;
  str_c = (char*)malloc(strsec.sh_size);
  fseek(fd, strsec.sh_offset, SEEK_SET);
  fread(str_c, strsec.sh_size, 1, fd);
  //r:check and dump systab!
  Elf_Sym symObj;
  FunctionObj *fobj;
  char *funcName;
  fseek(fd, symtabsec.sh_offset, SEEK_SET);
  for(int i = 0; i<symtabsec.sh_size; i+=sizeof(Elf_Sym)){
    fread(&symObj, sizeof(Elf_Sym), 1, fd);
    if(Elf_ST_TYPE(symObj.st_info) == STT_FUNC && Elf_ST_BIND(symObj.st_info) != STB_WEAK/* && symObj.st_size != 0*/){
        printf("Name:%s, Addr:%lx, Size:0x%lx, Type:%u\n", 
            str_c+symObj.st_name, 
            symObj.st_value,
            symObj.st_size,
            ELF64_ST_TYPE(symObj.st_info));
        
        fobj = (FunctionObj*)malloc(sizeof(FunctionObj));
        funcName = (char*)malloc(strlen(str_c+symObj.st_name)+1);
        strcpy(funcName, str_c+symObj.st_name);
        funcName[strlen(str_c+symObj.st_name)] = '\0';
        
        fobj->name = funcName;
        fobj->StAddr = symObj.st_value;
        
        MainFunctionObjInsert(fobj);
    }
  }
}

int main()
{
    // MainElfLoader("mul_64");
    MainElfLoader("/home/xpzh/ysyx/ysyx-workbench/nanos-lite/build/nanos-lite-riscv64-nemu.elf");
    printf("HHHH\n");
    FunctionObjP ite = mainFuncP;
    while(1){
      if(ite == NULL){
        break;
      }
      else{
        printf("s,Name:%s, Addr:0x%lx\n", ite->name, ite->StAddr);
        ite = ite->nxt;
      }
    }
    return 0;
}


