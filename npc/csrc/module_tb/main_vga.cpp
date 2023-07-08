#include <stdlib.h> //所有文件都要包含
#include <iostream> //所有文件都要包含
#include <verilated.h> //仿真的API
#include <verilated_vcd_c.h> //生成波形文件的API
#include <Vbiu_module_tb.h>
#include "svdpi.h"
#include <SDL2/SDL.h>

VerilatedContext *contextp;
Vbiu_module_tb *top;
VerilatedVcdC *m_trace; //定义跟踪对象

static uint64_t instrCnt = 0;

void sim_init(int argc, char** argv)
{
    contextp = new VerilatedContext;
    contextp->traceEverOn(true);
    contextp->commandArgs(argc, argv);
    top = new Vbiu_module_tb(contextp);
    m_trace = new VerilatedVcdC;
    top->trace(m_trace, 8);
    m_trace->open("wave_vga_tb.vcd");
    top->eval();
    m_trace->dump(contextp->time());
}

void sim_finish(){
    if (!contextp->gotFinish()) {
        VL_DEBUG_IF(VL_PRINTF("+ Exiting without $finish; no events left\n"););
    }

    // Final model cleanup
    top->final();
}

int main(int argc, char** argv, char** env) {
	// Setup context, defaults, and parse command line
    Verilated::debug(0);

    sim_init(argc, argv);
    
    SDL_Event event;
    bool stop = false;
    while(1){
        if (!top->eventsPending())
            break;
        if(contextp->gotFinish()){
            break;
        }
        contextp->time(top->nextTimeSlot());
        top->eval();
        m_trace->dump(contextp->time());
        while (SDL_PollEvent(&event)) {
            switch (event.type) {
            case SDL_QUIT:
                stop = true;
                break;
            default: break;
            }
        }
        if(stop){
            break;
        }
    }
    
    sim_finish();
    
    return 0;
}