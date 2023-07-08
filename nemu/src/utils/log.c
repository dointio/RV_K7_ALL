/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <common.h>
#include <elf.h>

extern uint64_t g_nr_guest_inst;
FILE *InstLogFp = NULL;
FILE *MemLogFp = NULL;
FILE *FuncLogFp = NULL;
FILE *PesLogFp = NULL;
FILE *ExcpLogFp = NULL;

void MainElfLoader(const char *file);
void AppElfLoader(const char *listFile);

void init_log(const char *InstLogFile, const char *MemLogFile, const char *MainElfFile, const char *AppElfListFile, const char *FuncLogFile, const char *PesLogFile, const char *ExcpLogFile) {
  //r: instlog(old ver, default dump to stdout)
  // InstLogFp = stdout;
  // if (InstLogFile != NULL) {
  //   FILE *fp = fopen(InstLogFile, "w");
  //   Assert(fp, "Can not open '%s'", InstLogFile);
  //   InstLogFp = fp;
  // }
  // printf(ANSI_FG_BLUE);
  // printf("Log is written to %s\n", InstLogFile ? InstLogFile : "stdout");
  // printf(ANSI_NONE);
  //r: instlog(new ver, default not dump)
#ifdef CONFIG_ITRACE
  if (InstLogFile != NULL) {
    FILE *fp = fopen(InstLogFile, "w");
    Assert(fp, "Can not open '%s'", InstLogFile);
    InstLogFp = fp;
    printf(ANSI_FG_GREEN);
    printf("InstLogFile:%s\n", InstLogFile);
    printf(ANSI_NONE);
  }
  else{
    printf(ANSI_FG_YELLOW);
    printf("No InstLogFile, so dont dump itrace!\n");
    printf(ANSI_NONE);
  }
#else
  if (InstLogFile != NULL){
    printf(ANSI_FG_YELLOW);
    printf("InstTrace is close when comp!!\n");
    printf(ANSI_NONE);
  }
#endif
  //r: memlog
#ifdef CONFIG_MTRACE
  if (MemLogFile != NULL) {
    FILE *fp = fopen(MemLogFile, "w");
    Assert(fp, "Can not open '%s'(MemLogFile)\n", MemLogFile);
    MemLogFp = fp;
    printf(ANSI_FG_GREEN);
    printf("MemLogFile:%s\n", MemLogFile);
    printf(ANSI_NONE);
  }
  else{
    printf(ANSI_FG_YELLOW);
    printf("No MemLogFile, so dont dump mtrace!\n");
    printf(ANSI_NONE);
  }
#else
  if (MemLogFile != NULL){
    printf(ANSI_FG_YELLOW);
    printf("MemTrace is close when comp!!\n");
    printf(ANSI_NONE);
  }
#endif
  //r: peslog
#ifdef CONFIG_DTRACE
  if (PesLogFile != NULL) {
    FILE *fp = fopen(PesLogFile, "w");
    Assert(fp, "Can not open '%s'(PesLogFile)\n", PesLogFile);
    PesLogFp = fp;
    printf(ANSI_FG_GREEN);
    printf("PesLogFile:%s\n", PesLogFile);
    printf(ANSI_NONE);
  }
  else{
    printf(ANSI_FG_YELLOW);
    printf("No PesLogFile, so dont dump dtrace!\n");
    printf(ANSI_NONE);
  }
#else
  if (PesLogFile != NULL){
    printf(ANSI_FG_YELLOW);
    printf("PesTrace is close when comp!!\n");
    printf(ANSI_NONE);
  }
#endif
  //r: excplog
#ifdef CONFIG_ETRACE
  if (ExcpLogFile != NULL) {
    FILE *fp = fopen(ExcpLogFile, "w");
    Assert(fp, "Can not open '%s'(ExcpLogFile)\n", ExcpLogFile);
    ExcpLogFp = fp;
    printf(ANSI_FG_GREEN);
    printf("ExcpLogFile:%s\n", ExcpLogFile);
    printf(ANSI_NONE);
  }
  else{
    printf(ANSI_FG_YELLOW);
    printf("No ExcpLogFile, so dont dump etrace!\n");
    printf(ANSI_NONE);
  }
#else
  if (ExcpLogFile != NULL){
    printf(ANSI_FG_YELLOW);
    printf("EexpTrace is close when comp!!\n");
    printf(ANSI_NONE);
  }
#endif
  //r: funclog
#ifdef CONFIG_FTRACE
  if (FuncLogFile != NULL) {
    if(MainElfFile != NULL){
      //r: open input elf
      MainElfLoader(MainElfFile);
      if(AppElfListFile != NULL)
        AppElfLoader(AppElfListFile);
      //r: open func log file
      FILE *fp = fopen(FuncLogFile, "w");
      Assert(fp, "Can not open '%s'(FuncLogFile)\n", FuncLogFile);
      FuncLogFp = fp;
      printf(ANSI_FG_GREEN);
      printf("FuncLogFile:%s\n", FuncLogFile);
      printf(ANSI_NONE);
    }
    else {
      printf(ANSI_FG_RED);
      printf("Set FuncLogFile, but no input elf!!!\n");
      printf(ANSI_NONE);
      assert(0);  
    }
  }
  else{
    printf(ANSI_FG_YELLOW);
    printf("No FuncLogFile, so dont dump mtrace!\n");
    printf(ANSI_NONE);
  }
#else
  if (FuncLogFile != NULL){
    printf(ANSI_FG_YELLOW);
    printf("FuncTrace is close when comp!!\n");
    printf(ANSI_NONE);
  }
#endif
}

bool InstLogEnable() {
#ifdef CONFIG_ITRACE
  return (InstLogFp != NULL) && (g_nr_guest_inst >= CONFIG_TRACE_START) &&
         (g_nr_guest_inst <= CONFIG_TRACE_END);
#else
  return false;
#endif
}

