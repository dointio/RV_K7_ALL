`include "mydefines.v"
module ifu
(
    clk,
    rst,

    jmp_req_i,
    jmp_addr_i,

    
    ifu_prdt_taken_o,
    ifu_pc_o,
    ifu_vld_o,
    ifu_rdy_o,
    ifu_instr_o,
    ifu_err_o,

    ifu_req_vld,
    ifu_req_rdy,
    ifu_req_addr,

    ifu_rsp_vld,
    ifu_rsp_rdy,
    ifu_rsp_data,
    ifu_rsp_err
);

    input clk,rst;

    input jmp_req_i;
    input [`MYRISCV_ADDRBUS] jmp_addr_i;

    
    output ifu_vld_o;
    input ifu_rdy_o;
    output ifu_prdt_taken_o;
    output [`MYRISCV_ADDRBUS] ifu_pc_o;
    output [`MYRISCV_INSTBUS] ifu_instr_o;
    output ifu_err_o;

    output ifu_req_vld;
    input ifu_req_rdy;
    output [`MYRISCV_ADDRBUS] ifu_req_addr;

    input ifu_rsp_vld;
    output ifu_rsp_rdy;
    input [`MYRISCV_DATABUS] ifu_rsp_data;
    input ifu_rsp_err;



    wire [`MYRISCV_ADDRBUS] bpu_jump_op1;
    wire [`MYRISCV_ADDRBUS] bpu_jump_op2;
    wire pc_has_jump;
    //g: connect to instr channel(start)
    wire [`MYRISCV_ADDRBUS] pcside_req_addr_w;
    wire pcside_req_vld_w;
    wire pcside_req_rdy_w;
    wire pcside_rsp_vld_w;
    wire pcside_rsp_rdy_w;
    wire [`MYRISCV_INSTBUS] pcside_rsp_instr_w;
    wire pcside_rsp_err_w;
    //g: connect to instr channel(end)
    assign ifu_vld_o = pcside_rsp_vld_w & (~pc_has_jump);
    // assign ifu_rdy_o = pcside_rsp_rdy_w | pc_has_jump;
    assign pcside_rsp_rdy_w = ifu_rdy_o | pc_has_jump;
    assign ifu_instr_o = pcside_rsp_instr_w;
    assign ifu_err_o = pcside_rsp_err_w;

    pc pc_inst
    (
        .clk    (clk),
        .rst    (rst),

        .dec_rdy                (ifu_rdy_o),

        .jump_flag_i            (jmp_req_i),
        .jump_addr_i            (jmp_addr_i),

        .bpu_prdt_taken         (ifu_prdt_taken_o),
        .bpu_jump_op1           (bpu_jump_op1),
        .bpu_jump_op2           (bpu_jump_op2),

        .pc_has_jump_o          (pc_has_jump),
        .pc_o                   (ifu_pc_o),

        .instr_req_pc       (pcside_req_addr_w),
        .instr_req_vld      (pcside_req_vld_w),
        .instr_req_rdy      (pcside_req_rdy_w)
    );

    bpu bpu_inst
    (   
        .clk            (clk),
        .rst            (rst),
        // from pc
        // .bpu_pc_i             (icache_rsp_pc),             // 指令内容
        // .bpu_pc_i               (pc_o),
        .bpu_pc_i               (ifu_pc_o),
        // .bpu_ins_i              (icache_rsp_ins),    // 指令地址
        .bpu_ins_i              (ifu_instr_o),

        // .icache_rsp_vld         (icache_rsp_vld),
        .instr_rsp_vld          (pcside_rsp_vld_w),

        .bpu_prdt_taken_o       (ifu_prdt_taken_o),
        .bpu_jump_op1           (bpu_jump_op1),
        .bpu_jump_op2           (bpu_jump_op2)
    );

    //g: connect to instr channel(start)
    wire memside_req_vld_w;
    wire memside_req_rdy_w;
    wire [`MYRISCV_ADDRBUS] memside_req_addr_w;

    wire memside_rsp_vld_w;
    wire memside_rsp_rdy_w;
    wire [`MYRISCV_DATABUS] memside_rsp_data_w;
    wire memside_rsp_err_w;
    //g: connect to instr channel(end)
    assign ifu_req_vld = memside_req_vld_w;
    assign memside_req_rdy_w = ifu_req_rdy;
    assign ifu_req_addr = memside_req_addr_w;

    instrChal instrChal_inst
    (
        .clk                (clk),
        .rst                (rst),    

        .pcside_req_vld     (pcside_req_vld_w),
        .pcside_req_rdy     (pcside_req_rdy_w),
        .pcside_req_addr    (pcside_req_addr_w),

        .pcside_rsp_vld     (pcside_rsp_vld_w),
        .pcside_rsp_rdy     (pcside_rsp_rdy_w),
        .pcside_rsp_instr   (pcside_rsp_instr_w),
        .pcside_rsp_err     (pcside_rsp_err_w),

        .memside_req_vld        (memside_req_vld_w),
        .memside_req_rdy        (memside_req_rdy_w),
        .memside_req_addr       (memside_req_addr_w),

        .memside_rsp_vld        (memside_rsp_vld_w),
        .memside_rsp_rdy        (memside_rsp_rdy_w),
        .memside_rsp_data       (memside_rsp_data_w),
        .memside_rsp_err        (memside_rsp_err_w)
    );


    bypbuf # ( //就是带旁路功能的fifo，因为写入fifo再读出fifo，中间是有触发器延时的，
               //而如果fifo为空的同时写入和读出同时发生，为了加速，会直接旁路fifo！
        .DP(1),
        .DW(`MYRISCV_DATADW+1) 
    ) ifu2mem_bypbuf(
        .clk        (clk),
        .rst        (rst),

        .i_vld      (ifu_rsp_vld),
        .i_rdy      (ifu_rsp_rdy),

        .o_vld      (memside_rsp_vld_w),
        .o_rdy      (memside_rsp_rdy_w),

        .data_i     ({ifu_rsp_data, ifu_rsp_err}),
        .data_o     ({memside_rsp_data_w, memside_rsp_err_w})
    );



endmodule
