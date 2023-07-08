#include <iostream>
#include "cpuStatus.hpp"
#include "Debug.hpp"
#include "sim.hpp"
#include <verilated_dpi.h>


extern "C"{
    void halt()
    {
        printf(ANSI_FG_GREEN);
        printf("NPC: CPU stop because of ebreak instr!\n");
        printf(ANSI_NONE);
        exit(cpu_gpr_t[10]);
        setCPURunState(Ebreak);
    }
}