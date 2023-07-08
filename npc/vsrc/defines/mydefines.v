//select sim or fpga
`define FPGA_XILINX     //XILINX or ALTER //only used when not in sim_platform!
//arch
`define MYRISCV_ARCH_64    //64 or 32
`define MEM_ARCH_64     //64 or 32, addr range

//mul
`define MYRISCV_SUPPORT_MULDIV

//
`define RISCV_STVEC 64'h80000000
`ifdef MYRISCV_ARCH_64    //64 or 32 //R: not used now
    `define RISCV_TRAP_BASE 64'd0
`else
    `define RISCV_TRAP_BASE 32'd0
`endif


//set rst edge 
`define RSTLEVEL 1'b0

//r: for old e203
`define E203_HART_ID_W  1
`define E203_SUPPORT_MCYCLE_MINSTRET
`define E203_PC_SIZE_IS_32

//IP config
// `define SRAM_MYRTL
// `define USE_XILINXIP

//nice
`define MYRISCV_HAS_NICE


//fpga_xilinx

//arbit split
    `define ITCM_SELECT_PC      2'b01
    `define ITCM_SELECT_LSU     2'b10
    `define ITCM_SELECT_EXT     2'b11

    `define BIU_SELECT_PC       2'b01 
    `define BIU_SELECT_LSU      2'b10
    `define BIU_SELECT_EXT      2'b11

    `define LSU_SELECT_ITCM         2'b01
    `define LSU_SELECT_DTCM         2'b10
    `define LSU_SELECT_BIU          2'b11

    `define LSU_SELECT_MUXIN_BUS    0:0
    `define LSU_SELECT_MUXIN_WD 1
    `define LSU_SELECT_EXU          1'b0
    `define LSU_SELECT_NICE         1'b1
    

//oitf
    `define OitfSize 4
    `define OitfSizeWD 2

//csr
    `define MYRISCV_CSRADDRBUS 11:0

`ifdef MYRISCV_ARCH_64
    `include "DataFormat_64.v"
`else
    `include "DataFormat_32.v"
`endif

`ifdef MEM_ARCH_64
    `include "MemConfig_64.v"
`else
    `include "MemConfig_32.v"
`endif

`include "myfuncs.v"
