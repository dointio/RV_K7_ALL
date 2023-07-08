`include "mydefines.v"
module ddr_vga_test
(
    input wire sys_clk,
    output wire calib_done,

    output reg [3:0] led,

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
    wire [63:0]     S00_AXI_RD_rdata;
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
        else if(time_cnt == 64'd99_999_999) begin
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
        else if(pix_cnt == (800*300-1)) begin
            pix_color <= {8'd0, pix_color[7:0], pix_color[23:8]};
        end
        else if(pix_cnt == (800*600-1)) begin
            pix_color <= {8'd0, pix_color[7:0], pix_color[23:8]};
        end
    end

    
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
    
    
        .clk            (ui_clk),
        .rst            ((~ui_rst) & calib_done_r2)
    );

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
        .i_icb_cmd_valid    (mig_icb_cmd_valid),
        .i_icb_cmd_ready    (mig_icb_cmd_ready), 
        .i_icb_cmd_read     (mig_icb_cmd_read), 
        .i_icb_cmd_addr     (mig_icb_cmd_addr), 
        .i_icb_cmd_wdata    (mig_icb_cmd_wdata), 
        .i_icb_cmd_wmask    (mig_icb_cmd_wmask),
        // .i_icb_cmd_size(mig_icb_cmd_size),

        .i_icb_rsp_valid    (mig_icb_rsp_valid), 
        .i_icb_rsp_ready    (mig_icb_rsp_ready), 
        .i_icb_rsp_err      (mig_icb_rsp_err),
        .i_icb_rsp_rdata    (mig_icb_rsp_rdata), 
        
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
        .rst       ((~ui_rst) & calib_done_r2)
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
        .s_axi_awaddr (S00_AXI_WR_awaddr),
        .s_axi_awlen (S00_AXI_WR_awlen),
        .s_axi_awsize (S00_AXI_WR_awsize),
        .s_axi_awburst (S00_AXI_WR_awburst),
        .s_axi_awlock (S00_AXI_WR_awlock),
        .s_axi_awcache (S00_AXI_WR_awcache),
        .s_axi_awprot (S00_AXI_WR_awprot),
        .s_axi_awqos (4'b0000),
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
        
        .s_axi_arid     (4'b0000),
        .s_axi_araddr (S00_AXI_RD_araddr),
        .s_axi_arlen (S00_AXI_RD_arlen),
        .s_axi_arsize (S00_AXI_RD_arsize),
        .s_axi_arburst (S00_AXI_RD_arburst),
        .s_axi_arlock (S00_AXI_RD_arlock),
        .s_axi_arcache (S00_AXI_RD_arcache),
        .s_axi_arprot (S00_AXI_RD_arprot),
        .s_axi_arqos (4'b0000),
        .s_axi_arvalid (S00_AXI_RD_arvalid),
        .s_axi_arready (S00_AXI_RD_arready),

        .s_axi_rready (S00_AXI_RD_rready),
        .s_axi_rid     (),
        .s_axi_rdata (S00_AXI_RD_rdata),
        .s_axi_rresp (S00_AXI_RD_rresp),
        .s_axi_rlast (S00_AXI_RD_rlast),
        .s_axi_rvalid (S00_AXI_RD_rvalid),
        
        .init_calib_complete (calib_done),
        .sys_rst             (locked)
    );


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
        .vga_data           (vga_data)
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
