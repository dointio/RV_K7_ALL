`include "mydefines.v"

module biu_bridge(

  output                         biu_active,
  //r: lsu_channel
  input                          lsu2biu_icb_cmd_valid,
  output                         lsu2biu_icb_cmd_ready,
  input  [`MYRISCV_ADDRDW-1:0]   lsu2biu_icb_cmd_addr, 
  input                          lsu2biu_icb_cmd_read, 
  input  [`MYRISCV_XLEN-1:0]        lsu2biu_icb_cmd_wdata,
  input  [`MYRISCV_XLEN/8-1:0]      lsu2biu_icb_cmd_wmask,
  input  [1:0]                   lsu2biu_icb_cmd_burst,
  input  [1:0]                   lsu2biu_icb_cmd_beat,
  input                          lsu2biu_icb_cmd_lock,
  input                          lsu2biu_icb_cmd_excl,
  input  [1:0]                   lsu2biu_icb_cmd_size,
  
  output                         lsu2biu_icb_rsp_valid,
  input                          lsu2biu_icb_rsp_ready,
  output                         lsu2biu_icb_rsp_err  ,
  output                         lsu2biu_icb_rsp_excl_ok,
  output [`MYRISCV_XLEN-1:0]        lsu2biu_icb_rsp_rdata,

`ifdef MYRISCV_HAS_MEM_ITF //{ //r:如果有mem，ifu才有访问biu的必要。
    //r: ifu_channel
  input                          ifu2biu_icb_cmd_valid,
  output                         ifu2biu_icb_cmd_ready,
  input  [`MYRISCV_ADDRDW-1:0]   ifu2biu_icb_cmd_addr, 
  input                          ifu2biu_icb_cmd_read, 
  input  [`MYRISCV_XLEN-1:0]        ifu2biu_icb_cmd_wdata,
  input  [`MYRISCV_XLEN/8-1:0]      ifu2biu_icb_cmd_wmask,
  input  [1:0]                   ifu2biu_icb_cmd_burst,
  input  [1:0]                   ifu2biu_icb_cmd_beat,
  input                          ifu2biu_icb_cmd_lock,
  input                          ifu2biu_icb_cmd_excl,
  input  [1:0]                   ifu2biu_icb_cmd_size,

  output                         ifu2biu_icb_rsp_valid,
  input                          ifu2biu_icb_rsp_ready,
  output                         ifu2biu_icb_rsp_err  ,
  output                         ifu2biu_icb_rsp_excl_ok,
  output [`MYRISCV_XLEN-1:0]        ifu2biu_icb_rsp_rdata,
  // output                         ifu2biu_replay,
`endif//}
  ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
  //r: jtag channel
  input                          jtag2biu_icb_cmd_valid,
  output                         jtag2biu_icb_cmd_ready,
  input  [`MYRISCV_ADDRDW-1:0]   jtag2biu_icb_cmd_addr, 
  input                          jtag2biu_icb_cmd_read, 
  input  [`MYRISCV_XLEN-1:0]        jtag2biu_icb_cmd_wdata,
  input  [`MYRISCV_XLEN/8-1:0]      jtag2biu_icb_cmd_wmask,
  input  [1:0]                   jtag2biu_icb_cmd_burst,
  input  [1:0]                   jtag2biu_icb_cmd_beat,
  input                          jtag2biu_icb_cmd_lock,
  input                          jtag2biu_icb_cmd_excl,
  input  [1:0]                   jtag2biu_icb_cmd_size,

  output                         jtag2biu_icb_rsp_valid,
  input                          jtag2biu_icb_rsp_ready,
  output                         jtag2biu_icb_rsp_err  ,
  output                         jtag2biu_icb_rsp_excl_ok,
  output [`MYRISCV_XLEN-1:0]        jtag2biu_icb_rsp_rdata,
  //output                         ifu2biu_replay,

  //r: ppi slave channel
  input                          ppi_icb_enable,

  output                         ppi_icb_cmd_valid,
  input                          ppi_icb_cmd_ready,
  output [`MYRISCV_ADDRDW-1:0]   ppi_icb_cmd_addr, 
  output                         ppi_icb_cmd_read, 
  output [`MYRISCV_XLEN-1:0]        ppi_icb_cmd_wdata,
  output [`MYRISCV_XLEN/8-1:0]      ppi_icb_cmd_wmask,
  output [1:0]                   ppi_icb_cmd_burst,
  output [1:0]                   ppi_icb_cmd_beat,
  output                         ppi_icb_cmd_lock,
  output                         ppi_icb_cmd_excl,
  output [1:0]                   ppi_icb_cmd_size,

  input                          ppi_icb_rsp_valid,
  output                         ppi_icb_rsp_ready,
  input                          ppi_icb_rsp_err  ,
  input                          ppi_icb_rsp_excl_ok,
  input  [`MYRISCV_XLEN-1:0]        ppi_icb_rsp_rdata,

  //r: clint slave channel
  input                          clint_icb_enable,

  output                         clint_icb_cmd_valid,
  input                          clint_icb_cmd_ready,
  output [`MYRISCV_ADDRDW-1:0]   clint_icb_cmd_addr, 
  output                         clint_icb_cmd_read, 
  output [`MYRISCV_XLEN-1:0]        clint_icb_cmd_wdata,
  output [`MYRISCV_XLEN/8-1:0]      clint_icb_cmd_wmask,
  output [1:0]                   clint_icb_cmd_burst,
  output [1:0]                   clint_icb_cmd_beat,
  output                         clint_icb_cmd_lock,
  output                         clint_icb_cmd_excl,
  output [1:0]                   clint_icb_cmd_size,

  input                          clint_icb_rsp_valid,
  output                         clint_icb_rsp_ready,
  input                          clint_icb_rsp_err  ,
  input                          clint_icb_rsp_excl_ok,
  input  [`MYRISCV_XLEN-1:0]        clint_icb_rsp_rdata,

  //r: plic slave channel
  input                          plic_icb_enable,
  
  output                         plic_icb_cmd_valid,
  input                          plic_icb_cmd_ready,
  output [`MYRISCV_ADDRDW-1:0]   plic_icb_cmd_addr, 
  output                         plic_icb_cmd_read, 
  output [`MYRISCV_XLEN-1:0]        plic_icb_cmd_wdata,
  output [`MYRISCV_XLEN/8-1:0]      plic_icb_cmd_wmask,
  output [1:0]                   plic_icb_cmd_burst,
  output [1:0]                   plic_icb_cmd_beat,
  output                         plic_icb_cmd_lock,
  output                         plic_icb_cmd_excl,
  output [1:0]                   plic_icb_cmd_size,
  
  input                          plic_icb_rsp_valid,
  output                         plic_icb_rsp_ready,
  input                          plic_icb_rsp_err  ,
  input                          plic_icb_rsp_excl_ok,
  input  [`MYRISCV_XLEN-1:0]        plic_icb_rsp_rdata,

`ifdef MYRISCV_HAS_FIO //{ //r: fio channel for fast IO(?)
  //r: fio slave channel
  input                             fio_icb_enable,
  
  output                            fio_icb_cmd_valid,
  input                             fio_icb_cmd_ready,
  output [`MYRISCV_ADDRDW-1:0]      fio_icb_cmd_addr, 
  output                            fio_icb_cmd_read, 
  output [`MYRISCV_XLEN-1:0]        fio_icb_cmd_wdata,
  output [`MYRISCV_XLEN/8-1:0]      fio_icb_cmd_wmask,
  output [1:0]                      fio_icb_cmd_burst,
  output [1:0]                      fio_icb_cmd_beat,
  output                            fio_icb_cmd_lock,
  output                            fio_icb_cmd_excl,
  output [1:0]                      fio_icb_cmd_size,
      
  input                             fio_icb_rsp_valid,
  output                            fio_icb_rsp_ready,
  input                             fio_icb_rsp_err  ,
  input                             fio_icb_rsp_excl_ok,
  input  [`MYRISCV_XLEN-1:0]        fio_icb_rsp_rdata,
`endif//}

`ifdef MYRISCV_HAS_MEM_ITF //{ //r:for outside mem
  input                             mem_icb_enable,
    
  output                            mem_icb_cmd_valid,
  input                             mem_icb_cmd_ready,
  output [`MYRISCV_ADDRDW-1:0]      mem_icb_cmd_addr, 
  output                            mem_icb_cmd_read, 
  output [`MYRISCV_XLEN-1:0]        mem_icb_cmd_wdata,
  output [`MYRISCV_XLEN/8-1:0]      mem_icb_cmd_wmask,
  output [1:0]                      mem_icb_cmd_burst,
  output [1:0]                      mem_icb_cmd_beat,
  output                            mem_icb_cmd_lock,
  output                            mem_icb_cmd_excl,
  output [1:0]                      mem_icb_cmd_size,
  
  input                             mem_icb_rsp_valid,
  output                            mem_icb_rsp_ready,
  input                             mem_icb_rsp_err  ,
  input                             mem_icb_rsp_excl_ok,
  input  [`MYRISCV_XLEN-1:0]        mem_icb_rsp_rdata,
`endif//}

  input  clk,
  input  rst
  );


  `ifdef MYRISCV_HAS_MEM_ITF //{
      // localparam BIU_ARBT_I_NUM = 2;
      // localparam BIU_ARBT_I_PTR_W = 1;
      localparam BIU_ARBT_I_NUM = 3;
      localparam BIU_ARBT_I_PTR_W = 2;
  `else//}{
      localparam BIU_ARBT_I_NUM = 1;
      localparam BIU_ARBT_I_PTR_W = 1;
  `endif//}

  
  // The SPLT_NUM is the sum of following components
  //   * ppi, clint, plic, SystemITF, Fast-IO, IFU-err 
      localparam BIU_SPLT_I_NUM_0 = 4;

  `ifdef MYRISCV_HAS_MEM_ITF //{
      localparam BIU_SPLT_I_NUM_1 = (BIU_SPLT_I_NUM_0 + 1);
  `else//}{
      localparam BIU_SPLT_I_NUM_1 = BIU_SPLT_I_NUM_0;
  `endif//}

  `ifdef MYRISCV_HAS_FIO //{
      localparam BIU_SPLT_I_NUM_2 = (BIU_SPLT_I_NUM_1 + 1);
  `else//}{
      localparam BIU_SPLT_I_NUM_2 = BIU_SPLT_I_NUM_1;
  `endif//}

      localparam BIU_SPLT_I_NUM   = BIU_SPLT_I_NUM_2;

  wire                         ifuerr_icb_cmd_valid;
  wire                         ifuerr_icb_cmd_ready;
  wire [`MYRISCV_ADDRDW-1:0]   ifuerr_icb_cmd_addr; 
  wire                         ifuerr_icb_cmd_read; 
  wire [2-1:0]                 ifuerr_icb_cmd_burst;
  wire [2-1:0]                 ifuerr_icb_cmd_beat;
  wire [`MYRISCV_XLEN-1:0]        ifuerr_icb_cmd_wdata;
  wire [`MYRISCV_XLEN/8-1:0]      ifuerr_icb_cmd_wmask;
  wire                         ifuerr_icb_cmd_lock;
  wire                         ifuerr_icb_cmd_excl;
  wire [1:0]                   ifuerr_icb_cmd_size;
  
  wire                         ifuerr_icb_rsp_valid;
  wire                         ifuerr_icb_rsp_ready;
  wire                         ifuerr_icb_rsp_err  ;
  wire                         ifuerr_icb_rsp_excl_ok;
  wire [`MYRISCV_XLEN-1:0]        ifuerr_icb_rsp_rdata;

  wire arbt_icb_cmd_valid;
  wire arbt_icb_cmd_ready;
  wire [`MYRISCV_ADDRDW-1:0] arbt_icb_cmd_addr;
  wire arbt_icb_cmd_read;
  wire [`MYRISCV_XLEN-1:0] arbt_icb_cmd_wdata;
  wire [`MYRISCV_XLEN/8-1:0] arbt_icb_cmd_wmask;
  wire [1:0] arbt_icb_cmd_burst;
  wire [1:0] arbt_icb_cmd_beat;
  wire arbt_icb_cmd_lock;
  wire arbt_icb_cmd_excl;
  wire [1:0] arbt_icb_cmd_size;
  wire arbt_icb_cmd_usr;


  wire arbt_icb_rsp_valid;
  wire arbt_icb_rsp_ready;
  wire arbt_icb_rsp_err;
  wire arbt_icb_rsp_excl_ok;
  wire [`MYRISCV_XLEN-1:0] arbt_icb_rsp_rdata;

  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_valid;
  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_ready;
  wire [BIU_ARBT_I_NUM*`MYRISCV_ADDRDW-1:0] arbt_bus_icb_cmd_addr;
  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_read;
  wire [BIU_ARBT_I_NUM*`MYRISCV_XLEN-1:0] arbt_bus_icb_cmd_wdata;
  wire [BIU_ARBT_I_NUM*`MYRISCV_XLEN/8-1:0] arbt_bus_icb_cmd_wmask;
  wire [BIU_ARBT_I_NUM*2-1:0] arbt_bus_icb_cmd_burst;
  wire [BIU_ARBT_I_NUM*2-1:0] arbt_bus_icb_cmd_beat;
  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_lock;
  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_excl;
  wire [BIU_ARBT_I_NUM*2-1:0] arbt_bus_icb_cmd_size;
  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_usr;

  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_rsp_valid;
  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_rsp_ready;
  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_rsp_err;
  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_rsp_excl_ok;
  wire [BIU_ARBT_I_NUM*`MYRISCV_XLEN-1:0] arbt_bus_icb_rsp_rdata;

  //CMD Channel
  assign arbt_bus_icb_cmd_valid =
      // The  LSU take higher priority
                          {
                            jtag2biu_icb_cmd_valid,
`ifdef MYRISCV_HAS_MEM_ITF
                            ifu2biu_icb_cmd_valid,
`endif
                            lsu2biu_icb_cmd_valid
                          } ;

  assign arbt_bus_icb_cmd_addr =
                          {
                            jtag2biu_icb_cmd_addr,
`ifdef MYRISCV_HAS_MEM_ITF
                            ifu2biu_icb_cmd_addr,
`endif
                            lsu2biu_icb_cmd_addr
                          } ;

  assign arbt_bus_icb_cmd_read =
                          {
                            jtag2biu_icb_cmd_read,
`ifdef MYRISCV_HAS_MEM_ITF
                            ifu2biu_icb_cmd_read,
`endif
                            lsu2biu_icb_cmd_read
                          } ;

  assign arbt_bus_icb_cmd_wdata =
                          {
                            jtag2biu_icb_cmd_wdata,
`ifdef MYRISCV_HAS_MEM_ITF
                            ifu2biu_icb_cmd_wdata,
`endif
                            lsu2biu_icb_cmd_wdata
                          } ;

  assign arbt_bus_icb_cmd_wmask =
                          {
                            jtag2biu_icb_cmd_wmask,
`ifdef MYRISCV_HAS_MEM_ITF
                            ifu2biu_icb_cmd_wmask,
`endif
                            lsu2biu_icb_cmd_wmask
                          } ;
                        
  assign arbt_bus_icb_cmd_burst =
                          {
                            jtag2biu_icb_cmd_burst,
`ifdef MYRISCV_HAS_MEM_ITF
                            ifu2biu_icb_cmd_burst,
`endif
                            lsu2biu_icb_cmd_burst
                          } ;
                        
  assign arbt_bus_icb_cmd_beat =
                          {
                            jtag2biu_icb_cmd_beat,
`ifdef MYRISCV_HAS_MEM_ITF
                            ifu2biu_icb_cmd_beat,
`endif
                            lsu2biu_icb_cmd_beat
                          } ;
                        
  assign arbt_bus_icb_cmd_lock =
                          {
                            jtag2biu_icb_cmd_lock,
`ifdef MYRISCV_HAS_MEM_ITF
                            ifu2biu_icb_cmd_lock,
`endif
                            lsu2biu_icb_cmd_lock
                          } ;

  assign arbt_bus_icb_cmd_excl =
                          {
                            jtag2biu_icb_cmd_excl,
`ifdef MYRISCV_HAS_MEM_ITF
                            ifu2biu_icb_cmd_excl,
`endif
                            lsu2biu_icb_cmd_excl
                          } ;
                          
  assign arbt_bus_icb_cmd_size =
                          {
                            jtag2biu_icb_cmd_size,
`ifdef MYRISCV_HAS_MEM_ITF
                            ifu2biu_icb_cmd_size,
`endif
                            lsu2biu_icb_cmd_size
                          } ;

wire ifu2biu_icb_cmd_ifu = 1'b1;
wire lsu2biu_icb_cmd_ifu = 1'b0;
wire jtag2biu_icb_cmd_ifu = 1'b0;
assign arbt_bus_icb_cmd_usr =
                          {
                            jtag2biu_icb_cmd_ifu,
`ifdef MYRISCV_HAS_MEM_ITF
                            ifu2biu_icb_cmd_ifu,
`endif
                            lsu2biu_icb_cmd_ifu
                          } ;

  assign                   {
                            jtag2biu_icb_cmd_ready,
`ifdef MYRISCV_HAS_MEM_ITF
                            ifu2biu_icb_cmd_ready,
`endif
                            lsu2biu_icb_cmd_ready
                          } = arbt_bus_icb_cmd_ready;

  //RSP Channel
  assign                   {
                            jtag2biu_icb_rsp_valid,
`ifdef MYRISCV_HAS_MEM_ITF
                            ifu2biu_icb_rsp_valid,
`endif
                            lsu2biu_icb_rsp_valid
                          } = arbt_bus_icb_rsp_valid;

  assign                   {
                            jtag2biu_icb_rsp_err,
`ifdef MYRISCV_HAS_MEM_ITF
                            ifu2biu_icb_rsp_err,
`endif
                            lsu2biu_icb_rsp_err
                          } = arbt_bus_icb_rsp_err;

  assign                   {
                            jtag2biu_icb_rsp_excl_ok,
`ifdef MYRISCV_HAS_MEM_ITF
                            ifu2biu_icb_rsp_excl_ok,
`endif
                            lsu2biu_icb_rsp_excl_ok
                          } = arbt_bus_icb_rsp_excl_ok;
                          
  assign                   {
                            jtag2biu_icb_rsp_rdata,
`ifdef MYRISCV_HAS_MEM_ITF
                            ifu2biu_icb_rsp_rdata,
`endif
                            lsu2biu_icb_rsp_rdata
                          } = arbt_bus_icb_rsp_rdata;

  assign arbt_bus_icb_rsp_ready = {
                            jtag2biu_icb_rsp_ready,
`ifdef MYRISCV_HAS_MEM_ITF
                            ifu2biu_icb_rsp_ready,
`endif 
                            lsu2biu_icb_rsp_ready
                          };

  arbt_me # (
    // .ARBT_SCHEME (0),// Priority based
    .ALLOW_0CYCL_RSP  (0),// Dont allow the 0 cycle response because in BIU we always have CMD_DP larger than 0
                        //   when the response come back from the external bus, it is at least 1 cycle later
    .FIFO_DP          (`MYRISCV_BIU_OUTFIFO_DEEP),
    .FIFO_CUT_READY   (`MYRISCV_BIU_ARBT_FIFO_CUT_READY),
    .ARBT_NUM         (BIU_ARBT_I_NUM),
    .USR_W      (1),
    .AW         (`MYRISCV_ADDRDW),
    .DW         (`MYRISCV_XLEN) 
  ) arbt_inst(
    .o_icb_cmd_vld          (arbt_icb_cmd_valid )     ,
    .o_icb_cmd_rdy          (arbt_icb_cmd_ready )     ,
    .o_icb_cmd_read         (arbt_icb_cmd_read )      ,
    .o_icb_cmd_addr         (arbt_icb_cmd_addr )      ,
    .o_icb_cmd_wdata        (arbt_icb_cmd_wdata )     ,
    .o_icb_cmd_wmask        (arbt_icb_cmd_wmask)      ,
    // .o_icb_cmd_burst        (arbt_icb_cmd_burst)     ,
    // .o_icb_cmd_beat         (arbt_icb_cmd_beat )     ,
    // .o_icb_cmd_excl         (arbt_icb_cmd_excl )     ,
    // .o_icb_cmd_lock         (arbt_icb_cmd_lock )     ,
    // .o_icb_cmd_size         (arbt_icb_cmd_size )     ,
    .o_icb_cmd_usr          (arbt_icb_cmd_usr  )     ,
                                  
    .o_icb_rsp_vld          (arbt_icb_rsp_valid )     ,
    .o_icb_rsp_rdy          (arbt_icb_rsp_ready )     ,
    .o_icb_rsp_err          (arbt_icb_rsp_err)        ,
    // .o_icb_rsp_excl_ok      (arbt_icb_rsp_excl_ok)    ,
    .o_icb_rsp_rdata        (arbt_icb_rsp_rdata )     ,
    .o_icb_rsp_usr          (1'b0   )     ,
                                
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

  // arbt_e203 # (
  //   .ARBT_SCHEME (0),// Priority based
  //   .ALLOW_0CYCL_RSP (0),// Dont allow the 0 cycle response because in BIU we always have CMD_DP larger than 0
  //                       //   when the response come back from the external bus, it is at least 1 cycle later
  //   .FIFO_OUTS_NUM   (`MYRISCV_BIU_OUTFIFO_DEEP),
  //   .FIFO_CUT_READY  (`MYRISCV_BIU_ARBT_FIFO_CUT_READY),
  //   .ARBT_NUM   (BIU_ARBT_I_NUM),
  //   .ARBT_PTR_W (BIU_ARBT_I_PTR_W),
  //   .USR_W      (1),
  //   .AW         (`MYRISCV_ADDRDW),
  //   .DW         (`MYRISCV_XLEN) 
  // ) u_biu_icb_arbt(
  //   .o_icb_cmd_valid        (arbt_icb_cmd_valid )     ,
  //   .o_icb_cmd_ready        (arbt_icb_cmd_ready )     ,
  //   .o_icb_cmd_read         (arbt_icb_cmd_read )      ,
  //   .o_icb_cmd_addr         (arbt_icb_cmd_addr )      ,
  //   .o_icb_cmd_wdata        (arbt_icb_cmd_wdata )     ,
  //   .o_icb_cmd_wmask        (arbt_icb_cmd_wmask)      ,
  //   .o_icb_cmd_burst        (arbt_icb_cmd_burst)     ,
  //   .o_icb_cmd_beat         (arbt_icb_cmd_beat )     ,
  //   .o_icb_cmd_excl         (arbt_icb_cmd_excl )     ,
  //   .o_icb_cmd_lock         (arbt_icb_cmd_lock )     ,
  //   .o_icb_cmd_size         (arbt_icb_cmd_size )     ,
  //   .o_icb_cmd_usr          (arbt_icb_cmd_usr  )     ,
                                  
  //   .o_icb_rsp_valid        (arbt_icb_rsp_valid )     ,
  //   .o_icb_rsp_ready        (arbt_icb_rsp_ready )     ,
  //   .o_icb_rsp_err          (arbt_icb_rsp_err)        ,
  //   .o_icb_rsp_excl_ok      (arbt_icb_rsp_excl_ok)    ,
  //   .o_icb_rsp_rdata        (arbt_icb_rsp_rdata )     ,
  //   .o_icb_rsp_usr          (1'b0   )     ,
                                
  //   .i_bus_icb_cmd_ready    (arbt_bus_icb_cmd_ready ) ,
  //   .i_bus_icb_cmd_valid    (arbt_bus_icb_cmd_valid ) ,
  //   .i_bus_icb_cmd_read     (arbt_bus_icb_cmd_read )  ,
  //   .i_bus_icb_cmd_addr     (arbt_bus_icb_cmd_addr )  ,
  //   .i_bus_icb_cmd_wdata    (arbt_bus_icb_cmd_wdata ) ,
  //   .i_bus_icb_cmd_wmask    (arbt_bus_icb_cmd_wmask)  ,
  //   .i_bus_icb_cmd_burst    (arbt_bus_icb_cmd_burst),
  //   .i_bus_icb_cmd_beat     (arbt_bus_icb_cmd_beat ),
  //   .i_bus_icb_cmd_excl     (arbt_bus_icb_cmd_excl ),
  //   .i_bus_icb_cmd_lock     (arbt_bus_icb_cmd_lock ),
  //   .i_bus_icb_cmd_size     (arbt_bus_icb_cmd_size ),
  //   .i_bus_icb_cmd_usr      (arbt_bus_icb_cmd_usr ),
                                  
  //   .i_bus_icb_rsp_valid    (arbt_bus_icb_rsp_valid ) ,
  //   .i_bus_icb_rsp_ready    (arbt_bus_icb_rsp_ready ) ,
  //   .i_bus_icb_rsp_err      (arbt_bus_icb_rsp_err)    ,
  //   .i_bus_icb_rsp_excl_ok  (arbt_bus_icb_rsp_excl_ok),
  //   .i_bus_icb_rsp_rdata    (arbt_bus_icb_rsp_rdata ) ,
  //   .i_bus_icb_rsp_usr      () ,
                              
  //   .clk                    (clk  )                     ,
  //   .rst_n                  (rst)
  // );

// To breakup the dead-lock cases, when incoming load/store request to the BIU but not granted 
//  This kind of potential deadlock case only happened at the low end core, where the ifetch response
//  provided to IFU, but IFU cannot accept it because it is waiting the IR stage to be cleared, and IR
//  stage is waiting the LSU to be cleared, and LSU is waiting this BIU to be cleared.
// At any mid of high end core (or with multiple oustandings), we definitely will update IFU
//  to make sure it always can accept any oustanding transactions traded with area cost.
// So back to this very low end core, to save areas, we prefetch without knowing if IR can accept
//  the response or not, and also in very low end core it is just 1 oustanding (multiple oustanding 
//  belong to mid or high end core), so to cut off this deadlocks, we just let the BIU to trigger
//  and replay indication if LSU cannot get granted, if IFU just overkilly forced to be replayed, it
//  just lost performance, but we dont care, because in low end core, ifetch to system mem is not
//  guranteed by performance. If IFU really suppose to be replayed, then good luck to break this deadlock.
  //wire ifu_replay_r;
// The IFU replay will be set when:
//    * Accessed by non-IFU access
//    * Or non-IFU access is to access ITCM, but not granted
  //wire ifu_replay_set = (arbt_icb_cmd_valid & arbt_icb_cmd_ready & lsu2biu_icb_cmd_valid)
  //               | (lsu2biu_icb_cmd_valid & (~lsu2biu_icb_cmd_ready));
// The IFU replay will be cleared after accessed by a IFU access
  //wire ifu_replay_clr = (arbt_icb_cmd_valid & arbt_icb_cmd_ready & ifu2biu_icb_cmd_valid);
  //wire ifu_replay_ena = ifu_replay_set | ifu_replay_clr;
  //wire ifu_replay_nxt = ifu_replay_set | (~ifu_replay_clr);
  //sirv_gnrl_dfflr #(1)ifu_replay_dffl(ifu_replay_ena, ifu_replay_nxt, ifu_replay_r, clk, rst);
  //assign ifu2biu_replay = ifu_replay_r;

  wire buf_icb_cmd_valid;
  wire buf_icb_cmd_ready;
  wire [`MYRISCV_ADDRDW-1:0] buf_icb_cmd_addr;
  wire buf_icb_cmd_read;
  wire [`MYRISCV_XLEN-1:0] buf_icb_cmd_wdata;
  wire [`MYRISCV_XLEN/8-1:0] buf_icb_cmd_wmask;
  wire [1:0] buf_icb_cmd_burst;
  wire [1:0] buf_icb_cmd_beat;
  wire buf_icb_cmd_lock;
  wire buf_icb_cmd_excl;
  wire [1:0] buf_icb_cmd_size;
  wire buf_icb_cmd_usr;

  wire buf_icb_cmd_ifu = buf_icb_cmd_usr;

  wire buf_icb_rsp_valid;
  wire buf_icb_rsp_ready;
  wire buf_icb_rsp_err;
  wire buf_icb_rsp_excl_ok;
  wire [`MYRISCV_XLEN-1:0] buf_icb_rsp_rdata;

  wire icb_buffer_active;

  icb_buffer # (
    .OUTS_CNT_W   (`MYRISCV_BIU_BUF_CNTW),
    .AW    (`MYRISCV_ADDRDW),
    .DW    (`MYRISCV_XLEN), 
    .CMD_DP(`MYRISCV_BIU_CMDBUF_DEEP),
    .RSP_DP(`MYRISCV_BIU_RSPBUF_DEEP),
    .CMD_CUT_READY (`MYRISCV_BIU_CMDBUF_CUT_READY),
    .RSP_CUT_READY (`MYRISCV_BIU_RSPBUF_CUT_READY),
    .USR_W (1)
  )u_sirv_gnrl_icb_buffer(
    .icb_buffer_active      (icb_buffer_active),
    .i_icb_cmd_valid        (arbt_icb_cmd_valid),
    .i_icb_cmd_ready        (arbt_icb_cmd_ready),
    .i_icb_cmd_read         (arbt_icb_cmd_read ),
    .i_icb_cmd_addr         (arbt_icb_cmd_addr ),
    .i_icb_cmd_wdata        (arbt_icb_cmd_wdata),
    .i_icb_cmd_wmask        (arbt_icb_cmd_wmask),
    .i_icb_cmd_lock         (arbt_icb_cmd_lock ),
    .i_icb_cmd_excl         (arbt_icb_cmd_excl ),
    .i_icb_cmd_size         (arbt_icb_cmd_size ),
    .i_icb_cmd_burst        (arbt_icb_cmd_burst),
    .i_icb_cmd_beat         (arbt_icb_cmd_beat ),
    .i_icb_cmd_usr          (arbt_icb_cmd_usr  ),
                    
    .i_icb_rsp_valid        (arbt_icb_rsp_valid),
    .i_icb_rsp_ready        (arbt_icb_rsp_ready),
    .i_icb_rsp_err          (arbt_icb_rsp_err  ),
    .i_icb_rsp_excl_ok      (arbt_icb_rsp_excl_ok),
    .i_icb_rsp_rdata        (arbt_icb_rsp_rdata),
    .i_icb_rsp_usr          (),
    
    .o_icb_cmd_valid        (buf_icb_cmd_valid),
    .o_icb_cmd_ready        (buf_icb_cmd_ready),
    .o_icb_cmd_read         (buf_icb_cmd_read ),
    .o_icb_cmd_addr         (buf_icb_cmd_addr ),
    .o_icb_cmd_wdata        (buf_icb_cmd_wdata),
    .o_icb_cmd_wmask        (buf_icb_cmd_wmask),
    .o_icb_cmd_lock         (buf_icb_cmd_lock ),
    .o_icb_cmd_excl         (buf_icb_cmd_excl ),
    .o_icb_cmd_size         (buf_icb_cmd_size ),
    .o_icb_cmd_burst        (buf_icb_cmd_burst),
    .o_icb_cmd_beat         (buf_icb_cmd_beat ),
    .o_icb_cmd_usr          (buf_icb_cmd_usr),
                        
    .o_icb_rsp_valid        (buf_icb_rsp_valid),
    .o_icb_rsp_ready        (buf_icb_rsp_ready),
    .o_icb_rsp_err          (buf_icb_rsp_err  ),
    .o_icb_rsp_excl_ok      (buf_icb_rsp_excl_ok),
    .o_icb_rsp_rdata        (buf_icb_rsp_rdata),
    .o_icb_rsp_usr          (1'b0  ),

    .clk                    (clk  ),
    .rst                    (rst)
  );

  wire [BIU_SPLT_I_NUM*1-1:0] splt_bus_icb_cmd_valid;
  wire [BIU_SPLT_I_NUM*1-1:0] splt_bus_icb_cmd_ready;
  wire [BIU_SPLT_I_NUM*`MYRISCV_ADDRDW-1:0] splt_bus_icb_cmd_addr;
  wire [BIU_SPLT_I_NUM*1-1:0] splt_bus_icb_cmd_read;
  wire [BIU_SPLT_I_NUM*`MYRISCV_XLEN-1:0] splt_bus_icb_cmd_wdata;
  wire [BIU_SPLT_I_NUM*`MYRISCV_XLEN/8-1:0] splt_bus_icb_cmd_wmask;
  wire [BIU_SPLT_I_NUM*2-1:0] splt_bus_icb_cmd_burst;
  wire [BIU_SPLT_I_NUM*2-1:0] splt_bus_icb_cmd_beat;
  wire [BIU_SPLT_I_NUM*1-1:0] splt_bus_icb_cmd_lock;
  wire [BIU_SPLT_I_NUM*1-1:0] splt_bus_icb_cmd_excl;
  wire [BIU_SPLT_I_NUM*2-1:0] splt_bus_icb_cmd_size;

  wire [BIU_SPLT_I_NUM*1-1:0] splt_bus_icb_rsp_valid;
  wire [BIU_SPLT_I_NUM*1-1:0] splt_bus_icb_rsp_ready;
  wire [BIU_SPLT_I_NUM*1-1:0] splt_bus_icb_rsp_err;
  wire [BIU_SPLT_I_NUM*1-1:0] splt_bus_icb_rsp_excl_ok;
  wire [BIU_SPLT_I_NUM*`MYRISCV_XLEN-1:0] splt_bus_icb_rsp_rdata;

  //CMD Channel
  assign {
                            ifuerr_icb_cmd_valid
                          , ppi_icb_cmd_valid
                          , clint_icb_cmd_valid
                          , plic_icb_cmd_valid
                          `ifdef MYRISCV_HAS_FIO //{
                          , fio_icb_cmd_valid
                          `endif//}
                          `ifdef MYRISCV_HAS_MEM_ITF //{
                          , mem_icb_cmd_valid
                          `endif//}
                          } = splt_bus_icb_cmd_valid;

  assign {
                            ifuerr_icb_cmd_addr
                          , ppi_icb_cmd_addr
                          , clint_icb_cmd_addr
                          , plic_icb_cmd_addr
                          `ifdef MYRISCV_HAS_FIO //{
                          , fio_icb_cmd_addr
                          `endif//}
                          `ifdef MYRISCV_HAS_MEM_ITF //{
                          , mem_icb_cmd_addr
                          `endif//}
                          } = splt_bus_icb_cmd_addr;

  assign {
                            ifuerr_icb_cmd_read
                          , ppi_icb_cmd_read
                          , clint_icb_cmd_read
                          , plic_icb_cmd_read
                          `ifdef MYRISCV_HAS_FIO //{
                          , fio_icb_cmd_read
                          `endif//}
                          `ifdef MYRISCV_HAS_MEM_ITF //{
                          , mem_icb_cmd_read
                          `endif//}
                          } = splt_bus_icb_cmd_read;

  assign {
                            ifuerr_icb_cmd_wdata
                          , ppi_icb_cmd_wdata
                          , clint_icb_cmd_wdata
                          , plic_icb_cmd_wdata
                          `ifdef MYRISCV_HAS_FIO //{
                          , fio_icb_cmd_wdata
                          `endif//}
                          `ifdef MYRISCV_HAS_MEM_ITF //{
                          , mem_icb_cmd_wdata
                          `endif//}
                          } = splt_bus_icb_cmd_wdata;

  assign {
                            ifuerr_icb_cmd_wmask
                          , ppi_icb_cmd_wmask
                          , clint_icb_cmd_wmask
                          , plic_icb_cmd_wmask
                          `ifdef MYRISCV_HAS_FIO //{
                          , fio_icb_cmd_wmask
                          `endif//}
                          `ifdef MYRISCV_HAS_MEM_ITF //{
                          , mem_icb_cmd_wmask
                          `endif//}
                          } = splt_bus_icb_cmd_wmask;
                        
  assign {
                            ifuerr_icb_cmd_burst
                          , ppi_icb_cmd_burst
                          , clint_icb_cmd_burst
                          , plic_icb_cmd_burst
                          `ifdef MYRISCV_HAS_FIO //{
                          , fio_icb_cmd_burst
                          `endif//}
                          `ifdef MYRISCV_HAS_MEM_ITF //{
                          , mem_icb_cmd_burst
                          `endif//}
                          } = splt_bus_icb_cmd_burst;
                        
  assign {
                            ifuerr_icb_cmd_beat
                          , ppi_icb_cmd_beat
                          , clint_icb_cmd_beat
                          , plic_icb_cmd_beat
                          `ifdef MYRISCV_HAS_FIO //{
                          , fio_icb_cmd_beat
                          `endif//}
                          `ifdef MYRISCV_HAS_MEM_ITF //{
                          , mem_icb_cmd_beat
                          `endif//}
                          } = splt_bus_icb_cmd_beat;
                        
  assign {
                            ifuerr_icb_cmd_lock
                          , ppi_icb_cmd_lock
                          , clint_icb_cmd_lock
                          , plic_icb_cmd_lock
                          `ifdef MYRISCV_HAS_FIO //{
                          , fio_icb_cmd_lock
                          `endif//}
                          `ifdef MYRISCV_HAS_MEM_ITF //{
                          , mem_icb_cmd_lock
                          `endif//}
                          } = splt_bus_icb_cmd_lock;

  assign {
                            ifuerr_icb_cmd_excl
                          , ppi_icb_cmd_excl
                          , clint_icb_cmd_excl
                          , plic_icb_cmd_excl
                          `ifdef MYRISCV_HAS_FIO //{
                          , fio_icb_cmd_excl
                          `endif//}
                          `ifdef MYRISCV_HAS_MEM_ITF //{
                          , mem_icb_cmd_excl
                          `endif//}
                          } = splt_bus_icb_cmd_excl;
                          
  assign {
                            ifuerr_icb_cmd_size
                          , ppi_icb_cmd_size
                          , clint_icb_cmd_size
                          , plic_icb_cmd_size
                          `ifdef MYRISCV_HAS_FIO //{
                          , fio_icb_cmd_size
                          `endif//}
                          `ifdef MYRISCV_HAS_MEM_ITF //{
                          , mem_icb_cmd_size
                          `endif//}
                          } = splt_bus_icb_cmd_size;

  assign splt_bus_icb_cmd_ready = {
                            ifuerr_icb_cmd_ready
                          , ppi_icb_cmd_ready
                          , clint_icb_cmd_ready
                          , plic_icb_cmd_ready
                          `ifdef MYRISCV_HAS_FIO //{
                          , fio_icb_cmd_ready
                          `endif//}
                          `ifdef MYRISCV_HAS_MEM_ITF //{
                          , mem_icb_cmd_ready
                          `endif//}
                          };

  //RSP Channel
  assign splt_bus_icb_rsp_valid = {
                            ifuerr_icb_rsp_valid
                          , ppi_icb_rsp_valid
                          , clint_icb_rsp_valid
                          , plic_icb_rsp_valid
                          `ifdef MYRISCV_HAS_FIO //{
                          , fio_icb_rsp_valid
                          `endif//}
                          `ifdef MYRISCV_HAS_MEM_ITF //{
                          , mem_icb_rsp_valid
                          `endif//}
                          };

  assign splt_bus_icb_rsp_err = {
                            ifuerr_icb_rsp_err
                          , ppi_icb_rsp_err
                          , clint_icb_rsp_err
                          , plic_icb_rsp_err
                          `ifdef MYRISCV_HAS_FIO //{
                          , fio_icb_rsp_err
                          `endif//}
                          `ifdef MYRISCV_HAS_MEM_ITF //{
                          , mem_icb_rsp_err
                          `endif//}
                          };

  assign splt_bus_icb_rsp_excl_ok = {
                            ifuerr_icb_rsp_excl_ok
                          , ppi_icb_rsp_excl_ok
                          , clint_icb_rsp_excl_ok
                          , plic_icb_rsp_excl_ok
                          `ifdef MYRISCV_HAS_FIO //{
                          , fio_icb_rsp_excl_ok
                          `endif//}
                          `ifdef MYRISCV_HAS_MEM_ITF //{
                          , mem_icb_rsp_excl_ok
                          `endif//}
                          };

  assign splt_bus_icb_rsp_rdata = {
                            ifuerr_icb_rsp_rdata
                          , ppi_icb_rsp_rdata
                          , clint_icb_rsp_rdata
                          , plic_icb_rsp_rdata
                          `ifdef MYRISCV_HAS_FIO //{
                          , fio_icb_rsp_rdata
                          `endif//}
                          `ifdef MYRISCV_HAS_MEM_ITF //{
                          , mem_icb_rsp_rdata
                          `endif//}
                          };

  assign {
                            ifuerr_icb_rsp_ready
                          , ppi_icb_rsp_ready
                          , clint_icb_rsp_ready
                          , plic_icb_rsp_ready
                          `ifdef MYRISCV_HAS_FIO //{
                          , fio_icb_rsp_ready
                          `endif//}
                          `ifdef MYRISCV_HAS_MEM_ITF //{
                          , mem_icb_rsp_ready
                          `endif//}
                          } = splt_bus_icb_rsp_ready;
//r:通过更改几个REGION宏定义，可以确定判定使用哪些位，而输入的ppi_region_indix等则是器件的地址索引。比如判断addr的高5位是不是5'b00001来确定是不是某个器件的访问。
  // wire buf_icb_cmd_ppi = ppi_icb_enable & (buf_icb_cmd_addr[`E203_PPI_BASE_REGION] ==  ppi_region_indic[`E203_PPI_BASE_REGION]);
  wire buf_icb_cmd_ppi = ppi_icb_enable & (buf_icb_cmd_addr[`PPI_REGION_ADDRBUS] == `PPI_REGION_INDIC);
  wire buf_icb_sel_ppi = buf_icb_cmd_ppi & (~buf_icb_cmd_ifu);

  // wire buf_icb_cmd_clint = clint_icb_enable & (buf_icb_cmd_addr[`E203_CLINT_BASE_REGION] ==  clint_region_indic[`E203_CLINT_BASE_REGION]);
  wire buf_icb_cmd_clint = clint_icb_enable & (buf_icb_cmd_addr[`CLINT_REGION_ADDRBUS] == `CLINT_REGION_INDIC);
  wire buf_icb_sel_clint = buf_icb_cmd_clint & (~buf_icb_cmd_ifu);

  // wire buf_icb_cmd_plic = plic_icb_enable & (buf_icb_cmd_addr[`E203_PLIC_BASE_REGION] ==  plic_region_indic[`E203_PLIC_BASE_REGION]);
  wire buf_icb_cmd_plic = plic_icb_enable & (buf_icb_cmd_addr[`PLIC_REGION_ADDRBUS] == `PLIC_REGION_INDIC);
  wire buf_icb_sel_plic = buf_icb_cmd_plic & (~buf_icb_cmd_ifu);

  `ifdef MYRISCV_HAS_FIO //{
  // wire buf_icb_cmd_fio = fio_icb_enable & (buf_icb_cmd_addr[`E203_FIO_BASE_REGION] ==  fio_region_indic[`E203_FIO_BASE_REGION]);
  wire buf_icb_cmd_fio = fio_icb_enable & (buf_icb_cmd_addr[`FIO_REGION_ADDRBUS] == `FIO_REGION_INDIC);
  wire buf_icb_sel_fio = buf_icb_cmd_fio & (~buf_icb_cmd_ifu);
  `endif//}

  wire buf_icb_sel_ifuerr =( //r:ifu取指越界判断，如果访问来自ifu，访问对象却是ppi，clint等，就是明显越界了!!!
                            buf_icb_cmd_ppi 
                          | buf_icb_cmd_clint 
                          | buf_icb_cmd_plic
                          `ifdef MYRISCV_HAS_FIO //{
                          | buf_icb_cmd_fio
                          `endif//}
                          ) & buf_icb_cmd_ifu;
`ifdef PLATFORM_SIM
  `ifdef USE_DPIC
    import "DPI-C" function void IFU_OVERFLOW(input bit[`MYRISCV_ADDRBUS] addr_i, input bit Read, 
      input bit[`MYRISCV_DATABUS] data_i, input bit[`MYRISCV_DATADW/8-1 : 0] mask_i);
    always@(posedge buf_icb_sel_ifuerr) begin
      IFU_OVERFLOW(buf_icb_cmd_addr, buf_icb_cmd_read, buf_icb_cmd_wdata, buf_icb_cmd_wmask);
      # 50
      $finish;
    end
  `else
    always@(posedge buf_icb_sel_ifuerr) begin
      $display("(%t) Error! ifu req overflow the mem region! Addr: %x",$time, buf_icb_cmd_addr);
      # 50
      $finish;
    end
  `endif
