`include "e203_defines.v"
`include "mydefines.v"


module csr_64(
    input nonflush_cmt_ena,     //没有用，空引脚。。
    `ifdef E203_HAS_NICE
        output nice_xs_off,     //没有用，固定assign 1'b0
    `endif

    //**********************************************
    //用！一般读写接口，同一般寄存器。
    input csr_ena,
    input csr_wr_en,
    input csr_rd_en,
    input [12-1:0] csr_idx,
    output [`MYRISCV_XLEN-1:0] read_csr_dat,
    input  [`MYRISCV_XLEN-1:0] wbck_csr_dat,
    //**********************************************

    output csr_access_ilgl,     //没有用，固定输出0
    output tm_stop,             //停止time计数器，看来这个计数器在外面，难道是在定时器里？
    output core_cgstop,         //我用不到，内核时钟停止。
    output tcm_cgstop,          //我用不到，TCM时钟停止。我都不知道TCM是啥。
    output itcm_nohold,         //我用不到？停止itcm？就是itcmnohold_r[0]（也只有bit 0有效），这个是蜂鸟自己加的。
    output mdv_nob2b,           //我用不到？不知道干啥的，就是mdvnob2b_r[0]（也只有bit 0有效），这个csr是蜂鸟自己加的。

    input  [`E203_HART_ID_W-1:0] core_mhartid, //暂时用不到(input 0)，直连mhartid[0]寄存器（只读，且单核心只有bit 0有效），应该与jtag有关。
    input  ext_irq_r,   //用！三个irq用于更新meip,msip,mtip。在对应中断发生时触发。
    input  sft_irq_r,   //用！
    input  tmr_irq_r,   //用！

    //用！下面四个就是mie寄存器（中断使能）输出
    output status_mie_r,
    output mtie_r,
    output msie_r,
    output meie_r,

    //***************************************************************************************************************
    //暂时不用，这dcsr,dpc,dscratch三个寄存器不知道干啥的，和dbg有关，而且实际在csr外面，只是根据csr地址才映射在csr里，好像不是csr标准寄存器？。
    //wr_xxx_ena来写，dcsr_r等直接映射，wr_csr_nxt就是写入三个寄存器的数据。
    output wr_dcsr_ena    ,
    output wr_dpc_ena     ,
    output wr_dscratch_ena,

    output [`MYRISCV_XLEN-1:0]  wr_csr_nxt, //直连wbck_csr_data(csr写入数据)，难道外面还有csr寄存器？？

    //这三个输入就是直接作为某个csr寄存器来输出给core看的（让core通过csr指令读取）
    input [`MYRISCV_XLEN-1:0]   dcsr_r,      //暂时用不到(input 0)
    input [`MYRISCV_ADDRDW-1:0] dpc_r,    //暂时用不到(input 0)
    input [`MYRISCV_XLEN-1:0]   dscratch_r,  //暂时用不到(input 0)
    //***************************************************************************************************************

    input  dbg_mode,        //暂时用不到(input 0)，dbg相关
    input  dbg_stopcycle,   //暂时用不到(input 0)，dbg相关

    output u_mode, //没有用，实际仅支持机器模式。。。
    output s_mode, //没有用，实际仅支持机器模式。。。
    output h_mode, //没有用，实际仅支持机器模式。。。
    output m_mode, //固定1

    //用！对各种寄存器进行硬件写入，这些寄存器都是支持硬件写入的，所以对硬件写入留出专门接口。
    input [`MYRISCV_ADDRDW-1:0] cmt_badaddr, //用！mtval写入,暂时用不到内存地址异常。
    input cmt_badaddr_ena,
    input [`MYRISCV_ADDRDW-1:0] cmt_epc, //用！epc写入
    input cmt_epc_ena,
    input [`MYRISCV_XLEN-1:0] cmt_cause, //用！mcause写入
    input cmt_cause_ena,
    input cmt_status_ena, //用！mstatus写入，在异常发生时触发，这里的写入内容是固定的，所以直接没有留出数据口。
    
    input cmt_instret_ena, //暂时用不到，这个是指令计数器的使能端口。

    input cmt_mret_ena, //用！mret命令到来时触发，触发修改mstatus。而mstatus写入内容是固定值，所以没有数据口。
    
    output[`MYRISCV_ADDRDW-1:0]     csr_epc_r, //用！输出epc值
    output[`MYRISCV_ADDRDW-1:0]     csr_dpc_r, //暂时不用，输出dpc值，不知道dpc是干啥的？
    output[`MYRISCV_XLEN-1:0]       csr_mtvec_r, //用！输出mtvec_r值


    input  clk_aon, //clk计数器专用，永远不会停止的时钟，用于时钟计数。
    input  clk, //csr寄存器时钟
    input  rst_n //复位。

  );

assign csr_access_ilgl = 1'b0;

// Only toggle when need to read or write to save power
wire wbck_csr_wen = csr_wr_en & csr_ena & (~csr_access_ilgl);
wire read_csr_ena = csr_rd_en & csr_ena & (~csr_access_ilgl);

wire [1:0] priv_mode = u_mode ? 2'b00 : 
                       s_mode ? 2'b01 :
                       h_mode ? 2'b10 : 
                       m_mode ? 2'b11 : 
                                2'b11;

//0x000 URW ustatus User status register.
//    * Since we support the user-level interrupt, hence we need to support UIE
//0x300 MRW mstatus Machine status register.
wire sel_ustatus = (csr_idx == 12'h000);
wire sel_mstatus = (csr_idx == 12'h300);

wire rd_ustatus = sel_ustatus & csr_rd_en;
wire rd_mstatus = sel_mstatus & csr_rd_en;
wire wr_ustatus = sel_ustatus & csr_wr_en;
wire wr_mstatus = sel_mstatus & csr_wr_en;


/////////////////////////////////////////////////////////////////////
// Note: the below implementation only apply to Machine-mode config,
//       if other mode is also supported, these logics need to be updated

//////////////////////////
// Implement MPIE field
//
wire status_mpie_r;
    // The MPIE Feilds will be updates when: 
wire status_mpie_ena  = 
        // The CSR is written by CSR instructions
        (wr_mstatus & wbck_csr_wen) |
        // The MRET instruction commited
        cmt_mret_ena |
        // The Trap is taken
        cmt_status_ena;

wire status_mpie_nxt    = 
    //   See Priv SPEC:
    //       When a trap is taken from privilege mode y into privilege
    //       mode x, xPIE is set to the value of xIE;
    // So, When the Trap is taken, the MPIE is updated with the current MIE value
    cmt_status_ena ? status_mie_r :
    //   See Priv SPEC:
    //       When executing an xRET instruction, supposing xPP holds the value y, xIE
    //       is set to xPIE; the privilege mode is changed to y; 
    //       xPIE is set to 1;
    // So, When the MRET instruction commited, the MPIE is updated with 1
    cmt_mret_ena  ? 1'b1 :
    // When the CSR is written by CSR instructions
    (wr_mstatus & wbck_csr_wen) ? wbck_csr_dat[7] : // MPIE is in field 7 of mstatus
                  status_mpie_r; // Unchanged 

//sirv_gnrl_dfflr #(1) status_mpie_dfflr (status_mpie_ena, status_mpie_nxt, status_mpie_r, clk, rst_n);
reg_enrs #(1, 0, " status_mpie_dfflr ")  status_mpie_dfflr  ( clk, rst_n,status_mpie_ena, status_mpie_nxt, status_mpie_r);

//////////////////////////
// Implement MIE field
//
    // The MIE Feilds will be updates same as MPIE
wire status_mie_ena  = status_mpie_ena; 
wire status_mie_nxt    = 
    //   See Priv SPEC:
    //       When a trap is taken from privilege mode y into privilege
    //       mode x, xPIE is set to the value of xIE,
    //       xIE is set to 0;
    // So, When the Trap is taken, the MIE is updated with 0
     cmt_status_ena ? 1'b0 :
    //   See Priv SPEC:
    //       When executing an xRET instruction, supposing xPP holds the value y, xIE
    //       is set to xPIE; the privilege mode is changed to y, xPIE is set to 1;
    // So, When the MRET instruction commited, the MIE is updated with MPIE
    cmt_mret_ena ? status_mpie_r :
    // When the CSR is written by CSR instructions
    (wr_mstatus & wbck_csr_wen) ? wbck_csr_dat[3] : // MIE is in field 3 of mstatus
                  status_mie_r; // Unchanged 

//sirv_gnrl_dfflr #(1) status_mie_dfflr (status_mie_ena, status_mie_nxt, status_mie_r, clk, rst_n);
reg_enrs #(1, 0, " status_mie_dfflr ")  status_mie_dfflr  ( clk, rst_n,status_mie_ena, status_mie_nxt, status_mie_r);

//////////////////////////
// Implement SD field
//
//  See Priv SPEC:
//    The SD bit is read-only 
//    And is set when either the FS or XS bits encode a Dirty
//      state (i.e., SD=((FS==11) OR (XS==11))).
wire [1:0] status_fs_r;
wire [1:0] status_xs_r;
wire status_sd_r = (status_fs_r == 2'b11) | (status_xs_r == 2'b11);

assign status_xs_r = 2'b0;

//////////////////////////
// Implement XS field
//
//  See Priv SPEC:
//    XS field is read-only
//    The XS field represents a summary of all extensions' status
    // But in E200 we implement XS exactly same as FS to make it usable by software to 
    //   disable extended accelerators
    
`ifdef E203_HAS_NICE
   // If no NICE coprocessor interface configured, the XS is just hardwired to 0
    assign nice_xs_off = 1'b0;// We just make this signal to 0
`endif

//////////////////////////
// Implement FS field
//

`ifndef E203_HAS_FPU
   // If no FPU configured, the FS is just hardwired to 0
    assign status_fs_r = 2'b0; 
`endif

//////////////////////////
//r:???????????????????????????????????????
wire [1:0] status_sxl_r = 0;
wire [1:0] status_uxl_r = 0;

// Pack to the full mstatus register
//
wire [`MYRISCV_XLEN-1:0] status_r;
assign status_r[63]    = status_sd_r;                        //SD
assign status_r[62:36] = 0;
assign status_r[35:34] = status_sxl_r;
assign status_r[33:32] = status_uxl_r;
assign status_r[31:23] = 9'b0; // Reserved
assign status_r[22:17] = 6'b0;               // TSR--MPRV
assign status_r[16:15] = status_xs_r;                        // XS
assign status_r[14:13] = status_fs_r;                        // FS
assign status_r[12:11] = 2'b11;              // MPP 
assign status_r[10:9]  = 2'b0; // Reserved
assign status_r[8]     = 1'b0;               // SPP
assign status_r[7]     = status_mpie_r;                      // MPIE
assign status_r[6]     = 1'b0; // Reserved
assign status_r[5]     = 1'b0;               // SPIE 
assign status_r[4]     = 1'b0;               // UPIE 
assign status_r[3]     = status_mie_r;                       // MIE
assign status_r[2]     = 1'b0; // Reserved
assign status_r[1]     = 1'b0;               // SIE 
assign status_r[0]     = 1'b0;               // UIE 

wire [`MYRISCV_XLEN-1:0] csr_mstatus = status_r;

//0x004 URW uie User interrupt-enable register.
//    * Since we dont delegate interrupt to user mode, hence it is as all 0s
//0x304 MRW mie Machine interrupt-enable register.
wire sel_mie = (csr_idx == 12'h304);
wire rd_mie = sel_mie & csr_rd_en;
wire wr_mie = sel_mie & csr_wr_en;
wire mie_ena = wr_mie & wbck_csr_wen;
wire [`MYRISCV_XLEN-1:0] mie_r;
wire [`MYRISCV_XLEN-1:0] mie_nxt;
assign mie_nxt[63:12] = 52'b0;
assign mie_nxt[11] = wbck_csr_dat[11];//MEIE
assign mie_nxt[10:8] = 3'b0;
assign mie_nxt[ 7] = wbck_csr_dat[ 7];//MTIE
assign mie_nxt[6:4] = 3'b0;
assign mie_nxt[ 3] = wbck_csr_dat[ 3];//MSIE
assign mie_nxt[2:0] = 3'b0;
//sirv_gnrl_dfflr #(`MYRISCV_XLEN) mie_dfflr (mie_ena, mie_nxt, mie_r, clk, rst_n);
reg_enrs #(`MYRISCV_XLEN, 0, " mie_dfflr ")  mie_dfflr  ( clk, rst_n,mie_ena, mie_nxt, mie_r);
wire [`MYRISCV_XLEN-1:0] csr_mie = mie_r;

assign meie_r = csr_mie[11]; 
assign mtie_r = csr_mie[ 7];
assign msie_r = csr_mie[ 3];

//0x044 URW uip User interrupt pending.
//  We dont support delegation scheme, so no need to support the uip
//0x344 MRW mip Machine interrupt pending
wire sel_mip = (csr_idx == 12'h344);
wire rd_mip = sel_mip & csr_rd_en;
//wire wr_mip = sel_mip & csr_wr_en;
// The MxIP is read-only
wire meip_r;
wire msip_r;
wire mtip_r;
// sirv_gnrl_dffr #(1) meip_dffr (ext_irq_r, meip_r, clk, rst_n);
// sirv_gnrl_dffr #(1) msip_dffr (sft_irq_r, msip_r, clk, rst_n);
// sirv_gnrl_dffr #(1) mtip_dffr (tmr_irq_r, mtip_r, clk, rst_n);
reg_rs #(1, 0) meip_dffr (clk, rst_n, ext_irq_r, meip_r);
reg_rs #(1, 0) msip_dffr (clk, rst_n, sft_irq_r, msip_r);
reg_rs #(1, 0) mtip_dffr (clk, rst_n, tmr_irq_r, mtip_r);

wire [`MYRISCV_XLEN-1:0] ip_r;
assign ip_r[63:12] = 52'b0;
assign ip_r[11] = meip_r;
assign ip_r[10:8] = 3'b0;
assign ip_r[ 7] = mtip_r;
assign ip_r[6:4] = 3'b0;
assign ip_r[ 3] = msip_r;
assign ip_r[2:0] = 3'b0;
wire [`MYRISCV_XLEN-1:0] csr_mip = ip_r;
//

//0x005 URW utvec User trap handler base address.
//  We dont support user trap, so no utvec needed
//0x305 MRW mtvec Machine trap-handler base address.
wire sel_mtvec = (csr_idx == 12'h305);
wire rd_mtvec = csr_rd_en & sel_mtvec;
// `ifdef E203_SUPPORT_MTVEC //{
    wire wr_mtvec = sel_mtvec & csr_wr_en;
    wire mtvec_ena = (wr_mtvec & wbck_csr_wen);
    wire [`MYRISCV_XLEN-1:0] mtvec_r;
    wire [`MYRISCV_XLEN-1:0] mtvec_nxt = wbck_csr_dat;
    //sirv_gnrl_dfflr #(`MYRISCV_XLEN) mtvec_dfflr (mtvec_ena, mtvec_nxt, mtvec_r, clk, rst_n);
    reg_enrs #(`MYRISCV_XLEN, 0, " mtvec_dfflr ")  mtvec_dfflr  ( clk, rst_n,mtvec_ena, mtvec_nxt, mtvec_r);
    wire [`MYRISCV_XLEN-1:0] csr_mtvec = mtvec_r;
// `else//}{
//     // THe vector table base is a configurable parameter, so we dont support writeable to it
//     wire [`MYRISCV_XLEN-1:0] csr_mtvec = `RISCV_TRAP_BASE;
// `endif//}
assign csr_mtvec_r = csr_mtvec;

//0x340 MRW mscratch 
wire sel_mscratch = (csr_idx == 12'h340);
wire rd_mscratch = sel_mscratch & csr_rd_en;
`ifdef E203_SUPPORT_MSCRATCH //{
wire wr_mscratch = sel_mscratch & csr_wr_en;
wire mscratch_ena = (wr_mscratch & wbck_csr_wen);
wire [`MYRISCV_XLEN-1:0] mscratch_r;
wire [`MYRISCV_XLEN-1:0] mscratch_nxt = wbck_csr_dat;
//sirv_gnrl_dfflr #(`MYRISCV_XLEN) mscratch_dfflr (mscratch_ena, mscratch_nxt, mscratch_r, clk, rst_n);
reg_enrs #(`MYRISCV_XLEN, 0, " mscratch_dfflr ")  mscratch_dfflr  ( clk, rst_n,mscratch_ena, mscratch_nxt, mscratch_r);
wire [`MYRISCV_XLEN-1:0] csr_mscratch = mscratch_r;
`else//}{
wire [`MYRISCV_XLEN-1:0] csr_mscratch = `MYRISCV_XLEN'b0;
`endif//}

// 0xB00 MRW mcycle 
// 0xB02 MRW minstret 
// 0xB80 MRW mcycleh
// 0xB82 MRW minstreth 
wire sel_mcycle    = (csr_idx == 12'hB00);
wire sel_mcycleh   = (csr_idx == 12'hB80);
wire sel_minstret  = (csr_idx == 12'hB02);
wire sel_minstreth = (csr_idx == 12'hB82);

// 0xBFF MRW counterstop 
      // This register is our self-defined register to stop
      // the cycle/time/instret counters to save dynamic powers
wire sel_counterstop = (csr_idx == 12'hBFF);// This address is not used by ISA
// 0xBFE MRW mcgstop 
      // This register is our self-defined register to disable the 
      // automaticall clock gating for CPU logics for debugging purpose
wire sel_mcgstop = (csr_idx == 12'hBFE);// This address is not used by ISA
// 0xBFD MRW itcmnohold 
      // This register is our self-defined register to disble the 
      // ITCM SRAM output holdup feature, if set, then we assume
      // ITCM SRAM output cannot holdup last read value
wire sel_itcmnohold = (csr_idx == 12'hBFD);// This address is not used by ISA
// 0xBF0 MRW mdvnob2b 
      // This register is our self-defined register to disble the 
      // Mul/div back2back feature
wire sel_mdvnob2b = (csr_idx == 12'hBF0);// This address is not used by ISA


wire rd_mcycle     = csr_rd_en & sel_mcycle   ;
wire rd_mcycleh    = csr_rd_en & sel_mcycleh  ;
wire rd_minstret   = csr_rd_en & sel_minstret ;
wire rd_minstreth  = csr_rd_en & sel_minstreth;

wire rd_itcmnohold   = csr_rd_en & sel_itcmnohold;
wire rd_mdvnob2b   = csr_rd_en & sel_mdvnob2b;
wire rd_counterstop  = csr_rd_en & sel_counterstop;
wire rd_mcgstop       = csr_rd_en & sel_mcgstop;

`ifdef E203_SUPPORT_MCYCLE_MINSTRET //{
wire wr_mcycle     = csr_wr_en & sel_mcycle   ;
wire wr_mcycleh    = csr_wr_en & sel_mcycleh  ;
wire wr_minstret   = csr_wr_en & sel_minstret ;
wire wr_minstreth  = csr_wr_en & sel_minstreth;

wire wr_itcmnohold   = csr_wr_en & sel_itcmnohold ;
wire wr_mdvnob2b   = csr_wr_en & sel_mdvnob2b ;
wire wr_counterstop  = csr_wr_en & sel_counterstop;
wire wr_mcgstop       = csr_wr_en & sel_mcgstop     ;

wire mcycle_wr_ena    = (wr_mcycle    & wbck_csr_wen);
wire mcycleh_wr_ena   = (wr_mcycleh   & wbck_csr_wen);
wire minstret_wr_ena  = (wr_minstret  & wbck_csr_wen);
wire minstreth_wr_ena = (wr_minstreth & wbck_csr_wen);

wire itcmnohold_wr_ena  = (wr_itcmnohold  & wbck_csr_wen);
wire mdvnob2b_wr_ena  = (wr_mdvnob2b  & wbck_csr_wen);
wire counterstop_wr_ena = (wr_counterstop & wbck_csr_wen);
wire mcgstop_wr_ena      = (wr_mcgstop      & wbck_csr_wen);

wire [`MYRISCV_XLEN-1:0] mcycle_r   ;
wire [`MYRISCV_XLEN-1:0] mcycleh_r  ;
wire [`MYRISCV_XLEN-1:0] minstret_r ;
wire [`MYRISCV_XLEN-1:0] minstreth_r;

wire cy_stop;
wire ir_stop;

wire stop_cycle_in_dbg = dbg_stopcycle & dbg_mode;
wire mcycle_ena    = mcycle_wr_ena    | 
                     ((~cy_stop) & (~stop_cycle_in_dbg) & (1'b1));
wire mcycleh_ena   = mcycleh_wr_ena   | 
                     ((~cy_stop) & (~stop_cycle_in_dbg) & ((mcycle_r == (~(`MYRISCV_XLEN'b0)))));
wire minstret_ena  = minstret_wr_ena  |
                     ((~ir_stop) & (~stop_cycle_in_dbg) & (cmt_instret_ena));
wire minstreth_ena = minstreth_wr_ena |
                     ((~ir_stop) & (~stop_cycle_in_dbg) & ((cmt_instret_ena & (minstret_r == (~(`MYRISCV_XLEN'b0))))));

wire [`MYRISCV_XLEN-1:0] mcycle_nxt    = mcycle_wr_ena    ? wbck_csr_dat : (mcycle_r    + 1'b1);
wire [`MYRISCV_XLEN-1:0] mcycleh_nxt   = mcycleh_wr_ena   ? wbck_csr_dat : (mcycleh_r   + 1'b1);
wire [`MYRISCV_XLEN-1:0] minstret_nxt  = minstret_wr_ena  ? wbck_csr_dat : (minstret_r  + 1'b1);
wire [`MYRISCV_XLEN-1:0] minstreth_nxt = minstreth_wr_ena ? wbck_csr_dat : (minstreth_r + 1'b1);

//We need to use the always-on clock for this counter
//sirv_gnrl_dfflr #(`MYRISCV_XLEN) mcycle_dfflr (mcycle_ena, mcycle_nxt, mcycle_r   , clk_aon, rst_n);
reg_enrs #(`MYRISCV_XLEN, 0, " mcycle_dfflr ")  mcycle_dfflr  ( clk_aon, rst_n,mcycle_ena, mcycle_nxt, mcycle_r   );
//sirv_gnrl_dfflr #(`MYRISCV_XLEN) mcycleh_dfflr (mcycleh_ena, mcycleh_nxt, mcycleh_r  , clk_aon, rst_n);
reg_enrs #(`MYRISCV_XLEN, 0, " mcycleh_dfflr ")  mcycleh_dfflr  ( clk_aon, rst_n,mcycleh_ena, mcycleh_nxt, mcycleh_r  );
//sirv_gnrl_dfflr #(`MYRISCV_XLEN) minstret_dfflr (minstret_ena, minstret_nxt, minstret_r , clk, rst_n);
reg_enrs #(`MYRISCV_XLEN, 0, " minstret_dfflr ")  minstret_dfflr  ( clk, rst_n,minstret_ena, minstret_nxt, minstret_r );
//sirv_gnrl_dfflr #(`MYRISCV_XLEN) minstreth_dfflr (minstreth_ena, minstreth_nxt, minstreth_r, clk, rst_n);
reg_enrs #(`MYRISCV_XLEN, 0, " minstreth_dfflr ")  minstreth_dfflr  ( clk, rst_n,minstreth_ena, minstreth_nxt, minstreth_r);

wire [`MYRISCV_XLEN-1:0] counterstop_r;
wire counterstop_ena = counterstop_wr_ena;
wire [`MYRISCV_XLEN-1:0] counterstop_nxt = {{(`MYRISCV_XLEN-3){1'b0}},wbck_csr_dat[2:0]};// Only LSB 3bits are useful
//sirv_gnrl_dfflr #(`MYRISCV_XLEN) counterstop_dfflr (counterstop_ena, counterstop_nxt, counterstop_r, clk, rst_n);
reg_enrs #(`MYRISCV_XLEN, 0, " counterstop_dfflr ")  counterstop_dfflr  ( clk, rst_n,counterstop_ena, counterstop_nxt, counterstop_r);

wire [`MYRISCV_XLEN-1:0] csr_mcycle    = mcycle_r;
wire [`MYRISCV_XLEN-1:0] csr_mcycleh   = mcycleh_r;
wire [`MYRISCV_XLEN-1:0] csr_minstret  = minstret_r;
wire [`MYRISCV_XLEN-1:0] csr_minstreth = minstreth_r;
wire [`MYRISCV_XLEN-1:0] csr_counterstop = counterstop_r;
`else//}{
wire [`MYRISCV_XLEN-1:0] csr_mcycle    = `MYRISCV_XLEN'b0;
wire [`MYRISCV_XLEN-1:0] csr_mcycleh   = `MYRISCV_XLEN'b0;
wire [`MYRISCV_XLEN-1:0] csr_minstret  = `MYRISCV_XLEN'b0;
wire [`MYRISCV_XLEN-1:0] csr_minstreth = `MYRISCV_XLEN'b0;
wire [`MYRISCV_XLEN-1:0] csr_counterstop = `MYRISCV_XLEN'b0;
`endif//}

wire [`MYRISCV_XLEN-1:0] itcmnohold_r;
wire itcmnohold_ena = itcmnohold_wr_ena;
wire [`MYRISCV_XLEN-1:0] itcmnohold_nxt = {{(`MYRISCV_XLEN-1){1'b0}},wbck_csr_dat[0]};// Only LSB 1bits are useful
//sirv_gnrl_dfflr #(`MYRISCV_XLEN) itcmnohold_dfflr (itcmnohold_ena, itcmnohold_nxt, itcmnohold_r, clk, rst_n);
reg_enrs #(`MYRISCV_XLEN, 0, " itcmnohold_dfflr ")  itcmnohold_dfflr  ( clk, rst_n,itcmnohold_ena, itcmnohold_nxt, itcmnohold_r);

wire [`MYRISCV_XLEN-1:0] csr_itcmnohold  = itcmnohold_r;

wire [`MYRISCV_XLEN-1:0] mdvnob2b_r;
wire mdvnob2b_ena = mdvnob2b_wr_ena;
wire [`MYRISCV_XLEN-1:0] mdvnob2b_nxt = {{(`MYRISCV_XLEN-1){1'b0}},wbck_csr_dat[0]};// Only LSB 1bits are useful
//sirv_gnrl_dfflr #(`MYRISCV_XLEN) mdvnob2b_dfflr (mdvnob2b_ena, mdvnob2b_nxt, mdvnob2b_r, clk, rst_n);
reg_enrs #(`MYRISCV_XLEN, 0, " mdvnob2b_dfflr ")  mdvnob2b_dfflr  ( clk, rst_n,mdvnob2b_ena, mdvnob2b_nxt, mdvnob2b_r);

wire [`MYRISCV_XLEN-1:0] csr_mdvnob2b  = mdvnob2b_r;

assign cy_stop = counterstop_r[0];// Stop CYCLE   counter
assign tm_stop = counterstop_r[1];// Stop TIME    counter
assign ir_stop = counterstop_r[2];// Stop INSTRET counter

assign itcm_nohold = itcmnohold_r[0];// ITCM no-hold up feature
assign mdv_nob2b = mdvnob2b_r[0];// Mul/Div no back2back feature



wire [`MYRISCV_XLEN-1:0] mcgstop_r;
wire mcgstop_ena = mcgstop_wr_ena;
wire [`MYRISCV_XLEN-1:0] mcgstop_nxt = {{(`MYRISCV_XLEN-2){1'b0}},wbck_csr_dat[1:0]};// Only LSB 2bits are useful
//sirv_gnrl_dfflr #(`MYRISCV_XLEN) mcgstop_dfflr (mcgstop_ena, mcgstop_nxt, mcgstop_r, clk, rst_n);
reg_enrs #(`MYRISCV_XLEN, 0, " mcgstop_dfflr ")  mcgstop_dfflr  ( clk, rst_n,mcgstop_ena, mcgstop_nxt, mcgstop_r);
wire [`MYRISCV_XLEN-1:0] csr_mcgstop = mcgstop_r;
assign core_cgstop = mcgstop_r[0];// Stop Core clock gating
assign tcm_cgstop = mcgstop_r[1];// Stop TCM  clock gating


//`ifdef E203_SUPPORT_CYCLE //{
////0xC00 URO cycle 
////0xC80 URO cycleh
//wire sel_cycle  = (csr_idx == 12'hc00);
//wire sel_cycleh = (csr_idx == 12'hc80);
//wire rd_cycle = sel_cycle & csr_rd_en;
//wire wr_cycle = sel_cycle & csr_wr_en;
//wire cycle_ena = (wr_cycle & wbck_csr_wen);
//wire rd_cycleh = sel_cycleh & csr_rd_en;
//wire wr_cycleh = sel_cycleh & csr_wr_en;
//wire cycleh_ena = (wr_cycleh & wbck_csr_wen);
//wire [`MYRISCV_XLEN-1:0] cycle_r;
//wire [`MYRISCV_XLEN-1:0] cycleh_r;
//wire [`MYRISCV_XLEN-1:0] cycle_nxt = wbck_csr_dat;
//wire [`MYRISCV_XLEN-1:0] cycleh_nxt = wbck_csr_dat;
//sirv_gnrl_dfflr #(`MYRISCV_XLEN) cycle_dfflr (cycle_ena, cycle_nxt, cycle_r, clk, rst_n);
// reg_enrs #(`MYRISCV_XLEN, 0, " cycle_dfflr ")  cycle_dfflr  ( clk, rst_n,cycle_ena, cycle_nxt, cycle_r);
//sirv_gnrl_dfflr #(`MYRISCV_XLEN) cycleh_dfflr(cycleh_ena,cycleh_nxt,cycleh_r,clk, rst_n);
// reg_enrs #(`MYRISCV_XLEN, 0, " cycleh_dfflr")  cycleh_dfflr (clk, rst_n,cycleh_ena,cycleh_nxt,cycleh_r);
//wire [`MYRISCV_XLEN-1:0] csr_cycle  = cycle_r;
//wire [`MYRISCV_XLEN-1:0] csr_cycleh = cycleh_r;
//`else//}{
//wire [`MYRISCV_XLEN-1:0] csr_cycle = `MYRISCV_XLEN'b0;
//wire [`MYRISCV_XLEN-1:0] csr_cycleh = `MYRISCV_XLEN'b0;
//`endif//}

//
//0x041 URW uepc User exception program counter.
//  We dont support user trap, so no uepc needed
//0x341 MRW mepc Machine exception program counter.
wire sel_mepc = (csr_idx == 12'h341);
wire rd_mepc = sel_mepc & csr_rd_en;
wire wr_mepc = sel_mepc & csr_wr_en;
wire epc_ena = (wr_mepc & wbck_csr_wen) | cmt_epc_ena;
wire [`MYRISCV_ADDRDW-1:0] epc_r;
wire [`MYRISCV_ADDRDW-1:0] epc_nxt;
assign epc_nxt[`MYRISCV_ADDRDW-1:1] = cmt_epc_ena ? cmt_epc[`MYRISCV_ADDRDW-1:1] : wbck_csr_dat[`MYRISCV_ADDRDW-1:1];
assign epc_nxt[0] = 1'b0;// Must not hold PC which will generate the misalign exception according to ISA
//sirv_gnrl_dfflr #(`MYRISCV_ADDRDW) epc_dfflr (epc_ena, epc_nxt, epc_r, clk, rst_n);
reg_enrs #(`MYRISCV_ADDRDW, 0, " epc_dfflr ")  epc_dfflr  ( clk, rst_n,epc_ena, epc_nxt, epc_r);
wire [`MYRISCV_XLEN-1:0] csr_mepc;
wire dummy_0;
assign {dummy_0,csr_mepc} = {{`MYRISCV_XLEN+1-`MYRISCV_ADDRDW{1'b0}},epc_r};
assign csr_epc_r = csr_mepc;

//0x042 URW ucause User trap cause.
//  We dont support user trap, so no ucause needed
//0x342 MRW mcause Machine trap cause.
wire sel_mcause = (csr_idx == 12'h342);
wire rd_mcause = sel_mcause & csr_rd_en;
wire wr_mcause = sel_mcause & csr_wr_en;
wire cause_ena = (wr_mcause & wbck_csr_wen) | cmt_cause_ena;
wire [`MYRISCV_XLEN-1:0] cause_r;
wire [`MYRISCV_XLEN-1:0] cause_nxt;
assign cause_nxt[63]  = cmt_cause_ena ? cmt_cause[63] : wbck_csr_dat[63];
assign cause_nxt[62:4] = 59'b0;
assign cause_nxt[3:0] = cmt_cause_ena ? cmt_cause[3:0] : wbck_csr_dat[3:0];
//sirv_gnrl_dfflr #(`MYRISCV_XLEN) cause_dfflr (cause_ena, cause_nxt, cause_r, clk, rst_n);
reg_enrs #(`MYRISCV_XLEN, 0, " cause_dfflr ")  cause_dfflr  ( clk, rst_n,cause_ena, cause_nxt, cause_r);
wire [`MYRISCV_XLEN-1:0] csr_mcause = cause_r;


//0x043 URW ubadaddr User bad address.
//  We dont support user trap, so no ubadaddr needed
//0x343 MRW mbadaddr Machine bad address.
wire sel_mbadaddr = (csr_idx == 12'h343);
wire rd_mbadaddr = sel_mbadaddr & csr_rd_en;
wire wr_mbadaddr = sel_mbadaddr & csr_wr_en;
wire cmt_trap_badaddr_ena = cmt_badaddr_ena;
wire badaddr_ena = (wr_mbadaddr & wbck_csr_wen) | cmt_trap_badaddr_ena;
wire [`MYRISCV_ADDRDW-1:0] badaddr_r;
wire [`MYRISCV_ADDRDW-1:0] badaddr_nxt;
assign badaddr_nxt = cmt_trap_badaddr_ena ? cmt_badaddr : wbck_csr_dat[`MYRISCV_ADDRDW-1:0];
//sirv_gnrl_dfflr #(`MYRISCV_ADDRDW) badaddr_dfflr (badaddr_ena, badaddr_nxt, badaddr_r, clk, rst_n);
reg_enrs #(`MYRISCV_ADDRDW, 0, " badaddr_dfflr ")  badaddr_dfflr  ( clk, rst_n,badaddr_ena, badaddr_nxt, badaddr_r);
wire [`MYRISCV_XLEN-1:0] csr_mbadaddr;
wire dummy_1;
assign {dummy_1,csr_mbadaddr} = {{`MYRISCV_XLEN+1-`MYRISCV_ADDRDW{1'b0}},badaddr_r};

// We dont support the delegation scheme, so no need to implement
//   delegete registers


//0x301 MRW misa ISA and extensions
wire sel_misa = (csr_idx == 12'h301);
wire rd_misa = sel_misa & csr_rd_en;
// Only implemented the M mode, IMC or EMC
wire [`MYRISCV_XLEN-1:0] csr_misa = {
`ifdef MYRISCV_ARCH_64
    {32'd0}
   ,
`endif
   2'b1
   ,4'b0 //WIRI
   ,1'b0 //              25 Z Reserved
   ,1'b0 //              24 Y Reserved
   ,1'b0 //              23 X Non-standard extensions present
   ,1'b0 //              22 W Reserved
   ,1'b0 //              21 V Tentatively reserved for Vector extension 20 U User mode implemented
   ,1'b0 //              20 U User mode implemented
   ,1'b0 //              19 T Tentatively reserved for Transactional Memory extension
   ,1'b0 //              18 S Supervisor mode implemented
   ,1'b0 //              17 R Reserved
   ,1'b0 //              16 Q Quad-precision floating-point extension
   ,1'b0 //              15 P Tentatively reserved for Packed-SIMD extension
   ,1'b0 //              14 O Reserved
   ,1'b0 //              13 N User-level interrupts supported
   ,1'b1 // 12 M Integer Multiply/Divide extension
   ,1'b0 //              11 L Tentatively reserved for Decimal Floating-Point extension
   ,1'b0 //              10 K Reserved
   ,1'b0 //              9 J Reserved
   `ifdef E203_RFREG_NUM_IS_32
   ,1'b1 // 8 I RV32I/64I/128I base ISA
   `else
   ,1'b0
   `endif
   ,1'b0 //              7 H Hypervisor mode implemented
   ,1'b0 //              6 G Additional standard extensions present
  `ifndef E203_HAS_FPU//{
   ,1'b0 //              5 F Single-precision floating-point extension
  `endif//
   `ifdef E203_RFREG_NUM_IS_32
   ,1'b0 //              4 E RV32E base ISA
   `else
   ,1'b1 //              
   `endif
  `ifndef E203_HAS_FPU//{
   ,1'b0 //              3 D Double-precision floating-point extension
  `endif//
   ,1'b1 // 2 C Compressed extension
   ,1'b0 //              1 B Tentatively reserved for Bit operations extension
  `ifdef E203_SUPPORT_AMO//{
   ,1'b1 //              0 A Atomic extension
  `endif//E203_SUPPORT_AMO}
  `ifndef E203_SUPPORT_AMO//{
   ,1'b0 //              0 A Atomic extension
  `endif//}
                           };

//Machine Information Registers
//0xF11 MRO mvendorid Vendor ID.
//0xF12 MRO marchid Architecture ID.
//0xF13 MRO mimpid Implementation ID.
//0xF14 MRO mhartid Hardware thread ID.
wire [`MYRISCV_XLEN-1:0] csr_mvendorid = `MYRISCV_XLEN'h536;
wire [`MYRISCV_XLEN-1:0] csr_marchid   = `MYRISCV_XLEN'hE203;
wire [`MYRISCV_XLEN-1:0] csr_mimpid    = `MYRISCV_XLEN'h1;
wire [`MYRISCV_XLEN-1:0] csr_mhartid   = {{`MYRISCV_XLEN-`E203_HART_ID_W{1'b0}},core_mhartid};
wire rd_mvendorid = csr_rd_en & (csr_idx == 12'hF11);
wire rd_marchid   = csr_rd_en & (csr_idx == 12'hF12);
wire rd_mimpid    = csr_rd_en & (csr_idx == 12'hF13);
wire rd_mhartid   = csr_rd_en & (csr_idx == 12'hF14);

//0x7b0 Debug Control and Status
//0x7b1 Debug PC
//0x7b2 Debug Scratch Register
//0x7a0 Trigger selection register
wire sel_dcsr     = (csr_idx == 12'h7b0);
wire sel_dpc      = (csr_idx == 12'h7b1);
wire sel_dscratch = (csr_idx == 12'h7b2);

wire rd_dcsr     = dbg_mode & csr_rd_en & sel_dcsr    ;
wire rd_dpc      = dbg_mode & csr_rd_en & sel_dpc     ;
wire rd_dscratch = dbg_mode & csr_rd_en & sel_dscratch;


assign wr_dcsr_ena     = dbg_mode & csr_wr_en & sel_dcsr    ;
assign wr_dpc_ena      = dbg_mode & csr_wr_en & sel_dpc     ;
assign wr_dscratch_ena = dbg_mode & csr_wr_en & sel_dscratch;


assign wr_csr_nxt     = wbck_csr_dat;


wire [`MYRISCV_XLEN-1:0] csr_dcsr     = dcsr_r    ;
`ifdef E203_PC_SIZE_IS_16
wire [`MYRISCV_XLEN-1:0] csr_dpc      = {{`MYRISCV_XLEN-`MYRISCV_ADDRDW{1'b0}},dpc_r};
`endif
`ifdef E203_PC_SIZE_IS_24
wire [`MYRISCV_XLEN-1:0] csr_dpc      = {{`MYRISCV_XLEN-`MYRISCV_ADDRDW{1'b0}},dpc_r};
`endif
`ifdef E203_PC_SIZE_IS_32
wire [`MYRISCV_XLEN-1:0] csr_dpc      = dpc_r     ;
`endif
wire [`MYRISCV_XLEN-1:0] csr_dscratch = dscratch_r;

assign csr_dpc_r = dpc_r;

/////////////////////////////////////////////////////////////////////
//  Generate the Read path
  //Currently we only support the M mode to simplify the implementation and 
  //      reduce the gatecount because we are a privite core
assign u_mode = 1'b0;
assign s_mode = 1'b0;
assign h_mode = 1'b0;
assign m_mode = 1'b1;
assign read_csr_dat = `MYRISCV_XLEN'b0 
               //| ({`MYRISCV_XLEN{rd_ustatus  }} & csr_ustatus  )
               | ({`MYRISCV_XLEN{rd_mstatus  }} & csr_mstatus  )
               | ({`MYRISCV_XLEN{rd_mie      }} & csr_mie      )
               | ({`MYRISCV_XLEN{rd_mtvec    }} & csr_mtvec    )
               | ({`MYRISCV_XLEN{rd_mepc     }} & csr_mepc     )
               | ({`MYRISCV_XLEN{rd_mscratch }} & csr_mscratch ) //r: 根据规定，他的作用就是用来缓存数据，可以用来存任何东西，没有专门作用。
               | ({`MYRISCV_XLEN{rd_mcause   }} & csr_mcause   )
               | ({`MYRISCV_XLEN{rd_mbadaddr }} & csr_mbadaddr )
               | ({`MYRISCV_XLEN{rd_mip      }} & csr_mip      )
               | ({`MYRISCV_XLEN{rd_misa     }} & csr_misa     ) //r: read only, 记录了实现了哪些指令，支不支持浮点数等信息
               | ({`MYRISCV_XLEN{rd_mvendorid}} & csr_mvendorid) //r: read only, 供应商编号
               | ({`MYRISCV_XLEN{rd_marchid  }} & csr_marchid  ) //r: read only, 机器模式架构编号
               | ({`MYRISCV_XLEN{rd_mimpid   }} & csr_mimpid   ) //r: read only, 机器模式硬件实现编号
               | ({`MYRISCV_XLEN{rd_mhartid  }} & csr_mhartid  ) //r: mhartid应该是每个core都有一个，记录这个core的编号.
                                                                 //r: 操作系统有时通过csr指令，来读取这个寄存器，确定当前线程是运行在哪个core上！！！
               | ({`MYRISCV_XLEN{rd_mcycle   }} & csr_mcycle   ) //r:周期计数器
               | ({`MYRISCV_XLEN{rd_mcycleh  }} & csr_mcycleh  )
               | ({`MYRISCV_XLEN{rd_minstret }} & csr_minstret ) //r:指令计数器
               | ({`MYRISCV_XLEN{rd_minstreth}} & csr_minstreth)
               //r: 有三个使能位，用于停止周期计数、指令计数、时间计数。
               | ({`MYRISCV_XLEN{rd_counterstop}}   & csr_counterstop)  // Self-defined 
               //r: 只有低两位有用，分别用来停止内核core与停止tcm，tcm就是itcm与dtcm，两个都是sram。这个应该与低功耗有关。
               | ({`MYRISCV_XLEN{rd_mcgstop}}       & csr_mcgstop)      // Self-defined 
               //r: 与itcm设置有关，只有[0]有用，用于关闭itcm的某种设置（默认就是关闭），与hold（保持？）有关？
               | ({`MYRISCV_XLEN{rd_itcmnohold}}    & csr_itcmnohold)   // Self-defined
               //r: 与muldiv处理模块有关，只用[0]有用。
               //r: b2b好像是指：乘法结果为64位，需要两条指令，分别得到高32与低32位，实际可以只做一次运算，b2b模式就是保留上次运算结果(64位)。
               //r: 除法也类似，一次可以得到32位商与32位余数，也需要两条指令。 
               | ({`MYRISCV_XLEN{rd_mdvnob2b}}      & csr_mdvnob2b)     // Self-defined 
               | ({`MYRISCV_XLEN{rd_dcsr     }} & csr_dcsr    ) //r:for debug
               | ({`MYRISCV_XLEN{rd_dpc      }} & csr_dpc     ) //r:for debug
               | ({`MYRISCV_XLEN{rd_dscratch }} & csr_dscratch) //r:for debug
               ;


endmodule

