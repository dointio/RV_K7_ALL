//=====================================================================
//
// Designer   : Jayden Hu
//
// Description:
//  The peirpheral bus and the connected devices 
//
// ====================================================================

`include "mydefines.v"

module ppi_domain_sim(
    input                           ppi_icb_cmd_valid,
    output                          ppi_icb_cmd_ready,
    input  [`MYRISCV_ADDRBUS]       ppi_icb_cmd_addr, 
    input                           ppi_icb_cmd_read, 
    input  [`MYRISCV_DATADW-1:0]    ppi_icb_cmd_wdata,
    input  [`MYRISCV_DATADW/8-1:0]  ppi_icb_cmd_wmask,
    //
    output                          ppi_icb_rsp_valid,
    input                           ppi_icb_rsp_ready,
    output                          ppi_icb_rsp_err,
    output [`MYRISCV_DATADW-1:0]    ppi_icb_rsp_rdata,

    //o: uart
    output  interrupt_uart_req,
    output  tx,
    input   rx,

    //o: gpio_out
    output [31:0] gpioa_o_w,

    //o: sgpu
    output                          sgpu_o_icb_cmd_vld,
    input                           sgpu_o_icb_cmd_rdy,
    output  [1-1:0]                 sgpu_o_icb_cmd_read,
    output  [`MYRISCV_ADDRBUS]      sgpu_o_icb_cmd_addr,
    output  [63:0]                  sgpu_o_icb_cmd_wdata,
    output  [7:0]                   sgpu_o_icb_cmd_wmask,
    // output  [1:0]       sgpu_o_icb_cmd_size,

    input               sgpu_o_icb_rsp_vld,
    output              sgpu_o_icb_rsp_rdy,
    input               sgpu_o_icb_rsp_err,
    input   [63:0]      sgpu_o_icb_rsp_rdata,

    input           pix_clk,
    output          vga_vsync,
    output          vga_hsync,
    output          vga_en,
    output [23:0]   vga_data,
    //o:end

    input  clk,
    input  rst
);

    wire                          gpioa_icb_cmd_valid;
    wire                          gpioa_icb_cmd_ready;
    wire [`MYRISCV_ADDRDW-1:0]    gpioa_icb_cmd_addr; 
    wire                          gpioa_icb_cmd_read; 
    wire [`MYRISCV_DATADW-1:0]    gpioa_icb_cmd_wdata;
    wire [`MYRISCV_DATADW/8 -1:0] gpioa_icb_cmd_wmask;
    
    wire                          gpioa_icb_rsp_valid;
    wire                          gpioa_icb_rsp_ready;
    wire [`MYRISCV_DATADW-1:0]    gpioa_icb_rsp_rdata;
    wire                          gpioa_icb_rsp_err;

    wire                          uart_icb_cmd_valid;
    wire                          uart_icb_cmd_ready;
    wire [`MYRISCV_ADDRDW-1:0]    uart_icb_cmd_addr; 
    wire                          uart_icb_cmd_read; 
    wire [`MYRISCV_DATADW-1:0]    uart_icb_cmd_wdata;
    wire [`MYRISCV_DATADW/8 -1:0] uart_icb_cmd_wmask;
    
    wire                          uart_icb_rsp_valid;
    wire                          uart_icb_rsp_ready;
    wire [`MYRISCV_DATADW-1:0]    uart_icb_rsp_rdata;
    wire                          uart_icb_rsp_err;

    wire                          timer_icb_cmd_valid;
    wire                          timer_icb_cmd_ready;
    wire [`MYRISCV_ADDRDW-1:0]    timer_icb_cmd_addr; 
    wire                          timer_icb_cmd_read; 
    wire [`MYRISCV_DATADW-1:0]    timer_icb_cmd_wdata;
    wire [`MYRISCV_DATADW/8 -1:0] timer_icb_cmd_wmask;
    
    wire                          timer_icb_rsp_valid;
    wire                          timer_icb_rsp_ready;
    wire [`MYRISCV_DATADW-1:0]    timer_icb_rsp_rdata;
    wire                          timer_icb_rsp_err;


    wire                          simple_gpu_icb_cmd_valid;
    wire                          simple_gpu_icb_cmd_ready;
    wire [`MYRISCV_ADDRDW-1:0]    simple_gpu_icb_cmd_addr; 
    wire                          simple_gpu_icb_cmd_read; 
    wire [`MYRISCV_DATADW-1:0]    simple_gpu_icb_cmd_wdata;
    wire [`MYRISCV_DATADW/8 -1:0] simple_gpu_icb_cmd_wmask;
    
    wire                          simple_gpu_icb_rsp_valid;
    wire                          simple_gpu_icb_rsp_ready;
    wire [`MYRISCV_DATADW-1:0]    simple_gpu_icb_rsp_rdata;
    wire                          simple_gpu_icb_rsp_err;



    // The total address range for the PPI is from/to
    //  **************0x1000 0000 -- 0x1FFF FFFF
    // There are several slaves for PPI bus, including:
    //  * GPIOA     : 0x1001_2000 -- 0x1001_2FFF

    ppi_bridge # (
        .ICB_FIFO_DP        (2),// We add a ping-pong buffer here to cut down the timing path
        .ICB_FIFO_CUT_READY (1),// We configure it to cut down the back-pressure ready signal

        .AW                   (`MYRISCV_ADDRDW),
        .DW                   (`MYRISCV_DATADW),
        .SPLT_FIFO_OUTS_NUM   (1),// The peirpherals only allow 1 oustanding
        .SPLT_FIFO_CUT_READY  (1)// The peirpherals always cut ready
    )u_sirv_ppi_fab(
        .clk  (clk),
        .rst  (rst),

        .i_icb_cmd_valid  (ppi_icb_cmd_valid),
        .i_icb_cmd_ready  (ppi_icb_cmd_ready),
        .i_icb_cmd_addr   (ppi_icb_cmd_addr ),
        .i_icb_cmd_read   (ppi_icb_cmd_read ),
        .i_icb_cmd_wdata  (ppi_icb_cmd_wdata),
        .i_icb_cmd_wmask  (ppi_icb_cmd_wmask),
        .i_icb_cmd_lock   (1'b0),
        .i_icb_cmd_excl   (1'b0 ),
        .i_icb_cmd_size   (2'b0 ),
        .i_icb_cmd_burst  (2'b0 ),
        .i_icb_cmd_beat   (2'b0 ),
        
        .i_icb_rsp_valid  (ppi_icb_rsp_valid),
        .i_icb_rsp_ready  (ppi_icb_rsp_ready),
        .i_icb_rsp_err    (ppi_icb_rsp_err  ),
        .i_icb_rsp_excl_ok(),
        .i_icb_rsp_rdata  (ppi_icb_rsp_rdata),
        
        //o:  GPIOA
        .gpioa_icb_enable     (1'b1),
        .gpioa_icb_cmd_valid  (gpioa_icb_cmd_valid),
        .gpioa_icb_cmd_ready  (gpioa_icb_cmd_ready),
        .gpioa_icb_cmd_addr   (gpioa_icb_cmd_addr ),
        .gpioa_icb_cmd_read   (gpioa_icb_cmd_read ),
        .gpioa_icb_cmd_wdata  (gpioa_icb_cmd_wdata),
        .gpioa_icb_cmd_wmask  (gpioa_icb_cmd_wmask),
        .gpioa_icb_cmd_lock   (),
        .gpioa_icb_cmd_excl   (),
        .gpioa_icb_cmd_size   (),
        .gpioa_icb_cmd_burst  (),
        .gpioa_icb_cmd_beat   (),
        
        .gpioa_icb_rsp_valid  (gpioa_icb_rsp_valid),
        .gpioa_icb_rsp_ready  (gpioa_icb_rsp_ready),
        .gpioa_icb_rsp_err    (gpioa_icb_rsp_err),
        .gpioa_icb_rsp_excl_ok(1'b0  ),
        .gpioa_icb_rsp_rdata  (gpioa_icb_rsp_rdata),

        //o:  UART
        .uart_icb_enable     (1'b1),
        .uart_icb_cmd_valid  (uart_icb_cmd_valid),
        .uart_icb_cmd_ready  (uart_icb_cmd_ready),
        .uart_icb_cmd_addr   (uart_icb_cmd_addr ),
        .uart_icb_cmd_read   (uart_icb_cmd_read ),
        .uart_icb_cmd_wdata  (uart_icb_cmd_wdata),
        .uart_icb_cmd_wmask  (uart_icb_cmd_wmask),
        .uart_icb_cmd_lock   (),
        .uart_icb_cmd_excl   (),
        .uart_icb_cmd_size   (),
        .uart_icb_cmd_burst  (),
        .uart_icb_cmd_beat   (),
        
        .uart_icb_rsp_valid  (uart_icb_rsp_valid),
        .uart_icb_rsp_ready  (uart_icb_rsp_ready),
        .uart_icb_rsp_err    (uart_icb_rsp_err),
        .uart_icb_rsp_excl_ok(1'b0  ),
        .uart_icb_rsp_rdata  (uart_icb_rsp_rdata),

        //o:  Timer
        .timer_icb_enable     (1'b1),
        .timer_icb_cmd_valid  (timer_icb_cmd_valid),
        .timer_icb_cmd_ready  (timer_icb_cmd_ready),
        .timer_icb_cmd_addr   (timer_icb_cmd_addr ),
        .timer_icb_cmd_read   (timer_icb_cmd_read ),
        .timer_icb_cmd_wdata  (timer_icb_cmd_wdata),
        .timer_icb_cmd_wmask  (timer_icb_cmd_wmask),
        .timer_icb_cmd_lock   (),
        .timer_icb_cmd_excl   (),
        .timer_icb_cmd_size   (),
        .timer_icb_cmd_burst  (),
        .timer_icb_cmd_beat   (),
        
        .timer_icb_rsp_valid  (timer_icb_rsp_valid),
        .timer_icb_rsp_ready  (timer_icb_rsp_ready),
        .timer_icb_rsp_err    (timer_icb_rsp_err),
        .timer_icb_rsp_excl_ok(1'b0  ),
        .timer_icb_rsp_rdata  (timer_icb_rsp_rdata),

        //o: SGPU
        .simple_gpu_icb_enable     (1'b1),
        .simple_gpu_icb_cmd_valid  (simple_gpu_icb_cmd_valid),
        .simple_gpu_icb_cmd_ready  (simple_gpu_icb_cmd_ready),
        .simple_gpu_icb_cmd_addr   (simple_gpu_icb_cmd_addr ),
        .simple_gpu_icb_cmd_read   (simple_gpu_icb_cmd_read ),
        .simple_gpu_icb_cmd_wdata  (simple_gpu_icb_cmd_wdata),
        .simple_gpu_icb_cmd_wmask  (simple_gpu_icb_cmd_wmask),
        .simple_gpu_icb_cmd_lock   (),
        .simple_gpu_icb_cmd_excl   (),
        .simple_gpu_icb_cmd_size   (),
        .simple_gpu_icb_cmd_burst  (),
        .simple_gpu_icb_cmd_beat   (),
        
        .simple_gpu_icb_rsp_valid  (simple_gpu_icb_rsp_valid),
        .simple_gpu_icb_rsp_ready  (simple_gpu_icb_rsp_ready),
        .simple_gpu_icb_rsp_err    (simple_gpu_icb_rsp_err),
        .simple_gpu_icb_rsp_excl_ok(1'b0  ),
        .simple_gpu_icb_rsp_rdata  (simple_gpu_icb_rsp_rdata)
    );

    // * APB Peripheral:  GPIO A
    wire [`MYRISCV_ADDRBUS] gpioa_apb_paddr;
    wire [`MYRISCV_DATADW/8-1:0] gpioa_apb_strb;
    wire gpioa_apb_pwrite;
    wire gpioa_apb_pselx;
    wire gpioa_apb_penable;
    wire [`MYRISCV_DATADW-1:0] gpioa_apb_pwdata;
    wire [`MYRISCV_DATADW-1:0] gpioa_apb_prdata;

    wire [32-1:0] gpioa_i_ival;
    wire [32-1:0] gpioa_o_oval;
    wire [32-1:0] gpioa_o_oe;
    wire [32-1:0] gpioa_in_sync;
    wire [32-1:0] gpioa_iof;
    
    icb2apb # (
        .AW   (64),
        .DW   (`MYRISCV_DATADW) 
    ) u_gpioa_apb_icb2apb(
        .i_icb_cmd_valid (gpioa_icb_cmd_valid),
        .i_icb_cmd_ready (gpioa_icb_cmd_ready),
        .i_icb_cmd_addr  (gpioa_icb_cmd_addr ),
        .i_icb_cmd_read  (gpioa_icb_cmd_read ),
        .i_icb_cmd_wdata (gpioa_icb_cmd_wdata),
        .i_icb_cmd_wmask (gpioa_icb_cmd_wmask),
        .i_icb_cmd_size  (),

        .i_icb_rsp_valid (gpioa_icb_rsp_valid),
        .i_icb_rsp_ready (gpioa_icb_rsp_ready),
        .i_icb_rsp_rdata (gpioa_icb_rsp_rdata),
        .i_icb_rsp_err   (gpioa_icb_rsp_err),

        .apb_paddr     (gpioa_apb_paddr  ),
        .apb_pstrb     (gpioa_apb_strb),
        .apb_pwrite    (gpioa_apb_pwrite ),
        .apb_pselx     (gpioa_apb_pselx  ),
        .apb_penable   (gpioa_apb_penable), 
        .apb_pwdata    (gpioa_apb_pwdata ),
        .apb_prdata    (gpioa_apb_prdata ),

        .clk           (clk  ),
        .rst           (rst) 
    );

    simple_gpio u_perips_apb_gpioa (
        .clk        (clk),
        .rst        (rst),

        .paddr    (gpioa_apb_paddr),
        .pstrb    (gpioa_apb_strb),
        .pwdata   (gpioa_apb_pwdata),
        .pwrite   (gpioa_apb_pwrite),
        .psel     (gpioa_apb_pselx),
        .penable  (gpioa_apb_penable),
        .prdata   (gpioa_apb_prdata),
        .pready   (),
        .pslverr  (),

        .gpio_o   (gpioa_o_w)
    );

`ifdef PLATFORM_SIM
    uart_sim uart_inst(
        .clk            (clk),
        .rst_n            (rst),

        .icb_cmd_vld    (uart_icb_cmd_valid),
        .icb_cmd_rdy    (uart_icb_cmd_ready),
        .icb_cmd_read   (uart_icb_cmd_read),
        .icb_cmd_addr   (uart_icb_cmd_addr),
        .icb_cmd_wdata  (uart_icb_cmd_wdata),
        .icb_cmd_wmask  (uart_icb_cmd_wmask),

        .icb_rsp_vld    (uart_icb_rsp_valid),
        .icb_rsp_rdy    (uart_icb_rsp_ready),
        .icb_rsp_rdata  (uart_icb_rsp_rdata),
        .icb_rsp_err    (uart_icb_rsp_err),

        .interrupt_req  (interrupt_uart_req),

        .rx             (rx),
        .tx             (tx)
    );
`else
    uart uart_inst(
        .clk            (clk),
        .rst_n            (rst),

        .icb_cmd_vld    (uart_icb_cmd_valid),
        .icb_cmd_rdy    (uart_icb_cmd_ready),
        .icb_cmd_read   (uart_icb_cmd_read),
        .icb_cmd_addr   (uart_icb_cmd_addr),
        .icb_cmd_wdata  (uart_icb_cmd_wdata),
        .icb_cmd_wmask  (uart_icb_cmd_wmask),

        .icb_rsp_vld    (uart_icb_rsp_valid),
        .icb_rsp_rdy    (uart_icb_rsp_ready),
        .icb_rsp_rdata  (uart_icb_rsp_rdata),
        .icb_rsp_err    (uart_icb_rsp_err),

        .interrupt_req  (interrupt_uart_req),

        .rx             (rx),
        .tx             (tx)
    );
`endif


`ifdef PLATFORM_SIM
    timer_c timer_inst(
        .clk                (clk),
        .rst                (rst),

        .icb_cmd_vld        (timer_icb_cmd_valid),
        .icb_cmd_rdy        (timer_icb_cmd_ready),
        .icb_cmd_addr       (timer_icb_cmd_addr),
        .icb_cmd_read       (timer_icb_cmd_read),
        .icb_cmd_wdata      (timer_icb_cmd_wdata),
        .icb_cmd_wmask      (timer_icb_cmd_wmask),

        .icb_rsp_rdata      (timer_icb_rsp_rdata),
        .icb_rsp_err        (timer_icb_rsp_err),
        .icb_rsp_vld        (timer_icb_rsp_valid),
        .icb_rsp_rdy        (timer_icb_rsp_ready)
    );
`else //r: wait implement timer
    assign timer_icb_cmd_ready = 1'b0;
    assign timer_icb_rsp_valid = 1'b0;
    assign timer_icb_rsp_rdata = 0;
`endif

    
// `ifdef PLATFORM_SIM
    sgpu_top sgpu_inst (
        .clk                (clk),
        .rst                (rst),

        .i_icb_cmd_vld        (simple_gpu_icb_cmd_valid),
        .i_icb_cmd_rdy        (simple_gpu_icb_cmd_ready),
        .i_icb_cmd_addr       (simple_gpu_icb_cmd_addr),
        .i_icb_cmd_read       (simple_gpu_icb_cmd_read),
        .i_icb_cmd_wdata      (simple_gpu_icb_cmd_wdata),
        .i_icb_cmd_wmask      (simple_gpu_icb_cmd_wmask),

        .i_icb_rsp_rdata      (simple_gpu_icb_rsp_rdata),
        .i_icb_rsp_err        (simple_gpu_icb_rsp_err),
        .i_icb_rsp_vld        (simple_gpu_icb_rsp_valid),
        .i_icb_rsp_rdy        (simple_gpu_icb_rsp_ready),

        .o_icb_cmd_vld      (sgpu_o_icb_cmd_vld      ),
        .o_icb_cmd_rdy      (sgpu_o_icb_cmd_rdy      ),
        .o_icb_cmd_read     (sgpu_o_icb_cmd_read     ),
        .o_icb_cmd_addr     (sgpu_o_icb_cmd_addr     ),
        .o_icb_cmd_wdata    (sgpu_o_icb_cmd_wdata    ),
        .o_icb_cmd_wmask    (sgpu_o_icb_cmd_wmask    ),

        .o_icb_rsp_vld      (sgpu_o_icb_rsp_vld      ),
        .o_icb_rsp_rdy      (sgpu_o_icb_rsp_rdy      ),
        .o_icb_rsp_rdata    (sgpu_o_icb_rsp_rdata    ),
        .o_icb_rsp_err      (sgpu_o_icb_rsp_err      ),

        .clk_pix            (pix_clk),
        .vga_vsync          (vga_vsync),
        .vga_hsync          (vga_hsync),
        .vga_en             (vga_en),
        .vga_data           (vga_data)
    );
// `else
//     assign simple_gpu_icb_cmd_ready = 1'b1;
//     assign simple_gpu_icb_rsp_valid = 1'b0;
//     assign simple_gpu_icb_rsp_rdata = 0;
//     assign simple_gpu_icb_rsp_err = 0;

//     assign sgpu_o_icb_cmd_vld = 0;
//     assign sgpu_o_icb_rsp_rdy = 0;
// `endif

endmodule
