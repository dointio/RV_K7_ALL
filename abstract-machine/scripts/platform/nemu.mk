AM_SRCS := platform/nemu/trm.c \
           platform/nemu/ioe/ioe.c \
           platform/nemu/ioe/timer.c \
           platform/nemu/ioe/input.c \
           platform/nemu/ioe/gpu.c \
           platform/nemu/ioe/audio.c \
           platform/nemu/ioe/disk.c \
           platform/nemu/mpe.c

CFLAGS    += -fdata-sections -ffunction-sections
LDFLAGS   += -T $(AM_HOME)/scripts/linker.ld \
             --defsym=_pmem_start=0x80000000 --defsym=_entry_offset=0x0
LDFLAGS   += --gc-sections -e _start
# NEMUARGS += -I $(shell dirname $(IMAGE).elf)/nemu-instlog.txt -M $(shell dirname $(IMAGE).elf)/nemu-memlog.txt

ifeq ($(NEMUARGS),)
NEMUARGS_2 :=   -I $(shell dirname $(IMAGE).elf)/nemu-instlog.txt -M $(shell dirname $(IMAGE).elf)/nemu-memlog.txt \
                -P $(shell dirname $(IMAGE).elf)/nemu-peslog.txt -E $(shell dirname $(IMAGE).elf)/nemu-excplog.txt \
                -F $(shell dirname $(IMAGE).elf)/nemu-funclog.txt -m $(IMAGE).elf
else
NEMUARGS_2 := $(NEMUARGS) \
                -I $(shell dirname $(IMAGE).elf)/nemu-instlog.txt -M $(shell dirname $(IMAGE).elf)/nemu-memlog.txt \
                -P $(shell dirname $(IMAGE).elf)/nemu-peslog.txt -E $(shell dirname $(IMAGE).elf)/nemu-excplog.txt \
                -F $(shell dirname $(IMAGE).elf)/nemu-funclog.txt -m $(IMAGE).elf
endif


CFLAGS += -DMAINARGS=\"$(mainargs)\"
CFLAGS += -I$(AM_HOME)/am/src/platform/nemu/include
.PHONY: $(AM_HOME)/am/src/platform/nemu/trm.c

image: $(IMAGE).elf
#	@$(OBJDUMP) -D $(IMAGE).elf > $(IMAGE).txt
	@echo "\33[1;31mWarning!! Objdump Close!, check abstract machine:nemu.mk to open!\33[0m"
	@echo + OBJCOPY "->" $(IMAGE_REL).bin
	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $(IMAGE).elf $(IMAGE).bin

run: image
	$(MAKE) -C $(NEMU_HOME) ISA=$(ISA) run ARGS="$(NEMUARGS_2)" IMG=$(IMAGE).bin

gdb: image
	$(MAKE) -C $(NEMU_HOME) ISA=$(ISA) gdb ARGS="$(NEMUARGS_2)" IMG=$(IMAGE).bin
