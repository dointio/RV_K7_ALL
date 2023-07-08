#ifndef __DEBUG_HPP__
#define __DEBUG_HPP__

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

#ifndef __DEBUG_H__
#define __DEBUG_H__
#include <stdio.h>
#include <assert.h>

// ----------- log -----------

#define ANSI_FG_BLACK   "\033[1;30m"
#define ANSI_FG_RED     "\033[1;31m"
#define ANSI_FG_GREEN   "\033[1;32m"
#define ANSI_FG_YELLOW  "\033[1;33m"
#define ANSI_FG_BLUE    "\033[1;34m"
#define ANSI_FG_MAGENTA "\033[1;35m"
#define ANSI_FG_CYAN    "\033[1;36m"
#define ANSI_FG_WHITE   "\033[1;37m"
#define ANSI_BG_BLACK   "\033[1;40m"
#define ANSI_BG_RED     "\033[1;41m"
#define ANSI_BG_GREEN   "\033[1;42m"
#define ANSI_BG_YELLOW  "\033[1;43m"
#define ANSI_BG_BLUE    "\033[1;44m"
#define ANSI_BG_MAGENTA "\033[1;35m"
#define ANSI_BG_CYAN    "\033[1;46m"
#define ANSI_BG_WHITE   "\033[1;47m"
#define ANSI_NONE       "\033[0m"

#define ANSI_FMT(str, fmt) fmt str ANSI_NONE

#define log_write(...) \
  do { \
    extern FILE* InstLogFp; \
    fprintf(InstLogFp, __VA_ARGS__); \
    fflush(InstLogFp); \
  } while (0)

#define log_write_inst(...)  \
  do { \
    extern FILE* InstLogFp; \
    extern bool log_inst_enable(); \
    if (log_inst_enable()) { \
      fprintf(InstLogFp, __VA_ARGS__); \
      fflush(InstLogFp); \
    } \
  }while(0)

#define log_write_mem(...)  \
  do { \
    extern FILE* MemLogFp; \
    extern bool log_mem_enable(); \
    if (log_mem_enable()) { \
      fprintf(MemLogFp, __VA_ARGS__); \
      fflush(MemLogFp); \
    } \
  }while(0)

#define _Log(...) \
  do { \
    /*printf(__VA_ARGS__);*/ \
    log_write(__VA_ARGS__); \
  } while (0)

#define _LogInst(...) \
  do { \
    log_write_inst(__VA_ARGS__); \
  }while(0)

#define _LogMem(...) \
  do { \
    log_write_mem(__VA_ARGS__); \
  }while(0)


#define Log(format, ...) \
    _Log(ANSI_FMT("[%s:%d %s] " format, ANSI_FG_BLUE) "\n", \
        __FILE__, __LINE__, __func__, ## __VA_ARGS__)

//----------------------------assert--------------------------

#define Assert(cond, format, ...) \
  do { \
    if (!(cond)) { \
      _Log(format, ## __VA_ARGS__); \
      assert(cond); \
    } \
  } while (0)

#define panic(format, ...) Assert(0, format, ## __VA_ARGS__)

#define TODO() panic("please implement me")

#endif


#endif

