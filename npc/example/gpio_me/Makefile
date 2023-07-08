
# RISCV_ARCH := -march=rv32im
# RISCV_ABI := -mabi=ilp32
# MELF := -melf32lriscv
# CFLAGS += -DRISCV_32

RISCV_ARCH := -march=rv64g
MELF := -melf64lriscv
RISCV_MCMODEL := medlow

TARGET = mygpio

#CFLAGS += -DSIMULATION
CFLAGS += -O2
#ASM_SRCS +=
#LDFLAGS +=
#INCLUDES += -I.

C_SRCS := \
	main.c \


COMMON_DIR = ..
TOOLCHAIN_DIR = ../../..
include ../common.mk
