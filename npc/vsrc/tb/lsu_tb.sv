module lsu_tb ();

`include "mydefines.v"

wire  clk,rst;
wire  disp2lsu_rdy,
wire  [`MYRISCV_ADDRBUS] ex2lsu_pc,   // 指令地址
wire  [`MYRISCV_REGBUS] ex2lsu_rs1,       // 通用寄存器1输入数据
wire  [`MYRISCV_REGBUS] ex2lsu_rs2,       // 通用寄存器2输入数据
wire  [`MYRISCV_REGBUS] ex2lsu_imm,
wire  ex2lsu_rdwen,                    // 是否写通用寄存器
wire  [`MYRISCV_REGADDRBUS] ex2lsu_rdidx,    // 写通用寄存器地址
wire  [`MY_DECINFO_WIDTH-1 : 0] ex2lsu_info,

wire nice2lsu_vld,
wire nice2lsu_rdy,
wire nice2lsu_read,   // 指令地址
wire [`MYRISCV_ADDRBUS] nice2lsu_addr,       // 通用寄存器1输入数据
wire [`MYRISCV_REGBUS] nice2lsu_wdata,       // 通用寄存器2输入数据
wire  [(`MYRISCV_XLEN/8-1):0] nice2lsu_wmask,
wire [1:0] nice2lsu_size,
wire nice2lsu_unsign,
wire [`MYRISCV_REGADDRBUS] nice2lsu_rdidx,
wire nice2lsu_ret,//将结果写回nice而不是reg中.

wire lsu_cmd_vld,
wire lsu_cmd_rdy,
wire lsu_cmd_read,
wire [`MYRISCV_ADDRBUS] lsu_cmd_addr,
wire [`MYRISCV_REGBUS] lsu_cmd_wdata,
wire [(`MYRISCV_XLEN/8-1):0] lsu_cmd_wmask,

wire lsu_rsp_vld,
wire lsu_rsp_rdy,
wire [`MYRISCV_REGBUS] lsu_rsp_rdata,
wire lsu_rsp_err,

// to nice
wire lsu2nice_vld,                   // 
wire lsu2nice_rdy,
wire [`MYRISCV_REGBUS] lsu2nice_wdata,       // 
wire [`MYRISCV_REGADDRBUS] lsu2nice_rdidx,   // 这个返回地址不知道有没有用，先留着。

// to regs
wire lsu2wb_vld,                   // 是否写通用寄存器
wire lsu2wb_rdy,
wire [`MYRISCV_REGBUS] lsu2wb_wdata,       // 写寄存器数据
wire [`MYRISCV_REGADDRBUS] lsu2wb_rdidx   // 写通用寄存器地址


endmodule

