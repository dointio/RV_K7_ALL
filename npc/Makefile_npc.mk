ProjectPath := $(shell pwd)
ProjectPath := $(abspath $(ProjectPath))


VERILATOR_FLAGS := --Wall --trace --timing --timescale 1ns/1ps
#checks
VERILATOR_FLAGS += --Wno-UNUSEDPARAM
VERILATOR_FLAGS += --Wno-PINCONNECTEMPTY
VERILATOR_FLAGS += --Wno-PINMISSING
VERILATOR_FLAGS += --Wno-UNUSEDSIGNAL
VERILATOR_FLAGS += --Wno-WIDTHEXPAND
VERILATOR_FLAGS += --Wno-WIDTHTRUNC
VERILATOR_FLAGS += --Wno-UNDRIVEN
VERILATOR_FLAGS += --Wno-UNUSEDGENVAR
VERILATOR_FLAGS += --Wno-SYNCASYNCNET
VERILATOR_FLAGS += -Wno-fatal 
#store:--Wno-CASEINCOMPLETE  --Wno-UNOPTFLAT

#top module name
ifeq ($(TOP_MODEL),)
TOP_MODEL := riscv_tb
endif
CFILES := ./csrc/main.cpp \
	\
	./csrc/sim/simloop.cpp \
	./csrc/sim/trace.cpp \
	./csrc/sdb/expr.cpp \
	./csrc/sdb/watchpoint.cpp \
	./csrc/sdb/sdb.cpp \
	\
	./csrc/utils/myargs.cpp \
	./csrc/utils/log.cpp \
	./csrc/utils/disasm.cpp \
	./csrc/utils/progLoad.cpp \
	\
	./csrc/cpu/exu_check.cpp \
	./csrc/cpu/cpuStatus.cpp \
	./csrc/cpu/mem.cpp \
	\
	./csrc/module_c/div.cpp \
	./csrc/module_c/vga.cpp \
	./csrc/module_c/timer.cpp \
	./csrc/module_c/asyncfifo.cpp
	
	
DEFINE_CC := -DCC_TOP


# CPPFLAGS += -I$(ProjectPath)/csrc/
ADD_CFLAGS := -I$(ProjectPath)/csrc/include 
ADD_CFLAGS += -I$(ProjectPath)/csrc/cpu 
ADD_CFLAGS += -I$(ProjectPath)/csrc/sdb 
ADD_CFLAGS += -I$(ProjectPath)/csrc/sim 
ADD_CFLAGS += -I$(ProjectPath)/csrc/utils 
ADD_CFLAGS += -g 
ADD_CFLAGS += -O3

#r: defines--cc and defines--sv
# wavetrace
ADD_CFLAGS += -DOPEN_WAVE_TRACE
# itrace
ADD_CFLAGS += -DSIM_VERILATOR_ITRACE
# mtrace
VERILATOR_FLAGS += -DSIM_VERILATOR_MTRACE
ADD_CFLAGS += -DSIM_VERILATOR_MTRACE
# for jtag test...
# VERILATOR_FLAGS += -DJTAG_SIM 
# sim set
VERILATOR_FLAGS += -DSIM_VERILATOR 
VERILATOR_FLAGS += -DPLATFORM_SIM  #SIM or FPGA
VERILATOR_FLAGS += -DUSE_DPIC
VERILATOR_FLAGS += -DDIV_CC
#virscreen #r: note: virscreen and virscreen_gpu only open one of them!!!!!
# VERILATOR_FLAGS += -DOPEN_VIRSCREEN
# ADD_CFLAGS += -DOPEN_VIRSCREEN
#virscreen_gpu
# VERILATOR_FLAGS += -DOPEN_VIRSCREEN_GPU
# ADD_CFLAGS += -DOPEN_VIRSCREEN_GPU

VERILATOR_FLAGS += -DSRAM_MYRTL 

VERILATOR_FLAGS += -DStop_Time=0 # 0 or not define: not stop;  n: #n,then finish!

#r: defines (end)

#r: difftest (start)
DIFF_REF_NEMU_PATH = $(NEMU_HOME)/build/riscv64-nemu-interpreter-so
#r: (end)

ADD_CFLAGS_2 := "$(ADD_CFLAGS)"

