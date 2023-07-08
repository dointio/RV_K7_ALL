`include "mydefines.v"
module ddr_vga_axi_mux_test
(
    input wire sys_clk,
    output wire calib_done,

    output [3:0] led,

    input wire rstn,
    output wire  locked,
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

    output wire[2:0] TMDS_DATA_P1,
    output wire[2:0] TMDS_DATA_N1,
    output wire      TMDS_CLK_P1,
    output wire      TMDS_CLK_N1,
    output wire      HDMI_OUT_EN1
);
    wire ui_clk;
    wire ui_rst;
    wire ddr3_clk;
    wire clk_vga;
    wire clk_200m;

    clk_wiz_0 clk_wiz_0_inst
    (
        .clk_out1   (ddr3_clk),
        .clk_out2   (clk_vga),
        .clk_out3   (clk_200m),
        .resetn     (rstn),
        .locked     (locked),
        .clk_in1    (sys_clk)
    );
    
    wire [3:0]  mem_axi_arid;
    wire [31:0] mem_axi_araddr;
    wire [7:0]  mem_axi_arlen;
    wire [2:0]  mem_axi_arsize;
    wire [1:0]  mem_axi_arburst;
    wire [0:0]  mem_axi_arlock;
    wire [3:0]  mem_axi_arcache;
    wire [2:0]  mem_axi_arprot;
    wire [3:0]  mem_axi_arqos = 0;
    wire        mem_axi_arready;
    wire        mem_axi_arvalid;
    
    wire            mem_axi_rready;
    wire [3:0]      mem_axi_rid;
    wire [63:0]     mem_axi_rdata;
    wire [1:0]      mem_axi_rresp;
    wire            mem_axi_rlast;
    wire            mem_axi_rvalid;


    wire [3:0]  mem_axi_awid;
    wire [31:0] mem_axi_awaddr;
    wire [7:0]  mem_axi_awlen;
    wire [2:0]  mem_axi_awsize;
    wire [1:0]  mem_axi_awburst;
    wire [0:0]  mem_axi_awlock;
    wire [3:0]  mem_axi_awcache;
    wire [2:0]  mem_axi_awprot;
    wire [3:0]  mem_axi_awqos = 0;
    wire        mem_axi_awvalid;
    wire        mem_axi_awready;
    

    wire [3:0]  mem_axi_bid;
    wire        mem_axi_bready;
    wire [1:0]  mem_axi_bresp;
    wire        mem_axi_bvalid;

    wire [63:0]    mem_axi_wdata;
    wire [7:0]     mem_axi_wstrb;
    wire            mem_axi_wlast;
    wire            mem_axi_wready;
    wire            mem_axi_wvalid;

    wire                          mem2mig_icb_cmd_valid;
    wire                         mem2mig_icb_cmd_ready;
    wire [`MYRISCV_ADDRBUS]       mem2mig_icb_cmd_addr; 
    wire                          mem2mig_icb_cmd_read; 
    wire [2-1:0]                  mem2mig_icb_cmd_burst;
    wire [2-1:0]                  mem2mig_icb_cmd_beat;
    wire [`MYRISCV_DATADW-1:0]   mem2mig_icb_cmd_wdata;
    wire [`MYRISCV_DATADW/8-1:0]  mem2mig_icb_cmd_wmask;
    wire                          mem2mig_icb_cmd_lock;
    wire                          mem2mig_icb_cmd_excl;
    wire [1:0]                    mem2mig_icb_cmd_size;

    wire                          mem2mig_icb_rsp_valid;
    wire                          mem2mig_icb_rsp_ready;
    wire                          mem2mig_icb_rsp_err  ;
    wire                          mem2mig_icb_rsp_excl_ok;
    wire [`MYRISCV_DATADW-1:0]    mem2mig_icb_rsp_rdata;


    reg calib_done_r1, calib_done_r2;
    always@(posedge ui_clk) begin
        calib_done_r1 <= calib_done;
        calib_done_r2 <= calib_done_r1;
    end

    
    
    reg [63:0] time_cnt;
    
    always @(posedge ui_clk) begin
        if(ui_rst | ~calib_done_r2) begin
            time_cnt <= 0;
        end
        else if(time_cnt == 64'd99_999_999)begin
            time_cnt <= 0;
        end
        else begin
            time_cnt <= time_cnt + 1'b1;
        end
    end

    reg [63:0] pix_cnt;
    always @(posedge ui_clk) begin
        if(ui_rst | ~calib_done_r2) begin
            pix_cnt <= 0;

        end
        else if(mem2mig_icb_cmd_valid & mem2mig_icb_cmd_ready & (pix_cnt < (800*600)))begin
            pix_cnt <= pix_cnt + 1'b1;
        end
        else if((pix_cnt >= (800*600)) && time_cnt == 64'd99_999_999) begin
            pix_cnt <= 0;
        end
    end
    assign mem2mig_icb_rsp_ready = 1'b1;
    assign mem2mig_icb_cmd_valid = (pix_cnt < (800*600));
    assign mem2mig_icb_cmd_read = 1'b0;
    assign mem2mig_icb_cmd_addr = 64'hf000_0000 + (pix_cnt<<2);
    assign mem2mig_icb_cmd_wmask = pix_cnt[0] ? 8'h0f : 8'hf0;
    reg [31:0] pix_color;
    assign mem2mig_icb_cmd_wdata = {pix_color, pix_color};

    always @(posedge ui_clk) begin
        if(ui_rst | ~calib_done_r2) begin
            pix_color <= 32'hff0000;
        end
        else if(pix_cnt == (800*100-1) || pix_cnt == (800*200-1) || pix_cnt == (800*300-1) || pix_cnt == (800*400-1)
            || pix_cnt == (800*500-1) || pix_cnt == (800*600-1)) begin
            pix_color <= {8'd0, pix_color[7:0], pix_color[23:8]};
        end
    end

    icb2axi #(
        .AXI_FIFO_DP        (16),
        .AXI_FIFO_CUT_READY (1),
        .AW                 (32),
        .FIFO_OUTS_NUM      (16),
        .FIFO_CUT_READY     (0),
        .DW                 (64),
        .LOCKW              (1),
        .AXILENW            (8)
    ) icb2axi_mem_inst(
        .i_icb_cmd_valid    (mem2mig_icb_cmd_valid),
        .i_icb_cmd_ready    (mem2mig_icb_cmd_ready), 
        .i_icb_cmd_read     (mem2mig_icb_cmd_read), 
        .i_icb_cmd_addr     (mem2mig_icb_cmd_addr), 
        .i_icb_cmd_wdata    (mem2mig_icb_cmd_wdata), 
        .i_icb_cmd_wmask    (mem2mig_icb_cmd_wmask),
        // .i_icb_cmd_size(mem2mig_icb_cmd_size),

        .i_icb_rsp_valid    (mem2mig_icb_rsp_valid), 
        .i_icb_rsp_ready    (mem2mig_icb_rsp_ready), 
        .i_icb_rsp_err      (mem2mig_icb_rsp_err),
        .i_icb_rsp_rdata    (mem2mig_icb_rsp_rdata), 
        
        .o_axi_arvalid (mem_axi_arvalid),
        .o_axi_arready (mem_axi_arready),
        .o_axi_araddr (mem_axi_araddr),
        .o_axi_arcache (mem_axi_arcache),
        .o_axi_arprot (mem_axi_arprot),
        .o_axi_arlock (mem_axi_arlock),
        .o_axi_arburst (mem_axi_arburst),
        .o_axi_arlen (mem_axi_arlen),
        .o_axi_arsize (mem_axi_arsize),

        .o_axi_awvalid (mem_axi_awvalid),
        .o_axi_awready (mem_axi_awready),
        .o_axi_awaddr (mem_axi_awaddr),
        .o_axi_awcache (mem_axi_awcache),
        .o_axi_awprot (mem_axi_awprot),
        .o_axi_awlock (mem_axi_awlock),
        .o_axi_awburst (mem_axi_awburst),
        .o_axi_awlen (mem_axi_awlen),
        .o_axi_awsize (mem_axi_awsize),

        .o_axi_rvalid (mem_axi_rvalid),
        .o_axi_rready (mem_axi_rready),
        .o_axi_rdata (mem_axi_rdata),
        .o_axi_rresp (mem_axi_rresp),
        .o_axi_rlast (mem_axi_rlast),

        .o_axi_wvalid (mem_axi_wvalid),
        .o_axi_wready (mem_axi_wready),
        .o_axi_wdata (mem_axi_wdata),
        .o_axi_wstrb (mem_axi_wstrb),
        .o_axi_wlast (mem_axi_wlast),

        .o_axi_bvalid (mem_axi_bvalid),
        .o_axi_bready (mem_axi_bready),
        .o_axi_bresp (mem_axi_bresp),

        .clk         (ui_clk),
        .rst       ((~ui_rst) & calib_done_r2)
    );

    
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


    wire [3:0]  ppi_axi_arid;
    wire [31:0] ppi_axi_araddr;
    wire [7:0]  ppi_axi_arlen;
    wire [2:0]  ppi_axi_arsize;
    wire [1:0]  ppi_axi_arburst;
    wire [0:0]  ppi_axi_arlock;
    wire [3:0]  ppi_axi_arcache;
    wire [2:0]  ppi_axi_arprot;
    wire [3:0]  ppi_axi_arqos = 0;
    wire        ppi_axi_arready;
    wire        ppi_axi_arvalid;
    
    wire            ppi_axi_rready;
    wire [3:0]      ppi_axi_rid;
    wire [63:0]     ppi_axi_rdata;
    wire [1:0]      ppi_axi_rresp;
    wire            ppi_axi_rlast;
    wire            ppi_axi_rvalid;


    wire [3:0]  ppi_axi_awid;
    wire [31:0] ppi_axi_awaddr;
    wire [7:0]  ppi_axi_awlen;
    wire [2:0]  ppi_axi_awsize;
    wire [1:0]  ppi_axi_awburst;
    wire [0:0]  ppi_axi_awlock;
    wire [3:0]  ppi_axi_awcache;
    wire [2:0]  ppi_axi_awprot;
    wire [3:0]  ppi_axi_awqos = 0;
    wire        ppi_axi_awvalid;
    wire        ppi_axi_awready;
    

    wire [3:0]  ppi_axi_bid;
    wire        ppi_axi_bready;
    wire [1:0]  ppi_axi_bresp;
    wire        ppi_axi_bvalid;

    wire [63:0]    ppi_axi_wdata;
    wire [7:0]     ppi_axi_wstrb;
    wire            ppi_axi_wlast;
    wire            ppi_axi_wready;
    wire            ppi_axi_wvalid;

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

    assign simple_gpu_icb_cmd_valid = 1'b0;
    assign simple_gpu_icb_rsp_ready = 1'b1;

    wire          vga_vsync;
    wire          vga_hsync;
    wire          vga_en;
    wire [23:0]   vga_data;

    wire r_fifo_error;
    sgpu_top sgpu_inst (
        .clk                (ui_clk),
        .rst                ((~ui_rst) & calib_done_r2),

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

        .o_icb_cmd_vld      (ppi2mig_icb_cmd_valid),
        .o_icb_cmd_rdy      (ppi2mig_icb_cmd_ready),
        .o_icb_cmd_read     (ppi2mig_icb_cmd_read),
        .o_icb_cmd_addr     (ppi2mig_icb_cmd_addr),
        .o_icb_cmd_wdata    (ppi2mig_icb_cmd_wdata),
        .o_icb_cmd_wmask    (ppi2mig_icb_cmd_wmask),

        .o_icb_rsp_vld      (ppi2mig_icb_rsp_valid),
        .o_icb_rsp_rdy      (ppi2mig_icb_rsp_ready),
        .o_icb_rsp_rdata    (ppi2mig_icb_rsp_rdata),
        .o_icb_rsp_err      (ppi2mig_icb_rsp_err),

        .clk_pix            (clk_vga),
        .vga_vsync          (vga_vsync),
        .vga_hsync          (vga_hsync),
        .vga_en             (vga_en),
        .vga_data           (vga_data),

        .r_fifo_error              (r_fifo_error)
    );

    assign led[0] = r_fifo_error;

    icb2axi #(
        .AXI_FIFO_DP        (16),
        .AXI_FIFO_CUT_READY (1),
        .AW                 (32),
        .FIFO_OUTS_NUM      (16),
        .FIFO_CUT_READY     (0),
        .DW                 (64),
        .LOCKW              (1),
        .AXILENW            (8)
    ) icb2axi_ppi_inst(
        .i_icb_cmd_valid    (ppi2mig_icb_cmd_valid),
        .i_icb_cmd_ready    (ppi2mig_icb_cmd_ready), 
        .i_icb_cmd_read     (ppi2mig_icb_cmd_read), 
        .i_icb_cmd_addr     (ppi2mig_icb_cmd_addr), 
        .i_icb_cmd_wdata    (ppi2mig_icb_cmd_wdata), 
        .i_icb_cmd_wmask    (ppi2mig_icb_cmd_wmask),
        // .i_icb_cmd_size(ppi2mig_icb_cmd_size),

        .i_icb_rsp_valid    (ppi2mig_icb_rsp_valid), 
        .i_icb_rsp_ready    (ppi2mig_icb_rsp_ready), 
        .i_icb_rsp_err      (ppi2mig_icb_rsp_err),
        .i_icb_rsp_rdata    (ppi2mig_icb_rsp_rdata), 
        
        .o_axi_arvalid (ppi_axi_arvalid),
        .o_axi_arready (ppi_axi_arready),
        .o_axi_araddr (ppi_axi_araddr),
        .o_axi_arcache (ppi_axi_arcache),
        .o_axi_arprot (ppi_axi_arprot),
        .o_axi_arlock (ppi_axi_arlock),
        .o_axi_arburst (ppi_axi_arburst),
        .o_axi_arlen (ppi_axi_arlen),
        .o_axi_arsize (ppi_axi_arsize),

        .o_axi_awvalid (ppi_axi_awvalid),
        .o_axi_awready (ppi_axi_awready),
        .o_axi_awaddr (ppi_axi_awaddr),
        .o_axi_awcache (ppi_axi_awcache),
        .o_axi_awprot (ppi_axi_awprot),
        .o_axi_awlock (ppi_axi_awlock),
        .o_axi_awburst (ppi_axi_awburst),
        .o_axi_awlen (ppi_axi_awlen),
        .o_axi_awsize (ppi_axi_awsize),

        .o_axi_rvalid (ppi_axi_rvalid),
        .o_axi_rready (ppi_axi_rready),
        .o_axi_rdata (ppi_axi_rdata),
        .o_axi_rresp (ppi_axi_rresp),
        .o_axi_rlast (ppi_axi_rlast),

        .o_axi_wvalid (ppi_axi_wvalid),
        .o_axi_wready (ppi_axi_wready),
        .o_axi_wdata (ppi_axi_wdata),
        .o_axi_wstrb (ppi_axi_wstrb),
        .o_axi_wlast (ppi_axi_wlast),

        .o_axi_bvalid (ppi_axi_bvalid),
        .o_axi_bready (ppi_axi_bready),
        .o_axi_bresp (ppi_axi_bresp),

        .clk         (ui_clk),
        .rst       ((~ui_rst) & calib_done_r2)
    );


    //r:arbt_axi

    wire [3:0]  S00_AXI_arid;
    wire [31:0] S00_AXI_araddr;
    wire [7:0]  S00_AXI_arlen;
    wire [2:0]  S00_AXI_arsize;
    wire [1:0]  S00_AXI_arburst;
    wire [0:0]  S00_AXI_arlock;
    wire [3:0]  S00_AXI_arcache;
    wire [2:0]  S00_AXI_arprot;
    wire [3:0]  S00_AXI_arqos = 0;
    wire        S00_AXI_arready;
    wire        S00_AXI_arvalid;
    
    wire            S00_AXI_rready;
    wire [3:0]      S00_AXI_rid;
    wire [63:0]     S00_AXI_rdata;
    wire [1:0]      S00_AXI_rresp;
    wire            S00_AXI_rlast;
    wire            S00_AXI_rvalid;


    wire [3:0]  S00_AXI_awid;
    wire [31:0] S00_AXI_awaddr;
    wire [7:0]  S00_AXI_awlen;
    wire [2:0]  S00_AXI_awsize;
    wire [1:0]  S00_AXI_awburst;
    wire [0:0]  S00_AXI_awlock;
    wire [3:0]  S00_AXI_awcache;
    wire [2:0]  S00_AXI_awprot;
    wire [3:0]  S00_AXI_awqos = 0;
    wire        S00_AXI_awvalid;
    wire        S00_AXI_awready;
    

    wire [3:0]  S00_AXI_bid;
    wire        S00_AXI_bready;
    wire [1:0]  S00_AXI_bresp;
    wire        S00_AXI_bvalid;

    wire [63:0]    S00_AXI_wdata;
    wire [7:0]     S00_AXI_wstrb;
    wire            S00_AXI_wlast;
    wire            S00_AXI_wready;
    wire            S00_AXI_wvalid;

    // #(
    //     parameter AW = 32,
    //     parameter DW = 32,
    //     parameter LOCKW = 1,
    //     parameter AXILENW = 8,
    //     parameter FIFO_DP = 2,
    //     parameter FIFO_CUT_READY = 1,
    //     parameter ALLOW_0CYCL_RSP = 1,
    //     parameter ARBT_NUM = 2
    // )
    axi_arbt #(
        .AW                 (32),
        .DW                 (`MYRISCV_DATADW),
        .LOCKW              (1),
        .AXILENW            (8),
        .FIFO_DP            (2),
        .FIFO_CUT_READY     (1),
        .ALLOW_0CYCL_RSP    (1),
        .ARBT_NUM           (2)
    ) arbt_axi_inst
    (
        .i_axi_arvalid_bus  ({mem_axi_arvalid, ppi_axi_arvalid}),
        .i_axi_arready_bus  ({mem_axi_arready, ppi_axi_arready}),
        .i_axi_araddr_bus  ({mem_axi_araddr, ppi_axi_araddr}),
        .i_axi_arcache_bus  ({mem_axi_arcache, ppi_axi_arcache}),
        .i_axi_arprot_bus  ({mem_axi_arprot, ppi_axi_arprot}),
        .i_axi_arlock_bus  ({mem_axi_arlock, ppi_axi_arlock}),
        .i_axi_arburst_bus  ({mem_axi_arburst, ppi_axi_arburst}),
        .i_axi_arlen_bus  ({mem_axi_arlen, ppi_axi_arlen}),
        .i_axi_arsize_bus  ({mem_axi_arsize, ppi_axi_arsize}),

        .i_axi_awvalid_bus  ({mem_axi_awvalid, ppi_axi_awvalid}),
        .i_axi_awready_bus  ({mem_axi_awready, ppi_axi_awready}),
        .i_axi_awaddr_bus  ({mem_axi_awaddr, ppi_axi_awaddr}),
        .i_axi_awcache_bus  ({mem_axi_awcache, ppi_axi_awcache}),
        .i_axi_awprot_bus  ({mem_axi_awprot, ppi_axi_awprot}),
        .i_axi_awlock_bus  ({mem_axi_awlock, ppi_axi_awlock}),
        .i_axi_awburst_bus  ({mem_axi_awburst, ppi_axi_awburst}),
        .i_axi_awlen_bus  ({mem_axi_awlen, ppi_axi_awlen}),
        .i_axi_awsize_bus  ({mem_axi_awsize, ppi_axi_awsize}),

        .i_axi_rvalid_bus  ({mem_axi_rvalid, ppi_axi_rvalid}),
        .i_axi_rready_bus  ({mem_axi_rready, ppi_axi_rready}),
        .i_axi_rdata_bus  ({mem_axi_rdata, ppi_axi_rdata}),
        .i_axi_rresp_bus  ({mem_axi_rresp, ppi_axi_rresp}),
        .i_axi_rlast_bus  ({mem_axi_rlast, ppi_axi_rlast}),

        .i_axi_wvalid_bus  ({mem_axi_wvalid, ppi_axi_wvalid}),
        .i_axi_wready_bus  ({mem_axi_wready, ppi_axi_wready}),
        .i_axi_wdata_bus  ({mem_axi_wdata, ppi_axi_wdata}),
        .i_axi_wstrb_bus  ({mem_axi_wstrb, ppi_axi_wstrb}),
        .i_axi_wlast_bus  ({mem_axi_wlast, ppi_axi_wlast}),

        .i_axi_bvalid_bus  ({mem_axi_bvalid, ppi_axi_bvalid}),
        .i_axi_bready_bus  ({mem_axi_bready, ppi_axi_bready}),
        .i_axi_bresp_bus  ({mem_axi_bresp, ppi_axi_bresp}),

        .o_axi_arvalid(S00_AXI_arvalid),
        .o_axi_arready(S00_AXI_arready),
        .o_axi_araddr(S00_AXI_araddr),
        .o_axi_arcache(S00_AXI_arcache),
        .o_axi_arprot(S00_AXI_arprot),
        .o_axi_arlock(S00_AXI_arlock),
        .o_axi_arburst(S00_AXI_arburst),
        .o_axi_arlen(S00_AXI_arlen),
        .o_axi_arsize(S00_AXI_arsize),

        .o_axi_awvalid(S00_AXI_awvalid),
        .o_axi_awready(S00_AXI_awready),
        .o_axi_awaddr(S00_AXI_awaddr),
        .o_axi_awcache(S00_AXI_awcache),
        .o_axi_awprot(S00_AXI_awprot),
        .o_axi_awlock(S00_AXI_awlock),
        .o_axi_awburst(S00_AXI_awburst),
        .o_axi_awlen(S00_AXI_awlen),
        .o_axi_awsize(S00_AXI_awsize),

        .o_axi_rvalid(S00_AXI_rvalid),
        .o_axi_rready(S00_AXI_rready),
        .o_axi_rdata(S00_AXI_rdata),
        .o_axi_rresp(S00_AXI_rresp),
        .o_axi_rlast(S00_AXI_rlast),

        .o_axi_wvalid(S00_AXI_wvalid),
        .o_axi_wready(S00_AXI_wready),
        .o_axi_wdata(S00_AXI_wdata),
        .o_axi_wstrb(S00_AXI_wstrb),
        .o_axi_wlast(S00_AXI_wlast),

        .o_axi_bvalid(S00_AXI_bvalid),
        .o_axi_bready(S00_AXI_bready),
        .o_axi_bresp(S00_AXI_bresp),
                
        .clk            (ui_clk),
        .rst            ((~ui_rst) & calib_done_r2)
    );


    //r:end


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
        
        .sys_clk_i  (ddr3_clk),
        .clk_ref_i  (clk_200m),
        .ui_clk         (ui_clk),
        .ui_clk_sync_rst    (ui_rst),
        .mmcm_locked  (),
        .aresetn  (locked),
        .app_sr_req  ('b0),
        .app_ref_req    ('b0),
        .app_zq_req  ('b0),
        .app_sr_active  (),
        .app_ref_ack    (),
        .app_zq_ack  (),
        
        .s_axi_awid     (4'b1111),
        .s_axi_awaddr (S00_AXI_awaddr),
        .s_axi_awlen (S00_AXI_awlen),
        .s_axi_awsize (S00_AXI_awsize),
        .s_axi_awburst (S00_AXI_awburst),
        .s_axi_awlock (S00_AXI_awlock),
        .s_axi_awcache (S00_AXI_awcache),
        .s_axi_awprot (S00_AXI_awprot),
        .s_axi_awqos (4'b0000),
        .s_axi_awvalid (S00_AXI_awvalid),
        .s_axi_awready (S00_AXI_awready),
        
        .s_axi_wdata (S00_AXI_wdata),
        .s_axi_wstrb (S00_AXI_wstrb),
        .s_axi_wlast (S00_AXI_wlast),
        .s_axi_wvalid (S00_AXI_wvalid),
        .s_axi_wready (S00_AXI_wready),

        .s_axi_bready (S00_AXI_bready),
        .s_axi_bid     (S00_AXI_bid),
        .s_axi_bresp (S00_AXI_bresp),
        .s_axi_bvalid (S00_AXI_bvalid),
        
        .s_axi_arid     (4'b0000),
        .s_axi_araddr (S00_AXI_araddr),
        .s_axi_arlen (S00_AXI_arlen),
        .s_axi_arsize (S00_AXI_arsize),
        .s_axi_arburst (S00_AXI_arburst),
        .s_axi_arlock (S00_AXI_arlock),
        .s_axi_arcache (S00_AXI_arcache),
        .s_axi_arprot (S00_AXI_arprot),
        .s_axi_arqos (4'b0000),
        .s_axi_arvalid (S00_AXI_arvalid),
        .s_axi_arready (S00_AXI_arready),

        .s_axi_rready (S00_AXI_rready),
        .s_axi_rid     (),
        .s_axi_rdata (S00_AXI_rdata),
        .s_axi_rresp (S00_AXI_rresp),
        .s_axi_rlast (S00_AXI_rlast),
        .s_axi_rvalid (S00_AXI_rvalid),
        
        .init_calib_complete (calib_done),
        .sys_rst             (locked)
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



endmodule
