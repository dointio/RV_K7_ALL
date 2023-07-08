// 执行模块
// 纯组合逻辑电路
`include "e203_defines.v"
module new_disp(
    dec2ex_vld,
    dec2ex_rdy,

    // from dec
    op_select,

    disp2alu_vld,
    disp2alu_rdy,

    disp2lsu_vld,
    disp2lsu_rdy,

    disp2muldiv_vld,
    disp2muldiv_rdy,
    `ifdef MYRISCV_HAS_NICE
        disp2nice_vld,
        disp2nice_rdy,
    `endif
    halt_req,
    jump_req_nodelay//r: after reg!!!

    );


    input wire  dec2ex_vld;
    output wire dec2ex_rdy;

    // from dec
    input [`MY_DECINFO_GRP_WIDTH-1 : 0] op_select;

    output wire disp2alu_vld;
    input wire disp2alu_rdy;

    output wire disp2lsu_vld;
    input wire disp2lsu_rdy;

    output wire disp2muldiv_vld;
    input wire disp2muldiv_rdy;

    `ifdef MYRISCV_HAS_NICE
    output wire disp2nice_vld;
    input wire disp2nice_rdy;
    `endif

    input wire halt_req;
    input wire jump_req_nodelay;//r: after reg!!!

    wire dec2ex_vld_true = dec2ex_vld & (~halt_req) & (~jump_req_nodelay);

    wire select_alu = (op_select == `MY_DECINFO_GRP_ALU) 
                        || (op_select == `MY_DECINFO_GRP_BJP)
                        || (op_select == `MY_DECINFO_GRP_CSR);
    wire select_lsu = (op_select == `MY_DECINFO_GRP_AGU);
    wire select_muldiv = (op_select == `MY_DECINFO_GRP_MULDIV);
    `ifdef MYRISCV_HAS_NICE
    wire select_nice = (op_select == `MY_DECINFO_GRP_NICE);
    `endif
    assign disp2alu_vld = select_alu ? dec2ex_vld_true : 1'b0;
    assign disp2lsu_vld = (op_select == `MY_DECINFO_GRP_AGU) ? dec2ex_vld_true : 1'b0;
    assign disp2muldiv_vld = (op_select == `MY_DECINFO_GRP_MULDIV) ? dec2ex_vld_true : 1'b0;
    `ifdef MYRISCV_HAS_NICE
    assign disp2nice_vld = (op_select == `MY_DECINFO_GRP_NICE) ? dec2ex_vld_true : 1'b0;
    `endif
    assign dec2ex_rdy = (
                        (select_alu & disp2alu_rdy) 
                        || (select_lsu & disp2lsu_rdy)
                        || (select_muldiv & disp2muldiv_rdy)
                        `ifdef MYRISCV_HAS_NICE
                        || (select_nice & disp2nice_rdy)
                        `endif
                        ) & (~halt_req);
  
endmodule
