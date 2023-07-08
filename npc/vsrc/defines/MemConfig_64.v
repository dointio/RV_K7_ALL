
//addr size
    `define MYRISCV_ADDRDW 64
    `define MYRISCV_ADDRBUS 63:0

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

//外设配置
    `define MYRISCV_HAS_MEM_ITF
    `define MYRISCV_HAS_FIO
//r: ddr路径配置
    `define MYRISCV_DDR_ARBT_DEEP 8
    `define MYRISCV_DDR_ARBT_FIFO_CUT_READY 1
    `define MYRISCV_DDR_ICB2AXI_FIFO_DEEP 8
    `define MYRISCV_DDR_ICB2AXI_FIFO_CUT 1

//地址分配
//r: level 1
    //o: sram
    `define SRAM_ADDR_MASK          64'hfffffffff0000000 //r: 0x8000_0000 --- 0x8fff_ffff
    `define SRAM_ADDR_INDEX         64'h0000000080000000
    `define SRAM_SIZE               2048*8
    `define SRAM_ADDR_WD            11+3
    `define SRAM_ADDR_OFF           3
    `define SRAM_XLEN               64

    //o: dtcm, now not used!
    `define DTCM_ADDR_MASK          64'h00000000ffffff00
    `define DTCM_ADDR_INDEX         64'h0000000000000001 //暂时不会生效
    

    //o: others, to biu port

//r: level 2, biu region
    `define PPI_REGION_ADDRBUS      63:28 //r: 0xa000_0000 --- 0xafff_ffff
    `define PPI_REGION_INDIC        36'ha //r: new, old:36'h1, now:36'ha;
    `define CLINT_REGION_ADDRBUS    63:24 //r: 0x2000_0000 --- 0xafff_ffff
    `define CLINT_REGION_INDIC      40'h02
    `define PLIC_REGION_ADDRBUS     63:24 //r: 0xc000_0000 --- 0xafff_ffff
    `define PLIC_REGION_INDIC       40'h0c
    `define FIO_REGION_ADDRBUS      63:28 //r: 0x4000_0000 --- 0x4fff_ffff
    `define FIO_REGION_INDIC        36'h4 //瞎安排的，就每打算开FIO。。。
    //r: others, all to mem region, need to check overflow in sim!!!!to void error in fpga!!

    // `define MEM_REGION_ADDRBUS //蜂鸟将mem安排在0x2000_0000~0x3fff_ffff，这里直接将所有剩余空间都安排给mem
//r: level 3, mem region
    `define MIG_REGION_ADDRBUS      63:30 //r: 0xc000_0000 --- 0xffff_ffff
    `define MIG_REGION_INDIC        {2'b00, 32'h3}

    //o: note: uint 64bit--8byte!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    //g: note: uint 64bit--8byte!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    //r: note: uint 64bit--8byte!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    `define DDR_SIM_SIZE_CPU    16*1024*1024    //r: 8*16*1024*1024 byte
    `define DDR_SIM_SIZE_GPU    1024*1024       //r: 8*1024*1024 byte

    `define DDR_SIM_ADDR_WD           27
    `define DDR_SIM_ADDR_OFF          3
    `define DDR_SIM_XLEN              64

//r: level 3, ppi region
//ppi地址细分
    `define PPI_GPIOA_REGION_ADDRBUS    27:12 //0x?001_2000~0x?001_2fff
    `define PPI_GPIOA_REGION_INDIC      16'h0012

    `define PPI_UART_REGION_ADDRBUS    27:0 //0x?000_03f8~0x?000_0407
    `define PPI_UART_REGION_INDIC_L    28'h00003f8
    `define PPI_UART_REGION_INDIC_H    28'h0000407

    `define PPI_TIMER_REGION_ADDRBUS    27:0 //0x?000_0048~0x?000_005f
    `define PPI_TIMER_REGION_INDIC_L    28'h0000048
    `define PPI_TIMER_REGION_INDIC_H    28'h000005f

    `define PPI_SGPU_REGION_ADDRBUS_ONE 27:24 //0x?100_0000~0x?1ff_ffff
    `define PPI_SGPU_REGION_INDIC_ONE   4'h1
    `define PPI_SGPU_REGION_ADDRBUS_TWO 27:8 //0x?000_0100~0x?000_01ff
    `define PPI_SGPU_REGION_INDIC_TWO   20'h00001

    `define DISABLE_SV_ASSERTION
    `define FPGA_SOURCE

//vga
    `define SCREEN_W 800
    `define SCREEN_H 600


