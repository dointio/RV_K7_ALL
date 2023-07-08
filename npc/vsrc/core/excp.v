`include "mydefines.v"

module excp(
//   output  commit_trap,//r:	给lsu的，在异常发生时，用于取消lsu的访问，方法貌似是在lsu处将当前请求的mask置为0
//   output  core_wfi,
//   output  wfi_halt_ifu_req,
//   output  wfi_halt_exu_req,
//   input   wfi_halt_ifu_ack,
//   input   wfi_halt_exu_ack,

//   input   amo_wait,

//   output  alu_excp_i_ready,
//   input   alu_excp_i_valid       ,
//   input   alu_excp_i_ld          ,
//   input   alu_excp_i_stamo       ,
//   input   alu_excp_i_misalgn     ,
//   input   alu_excp_i_buserr ,
  input   alu_excp_i_ecall ,
  input   alu_excp_i_ebreak ,
//   input   alu_excp_i_wfi ,
//   input   alu_excp_i_ifu_misalgn ,
//   input   alu_excp_i_ifu_buserr ,
//   input   alu_excp_i_ifu_ilegl ,
//   input   [`MYRISCV_ADDRBUS] alu_excp_i_badaddr,
  input   [`MYRISCV_ADDRBUS] alu_excp_i_pc,
//   input   [31:0] alu_excp_i_instr,
//   input   alu_excp_i_pc_vld,
  
//   output  longp_excp_i_ready,
//   input   longp_excp_i_valid,
//   input   longp_excp_i_ld,
//   input   longp_excp_i_st,// 1: load, 0: store
//   input   longp_excp_i_buserr , // The load/store bus-error exception generated
//   input   longp_excp_i_insterr, 
//   input   [`MYRISCV_ADDRBUS] longp_excp_i_badaddr,
//   input   [`MYRISCV_ADDRBUS] longp_excp_i_pc,

//   input   excpirq_flush_ack,
//   output  excpirq_flush_req,
  output  nonalu_excpirq_flush_req_raw,
  output  [`MYRISCV_ADDRBUS] excpirq_flush_add_op1,  
  output  [`MYRISCV_ADDRBUS] excpirq_flush_add_op2,  
  `ifdef E203_TIMING_BOOST//}
  output  [`MYRISCV_ADDRBUS] excpirq_flush_pc,  
  `endif//}

  input   [`MYRISCV_XLEN-1:0] csr_mtvec_r,
  input   cmt_dret_ena,
  input   cmt_ena,

  output  [`MYRISCV_ADDRBUS] cmt_badaddr,
  output  [`MYRISCV_ADDRBUS] cmt_epc,
  output  [`MYRISCV_XLEN-1:0] cmt_cause,
  output  cmt_badaddr_ena,
  output  cmt_epc_ena,
  output  cmt_cause_ena,
  output  cmt_status_ena,

  output  [`MYRISCV_ADDRBUS] cmt_dpc,
  output  cmt_dpc_ena,
  output  [3-1:0] cmt_dcause,
  output  cmt_dcause_ena,


//   input   dbg_irq_r,
//   input   [`E203_LIRQ_NUM-1:0] lcl_irq_r, //r: e203 not implement!!
  input   ext_irq_r,
  input   sft_irq_r,
  input   tmr_irq_r,

  input   status_mie_r,
  input   mtie_r,
  input   msie_r,
  input   meie_r,

//   input   dbg_mode,
//   input   dbg_halt_r,
//   input   dbg_step_r,
//   input   dbg_ebreakm_r,


//   input   oitf_empty,

//   input   u_mode,
//   input   s_mode,
//   input   h_mode,
//   input   m_mode,

  output  excp_active,

  input   clk,
  input   rst_n
  );


endmodule
