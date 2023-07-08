`include "mydefines.v"
`include "e203_defines.v"

module exu(
        clk,
        rst,

    //dec to exu
        exu_vld_i,
        exu_rdy_i,
        exu_rs1_idx_i,
        exu_rs2_idx_i,
        exu_rs1_i,
        exu_rs2_i,
        `ifdef PLATFORM_SIM
            exu_instr_i,
        `endif
        exu_pc_i,
        exu_imm_i,
        exu_rdwen_i,
        exu_rdidx_i,
        exu_info_i,

        soft_trap_i,
        ext_trap_i,
        time_trap_i,
        jtag_halt_i,
        jtag_rst_i,

        halt_req_o,
        flush_req_o,
        flush_addr_o,

        flush_req_no_delay_o,

        nice2lsu_vld,
        nice2lsu_rdy,
        nice2lsu_read,   // 指令地址
        nice2lsu_addr,       // 通用寄存器1输入数据
        nice2lsu_wdata,       // 通用寄存器2输入数据
        nice2lsu_wmask,
        nice2lsu_size,
        nice2lsu_unsign,
        nice2lsu_rdidx,
        nice2lsu_ret,//将结果写回nice而不是reg中.

        lsu2nice_vld,                   // 
        lsu2nice_rdy,
        lsu2nice_wdata,       // 
        lsu2nice_rdidx,   // 这个返回地址不知道有没有用，先留着。

        lsu2sram_cmd_vld,
        lsu2sram_cmd_rdy,
        lsu2sram_cmd_read,
        lsu2sram_cmd_addr,
        lsu2sram_cmd_wdata,
        lsu2sram_cmd_wmask,

        lsu2sram_rsp_vld,
        lsu2sram_rsp_rdy,
        lsu2sram_rsp_rdata,
        lsu2sram_rsp_err,

        lsu2dtcm_cmd_vld,
        lsu2dtcm_cmd_rdy,
        lsu2dtcm_cmd_read,
        lsu2dtcm_cmd_addr,
        lsu2dtcm_cmd_wdata,
        lsu2dtcm_cmd_wmask,

        lsu2dtcm_rsp_vld,
        lsu2dtcm_rsp_rdy,
        lsu2dtcm_rsp_rdata,
        lsu2dtcm_rsp_err,

        lsu2biu_cmd_vld,
        lsu2biu_cmd_rdy,
        lsu2biu_cmd_read,
        lsu2biu_cmd_addr,
        lsu2biu_cmd_wdata,
        lsu2biu_cmd_wmask,

        lsu2biu_rsp_vld,
        lsu2biu_rsp_rdy,
        lsu2biu_rsp_rdata,
        lsu2biu_rsp_err,

        reg_wen,
        reg_waddr,
        reg_wdata,

        oitf_clr_req_o,
        oitf_clr_idx_o,

        timer_en
    );

    input clk, rst;

    input wire exu_vld_i;
    output wire exu_rdy_i;
    input wire [`MYRISCV_REGADDRBUS] exu_rs1_idx_i;
    input wire [`MYRISCV_REGADDRBUS] exu_rs2_idx_i;
    input wire [`MYRISCV_REGBUS] exu_rs1_i;
    input wire [`MYRISCV_REGBUS] exu_rs2_i;
    `ifdef PLATFORM_SIM
        input wire [`MYRISCV_INSTBUS] exu_instr_i;
    `endif
    input wire [`MYRISCV_ADDRBUS] exu_pc_i;
    input wire [`MYRISCV_XLEN-1 : 0] exu_imm_i;
    input wire exu_rdwen_i;
    input wire [`MYRISCV_REGADDRBUS] exu_rdidx_i;
    input wire [`MY_DECINFO_WIDTH-1 : 0] exu_info_i;

    input wire soft_trap_i;
    input wire ext_trap_i;
    input wire time_trap_i;
    input wire jtag_halt_i;
    input wire jtag_rst_i;

    output wire halt_req_o;
    output wire flush_req_o;
    output wire [`MYRISCV_ADDRBUS] flush_addr_o;

    output wire flush_req_no_delay_o;

    input wire nice2lsu_vld;
    output wire nice2lsu_rdy;
    input wire nice2lsu_read;   // 指令地址
    input wire [`MYRISCV_ADDRBUS] nice2lsu_addr;       // 通用寄存器1输入数据
    input wire [`MYRISCV_REGBUS] nice2lsu_wdata;       // 通用寄存器2输入数据
    input wire  [(`MYRISCV_DATADW/8-1):0] nice2lsu_wmask;
    input wire [1:0] nice2lsu_size;
    input wire nice2lsu_unsign;
    input wire [`MYRISCV_REGADDRBUS] nice2lsu_rdidx;
    input wire nice2lsu_ret;//将结果写回nice而不是reg中.

    output wire lsu2nice_vld;                   // 
    input wire lsu2nice_rdy;
    output wire [`MYRISCV_REGBUS] lsu2nice_wdata;       // 
    output wire [`MYRISCV_REGADDRBUS] lsu2nice_rdidx;   // 这个返回地址不知道有没有用，先留着。
    
    output wire lsu2sram_cmd_vld;
    input wire lsu2sram_cmd_rdy;
    output wire lsu2sram_cmd_read;
    output wire [`MYRISCV_ADDRBUS] lsu2sram_cmd_addr;
    output wire [`MYRISCV_REGBUS] lsu2sram_cmd_wdata;
    output wire [(`MYRISCV_DATADW/8-1):0] lsu2sram_cmd_wmask;

    input wire lsu2sram_rsp_vld;
    output wire lsu2sram_rsp_rdy;
    input wire [`MYRISCV_REGBUS] lsu2sram_rsp_rdata;
    input wire lsu2sram_rsp_err;

    output wire lsu2dtcm_cmd_vld;
    input wire lsu2dtcm_cmd_rdy;
    output wire lsu2dtcm_cmd_read;
    output wire [`MYRISCV_ADDRBUS] lsu2dtcm_cmd_addr;
    output wire [`MYRISCV_REGBUS] lsu2dtcm_cmd_wdata;
    output wire [(`MYRISCV_DATADW/8-1):0] lsu2dtcm_cmd_wmask;

    input wire lsu2dtcm_rsp_vld;
    output wire lsu2dtcm_rsp_rdy;
    input wire [`MYRISCV_REGBUS] lsu2dtcm_rsp_rdata;
    input wire lsu2dtcm_rsp_err;

    output wire lsu2biu_cmd_vld;
    input wire lsu2biu_cmd_rdy;
    output wire lsu2biu_cmd_read;
    output wire [`MYRISCV_ADDRBUS] lsu2biu_cmd_addr;
    output wire [`MYRISCV_REGBUS] lsu2biu_cmd_wdata;
    output wire [(`MYRISCV_DATADW/8-1):0] lsu2biu_cmd_wmask; 

    input wire lsu2biu_rsp_vld;
    output wire lsu2biu_rsp_rdy;
    input wire [`MYRISCV_REGBUS] lsu2biu_rsp_rdata;
    input wire lsu2biu_rsp_err;

    output wire reg_wen;
    output wire [`MYRISCV_REGADDRBUS] reg_waddr;
    output wire [`MYRISCV_REGBUS] reg_wdata;

    output wire oitf_clr_req_o;
    output wire [`MYRISCV_REGADDRBUS] oitf_clr_idx_o;

    output timer_en;
    
    //o:*****************************inside modules********************************************
    wire disp2alu_vld;
    wire disp2alu_rdy;

    wire disp2lsu_vld;
    wire disp2lsu_rdy;

    wire disp2muldiv_vld;
    wire disp2muldiv_rdy;

    `ifdef MYRISCV_HAS_NICE
    wire disp2nice_vld;
    wire disp2nice_rdy;
    `endif

    disp exu_disp_inst(
        .dec2ex_vld         (exu_vld_i),
        .dec2ex_rdy         (exu_rdy_i),

        .op_select          (exu_info_i[`MY_DECINFO_GRP]),

        .disp2alu_vld       (disp2alu_vld),
        .disp2alu_rdy       (disp2alu_rdy),

        .disp2lsu_vld       (disp2lsu_vld),
        .disp2lsu_rdy       (disp2lsu_rdy),

        .disp2muldiv_vld    (disp2muldiv_vld),
        .disp2muldiv_rdy    (disp2muldiv_rdy),

        `ifdef MYRISCV_HAS_NICE
        .disp2nice_vld      (disp2nice_vld),
        .disp2nice_rdy      (disp2nice_rdy),
        `endif

        .halt_req           (halt_req_o),
        .jump_req_withdelay (flush_req_o)
    );


    wire alu2wb_vld;                   // 是否要写通用寄存器
    wire alu2wb_rdy;
    wire[`MYRISCV_REGBUS] alu2wb_wdata;       // 写寄存器数据
    wire[`MYRISCV_REGADDRBUS] alu2wb_rdidx;   // 写通用寄存器地址

    wire exu_bjp_mret;
    wire exu_bjp_taken;
    wire exu_bjp_prdt_taken;
    wire [`MYRISCV_ADDRBUS] exu_bjp_jaddr;


    wire csr_ena;
    wire csr_wr_en;
    wire csr_rd_en;
    wire [`MYRISCV_CSRADDRBUS] csr_idx;
    wire [`MYRISCV_REGBUS] read_csr_dat;
    wire  [`MYRISCV_REGBUS] wbck_csr_dat;
    
    wire alu_ecall_w;
    wire alu_ebreak_w;
    alu alu_inst
    (
        .disp2alu_vld           (disp2alu_vld),
        .disp2alu_rdy           (disp2alu_rdy),
        .dec2ex_pc              (exu_pc_i),    // 指令地址
        .dec2ex_rs1_idx         (exu_rs1_idx_i),
        .dec2ex_rs2_idx         (exu_rs2_idx_i),
        .dec2ex_rs1             (exu_rs1_i),
        .dec2ex_rs2             (exu_rs2_i),
        .dec2ex_imm             (exu_imm_i),
        .dec2ex_rdwen           (exu_rdwen_i),
        .dec2ex_rdidx           (exu_rdidx_i),
        .dec2ex_info            (exu_info_i),
        
        //reg wbck itf
        .alu2wb_vld             (alu2wb_vld),
        .alu2wb_rdy             (alu2wb_rdy),
        .alu2wb_data           (alu2wb_wdata),
        .alu2wb_rdidx           (alu2wb_rdidx),

        //csr control
        .csr_ena            (csr_ena),
        .csr_wr_en          (csr_wr_en),
        .csr_rd_en          (csr_rd_en),
        .csr_idx            (csr_idx),
        .read_csr_dat       (read_csr_dat),
        .wbck_csr_dat       (wbck_csr_dat),

        //Jump, to pipe_ctrl
        .alu_ecall_o        (alu_ecall_w),
        .alu_ebreak_o       (alu_ebreak_w),

        .exu_bjp_mret       (exu_bjp_mret),
        .exu_bjp_taken      (exu_bjp_taken),
        .exu_bjp_prdt_taken (exu_bjp_prdt_taken),
        // .exu_bjp_pc         (exu_bjp_pc),
        .exu_bjp_pc         (),
        .exu_bjp_jaddr      (exu_bjp_jaddr)
    );

    wire status_mie_r;
    wire mtie_r;
    wire msie_r;
    wire meie_r;

    wire [`MYRISCV_ADDRDW-1:0] cmt_badaddr; //用！mtval写入,暂时用不到内存地址异常。
    wire cmt_badaddr_ena;
    wire [`MYRISCV_ADDRDW-1:0] cmt_epc; //用！epc写入
    wire cmt_epc_ena;
    wire [`MYRISCV_XLEN-1:0] cmt_cause; //用！mcause写入
    wire cmt_cause_ena;
    wire cmt_status_ena; //用！mstatus写入，在异常发生时触发，这里的写入内容是固定的，所以直接没有留出数据口。
    
    // wire cmt_instret_ena; //暂时用不到，这个是指令计数器的使能端口。

    wire                      cmt_mret_ena; //用！mret命令到来时触发，触发修改mstatus。而mstatus写入内容是固定值，所以没有数据口。
    
    wire [`MYRISCV_ADDRDW-1:0]  csr_epc_r; //用！输出epc值
    // wire [`MYRISCV_ADDRDW-1:0]  csr_dpc_r; //暂时不用，输出dpc值，不知道dpc是干啥的？
    wire [`MYRISCV_XLEN-1:0]     csr_mtvec_r; //用！输出mtvec_r值

    pipe_ctrl pipe_ctrl_inst
    (
        .clk                         (clk),
        .rst                         (rst),
        
        //中断输入
        .soft_trap_i                (soft_trap_i),
        .ext_trap_i                 (ext_trap_i),
        .time_trap_i                (time_trap_i),
        .jtag_halt_i                (jtag_halt_i),
        .jtag_rst_i                 (jtag_rst_i),

        //异常输入
        .ecall_i                    (alu_ecall_w),
        .ebreak_i                   (alu_ebreak_w),
        .lsu_badaddr_i              (0),

        //alu跳转输入及指令有效输入
        // exu_bjp,
        .mret_i                     (exu_bjp_mret),
        .exu_bjp_taken              (exu_bjp_taken),
        .exu_bjp_prdt_taken         (exu_bjp_prdt_taken),
        .exu_instr_pc               (exu_pc_i),
        .exu_bjp_jaddr              (exu_bjp_jaddr),
        .exu_instr_vld              (disp2alu_vld),  
        .exu_instr_rdy              (disp2alu_rdy),

        //相关csr读写接口
        // .ext_irq_trigge             (ext_irq_r),
        // .sft_irq_trigge             (sft_irq_r),
        // .tim_irq_trigge             (tmr_irq_r),
        
        .status_mie_i               (status_mie_r),
        .mtie_i                     (mtie_r),
        .msie_i                     (msie_r),
        .meie_i                     (meie_r),

        .cmt_badaddr                (cmt_badaddr),
        .cmt_badaddr_ena            (cmt_badaddr_ena),
        .cmt_epc                    (cmt_epc),
        .cmt_epc_ena                (cmt_epc_ena),
        .cmt_cause                  (cmt_cause),
        .cmt_cause_ena              (cmt_cause_ena),
        .cmt_status_ena             (cmt_status_ena),
        .cmt_mret_ena               (cmt_mret_ena),

        .csr_epc_i                  (csr_epc_r),
        .csr_mtvec_i                (csr_mtvec_r),

        .u_mode                     (1'b0),
        .s_mode                     (1'b0),
        .h_mode                     (1'b0),
        .m_mode                     (1'b1),

        //冲刷请求
        .halt_req                   (halt_req_o),
        .flush_req                  (flush_req_o),
        .flush_addr                 (flush_addr_o),

        .flush_req_no_delay         (flush_req_no_delay_o)
    );

    wire timer_stop;
    assign timer_en = timer_stop;
`ifdef MYRISCV_ARCH_64
    csr_64 
`else
    csr 
`endif
    csr_inst(
        .nonflush_cmt_ena    (),
    `ifdef E203_HAS_NICE
        .nice_xs_off         (),
    `endif
        //**********************************************
        //用！一般读写接口，同一般寄存器。
        .csr_ena            (csr_ena),
        .csr_wr_en          (csr_wr_en),
        .csr_rd_en          (csr_rd_en),
        .csr_idx            (csr_idx),
        .read_csr_dat       (read_csr_dat),
        .wbck_csr_dat       (wbck_csr_dat),
        //**********************************************
        .csr_access_ilgl    (), //没有用，固定输出0
        .tm_stop            (timer_stop),
        .core_cgstop        (),
        .tcm_cgstop         (),
        .itcm_nohold        (),
        .mdv_nob2b          (),

        //*********************************************
        .core_mhartid       ({`E203_HART_ID_W{1'b0}}), //csr_core_hardid

        // .ext_irq_r          (ext_irq_r),   //用！三个irq用于更新meip,msip,mtip。在对应中断发生时触发。
        // .sft_irq_r          (sft_irq_r),   //用！
        // .tmr_irq_r          (tmr_irq_r),   //用！
        .ext_irq_r          (ext_trap_i),
        .sft_irq_r          (soft_trap_i),
        .tmr_irq_r          (time_trap_i),

        //用！下面四个就是mie寄存器（中断使能）输出
        .status_mie_r       (status_mie_r),
        .mtie_r             (mtie_r),
        .msie_r             (msie_r),
        .meie_r             (meie_r),
        //******************************************************
        //暂时不用，这dcsr,dpc,dscratch三个寄存器不知道干啥的，和dbg有关，而且实际在csr外面，只是根据csr地址才映射在csr里，好像不是csr标准寄存器？。
        //wr_xxx_ena来写，dcsr_r等直接映射，wr_csr_nxt就是写入三个寄存器的数据。
        .wr_dcsr_ena        (),
        .wr_dpc_ena         (),
        .wr_dscratch_ena    (),

        .wr_csr_nxt         (), //直连wbck_csr_data(csr写入数据)，难道外面还有csr寄存器？？

        //这三个输入就是直接作为某个csr寄存器来输出给core看的（让core通过csr指令读取）
        .dcsr_r             ({`MYRISCV_XLEN{1'b0}}),
        .dpc_r              ({`MYRISCV_XLEN{1'b0}}),
        .dscratch_r         ({`MYRISCV_XLEN{1'b0}}),
        //***************************************************************************************************************        
        .dbg_mode           (1'b0),
        .dbg_stopcycle      (1'b0),

        .u_mode         (),
        .s_mode         (),
        .h_mode         (),
        .m_mode         (),

        //用！对各种寄存器进行硬件写入，这些寄存器都是支持硬件写入的，所以对硬件写入留出专门接口。
        .cmt_badaddr            (cmt_badaddr), //用！mtval写入,暂时用不到内存地址异常。
        .cmt_badaddr_ena        (cmt_badaddr_ena),
        .cmt_epc                (cmt_epc), //用！epc写入
        .cmt_epc_ena            (cmt_epc_ena),
        .cmt_cause              (cmt_cause), //用！mcause写入
        .cmt_cause_ena          (cmt_cause_ena),
        
        .cmt_status_ena         (cmt_status_ena), 
        //用！mstatus写入，在异常发生时触发，这里的写入内容是固定的，所以直接没有留出数据口。
        
        .cmt_instret_ena        (1'b0), //暂时用不到，这个是指令计数器的使能端口。

        .cmt_mret_ena           (cmt_mret_ena), //用！mret命令到来时触发，触发修改mstatus。而mstatus写入内容是固定值，所以没有数据口。

        .csr_epc_r              (csr_epc_r), //用！输出epc值
        .csr_dpc_r              (), //暂时不用，输出dpc值，不知道dpc是干啥的？
        .csr_mtvec_r            (csr_mtvec_r), //用！输出mtvec_r值


        .clk_aon                (clk), //clk计数器专用，永远不会停止的时钟，用于时钟计数。
        .clk                    (clk), //csr寄存器时钟
        .rst_n                  (rst) //复位。
    );

    //o:muldiv(st)
    wire div2wb_vld;                   // 是否写通用寄存器
    wire div2wb_rdy;
    wire [`MYRISCV_REGBUS] div2wb_wdata;// 写寄存器数据
    wire[`MYRISCV_REGADDRBUS] div2wb_rdidx;   // 写通用寄存器地址
`ifdef PLATFORM_SIM
    `ifdef DIV_CC
        div_c muldiv_inst(
            .clk                (clk),
            .rst                (rst),
            // from id
            .disp2div_vld       (disp2muldiv_vld),
            .disp2div_rdy       (disp2muldiv_rdy),
            // input wire[`MYRISCV_INSTBUS] dec2ex_instr,            // 指令内容
            .dec2ex_pc              (exu_pc_i),    // 指令地址
            .dec2ex_rs1_idx         (exu_rs1_idx_i),
            .dec2ex_rs2_idx         (exu_rs2_idx_i),
            .dec2ex_rs1             (exu_rs1_i),
            .dec2ex_rs2             (exu_rs2_i),
            .dec2ex_rdwen           (exu_rdwen_i),
            .dec2ex_rdidx           (exu_rdidx_i),
            .dec2ex_info            (exu_info_i),
            
            //reg wbck itf
            .div2wb_vld             (div2wb_vld),
            .div2wb_rdy             (div2wb_rdy),
            .div2wb_data            (div2wb_wdata),
            .div2wb_rdidx           (div2wb_rdidx)
        );
    `else //o: sim, but not use div_cc
        assign disp2muldiv_rdy  = 1'b0;
        assign div2wb_vld       = 1'b0;
        assign div2wb_wdata     = {`MYRISCV_XLEN{1'b0}};
        assign div2wb_rdidx     = {`MYRISCV_REGADDRWD{1'b0}};
    `endif
`else //o: on fpga
        assign disp2muldiv_rdy  = 1'b0;
        assign div2wb_vld       = 1'b0;
        assign div2wb_wdata     = {`MYRISCV_XLEN{1'b0}};
        assign div2wb_rdidx     = {`MYRISCV_REGADDRWD{1'b0}};
`endif

    //o:muldiv(end)

    // to regs
    wire lsu2wb_vld;                   // 是否写通用寄存器
    wire lsu2wb_rdy;
    wire [`MYRISCV_REGBUS] lsu2wb_wdata;       // 写寄存器数据
    wire [`MYRISCV_REGADDRBUS] lsu2wb_rdidx;   // 写通用寄存器地址

    wire lsu_cmd_vld;
    wire lsu_cmd_rdy;
    wire lsu_cmd_read;
    wire [`MYRISCV_ADDRBUS] lsu_cmd_addr;
    wire [`MYRISCV_REGBUS] lsu_cmd_wdata;
    wire [(`MYRISCV_DATADW/8-1):0] lsu_cmd_wmask;

    wire lsu_rsp_vld;
    wire lsu_rsp_rdy;
    wire [`MYRISCV_REGBUS] lsu_rsp_rdata;
    wire lsu_rsp_err;

    lsu lsu_inst
    (
        .clk                    (clk),
        .rst                    (rst),

        .disp2lsu_vld           (disp2lsu_vld),
        .disp2lsu_rdy           (disp2lsu_rdy),
        .ex2lsu_pc              (exu_pc_i),    // 指令地址
        .ex2lsu_rs1             (exu_rs1_i),
        .ex2lsu_rs2             (exu_rs2_i),
        .ex2lsu_imm             (exu_imm_i),
        .ex2lsu_rdwen           (exu_rdwen_i),
        .ex2lsu_rdidx           (exu_rdidx_i),
        .ex2lsu_info            (exu_info_i),

        .nice2lsu_vld           (nice2lsu_vld),
        .nice2lsu_rdy           (nice2lsu_rdy),
        .nice2lsu_read          (nice2lsu_read),
        .nice2lsu_addr          (nice2lsu_addr),
        .nice2lsu_wdata         (nice2lsu_wdata),
        .nice2lsu_wmask         (nice2lsu_wmask),
        .nice2lsu_size          (nice2lsu_size),
        .nice2lsu_unsign        (nice2lsu_unsign),
        .nice2lsu_rdidx         (nice2lsu_rdidx),
        .nice2lsu_ret           (nice2lsu_ret),

        .lsu_cmd_vld   (lsu_cmd_vld),
        .lsu_cmd_rdy   (lsu_cmd_rdy),
        .lsu_cmd_read   (lsu_cmd_read),
        .lsu_cmd_addr   (lsu_cmd_addr),
        .lsu_cmd_wdata   (lsu_cmd_wdata),
        .lsu_cmd_wmask   (lsu_cmd_wmask),

        .lsu_rsp_vld            (lsu_rsp_vld),
        .lsu_rsp_rdy            (lsu_rsp_rdy),
        .lsu_rsp_rdata          (lsu_rsp_rdata),
        .lsu_rsp_err            (lsu_rsp_err),

        .lsu2nice_vld           (lsu2nice_vld),
        .lsu2nice_rdy           (lsu2nice_rdy),
        .lsu2nice_wdata         (lsu2nice_wdata),
        .lsu2nice_rdidx         (lsu2nice_rdidx),

        // to regs
        .lsu2wb_vld   (lsu2wb_vld),                   // 是否写通用寄存器
        .lsu2wb_rdy   (lsu2wb_rdy),
        .lsu2wb_wdata   (lsu2wb_wdata),       // 写寄存器数据
        .lsu2wb_rdidx   (lsu2wb_rdidx)    // 写通用寄存器地址
    );

    wire lsu2sram_cmd_vld_w;
    wire lsu2sram_cmd_rdy_w;
    wire lsu2sram_cmd_read_w;
    wire [`MYRISCV_ADDRBUS] lsu2sram_cmd_addr_w;
    wire [`MYRISCV_DATABUS] lsu2sram_cmd_wdata_w;
    wire [(`MYRISCV_DATADW/8-1):0] lsu2sram_cmd_wmask_w;
    fifo_simple # (
    .CUT_READY          (1),
    .ZEROOUT_WHENEMPTY  (0),// Mask out the data with valid or not
    .DP                 (2),// FIFO depth
    .DW                 (1+(`MYRISCV_ADDRDW)+(`MYRISCV_DATADW)+(`MYRISCV_DATADW/8))// FIFO width(read+addr+wdata+wmask)
    ) lsu2sram_cmd_cutfifo (
        .w_req          (lsu2sram_cmd_vld_w),
        .unfull         (lsu2sram_cmd_rdy_w),
        .data_i         ({lsu2sram_cmd_read_w, lsu2sram_cmd_addr_w, lsu2sram_cmd_wdata_w, lsu2sram_cmd_wmask_w}),
        .unempty        (lsu2sram_cmd_vld),
        .r_req          (lsu2sram_cmd_rdy),
        .data_o         ({lsu2sram_cmd_read, lsu2sram_cmd_addr, lsu2sram_cmd_wdata, lsu2sram_cmd_wmask}),

        .clk            (clk),
        .rst            (rst)
    );

    lsu_splt lsu_splt_inst
    (
        .clk                (clk),
        .rst                (rst),

        .lsu_cmd_vld    (lsu_cmd_vld),
        .lsu_cmd_rdy    (lsu_cmd_rdy),
        .lsu_cmd_read   (lsu_cmd_read),
        .lsu_cmd_addr   (lsu_cmd_addr),
        .lsu_cmd_wdata  (lsu_cmd_wdata),
        .lsu_cmd_wmask  (lsu_cmd_wmask),

        .lsu_rsp_vld            (lsu_rsp_vld),
        .lsu_rsp_rdy            (lsu_rsp_rdy),
        .lsu_rsp_rdata          (lsu_rsp_rdata),
        .lsu_rsp_err            (lsu_rsp_err),

        .lsu2sram_cmd_vld   (lsu2sram_cmd_vld_w),
        .lsu2sram_cmd_rdy   (lsu2sram_cmd_rdy_w),
        .lsu2sram_cmd_read  (lsu2sram_cmd_read_w),
        .lsu2sram_cmd_addr  (lsu2sram_cmd_addr_w),
        .lsu2sram_cmd_wdata (lsu2sram_cmd_wdata_w),
        .lsu2sram_cmd_wmask (lsu2sram_cmd_wmask_w),

        .lsu2sram_rsp_vld   (lsu2sram_rsp_vld),
        .lsu2sram_rsp_rdy   (lsu2sram_rsp_rdy),
        .lsu2sram_rsp_rdata (lsu2sram_rsp_rdata),
        .lsu2sram_rsp_err   (lsu2sram_rsp_err),

        .lsu2dtcm_cmd_vld       (lsu2dtcm_cmd_vld),
        .lsu2dtcm_cmd_rdy       (lsu2dtcm_cmd_rdy),
        .lsu2dtcm_cmd_read      (lsu2dtcm_cmd_read),
        .lsu2dtcm_cmd_addr      (lsu2dtcm_cmd_addr),
        .lsu2dtcm_cmd_wdata     (lsu2dtcm_cmd_wdata),
        .lsu2dtcm_cmd_wmask     (lsu2dtcm_cmd_wmask),

        .lsu2dtcm_rsp_vld   (lsu2dtcm_rsp_vld),
        .lsu2dtcm_rsp_rdy   (lsu2dtcm_rsp_rdy),
        .lsu2dtcm_rsp_rdata (lsu2dtcm_rsp_rdata),
        .lsu2dtcm_rsp_err   (lsu2dtcm_rsp_err),

        .lsu2biu_cmd_vld    (lsu2biu_cmd_vld),
        .lsu2biu_cmd_rdy    (lsu2biu_cmd_rdy),
        .lsu2biu_cmd_read   (lsu2biu_cmd_read),
        .lsu2biu_cmd_addr   (lsu2biu_cmd_addr),
        .lsu2biu_cmd_wdata  (lsu2biu_cmd_wdata),
        .lsu2biu_cmd_wmask  (lsu2biu_cmd_wmask),

        .lsu2biu_rsp_vld    (lsu2biu_rsp_vld),
        .lsu2biu_rsp_rdy    (lsu2biu_rsp_rdy),
        .lsu2biu_rsp_rdata  (lsu2biu_rsp_rdata),
        .lsu2biu_rsp_err    (lsu2biu_rsp_err)
    );


    `ifdef MYRISCV_HAS_NICE
    wire nice2wb_vld;
    wire nice2wb_rdy;
    wire [`MYRISCV_REGADDRBUS] nice2wb_rdidx;
    wire [`MYRISCV_REGBUS] nice2wb_wdata;

    exu_cordic cordic_inst
    (
        // .clk                (clk),
        // .rst_n              (rst),

        // .disp2cordic_vld    (disp2nice_vld),
        // .disp2cordic_rdy    (disp2nice_rdy)

        .clk                        (clk),
        .rst_n                      (rst),

        .disp2cordic_vld            (disp2nice_vld),
        .disp2cordic_rdy            (disp2nice_rdy),
        .ex2cordic_info             (exu_info_i),
        .ex2cordic_rs1              (exu_rs1_i),
        .ex2cordic_rdidx            (exu_rdidx_i),

        .cordic2wb_vld              (nice2wb_vld),
        .cordic2wb_rdy              (nice2wb_rdy),
        .rdidx_o                    (nice2wb_rdidx),
        .rddata_o                   (nice2wb_wdata)
    );
    `endif

    wbck wbck_inst
    (
        // .cur_w_index                (cur_w_index),
        .clr_req                (oitf_clr_req_o),
        .clr_idx                (oitf_clr_idx_o),

        .alu2wb_vld             (alu2wb_vld),
        .alu2wb_rdy             (alu2wb_rdy),
        .alu2wb_wdata           (alu2wb_wdata),
        .alu2wb_waddr           (alu2wb_rdidx),

        .div2wb_vld             (div2wb_vld),
        .div2wb_rdy             (div2wb_rdy),
        .div2wb_wdata           (div2wb_wdata),
        .div2wb_waddr           (div2wb_rdidx),

        .nice2wb_vld             (nice2wb_vld),
        .nice2wb_rdy             (nice2wb_rdy),
        .nice2wb_wdata           (nice2wb_wdata),
        .nice2wb_waddr           (nice2wb_rdidx), 

        .lsu2wb_vld             (lsu2wb_vld),
        .lsu2wb_rdy             (lsu2wb_rdy),
        .lsu2wb_wdata           (lsu2wb_wdata),
        .lsu2wb_waddr           (lsu2wb_rdidx),

        .reg_wen                (reg_wen),
        .reg_waddr              (reg_waddr),
        .reg_wdata              (reg_wdata)
    );

endmodule
