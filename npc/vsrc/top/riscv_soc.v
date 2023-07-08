`include "mydefines.v"
module riscv_soc
(
    input clk,
    input rst,
    input rst_sys_i,


    input jtag_TCK,
    input jtag_TMS,
    input jtag_TDI,
    output jtag_TDO,

`ifdef USE_XILINXIP
    inout [31:0]       ddr3_dq,
    inout [3:0]        ddr3_dqs_n,
    inout [3:0]        ddr3_dqs_p,
    output [14:0]      ddr3_addr,
    output [2:0]       ddr3_ba,
    output             ddr3_ras_n,
    output             ddr3_cas_n,
    output             ddr3_we_n,
    output             ddr3_reset_n,
    output [0:0]       ddr3_ck_p,
    output [0:0]       ddr3_ck_n,
    output [0:0]       ddr3_cke,
    output [0:0]       ddr3_cs_n,
    output [3:0]       ddr3_dm,
    output [0:0]       ddr3_odt,
`endif

    output [7:0] gpio_o,
    output tx,
    input  rx,

    output wire[2:0] TMDS_DATA_P1,
    output wire[2:0] TMDS_DATA_N1,
    output wire      TMDS_CLK_P1,
    output wire      TMDS_CLK_N1,
    output wire      HDMI_OUT_EN1
);

    wire [31:0] gpio_w;
    
    wire          vga_vsync;
    wire          vga_hsync;
    wire          vga_en;
    wire [23:0]   vga_data;

    wire    [`MYRISCV_REGADDRBUS] jtag_reg_idx;
    wire    jtag_reg_we_vld;
    reg     jtag_reg_we_rdy = 1'b1;
    wire    [`MYRISCV_REGBUS] jtag_reg_wdata;
    reg     [`MYRISCV_REGBUS] jtag_reg_rdata = {`MYRISCV_REGWD{1'b0}};

    wire jtag_cmd_vld;
    wire jtag_cmd_rdy;
    wire jtag_cmd_read;
    wire [`MYRISCV_ADDRBUS] jtag_cmd_addr;
    wire [`MYRISCV_XLEN-1 : 0] jtag_cmd_wdata;
    wire [`MYRISCV_XLEN/8-1 : 0] jtag_cmd_wmask;

    wire jtag_rsp_vld;
    wire jtag_rsp_rdy;
    wire jtag_rsp_err;
    wire [`MYRISCV_XLEN-1 : 0] jtag_rsp_rdata;


    wire jtag_halt_w;
    wire jtag_rst_w;

wire clk_sys;
wire rst_sys;
wire clk_vga;

`ifdef USE_XILINXIP
    wire clk_ddr;
    wire clk_200m;
    wire calib_done;
    wire clk_ddr_div_clk;
    wire clk_ddr_div_rst;
    wire clk_ddr_div_rst_n = ~clk_ddr_div_rst;

    assign clk_sys = clk_ddr_div_clk;
    
    reg sys_rst_r1, sys_rst_r2;
    always @(posedge clk_ddr_div_clk)begin
        sys_rst_r1 <= clk_ddr_div_rst_n & rst_sys_i & calib_done;
        sys_rst_r2 <= sys_rst_r1;
    end
    assign rst_sys = sys_rst_r2;

    reg rst_n_r1,rst_n_r2;
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            rst_n_r1 <= 0;
            rst_n_r2 <= 0;
        end
        else begin
            rst_n_r1 <= 1'b1;
            rst_n_r2 <= rst_n_r1;
        end
    end

    wire plllocked;
    clk_wiz_0 pll_inst 
    (
        // Clock out ports
        .clk_out1   (clk_ddr),//r: 400
        .clk_out2   (clk_vga),//r:40
        .clk_out3   (clk_200m),//r:200
        // Status and control signals
        .resetn     (rst_n_r2),
        .locked     (plllocked),
        // Clock in ports
        .clk_in1    (clk)
    );
    
`else //r: sim or othres 
    assign clk_sys = clk;
    assign rst_sys = rst;
    assign clk_vga = clk;
`endif

    jtag_top jtag_inst(
        .clk  (clk_sys),
        .jtag_rst_n  (rst_sys),

        .jtag_pin_TCK       (jtag_TCK),
        .jtag_pin_TMS       (jtag_TMS),
        .jtag_pin_TDI       (jtag_TDI),
        .jtag_pin_TDO       (jtag_TDO),


        .jtag_reg_idx       (jtag_reg_idx),
        .jtag_reg_we_vld    (jtag_reg_we_vld),
        .jtag_reg_we_rdy    (jtag_reg_we_rdy),
        .jtag_reg_wdata     (jtag_reg_wdata),
        .jtag_reg_rdata     (jtag_reg_rdata),

        .jtag_cmd_vld       (jtag_cmd_vld),
        .jtag_cmd_rdy       (jtag_cmd_rdy),
        .jtag_cmd_read      (jtag_cmd_read),
        .jtag_cmd_addr      (jtag_cmd_addr),
        .jtag_cmd_wdata     (jtag_cmd_wdata),
        .jtag_cmd_wmask     (jtag_cmd_wmask),

        .jtag_rsp_vld       (jtag_rsp_vld),
        .jtag_rsp_rdy       (jtag_rsp_rdy),
        .jtag_rsp_err       (jtag_rsp_err),
        .jtag_rsp_rdata     (jtag_rsp_rdata),

        .halt_req_o         (jtag_halt_w),
        .reset_req_o        (jtag_rst_w)
    );

    //o: PPI_BUS(start)
        wire ppi_icb_cmd_vld;
        wire ppi_icb_cmd_rdy;
        wire [`MYRISCV_ADDRBUS] ppi_icb_cmd_addr;
        wire ppi_icb_cmd_read;
        wire [`MYRISCV_DATABUS] ppi_icb_cmd_wdata;
        wire [(`MYRISCV_DATADW/8-1):0] ppi_icb_cmd_wmask;

        wire ppi_icb_rsp_vld;
        wire ppi_icb_rsp_rdy;
        wire ppi_icb_rsp_err;
        // wire ppi_icb_rsp_excl_ok;
        wire [`MYRISCV_DATABUS] ppi_icb_rsp_rdata;
    //o: PPI_BUS(end)
    //o: MEM_BUS(start)
        wire mem_icb_cmd_vld;
        wire mem_icb_cmd_rdy;
        wire [`MYRISCV_ADDRBUS] mem_icb_cmd_addr;
        wire mem_icb_cmd_read;
        wire [`MYRISCV_DATABUS] mem_icb_cmd_wdata;
        wire [(`MYRISCV_DATADW/8-1):0] mem_icb_cmd_wmask;

        wire mem_icb_rsp_vld;
        wire mem_icb_rsp_rdy;
        wire mem_icb_rsp_err;
        // wire mem_icb_rsp_excl_ok;
        wire [`MYRISCV_DATABUS] mem_icb_rsp_rdata;
    //o: MEM_BUS(end)
    //o: CLINT_BUS(start)
        wire clint_icb_cmd_vld;
        wire clint_icb_cmd_rdy;
        wire [`MYRISCV_ADDRBUS] clint_icb_cmd_addr;
        wire clint_icb_cmd_read;
        wire [`MYRISCV_DATABUS] clint_icb_cmd_wdata;
        wire [(`MYRISCV_DATADW/8-1):0] clint_icb_cmd_wmask;

        wire clint_icb_rsp_vld;
        wire clint_icb_rsp_rdy;
        wire clint_icb_rsp_err;
        // wire clint_icb_rsp_excl_ok;
        wire [`MYRISCV_DATABUS] clint_icb_rsp_rdata;

        wire tmr_irq_w, soft_irq_w;
        wire timer_en;
    //o: CLINT_BUS(end)
    //o: PLINT_BUS(start)
        wire ext_irq_w = 1'b0;
    //o: PLINT_BUS(end)

    riscv_core riscv_core_inst
    (
        .clk                (clk_sys),
        .rst                (rst_sys),

        .jtag_cmd_vld       (jtag_cmd_vld),
        .jtag_cmd_rdy       (jtag_cmd_rdy),
        .jtag_cmd_read      (jtag_cmd_read),
        .jtag_cmd_addr      (jtag_cmd_addr),
        .jtag_cmd_wdata     (jtag_cmd_wdata),
        .jtag_cmd_wmask     (jtag_cmd_wmask),

        .jtag_rsp_vld       (jtag_rsp_vld),
        .jtag_rsp_rdy       (jtag_rsp_rdy),
        .jtag_rsp_err       (jtag_rsp_err),
        .jtag_rsp_rdata     (jtag_rsp_rdata),

        .soft_trap_i        (soft_irq_w),
        .ext_trap_i         (ext_irq_w),
        .time_trap_i        (tmr_irq_w),
        .jtag_halt_i        (jtag_halt_w),
        .jtag_rst_i         (jtag_rst_w),

        .ppi_icb_cmd_valid                  (ppi_icb_cmd_vld),
        .ppi_icb_cmd_ready                  (ppi_icb_cmd_rdy),
        .ppi_icb_cmd_addr                   (ppi_icb_cmd_addr),
        .ppi_icb_cmd_read                   (ppi_icb_cmd_read),
        .ppi_icb_cmd_wdata                  (ppi_icb_cmd_wdata),
        .ppi_icb_cmd_wmask                  (ppi_icb_cmd_wmask),

        .ppi_icb_rsp_valid                  (ppi_icb_rsp_vld), 
        .ppi_icb_rsp_ready                  (ppi_icb_rsp_rdy),
        .ppi_icb_rsp_err                    (ppi_icb_rsp_err),
        .ppi_icb_rsp_rdata                  (ppi_icb_rsp_rdata),
        .ppi_icb_rsp_excl_ok                (), 

        .mem_icb_cmd_vld        (mem_icb_cmd_vld),
        .mem_icb_cmd_rdy        (mem_icb_cmd_rdy),
        .mem_icb_cmd_addr       (mem_icb_cmd_addr),
        .mem_icb_cmd_read       (mem_icb_cmd_read),
        .mem_icb_cmd_wdata      (mem_icb_cmd_wdata),
        .mem_icb_cmd_wmask      (mem_icb_cmd_wmask),

        .mem_icb_rsp_vld        (mem_icb_rsp_vld), 
        .mem_icb_rsp_rdy        (mem_icb_rsp_rdy),
        .mem_icb_rsp_err        (mem_icb_rsp_err),
        .mem_icb_rsp_rdata      (mem_icb_rsp_rdata),

        .clint_icb_cmd_valid        (clint_icb_cmd_vld),
        .clint_icb_cmd_ready        (clint_icb_cmd_rdy), 
        .clint_icb_cmd_addr       (clint_icb_cmd_addr),
        .clint_icb_cmd_read       (clint_icb_cmd_read),
        .clint_icb_cmd_wdata      (clint_icb_cmd_wdata),
        .clint_icb_cmd_wmask      (clint_icb_cmd_wmask),

        .clint_icb_rsp_valid        (clint_icb_rsp_vld),
        .clint_icb_rsp_ready        (clint_icb_rsp_rdy),
        .clint_icb_rsp_err        (clint_icb_rsp_err),
        .clint_icb_rsp_excl_ok      (),
        .clint_icb_rsp_rdata      (clint_icb_rsp_rdata),

        .timer_en               (timer_en)
    );

    clint clint_inst(
        .clk            (clk),
        .rst            (rst),

        .timer_en       (timer_en),

        .clint_icb_cmd_valid        (clint_icb_cmd_vld),
        .clint_icb_cmd_ready        (clint_icb_cmd_rdy),
        .clint_icb_cmd_addr         (clint_icb_cmd_addr),
        .clint_icb_cmd_read         (clint_icb_cmd_read),
        .clint_icb_cmd_wdata        (clint_icb_cmd_wdata),
        .clint_icb_cmd_wmask        (clint_icb_cmd_wmask),
        .clint_icb_cmd_burst        (),
        .clint_icb_cmd_beat         (),
        .clint_icb_cmd_lock         (),
        .clint_icb_cmd_excl         (),
        .clint_icb_cmd_size         (),

        .clint_icb_rsp_valid        (clint_icb_rsp_vld),
        .clint_icb_rsp_ready        (clint_icb_rsp_rdy),
        .clint_icb_rsp_err          (clint_icb_rsp_err),
        .clint_icb_rsp_excl_ok      (),
        .clint_icb_rsp_rdata        (clint_icb_rsp_rdata),

        .soft_irq_o                 (soft_irq_w),
        .tmr_irq_o                  (tmr_irq_w)
    );


    wire                          mem2mig_icb_cmd_valid;
    wire                          mem2mig_icb_cmd_ready;
    wire [`MYRISCV_ADDRBUS]       mem2mig_icb_cmd_addr; 
    wire                          mem2mig_icb_cmd_read; 
    wire [2-1:0]                  mem2mig_icb_cmd_burst;
    wire [2-1:0]                  mem2mig_icb_cmd_beat;
    wire [`MYRISCV_DATADW-1:0]    mem2mig_icb_cmd_wdata;
    wire [`MYRISCV_DATADW/8-1:0]  mem2mig_icb_cmd_wmask;
    wire                          mem2mig_icb_cmd_lock;
    wire                          mem2mig_icb_cmd_excl;
    wire [1:0]                    mem2mig_icb_cmd_size;

    wire                          mem2mig_icb_rsp_valid;
    wire                          mem2mig_icb_rsp_ready;
    wire                          mem2mig_icb_rsp_err  ;
    wire                          mem2mig_icb_rsp_excl_ok;
    wire [`MYRISCV_DATADW-1:0]    mem2mig_icb_rsp_rdata;

    mem_domain mem_domain_inst(
        //o: port to biu
        .mem_icb_cmd_valid(mem_icb_cmd_vld),
        .mem_icb_cmd_ready(mem_icb_cmd_rdy),
        .mem_icb_cmd_addr(mem_icb_cmd_addr), 
        .mem_icb_cmd_read(mem_icb_cmd_read), 
        .mem_icb_cmd_wdata(mem_icb_cmd_wdata),
        .mem_icb_cmd_wmask(mem_icb_cmd_wmask),
        //
        .mem_icb_rsp_valid(mem_icb_rsp_vld),
        .mem_icb_rsp_ready(mem_icb_rsp_rdy),
        .mem_icb_rsp_err(mem_icb_rsp_err),
        .mem_icb_rsp_rdata(mem_icb_rsp_rdata),

        //o: no used
        .sysmem_icb_cmd_valid(),
        .sysmem_icb_cmd_ready(),
        .sysmem_icb_cmd_addr(), 
        .sysmem_icb_cmd_read(), 
        .sysmem_icb_cmd_wdata(),
        .sysmem_icb_cmd_wmask(),
        //
        .sysmem_icb_rsp_valid(),
        .sysmem_icb_rsp_ready(),
        .sysmem_icb_rsp_err(),
        .sysmem_icb_rsp_rdata(),

        //o: no used
        .qspi0_ro_icb_cmd_valid(),
        .qspi0_ro_icb_cmd_ready(),
        .qspi0_ro_icb_cmd_addr(), 
        .qspi0_ro_icb_cmd_read(), 
        .qspi0_ro_icb_cmd_wdata(),
        //
        .qspi0_ro_icb_rsp_valid(),
        .qspi0_ro_icb_rsp_ready(),
        .qspi0_ro_icb_rsp_err(),
        .qspi0_ro_icb_rsp_rdata(),

        //o: noused
        .dm_icb_cmd_valid(),
        .dm_icb_cmd_ready(),
        .dm_icb_cmd_addr(), 
        .dm_icb_cmd_read(), 
        .dm_icb_cmd_wdata(),
        //
        .dm_icb_rsp_valid(),
        .dm_icb_rsp_ready(),
        .dm_icb_rsp_rdata(),


        .mig_icb_cmd_valid  (mem2mig_icb_cmd_valid),
        .mig_icb_cmd_ready  (mem2mig_icb_cmd_ready),
        .mig_icb_cmd_addr(mem2mig_icb_cmd_addr), 
        .mig_icb_cmd_read(mem2mig_icb_cmd_read), 
        .mig_icb_cmd_burst(mem2mig_icb_cmd_burst),
        .mig_icb_cmd_beat(mem2mig_icb_cmd_beat),
        .mig_icb_cmd_wdata(mem2mig_icb_cmd_wdata),
        .mig_icb_cmd_wmask(mem2mig_icb_cmd_wmask),
        .mig_icb_cmd_lock(mem2mig_icb_cmd_lock),
        .mig_icb_cmd_excl(mem2mig_icb_cmd_excl),
        .mig_icb_cmd_size(mem2mig_icb_cmd_size),

        .mig_icb_rsp_valid(mem2mig_icb_rsp_valid),
        .mig_icb_rsp_ready(mem2mig_icb_rsp_ready),
        .mig_icb_rsp_err  (mem2mig_icb_rsp_err  ),
        .mig_icb_rsp_excl_ok(mem2mig_icb_rsp_excl_ok),
        .mig_icb_rsp_rdata(mem2mig_icb_rsp_rdata),

        .clk            (clk_sys),
        .bus_rst_n      (rst_sys),
        .rst            (rst_sys)
    );

`ifdef USE_XILINXIP

    wire mem2mig_axi_arvalid;
    wire mem2mig_axi_arready;
    wire [31:0] mem2mig_axi_araddr;
    wire [3:0] mem2mig_axi_arcache;
    wire [2:0] mem2mig_axi_arprot;
    wire [1-1:0] mem2mig_axi_arlock;
    wire [1:0] mem2mig_axi_arburst;
    wire [8-1:0] mem2mig_axi_arlen;
    wire [2:0] mem2mig_axi_arsize;

    wire mem2mig_axi_awvalid;
    wire  mem2mig_axi_awready;
    wire [31:0] mem2mig_axi_awaddr;
    wire [3:0] mem2mig_axi_awcache;
    wire [2:0] mem2mig_axi_awprot;
    wire [1-1:0] mem2mig_axi_awlock;
    wire [1:0] mem2mig_axi_awburst;
    wire [8-1:0] mem2mig_axi_awlen;
    wire [2:0] mem2mig_axi_awsize;

    wire  mem2mig_axi_rvalid;
    wire mem2mig_axi_rready;
    wire  [63:0] mem2mig_axi_rdata;
    wire  [1:0] mem2mig_axi_rresp;
    wire  mem2mig_axi_rlast;

    wire mem2mig_axi_wvalid;
    wire  mem2mig_axi_wready;
    wire [63:0] mem2mig_axi_wdata;
    wire [(64/8)-1:0] mem2mig_axi_wstrb;
    wire mem2mig_axi_wlast;

    wire  mem2mig_axi_bvalid;
    wire mem2mig_axi_bready;
    wire  [1:0] mem2mig_axi_bresp;

    icb2axi #(
        .AXI_FIFO_DP        (`MYRISCV_DDR_ICB2AXI_FIFO_DEEP),
        .AXI_FIFO_CUT_READY (`MYRISCV_DDR_ICB2AXI_FIFO_CUT),
        .AW                 (32),
        .FIFO_OUTS_NUM      (`MYRISCV_DDR_ICB2AXI_FIFO_DEEP),
        .FIFO_CUT_READY     (`MYRISCV_DDR_ICB2AXI_FIFO_CUT),
        .DW                 (64),
        .LOCKW              (1),
        .AXILENW            (8)
    ) icb2axi_inst(
        .i_icb_cmd_valid    (mem2mig_icb_cmd_valid),
        .i_icb_cmd_ready    (mem2mig_icb_cmd_ready), 
        .i_icb_cmd_read     (mem2mig_icb_cmd_read), 
        .i_icb_cmd_addr     (mem2mig_icb_cmd_addr[31:0]), 
        .i_icb_cmd_wdata    (mem2mig_icb_cmd_wdata), 
        .i_icb_cmd_wmask    (mem2mig_icb_cmd_wmask),
        // .i_icb_cmd_size(mem2mig_icb_cmd_size),

        .i_icb_rsp_valid    (mem2mig_icb_rsp_valid), 
        .i_icb_rsp_ready    (mem2mig_icb_rsp_ready), 
        .i_icb_rsp_err      (mem2mig_icb_rsp_err),
        .i_icb_rsp_rdata    (mem2mig_icb_rsp_rdata), 
        
        .o_axi_arvalid  (mem2mig_axi_arvalid  ),
        .o_axi_arready  (mem2mig_axi_arready  ),
        .o_axi_araddr   (mem2mig_axi_araddr   ),
        .o_axi_arcache  (mem2mig_axi_arcache  ),
        .o_axi_arprot   (mem2mig_axi_arprot   ),
        .o_axi_arlock   (mem2mig_axi_arlock   ),
        .o_axi_arburst  (mem2mig_axi_arburst  ),
        .o_axi_arlen    (mem2mig_axi_arlen    ),
        .o_axi_arsize   (mem2mig_axi_arsize   ),

        .o_axi_awvalid (mem2mig_axi_awvalid ),
        .o_axi_awready (mem2mig_axi_awready ),
        .o_axi_awaddr   (mem2mig_axi_awaddr   ),
        .o_axi_awcache (mem2mig_axi_awcache ),
        .o_axi_awprot   (mem2mig_axi_awprot   ),
        .o_axi_awlock (mem2mig_axi_awlock ),
        .o_axi_awburst (mem2mig_axi_awburst ),
        .o_axi_awlen    (mem2mig_axi_awlen    ),
        .o_axi_awsize (mem2mig_axi_awsize ),

        .o_axi_rvalid (mem2mig_axi_rvalid ),
        .o_axi_rready (mem2mig_axi_rready ),
        .o_axi_rdata (mem2mig_axi_rdata ),
        .o_axi_rresp (mem2mig_axi_rresp ),
        .o_axi_rlast (mem2mig_axi_rlast ),

        .o_axi_wvalid (mem2mig_axi_wvalid ),
        .o_axi_wready (mem2mig_axi_wready ),
        .o_axi_wdata (mem2mig_axi_wdata ),
        .o_axi_wstrb (mem2mig_axi_wstrb ),
        .o_axi_wlast (mem2mig_axi_wlast ),

        .o_axi_bvalid (mem2mig_axi_bvalid ),
        .o_axi_bready (mem2mig_axi_bready ),
        .o_axi_bresp (mem2mig_axi_bresp ),

        .clk         (clk_sys),
        .rst         (rst_sys)
    );

    wire ppi2mig_axi_arvalid;
    wire ppi2mig_axi_arready;
    wire [31:0] ppi2mig_axi_araddr;
    wire [3:0] ppi2mig_axi_arcache;
    wire [2:0] ppi2mig_axi_arprot;
    wire [1-1:0] ppi2mig_axi_arlock;
    wire [1:0] ppi2mig_axi_arburst;
    wire [8-1:0] ppi2mig_axi_arlen;
    wire [2:0] ppi2mig_axi_arsize;

    wire ppi2mig_axi_awvalid;
    wire  ppi2mig_axi_awready;
    wire [31:0] ppi2mig_axi_awaddr;
    wire [3:0] ppi2mig_axi_awcache;
    wire [2:0] ppi2mig_axi_awprot;
    wire [1-1:0] ppi2mig_axi_awlock;
    wire [1:0] ppi2mig_axi_awburst;
    wire [8-1:0] ppi2mig_axi_awlen;
    wire [2:0] ppi2mig_axi_awsize;

    wire  ppi2mig_axi_rvalid;
    wire ppi2mig_axi_rready;
    wire  [63:0] ppi2mig_axi_rdata;
    wire  [1:0] ppi2mig_axi_rresp;
    wire  ppi2mig_axi_rlast;

    wire ppi2mig_axi_wvalid;
    wire  ppi2mig_axi_wready;
    wire [63:0] ppi2mig_axi_wdata;
    wire [(64/8)-1:0] ppi2mig_axi_wstrb;
    wire ppi2mig_axi_wlast;

    wire  ppi2mig_axi_bvalid;
    wire ppi2mig_axi_bready;
    wire  [1:0] ppi2mig_axi_bresp;

    wire sgpu_fifo_read_err;
    ppi_domain ppi_inst (
        .clk            (clk_sys),
        .rst            (rst_sys),

        .ppi_icb_cmd_valid                  (ppi_icb_cmd_vld),
        .ppi_icb_cmd_ready                  (ppi_icb_cmd_rdy),
        .ppi_icb_cmd_addr                   (ppi_icb_cmd_addr),
        .ppi_icb_cmd_read                   (ppi_icb_cmd_read),
        .ppi_icb_cmd_wdata                  (ppi_icb_cmd_wdata),
        .ppi_icb_cmd_wmask                  (ppi_icb_cmd_wmask),

        .ppi_icb_rsp_valid                  (ppi_icb_rsp_vld), 
        .ppi_icb_rsp_ready                  (ppi_icb_rsp_rdy),
        .ppi_icb_rsp_err                    (ppi_icb_rsp_err),
        .ppi_icb_rsp_rdata                  (ppi_icb_rsp_rdata),

        .gpioa_o_w          (gpio_w),

        .interrupt_uart_req (),

        .tx                 (tx),
        .rx                 (rx),
        
        .sgpu_axi_arvalid(ppi2mig_axi_arvalid),
        .sgpu_axi_arready(ppi2mig_axi_arready),
        .sgpu_axi_araddr(ppi2mig_axi_araddr),
        .sgpu_axi_arcache(ppi2mig_axi_arcache),
        .sgpu_axi_arprot(ppi2mig_axi_arprot),
        .sgpu_axi_arlock(ppi2mig_axi_arlock),
        .sgpu_axi_arburst(ppi2mig_axi_arburst),
        .sgpu_axi_arlen(ppi2mig_axi_arlen),
        .sgpu_axi_arsize(ppi2mig_axi_arsize),

        .sgpu_axi_rvalid(ppi2mig_axi_rvalid),
        .sgpu_axi_rready(ppi2mig_axi_rready),
        .sgpu_axi_rdata(ppi2mig_axi_rdata),
        .sgpu_axi_rresp(ppi2mig_axi_rresp),
        .sgpu_axi_rlast(ppi2mig_axi_rlast),

        .sgpu_fifo_read_err (sgpu_fifo_read_err),

        .pix_clk            (clk_vga),
        .vga_vsync          (vga_vsync),
        .vga_hsync          (vga_hsync),
        .vga_en             (vga_en),
        .vga_data           (vga_data)
    );

    wire mig_axi_arvalid;
    wire  mig_axi_arready;
    wire [31:0] mig_axi_araddr;
    wire [3:0] mig_axi_arcache;
    wire [2:0] mig_axi_arprot;
    wire [1-1:0] mig_axi_arlock;
    wire [1:0] mig_axi_arburst;
    wire [8-1:0] mig_axi_arlen;
    wire [2:0] mig_axi_arsize;

    wire mig_axi_awvalid;
    wire  mig_axi_awready;
    wire [31:0] mig_axi_awaddr;
    wire [3:0] mig_axi_awcache;
    wire [2:0] mig_axi_awprot;
    wire [1-1:0] mig_axi_awlock;
    wire [1:0] mig_axi_awburst;
    wire [8-1:0] mig_axi_awlen;
    wire [2:0] mig_axi_awsize;

    wire  mig_axi_rvalid;
    wire mig_axi_rready;
    wire  [63:0] mig_axi_rdata;
    wire  [1:0] mig_axi_rresp;
    wire  mig_axi_rlast;

    wire mig_axi_wvalid;
    wire  mig_axi_wready;
    wire [63:0] mig_axi_wdata;
    wire [(64/8)-1:0] mig_axi_wstrb;
    wire mig_axi_wlast;

    wire  mig_axi_bvalid;
    wire mig_axi_bready;
    wire  [1:0] mig_axi_bresp;

    axi_arbt #(
        .AW                 (32),
        .DW                 (`MYRISCV_DATADW),
        .LOCKW              (1),
        .AXILENW            (8),
        .FIFO_DP            (8),
        .FIFO_CUT_READY     (1),
        .ALLOW_0CYCL_RSP    (1),
        .ARBT_NUM           (2)
    ) arbt_axi_inst
    (
        .i_axi_arvalid_bus  ({mem2mig_axi_arvalid, ppi2mig_axi_arvalid}),
        .i_axi_arready_bus  ({mem2mig_axi_arready, ppi2mig_axi_arready}),
        .i_axi_araddr_bus  ({mem2mig_axi_araddr, ppi2mig_axi_araddr}),
        .i_axi_arcache_bus  ({mem2mig_axi_arcache, ppi2mig_axi_arcache}),
        .i_axi_arprot_bus  ({mem2mig_axi_arprot, ppi2mig_axi_arprot}),
        .i_axi_arlock_bus  ({mem2mig_axi_arlock, ppi2mig_axi_arlock}),
        .i_axi_arburst_bus  ({mem2mig_axi_arburst, ppi2mig_axi_arburst}),
        .i_axi_arlen_bus  ({mem2mig_axi_arlen, ppi2mig_axi_arlen}),
        .i_axi_arsize_bus  ({mem2mig_axi_arsize, ppi2mig_axi_arsize}),

        .i_axi_awvalid_bus  ({mem2mig_axi_awvalid, ppi2mig_axi_awvalid}),
        .i_axi_awready_bus  ({mem2mig_axi_awready, ppi2mig_axi_awready}),
        .i_axi_awaddr_bus  ({mem2mig_axi_awaddr, ppi2mig_axi_awaddr}),
        .i_axi_awcache_bus  ({mem2mig_axi_awcache, ppi2mig_axi_awcache}),
        .i_axi_awprot_bus  ({mem2mig_axi_awprot, ppi2mig_axi_awprot}),
        .i_axi_awlock_bus  ({mem2mig_axi_awlock, ppi2mig_axi_awlock}),
        .i_axi_awburst_bus  ({mem2mig_axi_awburst, ppi2mig_axi_awburst}),
        .i_axi_awlen_bus  ({mem2mig_axi_awlen, ppi2mig_axi_awlen}),
        .i_axi_awsize_bus  ({mem2mig_axi_awsize, ppi2mig_axi_awsize}),

        .i_axi_rvalid_bus  ({mem2mig_axi_rvalid, ppi2mig_axi_rvalid}),
        .i_axi_rready_bus  ({mem2mig_axi_rready, ppi2mig_axi_rready}),
        .i_axi_rdata_bus  ({mem2mig_axi_rdata, ppi2mig_axi_rdata}),
        .i_axi_rresp_bus  ({mem2mig_axi_rresp, ppi2mig_axi_rresp}),
        .i_axi_rlast_bus  ({mem2mig_axi_rlast, ppi2mig_axi_rlast}),

        .i_axi_wvalid_bus  ({mem2mig_axi_wvalid, ppi2mig_axi_wvalid}),
        .i_axi_wready_bus  ({mem2mig_axi_wready, ppi2mig_axi_wready}),
        .i_axi_wdata_bus  ({mem2mig_axi_wdata, ppi2mig_axi_wdata}),
        .i_axi_wstrb_bus  ({mem2mig_axi_wstrb, ppi2mig_axi_wstrb}),
        .i_axi_wlast_bus  ({mem2mig_axi_wlast, ppi2mig_axi_wlast}),

        .i_axi_bvalid_bus  ({mem2mig_axi_bvalid, ppi2mig_axi_bvalid}),
        .i_axi_bready_bus  ({mem2mig_axi_bready, ppi2mig_axi_bready}),
        .i_axi_bresp_bus  ({mem2mig_axi_bresp, ppi2mig_axi_bresp}),

        .o_axi_arvalid(mig_axi_arvalid),
        .o_axi_arready(mig_axi_arready),
        .o_axi_araddr(mig_axi_araddr),
        .o_axi_arcache(mig_axi_arcache),
        .o_axi_arprot(mig_axi_arprot),
        .o_axi_arlock(mig_axi_arlock),
        .o_axi_arburst(mig_axi_arburst),
        .o_axi_arlen(mig_axi_arlen),
        .o_axi_arsize(mig_axi_arsize),

        .o_axi_awvalid(mig_axi_awvalid),
        .o_axi_awready(mig_axi_awready),
        .o_axi_awaddr(mig_axi_awaddr),
        .o_axi_awcache(mig_axi_awcache),
        .o_axi_awprot(mig_axi_awprot),
        .o_axi_awlock(mig_axi_awlock),
        .o_axi_awburst(mig_axi_awburst),
        .o_axi_awlen(mig_axi_awlen),
        .o_axi_awsize(mig_axi_awsize),

        .o_axi_rvalid(mig_axi_rvalid),
        .o_axi_rready(mig_axi_rready),
        .o_axi_rdata(mig_axi_rdata),
        .o_axi_rresp(mig_axi_rresp),
        .o_axi_rlast(mig_axi_rlast),

        .o_axi_wvalid(mig_axi_wvalid),
        .o_axi_wready(mig_axi_wready),
        .o_axi_wdata(mig_axi_wdata),
        .o_axi_wstrb(mig_axi_wstrb),
        .o_axi_wlast(mig_axi_wlast),

        .o_axi_bvalid(mig_axi_bvalid),
        .o_axi_bready(mig_axi_bready),
        .o_axi_bresp(mig_axi_bresp),
                
        .clk            (clk_sys),
        .rst            (rst_sys)
    );

    mig_7series_0  mig_7series_0_inst 
    (
        .ddr3_dq  (ddr3_dq),
        .ddr3_dqs_n  (ddr3_dqs_n),
        .ddr3_dqs_p  (ddr3_dqs_p),
        .ddr3_addr  (ddr3_addr),
        .ddr3_ba  (ddr3_ba),
        .ddr3_ras_n  (ddr3_ras_n),
        .ddr3_cas_n  (ddr3_cas_n),
        .ddr3_we_n  (ddr3_we_n),
        .ddr3_reset_n (ddr3_reset_n),
        .ddr3_ck_p  (ddr3_ck_p),
        .ddr3_ck_n  (ddr3_ck_n),
        .ddr3_cke  (ddr3_cke),
        .ddr3_cs_n  (ddr3_cs_n),
        .ddr3_dm  (ddr3_dm),
        .ddr3_odt  (ddr3_odt),
        
        .sys_clk_i          (clk_ddr),
        .clk_ref_i          (clk_200m),
        .ui_clk             (clk_ddr_div_clk),
        .ui_clk_sync_rst    (clk_ddr_div_rst),
        .mmcm_locked        (),
        .aresetn            (plllocked),
        .app_sr_req         ('b0),
        .app_ref_req        ('b0),
        .app_zq_req         ('b0),
        .app_sr_active      (),
        .app_ref_ack        (),
        .app_zq_ack         (),
        
        // .s_axi_awid     (mig_axi_awid),
        .s_axi_awid     (4'b1111), //r: k7 example!
        .s_axi_awaddr (mig_axi_awaddr),
        .s_axi_awlen (mig_axi_awlen),
        .s_axi_awsize (mig_axi_awsize),
        .s_axi_awburst (mig_axi_awburst),
        .s_axi_awlock (mig_axi_awlock),
        .s_axi_awcache (mig_axi_awcache),
        .s_axi_awprot (mig_axi_awprot),
        .s_axi_awqos (4'b0000),//r: k7 example
        .s_axi_awvalid (mig_axi_awvalid),
        .s_axi_awready (mig_axi_awready),
        
        .s_axi_wdata (mig_axi_wdata),
        .s_axi_wstrb (mig_axi_wstrb),
        .s_axi_wlast (mig_axi_wlast),
        .s_axi_wvalid (mig_axi_wvalid),
        .s_axi_wready (mig_axi_wready),

        .s_axi_bready (mig_axi_bready),
        .s_axi_bid     (),//r: k7 example
        .s_axi_bresp (mig_axi_bresp),
        .s_axi_bvalid (mig_axi_bvalid),
        
        .s_axi_arid     (4'b0000), //r: k7 example:1'b0
        .s_axi_araddr (mig_axi_araddr),
        .s_axi_arlen (mig_axi_arlen),
        .s_axi_arsize (mig_axi_arsize),
        .s_axi_arburst (mig_axi_arburst),
        .s_axi_arlock (mig_axi_arlock),
        .s_axi_arcache (mig_axi_arcache),
        .s_axi_arprot (mig_axi_arprot),
        .s_axi_arqos (4'b0000),//r: k7 example
        .s_axi_arvalid (mig_axi_arvalid),
        .s_axi_arready (mig_axi_arready),

        .s_axi_rready (mig_axi_rready),
        .s_axi_rid     (),//r: k7 example
        .s_axi_rdata (mig_axi_rdata),
        .s_axi_rresp (mig_axi_rresp),
        .s_axi_rlast (mig_axi_rlast),
        .s_axi_rvalid (mig_axi_rvalid),

        // .device_temp_i    (0),
        // .device_temp       (),
        
        .init_calib_complete (calib_done),
        .sys_rst             (plllocked)
    );

    rgb2dvi_0 rgb2dvi_0_inst1(
        .TMDS_Clk_p(TMDS_CLK_P1),
        .TMDS_Clk_n(TMDS_CLK_N1),
        .TMDS_Data_p(TMDS_DATA_P1),
        .TMDS_Data_n(TMDS_DATA_N1),
        .aRst_n(1'b1), 
        // .vid_pData({Red, Blue, Green}),
        .vid_pData  (vga_data),
        .vid_pVDE   (vga_en),
        .vid_pHSync (vga_hsync),
        .vid_pVSync (vga_vsync),
        .PixelClk   (clk_vga),
        .SerialClk  (clk_200m)
    ); 
`else
    wire                          ppi2mig_icb_cmd_valid;
    wire                          ppi2mig_icb_cmd_ready;
    wire [`MYRISCV_ADDRBUS]       ppi2mig_icb_cmd_addr; 
    wire                          ppi2mig_icb_cmd_read; 
    wire [2-1:0]                  ppi2mig_icb_cmd_burst;
    wire [2-1:0]                  ppi2mig_icb_cmd_beat;
    wire [`MYRISCV_DATADW-1:0]    ppi2mig_icb_cmd_wdata;
    wire [`MYRISCV_DATADW/8-1:0]  ppi2mig_icb_cmd_wmask;
    wire                          ppi2mig_icb_cmd_lock;
    wire                          ppi2mig_icb_cmd_excl;
    wire [1:0]                    ppi2mig_icb_cmd_size;

    wire                          ppi2mig_icb_rsp_valid;
    wire                          ppi2mig_icb_rsp_ready;
    wire                          ppi2mig_icb_rsp_err  ;
    wire                          ppi2mig_icb_rsp_excl_ok;
    wire [`MYRISCV_DATADW-1:0]    ppi2mig_icb_rsp_rdata;

    // assign ppi2mig_icb_cmd_valid = 0;
    // assign ppi2mig_icb_rsp_ready = 0;

    ppi_domain_sim ppi_inst(
        .clk            (clk_sys),
        .rst            (rst_sys),

        .ppi_icb_cmd_valid                  (ppi_icb_cmd_vld),
        .ppi_icb_cmd_ready                  (ppi_icb_cmd_rdy),
        .ppi_icb_cmd_addr                   (ppi_icb_cmd_addr),
        .ppi_icb_cmd_read                   (ppi_icb_cmd_read),
        .ppi_icb_cmd_wdata                  (ppi_icb_cmd_wdata),
        .ppi_icb_cmd_wmask                  (ppi_icb_cmd_wmask),

        .ppi_icb_rsp_valid                  (ppi_icb_rsp_vld), 
        .ppi_icb_rsp_ready                  (ppi_icb_rsp_rdy),
        .ppi_icb_rsp_err                    (ppi_icb_rsp_err),
        .ppi_icb_rsp_rdata                  (ppi_icb_rsp_rdata),

        .gpioa_o_w          (gpio_w),

        .interrupt_uart_req (),

        .tx                 (tx),
        .rx                 (rx),
        
        .sgpu_o_icb_cmd_vld      (ppi2mig_icb_cmd_valid),
        .sgpu_o_icb_cmd_rdy      (ppi2mig_icb_cmd_ready),
        .sgpu_o_icb_cmd_read     (ppi2mig_icb_cmd_read),
        .sgpu_o_icb_cmd_addr     (ppi2mig_icb_cmd_addr),
        .sgpu_o_icb_cmd_wdata    (ppi2mig_icb_cmd_wdata),
        .sgpu_o_icb_cmd_wmask    (ppi2mig_icb_cmd_wmask),

        .sgpu_o_icb_rsp_vld      (ppi2mig_icb_rsp_valid),
        .sgpu_o_icb_rsp_rdy      (ppi2mig_icb_rsp_ready),
        .sgpu_o_icb_rsp_rdata    (ppi2mig_icb_rsp_rdata),
        .sgpu_o_icb_rsp_err      (ppi2mig_icb_rsp_err),


        .pix_clk            (clk_vga),
        .vga_vsync          (vga_vsync),
        .vga_hsync          (vga_hsync),
        .vga_en             (vga_en),
        .vga_data           (vga_data)
    );

    wire                          mig_icb_cmd_valid;
    wire                          mig_icb_cmd_ready;
    wire [`MYRISCV_ADDRDW-1:0]    mig_icb_cmd_addr; 
    wire                          mig_icb_cmd_read; 
    wire [`MYRISCV_DATADW-1:0]    mig_icb_cmd_wdata;
    wire [`MYRISCV_DATADW/8-1:0]  mig_icb_cmd_wmask;
    wire [1:0]                    mig_icb_cmd_burst;
    wire [1:0]                    mig_icb_cmd_beat;
    wire                          mig_icb_cmd_lock;
    wire                          mig_icb_cmd_excl;
    wire [1:0]                    mig_icb_cmd_size;

    wire                          mig_icb_rsp_valid;
    wire                          mig_icb_rsp_ready;
    wire                          mig_icb_rsp_err  ;
    wire                          mig_icb_rsp_excl_ok;
    wire  [`MYRISCV_DATADW-1:0]   mig_icb_rsp_rdata;

    ddr_arbt ddr_arbt_inst(
        .mem2mig_icb_cmd_valid(mem2mig_icb_cmd_valid),
        .mem2mig_icb_cmd_ready(mem2mig_icb_cmd_ready),
        .mem2mig_icb_cmd_addr(mem2mig_icb_cmd_addr), 
        .mem2mig_icb_cmd_read(mem2mig_icb_cmd_read), 
        .mem2mig_icb_cmd_wdata(mem2mig_icb_cmd_wdata),
        .mem2mig_icb_cmd_wmask(mem2mig_icb_cmd_wmask),
        .mem2mig_icb_cmd_burst(mem2mig_icb_cmd_burst),
        .mem2mig_icb_cmd_beat(mem2mig_icb_cmd_beat),
        .mem2mig_icb_cmd_lock(mem2mig_icb_cmd_lock),
        .mem2mig_icb_cmd_excl(mem2mig_icb_cmd_excl),
        .mem2mig_icb_cmd_size(mem2mig_icb_cmd_size),

        .mem2mig_icb_rsp_valid(mem2mig_icb_rsp_valid),
        .mem2mig_icb_rsp_ready(mem2mig_icb_rsp_ready),
        .mem2mig_icb_rsp_err  (mem2mig_icb_rsp_err  ),
        .mem2mig_icb_rsp_excl_ok(mem2mig_icb_rsp_excl_ok),
        .mem2mig_icb_rsp_rdata(mem2mig_icb_rsp_rdata),

        .ppi2mig_icb_cmd_valid(ppi2mig_icb_cmd_valid),
        .ppi2mig_icb_cmd_ready(ppi2mig_icb_cmd_ready),
        .ppi2mig_icb_cmd_addr(ppi2mig_icb_cmd_addr), 
        .ppi2mig_icb_cmd_read(ppi2mig_icb_cmd_read), 
        .ppi2mig_icb_cmd_wdata(ppi2mig_icb_cmd_wdata),
        .ppi2mig_icb_cmd_wmask(ppi2mig_icb_cmd_wmask),
        .ppi2mig_icb_cmd_burst(ppi2mig_icb_cmd_burst),
        .ppi2mig_icb_cmd_beat(ppi2mig_icb_cmd_beat),
        .ppi2mig_icb_cmd_lock(ppi2mig_icb_cmd_lock),
        .ppi2mig_icb_cmd_excl(ppi2mig_icb_cmd_excl),
        .ppi2mig_icb_cmd_size(ppi2mig_icb_cmd_size),

        .ppi2mig_icb_rsp_valid(ppi2mig_icb_rsp_valid),
        .ppi2mig_icb_rsp_ready(ppi2mig_icb_rsp_ready),
        .ppi2mig_icb_rsp_err  (ppi2mig_icb_rsp_err  ),
        .ppi2mig_icb_rsp_excl_ok(ppi2mig_icb_rsp_excl_ok),
        .ppi2mig_icb_rsp_rdata(ppi2mig_icb_rsp_rdata),


        .mig_icb_cmd_valid(mig_icb_cmd_valid),
        .mig_icb_cmd_ready(mig_icb_cmd_ready),
        .mig_icb_cmd_addr(mig_icb_cmd_addr), 
        .mig_icb_cmd_read(mig_icb_cmd_read), 
        .mig_icb_cmd_burst(mig_icb_cmd_burst),
        .mig_icb_cmd_beat(mig_icb_cmd_beat),
        .mig_icb_cmd_wdata(mig_icb_cmd_wdata),
        .mig_icb_cmd_wmask(mig_icb_cmd_wmask),
        .mig_icb_cmd_lock(mig_icb_cmd_lock),
        .mig_icb_cmd_excl(mig_icb_cmd_excl),
        .mig_icb_cmd_size(mig_icb_cmd_size),

        .mig_icb_rsp_valid(mig_icb_rsp_valid),
        .mig_icb_rsp_ready(mig_icb_rsp_ready),
        .mig_icb_rsp_err  (mig_icb_rsp_err  ),
        .mig_icb_rsp_excl_ok(mig_icb_rsp_excl_ok),
        .mig_icb_rsp_rdata(mig_icb_rsp_rdata),


        .clk            (clk_sys),
        .rst            (rst_sys)
    );


    wire ddr_cs;
    wire ddr_we;
    wire [`MYRISCV_ADDRBUS] ddr_addr;
    wire [(`MYRISCV_DATADW/8-1):0] ddr_wem;
    wire [`MYRISCV_DATABUS] ddr_wdata;
    wire [`MYRISCV_DATABUS] ddr_rdata;
    sram_ctrl ddr_ctrl_inst
    (
        .clk                (clk),
        .rst                (rst),

        .sram_cmd_vld           (mig_icb_cmd_valid),
        .sram_cmd_rdy           (mig_icb_cmd_ready),
        .sram_cmd_addr          (mig_icb_cmd_addr),
        .sram_cmd_read          (mig_icb_cmd_read),
        .sram_cmd_wdata         (mig_icb_cmd_wdata),
        .sram_cmd_wmask         (mig_icb_cmd_wmask),

        .sram_rsp_vld           (mig_icb_rsp_valid),
        .sram_rsp_rdy           (mig_icb_rsp_ready),
        .sram_rsp_err           (mig_icb_rsp_err),
        .sram_rsp_rdata         (mig_icb_rsp_rdata),


        .sram_cs                (ddr_cs),
        .sram_we                (ddr_we),
        .sram_addr              (ddr_addr),
        .sram_wem               (ddr_wem),
        .sram_wdata             (ddr_wdata),
        .sram_rdata             (ddr_rdata)
    );

    ddr_sim ddr_inst
    (
        .clk            (clk),
        .cs             (ddr_cs),
        .we             (ddr_we),
        .addr           (ddr_addr),
        .din            (ddr_wdata),
        .wem            (ddr_wem),
        .dout           (ddr_rdata)
    );

`endif

`ifdef USE_XILINXIP
    assign gpio_o[7] = plllocked;
    assign gpio_o[6] = jtag_halt_w;
    assign gpio_o[5] = jtag_rst_w;
    assign gpio_o[4] = calib_done;
    assign gpio_o[3] = sgpu_fifo_read_err;
    assign gpio_o[2:0] = gpio_w[2:0];
`else
    assign gpio_o = gpio_w[7:0];
`endif    

endmodule
