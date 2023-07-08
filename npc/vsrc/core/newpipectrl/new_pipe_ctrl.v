`include "mydefines.v"

module new_pipe_ctrl
(
    clk,
    rst,
    
    //中断输入
    soft_trap_i,
    ext_trap_i,
    time_trap_i,
    jtag_halt_i,
    jtag_rst_i,

    //异常输入
    //没有实现异常

    //alu跳转输入及指令有效输入
    // exu_bjp,
    mret_i,
    exu_bjp_taken,
    exu_bjp_prdt_taken,
    exu_instr_pc,
    exu_bjp_jaddr,
    exu_instr_vld,
    exu_instr_rdy,

    //相关csr读写接口
    ext_irq_trigge,
    sft_irq_trigge,
    tim_irq_trigge,

    status_mie_i,
    mtie_i,
    msie_i,
    meie_i,

    cmt_badaddr,
    cmt_badaddr_ena,
    cmt_epc,
    cmt_epc_ena,
    cmt_cause,
    cmt_cause_ena,
    cmt_status_ena,
    cmt_mret_ena,

    csr_epc_i,
    csr_mtvec_i,

    //冲刷请求
    halt_req,
    flush_req,
    flush_addr,

    //r: for oitf, 
    flush_req_no_delay
);

input clk;
input rst;

//中断输入
input mret_i;
input soft_trap_i;
input ext_trap_i;
input time_trap_i;
input jtag_halt_i;
input jtag_rst_i;

//异常输入
//没有实现异常

//alu跳转输入及指令有效输入
// input exu_bjp,
input exu_bjp_taken;
input exu_bjp_prdt_taken;
input [`MYRISCV_ADDRBUS] exu_instr_pc;
input [`MYRISCV_ADDRBUS] exu_bjp_jaddr;
input exu_instr_vld;
input exu_instr_rdy;

//相关csr读写接口
output ext_irq_trigge;
output sft_irq_trigge;
output tim_irq_trigge;

input status_mie_i;
input mtie_i;
input msie_i;
input meie_i;

output [`MYRISCV_REGBUS] cmt_badaddr;
output cmt_badaddr_ena;
output [`MYRISCV_REGBUS] cmt_epc;
output cmt_epc_ena;
output [`MYRISCV_REGBUS] cmt_cause;
output cmt_cause_ena;
output cmt_status_ena;
output cmt_mret_ena;

input [`MYRISCV_ADDRBUS] csr_epc_i;
input [`MYRISCV_ADDRBUS] csr_mtvec_i;

//冲刷请求
output halt_req;
output flush_req;
output [`MYRISCV_ADDRBUS] flush_addr;

output flush_req_no_delay;

//注意，如果当前指令有效，但是被阻塞了，那肯定是长指令，不是跳转指令，此时，
//在dec2exu的filp有特殊处理，这个指令不会被冲掉（此时只能是中断触发冲刷），
//还会执行，这避免了很多问题。
wire [`MYRISCV_ADDRBUS] interrupt_ret_pc;
reg [`MYRISCV_ADDRBUS] interrupt_ret_pc_r;
assign interrupt_ret_pc = (exu_instr_vld & exu_instr_rdy) ? 
                        (exu_bjp_taken ? exu_bjp_jaddr : exu_instr_pc + 4)
                        : (interrupt_ret_pc_r);

always@(posedge clk /*or negedge rst*/) begin
    if(!rst) begin
        interrupt_ret_pc_r <= 0;
    end
    else begin
        interrupt_ret_pc_r <= interrupt_ret_pc; 
    end
end

wire interrupt_req =(
                        (soft_trap_i & msie_i) 
                        | (ext_trap_i & meie_i) 
                        | (time_trap_i & mtie_i)
                    ) & status_mie_i;
wire mret_req = mret_i; //mret不会与jump一起来到，而且
                        //如果不支持中断嵌套，也不会与interrupt一起来到。
wire jump_req = (exu_bjp_taken ^ exu_bjp_prdt_taken) & (exu_instr_vld & exu_instr_rdy);
//*********************jtag_halt check*******************************
// assign halt_req = jtag_halt_i;
reg_rs #(1, 0) halt_reg (clk, rst, jtag_halt_i, halt_req);

//*********************mret check and inter check*******************************

wire mret_en = mret_req & (~halt_req);
wire interrupt_en = interrupt_req & (~mret_req) & (~halt_req);
assign ext_irq_trigge = ext_trap_i;
assign sft_irq_trigge = soft_trap_i;
assign tim_irq_trigge = time_trap_i;
assign cmt_badaddr = 0;
assign cmt_badaddr_ena = 1'b0;
assign cmt_epc = interrupt_ret_pc;
assign cmt_epc_ena = interrupt_en;
assign cmt_cause = 0;
assign cmt_cause_ena = 1'b0;
assign cmt_status_ena = interrupt_en;
assign cmt_mret_ena = mret_en;
wire [`MYRISCV_ADDRBUS] interrupt_addr = mret_en ? csr_epc_i : csr_mtvec_i;

//*********************jump check*******************************
wire jump_en = jump_req & (~interrupt_req) & (~halt_req);
wire [`MYRISCV_ADDRBUS] jump_addr = exu_bjp_prdt_taken ? (exu_instr_pc + 4)
                                : exu_bjp_jaddr;

//r: priority:jtag > mret > interrupt(different interrupt prioriy check by plic and clinc) > jump
// assign flush_req = jump_en | interrupt_en | mret_en | jtag_rst_i;
// assign flush_addr = jtag_rst_i ? `RISCV_STVEC :((mret_en | interrupt_en) ? interrupt_addr : jump_addr);

wire flush_req_i = jump_en | interrupt_en | mret_en | jtag_rst_i;
wire [`MYRISCV_ADDRBUS] flush_addr_i = jtag_rst_i ? `RISCV_STVEC :((mret_en | interrupt_en) ? interrupt_addr : jump_addr);

reg_rs #(1, 0) flush_reg (clk, rst, flush_req_i, flush_req);
reg_rs #(`MYRISCV_ADDRDW, 0) flush_addr_reg (clk, rst, flush_addr_i, flush_addr);
assign flush_req_no_delay = flush_req_i;

endmodule
