#ifndef __COMMON_HPP__
#define __COMMON_HPP__

#include "macro.h"
#include <iostream>

typedef uint64_t uint64_t;
typedef uint64_t paddr_t;

#define CONFIG_ISA64

enum CPURunState {
    Running, //init, or running
    Stop, //in sdb mode, wait for run/continue
    End,  //in sdb mode, user input "q" to quit
    Ebreak, //software call ebreak
    Abort, //difftest error! or InValid inst!!
    Quit, //usr click quit on the virscreen gui!
    Finish //in SV, call $finish!
};

typedef struct{
    CPURunState runState;
    uint64_t pc;
    uint64_t cnt;
    uint32_t inst;
    // bool Rd;
    // bool Wr;
    // uint64_t waddr, wdata, raddr, rdata;
    // uint32_t wmask;
    // uint32_t rmask; //r: rmask not used, rdata is after mask trnasfer!
}CPUState;

#endif
