`include "mydefines.v"
module minidec (

    // from pc
    if2dec_ins,             // 指令内容
    if2dec_pc,    // 指令地址

    // connect regs
    // reg1_rdata_i,        // 通用寄存器1输入数据
    // reg1_raddr_o,    // 读通用寄存器1地址

    dec2ex_op1_jump,
    dec2ex_op2_jump,

    dec_bjp,
    dec_jal,
    dec_jalr,
    dec_bxx
    );

    input wire[`MYRISCV_INSTBUS] if2dec_ins;             // 指令内容
    input wire[`MYRISCV_ADDRBUS] if2dec_pc;    // 指令地址

    // connect regs
    // input wire[`MYRISCV_REGBUS] reg1_rdata_i,        // 通用寄存器1输入数据
    // output wire [`MYRISCV_REGADDRBUS] reg1_raddr_o,    // 读通用寄存器1地址

    output wire [`MYRISCV_REGBUS] dec2ex_op1_jump;
    output wire [`MYRISCV_REGBUS] dec2ex_op2_jump;

    output dec_bjp;
    output dec_jal;
    output dec_jalr;
    output dec_bxx;

    wire [`MYRISCV_REGBUS] dec_imm;
    
    assign dec2ex_op1_jump = {{(`MYRISCV_XLEN-`MYRISCV_ADDRDW){1'b0}}, if2dec_pc};
    assign dec2ex_op2_jump = dec_imm;

    dec decode_inst_mini
    (
        .if2dec_instr     (if2dec_ins),
        .if2dec_pc      (if2dec_pc),

        // connect regs
        // .reg1_rdata_i (reg1_rdata_i),        // 通用寄存器1输入数据
        // .reg1_raddr_o (reg1_raddr_o),    // 读通用寄存器1地址


        .dec_bjp        (dec_bjp),
        .dec_jal        (dec_jal),
        .dec_jalr       (dec_jalr),
        .dec_bxx        (dec_bxx),

        // to ex
        // .dec2ex_op1_jump (dec2ex_op1_jump),
        // .dec2ex_op2_jump (dec2ex_op2_jump)
        .dec2ex_imm     (dec_imm)
    );

endmodule
