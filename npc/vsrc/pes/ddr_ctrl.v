
module ddr_ctrl
(
    i_icb_cmd_valid,
    i_icb_cmd_ready,
    i_icb_cmd_read,
    i_icb_cmd_addr,
    i_icb_cmd_wdata,
    i_icb_cmd_wmask,

    i_icb_rsp_valid,
    i_icb_rsp_ready,
    i_icb_rsp_err,
    i_icb_rsp_rdata
);
    input  i_icb_cmd_valid;
    output i_icb_cmd_ready;
    input  i_icb_cmd_read;
    input [31:0]     i_icb_cmd_addr;
    input [63:0]     i_icb_cmd_wdata;
    input [7:0]      i_icb_cmd_wmask;

    output  i_icb_rsp_valid;
    input   i_icb_rsp_ready;
    output  i_icb_rsp_err;
    output  [63:0]     i_icb_rsp_rdata;

    wire ui_clk;
    wire rst;

    wire [3:0]  S00_AXI_RD_arid;
    wire [31:0] S00_AXI_RD_araddr;
    wire [7:0]  S00_AXI_RD_arlen;
    wire [2:0]  S00_AXI_RD_arsize;
    wire [1:0]  S00_AXI_RD_arburst;
    wire [0:0]  S00_AXI_RD_arlock;
    wire [3:0]  S00_AXI_RD_arcache;
    wire [2:0]  S00_AXI_RD_arprot;
    wire [3:0]  S00_AXI_RD_arqos = 0;
    wire        S00_AXI_RD_arready;
    wire        S00_AXI_RD_arvalid;
    
    wire            S00_AXI_RD_rready;
    wire [3:0]      S00_AXI_RD_rid;
    wire [63:0]    S00_AXI_RD_rdata;
    wire [1:0]      S00_AXI_RD_rresp;
    wire            S00_AXI_RD_rlast;
    wire            S00_AXI_RD_rvalid;


    wire [3:0]  S00_AXI_WR_awid;
    wire [31:0] S00_AXI_WR_awaddr;
    wire [7:0]  S00_AXI_WR_awlen;
    wire [2:0]  S00_AXI_WR_awsize;
    wire [1:0]  S00_AXI_WR_awburst;
    wire [0:0]  S00_AXI_WR_awlock;
    wire [3:0]  S00_AXI_WR_awcache;
    wire [2:0]  S00_AXI_WR_awprot;
    wire [3:0]  S00_AXI_WR_awqos = 0;
    wire        S00_AXI_WR_awvalid;
    wire        S00_AXI_WR_awready;
    

    wire [3:0]  S00_AXI_WR_bid;
    wire        S00_AXI_WR_bready;
    wire [1:0]  S00_AXI_WR_bresp;
    wire        S00_AXI_WR_bvalid;

    wire [63:0]    S00_AXI_WR_wdata;
    wire [7:0]     S00_AXI_WR_wstrb;
    wire            S00_AXI_WR_wlast;
    wire            S00_AXI_WR_wready;
    wire            S00_AXI_WR_wvalid;

    icb2axi #(
        .AXI_FIFO_DP        (4),
        .AXI_FIFO_CUT_READY (1),
        .AW                 (32),
        .FIFO_OUTS_NUM      (8),
        .FIFO_CUT_READY     (0),
        .DW                 (64),
        .LOCKW              (1),
        .AXILENW            (8)
    ) icb2axi_inst(
        .i_icb_cmd_valid    (i_icb_cmd_valid),
        .i_icb_cmd_ready    (i_icb_cmd_ready), 
        .i_icb_cmd_read     (i_icb_cmd_read), 
        .i_icb_cmd_addr     (i_icb_cmd_addr), 
        .i_icb_cmd_wdata    (i_icb_cmd_wdata), 
        .i_icb_cmd_wmask    (i_icb_cmd_wmask),
        // .i_icb_cmd_size(i_icb_cmd_size),

        .i_icb_rsp_valid    (i_icb_rsp_valid), 
        .i_icb_rsp_ready    (i_icb_rsp_ready), 
        .i_icb_rsp_err      (i_icb_rsp_err),
        .i_icb_rsp_rdata    (i_icb_rsp_rdata), 
        
        .o_axi_arvalid (S00_AXI_RD_arvalid),
        .o_axi_arready (S00_AXI_RD_arready),
        .o_axi_araddr (S00_AXI_RD_araddr),
        .o_axi_arcache (S00_AXI_RD_arcache),
        .o_axi_arprot (S00_AXI_RD_arprot),
        .o_axi_arlock (S00_AXI_RD_arlock),
        .o_axi_arburst (S00_AXI_RD_arburst),
        .o_axi_arlen (S00_AXI_RD_arlen),
        .o_axi_arsize (S00_AXI_RD_arsize),

        .o_axi_awvalid (S00_AXI_WR_awvalid),
        .o_axi_awready (S00_AXI_WR_awready),
        .o_axi_awaddr (S00_AXI_WR_awaddr),
        .o_axi_awcache (S00_AXI_WR_awcache),
        .o_axi_awprot (S00_AXI_WR_awprot),
        .o_axi_awlock (S00_AXI_WR_awlock),
        .o_axi_awburst (S00_AXI_WR_awburst),
        .o_axi_awlen (S00_AXI_WR_awlen),
        .o_axi_awsize (S00_AXI_WR_awsize),

        .o_axi_rvalid (S00_AXI_RD_rvalid),
        .o_axi_rready (S00_AXI_RD_rready),
        .o_axi_rdata (S00_AXI_RD_rdata),
        .o_axi_rresp (S00_AXI_RD_rresp),
        .o_axi_rlast (S00_AXI_RD_rlast),

        .o_axi_wvalid (S00_AXI_WR_wvalid),
        .o_axi_wready (S00_AXI_WR_wready),
        .o_axi_wdata (S00_AXI_WR_wdata),
        .o_axi_wstrb (S00_AXI_WR_wstrb),
        .o_axi_wlast (S00_AXI_WR_wlast),

        .o_axi_bvalid (S00_AXI_WR_bvalid),
        .o_axi_bready (S00_AXI_WR_bready),
        .o_axi_bresp (S00_AXI_WR_bresp),

        .clk         (ui_clk),
        .rst         (rst)
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
        
        .sys_clk_i  (ddr3_clk),
        .clk_ref_i  (ddr3_clk),
        .ui_clk         (ui_clk),
        .ui_clk_sync_rst    (ui_rst),
        .mmcm_locked  (),
        .aresetn  (rst),
        .app_sr_req  ('b0),
        .app_ref_req    ('b0),
        .app_zq_req  ('b0),
        .app_sr_active  (),
        .app_ref_ack    (),
        .app_zq_ack  (),
        
        .s_axi_awid     (S00_AXI_WR_awid),
        .s_axi_awaddr (S00_AXI_WR_awaddr),
        .s_axi_awlen (S00_AXI_WR_awlen),
        .s_axi_awsize (S00_AXI_WR_awsize),
        .s_axi_awburst (S00_AXI_WR_awburst),
        .s_axi_awlock (S00_AXI_WR_awlock),
        .s_axi_awcache (S00_AXI_WR_awcache),
        .s_axi_awprot (S00_AXI_WR_awprot),
        .s_axi_awqos (S00_AXI_WR_awqos),
        .s_axi_awvalid (S00_AXI_WR_awvalid),
        .s_axi_awready (S00_AXI_WR_awready),
        
        .s_axi_wdata (S00_AXI_WR_wdata),
        .s_axi_wstrb (S00_AXI_WR_wstrb),
        .s_axi_wlast (S00_AXI_WR_wlast),
        .s_axi_wvalid (S00_AXI_WR_wvalid),
        .s_axi_wready (S00_AXI_WR_wready),

        .s_axi_bready (S00_AXI_WR_bready),
        .s_axi_bid     (S00_AXI_WR_bid),
        .s_axi_bresp (S00_AXI_WR_bresp),
        .s_axi_bvalid (S00_AXI_WR_bvalid),
        
        .s_axi_arid     (S00_AXI_RD_arid),
        .s_axi_araddr (S00_AXI_RD_araddr),
        .s_axi_arlen (S00_AXI_RD_arlen),
        .s_axi_arsize (S00_AXI_RD_arsize),
        .s_axi_arburst (S00_AXI_RD_arburst),
        .s_axi_arlock (S00_AXI_RD_arlock),
        .s_axi_arcache (S00_AXI_RD_arcache),
        .s_axi_arprot (S00_AXI_RD_arprot),
        .s_axi_arqos (S00_AXI_RD_arqos),
        .s_axi_arvalid (S00_AXI_RD_arvalid),
        .s_axi_arready (S00_AXI_RD_arready),

        .s_axi_rready (S00_AXI_RD_rready), 
        .s_axi_rid     (S00_AXI_RD_rid),
        .s_axi_rdata (S00_AXI_RD_rdata),
        .s_axi_rresp (S00_AXI_RD_rresp),
        .s_axi_rlast (S00_AXI_RD_rlast),
        .s_axi_rvalid (S00_AXI_RD_rvalid),
        
        .init_calib_complete (calib_done),
        .sys_rst             (rst)
    );


endmodule
