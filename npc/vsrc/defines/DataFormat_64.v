//data format
    `define MYRISCV_XLEN 64
    //REG
    `define MYRISCV_REGNUM          32
    `define MYRISCV_REGWD           `MYRISCV_XLEN
    `define MYRISCV_REGBUS          `MYRISCV_XLEN-1:0
    `define MYRISCV_REGADDRWD       5
    `define MYRISCV_REGADDRBUS      4:0
    //CSR REG
    `define MYRISCV_CSRREGWD        32
    `define MYRISCV_CSRREGBUS       31:0
    //DATA BUS
    // `define MYRISCV_DATAADDRWD      `MYRISCV_XLEN
    // `define MYRISCV_DATAADDRBUS     `MYRISCV_XLEN-1:0
    `define MYRISCV_DATADW          `MYRISCV_XLEN
    `define MYRISCV_DATABUS         `MYRISCV_XLEN-1:0
    //INSTR BUS, MAY NOT EQ TO DATA BUS
    // `define MYRISCV_INSTADDRWD      `MYRISCV_XLEN
    // `define MYRISCV_INSTADDRBUS     `MYRISCV_XLEN-1:0
    `define MYRISCV_INSTWD          32
    `define MYRISCV_INSTBUS         31:0
