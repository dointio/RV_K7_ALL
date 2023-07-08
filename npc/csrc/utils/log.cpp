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

#include "common.hpp"
#include "Debug.hpp"
#include "SimConfig.hpp"
#include "cpuStatus.hpp"
#include "dpi_import.hpp"

FILE *InstLogFp   = NULL;
char* InstLogFile = NULL;
bool logInstOpen = false;

FILE *MemLogFp    = NULL;
char* MemLogFile  = NULL;
bool logMemOpen = false;

uint64_t start = 0;
uint64_t max_num = 200;


void setInstLogFile(const char* file){
  int len = strlen(file);
  if(InstLogFile != NULL){
      free(InstLogFile);
  }
  InstLogFile = (char*)malloc(len+1);
  strcpy(InstLogFile, file);
}

void setMemLogFile(const char* file){
  int len = strlen(file);
  if(MemLogFile != NULL){
      free(MemLogFile);
  }
  MemLogFile = (char*)malloc(len+1);
  strcpy(MemLogFile, file);
}
void init_log() {
#ifdef SIM_VERILATOR_ITRACE
  if (logInstOpen) {
    if (InstLogFile != NULL) {
      FILE *fp = fopen(InstLogFile, "w");
      Assert(fp, "Can not open '%s'(InstLogFile)\n", InstLogFile);
      InstLogFp = fp;
    }
    else{
      printf(ANSI_FG_BLUE);
      printf("Open inst log, but not set InstLogFile, so will not log!\n");
      printf(ANSI_NONE);
    }
    // Log("Log is written to %s", InstLogFile ? InstLogFile : "stdout");
  }
#else
  if (logInstOpen) {
    printf(ANSI_FG_RED);
    printf("Inst Log function isn't open when compile!!!!\n");
    printf(ANSI_NONE);
  }
#endif

#ifdef SIM_VERILATOR_MTRACE
  if (logMemOpen){
    if (MemLogFile != NULL) {
      FILE *fp = fopen(MemLogFile, "w");
      Assert(fp, "Can not open '%s'(MemLogFile)\n", MemLogFile);
      MemLogFp = fp;
    }
    else{
      printf(ANSI_FG_YELLOW);
      printf("Open mem log, but not set MemLogFile, so will not log!\n");
      printf(ANSI_NONE);
    }
  }
#else
  if (logInstOpen) {
    printf(ANSI_FG_RED);
    printf("Mem Log function isn't open when compile!!!!\n");
    printf(ANSI_NONE);
  }
#endif
}

void setInstTraceStartNum(uint64_t st){start = st;}

void setInstTraceMaxNum(uint64_t max){max_num = max;}

bool log_inst_enable() {
#ifdef SIM_VERILATOR_ITRACE
  return (logInstOpen && (getCPU_CNT()>=start) && (getCPU_CNT()<start+max_num));
#else
  return false;
#endif
}

bool log_mem_enable() {
#ifdef SIM_VERILATOR_MTRACE
  return (logMemOpen && (MemLogFp != NULL) && (getCPU_CNT()>=start) && (getCPU_CNT()<start+max_num));
#else
  return false;
#endif
}
