`include "mydefines.v"
`include "e203_defines.v"

// lsu模块
module lsu_splt(
    input wire clk,
    input wire rst,

    input wire lsu_cmd_vld,
    output wire lsu_cmd_rdy,
    input wire lsu_cmd_read,
    input wire [`MYRISCV_ADDRBUS] lsu_cmd_addr,
    input wire [`MYRISCV_REGBUS] lsu_cmd_wdata,
    input wire [(`MYRISCV_DATADW/8-1):0] lsu_cmd_wmask,

    output wire lsu_rsp_vld,
    input wire lsu_rsp_rdy,
    output wire [`MYRISCV_REGBUS] lsu_rsp_rdata,
    output wire lsu_rsp_err,


    output wire lsu2sram_cmd_vld,
    input wire lsu2sram_cmd_rdy,
    output wire lsu2sram_cmd_read,
    output wire [`MYRISCV_ADDRBUS] lsu2sram_cmd_addr,
    output wire [`MYRISCV_REGBUS] lsu2sram_cmd_wdata,
    output wire [(`MYRISCV_DATADW/8-1):0] lsu2sram_cmd_wmask,

    input wire lsu2sram_rsp_vld,
    output wire lsu2sram_rsp_rdy,
    input wire [`MYRISCV_REGBUS] lsu2sram_rsp_rdata,
    input wire lsu2sram_rsp_err,

    output wire lsu2dtcm_cmd_vld,
    input wire lsu2dtcm_cmd_rdy,
    output wire lsu2dtcm_cmd_read,
    output wire [`MYRISCV_ADDRBUS] lsu2dtcm_cmd_addr,
    output wire [`MYRISCV_REGBUS] lsu2dtcm_cmd_wdata,
    output wire [(`MYRISCV_DATADW/8-1):0] lsu2dtcm_cmd_wmask,

    input wire lsu2dtcm_rsp_vld,
    output wire lsu2dtcm_rsp_rdy,
    input wire [`MYRISCV_REGBUS] lsu2dtcm_rsp_rdata,
    input wire lsu2dtcm_rsp_err,

    output wire lsu2biu_cmd_vld,
    input wire lsu2biu_cmd_rdy,
    output wire lsu2biu_cmd_read,
    output wire [`MYRISCV_ADDRBUS] lsu2biu_cmd_addr,
    output wire [`MYRISCV_REGBUS] lsu2biu_cmd_wdata,
    output wire [(`MYRISCV_DATADW/8-1):0] lsu2biu_cmd_wmask,

    input wire lsu2biu_rsp_vld,
    output wire lsu2biu_rsp_rdy,
    input wire [`MYRISCV_REGBUS] lsu2biu_rsp_rdata,
    input wire lsu2biu_rsp_err

    );


    // wire inputsel_vld_i;
    // wire inputsel_rdy_i;
    wire inputsel_vld_o;
    wire inputsel_rdy_o;
    wire fifo_unfull;
    wire fifo_unempty;

    // wire outputsel_vld_o;
    // wire outputsel_rdy_o;

    wire connect_itcm = ((lsu_cmd_addr & `SRAM_ADDR_MASK) == `SRAM_ADDR_INDEX);
    wire connect_dtcm = ((lsu_cmd_addr & `DTCM_ADDR_MASK) == `DTCM_ADDR_INDEX);
    wire [1:0] select_i =  connect_itcm ? `LSU_SELECT_ITCM : (connect_dtcm ? `LSU_SELECT_DTCM : `LSU_SELECT_BIU);
    wire [1:0] select_o;

    assign inputsel_vld_o = lsu_cmd_vld & fifo_unfull;
    assign lsu_cmd_rdy = inputsel_rdy_o & fifo_unfull;
    assign lsu2sram_cmd_vld = (select_i == `LSU_SELECT_ITCM) ? inputsel_vld_o : 1'b0;
    assign lsu2dtcm_cmd_vld = (select_i == `LSU_SELECT_DTCM) ? inputsel_vld_o : 1'b0;
    assign lsu2biu_cmd_vld  = (select_i == `LSU_SELECT_BIU) ? inputsel_vld_o : 1'b0;  
    assign inputsel_rdy_o   = (select_i == `LSU_SELECT_ITCM) ? lsu2sram_cmd_rdy : ((select_i == `LSU_SELECT_DTCM) ? lsu2dtcm_cmd_rdy : lsu2biu_cmd_rdy);
    assign lsu2sram_cmd_read = (select_i == `LSU_SELECT_ITCM) ? lsu_cmd_read : 1'b0;
    assign lsu2dtcm_cmd_read = (select_i == `LSU_SELECT_DTCM) ? lsu_cmd_read : 1'b0;
    assign lsu2biu_cmd_read  = (select_i == `LSU_SELECT_BIU) ? lsu_cmd_read : 1'b0;  
    assign lsu2sram_cmd_addr = (select_i == `LSU_SELECT_ITCM) ? lsu_cmd_addr : {(`MYRISCV_ADDRDW){1'b0}};
    assign lsu2dtcm_cmd_addr = (select_i == `LSU_SELECT_DTCM) ? lsu_cmd_addr : {(`MYRISCV_ADDRDW){1'b0}};
    assign lsu2biu_cmd_addr  = (select_i == `LSU_SELECT_BIU) ? lsu_cmd_addr : {(`MYRISCV_ADDRDW){1'b0}};  
    assign lsu2sram_cmd_wdata = (select_i == `LSU_SELECT_ITCM) ? lsu_cmd_wdata : {(`MYRISCV_DATADW){1'b0}};
    assign lsu2dtcm_cmd_wdata = (select_i == `LSU_SELECT_DTCM) ? lsu_cmd_wdata : {(`MYRISCV_DATADW){1'b0}};
    assign lsu2biu_cmd_wdata  = (select_i == `LSU_SELECT_BIU) ? lsu_cmd_wdata : {(`MYRISCV_DATADW){1'b0}};  
    assign lsu2sram_cmd_wmask = (select_i == `LSU_SELECT_ITCM) ? lsu_cmd_wmask : {(`MYRISCV_DATADW/8){1'b0}};
    assign lsu2dtcm_cmd_wmask = (select_i == `LSU_SELECT_DTCM) ? lsu_cmd_wmask : {(`MYRISCV_DATADW/8){1'b0}};
    assign lsu2biu_cmd_wmask  = (select_i == `LSU_SELECT_BIU) ? lsu_cmd_wmask : {(`MYRISCV_DATADW/8){1'b0}};

    

    fifo_simple # (
        .CUT_READY          (1),
        .ZEROOUT_WHENEMPTY  (0),
        .DP                 (2),
        .DW                 (2)
    ) fifo_inst (
        .w_req          (lsu_cmd_vld & lsu_cmd_rdy), 
        .unfull         (fifo_unfull), 
        .data_i         (select_i),
        .unempty        (fifo_unempty), 
        .r_req          (lsu_rsp_vld & lsu_rsp_rdy), 
        .data_o         (select_o),

        .clk            (clk),
        .rst            (rst)
    );

    assign lsu_rsp_vld = (select_o == `LSU_SELECT_ITCM) ? lsu2sram_rsp_vld : ((select_o == `LSU_SELECT_DTCM) ? lsu2dtcm_rsp_vld : lsu2biu_rsp_vld);
    assign lsu_rsp_rdata = (select_o == `LSU_SELECT_ITCM) ? lsu2sram_rsp_rdata : ((select_o == `LSU_SELECT_DTCM) ? lsu2dtcm_rsp_rdata : lsu2biu_rsp_rdata);
    assign lsu_rsp_err = (select_o == `LSU_SELECT_ITCM) ? lsu2sram_rsp_err : ((select_o == `LSU_SELECT_DTCM) ? lsu2dtcm_rsp_err : lsu2biu_rsp_err);

    assign lsu2sram_rsp_rdy = (select_o == `LSU_SELECT_ITCM) ? lsu_rsp_rdy : 1'b0;
    assign lsu2dtcm_rsp_rdy = (select_o == `LSU_SELECT_DTCM) ? lsu_rsp_rdy : 1'b0;
    assign lsu2biu_rsp_rdy  = (select_o == `LSU_SELECT_BIU) ? lsu_rsp_rdy : 1'b0;  

endmodule
