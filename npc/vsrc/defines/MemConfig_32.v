
//addr size
    `define MYRISCV_ADDRDW 32
    `define MYRISCV_ADDRBUS 31:0

//biu总线配置
    `define MYRISCV_BIU_OUTFIFO_DEEP 2
    `define MYRISCV_BIU_OUTFIFO_CUT_READY 1
    `define MYRISCV_BIU_CMDBUF_DEEP 2 //用来缓存cmd，同时缓存请求。
    `define MYRISCV_BIU_CMDBUF_CUT_READY `MYRISCV_BIU_OUTFIFO_CUT_READY
    `define MYRISCV_BIU_RSPBUF_DEEP 1 //从biu总线机制来看，没有缓存rsp的必要，这里加fifo纯粹是用来切断时序路径。
    `define MYRISCV_BIU_RSPBUF_CUT_READY 1
    `define MYRISCV_BIU_BUF_CNTW 2
    `define MYRISCV_BIU_ARBT_FIFO_CUT_READY 0
    `define MYRISCV_BIU_SPLT_FIFO_CUT_READY 1

//r: ddr路径配置
    `define MYRISCV_DDR_ARBT_DEEP 4
    `define MYRISCV_DDR_ARBT_FIFO_CUT_READY 1
    `define MYRISCV_DDR_ICB2AXI_FIFO_DEEP 4
    `define MYRISCV_DDR_ICB2AXI_FIFO_CUT 1
//外设配置
    `define MYRISCV_HAS_MEM_ITF
    `define MYRISCV_HAS_FIO

//地址分配
    // `define ITCM_REGION_ADDRBUS 31:28
    // `define ITCM_REGION_INDIC 4'h8
    `define SRAM_ADDR_MASK  32'hf0000000
    `define SRAM_ADDR_INDEX 32'h20000000

    // `define DTCM_REGION_ADDRBUS 31:28
    // `define DTCM_REGION_INDIC 4'h8
    `define DTCM_ADDR_MASK  32'hffffff00
    `define DTCM_ADDR_INDEX 32'h00000001 //暂时不会生效

    `define PPI_REGION_ADDRBUS 31:28
    `define PPI_REGION_INDIC 4'h1
    `define CLINT_REGION_ADDRBUS 31:24
    `define CLINT_REGION_INDIC 8'h02
    `define PLIC_REGION_ADDRBUS 31:24
    `define PLIC_REGION_INDIC 8'h0c
    `define FIO_REGION_ADDRBUS 31:28
    `define FIO_REGION_INDIC 4'h4 //瞎安排的，就每打算开FIO。。。
    // `define MEM_REGION_ADDRBUS //蜂鸟将mem安排在0x2000_0000~0x3fff_ffff，这里直接将所有剩余空间都安排给mem
    // `define MEM_REGION_INDIC

//ppi地址细分
    `define PPI_GPIOA_REGION_ADDRBUS 27:12 //0x1001_2000~0x1001_2fff
    `define PPI_GPIOA_REGION_INDIC 16'h0012
    // `define PPI_GPIOB_REGION_ADDRBUS
    // `define PPI_UART_REGION_ADDRBUS
    // `define PPI_IIC_REGION_ADDRBUS

    `define DISABLE_SV_ASSERTION
    `define FPGA_SOURCE
