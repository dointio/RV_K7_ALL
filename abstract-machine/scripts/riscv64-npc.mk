include $(AM_HOME)/scripts/isa/riscv64.mk
include $(AM_HOME)/scripts/platform/npc.mk
CFLAGS  += -DISA_H=\"riscv/riscv.h\"

AM_SRCS += riscv/npc/start.S \
           riscv/npc/cte.c \
           riscv/npc/trap.S \
           riscv/npc/vme.c


# CFLAGS    += -fdata-sections -ffunction-sections
# LDFLAGS   += -T $(AM_HOME)/scripts/linker.ld --defsym=_pmem_start=0x80000000 --defsym=_entry_offset=0x0
# LDFLAGS   += --gc-sections -e _start
# CFLAGS += -DMAINARGS=\"$(mainargs)\"
# .PHONY: $(AM_HOME)/am/src/riscv/npc/trm.c

# image: $(IMAGE).elf
# 	@$(OBJDUMP) -d $(IMAGE).elf > $(IMAGE).txt
# 	@echo + OBJCOPY "->" $(IMAGE_REL).bin
# 	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $(IMAGE).elf $(IMAGE).bin
