ProjectPath := $(shell pwd)
ProjectPath := $(abspath $(ProjectPath))

VERILATOR_FLAGS := --Wall --trace --timing --timescale 1ps/1ps
VERILATOR_FLAGS += -DPLATFORM_SIM
VERILATOR_FLAGS += -DSIM_VERILATOR
VERILATOR_FLAGS += -DStop_Time=0 # 0 or not define: not stop;  n: #n,then finish!
VERILATOR_FLAGS += -DDIV_CC
# VERILATOR_FLAGS += -DSIM_VERILATOR_MTRACE
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
TOP_MODEL := biu_module_tb

RTL_INCLUDE := +incdir+./vsrc/defines

RTL_LIST_VLOG := ./vsrc/pes/biu_master.v ./vsrc/tb/biu_module_tb.v ./vsrc/pes/gpu_simple.v \
                ./vsrc/pes/vgaVirScreen.v \
                ./vsrc/utils/reg_rs.v ./vsrc/utils/reg_enrs.v ./vsrc/utils/xchecker_reg.v
RTL_LIST_VHDL := 

# for gcc!!
ADD_LDFLAGS := "-lreadline \
	-lLLVM-14 \
	-lSDL2 \
	"

ADD_CFLAGS := -I$(ProjectPath)/csrc/include
ADD_CFLAGS += -I$(ProjectPath)/csrc/cpu
ADD_CFLAGS += -I$(ProjectPath)/csrc/sdb
ADD_CFLAGS += -I$(ProjectPath)/csrc/sim
ADD_CFLAGS += -I$(ProjectPath)/csrc/utils
ADD_CFLAGS += -DSIM_VERILATOR_ITRACE

ADD_CFLAGS_2 := "$(ADD_CFLAGS)"

CFILES := ./csrc/module_tb/main_vga.cpp \
	./csrc/module_c/vga.cpp

all: run
	gtkwave verilog.dump

comp:
	verilator $(VERILATOR_FLAGS) $(RTL_INCLUDE) \
	-cc $(RTL_LIST_VLOG) $(RTL_LIST_VHDL) \
	-LDFLAGS $(ADD_LDFLAGS) -CFLAGS $(ADD_CFLAGS_2) \
	--top-module $(TOP_MODEL) --Mdir obj_dir_cc --exe $(CFILES)

run: comp
	@$(MAKE) -C ./obj_dir_cc/ -f V$(TOP_MODEL).mk V$(TOP_MODEL)
	./obj_dir_cc/V$(TOP_MODEL)

DONTCHECK := --Wno-PINCONNECTEMPTY
DONTCHECK += --Wno-PINMISSING
DONTCHECK += --Wno-UNUSEDSIGNAL
DONTCHECK += --Wno-UNDRIVEN
DONTCHECK += --Wno-WIDTHEXPAND

check :
	verilator -Wall --timing $(RTL_INCLUDE) $(DONTCHECK) -lint-only $(RTL_LIST_VHDL) $(RTL_LIST_VLOG) --top-module $(TOP_MODEL) 

clean:
	rm -rf obj_dir_mdtb

# include ../Makefile


