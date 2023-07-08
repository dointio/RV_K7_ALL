`include "mydefines.v"

module pc2dec
(
    clk,
    rst,

    jump_flag_i,

    if2dec_vld_i,
    if2dec_rdy_i,
    if2dec_instr_i,
    if2dec_pc_i,
    if2dec_pc_j_i,
    if2dec_prdt_taken_i,

    if2dec_vld_o,
    if2dec_rdy_o,
    if2dec_instr_o,
    if2dec_pc_o,
    if2dec_prdt_taken_o
);


    //pc outer buf
    input clk, rst;

    input jump_flag_i;
    
    input if2dec_vld_i;
    output if2dec_rdy_i;
    input [`MYRISCV_INSTBUS] if2dec_instr_i;
    input [`MYRISCV_ADDRBUS] if2dec_pc_i;
    input if2dec_pc_j_i;
    input if2dec_prdt_taken_i;

    output reg if2dec_vld_o;
    input if2dec_rdy_o;
    output reg [`MYRISCV_INSTBUS] if2dec_instr_o;
    output reg [`MYRISCV_ADDRBUS] if2dec_pc_o;
    output reg if2dec_prdt_taken_o;

    assign if2dec_rdy_i = if2dec_rdy_o | ~if2dec_vld_o;
    always@(posedge clk /*or negedge rst*/)
    begin
        if(!rst) begin
            if2dec_vld_o <= 0;
        end
        else if(jump_flag_i) begin
            if2dec_vld_o <= 0;
        end
        else if(if2dec_rdy_i)begin
            if2dec_vld_o <= if2dec_vld_i & (~if2dec_pc_j_i);
        end
    end
    //特殊处理，如果输入vld无效，就别费事了，直接输出不变降低功耗。
    always@(posedge clk /*or negedge rst*/)
    begin
        if(!rst) begin
            if2dec_pc_o <= 0;
            if2dec_instr_o <= 0;
            if2dec_prdt_taken_o <= 0;
        end
        else if(if2dec_rdy_i && if2dec_vld_i && (~if2dec_pc_j_i))begin
            if2dec_pc_o <= if2dec_pc_i;
            if2dec_instr_o <= if2dec_instr_i;
            if2dec_prdt_taken_o <= if2dec_prdt_taken_i;
        end
    end

    // assign icache_rsp_rdy = pc_outer_rdy | jump_flag_i;

endmodule