bool MemLogEnable() {
#ifdef CONFIG_MTRACE
  return (MemLogFp != NULL) && (g_nr_guest_inst >= CONFIG_TRACE_START) &&
         (g_nr_guest_inst <= CONFIG_TRACE_END);
#else
  return false;
#endif
}

bool FuncLogEnable() {
#ifdef CONFIG_FTRACE
  return (FuncLogFp != NULL) && (g_nr_guest_inst >= CONFIG_TRACE_START) &&
         (g_nr_guest_inst <= CONFIG_TRACE_END);
#else
  return false;
#endif
}

bool PesLogEnable(){
#ifdef CONFIG_DTRACE
  return (PesLogFp != NULL) && (g_nr_guest_inst >= CONFIG_TRACE_START) &&
         (g_nr_guest_inst <= CONFIG_TRACE_END);
#else
  return false;
#endif
}

bool ExcpLogEnable() {
#ifdef CONFIG_ETRACE
  return (ExcpLogFp != NULL) && (g_nr_guest_inst >= CONFIG_TRACE_START) &&
         (g_nr_guest_inst <= CONFIG_TRACE_END);
#else
  return false;
#endif

  // return MUXDEF(CONFIG_TRACE, (MemLogFp != NULL) && (g_nr_guest_inst >= CONFIG_TRACE_START) &&
  //        (g_nr_guest_inst <= CONFIG_TRACE_END), false);
}


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

#pragma GCC diagnostic ignored "-Wunused-result"


typedef struct FunctionObj{
  char *name;
  Elf_Addr StAddr;
  struct FunctionObj *nxt;
} FunctionObj, *FunctionObjP;
// typedef struct FunctionObj *FunctionObjP;

FunctionObjP mainFuncP=NULL;
FunctionObjP appFuncP=NULL;

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

char* find_MainFuncObjList(vaddr_t addr)
{
  FunctionObjP now = mainFuncP;
  while(1){
    if(now == NULL){
      return NULL;
    }
    else if(((Elf_Addr)addr) == now->StAddr){
      // return now;
      return now->name;
    }
    else if(now->StAddr < ((Elf_Addr)addr)){
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
        // printf("Main Sym!Off:0x%lx, size:0x%lx\n", symtabsec.sh_offset, symtabsec.sh_size);
    }
    if(!strcmp(shstr_c+secObj.sh_name, ".strtab")){
        strsec = secObj;
        // printf("Main Str!Off:0x%lx, size:0x%lx\n", strsec.sh_offset, strsec.sh_size);
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
        // printf("Name:%s, Addr:%lx, Size:0x%lx, Type:%u\n", 
        //     str_c+symObj.st_name, 
        //     symObj.st_value,
        //     symObj.st_size,
        //     ELF64_ST_TYPE(symObj.st_info));
        
        fobj = (FunctionObj*)malloc(sizeof(FunctionObj));
        funcName = (char*)malloc(strlen(str_c+symObj.st_name)+1);
        strcpy(funcName, str_c+symObj.st_name);
        funcName[strlen(str_c+symObj.st_name)] = '\0';
        
        fobj->name = funcName;
        fobj->StAddr = symObj.st_value;
        
        MainFunctionObjInsert(fobj);
    }
  }
  printf(ANSI_FG_GREEN);
  printf("LoadMainElf:%s\n", file);
  FunctionObjP ite = mainFuncP;
  while(1){
      if(ite == NULL){
        break;
      }
      else{
        printf("\tFuncName:%s, Addr:0x%lx\n", ite->name, ite->StAddr);
        ite = ite->nxt;
      }
    }
  printf(ANSI_NONE);
}


void AppFunctionObjInsert(FunctionObjP in){
  FunctionObjP pre = NULL;
  FunctionObjP now = appFuncP;
  if(appFuncP == NULL){
    appFuncP = in;
    appFuncP->nxt = NULL;
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
          appFuncP = in;
        }
        else{
          pre->nxt = in;
        }
        break;
      }
    }
  }
}

char* find_AppFuncObjList(vaddr_t addr)
{
  FunctionObjP now = appFuncP;
  while(1){
    if(now == NULL){
      return NULL;
    }
    else if(((Elf_Addr)addr) == now->StAddr){
      // return now;
      return now->name;
    }
    else if(now->StAddr < ((Elf_Addr)addr)){
      now = now->nxt;
    }
    else {
      return NULL;
    }
  }
}

void AppElfLoader(const char *file)
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
        // printf("Main Sym!Off:0x%lx, size:0x%lx\n", symtabsec.sh_offset, symtabsec.sh_size);
    }
    if(!strcmp(shstr_c+secObj.sh_name, ".strtab")){
        strsec = secObj;
        // printf("Main Str!Off:0x%lx, size:0x%lx\n", strsec.sh_offset, strsec.sh_size);
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
        // printf("Name:%s, Addr:%lx, Size:0x%lx, Type:%u\n", 
        //     str_c+symObj.st_name, 
        //     symObj.st_value,
        //     symObj.st_size,
        //     ELF64_ST_TYPE(symObj.st_info));
        
        fobj = (FunctionObj*)malloc(sizeof(FunctionObj));
        funcName = (char*)malloc(strlen(str_c+symObj.st_name)+1);
        strcpy(funcName, str_c+symObj.st_name);
        funcName[strlen(str_c+symObj.st_name)] = '\0';
        
        fobj->name = funcName;
        fobj->StAddr = symObj.st_value;
        
        AppFunctionObjInsert(fobj);
    }
  }
  printf(ANSI_FG_GREEN);
  printf("LoadAppElf:%s\n", file);
  printf(ANSI_NONE);
}

