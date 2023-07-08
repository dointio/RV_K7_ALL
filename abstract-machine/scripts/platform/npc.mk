#r:my !!!!!
AM_SRCS :=  platform/npc/trm.c \
			platform/npc/ioe/ioe.c \
			platform/npc/ioe/timer.c \
			platform/npc/ioe/input.c \
			platform/npc/ioe/gpu.c \
			platform/npc/ioe/audio.c \
			platform/npc/ioe/disk.c \
            platform/npc/mpe.c

SPACE := " "

CFLAGS    += -fdata-sections -ffunction-sections
LDFLAGS   += -T $(AM_HOME)/scripts/linker_npc.ld \
             --defsym=_pmem_start=0x80000000 --defsym=_entry_offset=0x0
LDFLAGS   += --gc-sections -e _start

NPCARGS_INSTLOG ?= -I $(shell dirname $(IMAGE).elf)/npc-instlog.txt
NPCARGS_MEMLOG  ?= -M $(shell dirname $(IMAGE).elf)/npc-memlog.txt
NPCARGS_WAVELOG ?= -W  $(shell dirname $(IMAGE).elf)/npc-wave.vcd
NPCARGS_IMAGE ?= --file=$(IMAGE).bin
NPCARGS_STLOGCNT ?= 0
NPCARGS_MAXLOGCNT ?= 400000
NPCARGS_BATCH ?= -b

ifeq ($(NPCARGS),)
NPCARGS_2 :=  $(NPCARGS_INSTLOG) $(NPCARGS_MEMLOG) $(NPCARGS_WAVELOG) $(NPCARGS_IMAGE)\
             --stLogCnt=$(NPCARGS_STLOGCNT) --maxLogCnt=$(NPCARGS_MAXLOGCNT) $(NPCARGS_BATCH)
else
NPCARGS_2 := $(NPCARGS)
endif

#-b --stLogCnt=0 --maxLogCnt=1000

CFLAGS += -DMAINARGS=\"$(mainargs)\"
CFLAGS += -I$(AM_HOME)/am/src/platform/npc/include
.PHONY: $(AM_HOME)/am/src/platform/npc/trm.c

image: $(IMAGE).elf
#	@$(OBJDUMP) -d $(IMAGE).elf > $(IMAGE).txt
	@$(OBJDUMP) -D $(IMAGE).elf > $(IMAGE).txt
	@echo + OBJCOPY "->" $(IMAGE_REL).bin
	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $(IMAGE).elf $(IMAGE).bin

run: image
	$(MAKE) -C $(NPC_HOME) -f Makefile_npc.mk run_cc \
	ISA=$(ISA) ARGS="$(NPCARGS_2)"

gdb: image
	$(MAKE) -C $(NPC_HOME) -f Makefile_npc.mk gdb_cc \
	ISA=$(ISA) ARGS="$(NPCARGS_2)"