`endif

`ifdef MYRISCV_HAS_MEM_ITF //{
  //r:只要访问地址不是特定区域，统一发配到mem接口，至于mem有没有这个地址就不知道了。。。。这其实很危险，所以一定要在mem部分做判断，在仿真时就发现问题！
  wire buf_icb_sel_mem = mem_icb_enable 
                            & (~buf_icb_sel_ifuerr)
                            & (~buf_icb_sel_ppi)
                            & (~buf_icb_sel_clint)
                            & (~buf_icb_sel_plic)
                          `ifdef MYRISCV_HAS_FIO //{
                            & (~buf_icb_sel_fio)
                          `endif//}
                            ;
`endif//}

  wire [BIU_SPLT_I_NUM-1:0] buf_icb_splt_indic = 
      {
                            buf_icb_sel_ifuerr
                          , buf_icb_sel_ppi
                          , buf_icb_sel_clint
                          , buf_icb_sel_plic
                          `ifdef MYRISCV_HAS_FIO //{
                          , buf_icb_sel_fio
                          `endif//}
                          `ifdef MYRISCV_HAS_MEM_ITF //{
                          , buf_icb_sel_mem
                          `endif//}
      };

  splt_me # (
    .ALLOW_DIFF (0),// Dont allow different branches oustanding
    .ALLOW_0CYCL_RSP (0),// Allow the 0 cycle response because in BIU the splt
                        //  is after the buffer, and will directly talk to the external
                        //  bus, where maybe the ROM is 0 cycle responsed.
    .FIFO_DP    (`MYRISCV_BIU_OUTFIFO_DEEP),
    .FIFO_CUT_READY  (`MYRISCV_BIU_SPLT_FIFO_CUT_READY),
    .SPLT_NUM   (BIU_SPLT_I_NUM),
    .USR_W      (1),
    .AW         (`MYRISCV_ADDRDW),
    .DW         (`MYRISCV_XLEN) 
  ) u_biu_icb_splt(
    .i_icb_splt_sel       (buf_icb_splt_indic),        

    .i_icb_cmd_vld        (buf_icb_cmd_valid )     ,
    .i_icb_cmd_rdy        (buf_icb_cmd_ready )     ,
    .i_icb_cmd_read         (buf_icb_cmd_read )      ,
    .i_icb_cmd_addr         (buf_icb_cmd_addr )      ,
    .i_icb_cmd_wdata        (buf_icb_cmd_wdata )     ,
    .i_icb_cmd_wmask        (buf_icb_cmd_wmask)      ,
    // .i_icb_cmd_burst        (buf_icb_cmd_burst)     ,
    // .i_icb_cmd_beat         (buf_icb_cmd_beat )     ,
    // .i_icb_cmd_excl         (buf_icb_cmd_excl )     ,
    // .i_icb_cmd_lock         (buf_icb_cmd_lock )     ,
    // .i_icb_cmd_size         (buf_icb_cmd_size )     ,
    .i_icb_cmd_usr          (1'b0   )     ,
  
    .i_icb_rsp_vld        (buf_icb_rsp_valid )     ,
    .i_icb_rsp_rdy        (buf_icb_rsp_ready )     ,
    .i_icb_rsp_err          (buf_icb_rsp_err)        ,
    // .i_icb_rsp_excl_ok      (buf_icb_rsp_excl_ok)    ,
    .i_icb_rsp_rdata        (buf_icb_rsp_rdata )     ,
    .i_icb_rsp_usr          ( )     ,
                                
    .o_bus_icb_cmd_rdy    (splt_bus_icb_cmd_ready ) ,
    .o_bus_icb_cmd_vld    (splt_bus_icb_cmd_valid ) ,
    .o_bus_icb_cmd_read     (splt_bus_icb_cmd_read )  ,
    .o_bus_icb_cmd_addr     (splt_bus_icb_cmd_addr )  ,
    .o_bus_icb_cmd_wdata    (splt_bus_icb_cmd_wdata ) ,
    .o_bus_icb_cmd_wmask    (splt_bus_icb_cmd_wmask)  ,
    // .o_bus_icb_cmd_burst    (splt_bus_icb_cmd_burst),
    // .o_bus_icb_cmd_beat     (splt_bus_icb_cmd_beat ),
    // .o_bus_icb_cmd_excl     (splt_bus_icb_cmd_excl ),
    // .o_bus_icb_cmd_lock     (splt_bus_icb_cmd_lock ),
    // .o_bus_icb_cmd_size     (splt_bus_icb_cmd_size ),
    .o_bus_icb_cmd_usr      ()     ,
    
    .o_bus_icb_rsp_vld    (splt_bus_icb_rsp_valid ) ,
    .o_bus_icb_rsp_rdy    (splt_bus_icb_rsp_ready ) ,
    .o_bus_icb_rsp_err      (splt_bus_icb_rsp_err)    ,
    // .o_bus_icb_rsp_excl_ok  (splt_bus_icb_rsp_excl_ok),
    .o_bus_icb_rsp_rdata    (splt_bus_icb_rsp_rdata ) ,
    .o_bus_icb_rsp_usr      ({BIU_SPLT_I_NUM{1'b0}}) ,
                              
    .clk                    (clk  )                     ,
    .rst                    (rst)
  );


  assign biu_active = ifu2biu_icb_cmd_valid | lsu2biu_icb_cmd_valid | icb_buffer_active; 


  // Implement the IFU-accessed-Peripheral region error
  assign  ifuerr_icb_cmd_ready = ifuerr_icb_rsp_ready;
  
    // 0 Cycle response
  assign  ifuerr_icb_rsp_valid = ifuerr_icb_cmd_valid;
  assign  ifuerr_icb_rsp_err   = 1'b1;
  assign  ifuerr_icb_rsp_excl_ok = 1'b0;
  assign  ifuerr_icb_rsp_rdata   = {`MYRISCV_XLEN{1'b0}};


endmodule

