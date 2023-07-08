`include "mydefines.v"
module ddr_arbt(
    mem2mig_icb_cmd_valid,
    mem2mig_icb_cmd_ready,
    mem2mig_icb_cmd_addr, 
    mem2mig_icb_cmd_read, 
    mem2mig_icb_cmd_wdata,
    mem2mig_icb_cmd_wmask,
    mem2mig_icb_cmd_burst,
    mem2mig_icb_cmd_beat,
    mem2mig_icb_cmd_lock,
    mem2mig_icb_cmd_excl,
    mem2mig_icb_cmd_size,
    
    mem2mig_icb_rsp_valid,
    mem2mig_icb_rsp_ready,
    mem2mig_icb_rsp_err  ,
    mem2mig_icb_rsp_excl_ok,
    mem2mig_icb_rsp_rdata,

    ppi2mig_icb_cmd_valid,
    ppi2mig_icb_cmd_ready,
    ppi2mig_icb_cmd_addr, 
    ppi2mig_icb_cmd_read, 
    ppi2mig_icb_cmd_wdata,
    ppi2mig_icb_cmd_wmask,
    ppi2mig_icb_cmd_burst,
    ppi2mig_icb_cmd_beat,
    ppi2mig_icb_cmd_lock,
    ppi2mig_icb_cmd_excl,
    ppi2mig_icb_cmd_size,
    
    ppi2mig_icb_rsp_valid,
    ppi2mig_icb_rsp_ready,
    ppi2mig_icb_rsp_err  ,
    ppi2mig_icb_rsp_excl_ok,
    ppi2mig_icb_rsp_rdata,


    mig_icb_cmd_valid,
    mig_icb_cmd_ready,
    mig_icb_cmd_addr, 
    mig_icb_cmd_read, 
    mig_icb_cmd_burst,
    mig_icb_cmd_beat,
    mig_icb_cmd_wdata,
    mig_icb_cmd_wmask,
    mig_icb_cmd_lock,
    mig_icb_cmd_excl,
    mig_icb_cmd_size,

    mig_icb_rsp_valid,
    mig_icb_rsp_ready,
    mig_icb_rsp_err  ,
    mig_icb_rsp_excl_ok,
    mig_icb_rsp_rdata,


    clk,
    rst
);
    input clk,rst;

    input                           mem2mig_icb_cmd_valid;
    output                          mem2mig_icb_cmd_ready;
    input  [`MYRISCV_ADDRBUS]       mem2mig_icb_cmd_addr; 
    input                           mem2mig_icb_cmd_read; 
    input  [`MYRISCV_DATADW-1:0]    mem2mig_icb_cmd_wdata;
    input  [`MYRISCV_DATADW/8-1:0]  mem2mig_icb_cmd_wmask;
    input  [1:0]                    mem2mig_icb_cmd_burst;
    input  [1:0]                    mem2mig_icb_cmd_beat;
    input                           mem2mig_icb_cmd_lock;
    input                           mem2mig_icb_cmd_excl;
    input  [1:0]                    mem2mig_icb_cmd_size;

    output                          mem2mig_icb_rsp_valid;
    input                           mem2mig_icb_rsp_ready;
    output                          mem2mig_icb_rsp_err  ;
    output                          mem2mig_icb_rsp_excl_ok;
    output [`MYRISCV_DATADW-1:0]    mem2mig_icb_rsp_rdata;


    input                           ppi2mig_icb_cmd_valid;
    output                          ppi2mig_icb_cmd_ready;
    input  [`MYRISCV_ADDRBUS]       ppi2mig_icb_cmd_addr; 
    input                           ppi2mig_icb_cmd_read; 
    input  [`MYRISCV_DATADW-1:0]    ppi2mig_icb_cmd_wdata;
    input  [`MYRISCV_DATADW/8-1:0]  ppi2mig_icb_cmd_wmask;
    input  [1:0]                    ppi2mig_icb_cmd_burst;
    input  [1:0]                    ppi2mig_icb_cmd_beat;
    input                           ppi2mig_icb_cmd_lock;
    input                           ppi2mig_icb_cmd_excl;
    input  [1:0]                    ppi2mig_icb_cmd_size;

    output                          ppi2mig_icb_rsp_valid;
    input                           ppi2mig_icb_rsp_ready;
    output                          ppi2mig_icb_rsp_err  ;
    output                          ppi2mig_icb_rsp_excl_ok;
    output [`MYRISCV_DATADW-1:0]    ppi2mig_icb_rsp_rdata;

    output                          mig_icb_cmd_valid;
    input                           mig_icb_cmd_ready;
    output [`MYRISCV_ADDRDW-1:0]    mig_icb_cmd_addr; 
    output                          mig_icb_cmd_read; 
    output [`MYRISCV_DATADW-1:0]    mig_icb_cmd_wdata;
    output [`MYRISCV_DATADW/8-1:0]  mig_icb_cmd_wmask;
    output [1:0]                    mig_icb_cmd_burst;
    output [1:0]                    mig_icb_cmd_beat;
    output                          mig_icb_cmd_lock;
    output                          mig_icb_cmd_excl;
    output [1:0]                    mig_icb_cmd_size;

    input                           mig_icb_rsp_valid;
    output                          mig_icb_rsp_ready;
    input                           mig_icb_rsp_err  ;
    input                           mig_icb_rsp_excl_ok;
    input  [`MYRISCV_DATADW-1:0]    mig_icb_rsp_rdata;
    

    wire [2 *1-1:0]                 arbt_bus_icb_cmd_valid;
    wire [2 *1-1:0]                 arbt_bus_icb_cmd_ready;
    wire [(2 *`MYRISCV_ADDRDW)-1:0]   arbt_bus_icb_cmd_addr;
    wire [2 *1-1:0]                 arbt_bus_icb_cmd_read;
    wire [(2 *`MYRISCV_XLEN)-1:0] arbt_bus_icb_cmd_wdata;
    wire [(2 *`MYRISCV_XLEN)/8-1:0] arbt_bus_icb_cmd_wmask;
    wire [2 *2-1:0] arbt_bus_icb_cmd_burst;
    wire [2 *2-1:0] arbt_bus_icb_cmd_beat;
    wire [2 *1-1:0] arbt_bus_icb_cmd_lock;
    wire [2 *1-1:0] arbt_bus_icb_cmd_excl;
    wire [2 *2-1:0] arbt_bus_icb_cmd_size;
    wire [2 *1-1:0] arbt_bus_icb_cmd_usr;

    wire [2 *1-1:0] arbt_bus_icb_rsp_valid;
    wire [2 *1-1:0] arbt_bus_icb_rsp_ready;
    wire [2 *1-1:0] arbt_bus_icb_rsp_err;
    wire [2 *1-1:0] arbt_bus_icb_rsp_excl_ok;
    wire [(2 *`MYRISCV_XLEN)-1:0] arbt_bus_icb_rsp_rdata;

assign arbt_bus_icb_cmd_valid =
    {
    mem2mig_icb_cmd_valid,
    ppi2mig_icb_cmd_valid
    } ;

assign arbt_bus_icb_cmd_addr =
    {
    mem2mig_icb_cmd_addr,
    ppi2mig_icb_cmd_addr
    } ;

assign arbt_bus_icb_cmd_read =
    {
    mem2mig_icb_cmd_read,
    ppi2mig_icb_cmd_read
    } ;

assign arbt_bus_icb_cmd_wdata =
    {
    mem2mig_icb_cmd_wdata,
    ppi2mig_icb_cmd_wdata
    } ;

assign arbt_bus_icb_cmd_wmask =
    {
    mem2mig_icb_cmd_wmask,
    ppi2mig_icb_cmd_wmask
    } ;

assign arbt_bus_icb_cmd_burst =
    {
    mem2mig_icb_cmd_burst,
    ppi2mig_icb_cmd_burst
    } ;

assign arbt_bus_icb_cmd_beat =
    {
    mem2mig_icb_cmd_beat,
    ppi2mig_icb_cmd_beat
    } ;

assign arbt_bus_icb_cmd_lock =
    {
    mem2mig_icb_cmd_lock,
    ppi2mig_icb_cmd_lock
    } ;

assign arbt_bus_icb_cmd_excl =
    {
    mem2mig_icb_cmd_excl,
    ppi2mig_icb_cmd_excl
    } ;
    
assign arbt_bus_icb_cmd_size =
    {
    mem2mig_icb_cmd_size,
    ppi2mig_icb_cmd_size
    } ;

// assign arbt_bus_icb_cmd_usr = ;

assign                   {
    mem2mig_icb_cmd_ready,
    ppi2mig_icb_cmd_ready
    } = arbt_bus_icb_cmd_ready;

//RSP Channel
assign                   {
    mem2mig_icb_rsp_valid,
    ppi2mig_icb_rsp_valid
    } = arbt_bus_icb_rsp_valid;

assign                   {
    mem2mig_icb_rsp_err,
    ppi2mig_icb_rsp_err
    } = arbt_bus_icb_rsp_err;

assign                   {
    mem2mig_icb_rsp_excl_ok,
    ppi2mig_icb_rsp_excl_ok
    } = arbt_bus_icb_rsp_excl_ok;
    
assign                   {
    mem2mig_icb_rsp_rdata,
    ppi2mig_icb_rsp_rdata
    } = arbt_bus_icb_rsp_rdata;

assign arbt_bus_icb_rsp_ready = {
    mem2mig_icb_rsp_ready,
    ppi2mig_icb_rsp_ready
    };

    arbt_me # (
        // .ARBT_SCHEME (0),// Priority based
        .ALLOW_0CYCL_RSP  (0),// Dont allow the 0 cycle response because in BIU we always have CMD_DP larger than 0
                            //   when the response come back from the external bus, it is at least 1 cycle later
        .FIFO_DP          (`MYRISCV_DDR_ARBT_DEEP),
        .FIFO_CUT_READY   (`MYRISCV_DDR_ARBT_FIFO_CUT_READY),
        .ARBT_NUM         (2),
        .USR_W      (1),
        .AW         (`MYRISCV_ADDRDW),
        .DW         (`MYRISCV_XLEN) 
    ) arbt_mig(
        .o_icb_cmd_vld          (mig_icb_cmd_valid )     ,
        .o_icb_cmd_rdy          (mig_icb_cmd_ready )     ,
        .o_icb_cmd_read         (mig_icb_cmd_read )      ,
        .o_icb_cmd_addr         (mig_icb_cmd_addr )      ,
        .o_icb_cmd_wdata        (mig_icb_cmd_wdata )     ,
        .o_icb_cmd_wmask        (mig_icb_cmd_wmask)      ,
        // .o_icb_cmd_burst        (mig_icb_cmd_burst)     ,
        // .o_icb_cmd_beat         (mig_icb_cmd_beat )     ,
        // .o_icb_cmd_excl         (mig_icb_cmd_excl )     ,
        // .o_icb_cmd_lock         (mig_icb_cmd_lock )     ,
        // .o_icb_cmd_size         (mig_icb_cmd_size )     ,
        .o_icb_cmd_usr          (),
                                    
        .o_icb_rsp_vld          (mig_icb_rsp_valid )     ,
        .o_icb_rsp_rdy          (mig_icb_rsp_ready )     ,
        .o_icb_rsp_err          (mig_icb_rsp_err)        ,
        // .o_icb_rsp_excl_ok      (mig_icb_rsp_excl_ok)    ,
        .o_icb_rsp_rdata        (mig_icb_rsp_rdata )     ,
        .o_icb_rsp_usr          (),
                                    
        .i_bus_icb_cmd_rdy      (arbt_bus_icb_cmd_ready ) ,
        .i_bus_icb_cmd_vld      (arbt_bus_icb_cmd_valid ) ,
        .i_bus_icb_cmd_read     (arbt_bus_icb_cmd_read )  ,
        .i_bus_icb_cmd_addr     (arbt_bus_icb_cmd_addr )  ,
        .i_bus_icb_cmd_wdata    (arbt_bus_icb_cmd_wdata ) ,
        .i_bus_icb_cmd_wmask    (arbt_bus_icb_cmd_wmask)  ,
        // .i_bus_icb_cmd_burst    (arbt_bus_icb_cmd_burst),
        // .i_bus_icb_cmd_beat     (arbt_bus_icb_cmd_beat ),
        // .i_bus_icb_cmd_excl     (arbt_bus_icb_cmd_excl ),
        // .i_bus_icb_cmd_lock     (arbt_bus_icb_cmd_lock ),
        // .i_bus_icb_cmd_size     (arbt_bus_icb_cmd_size ),
        .i_bus_icb_cmd_usr      (arbt_bus_icb_cmd_usr ),
                                    
        .i_bus_icb_rsp_vld      (arbt_bus_icb_rsp_valid ) ,
        .i_bus_icb_rsp_rdy      (arbt_bus_icb_rsp_ready ) ,
        .i_bus_icb_rsp_err      (arbt_bus_icb_rsp_err)    ,
        // .i_bus_icb_rsp_excl_ok  (arbt_bus_icb_rsp_excl_ok),
        .i_bus_icb_rsp_rdata    (arbt_bus_icb_rsp_rdata ) ,
        .i_bus_icb_rsp_usr      () ,
                                
        .clk                    (clk  )                     ,
        .rst                    (rst)
    );

endmodule
