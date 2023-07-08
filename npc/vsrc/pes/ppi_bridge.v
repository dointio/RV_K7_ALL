`include "mydefines.v"

module ppi_bridge # (
    parameter ICB_FIFO_DP = 2, // This is to optionally add the pipeline stage for ICB bus
                                //   if the depth is 0, then means pass through, not add pipeline
                                //   if the depth is 2, then means added one ping-pong buffer stage
    parameter ICB_FIFO_CUT_READY = 1, // This is to cut the back-pressure signal if you set as 1

    parameter AW = 32,
    parameter DW = 32,
    parameter SPLT_FIFO_OUTS_NUM    = 2,
    parameter SPLT_FIFO_CUT_READY   = 1
)(
    //o: input port
    input                          i_icb_cmd_valid,
    output                         i_icb_cmd_ready,
    input  [AW-1:0]                i_icb_cmd_addr, 
    input                          i_icb_cmd_read, 
    input  [2-1:0]                 i_icb_cmd_burst,
    input  [2-1:0]                 i_icb_cmd_beat,
    input  [DW-1:0]                i_icb_cmd_wdata,
    input  [DW/8-1:0]              i_icb_cmd_wmask,
    input                          i_icb_cmd_lock,
    input                          i_icb_cmd_excl,
    input  [1:0]                   i_icb_cmd_size,

    output                         i_icb_rsp_valid,
    input                          i_icb_rsp_ready,
    output                         i_icb_rsp_err  ,
    output                         i_icb_rsp_excl_ok,
    output [DW-1:0]                i_icb_rsp_rdata,
    //o: gpioa_port(st)
    input                         gpioa_icb_enable,
    output                        gpioa_icb_cmd_valid,
    input                         gpioa_icb_cmd_ready,
    output [AW-1:0]               gpioa_icb_cmd_addr, 
    output                        gpioa_icb_cmd_read, 
    output [2-1:0]                gpioa_icb_cmd_burst,
    output [2-1:0]                gpioa_icb_cmd_beat,
    output [DW-1:0]               gpioa_icb_cmd_wdata,
    output [DW/8-1:0]             gpioa_icb_cmd_wmask,
    output                        gpioa_icb_cmd_lock,
    output                        gpioa_icb_cmd_excl,
    output [1:0]                  gpioa_icb_cmd_size,

    input                         gpioa_icb_rsp_valid,
    output                        gpioa_icb_rsp_ready,
    input                         gpioa_icb_rsp_err  ,
    input                         gpioa_icb_rsp_excl_ok,
    input  [DW-1:0]               gpioa_icb_rsp_rdata,
    //o: gpioa_port(end)

    //o: uart_port(st)
    input                         uart_icb_enable,
    output                        uart_icb_cmd_valid,
    input                         uart_icb_cmd_ready,
    output [AW-1:0]               uart_icb_cmd_addr, 
    output                        uart_icb_cmd_read, 
    output [2-1:0]                uart_icb_cmd_burst,
    output [2-1:0]                uart_icb_cmd_beat,
    output [DW-1:0]               uart_icb_cmd_wdata,
    output [DW/8-1:0]             uart_icb_cmd_wmask,
    output                        uart_icb_cmd_lock,
    output                        uart_icb_cmd_excl,
    output [1:0]                  uart_icb_cmd_size,

    input                         uart_icb_rsp_valid,
    output                        uart_icb_rsp_ready,
    input                         uart_icb_rsp_err  ,
    input                         uart_icb_rsp_excl_ok,
    input  [DW-1:0]               uart_icb_rsp_rdata,
    //o: uart_port(end)

    //o: timer_port(st)
    input                         timer_icb_enable,
    output                        timer_icb_cmd_valid,
    input                         timer_icb_cmd_ready,
    output [AW-1:0]               timer_icb_cmd_addr, 
    output                        timer_icb_cmd_read, 
    output [2-1:0]                timer_icb_cmd_burst,
    output [2-1:0]                timer_icb_cmd_beat,
    output [DW-1:0]               timer_icb_cmd_wdata,
    output [DW/8-1:0]             timer_icb_cmd_wmask,
    output                        timer_icb_cmd_lock,
    output                        timer_icb_cmd_excl,
    output [1:0]                  timer_icb_cmd_size,

    input                         timer_icb_rsp_valid,
    output                        timer_icb_rsp_ready,
    input                         timer_icb_rsp_err  ,
    input                         timer_icb_rsp_excl_ok,
    input  [DW-1:0]               timer_icb_rsp_rdata,
    //o: timer_port(end)

    //o: simple_gpu_port(st)
    input                         simple_gpu_icb_enable,
    output                        simple_gpu_icb_cmd_valid,
    input                         simple_gpu_icb_cmd_ready,
    output [AW-1:0]               simple_gpu_icb_cmd_addr, 
    output                        simple_gpu_icb_cmd_read, 
    output [2-1:0]                simple_gpu_icb_cmd_burst,
    output [2-1:0]                simple_gpu_icb_cmd_beat,
    output [DW-1:0]               simple_gpu_icb_cmd_wdata,
    output [DW/8-1:0]             simple_gpu_icb_cmd_wmask,
    output                        simple_gpu_icb_cmd_lock,
    output                        simple_gpu_icb_cmd_excl,
    output [1:0]                  simple_gpu_icb_cmd_size,

    input                         simple_gpu_icb_rsp_valid,
    output                        simple_gpu_icb_rsp_ready,
    input                         simple_gpu_icb_rsp_err  ,
    input                         simple_gpu_icb_rsp_excl_ok,
    input  [DW-1:0]               simple_gpu_icb_rsp_rdata,
    //o: simple_gpu_port(end)
    

    input  clk,
    input  rst
);

    wire                         buf_icb_cmd_valid;
    wire                         buf_icb_cmd_ready;
    wire [             AW-1:0]   buf_icb_cmd_addr; 
    wire                         buf_icb_cmd_read; 
    wire [2-1:0]                 buf_icb_cmd_burst;
    wire [2-1:0]                 buf_icb_cmd_beat;
    wire [        DW-1:0]        buf_icb_cmd_wdata;
    wire [        DW/8-1:0]      buf_icb_cmd_wmask;
    wire                         buf_icb_cmd_lock;
    wire                         buf_icb_cmd_excl;
    wire [1:0]                   buf_icb_cmd_size;

    wire                         buf_icb_rsp_valid;
    wire                         buf_icb_rsp_ready;
    wire                         buf_icb_rsp_err  ;
    wire                         buf_icb_rsp_excl_ok;
    wire [        DW-1:0]        buf_icb_rsp_rdata;

    icb_buffer # (
        .OUTS_CNT_W   (SPLT_FIFO_OUTS_NUM),
        .AW    (AW),
        .DW    (DW), 
        .CMD_DP(ICB_FIFO_DP),
        .RSP_DP(ICB_FIFO_DP),
        .CMD_CUT_READY (ICB_FIFO_CUT_READY),
        .RSP_CUT_READY (ICB_FIFO_CUT_READY),
        .USR_W (1)
    )u_sirv_gnrl_icb_buffer(
        .icb_buffer_active      (),
        .i_icb_cmd_valid        (i_icb_cmd_valid),
        .i_icb_cmd_ready        (i_icb_cmd_ready),
        .i_icb_cmd_read         (i_icb_cmd_read ),
        .i_icb_cmd_addr         (i_icb_cmd_addr ),
        .i_icb_cmd_wdata        (i_icb_cmd_wdata),
        .i_icb_cmd_wmask        (i_icb_cmd_wmask),
        .i_icb_cmd_lock         (i_icb_cmd_lock ),
        .i_icb_cmd_excl         (i_icb_cmd_excl ),
        .i_icb_cmd_size         (i_icb_cmd_size ),
        .i_icb_cmd_burst        (i_icb_cmd_burst),
        .i_icb_cmd_beat         (i_icb_cmd_beat ),
        .i_icb_cmd_usr          (1'b0  ),
                        
        .i_icb_rsp_valid        (i_icb_rsp_valid),
        .i_icb_rsp_ready        (i_icb_rsp_ready),
        .i_icb_rsp_err          (i_icb_rsp_err  ),
        .i_icb_rsp_excl_ok      (i_icb_rsp_excl_ok),
        .i_icb_rsp_rdata        (i_icb_rsp_rdata),
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
        .o_icb_cmd_usr          (),
                            
        .o_icb_rsp_valid        (buf_icb_rsp_valid),
        .o_icb_rsp_ready        (buf_icb_rsp_ready),
        .o_icb_rsp_err          (buf_icb_rsp_err  ),
        .o_icb_rsp_excl_ok      (buf_icb_rsp_excl_ok),
        .o_icb_rsp_rdata        (buf_icb_rsp_rdata),
        .o_icb_rsp_usr          (1'b0  ),

        .clk                    (clk  ),
        .rst                    (rst)
    );

    localparam SPLT_I_NUM = 5;//include deft_icb(error_return port)

    wire                         deft_icb_cmd_valid;
    wire                         deft_icb_cmd_ready;
    wire [             AW-1:0]   deft_icb_cmd_addr; 
    wire                         deft_icb_cmd_read; 
    wire [2-1:0]                 deft_icb_cmd_burst;
    wire [2-1:0]                 deft_icb_cmd_beat;
    wire [        DW-1:0]        deft_icb_cmd_wdata;
    wire [        DW/8-1:0]      deft_icb_cmd_wmask;
    wire                         deft_icb_cmd_lock;
    wire                         deft_icb_cmd_excl;
    wire [1:0]                   deft_icb_cmd_size;

    wire                         deft_icb_rsp_valid;
    wire                         deft_icb_rsp_ready;
    wire                         deft_icb_rsp_err  ;
    wire                         deft_icb_rsp_excl_ok;
    wire [        DW-1:0]        deft_icb_rsp_rdata;

    wire [SPLT_I_NUM*1-1:0]   splt_bus_icb_cmd_valid;
    wire [SPLT_I_NUM*1-1:0]   splt_bus_icb_cmd_ready;
    wire [SPLT_I_NUM*AW-1:0]  splt_bus_icb_cmd_addr;
    wire [SPLT_I_NUM*1-1:0]   splt_bus_icb_cmd_read;
    wire [SPLT_I_NUM*2-1:0]   splt_bus_icb_cmd_burst;
    wire [SPLT_I_NUM*2-1:0]   splt_bus_icb_cmd_beat;
    wire [SPLT_I_NUM*DW-1:0]    splt_bus_icb_cmd_wdata;
    wire [SPLT_I_NUM*DW/8-1:0]  splt_bus_icb_cmd_wmask;
    wire [SPLT_I_NUM*1-1:0]   splt_bus_icb_cmd_lock;
    wire [SPLT_I_NUM*1-1:0]   splt_bus_icb_cmd_excl;
    wire [SPLT_I_NUM*2-1:0]   splt_bus_icb_cmd_size;

    wire [SPLT_I_NUM*1-1:0] splt_bus_icb_rsp_valid;
    wire [SPLT_I_NUM*1-1:0] splt_bus_icb_rsp_ready;
    wire [SPLT_I_NUM*1-1:0] splt_bus_icb_rsp_err;
    wire [SPLT_I_NUM*1-1:0] splt_bus_icb_rsp_excl_ok;
    wire [SPLT_I_NUM*DW-1:0] splt_bus_icb_rsp_rdata;

    //CMD Channel
    assign {
                                gpioa_icb_cmd_valid
                            ,uart_icb_cmd_valid
                            ,timer_icb_cmd_valid
                            ,simple_gpu_icb_cmd_valid
                            ,deft_icb_cmd_valid
                            } = splt_bus_icb_cmd_valid;

    assign {
                                gpioa_icb_cmd_addr
                            ,uart_icb_cmd_addr
                            ,timer_icb_cmd_addr
                            ,simple_gpu_icb_cmd_addr
                            ,deft_icb_cmd_addr
                            } = splt_bus_icb_cmd_addr;

    assign {
                                gpioa_icb_cmd_read
                            ,uart_icb_cmd_read
                            ,timer_icb_cmd_read
                            ,simple_gpu_icb_cmd_read
                            ,deft_icb_cmd_read
                            } = splt_bus_icb_cmd_read;

    assign {
                                gpioa_icb_cmd_burst
                            ,uart_icb_cmd_burst
                            ,timer_icb_cmd_burst
                            ,simple_gpu_icb_cmd_burst
                            ,deft_icb_cmd_burst
                            } = splt_bus_icb_cmd_burst;

    assign {
                                gpioa_icb_cmd_beat
                            ,uart_icb_cmd_beat
                            ,timer_icb_cmd_beat
                            ,simple_gpu_icb_cmd_beat
                            ,deft_icb_cmd_beat                  
                            } = splt_bus_icb_cmd_beat;

    assign {
                                gpioa_icb_cmd_wdata
                            ,uart_icb_cmd_wdata
                            ,timer_icb_cmd_wdata
                            ,simple_gpu_icb_cmd_wdata
                            ,deft_icb_cmd_wdata
                            } = splt_bus_icb_cmd_wdata;

    assign {
                                gpioa_icb_cmd_wmask
                            ,uart_icb_cmd_wmask
                            ,timer_icb_cmd_wmask
                            ,simple_gpu_icb_cmd_wmask
                            ,deft_icb_cmd_wmask
                            } = splt_bus_icb_cmd_wmask;
                            
    assign {
                                gpioa_icb_cmd_lock
                            ,uart_icb_cmd_lock
                            ,timer_icb_cmd_lock
                            ,simple_gpu_icb_cmd_lock
                            ,deft_icb_cmd_lock
                            } = splt_bus_icb_cmd_lock;

    assign {
                                gpioa_icb_cmd_excl
                            ,uart_icb_cmd_excl
                            ,timer_icb_cmd_excl
                            ,simple_gpu_icb_cmd_excl
                            ,deft_icb_cmd_excl
                            } = splt_bus_icb_cmd_excl;
                            
    assign {
                                gpioa_icb_cmd_size
                            ,uart_icb_cmd_size
                            ,timer_icb_cmd_size
                            ,simple_gpu_icb_cmd_size
                            ,deft_icb_cmd_size
                            } = splt_bus_icb_cmd_size;

    assign splt_bus_icb_cmd_ready = {
                                gpioa_icb_cmd_ready
                            ,uart_icb_cmd_ready
                            ,timer_icb_cmd_ready
                            ,simple_gpu_icb_cmd_ready
                            ,deft_icb_cmd_ready
                            };

    //RSP Channel
    assign splt_bus_icb_rsp_valid = {
                                gpioa_icb_rsp_valid
                            ,uart_icb_rsp_valid
                            ,timer_icb_rsp_valid
                            ,simple_gpu_icb_rsp_valid
                            ,deft_icb_rsp_valid
                            };

    assign splt_bus_icb_rsp_err = {
                                gpioa_icb_rsp_err
                            ,uart_icb_rsp_err
                            ,timer_icb_rsp_err
                            ,simple_gpu_icb_rsp_err
                            ,deft_icb_rsp_err
                            };

    assign splt_bus_icb_rsp_excl_ok = {
                                gpioa_icb_rsp_excl_ok
                            ,uart_icb_rsp_excl_ok
                            ,timer_icb_rsp_excl_ok
                            ,simple_gpu_icb_rsp_excl_ok
                            ,deft_icb_rsp_excl_ok
                            };

    assign splt_bus_icb_rsp_rdata = {
                                gpioa_icb_rsp_rdata
                            ,uart_icb_rsp_rdata
                            ,timer_icb_rsp_rdata
                            ,simple_gpu_icb_rsp_rdata
                            ,deft_icb_rsp_rdata
                            };

    assign {
                                gpioa_icb_rsp_ready
                            ,uart_icb_rsp_ready
                            ,timer_icb_rsp_ready
                            ,simple_gpu_icb_rsp_ready
                            ,deft_icb_rsp_ready
                            } = splt_bus_icb_rsp_ready;

    //o: cmd_sig
    wire icb_cmd_gpioa = buf_icb_cmd_valid & (buf_icb_cmd_addr[`PPI_GPIOA_REGION_ADDRBUS] 
                        == `PPI_GPIOA_REGION_INDIC
                        ) & gpioa_icb_enable;
    
    wire icb_cmd_uart  = buf_icb_cmd_valid * (
                            (buf_icb_cmd_addr[`PPI_UART_REGION_ADDRBUS] >= `PPI_UART_REGION_INDIC_L) &
                            (buf_icb_cmd_addr[`PPI_UART_REGION_ADDRBUS] <= `PPI_UART_REGION_INDIC_H)
                        ) & uart_icb_enable;

    wire icb_cmd_timer = buf_icb_cmd_valid & (
                            (buf_icb_cmd_addr[`PPI_TIMER_REGION_ADDRBUS] >= `PPI_TIMER_REGION_INDIC_L) &
                            (buf_icb_cmd_addr[`PPI_TIMER_REGION_ADDRBUS] <= `PPI_TIMER_REGION_INDIC_H)
                        ) & timer_icb_enable;
    
    wire icb_cmd_simple_gpu =   buf_icb_cmd_valid & (
                                    (buf_icb_cmd_addr[`PPI_SGPU_REGION_ADDRBUS_ONE] == `PPI_SGPU_REGION_INDIC_ONE) |
                                    (buf_icb_cmd_addr[`PPI_SGPU_REGION_ADDRBUS_TWO] == `PPI_SGPU_REGION_INDIC_TWO)
                                ) & simple_gpu_icb_enable;

    wire icb_cmd_deft = (~icb_cmd_gpioa)
                        & (~icb_cmd_uart)
                        & (~icb_cmd_timer)
                        & (~icb_cmd_simple_gpu)
                        ;

    wire [SPLT_I_NUM-1:0] buf_icb_splt_indic = 
        {
                        icb_cmd_gpioa
                        , icb_cmd_uart
                        , icb_cmd_timer
                        , icb_cmd_simple_gpu
                        , icb_cmd_deft
        };

    splt_mux # (
        .ALLOW_DIFFER_CHANNEL (1),// Dont allow different branches oustanding
        .ALLOW_0CYCL_RSP (1),// Allow the 0 cycle response because in BIU the splt
                            //  is after the buffer, and will directly talk to the external
                            //  bus, where maybe the ROM is 0 cycle responsed.
        .FIFO_OUTS_NUM   (SPLT_FIFO_OUTS_NUM ),
        // .FIFO_CUT_READY  (SPLT_FIFO_CUT_READY),
        .FIFO_CUT_READY   (1),
        .SPLT_NUM   (SPLT_I_NUM),
        .SPLT_PTR_W (SPLT_I_NUM),
        .SPLT_PTR_1HOT (1),
        .VLD_MSK_PAYLOAD(1),
        .USR_W      (1),
        .AW         (AW),
        .DW         (DW) 
    ) u_buf_icb_splt(
        .i_icb_splt_indic       (buf_icb_splt_indic),        

        .i_icb_cmd_valid        (buf_icb_cmd_valid )     ,
        .i_icb_cmd_ready        (buf_icb_cmd_ready )     ,
        .i_icb_cmd_read         (buf_icb_cmd_read )      ,
        .i_icb_cmd_addr         (buf_icb_cmd_addr )      ,
        .i_icb_cmd_wdata        (buf_icb_cmd_wdata )     ,
        .i_icb_cmd_wmask        (buf_icb_cmd_wmask)      ,
        .i_icb_cmd_burst        (buf_icb_cmd_burst)     ,
        .i_icb_cmd_beat         (buf_icb_cmd_beat )     ,
        .i_icb_cmd_excl         (buf_icb_cmd_excl )     ,
        .i_icb_cmd_lock         (buf_icb_cmd_lock )     ,
        .i_icb_cmd_size         (buf_icb_cmd_size )     ,
        .i_icb_cmd_usr          (1'b0)     ,

        .i_icb_rsp_valid        (buf_icb_rsp_valid )     ,
        .i_icb_rsp_ready        (buf_icb_rsp_ready )     ,
        .i_icb_rsp_err          (buf_icb_rsp_err)        ,
        .i_icb_rsp_excl_ok      (buf_icb_rsp_excl_ok)    ,
        .i_icb_rsp_rdata        (buf_icb_rsp_rdata )     ,
        .i_icb_rsp_usr          ( )     ,
                                    
        .o_bus_icb_cmd_ready    (splt_bus_icb_cmd_ready ) ,
        .o_bus_icb_cmd_valid    (splt_bus_icb_cmd_valid ) ,
        .o_bus_icb_cmd_read     (splt_bus_icb_cmd_read )  ,
        .o_bus_icb_cmd_addr     (splt_bus_icb_cmd_addr )  ,
        .o_bus_icb_cmd_wdata    (splt_bus_icb_cmd_wdata ) ,
        .o_bus_icb_cmd_wmask    (splt_bus_icb_cmd_wmask)  ,
        .o_bus_icb_cmd_burst    (splt_bus_icb_cmd_burst),
        .o_bus_icb_cmd_beat     (splt_bus_icb_cmd_beat ),
        .o_bus_icb_cmd_excl     (splt_bus_icb_cmd_excl ),
        .o_bus_icb_cmd_lock     (splt_bus_icb_cmd_lock ),
        .o_bus_icb_cmd_size     (splt_bus_icb_cmd_size ),
        .o_bus_icb_cmd_usr      ()     ,
        
        .o_bus_icb_rsp_valid    (splt_bus_icb_rsp_valid ) ,
        .o_bus_icb_rsp_ready    (splt_bus_icb_rsp_ready ) ,
        .o_bus_icb_rsp_err      (splt_bus_icb_rsp_err)    ,
        .o_bus_icb_rsp_excl_ok  (splt_bus_icb_rsp_excl_ok),
        .o_bus_icb_rsp_rdata    (splt_bus_icb_rsp_rdata ) ,
        .o_bus_icb_rsp_usr      ({SPLT_I_NUM{1'b0}}) ,
                                
        .clk                    (clk),
        .rst                    (rst)
    );

    ///////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////
    // Implement the default slave //o: ppi target miss!!
    assign  deft_icb_cmd_ready = deft_icb_rsp_ready;

        // 0 Cycle response
    assign  deft_icb_rsp_valid = deft_icb_cmd_valid;
    assign  deft_icb_rsp_err   = 1'b1;
    assign  deft_icb_rsp_excl_ok = 1'b0;
    assign  deft_icb_rsp_rdata   = {DW{1'b0}};

`ifdef PLATFORM_SIM
`ifdef USE_DPIC
    import "DPI-C" function void PPI_OVERFLOW(input bit[`MYRISCV_ADDRBUS] addr_i, input bit Read, 
        input bit[`MYRISCV_DATABUS] data_i, input bit[`MYRISCV_DATADW/8-1 : 0] mask_i);
    always@(posedge deft_icb_cmd_valid) begin
        PPI_OVERFLOW(deft_icb_cmd_addr, deft_icb_cmd_read, deft_icb_cmd_wdata, deft_icb_cmd_wmask);
    end
`else
    always@(posedge deft_icb_cmd_valid) begin
        $display("%t, ppi region ifetch overflow!", $time);
        $display("Addr: 0x%016x, Read: %1d, Mask: %08b, Data:%d(0x%x)(c:%c) .", deft_icb_cmd_addr, deft_icb_cmd_read, deft_icb_cmd_wmask, deft_icb_cmd_wdata, deft_icb_cmd_wdata, deft_icb_cmd_wdata[7:0]);
    end
`endif
`endif

endmodule

