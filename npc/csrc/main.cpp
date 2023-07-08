#include <stdlib.h> //所有文件都要包含
#include <iostream> //所有文件都要包含
#include <verilated.h> //仿真的API
#include <verilated_vcd_c.h> //生成波形文件的API
#include "Vriscv_tb.h" // verilated 后 ALU模块的类定义
#include "Vriscv_tb__Dpi.h"
#include "svdpi.h"

#include "cpuStatus.hpp"
#include "sim.hpp"
#include "sdb.hpp"
#include "utils.hpp"


// void init_disasm(const char *triple);

int main(int argc, char** argv, char** env) {
	parse_args(argc, argv);

	// Setup context, defaults, and parse command line
    Verilated::debug(0);

    init_log();
    sim_init(argc, argv);
    init_sdb();
    init_disasm( "riscv64" "-pc-linux-gnu" );

	svSetScope(svGetScopeFromName("TOP.riscv_tb"));

	loadBinFile();

    if(sdb_in_batch_mode()){
        cpu_exec(-1);
    }
    else{
        sdb_mainloop();
    }

    printf("Sim finish! CPU state: %d\n", getCPURunState());
    
    sim_finish();

    if(getCPURunState() != Ebreak)
        return 1;
    else
        return 0;
}