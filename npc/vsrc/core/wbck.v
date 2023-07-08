`include "mydefines.v"
`include "e203_defines.v"

module wbck
(
    // clk,
    // rst,

    //oitf
    // cur_w_index,
    clr_req,
    clr_idx,

    //nice
    nice2wb_vld,
    nice2wb_rdy,
    nice2wb_wdata,
    nice2wb_waddr,

    //alu
    alu2wb_vld,
    alu2wb_rdy,
    alu2wb_wdata,
    alu2wb_waddr,

    //div
    div2wb_vld,
    div2wb_rdy,
    div2wb_wdata,
    div2wb_waddr,

    //lsu
    lsu2wb_vld,
    lsu2wb_rdy,
    lsu2wb_wdata,
    lsu2wb_waddr,

    //to regfile
    reg_wen,
    reg_waddr,
    reg_wdata
);

// input rst;
// input [`MYRISCV_REGADDRBUS] cur_w_index;
output clr_req;
output [`MYRISCV_REGADDRBUS] clr_idx;

input nice2wb_vld;
output nice2wb_rdy;
input [`MYRISCV_REGADDRBUS] nice2wb_waddr;
input [`MYRISCV_REGBUS] nice2wb_wdata;

input alu2wb_vld;
output alu2wb_rdy;
input [`MYRISCV_REGBUS] alu2wb_wdata;
input [`MYRISCV_REGADDRBUS] alu2wb_waddr;

input div2wb_vld;
output div2wb_rdy;
input [`MYRISCV_REGBUS] div2wb_wdata;
input [`MYRISCV_REGADDRBUS] div2wb_waddr;

input lsu2wb_vld;
output lsu2wb_rdy;
input [`MYRISCV_REGBUS] lsu2wb_wdata;
input [`MYRISCV_REGADDRBUS] lsu2wb_waddr;

output reg_wen; 
output [`MYRISCV_REGADDRBUS] reg_waddr;
output [`MYRISCV_REGBUS] reg_wdata;

//lsu最优先，nic次级优先 ...
wire lsu_e  = lsu2wb_vld;
wire nice_e = (~lsu2wb_vld) & nice2wb_vld;
wire div_e  = (~lsu2wb_vld) & (~nice2wb_vld) & div2wb_vld;
wire alu_e  = (~lsu2wb_vld) & (~nice2wb_vld) & (~div2wb_vld);

assign lsu2wb_rdy   = 1;
assign nice2wb_rdy  = (~lsu_e);
assign div2wb_rdy   = (~lsu_e) & (~nice_e);
assign alu2wb_rdy   = (~lsu_e) & (~nice_e) & (~div_e);

assign reg_wen      = alu2wb_vld | div2wb_vld | nice2wb_vld | lsu2wb_vld;
assign reg_waddr    = lsu_e ? (lsu2wb_waddr) : (nice_e ? nice2wb_waddr : (div_e ? div2wb_waddr : alu2wb_waddr));
assign reg_wdata    = lsu_e ? (lsu2wb_wdata) : (nice_e ? nice2wb_wdata : (div_e ? div2wb_wdata : alu2wb_wdata));

//r: note, div_cc is not long instr, but div_sv is long instr!
assign clr_req = (lsu_e) | (nice_e) 
    `ifndef DIV_CC 
        | (div_e)
    `endif
    ;
assign clr_idx = reg_waddr;
endmodule
