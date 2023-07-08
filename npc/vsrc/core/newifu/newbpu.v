`include "mydefines.v"

module newbpu
(
    clk,
    rst,

    //connect pc
    bpu_pc_i,
    bpu_ins_i,

    pc_req_vld_mi,
    pc_req_rdy_mi,

    pc_rsp_vld_i,
    pc_rsp_rdy_i,

    pc_rsp_vld_o,
    pc_rsp_rdy_o,

    bpu_prdt_taken_r_o,
    bpu_prdt_taken_o,
    bpu_jump_op1,
    bpu_jump_op2
);

    input clk, rst;
    input [`MYRISCV_ADDRBUS] bpu_pc_i;
    input [`MYRISCV_INSTBUS] bpu_ins_i;
    
    input pc_req_vld_mi;
    input pc_req_rdy_mi;

    input   pc_rsp_vld_i;
    output  pc_rsp_rdy_i;
    output  pc_rsp_vld_o;
    input   pc_rsp_rdy_o;

    output bpu_prdt_taken_r_o;
    output bpu_prdt_taken_o;
    output [`MYRISCV_ADDRBUS] bpu_jump_op1;
    output [`MYRISCV_ADDRBUS] bpu_jump_op2;

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

        .dec_bjp        (dec_bjp),
        .dec_jal        (dec_jal),
        .dec_jalr       (dec_jalr),
        .dec_bxx        (dec_bxx),

        // to ex
        .dec2ex_op1_jump (op_w1),
        .dec2ex_op2_jump (op_w2)
    );

    wire bpu_prdt_taken = ((dec_jal) || (dec_bxx && (op_w2[31])));

    reg taken_r;
    reg [`MYRISCV_ADDRBUS] op1_r;
    reg [`MYRISCV_ADDRBUS] op2_r;
    always@(posedge clk) begin
        if(rst == `RSTLEVEL) begin
            taken_r <= 0;
        end
        else if(pc_req_vld_mi & pc_req_rdy_mi & taken_r) begin
            taken_r <= 0;
        end
        else if(pc_rsp_vld_o & pc_rsp_rdy_o) begin
            taken_r <= bpu_prdt_taken;
        end
    end

    always@(posedge clk) begin
        if(pc_rsp_vld_o & pc_rsp_rdy_o & bpu_prdt_taken) begin
            op1_r <= op_w1;
            op2_r <= op_w2;
        end
    end

    assign pc_rsp_vld_o = taken_r ? 1'b0 : pc_rsp_vld_i;
    assign pc_rsp_rdy_i = taken_r ? 1'b1 : pc_rsp_rdy_o;

    assign bpu_prdt_taken_r_o = taken_r;
    assign bpu_jump_op1 = op1_r;
    assign bpu_jump_op2 = op2_r;
    assign bpu_prdt_taken_o = /*pc_rsp_vld_o & pc_rsp_rdy_o &*/ bpu_prdt_taken;

endmodule
