
# RISCV_PATH := $(TOOLCHAIN_DIR)/tools/gnu-mcu-eclipse-riscv-none-gcc-8.2.0-2.2-20190521-0004-win64/
RISCV_PATH := /home/Riscv_Tools

# RISCV_GCC     := $(abspath $(RISCV_PATH)/bin/riscv32-unknown-elf-gcc)
# RISCV_AS      := $(abspath $(RISCV_PATH)/bin/riscv32-unknown-elf-as)
# RISCV_GXX     := $(abspath $(RISCV_PATH)/bin/riscv32-unknown-elf-g++)
# RISCV_OBJDUMP := $(abspath $(RISCV_PATH)/bin/riscv32-unknown-elf-objdump)
# RISCV_GDB     := $(abspath $(RISCV_PATH)/bin/riscv32-unknown-elf-gdb)
# RISCV_AR      := $(abspath $(RISCV_PATH)/bin/riscv32-unknown-elf-ar)
# RISCV_OBJCOPY := $(abspath $(RISCV_PATH)/bin/riscv32-unknown-elf-objcopy)
# RISCV_READELF := $(abspath $(RISCV_PATH)/bin/riscv32-unknown-elf-readelf)

RISCV_GCC     := riscv64-linux-gnu-gcc
RISCV_AS      := riscv64-linux-gnu-as
RISCV_GXX     := riscv64-linux-gnu-g++
RISCV_OBJDUMP := riscv64-linux-gnu-objdump
RISCV_GDB     := riscv64-linux-gnu-gdb
RISCV_AR      := riscv64-linux-gnu-ar
RISCV_OBJCOPY := riscv64-linux-gnu-objcopy
RISCV_READELF := riscv64-linux-gnu-readelf

.PHONY: all
all: $(TARGET)

ASM_SRCS += $(COMMON_DIR)/start.S
ASM_SRCS += $(COMMON_DIR)/trap_entry.S
C_SRCS += $(COMMON_DIR)/init.c
C_SRCS += $(COMMON_DIR)/trap_handler.c
C_SRCS += $(COMMON_DIR)/lib/utils.c
C_SRCS += $(COMMON_DIR)/lib/xprintf.c
C_SRCS += $(COMMON_DIR)/lib/uart.c
C_SRCS += $(COMMON_DIR)/lib/flash_n25q.c
C_SRCS += $(COMMON_DIR)/lib/spi.c

LINKER_SCRIPT := $(COMMON_DIR)/link_me.lds

INCLUDES += -I$(COMMON_DIR)

LDFLAGS += -T $(LINKER_SCRIPT) -nostartfiles -Wl,--gc-sections -Wl,--check-sections

ASM_OBJS := $(ASM_SRCS:.S=.o)
C_OBJS := $(C_SRCS:.c=.o)

LINK_OBJS += $(ASM_OBJS) $(C_OBJS)
LINK_DEPS += $(LINKER_SCRIPT)

CLEAN_OBJS += $(TARGET) $(LINK_OBJS) $(TARGET).dump $(TARGET).bin

CFLAGS += $(RISCV_ARCH)
CFLAGS += $(RISCV_ABI)
CFLAGS += -mcmodel=$(RISCV_MCMODEL) -ffunction-sections -fdata-sections -fno-builtin-printf -fno-builtin-malloc -O0

$(TARGET): $(LINK_OBJS) $(LINK_DEPS) Makefile
#	$(RISCV_GCC) $(CFLAGS) $(INCLUDES) $(LINK_OBJS) -o $@ $(LDFLAGS)
	riscv64-linux-gnu-ld -z $(MELF) --gc-sections $(INCLUDES) --start-group $(LINK_OBJS) --end-group -o $@ -T $(LINKER_SCRIPT) 
	$(RISCV_OBJCOPY) -O binary $@ $@.bin
	$(RISCV_OBJDUMP) --disassemble-all $@ > $@.dump

$(ASM_OBJS): %.o: %.S
	$(RISCV_GCC) $(CFLAGS) $(INCLUDES) -c -o $@ $<

$(C_OBJS): %.o: %.c
	$(RISCV_GCC) $(CFLAGS) $(INCLUDES) -c -o $@ $<

.PHONY: clean
clean:
	rm -f $(CLEAN_OBJS)
