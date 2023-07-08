`include "mydefines.v"
module sram_ctrl
(
    clk,
    rst,

    sram_cmd_vld,
    sram_cmd_rdy,
    sram_cmd_addr,
    sram_cmd_read,
    sram_cmd_wdata,
    sram_cmd_wmask,

    sram_rsp_vld,
    sram_rsp_rdy,
    sram_rsp_err,
    sram_rsp_rdata,


    sram_cs,
    sram_we,
    sram_addr,
    sram_wem,
    sram_wdata,
    sram_rdata
);

    input clk, rst;

    input sram_cmd_vld;
    output sram_cmd_rdy;
    input [`MYRISCV_ADDRBUS] sram_cmd_addr;
    input sram_cmd_read;
    input [`MYRISCV_DATABUS] sram_cmd_wdata;
    input [(`MYRISCV_DATADW/8-1):0] sram_cmd_wmask;

    output reg sram_rsp_vld;
    input sram_rsp_rdy;
    output sram_rsp_err;
    output [`MYRISCV_DATABUS] sram_rsp_rdata;

    output sram_cs;
    output sram_we;
    output [`MYRISCV_ADDRBUS] sram_addr;
    output [(`MYRISCV_DATADW/8-1):0] sram_wem;
    output [`MYRISCV_DATABUS] sram_wdata;
    input  [`MYRISCV_DATABUS] sram_rdata;


    assign sram_cmd_rdy = sram_rsp_rdy | (~sram_rsp_vld);
    // reg sram_rsp_vld;
    always@(posedge clk /*or negedge rst*/) begin
        if(!rst) begin
            sram_rsp_vld <= 0;
        end
        else if(sram_cmd_rdy)begin
            sram_rsp_vld <= sram_cmd_vld;
        end
    end

    assign sram_cs = sram_cmd_rdy & sram_cmd_vld;
    assign sram_we = (~sram_cmd_read);
    assign sram_addr = sram_cmd_addr;
    assign sram_wem = sram_cmd_wmask;
    assign sram_wdata = sram_cmd_wdata;

    assign sram_rsp_rdata = sram_rdata;
    assign sram_rsp_err = 0;

endmodule
