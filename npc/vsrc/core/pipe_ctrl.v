`include "mydefines.v"

module pipe_ctrl
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
    // excp_vld_alu_i,
    // excp_vld_lsu_i,
    ecall_i,
    ebreak_i,
    lsu_badaddr_i,

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


    u_mode,
    s_mode,
    h_mode,
    m_mode,

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
// input excp_vld_alu_i;
// input excp_vld_lsu_i;
input ecall_i;
input ebreak_i;
input [`MYRISCV_ADDRBUS] lsu_badaddr_i;

//alu跳转输入及指令有效输入
// input exu_bjp,
input exu_bjp_taken;
input exu_bjp_prdt_taken;
input [`MYRISCV_ADDRBUS] exu_instr_pc;
input [`MYRISCV_ADDRBUS] exu_bjp_jaddr;
input exu_instr_vld;
input exu_instr_rdy;

//相关csr读写接口
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


input   u_mode;
input   s_mode;
input   h_mode;
input   m_mode;

//冲刷请求
output halt_req;
output flush_req;
output flush_req_no_delay;
output [`MYRISCV_ADDRBUS] flush_addr;


//*********************************int/jump/excp req******************************************
wire excp_vld_alu_i = ecall_i;
wire excp_vld_lsu_i = 1'b0;
wire excp_req = excp_vld_alu_i | excp_vld_lsu_i;
wire interrupt_req =(
                        (soft_trap_i & msie_i) 
                        | (ext_trap_i & meie_i) 
                        | (time_trap_i & mtie_i)
                    ) & status_mie_i;
wire mret_req       = mret_i; //mret不会与jump一起来到，而且
                                //如果不支持中断嵌套，也不会与interrupt一起来到。
wire ebreak_req     = ebreak_i;
wire jump_req       = (exu_bjp_taken ^ exu_bjp_prdt_taken) & (exu_instr_vld & exu_instr_rdy);



//********************************* zhong cai***********************************
//r: priority:excp > intr(different interrupt prioriy check by plic and clinc) > mret, ebreak, jump
wire excp_en        = excp_req;
wire interrupt_en   = ~excp_req  & interrupt_req;
wire ebreak_en      = ebreak_req & ~excp_req & ~interrupt_req;
wire mret_en        = mret_req   & ~excp_req & ~interrupt_req;
wire jump_en        = jump_req   & ~excp_req & ~interrupt_req;
wire halt_en        = jtag_halt_i   & ~excp_req & ~interrupt_req & ~(mret_en | ebreak_en | jump_en);

//********************************* excp/intr ret pc*****************************
wire [`MYRISCV_ADDRBUS] excp_intr_ret_pc;
wire [`MYRISCV_ADDRBUS] excp_intr_ret_pc_r;
assign excp_intr_ret_pc =   (excp_vld_alu_i & excp_vld_lsu_i) ? exu_instr_pc : (
                            (exu_instr_vld & exu_instr_rdy) ? (exu_bjp_taken ? exu_bjp_jaddr : exu_instr_pc + 4) :
                            excp_intr_ret_pc_r);

// assign excp_intr_ret_pc =    (exu_instr_vld & exu_instr_rdy)? exu_instr_pc : excp_intr_ret_pc_r;

reg_rs  #(`MYRISCV_ADDRDW, 0) interrupt_pc_reg (clk, rst, excp_intr_ret_pc, excp_intr_ret_pc_r);

//*************************** jump addr *******************************
wire [`MYRISCV_ADDRBUS] jump_addr = exu_bjp_prdt_taken ? (exu_instr_pc + 4)
                                : exu_bjp_jaddr;

//*************************** csr cmt *********************************

assign cmt_badaddr_ena  = 1'b0;
assign cmt_badaddr      = lsu_badaddr_i;
assign cmt_epc_ena      = excp_en | interrupt_en;
assign cmt_epc          = excp_intr_ret_pc;

assign cmt_cause_ena    = excp_en | interrupt_en;
assign cmt_cause[`MYRISCV_XLEN-1]   = interrupt_en;
assign cmt_cause[`MYRISCV_XLEN-2:5] = 0;
wire [4:0] excp_cause = (ecall_i & u_mode) ? 5'd8
    : (ecall_i & s_mode) ? 5'd9 //Environment call from S-mode
    : (ecall_i & h_mode) ? 5'd10 //Environment call from H-mode
    : (ecall_i & m_mode) ? 5'd11 //Environment call from M-mode
    : 5'h1f; // reserved //r: ebreak is a spical excp in ysyx!!!
    //   alu_excp_flush_req_ifu_misalgn? 5'd0 //Instruction address misaligned
    // : alu_excp_flush_req_ifu_buserr ? 5'd1 //Instruction access fault
    // : alu_excp_flush_req_ifu_ilegl  ? 5'd2 //Illegal instruction
    // : alu_excp_flush_req_ebreak     ? 5'd3 //Breakpoint
    // : alu_excp_flush_req_ld_misalgn ? 5'd4 //load address misalign
    // : (longp_excp_flush_req_ld_buserr | alu_excp_flush_req_ld_buserr) ? 5'd5 //load access fault
    // : alu_excp_flush_req_stamo_misalgn ? 5'd6 //Store/AMO address misalign
    // : (longp_excp_flush_req_st_buserr | alu_excp_flush_req_stamo_buserr) ? 5'd7 //Store/AMO access fault
    // : (alu_excp_flush_req_ecall & u_mode) ? 5'd8 //Environment call from U-mode
    // : (alu_excp_flush_req_ecall & s_mode) ? 5'd9 //Environment call from S-mode
    // : (alu_excp_flush_req_ecall & h_mode) ? 5'd10 //Environment call from H-mode
    // : (alu_excp_flush_req_ecall & m_mode) ? 5'd11 //Environment call from M-mode
    // : longp_excp_flush_req_insterr ? 5'd16// This only happened for the NICE long instructions actually  
    // : 5'h1F;//Otherwise a reserved value
wire [4:0] intr_cause = 
    (soft_trap_i & msie_i) ? 5'd3 :
    (time_trap_i & mtie_i) ? 5'd7 :
    (ext_trap_i  & meie_i) ? 5'd11 :
    5'h1f;
assign cmt_cause[4:0] = excp_en ? excp_cause : intr_cause;

assign cmt_status_ena   = excp_en | interrupt_en;
assign cmt_mret_ena     = mret_en;

//r:************************* spical for ysyx **********************************************
wire cpu_ebreak;
reg_rs  #(1, 0) ebreak_reg (clk, rst, ebreak_en, cpu_ebreak);

//********************************* jtag halt *********************************
wire halt_w;
reg_rs #(1, 0) halt_reg (clk, rst, jtag_halt_i, halt_w);
assign halt_req = halt_w | cpu_ebreak;

//***************************** flush sig out ************************************************
wire flush_req_i = excp_en | interrupt_en | jump_en | mret_en | jtag_rst_i;
wire [`MYRISCV_ADDRBUS] flush_addr_i = 
        jtag_rst_i ? `RISCV_STVEC : 
        (excp_en | interrupt_en) ? csr_mtvec_i :
        mret_en ? csr_epc_i : 
        jump_addr;

reg_rs #(1, 0) flush_reg (clk, rst, flush_req_i, flush_req);
reg_rs #(`MYRISCV_ADDRDW, 0) flush_addr_reg (clk, rst, flush_addr_i, flush_addr);
assign flush_req_no_delay = flush_req_i;


endmodule
