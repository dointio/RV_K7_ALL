`include "mydefines.v"
`include "e203_defines.v"

module dec2exu(
    clk, 
    rst,

    dec2ex_vld_i,
    dec2ex_rdy_i,
    `ifdef PLATFORM_SIM
        dec2ex_instr_i,
    `endif
    dec2ex_pc_i,
    dec2ex_rs1_idx_i,
    dec2ex_rs2_idx_i,
    dec2ex_rs1_i,
    dec2ex_rs2_i,
    dec2ex_imm_i,
    // dec2ex_rs1_jump_i,
    // dec2ex_rs2_jump_i,
    dec2ex_rdwen_i,
    dec2ex_rdidx_i,
    dec2ex_info_i,
    // dec2ex_csr_we_i,
    // dec2ex_csr_waddr_i,
    // dec2ex_csr_rdata_i,
    // dec2ex_prdt_taken_i,

    dec2ex_vld_o,
    dec2ex_rdy_o,
    dec2ex_rs1_idx_o,
    dec2ex_rs2_idx_o,
    dec2ex_rs1_o,
    dec2ex_rs2_o,
    `ifdef PLATFORM_SIM
        dec2ex_instr_o,
    `endif
    dec2ex_pc_o,
    dec2ex_imm_o,
    // dec2ex_rs1_jump_o,
    // dec2ex_rs2_jump_o,
    dec2ex_rdwen_o,
    dec2ex_rdidx_o,
    dec2ex_info_o,
    // dec2ex_csr_we_o,
    // dec2ex_csr_waddr_o,
    // dec2ex_csr_rdata_o,
    // dec2ex_prdt_taken_o,

    jump_flag_i
);



    input clk; 
    input rst;

    input wire dec2ex_vld_i;
    output wire  dec2ex_rdy_i;
    `ifdef PLATFORM_SIM
        input wire [`MYRISCV_INSTBUS] dec2ex_instr_i;         // 指令内容
    `endif
    input wire [`MYRISCV_ADDRBUS] dec2ex_pc_i;    // 指令地址
    input wire [`MYRISCV_REGADDRBUS] dec2ex_rs1_idx_i;
    input wire [`MYRISCV_REGADDRBUS] dec2ex_rs2_idx_i;
    input wire [`MYRISCV_REGBUS] dec2ex_rs1_i;
    input wire [`MYRISCV_REGBUS] dec2ex_rs2_i;
    input wire [`MYRISCV_REGBUS] dec2ex_imm_i;
    // input wire [`MYRISCV_REGBUS] dec2ex_rs1_jump_i;
    // input wire [`MYRISCV_REGBUS] dec2ex_rs2_jump_i;
    input wire dec2ex_rdwen_i;                     // 写通用寄存器标志
    input wire [`MYRISCV_REGADDRBUS] dec2ex_rdidx_i;     // 写通用寄存器地址
    input wire [`E203_DECINFO_WIDTH-1 : 0] dec2ex_info_i;
    // input wire dec2ex_csr_we_i;                     // 写CSR寄存器标志
    // input wire [`CSRAddrBus] dec2ex_csr_waddr_i;      // 写CSR寄存器地址
    // input wire [`MYRISCV_REGBUS] dec2ex_csr_rdata_i;
    // input wire dec2ex_prdt_taken_i;

    output reg dec2ex_vld_o;
    input wire dec2ex_rdy_o;
    `ifdef PLATFORM_SIM
        output reg [`MYRISCV_INSTBUS] dec2ex_instr_o;         // 指令内容
    `endif
    output reg [`MYRISCV_ADDRBUS] dec2ex_pc_o;    // 指令地址
    output reg [`MYRISCV_REGADDRBUS] dec2ex_rs1_idx_o;
    output reg [`MYRISCV_REGADDRBUS] dec2ex_rs2_idx_o;
    output reg [`MYRISCV_REGBUS] dec2ex_rs1_o;
    output reg [`MYRISCV_REGBUS] dec2ex_rs2_o;
    output reg [`MYRISCV_REGBUS] dec2ex_imm_o;
    // output reg[`MYRISCV_REGBUS] dec2ex_rs1_jump_o;
    // output reg[`MYRISCV_REGBUS] dec2ex_rs2_jump_o;
    output reg dec2ex_rdwen_o;                     // 写通用寄存器标志
    output reg [`MYRISCV_REGADDRBUS] dec2ex_rdidx_o;     // 写通用寄存器地址
    output reg [`E203_DECINFO_WIDTH-1 : 0] dec2ex_info_o;
    // output reg dec2ex_csr_we_o;                     // 写CSR寄存器标志
    // output reg [`CSRAddrBus] dec2ex_csr_waddr_o;      // 写CSR寄存器地址
    // output reg [`MYRISCV_REGBUS] dec2ex_csr_rdata_o;
    // output reg dec2ex_prdt_taken_o;

    input wire jump_flag_i;

    assign dec2ex_rdy_i = dec2ex_rdy_o | (~dec2ex_vld_o);
    always@(posedge clk /*or negedge rst*/) begin
        if(!rst) begin
            dec2ex_vld_o <= 0;
        end
        else if(jump_flag_i) begin
            // dec2ex_vld_o <= 0;
            if(dec2ex_vld_o & (~dec2ex_rdy_o)) begin 
            //发生这种情况，就是外部或定时器中断跳转，且同一时间ex中有条长指令在等待。
            //为了简化设计（不用回去刷掉oitf），同时仍符合正常逻辑，此时不会刷掉长指令。
                dec2ex_vld_o <= 1;
            end
            else begin
                dec2ex_vld_o <= 0;
            end
        end
        else if(dec2ex_rdy_i) begin
            dec2ex_vld_o <= dec2ex_vld_i;
        end
    end

    always@(posedge clk /*or negedge rst*/) begin
        if(!rst) begin
            `ifdef PLATFORM_SIM
                dec2ex_instr_o <= 0;
            `endif
            dec2ex_pc_o <= 0;
            dec2ex_rs1_idx_o <= 0;
            dec2ex_rs2_idx_o <= 0;
            dec2ex_rs1_o <= 0;
            dec2ex_rs2_o <= 0;
            dec2ex_imm_o <= 0;
            dec2ex_rdwen_o <= 0;
            dec2ex_rdidx_o <= 0;
            dec2ex_info_o <= 0;
        end
        else if(jump_flag_i & dec2ex_vld_o & (~dec2ex_rdy_o)) begin
            //保持输出不变
        end
        else if(dec2ex_rdy_i && dec2ex_vld_i) begin
            `ifdef PLATFORM_SIM
                dec2ex_instr_o <= dec2ex_instr_i;
            `endif
            dec2ex_pc_o <= dec2ex_pc_i;
            dec2ex_rs1_idx_o <= dec2ex_rs1_idx_i;
            dec2ex_rs2_idx_o <= dec2ex_rs2_idx_i;
            dec2ex_rs1_o <= dec2ex_rs1_i;
            dec2ex_rs2_o <= dec2ex_rs2_i;
            dec2ex_imm_o <= dec2ex_imm_i;
            // dec2ex_rs1_jump_o <= dec2ex_rs1_jump_i;
            // dec2ex_rs2_jump_o <= dec2ex_rs2_jump_i;
            dec2ex_rdwen_o <= dec2ex_rdwen_i;
            dec2ex_rdidx_o <= dec2ex_rdidx_i;
            // dec2ex_csr_we_o <= dec2ex_csr_we_i;
            // dec2ex_csr_waddr_o <= dec2ex_csr_waddr_i;
            // dec2ex_csr_rdata_o <= dec2ex_csr_rdata_i;
            // dec2ex_prdt_taken_o <= dec2ex_prdt_taken_i;
            dec2ex_info_o <= dec2ex_info_i;
        end
    end

endmodule
