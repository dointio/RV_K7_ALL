// void engine_start() {
// #ifdef CONFIG_TARGET_AM
//   cpu_exec(-1);
// #else
//   /* Receive commands from user. */
//   sdb_mainloop();
// #endif
// }
#include <stdlib.h> //所有文件都要包含
#include <iostream> //所有文件都要包含

#include "SimConfig.hpp"
#include "cpuStatus.hpp"
#include "Debug.hpp"
#include "sim.hpp"
#include "SDL2/SDL.h"

#include <verilated.h> //仿真的API
#include <verilated_vcd_c.h> //生成波形文件的API

#include "Vriscv_tb.h" // verilated 后 ALU模块的类定义

#include "svdpi.h"
#include "Vriscv_tb__Dpi.h"


// const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
// const std::unique_ptr<Vriscv_tb> top{new Vriscv_tb{contextp.get()}};



VerilatedContext *contextp;
Vriscv_tb *top;


#if(OPEN_WAVE_TRACE)
    VerilatedVcdC *m_trace; //定义跟踪对象
#endif

char* WaveLogFile = NULL;
bool WaveLogOpen = false;

void setWaveLogFile(const char* file){
  int len = strlen(file);
  if(WaveLogFile != NULL){
      free(WaveLogFile);
  }
  WaveLogFile = (char*)malloc(len+1);
  strcpy(WaveLogFile, file);
}

static uint64_t instrCnt = 0;



void sim_init(int argc, char** argv)
{
    contextp = new VerilatedContext;
    contextp->traceEverOn(true);
    contextp->commandArgs(argc, argv);
    top = new Vriscv_tb(contextp);
#if(OPEN_WAVE_TRACE)
    if(WaveLogOpen) {
        m_trace = new VerilatedVcdC;
        top->trace(m_trace, 8);
        m_trace->open(WaveLogFile);
    }
#else
    if(WaveLogOpen) {
        printf(ANSI_FG_RED);
        printf("Wave Log function isn't open when compile!!!!\n");
        printf(ANSI_NONE);
    }
#endif
    top->eval();
#if(OPEN_WAVE_TRACE)
    if(WaveLogOpen) {
        m_trace->dump(contextp->time());
    }
#endif
}

void sim_once(){
    while(1){
        if (!top->eventsPending())
            Assert(0, "Want sim once, but no eventsPending!\n");
        contextp->time(top->nextTimeSlot());
        top->eval();
#if(OPEN_WAVE_TRACE)
        if(WaveLogOpen) {
            m_trace->dump(contextp->time());
        }
#endif
        updateCPUState(); //r: update, copy CPU State from SV Model to CPP Record.
        if(getCPU_CNT() == instrCnt + 1){
            instrCnt++;
            break;
        }
        else if(getCPU_CNT() > instrCnt + 1){
            instrCnt = *cpu_curDispCnt;
            Assert(0, "Error! Want sim once, but SV run more than one instr! Now Cnt:%ld\n", getCPU_CNT());
        }
    }
}

extern "C" void update_screen();
extern "C" void update_screen_gpu();

void sim(uint64_t n){
    for(;n>0;n--){
        sim_once();
#ifdef OPEN_VIRSCREEN
        static uint64_t time_update = 0;
        extern uint64_t getTimerCntAll();
        if(getTimerCntAll() - time_update > 1000000/60){
            time_update = getTimerCntAll();
            update_screen();
        }
        

        static SDL_Event event;
        while (SDL_PollEvent(&event)) {
            switch (event.type) {
            case SDL_QUIT:
                setCPURunState(Quit);
                return;
            default: break;
            }
        }
#endif

#ifdef OPEN_VIRSCREEN_GPU
        static uint64_t time_update = 0;
        extern uint64_t getTimerCntAll();
        if(getTimerCntAll() - time_update > 1000000/30){
            time_update = getTimerCntAll();
            update_screen_gpu();
        }
        

        static SDL_Event event;
        while (SDL_PollEvent(&event)) {
            switch (event.type) {
            case SDL_QUIT:
                setCPURunState(Quit);
                return;
            default: break;
            }
        }
#endif
        if(contextp->gotFinish()){
            setCPURunState(Finish);
            break;
        }

#ifdef SIM_VERILATOR_ITRACE
        InstrunctionTrace();
#endif
    }
}

void cpu_exec(uint64_t n){
    switch (getCPURunState()){
        case Running:
        case Stop:
            break;
        default:
            printf("Sim has Stop!Please reRun the Software!\n");
            return;
    }

    sim(n);
    // Running, //init, or running
    // Stop, //in sdb mode, wait for run/continue
    // End,  //in sdb mode, user input "q" to quit
    // Ebreak, //software call ebreak
    // Abort, //difftest error! or InValid inst!!
    // Quit, //not used
    // Finish //in SV, call $finish!
    switch (getCPURunState())
    {
    case Running:
        setCPURunState(Stop);
    case Stop:
        break;
    case End:
        printf("After sim(n), CPU state is \"End\", it's an error!\n");
        break;
    case Ebreak:
        printf("Software finish!\n");
        break;
    case Abort:
        printf("CPU Abort! diff_test_Error or invalid_instruction!\n");
        break;
    case Quit:
        printf("Get Quit Req!\n");
        break;
    case Finish:
        printf("System Verilog call $finish!\n");
        break;
    default:
        Assert(0, "After sim(n), CPU in error State!\n");
    }
}

void sim_finish(){
    if (!contextp->gotFinish()) {
        VL_DEBUG_IF(VL_PRINTF("+ Exiting without $finish; no events left\n"););
    }

    // Final model cleanup
    top->final();
}
