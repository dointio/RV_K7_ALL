`include "mydefines.v"

//this module limit max one instr req in memory

module instrChal
(
    clk,
    rst,    

    pcside_req_vld,
    pcside_req_rdy,
    pcside_req_addr,

    pcside_rsp_vld,
    pcside_rsp_rdy,
    pcside_rsp_instr,
    pcside_rsp_err,

    memside_req_vld,
    memside_req_rdy,
    memside_req_addr,

    memside_rsp_vld,
    memside_rsp_rdy,
    memside_rsp_data,
    memside_rsp_err
);

    input clk, rst;

    input pcside_req_vld;
    output pcside_req_rdy;
    input [`MYRISCV_ADDRBUS] pcside_req_addr;

    output pcside_rsp_vld;
    input pcside_rsp_rdy;
    output [`MYRISCV_INSTBUS] pcside_rsp_instr;
    output pcside_rsp_err;

    output memside_req_vld;
    input memside_req_rdy;
    output [`MYRISCV_ADDRBUS] memside_req_addr;

    input memside_rsp_vld;
    output memside_rsp_rdy;
    input [`MYRISCV_DATABUS] memside_rsp_data;
    input memside_rsp_err;


    assign pcside_rsp_vld = memside_rsp_vld;
    assign memside_rsp_rdy = pcside_rsp_rdy;

    assign pcside_rsp_err = memside_rsp_err;
    wire rsp_handshake = pcside_rsp_vld & pcside_rsp_rdy;
    wire req_handshake = pcside_req_vld & pcside_req_rdy;

    wire waitData;
    wire needWait = waitData & (~rsp_handshake);
    
    assign memside_req_addr = pcside_req_addr;
    assign memside_req_vld = pcside_req_vld & (~needWait);
    assign pcside_req_rdy = memside_req_rdy & (~needWait);
    
    reg_enrs #(1, 0, "instrChal_reg") reg_inst (
        clk,
        rst,
        ~needWait, //r: don't support req and rsp in one cycle !
        // (~needWait) & ~(req_handshake & rsp_handshake), //r: support req and rsp in one cycle! will lead to loop with bpu!
        req_handshake,
        waitData
    );

`ifdef MYRISCV_ARCH_64
    wire instr_offset_r; //1:h, 0:l
    reg_enrs #(1, 0, "instrChal_reg2") reg2_inst (
        clk,
        rst,
        req_handshake, //r:don't support req and rsp in one cycle!
        // req_handshake & ~(rsp_handshake & ~waitData), //r: support req and rsp in one cycle!  will lead to loop with bpu!
        pcside_req_addr[2],
        instr_offset_r
    );
    wire instr_offset = instr_offset_r;
    // wire instr_offset = waitData ? instr_offset_r : pcside_req_addr[2];
    assign pcside_rsp_instr = instr_offset ? memside_rsp_data[63:32] : memside_rsp_data[31:0];
`else
    assign pcside_rsp_instr = memside_rsp_data;
`endif


endmodule
