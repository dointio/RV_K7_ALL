`include "mydefines.v"

module bpu
(
    clk,
    rst,

    //connect pc
    bpu_pc_i,
    bpu_ins_i,

    // reg1_raddr_o,
    // reg1_rdata_i,
    instr_rsp_vld,
    // icache_rsp_rdy,

    bpu_prdt_taken_o,
    bpu_jump_op1,
    bpu_jump_op2
);

    input clk, rst;
    input [`MYRISCV_ADDRBUS] bpu_pc_i;
    input [`MYRISCV_INSTBUS] bpu_ins_i;

    input instr_rsp_vld;
    
    output bpu_prdt_taken_o;
    // output [`MYRISCV_ADDRBUS] bpu_jump_addr_o;
    output [`MYRISCV_ADDRBUS] bpu_jump_op1;
    output [`MYRISCV_ADDRBUS] bpu_jump_op2;

    // wire if2dec_ins;             // 指令内容
    // wire if2dec_pc;    // 指令地址

    // connect regs
    // input [`MYRISCV_REGBUS] reg1_rdata_i;        // 通用寄存器1输入数据
    // output [`MYRISCV_REGADDRBUS] reg1_raddr_o;    // 读通用寄存器1地址

    wire dec_bjp;
    wire dec_jal;
    wire dec_jalr;
    wire dec_bxx;

    wire [`MYRISCV_ADDRBUS] op_w1;
    wire [`MYRISCV_ADDRBUS] op_w2;

    minidec minidec_inst
    (
        .if2dec_ins     (bpu_ins_i),
        .if2dec_pc      (bpu_pc_i),

        // connect regs
        // .reg1_rdata_i (reg1_rdata_i),        // 通用寄存器1输入数据
        // .reg1_raddr_o (reg1_raddr_o),    // 读通用寄存器1地址


        .dec_bjp        (dec_bjp),
        .dec_jal        (dec_jal),
        .dec_jalr       (dec_jalr),
        .dec_bxx        (dec_bxx),

        // to ex
        .dec2ex_op1_jump (op_w1),
        .dec2ex_op2_jump (op_w2)
    );

    reg bpu_prdt_r;
    reg [`MYRISCV_ADDRBUS] op_r1;
    reg [`MYRISCV_ADDRBUS] op_r2;
    assign bpu_prdt_taken_o = instr_rsp_vld ? 
        ((dec_jal) || (dec_bxx && (bpu_jump_op2[31]))) 
        : bpu_prdt_r;
    assign bpu_jump_op1 = instr_rsp_vld ? op_w1 : op_r1;
    assign bpu_jump_op2 = instr_rsp_vld ? op_w2 : op_r2;

    //buffer current predet!
    //r: why? because read channel may be used by lsu!!! and instr is read to dec!!!
    always@(posedge clk) begin
        if(rst == `RSTLEVEL)  begin
            bpu_prdt_r <= 0;
            op_r1 <= 0;
            op_r2 <= 0;
        end
        else if(instr_rsp_vld) begin
            bpu_prdt_r <= bpu_prdt_taken_o;
            op_r1 <= op_w1;
            op_r2 <= op_w2;
        end
    end
    

endmodule
