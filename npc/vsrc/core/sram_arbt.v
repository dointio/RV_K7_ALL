`include "mydefines.v"
module sram_arbt
(
    clk,
    rst,

    pc_cmd_vld,
    pc_cmd_rdy,
    pc_cmd_addr,
    // pc_cmd_read, // =1
    // pc_cmd_wdata, //=0
    // pc_cmd_wmask, //=0

    pc_rsp_vld,
    pc_rsp_rdy,
    pc_rsp_err, //dont us
    // pc_rsp_addr, 
    pc_rsp_rdata,

    ext_cmd_vld,
    ext_cmd_rdy,
    ext_cmd_addr,
    ext_cmd_read,
    ext_cmd_wdata,
    ext_cmd_wmask,

    ext_rsp_vld,
    ext_rsp_rdy,
    ext_rsp_err, 
    ext_rsp_rdata,

    lsu_cmd_vld,
    lsu_cmd_rdy,
    lsu_cmd_addr,
    lsu_cmd_read,
    lsu_cmd_wdata,
    lsu_cmd_wmask,

    lsu_rsp_vld,
    lsu_rsp_rdy,
    lsu_rsp_err,
    lsu_rsp_rdata,


    sram_cmd_vld,
    sram_cmd_rdy,
    sram_cmd_addr,
    sram_cmd_read,
    sram_cmd_wdata,
    sram_cmd_wmask,
    // sram_cmd_org,

    sram_rsp_vld,
    sram_rsp_rdy,
    sram_rsp_err,
    sram_rsp_rdata//,
    // sram_rsp_org
);
    input clk, rst;

    input pc_cmd_vld;
    output pc_cmd_rdy;
    input [`MYRISCV_ADDRBUS] pc_cmd_addr;

    output pc_rsp_vld;
    input pc_rsp_rdy;
    // output [3:0] pc_rsp_err; //dont us
    output pc_rsp_err;
    // output [`MYRISCV_ADDRBUS] pc_rsp_addr; 
    output [`MYRISCV_DATABUS] pc_rsp_rdata;

    input ext_cmd_vld;
    output ext_cmd_rdy;
    input [`MYRISCV_ADDRBUS] ext_cmd_addr;
    input ext_cmd_read;
    input [`MYRISCV_DATABUS] ext_cmd_wdata;
    input [(`MYRISCV_DATADW/8-1):0] ext_cmd_wmask;

    output ext_rsp_vld;
    input ext_rsp_rdy;
    output ext_rsp_err;
    output [`MYRISCV_DATABUS] ext_rsp_rdata;

    input lsu_cmd_vld;
    output lsu_cmd_rdy;
    input [`MYRISCV_ADDRBUS] lsu_cmd_addr;
    input lsu_cmd_read;
    input [`MYRISCV_DATABUS] lsu_cmd_wdata;
    input [(`MYRISCV_DATADW/8-1):0] lsu_cmd_wmask;

    output lsu_rsp_vld;
    input lsu_rsp_rdy;
    output lsu_rsp_err;
    output [`MYRISCV_DATABUS] lsu_rsp_rdata;

    output sram_cmd_vld;
    input sram_cmd_rdy;
    output [`MYRISCV_ADDRBUS] sram_cmd_addr;
    output sram_cmd_read;
    output [`MYRISCV_DATABUS] sram_cmd_wdata;
    output [(`MYRISCV_DATADW/8-1):0] sram_cmd_wmask;
    // input [1:0] sram_cmd_org;

    input sram_rsp_vld;
    output sram_rsp_rdy;
    input sram_rsp_err;
    input [`MYRISCV_DATABUS] sram_rsp_rdata;
    // output [1:0] sram_rsp_org;


    //exu, excl, pc
    // `define ITCM_SELECT_PC  2'b01
    // `define ITCM_SELECT_LSU 2'b10
    // `define ITCM_SELECT_EXT 2'b11

    // wire [1:0] connect= ext_cmd_vld ? `ITCM_SELECT_EXT : (lsu_cmd_vld ? `ITCM_SELECT_LSU : `ITCM_SELECT_PC);
    wire [1:0] connect = lsu_cmd_vld ? `ITCM_SELECT_LSU : (pc_cmd_vld ? `ITCM_SELECT_PC : (ext_cmd_vld ? `ITCM_SELECT_EXT : `ITCM_SELECT_PC));

    assign sram_cmd_vld = (connect== `ITCM_SELECT_EXT) ? ext_cmd_vld : (connect== `ITCM_SELECT_LSU ? lsu_cmd_vld : pc_cmd_vld);
    assign sram_cmd_addr = (connect== `ITCM_SELECT_EXT) ? ext_cmd_addr : (connect== `ITCM_SELECT_LSU ? lsu_cmd_addr : pc_cmd_addr);
    assign sram_cmd_read = (connect == `ITCM_SELECT_EXT) ? ext_cmd_read : (connect == `ITCM_SELECT_LSU ? lsu_cmd_read : 1'b1);
    assign sram_cmd_wdata = (connect == `ITCM_SELECT_EXT) ? ext_cmd_wdata : (connect == `ITCM_SELECT_LSU ? lsu_cmd_wdata : {(`MYRISCV_DATADW){1'b0}});
    assign sram_cmd_wmask = (connect == `ITCM_SELECT_EXT) ? ext_cmd_wmask : (connect == `ITCM_SELECT_LSU ? lsu_cmd_wmask : {(`MYRISCV_DATADW/8){1'b0}});
    assign ext_cmd_rdy = (connect==`ITCM_SELECT_EXT) ? sram_cmd_rdy : 1'b0;
    assign lsu_cmd_rdy = (connect==`ITCM_SELECT_LSU) ? sram_cmd_rdy : 1'b0;
    assign pc_cmd_rdy = (connect == `ITCM_SELECT_PC) ? sram_cmd_rdy : 1'b0;


    reg [1:0] connect_r;
    always@(posedge clk /*or negedge rst*/) begin
        if(!rst) begin
            connect_r <= `ITCM_SELECT_PC;
        end
        else if(sram_cmd_rdy & sram_cmd_vld)begin //不需要hold，因为相关逻辑在sram_ctrl里做了。
            connect_r <= connect;
        end
    end

    assign ext_rsp_vld = (connect_r == `ITCM_SELECT_EXT) ? sram_rsp_vld : 1'b0;
    assign lsu_rsp_vld = (connect_r == `ITCM_SELECT_LSU) ? sram_rsp_vld : 1'b0;
    assign pc_rsp_vld = (connect_r == `ITCM_SELECT_PC) ? sram_rsp_vld : 1'b0;


    assign ext_rsp_err = (connect_r == `ITCM_SELECT_EXT) ? sram_rsp_err : 1'd0;
    assign lsu_rsp_err = (connect_r == `ITCM_SELECT_LSU) ? sram_rsp_err : 1'd0;
    assign pc_rsp_err = (connect_r == `ITCM_SELECT_PC) ? sram_rsp_err : 1'b0;

    assign ext_rsp_rdata = (connect_r == `ITCM_SELECT_EXT) ? sram_rsp_rdata : {(`MYRISCV_DATADW){1'b0}};
    assign lsu_rsp_rdata = (connect_r == `ITCM_SELECT_LSU) ? sram_rsp_rdata : {(`MYRISCV_DATADW){1'b0}};
    assign pc_rsp_rdata = (connect_r == `ITCM_SELECT_PC) ? sram_rsp_rdata : {(`MYRISCV_DATADW){1'b0}};

    assign sram_rsp_rdy = (connect_r == `ITCM_SELECT_EXT) ? ext_rsp_rdy : (connect_r == `ITCM_SELECT_LSU ? lsu_rsp_rdy : pc_rsp_rdy);

endmodule