ADD_LDFLAGS := "-lreadline \
	-lLLVM-14 \
	-lSDL2 \
	"


#rtl files
# RTL_INCLUDE := +incdir+./vsrc_old/rtl/define
RTL_INCLUDE := +incdir+./vsrc/defines

RTL_LISTFILE := ./listfiles/myriscv_ysyx.f
RTL_LIST := $(shell cat $(RTL_LISTFILE))
RTL_LIST_VLOG := $(filter %.v %.sv, ${RTL_LIST})
RTL_LIST_VHDL := $(filter %.vhd, ${RTL_LIST})


all: run_cc
	gtkwave verilog.dump

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "Write this Makefile by your self."

comp_rtl:
	verilator $(VERILATOR_FLAGS) $(RTL_INCLUDE) -DVERILATOR_TB_DUMPFILE -cc $(RTL_LIST_VLOG) ./vsrc/tb/$(TOP_MODEL).sv \
	$(RTL_LIST_VHDL) --top-module $(TOP_MODEL) --Mdir obj_dir_$(TOP_MODEL) --binary --prof-cfuncs -CFLAGS -DVL_DEBUG

run_rtl: comp_rtl
	@$(MAKE) -C ./obj_dir_$(TOP_MODEL)/ -f V$(TOP_MODEL).mk V$(TOP_MODEL)
	./obj_dir_$(TOP_MODEL)/V$(TOP_MODEL)

DONTCHECK := --Wno-PINCONNECTEMPTY
DONTCHECK += --Wno-PINMISSING
DONTCHECK += --Wno-UNUSEDSIGNAL
DONTCHECK += --Wno-UNDRIVEN
DONTCHECK += --Wno-WIDTHEXPAND

check :
	verilator -Wall --timing $(RTL_INCLUDE) $(DONTCHECK) -lint-only \
	$(RTL_LIST_VHDL) $(RTL_LIST_VLOG) ./vsrc/tb/$(TOP_MODEL).sv \
	--top-module $(TOP_MODEL) 

comp_cc_s1:
	verilator $(VERILATOR_FLAGS) $(DEFINE_CC) $(RTL_INCLUDE) \
	-cc $(RTL_LIST_VLOG) $(RTL_LIST_VHDL) ./vsrc/tb/$(TOP_MODEL).sv \
	-LDFLAGS $(ADD_LDFLAGS) -CFLAGS $(ADD_CFLAGS_2) \
	--top-module $(TOP_MODEL) --Mdir obj_dir_$(TOP_MODEL)_cc --exe $(CFILES)

comp_cc_s2: comp_cc_s1
	@$(MAKE) -C ./obj_dir_$(TOP_MODEL)_cc/ -f V$(TOP_MODEL).mk V$(TOP_MODEL)


DEFAULT_IMGFILE   ?= /home/xpzh/ysyx/ysyx-workbench/npc/example/gpio_me/mygpio.bin
DEFAULT_BATCH     ?= -b
DEFAULT_INSTLOG   ?= npc_default_inst.log
DEFAULT_MEMLOG    ?= npc_default_mem.log
DEFAULT_WAVELOG   ?= npc_default_wave.log
DEFAULT_StLogCnt  ?= 0
DEFAULT_MaxLogCnt ?= 2000000000000
# DEFAULT_DIFFTEST ?=


ifeq ($(ARGS),)
RUNARGS := $(DEFAULT_BATCH) $(DEFAULT_DIFFTEST) -I $(DEFAULT_INSTLOG) \
			-M $(DEFAULT_MEMLOG) -W $(DEFAULT_WAVELOG) \
			--stLogCnt=$(DEFAULT_StLogCnt) \
			--maxLogCnt=$(DEFAULT_MaxLogCnt) --file=$(DEFAULT_IMGFILE)
else
RUNARGS := $(ARGS)
endif


run_cc:
	@./obj_dir_$(TOP_MODEL)_cc/V$(TOP_MODEL) $(RUNARGS)

gdb_cc:
	@gdb --args ./obj_dir_cc/V$(TOP_MODEL)

clean:
	rm -rf obj_dir_new_rtl

clean_cc:
	rm -rf obj_dir_cc

clean_vcd:
	rm -f *.vcd

# include ../Makefile


