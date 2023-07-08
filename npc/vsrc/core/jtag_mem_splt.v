`include "mydefines.v"

// lsu模块
module jtag_mem_splt(
    input wire clk,
    input wire rst,

    input wire jtag_cmd_vld,
    output wire jtag_cmd_rdy,
    input wire jtag_cmd_read,
    input wire [`MYRISCV_ADDRBUS] jtag_cmd_addr,
    input wire [`MYRISCV_REGBUS] jtag_cmd_wdata,
    input wire [(`MYRISCV_DATADW/8-1):0] jtag_cmd_wmask,

    output wire jtag_rsp_vld,
    input wire jtag_rsp_rdy,
    output wire [`MYRISCV_REGBUS] jtag_rsp_rdata,
    output wire jtag_rsp_err,


    output wire jtag2sram_cmd_vld,
    input wire jtag2sram_cmd_rdy,
    output wire jtag2sram_cmd_read,
    output wire [`MYRISCV_ADDRBUS] jtag2sram_cmd_addr,
    output wire [`MYRISCV_REGBUS] jtag2sram_cmd_wdata,
    output wire [(`MYRISCV_DATADW/8-1):0] jtag2sram_cmd_wmask,

    input wire jtag2sram_rsp_vld,
    output wire jtag2sram_rsp_rdy,
    input wire [`MYRISCV_REGBUS] jtag2sram_rsp_rdata,
    input wire jtag2sram_rsp_err,

    output wire jtag2dtcm_cmd_vld,
    input wire jtag2dtcm_cmd_rdy,
    output wire jtag2dtcm_cmd_read,
    output wire [`MYRISCV_ADDRBUS] jtag2dtcm_cmd_addr,
    output wire [`MYRISCV_REGBUS] jtag2dtcm_cmd_wdata,
    output wire [(`MYRISCV_DATADW/8-1):0] jtag2dtcm_cmd_wmask,

    input wire jtag2dtcm_rsp_vld,
    output wire jtag2dtcm_rsp_rdy,
    input wire [`MYRISCV_REGBUS] jtag2dtcm_rsp_rdata,
    input wire jtag2dtcm_rsp_err,

    output wire jtag2biu_cmd_vld,
    input wire jtag2biu_cmd_rdy,
    output wire jtag2biu_cmd_read,
    output wire [`MYRISCV_ADDRBUS] jtag2biu_cmd_addr,
    output wire [`MYRISCV_REGBUS] jtag2biu_cmd_wdata,
    output wire [(`MYRISCV_DATADW/8-1):0] jtag2biu_cmd_wmask,

    input wire jtag2biu_rsp_vld,
    output wire jtag2biu_rsp_rdy,
    input wire [`MYRISCV_REGBUS] jtag2biu_rsp_rdata,
    input wire jtag2biu_rsp_err

    );

    wire inputsel_vld_o;
    wire inputsel_rdy_o;
    wire fifo_unfull;
    wire fifo_unempty;

    wire connect_sram = ((jtag_cmd_addr & `SRAM_ADDR_MASK) == `SRAM_ADDR_INDEX);
    wire connect_dtcm = ((jtag_cmd_addr & `DTCM_ADDR_MASK) == `DTCM_ADDR_INDEX);
    wire [1:0] select_i =  connect_sram ? `LSU_SELECT_ITCM : (connect_dtcm ? `LSU_SELECT_DTCM : `LSU_SELECT_BIU);
    wire [1:0] select_o;

    assign inputsel_vld_o = jtag_cmd_vld & fifo_unfull;
    assign jtag_cmd_rdy = inputsel_rdy_o & fifo_unfull;
    assign jtag2sram_cmd_vld = (select_i == `LSU_SELECT_ITCM)   ? inputsel_vld_o : 1'b0;
    assign jtag2dtcm_cmd_vld = (select_i == `LSU_SELECT_DTCM)   ? inputsel_vld_o : 1'b0;
    assign jtag2biu_cmd_vld  = (select_i == `LSU_SELECT_BIU)    ? inputsel_vld_o : 1'b0;  
    assign jtag2sram_cmd_read = (select_i == `LSU_SELECT_ITCM)  ? jtag_cmd_read : 1'b0;
    assign jtag2dtcm_cmd_read = (select_i == `LSU_SELECT_DTCM)  ? jtag_cmd_read : 1'b0;
    assign jtag2biu_cmd_read  = (select_i == `LSU_SELECT_BIU)   ? jtag_cmd_read : 1'b0; 
    assign jtag2sram_cmd_addr = (select_i == `LSU_SELECT_ITCM)  ? jtag_cmd_addr : {`MYRISCV_ADDRDW{1'b0}};
    assign jtag2dtcm_cmd_addr = (select_i == `LSU_SELECT_DTCM)  ? jtag_cmd_addr : {`MYRISCV_ADDRDW{1'b0}};
    assign jtag2biu_cmd_addr  = (select_i == `LSU_SELECT_BIU)   ? jtag_cmd_addr : {`MYRISCV_ADDRDW{1'b0}};  
    assign jtag2sram_cmd_wdata = (select_i == `LSU_SELECT_ITCM) ? jtag_cmd_wdata : {`MYRISCV_DATADW{1'b0}};
    assign jtag2dtcm_cmd_wdata = (select_i == `LSU_SELECT_DTCM) ? jtag_cmd_wdata : {`MYRISCV_DATADW{1'b0}};
    assign jtag2biu_cmd_wdata  = (select_i == `LSU_SELECT_BIU)  ? jtag_cmd_wdata : {`MYRISCV_DATADW{1'b0}};  
    assign jtag2sram_cmd_wmask = (select_i == `LSU_SELECT_ITCM) ? jtag_cmd_wmask : {(`MYRISCV_DATADW/8){1'b0}};
    assign jtag2dtcm_cmd_wmask = (select_i == `LSU_SELECT_DTCM) ? jtag_cmd_wmask : {(`MYRISCV_DATADW/8){1'b0}};
    assign jtag2biu_cmd_wmask  = (select_i == `LSU_SELECT_BIU)  ? jtag_cmd_wmask : {(`MYRISCV_DATADW/8){1'b0}};
    assign inputsel_rdy_o   = (select_i == `LSU_SELECT_ITCM)    ? jtag2sram_cmd_rdy : ((select_i == `LSU_SELECT_DTCM) ? jtag2dtcm_cmd_rdy : jtag2biu_cmd_rdy);


    fifo_simple # (
        .CUT_READY          (1),
        .ZEROOUT_WHENEMPTY  (0),
        .DP                 (2),
        .DW                 (2)
    ) fifo_inst (
        .w_req          (jtag_cmd_vld & jtag_cmd_rdy), 
        .unfull         (fifo_unfull), 
        .data_i         (select_i),
        .unempty        (fifo_unempty), 
        .r_req          (jtag_rsp_vld & jtag_rsp_rdy), 
        .data_o         (select_o),

        .clk            (clk),
        .rst            (rst)
    );

    assign jtag_rsp_vld = (select_o == `LSU_SELECT_ITCM) ? jtag2sram_rsp_vld : ((select_o == `LSU_SELECT_DTCM) ? jtag2dtcm_rsp_vld : jtag2biu_rsp_vld);
    assign jtag_rsp_rdata = (select_o == `LSU_SELECT_ITCM) ? jtag2sram_rsp_rdata : ((select_o == `LSU_SELECT_DTCM) ? jtag2dtcm_rsp_rdata : jtag2biu_rsp_rdata);
    assign jtag_rsp_err = (select_o == `LSU_SELECT_ITCM) ? jtag2sram_rsp_err : ((select_o == `LSU_SELECT_DTCM) ? jtag2dtcm_rsp_err : jtag2biu_rsp_err);

    assign jtag2sram_rsp_rdy = (select_i == `LSU_SELECT_ITCM) ? jtag_rsp_rdy : 1'b0;
    assign jtag2dtcm_rsp_rdy = (select_i == `LSU_SELECT_DTCM) ? jtag_rsp_rdy : 1'b0;
    assign jtag2biu_rsp_rdy  = (select_i == `LSU_SELECT_BIU) ? jtag_rsp_rdy : 1'b0;  

endmodule
