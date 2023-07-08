`include "mydefines.v"
`include "e203_defines.v"
module riscv_core
(
    clk,
    rst,

    jtag_cmd_vld,
    jtag_cmd_rdy,
    jtag_cmd_read,
    jtag_cmd_addr,
    jtag_cmd_wdata,
    jtag_cmd_wmask,

    jtag_rsp_vld,
    jtag_rsp_rdy,
    jtag_rsp_err,
    jtag_rsp_rdata,

    soft_trap_i,
    ext_trap_i,
    time_trap_i,
    jtag_halt_i,
    jtag_rst_i,

    mem_icb_cmd_vld,
    mem_icb_cmd_rdy,
    mem_icb_cmd_addr,
    mem_icb_cmd_read,
    mem_icb_cmd_wdata,
    mem_icb_cmd_wmask,

    mem_icb_rsp_vld,
    mem_icb_rsp_rdy,
    mem_icb_rsp_err,
    mem_icb_rsp_rdata,

    ppi_icb_cmd_valid,
    ppi_icb_cmd_ready,
    ppi_icb_cmd_addr,
    ppi_icb_cmd_read,
    ppi_icb_cmd_wdata,
    ppi_icb_cmd_wmask,
    //
    //* Bus RSP channel
    ppi_icb_rsp_valid,
    ppi_icb_rsp_ready,
    ppi_icb_rsp_err,
    ppi_icb_rsp_excl_ok,
    ppi_icb_rsp_rdata,

    clint_icb_cmd_valid,
    clint_icb_cmd_ready,
    clint_icb_cmd_addr,
    clint_icb_cmd_read,
    clint_icb_cmd_wdata,
    clint_icb_cmd_wmask,
    //
    //* Bus RSP channel
    clint_icb_rsp_valid,
    clint_icb_rsp_ready,
    clint_icb_rsp_err,
    clint_icb_rsp_excl_ok,
    clint_icb_rsp_rdata,

    timer_en
);

    `include "mydefines.v"
//*******************************port*********************************************
    input clk, rst;
    input jtag_cmd_vld;
    output jtag_cmd_rdy;
    input jtag_cmd_read;
    input [`MYRISCV_ADDRBUS] jtag_cmd_addr;
    input [`MYRISCV_XLEN-1 : 0] jtag_cmd_wdata;
    input [`MYRISCV_XLEN/8-1 : 0] jtag_cmd_wmask;

    output jtag_rsp_vld;
    input jtag_rsp_rdy;
    output jtag_rsp_err;
    output [`MYRISCV_XLEN-1 : 0] jtag_rsp_rdata;

    input wire soft_trap_i;
    input wire ext_trap_i;
    input wire time_trap_i;
    input wire jtag_halt_i;
    input wire jtag_rst_i;

    output wire mem_icb_cmd_vld;
    input wire mem_icb_cmd_rdy;
    output wire [`MYRISCV_ADDRBUS] mem_icb_cmd_addr;
    output wire mem_icb_cmd_read;
    output wire [`MYRISCV_DATABUS] mem_icb_cmd_wdata;
    output wire [(`MYRISCV_DATADW/8-1):0] mem_icb_cmd_wmask;

    input wire mem_icb_rsp_vld;
    output wire mem_icb_rsp_rdy;
    input wire mem_icb_rsp_err;
    input wire [`MYRISCV_DATABUS] mem_icb_rsp_rdata;

    output wire ppi_icb_cmd_valid;
    input wire ppi_icb_cmd_ready;
    output wire [`MYRISCV_ADDRBUS] ppi_icb_cmd_addr;
    output wire ppi_icb_cmd_read;
    output wire [`MYRISCV_DATABUS] ppi_icb_cmd_wdata;
    output wire [(`MYRISCV_DATADW/8-1):0] ppi_icb_cmd_wmask;
    //
    //* Bus RSP channel
    input wire ppi_icb_rsp_valid;
    output wire ppi_icb_rsp_ready;
    input wire ppi_icb_rsp_err;
    input wire ppi_icb_rsp_excl_ok;
    input wire [`MYRISCV_DATABUS] ppi_icb_rsp_rdata;

    output wire clint_icb_cmd_valid;
    input wire clint_icb_cmd_ready;
    output wire [`MYRISCV_ADDRBUS] clint_icb_cmd_addr;
    output wire clint_icb_cmd_read;
    output wire [`MYRISCV_DATABUS] clint_icb_cmd_wdata;
    output wire [(`MYRISCV_DATADW/8-1):0] clint_icb_cmd_wmask;
    //
    //* Bus RSP channel
    input wire clint_icb_rsp_valid;
    output wire clint_icb_rsp_ready;
    input wire clint_icb_rsp_err;
    input wire clint_icb_rsp_excl_ok;
    input wire [`MYRISCV_DATABUS] clint_icb_rsp_rdata;

    output timer_en;

//*******************************************************************************
    wire flush_req_w;
    wire [`MYRISCV_ADDRBUS] flush_addr_w;
    wire flush_req_no_delay_w;

    wire ifu_vld_w;
    wire ifu_rdy_w;
    wire ifu_prdt_taken_w;
    // wire ifu_pc_has_jump_w;
    wire [`MYRISCV_ADDRBUS] ifu_pc_w;
    wire [`MYRISCV_INSTBUS] ifu_instr_w;

    //g:connect ifu and pc_split(st)
    wire pc_req_vld_chal;
    wire pc_req_rdy_chal;
    wire [`MYRISCV_ADDRBUS] pc_req_addr_chal;

    wire pc_rsp_vld_chal;
    wire pc_rsp_rdy_chal;
    wire [`MYRISCV_DATABUS] pc_rsp_data_chal;
    wire pc_rsp_err_chal;
    //g:connect ifu and pc_split(ed)

    newifu ifu_inst
    (
        .clk                    (clk),
        .rst                    (rst),
        
        .jmp_req_i              (flush_req_w),
        .jmp_addr_i             (flush_addr_w),

        .ifu_prdt_taken_o       (ifu_prdt_taken_w),
        // .ifu_pc_has_jump_o      (ifu_pc_has_jump_w),
        .ifu_pc_o               (ifu_pc_w),
        .ifu_vld_o              (ifu_vld_w),
        .ifu_rdy_o              (ifu_rdy_w),
        .ifu_instr_o            (ifu_instr_w),
        .ifu_err_o              (),

        .ifu_req_vld            (pc_req_vld_chal),
        .ifu_req_rdy            (pc_req_rdy_chal),
        .ifu_req_addr           (pc_req_addr_chal),

        .ifu_rsp_vld            (pc_rsp_vld_chal),
        .ifu_rsp_rdy            (pc_rsp_rdy_chal),
        .ifu_rsp_data           (pc_rsp_data_chal),
        .ifu_rsp_err            (pc_rsp_err_chal)
    );

    //g: connect pc_split and sram(st)
    wire ifu2sram_req_vld;
    wire ifu2sram_req_rdy;
    wire [`MYRISCV_ADDRBUS] ifu2sram_req_addr;

    wire [`MYRISCV_DATABUS] ifu2sram_rsp_data;
    wire ifu2sram_rsp_err;
    wire ifu2sram_rsp_vld;
    wire ifu2sram_rsp_rdy;
    //g: connect pc_split and sram(ed)
    
    //g: connect pc_split and biu(st)
    wire ifu2biu_cmd_vld;
    wire ifu2biu_cmd_rdy;
    wire [`MYRISCV_ADDRBUS] ifu2biu_cmd_addr;

    wire [`MYRISCV_DATABUS] ifu2biu_rsp_data;
    wire ifu2biu_rsp_err;
    wire ifu2biu_rsp_vld;
    wire ifu2biu_rsp_rdy;
    //g: connect pc_split and biu(ed)

    pcside_splt pc_split_inst
    (
        .clk                    (clk),
        .rst                    (rst),

        .pc_req_addr        (pc_req_addr_chal),
        .pc_req_vld         (pc_req_vld_chal),
        .pc_req_rdy         (pc_req_rdy_chal),

        .pc_rsp_data        (pc_rsp_data_chal),
        .pc_rsp_err         (pc_rsp_err_chal),
        .pc_rsp_vld         (pc_rsp_vld_chal),
        .pc_rsp_rdy         (pc_rsp_rdy_chal),


        .sram_req_vld       (ifu2sram_req_vld),
        .sram_req_rdy       (ifu2sram_req_rdy),
        .sram_req_addr      (ifu2sram_req_addr),

        .sram_rsp_vld       (ifu2sram_rsp_vld),
        .sram_rsp_rdy       (ifu2sram_rsp_rdy),
        .sram_rsp_data      (ifu2sram_rsp_data),
        .sram_rsp_err       (ifu2sram_rsp_err),

        .icb_req_vld        (ifu2biu_cmd_vld),
        .icb_req_rdy        (ifu2biu_cmd_rdy),
        .icb_req_addr       (ifu2biu_cmd_addr),

        .icb_rsp_vld        (ifu2biu_rsp_vld),
        .icb_rsp_rdy        (ifu2biu_rsp_rdy),
        .icb_rsp_data       (ifu2biu_rsp_data),
        .icb_rsp_err        (ifu2biu_rsp_err)
    );

    wire sram_cmd_vld;
    wire sram_cmd_rdy;
    wire [`MYRISCV_ADDRBUS] sram_cmd_addr;
    wire sram_cmd_read;
    wire [`MYRISCV_DATABUS] sram_cmd_wdata;
    wire [(`MYRISCV_DATADW/8-1):0] sram_cmd_wmask;

    wire sram_rsp_vld;
    wire sram_rsp_rdy;
    wire sram_rsp_err;
    wire [`MYRISCV_DATABUS] sram_rsp_rdata;    

    wire lsu2sram_cmd_vld;
    wire lsu2sram_cmd_rdy;
    wire lsu2sram_cmd_read;
    wire [`MYRISCV_ADDRBUS] lsu2sram_cmd_addr;
    wire [`MYRISCV_DATABUS] lsu2sram_cmd_wdata;
    wire [(`MYRISCV_DATADW/8-1):0] lsu2sram_cmd_wmask;

    wire lsu2sram_rsp_vld;
    wire lsu2sram_rsp_rdy;
    wire [`MYRISCV_DATABUS] lsu2sram_rsp_rdata;
    wire lsu2sram_rsp_err;

    wire jtag2sram_cmd_vld;
    wire jtag2sram_cmd_rdy;
    wire jtag2sram_cmd_read;
    wire [`MYRISCV_ADDRBUS] jtag2sram_cmd_addr;
    wire [`MYRISCV_DATABUS] jtag2sram_cmd_wdata;
    wire [(`MYRISCV_DATADW/8-1):0] jtag2sram_cmd_wmask;

    wire jtag2sram_rsp_vld;
    wire jtag2sram_rsp_rdy;
    wire [`MYRISCV_DATABUS] jtag2sram_rsp_rdata;
    wire jtag2sram_rsp_err;

    sram_arbt sram_arbt_inst
    (
        .clk                 (clk),
        .rst                 (rst),

        .pc_cmd_vld          (ifu2sram_req_vld),
        .pc_cmd_rdy          (ifu2sram_req_rdy), 
        .pc_cmd_addr         (ifu2sram_req_addr),
        // .pc_cmd_read, // =1
        // .pc_cmd_wdata, //=0
        // .pc_cmd_wmask, //=0

        .pc_rsp_vld          (ifu2sram_rsp_vld),
        .pc_rsp_rdy          (ifu2sram_rsp_rdy),
        .pc_rsp_err          (ifu2sram_rsp_err), //dont us
        .pc_rsp_rdata        (ifu2sram_rsp_data),

        .ext_cmd_vld            (jtag2sram_cmd_vld),
        .ext_cmd_rdy            (jtag2sram_cmd_rdy),
        .ext_cmd_addr           (jtag2sram_cmd_addr),
        .ext_cmd_read           (jtag2sram_cmd_read),
        .ext_cmd_wdata          (jtag2sram_cmd_wdata),
        .ext_cmd_wmask          (jtag2sram_cmd_wmask),

        .ext_rsp_vld            (jtag2sram_rsp_vld),
        .ext_rsp_rdy            (jtag2sram_rsp_rdy),
        .ext_rsp_err            (jtag2sram_rsp_err),
        .ext_rsp_rdata          (jtag2sram_rsp_rdata),

        .lsu_cmd_vld            (lsu2sram_cmd_vld),
        .lsu_cmd_rdy            (lsu2sram_cmd_rdy),
        .lsu_cmd_addr           (lsu2sram_cmd_addr),
        .lsu_cmd_read           (lsu2sram_cmd_read),
        .lsu_cmd_wdata          (lsu2sram_cmd_wdata),
        .lsu_cmd_wmask          (lsu2sram_cmd_wmask),

        .lsu_rsp_vld            (lsu2sram_rsp_vld),
        .lsu_rsp_rdy            (lsu2sram_rsp_rdy),
        .lsu_rsp_err            (lsu2sram_rsp_err),
        .lsu_rsp_rdata          (lsu2sram_rsp_rdata),

        .sram_cmd_vld           (sram_cmd_vld),
        .sram_cmd_rdy           (sram_cmd_rdy),
        .sram_cmd_addr          (sram_cmd_addr),
        .sram_cmd_read          (sram_cmd_read),
        .sram_cmd_wdata         (sram_cmd_wdata),
        .sram_cmd_wmask         (sram_cmd_wmask),

        .sram_rsp_vld           (sram_rsp_vld),
        .sram_rsp_rdy           (sram_rsp_rdy),
        .sram_rsp_err           (sram_rsp_err),
        .sram_rsp_rdata         (sram_rsp_rdata)
    );

    wire sram_cs;
    wire sram_we;
    wire [`MYRISCV_ADDRBUS] sram_addr;
    wire [(`MYRISCV_DATADW/8-1):0] sram_wem;
    wire [`MYRISCV_DATABUS] sram_wdata;
    wire [`MYRISCV_DATABUS] sram_rdata;

    sram_ctrl sram_ctrl_inst
    (
        .clk                (clk),
        .rst                (rst),

        .sram_cmd_vld           (sram_cmd_vld),
        .sram_cmd_rdy           (sram_cmd_rdy),
        .sram_cmd_addr          (sram_cmd_addr),
        .sram_cmd_read          (sram_cmd_read),
        .sram_cmd_wdata         (sram_cmd_wdata),
        .sram_cmd_wmask         (sram_cmd_wmask),

        .sram_rsp_vld           (sram_rsp_vld),
        .sram_rsp_rdy           (sram_rsp_rdy),
        .sram_rsp_err           (sram_rsp_err),
        .sram_rsp_rdata         (sram_rsp_rdata),


        .sram_cs                (sram_cs),
        .sram_we                (sram_we),
        .sram_addr              (sram_addr),
        .sram_wem               (sram_wem),
        .sram_wdata             (sram_wdata),
        .sram_rdata             (sram_rdata)
    );

    
`ifdef USE_XILINXIP //Xilinx IP
`ifdef MYRISCV_ARCH_64
    blk_mem_gen_0 sram_inst
    (
        .clka           (clk),
        .ena            (sram_cs),
        .wea            ({(`MYRISCV_DATADW/8){sram_we}} & sram_wem),
        .addra          (sram_addr[3+`SRAM_ADDR_WD-1:3]),
        .dina           (sram_wdata),
        .douta          (sram_rdata)
    );
`else
    blk_mem_gen_0 sram_inst
    (
        .clka           (clk),
        .ena            (sram_cs),
        .wea            ({(`MYRISCV_DATADW/8){sram_we}} & sram_wem),
        .addra          (sram_addr[2+`SRAM_ADDR_WD-1:2]),
        .dina           (sram_wdata),
        .douta          (sram_rdata)
    );
`endif
`else
    sram_sim #(
        .DP             (`SRAM_SIZE),
        .FORCE_X2ZERO   (0),
        .DW             (`MYRISCV_DATADW),
        .MW             (`MYRISCV_DATADW/8),
        .AW             (`MYRISCV_ADDRDW)
    )sram_inst
    (
        .clk            (clk),
        .cs             (sram_cs),
        .we             (sram_we),
        .addr           (sram_addr),
        .din            (sram_wdata),
        .wem            (sram_wem),
        .dout           (sram_rdata)
    );
    always @(posedge clk) begin
        if(sram_cs & sram_addr[27:`SRAM_ADDR_OFF]>=`SRAM_SIZE) begin
            $display("Error! Mem Overflow! Addr: %x", sram_addr);
            $finish;
        end
    end
`endif

    wire if2dec_vld_w;
    wire if2dec_rdy_w;
    wire [`MYRISCV_INSTBUS] if2dec_instr_w;
    wire [`MYRISCV_ADDRBUS] if2dec_pc_w;
    wire if2dec_prdt_taken_w;
    pc2dec pc2dec_inst(
        .clk                    (clk),
        .rst                    (rst),

        .jump_flag_i            (flush_req_w),

        .if2dec_vld_i           (ifu_vld_w),
        .if2dec_rdy_i           (ifu_rdy_w),
        .if2dec_instr_i         (ifu_instr_w),
        .if2dec_pc_j_i          (/*ifu_pc_has_jump_w*/1'b0 ),
        .if2dec_pc_i            (ifu_pc_w),
        .if2dec_prdt_taken_i    (ifu_prdt_taken_w),

        .if2dec_vld_o           (if2dec_vld_w),
        .if2dec_rdy_o           (if2dec_rdy_w),
        .if2dec_instr_o         (if2dec_instr_w),
        .if2dec_pc_o            (if2dec_pc_w),
        .if2dec_prdt_taken_o    (if2dec_prdt_taken_w)
    );

    wire i_misalgn = 1'b0;           // 指令未对齐异常
    wire i_buserr = 1'b0;               // 总线访问错误
    wire i_muldiv_b2b = 1'b0;        // The back2back case for mul/div
    wire dbg_mode = 1'b0;

    wire dec2ex_vld_w1;
    wire dec2ex_rdy_w1;
    wire dec2ex_rdwen_w1;
    wire [`MYRISCV_REGADDRBUS] dec2ex_rs1idx;    // 读通用寄存器1地址
    wire [`MYRISCV_REGADDRBUS] dec2ex_rs2idx;    // 读通用寄存器2地址
    wire [`MYRISCV_REGADDRBUS] dec2ex_rdidx_w1;
    wire [`MY_DECINFO_WIDTH-1 : 0] dec2ex_info_w1;
    wire [`MYRISCV_REGBUS] dec2ex_imm_w1;
    wire [`MYRISCV_ADDRBUS] dec2ex_pc_w1; 
    `ifdef PLATFORM_SIM
        wire [`MYRISCV_INSTBUS] dec2ex_instr_w1;
    `endif

    // wire wreg_index;
    wire is_long_instr;
    wire oitf_hold;
    dec decode_inst
    (
        .if2dec_instr     (if2dec_instr_w),
        .if2dec_pc      (if2dec_pc_w),
        .if2dec_vld     (if2dec_vld_w),
        .if2dec_rdy     (if2dec_rdy_w),
        .if2dec_prdt_taken  (if2dec_prdt_taken_w),
        .i_misalgn          (i_misalgn),
        .i_buserr           (i_buserr),
        .i_muldiv_b2b       (i_muldiv_b2b),

        .dbg_mode           (dbg_mode),

        .dec2ex_vld         (dec2ex_vld_w1),
        .dec2ex_rdy         (dec2ex_rdy_w1),
    `ifdef PLATFORM_SIM
        .dec2ex_instr   (dec2ex_instr_w1),
    `endif

        .dec2ex_rdwen       (dec2ex_rdwen_w1),
        .dec2ex_rs1x0       (),
        .dec2ex_rs2x0       (),
        .dec2ex_rs1en       (),
        .dec2ex_rs2en       (),
        .dec2ex_rs1idx      (dec2ex_rs1idx),
        .dec2ex_rs2idx      (dec2ex_rs2idx),
        .dec2ex_rdidx       (dec2ex_rdidx_w1),
        .dec2ex_info        (dec2ex_info_w1),
        .dec2ex_imm         (dec2ex_imm_w1),
        .dec2ex_pc          (dec2ex_pc_w1),
        .dec_misalgn        (),
        .dec_buserr         (),
        .dec_ilegl          (), //指令译码结果为非法


        `ifdef MYRISCV_HAS_NICE//{
            //nice decode
            .nice_xs_off            (),  
            .dec_nice               (),
            .nice_cmt_off_ilgl_o    (),  
        `endif//}
        
        .dec_mulhsu(),
        .dec_mul   (),
        .dec_div   (),
        .dec_rem   (),
        .dec_divu  (),
        .dec_remu  (),

        .dec_rv32(),
        .dec_bjp(),
        .dec_jal(),
        .dec_jalr(),
        .dec_bxx(),

        .dec_jalr_rs1idx    (),
        .dec_bjp_imm        (),

        // .wreg_index                 (wreg_index),
        .is_long_instr          (is_long_instr),
        .oitf_hold              (oitf_hold)
    );

    // wire [`MYRISCV_REGADDRBUS] cur_w_index;
    wire oitf_clr_req;
    wire [`MYRISCV_REGADDRBUS] oitf_clr_idx;
    oitf_fifo oitf_inst  
    (
        .clk                    (clk),
        .rst                    (rst & (~jtag_rst_i)),

        .is_long_instr           (is_long_instr),
        .instr_vld              (if2dec_vld_w & dec2ex_rdy_w1 & ~flush_req_w & ~flush_req_no_delay_w),

        .rs1_idx          (dec2ex_rs1idx),
        .rs2_idx          (dec2ex_rs2idx),
        .rdidx            (dec2ex_rdidx_w1),

        .dec2oitf_hold          (oitf_hold),
        .clr_req                (oitf_clr_req),
        .clr_idx                (oitf_clr_idx)
    );

    wire reg_wen;
    wire [`MYRISCV_REGADDRBUS] reg_waddr;
    wire [`MYRISCV_REGBUS] reg_wdata;
    wire [`MYRISCV_REGBUS] reg1_rdata;
    wire [`MYRISCV_REGBUS] reg2_rdata;
    regfile reg_inst
    (
        .clk            (clk),
        .rst_n          (rst),
        // .rst_n          (~jtag_rst_i),
        .test_mode      (1'b1),
        .read_src1_idx  (dec2ex_rs1idx),
        .read_src2_idx  (dec2ex_rs2idx),
        .read_src1_dat  (reg1_rdata),
        .read_src2_dat  (reg2_rdata),

        .wbck_dest_wen  (reg_wen),
        .wbck_dest_idx  (reg_waddr),
        .wbck_dest_dat  (reg_wdata),
        .x1_r           ()            
    );

    wire dec2ex_vld_w2; 
    wire dec2ex_rdy_w2;
    wire dec2ex_rdwen_w2;
    wire [`MYRISCV_REGADDRBUS] dec2ex_rs1_idx_w2;
    wire [`MYRISCV_REGADDRBUS] dec2ex_rs2_idx_w2;
    wire [`MYRISCV_REGBUS] dec2ex_rs1_w2;    // 读通用寄存器1地址
    wire [`MYRISCV_REGBUS] dec2ex_rs2_w2;    // 读通用寄存器2地址
    wire [`MYRISCV_REGADDRBUS] dec2ex_rdidx_w2;
    wire [`MY_DECINFO_WIDTH-1 : 0] dec2ex_info_w2;
    wire [`MYRISCV_REGBUS] dec2ex_imm_w2;
    wire [`MYRISCV_ADDRBUS] dec2ex_pc_w2; 
    `ifdef PLATFORM_SIM
        wire [`MYRISCV_INSTBUS] dec2ex_instr_w2;
    `endif

    dec2exu dec2exu_inst(
        .clk                    (clk), 
        .rst                    (rst),

        .dec2ex_vld_i    (dec2ex_vld_w1),
        .dec2ex_rdy_i    (dec2ex_rdy_w1),
        .dec2ex_pc_i    (dec2ex_pc_w1),
        `ifdef PLATFORM_SIM
            .dec2ex_instr_i   (dec2ex_instr_w1),
        `endif
        .dec2ex_rs1_idx_i       (dec2ex_rs1idx),
        .dec2ex_rs2_idx_i       (dec2ex_rs2idx),
        .dec2ex_rs1_i    (reg1_rdata),
        .dec2ex_rs2_i    (reg2_rdata),
        .dec2ex_imm_i    (dec2ex_imm_w1),
        .dec2ex_rdwen_i    (dec2ex_rdwen_w1),
        .dec2ex_rdidx_i    (dec2ex_rdidx_w1),
        .dec2ex_info_i    (dec2ex_info_w1),

        .dec2ex_vld_o   (dec2ex_vld_w2),
        .dec2ex_rdy_o   (dec2ex_rdy_w2),
        .dec2ex_rs1_idx_o       (dec2ex_rs1_idx_w2),
        .dec2ex_rs2_idx_o       (dec2ex_rs2_idx_w2),
        .dec2ex_rs1_o   (dec2ex_rs1_w2),
        .dec2ex_rs2_o   (dec2ex_rs2_w2),
        .dec2ex_pc_o   (dec2ex_pc_w2),
        `ifdef PLATFORM_SIM
            .dec2ex_instr_o   (dec2ex_instr_w2),
        `endif
        .dec2ex_imm_o   (dec2ex_imm_w2),
        .dec2ex_rdwen_o   (dec2ex_rdwen_w2),
        .dec2ex_rdidx_o   (dec2ex_rdidx_w2),
        .dec2ex_info_o   (dec2ex_info_w2),

        .jump_flag_i            (flush_req_w)
    );


    wire lsu2biu_cmd_vld;
    wire lsu2biu_cmd_rdy;
    wire lsu2biu_cmd_read;
    wire [`MYRISCV_ADDRBUS] lsu2biu_cmd_addr;
    wire [`MYRISCV_DATABUS] lsu2biu_cmd_wdata;
    wire [(`MYRISCV_DATADW/8-1):0] lsu2biu_cmd_wmask;

    wire lsu2biu_rsp_vld;
    wire lsu2biu_rsp_rdy;
    wire [`MYRISCV_DATABUS] lsu2biu_rsp_rdata;
    wire lsu2biu_rsp_err;

    exu exu_inst(
        .clk                    (clk),
        .rst                    (rst),
        //dec to exu
        .exu_vld_i              (dec2ex_vld_w2),
        .exu_rdy_i              (dec2ex_rdy_w2),
        .exu_rs1_idx_i          (dec2ex_rs1_idx_w2),
        .exu_rs2_idx_i          (dec2ex_rs2_idx_w2),
        .exu_rs1_i              (dec2ex_rs1_w2),
        .exu_rs2_i              (dec2ex_rs2_w2),
        `ifdef PLATFORM_SIM
            .exu_instr_i        (dec2ex_instr_w2),
        `endif
        .exu_pc_i               (dec2ex_pc_w2),
        .exu_imm_i              (dec2ex_imm_w2),
        .exu_rdwen_i            (dec2ex_rdwen_w2),
        .exu_rdidx_i            (dec2ex_rdidx_w2),
        .exu_info_i             (dec2ex_info_w2),

        .soft_trap_i            (soft_trap_i),
        .ext_trap_i             (ext_trap_i),
        .time_trap_i            (time_trap_i),
        .jtag_halt_i            (jtag_halt_i),
        .jtag_rst_i             (jtag_rst_i),

        .halt_req_o             (),
        .flush_req_o            (flush_req_w),
        .flush_addr_o           (flush_addr_w),

        .flush_req_no_delay_o   (flush_req_no_delay_w),

        .nice2lsu_vld           (1'b0),
        .nice2lsu_rdy           (),
        .nice2lsu_read          (),   // 指令地址
        .nice2lsu_addr          (),       // 通用寄存器1输入数据
        .nice2lsu_wdata         (),       // 通用寄存器2输入数据
        .nice2lsu_wmask         (),
        .nice2lsu_size          (),
        .nice2lsu_unsign        (),
        .nice2lsu_rdidx         (),
        .nice2lsu_ret           (1'b0),//将结果写回nice而不是reg中.

        .lsu2nice_vld           (),                   // 
        .lsu2nice_rdy           (1'b0),
        .lsu2nice_wdata         (),       // 
        .lsu2nice_rdidx         (),   // 这个返回地址不知道有没有用，先留着。

        .lsu2sram_cmd_vld       (lsu2sram_cmd_vld),
        .lsu2sram_cmd_rdy       (lsu2sram_cmd_rdy),
        .lsu2sram_cmd_read      (lsu2sram_cmd_read),
        .lsu2sram_cmd_addr      (lsu2sram_cmd_addr),
        .lsu2sram_cmd_wdata     (lsu2sram_cmd_wdata),
        .lsu2sram_cmd_wmask     (lsu2sram_cmd_wmask),

        .lsu2sram_rsp_vld       (lsu2sram_rsp_vld),
        .lsu2sram_rsp_rdy       (lsu2sram_rsp_rdy),
        .lsu2sram_rsp_rdata     (lsu2sram_rsp_rdata),
        .lsu2sram_rsp_err       (lsu2sram_rsp_err),

        .lsu2dtcm_cmd_vld       (),
        .lsu2dtcm_cmd_rdy       (1'b0),
        .lsu2dtcm_cmd_read      (),
        .lsu2dtcm_cmd_addr      (),
        .lsu2dtcm_cmd_wdata     (),
        .lsu2dtcm_cmd_wmask     (),

        .lsu2dtcm_rsp_vld       (1'b0),
        .lsu2dtcm_rsp_rdy       (),
        .lsu2dtcm_rsp_rdata     (),
        .lsu2dtcm_rsp_err       (),

        .lsu2biu_cmd_vld        (lsu2biu_cmd_vld),
        .lsu2biu_cmd_rdy        (lsu2biu_cmd_rdy),
        .lsu2biu_cmd_read       (lsu2biu_cmd_read),
        .lsu2biu_cmd_addr       (lsu2biu_cmd_addr),
        .lsu2biu_cmd_wdata      (lsu2biu_cmd_wdata),
        .lsu2biu_cmd_wmask      (lsu2biu_cmd_wmask),

        .lsu2biu_rsp_vld        (lsu2biu_rsp_vld),
        .lsu2biu_rsp_rdy        (lsu2biu_rsp_rdy),
        .lsu2biu_rsp_rdata      (lsu2biu_rsp_rdata),
        .lsu2biu_rsp_err        (lsu2biu_rsp_err),

        .reg_wen                (reg_wen),
        .reg_waddr              (reg_waddr),
        .reg_wdata              (reg_wdata),

        .oitf_clr_req_o         (oitf_clr_req),
        .oitf_clr_idx_o        (oitf_clr_idx),

        .timer_en               (timer_en)
    );

    wire jtag2biu_cmd_vld;
    wire jtag2biu_cmd_rdy;
    wire jtag2biu_cmd_read;
    wire [`MYRISCV_ADDRBUS] jtag2biu_cmd_addr;
    wire [`MYRISCV_DATABUS] jtag2biu_cmd_wdata;
    wire [(`MYRISCV_DATADW/8-1):0] jtag2biu_cmd_wmask;

    wire jtag2biu_rsp_vld;
    wire jtag2biu_rsp_rdy;
    wire [`MYRISCV_DATABUS] jtag2biu_rsp_rdata;
    wire jtag2biu_rsp_err;

    jtag_mem_splt jtag_mux_inst(
        .clk                        (clk),
        .rst                        (rst),

        .jtag_cmd_vld       (jtag_cmd_vld),
        .jtag_cmd_rdy       (jtag_cmd_rdy),
        .jtag_cmd_read      (jtag_cmd_read),
        .jtag_cmd_addr      (jtag_cmd_addr),
        .jtag_cmd_wdata     (jtag_cmd_wdata),
        .jtag_cmd_wmask     (jtag_cmd_wmask),

        .jtag_rsp_vld       (jtag_rsp_vld),
        .jtag_rsp_rdy       (jtag_rsp_rdy),
        .jtag_rsp_err       (jtag_rsp_err),
        .jtag_rsp_rdata     (jtag_rsp_rdata),


        .jtag2sram_cmd_vld      (jtag2sram_cmd_vld),
        .jtag2sram_cmd_rdy      (jtag2sram_cmd_rdy),
        .jtag2sram_cmd_read     (jtag2sram_cmd_read),
        .jtag2sram_cmd_addr     (jtag2sram_cmd_addr),
        .jtag2sram_cmd_wdata    (jtag2sram_cmd_wdata),
        .jtag2sram_cmd_wmask    (jtag2sram_cmd_wmask),

        .jtag2sram_rsp_vld      (jtag2sram_rsp_vld),
        .jtag2sram_rsp_rdy      (jtag2sram_rsp_rdy),
        .jtag2sram_rsp_rdata    (jtag2sram_rsp_rdata),
        .jtag2sram_rsp_err      (jtag2sram_rsp_err),

        // .jtag2dtcm_cmd_vld      (jtag2dtcm_cmd_vld),
        // .jtag2dtcm_cmd_rdy      (jtag2dtcm_cmd_rdy),
        // .jtag2dtcm_cmd_read     (jtag2dtcm_cmd_read),
        // .jtag2dtcm_cmd_addr     (jtag2dtcm_cmd_addr),
        // .jtag2dtcm_cmd_wdata    (jtag2dtcm_cmd_wdata),
        // .jtag2dtcm_cmd_wmask    (jtag2dtcm_cmd_wmask),

        // .jtag2dtcm_rsp_vld      (jtag2dtcm_rsp_vld),
        // .jtag2dtcm_rsp_rdy      (jtag2dtcm_rsp_rdy),
        // .jtag2dtcm_rsp_rdata    (jtag2dtcm_rsp_rdata),
        // .jtag2dtcm_rsp_err      (jtag2dtcm_rsp_err),

        .jtag2dtcm_cmd_vld      (),
        .jtag2dtcm_cmd_rdy      (1'b0),
        .jtag2dtcm_cmd_read     (),
        .jtag2dtcm_cmd_addr     (),
        .jtag2dtcm_cmd_wdata    (),
        .jtag2dtcm_cmd_wmask    (),
        
        .jtag2dtcm_rsp_vld      (1'b0),
        .jtag2dtcm_rsp_rdy      (),
        .jtag2dtcm_rsp_rdata    ({`MYRISCV_DATADW{1'b0}}),
        .jtag2dtcm_rsp_err      (1'b0),

        .jtag2biu_cmd_vld       (jtag2biu_cmd_vld),
        .jtag2biu_cmd_rdy       (jtag2biu_cmd_rdy),
        .jtag2biu_cmd_read      (jtag2biu_cmd_read),
        .jtag2biu_cmd_addr      (jtag2biu_cmd_addr),
        .jtag2biu_cmd_wdata     (jtag2biu_cmd_wdata),
        .jtag2biu_cmd_wmask     (jtag2biu_cmd_wmask),

        .jtag2biu_rsp_vld       (jtag2biu_rsp_vld),
        .jtag2biu_rsp_rdy       (jtag2biu_rsp_rdy),
        .jtag2biu_rsp_rdata     (jtag2biu_rsp_rdata),
        .jtag2biu_rsp_err       (jtag2biu_rsp_err)
    );

    biu_bridge biu_brg_inst(

        .biu_active                         (), //r:未使用

        // The ICB Interface from LSU 
        .lsu2biu_icb_cmd_valid              (lsu2biu_cmd_vld),
        .lsu2biu_icb_cmd_ready              (lsu2biu_cmd_rdy),
        .lsu2biu_icb_cmd_addr               (lsu2biu_cmd_addr), 
        .lsu2biu_icb_cmd_read               (lsu2biu_cmd_read),
        .lsu2biu_icb_cmd_wdata              (lsu2biu_cmd_wdata),
        .lsu2biu_icb_cmd_wmask              (lsu2biu_cmd_wmask),
        .lsu2biu_icb_cmd_burst              (2'd0),
        .lsu2biu_icb_cmd_beat               (2'd0),
        .lsu2biu_icb_cmd_lock               (1'b0),
        .lsu2biu_icb_cmd_excl               (1'b0),
        .lsu2biu_icb_cmd_size               (2'd0),

        .lsu2biu_icb_rsp_valid              (lsu2biu_rsp_vld),
        .lsu2biu_icb_rsp_ready              (lsu2biu_rsp_rdy),
        .lsu2biu_icb_rsp_err                (lsu2biu_rsp_err),
        .lsu2biu_icb_rsp_excl_ok            (),
        .lsu2biu_icb_rsp_rdata              (lsu2biu_rsp_rdata),

        `ifdef MYRISCV_HAS_MEM_ITF //{ //r:如果有mem，ifu才有访问biu的必要。
            ////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////
            // the icb interface from ifetch 
            //
            //    * bus cmd channel
            .ifu2biu_icb_cmd_valid          (ifu2biu_cmd_vld),
            .ifu2biu_icb_cmd_ready          (ifu2biu_cmd_rdy),
            .ifu2biu_icb_cmd_addr           (ifu2biu_cmd_addr),
            .ifu2biu_icb_cmd_read           (1'b1),
            .ifu2biu_icb_cmd_wdata          ({(`MYRISCV_DATADW){1'b0}}),
            .ifu2biu_icb_cmd_wmask          ({(`MYRISCV_DATADW/8){1'b0}}),
            .ifu2biu_icb_cmd_burst          (2'd0),
            .ifu2biu_icb_cmd_beat           (2'd0),
            .ifu2biu_icb_cmd_lock           (1'b0),
            .ifu2biu_icb_cmd_excl           (1'b0),
            .ifu2biu_icb_cmd_size           (2'b0),
            //
            //    * bus rsp channel
            .ifu2biu_icb_rsp_valid          (ifu2biu_rsp_vld),
            .ifu2biu_icb_rsp_ready          (ifu2biu_rsp_rdy),
            .ifu2biu_icb_rsp_err            (ifu2biu_rsp_err),
            .ifu2biu_icb_rsp_excl_ok        (),
            .ifu2biu_icb_rsp_rdata          (ifu2biu_rsp_data),

            //.ifu2biu_replay,

            .jtag2biu_icb_cmd_valid         (jtag2biu_cmd_vld),
            .jtag2biu_icb_cmd_ready         (jtag2biu_cmd_rdy),
            .jtag2biu_icb_cmd_addr          (jtag2biu_cmd_addr), 
            .jtag2biu_icb_cmd_read          (jtag2biu_cmd_read),
            .jtag2biu_icb_cmd_wdata         (jtag2biu_cmd_wdata),
            .jtag2biu_icb_cmd_wmask         (jtag2biu_cmd_wmask),
            .jtag2biu_icb_cmd_burst         (2'd0),
            .jtag2biu_icb_cmd_beat          (2'd0),
            .jtag2biu_icb_cmd_lock          (1'b0),
            .jtag2biu_icb_cmd_excl          (1'b0),
            .jtag2biu_icb_cmd_size          (2'd0),
            //
            //    * bus rsp channel
            .jtag2biu_icb_rsp_valid         (jtag2biu_rsp_vld),
            .jtag2biu_icb_rsp_ready         (jtag2biu_rsp_rdy),
            .jtag2biu_icb_rsp_err           (jtag2biu_rsp_err),
            .jtag2biu_icb_rsp_excl_ok       (),  
            .jtag2biu_icb_rsp_rdata         (jtag2biu_rsp_rdata), 
        `endif//}



        ////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////
        // The ICB Interface to Private Peripheral Interface
        //
        //   input [`MYRISCV_ADDRDW-1:0]    ppi_region_indic,
        .ppi_icb_enable                     (1'b1),
        //    * Bus cmd channel
        .ppi_icb_cmd_valid                  (ppi_icb_cmd_valid),
        .ppi_icb_cmd_ready                  (ppi_icb_cmd_ready),
        .ppi_icb_cmd_addr                   (ppi_icb_cmd_addr),
        .ppi_icb_cmd_read                   (ppi_icb_cmd_read),
        .ppi_icb_cmd_wdata                  (ppi_icb_cmd_wdata),
        .ppi_icb_cmd_wmask                  (ppi_icb_cmd_wmask),
        .ppi_icb_cmd_burst                  (),
        .ppi_icb_cmd_beat                   (), 
        .ppi_icb_cmd_lock                   (), 
        .ppi_icb_cmd_excl                   (), 
        .ppi_icb_cmd_size                   (), 
        //
        //    * Bus RSP channel
        .ppi_icb_rsp_valid                  (ppi_icb_rsp_valid), 
        .ppi_icb_rsp_ready                  (ppi_icb_rsp_ready),
        .ppi_icb_rsp_err                    (ppi_icb_rsp_err),
        .ppi_icb_rsp_excl_ok                (),
        .ppi_icb_rsp_rdata                  (ppi_icb_rsp_rdata), 

        //
        //   input [`MYRISCV_ADDRDW-1:0]    clint_region_indic,
        .clint_icb_enable                   (1'b1), 
        //    * Bus cmd channel
        .clint_icb_cmd_valid                (clint_icb_cmd_valid), 
        .clint_icb_cmd_ready               (clint_icb_cmd_ready), 
        .clint_icb_cmd_addr                (clint_icb_cmd_addr), 
        .clint_icb_cmd_read                (clint_icb_cmd_read), 
        .clint_icb_cmd_wdata               (clint_icb_cmd_wdata), 
        .clint_icb_cmd_wmask               (clint_icb_cmd_wmask), 
        .clint_icb_cmd_burst               (), 
        .clint_icb_cmd_beat                (), 
        .clint_icb_cmd_lock                (), 
        .clint_icb_cmd_excl                (), 
        .clint_icb_cmd_size                (), 
        //
        //    * Bus RSP channel
        .clint_icb_rsp_valid                  (clint_icb_rsp_valid), 
        .clint_icb_rsp_ready                  (clint_icb_rsp_ready), 
        .clint_icb_rsp_err                    (clint_icb_rsp_err), 
        .clint_icb_rsp_excl_ok                (clint_icb_rsp_excl_ok), 
        .clint_icb_rsp_rdata                  (clint_icb_rsp_rdata), 

            //
        //   input [`MYRISCV_ADDRDW-1:0]    plic_region_indic,
        .plic_icb_enable                    (1'b0), 
        //    * Bus cmd channel
        .plic_icb_cmd_valid                 (), 
        .plic_icb_cmd_ready                 (1'b0), 
        .plic_icb_cmd_addr                  (), 
        .plic_icb_cmd_read                  (), 
        .plic_icb_cmd_wdata                 (), 
        .plic_icb_cmd_wmask                 (), 
        .plic_icb_cmd_burst                 (), 
        .plic_icb_cmd_beat                  (), 
        .plic_icb_cmd_lock                  (), 
        .plic_icb_cmd_excl                  (), 
        .plic_icb_cmd_size                  (), 
        //
        //    * Bus RSP channel
        .plic_icb_rsp_valid                   (1'b0), 
        .plic_icb_rsp_ready                   (), 
        .plic_icb_rsp_err                     (), 
        .plic_icb_rsp_excl_ok                 (), 
        .plic_icb_rsp_rdata                   (), 


        `ifdef MYRISCV_HAS_FIO //{
            ////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////
            // The ICB Interface to Fast I/O
            //   input [`MYRISCV_ADDRDW-1:0]    fio_region_indic,
            .fio_icb_enable                     (1'b0), 
            //
            //    * Bus cmd channel
            .fio_icb_cmd_valid                   (), 
            .fio_icb_cmd_ready                   (1'b0), 
            .fio_icb_cmd_addr                    (), 
            .fio_icb_cmd_read                    (),  
            .fio_icb_cmd_wdata                   (), 
            .fio_icb_cmd_wmask                   (), 
            .fio_icb_cmd_burst                   (), 
            .fio_icb_cmd_beat                   (), 
            .fio_icb_cmd_lock                   (), 
            .fio_icb_cmd_excl                   (), 
            .fio_icb_cmd_size                   (), 
            //
            //    * Bus RSP channel
            .fio_icb_rsp_valid                   (1'b0), 
            .fio_icb_rsp_ready                   (), 
            .fio_icb_rsp_err                     (), 
            .fio_icb_rsp_excl_ok                 (), 
            .fio_icb_rsp_rdata                   (), 
        `endif//}

        `ifdef MYRISCV_HAS_MEM_ITF //{
            ////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////
            // The ICB Interface from Ifetch zxp:写错了吧，应该是to mem 
            //
            .mem_icb_enable                     (1'b1),
            //    * Bus cmd channel
            .mem_icb_cmd_valid                  (mem_icb_cmd_vld),
            .mem_icb_cmd_ready                  (mem_icb_cmd_rdy),
            .mem_icb_cmd_addr                   (mem_icb_cmd_addr),
            .mem_icb_cmd_read                   (mem_icb_cmd_read),
            .mem_icb_cmd_wdata                  (mem_icb_cmd_wdata),
            .mem_icb_cmd_wmask                  (mem_icb_cmd_wmask),
            .mem_icb_cmd_burst                  (),
            .mem_icb_cmd_beat                   (),
            .mem_icb_cmd_lock                   (),
            .mem_icb_cmd_excl                   (),
            .mem_icb_cmd_size                   (),
            //
            //    * Bus RSP channel
            .mem_icb_rsp_valid                  (mem_icb_rsp_vld),
            .mem_icb_rsp_ready                  (mem_icb_rsp_rdy),
            .mem_icb_rsp_err                    (mem_icb_rsp_err),
            .mem_icb_rsp_excl_ok                (),
            .mem_icb_rsp_rdata                  (mem_icb_rsp_rdata),
        `endif//}
 
        .clk                                    (clk),
        .rst                                    (rst)
    );


endmodule
