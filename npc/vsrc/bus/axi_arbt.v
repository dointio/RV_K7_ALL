module axi_arbt
#(
  parameter AW = 32,
  parameter DW = 32,
  parameter LOCKW = 1,
  parameter AXILENW = 8,
  parameter FIFO_DP = 2,
  parameter FIFO_CUT_READY = 1,
  parameter ALLOW_0CYCL_RSP = 1,
  parameter ARBT_NUM = 2
)
(
  input     [ARBT_NUM-1 : 0]            i_axi_arvalid_bus,
  output    [ARBT_NUM-1 : 0]            i_axi_arready_bus,
  input     [ARBT_NUM*AW-1 : 0]         i_axi_araddr_bus,
  input     [ARBT_NUM*4-1 : 0]          i_axi_arcache_bus,
  input     [ARBT_NUM*3-1 : 0]          i_axi_arprot_bus,
  input     [ARBT_NUM*LOCKW-1 : 0]      i_axi_arlock_bus,
  input     [ARBT_NUM*2-1 : 0]          i_axi_arburst_bus,
  input     [ARBT_NUM*AXILENW-1 : 0]    i_axi_arlen_bus,
  input     [ARBT_NUM*3-1 : 0]          i_axi_arsize_bus,

  input     [ARBT_NUM-1 : 0]            i_axi_awvalid_bus,
  output    [ARBT_NUM-1 : 0]            i_axi_awready_bus,
  input     [ARBT_NUM*AW-1:0]           i_axi_awaddr_bus,
  input     [ARBT_NUM*4-1:0]            i_axi_awcache_bus,
  input     [ARBT_NUM*3-1:0]            i_axi_awprot_bus,
  input     [ARBT_NUM*LOCKW-1:0]        i_axi_awlock_bus,
  input     [ARBT_NUM*2-1:0]            i_axi_awburst_bus,
  input     [ARBT_NUM*AXILENW-1:0]      i_axi_awlen_bus,
  input     [ARBT_NUM*3-1:0]            i_axi_awsize_bus,

  output    [ARBT_NUM-1 : 0]            i_axi_rvalid_bus,
  input     [ARBT_NUM-1 : 0]            i_axi_rready_bus,
  output    [ARBT_NUM*DW-1 : 0]         i_axi_rdata_bus,
  output    [ARBT_NUM*2-1 : 0]          i_axi_rresp_bus,
  output    [ARBT_NUM-1 : 0]            i_axi_rlast_bus,

  input     [ARBT_NUM-1 : 0]            i_axi_wvalid_bus,
  output    [ARBT_NUM-1 : 0]            i_axi_wready_bus,
  input     [ARBT_NUM*DW-1 : 0]         i_axi_wdata_bus,
  input     [ARBT_NUM*(DW/8)-1 : 0]     i_axi_wstrb_bus,
  input     [ARBT_NUM-1 : 0]            i_axi_wlast_bus,

  output    [ARBT_NUM-1 : 0]            i_axi_bvalid_bus,
  input     [ARBT_NUM-1 : 0]            i_axi_bready_bus,
  output    [ARBT_NUM*2-1:0]            i_axi_bresp_bus,

  output o_axi_arvalid,
  input  o_axi_arready,
  output [AW-1:0] o_axi_araddr,
  output [3:0] o_axi_arcache,
  output [2:0] o_axi_arprot,
  output [LOCKW-1:0] o_axi_arlock,
  output [1:0] o_axi_arburst,
  output [AXILENW-1:0] o_axi_arlen,
  output [2:0] o_axi_arsize,

  output o_axi_awvalid,
  input  o_axi_awready,
  output [AW-1:0] o_axi_awaddr,
  output [3:0] o_axi_awcache,
  output [2:0] o_axi_awprot,
  output [LOCKW-1:0] o_axi_awlock,
  output [1:0] o_axi_awburst,
  output [AXILENW-1:0] o_axi_awlen,
  output [2:0] o_axi_awsize,

  input  o_axi_rvalid,
  output o_axi_rready,
  input  [DW-1:0] o_axi_rdata,
  input  [1:0] o_axi_rresp,
  input  o_axi_rlast,

  output o_axi_wvalid,
  input  o_axi_wready,
  output [DW-1:0] o_axi_wdata,
  output [(DW/8)-1:0] o_axi_wstrb,
  output o_axi_wlast,

  input  o_axi_bvalid,
  output o_axi_bready,
  input  [1:0] o_axi_bresp,
        
  input  clk,  
  input  rst 
);

localparam TRUE_CUT_READY = (ALLOW_0CYCL_RSP != 0) ? 1 : FIFO_CUT_READY;

generate
    if(ARBT_NUM == 1)  begin : one_chal
        assign o_axi_arvalid = i_axi_arvalid_bus;
        assign i_axi_arready_bus = o_axi_arready;
        assign o_axi_araddr = i_axi_araddr_bus;
        assign o_axi_arcache = i_axi_arcache_bus;
        assign o_axi_arprot = i_axi_arprot_bus;
        assign o_axi_arlock = i_axi_arlock_bus;
        assign o_axi_arburst = i_axi_arburst_bus;
        assign o_axi_arlen = i_axi_arlen_bus;
        assign o_axi_arsize = i_axi_arsize_bus;

        assign o_axi_awvalid = i_axi_awvalid_bus;
        assign i_axi_awready_bus = o_axi_awready;
        assign o_axi_awaddr = i_axi_awaddr_bus;
        assign o_axi_awcache = i_axi_awcache_bus;
        assign o_axi_awprot = i_axi_awprot_bus;
        assign o_axi_awlock = i_axi_awlock_bus;
        assign o_axi_awburst = i_axi_awburst_bus;
        assign o_axi_awlen = i_axi_awlen_bus;
        assign o_axi_awsize = i_axi_awsize_bus;

        assign i_axi_rvalid_bus = o_axi_rvalid;
        assign o_axi_rready = i_axi_rready_bus;
        assign i_axi_rdata_bus = o_axi_rdata;
        assign i_axi_rresp_bus = o_axi_rresp;
        assign i_axi_rlast_bus = o_axi_rlast;

        assign o_axi_wvalid = i_axi_wvalid_bus;
        assign i_axi_wready_bus = o_axi_wready;
        assign o_axi_wdata = i_axi_wdata_bus;
        assign o_axi_wstrb = i_axi_wstrb_bus;
        assign o_axi_wlast = i_axi_wlast_bus;

        assign i_axi_bvalid_bus = o_axi_bvalid;
        assign o_axi_bready = i_axi_bready_bus;
        assign i_axi_bresp_bus = o_axi_bresp;
    end
    else begin : more_chal
        //r: bus to arry(st)
        wire   [ARBT_NUM-1:0]i_axi_arvalid;
        wire   [ARBT_NUM-1:0]i_axi_arready;
        wire   [AW-1:0] i_axi_araddr[ARBT_NUM-1:0];
        wire   [3:0] i_axi_arcache[ARBT_NUM-1:0];
        wire   [2:0] i_axi_arprot[ARBT_NUM-1:0];
        wire   [LOCKW-1:0] i_axi_arlock[ARBT_NUM-1:0];
        wire   [1:0] i_axi_arburst[ARBT_NUM-1:0];
        wire   [AXILENW-1:0] i_axi_arlen[ARBT_NUM-1:0];
        wire   [2:0] i_axi_arsize[ARBT_NUM-1:0];

        wire   [ARBT_NUM-1:0]i_axi_awvalid;
        wire   [ARBT_NUM-1:0]i_axi_awready;
        wire   [AW-1:0] i_axi_awaddr[ARBT_NUM-1:0];
        wire   [3:0] i_axi_awcache[ARBT_NUM-1:0];
        wire   [2:0] i_axi_awprot[ARBT_NUM-1:0];
        wire   [LOCKW-1:0] i_axi_awlock[ARBT_NUM-1:0];
        wire   [1:0] i_axi_awburst[ARBT_NUM-1:0];
        wire   [AXILENW-1:0] i_axi_awlen[ARBT_NUM-1:0];
        wire   [2:0] i_axi_awsize[ARBT_NUM-1:0];

        wire   [ARBT_NUM-1:0]i_axi_rvalid;
        wire   [ARBT_NUM-1:0]i_axi_rready;
        wire   [DW-1:0] i_axi_rdata[ARBT_NUM-1:0];
        wire   [1:0] i_axi_rresp[ARBT_NUM-1:0];
        wire   [ARBT_NUM-1:0]i_axi_rlast;

        wire   [ARBT_NUM-1:0]i_axi_wvalid;
        wire   [ARBT_NUM-1:0]i_axi_wready;
        wire   [DW-1:0] i_axi_wdata[ARBT_NUM-1:0];
        wire   [(DW/8)-1:0] i_axi_wstrb[ARBT_NUM-1:0];
        wire   [ARBT_NUM-1:0]i_axi_wlast;

        wire   [ARBT_NUM-1:0]i_axi_bvalid;
        wire   [ARBT_NUM-1:0]i_axi_bready;
        wire   [1:0] i_axi_bresp[ARBT_NUM-1:0];

        genvar i;
        for(i = 0; i < ARBT_NUM; i = i+1)//{
        begin:icb_distract_gen
            assign i_axi_arvalid[i] = i_axi_arvalid_bus[i];
            assign i_axi_arready_bus[i] = i_axi_arready[i];
            assign i_axi_araddr[i] = i_axi_araddr_bus[(i+1)*AW-1:i*AW];
            assign i_axi_arcache[i] = i_axi_arcache_bus[(i+1)*4-1:i*4];
            assign i_axi_arprot[i] = i_axi_arprot_bus[(i+1)*3-1:i*3];
            assign i_axi_arlock[i] = i_axi_arlock_bus[(i+1)*LOCKW-1:i*LOCKW];
            assign i_axi_arburst[i] = i_axi_arburst_bus[(i+1)*2-1:i*2];
            assign i_axi_arlen[i] = i_axi_arlen_bus[(i+1)*AXILENW-1:i*AXILENW];
            assign i_axi_arsize[i] = i_axi_arsize_bus[(i+1)*3-1:i*3];

            assign i_axi_awvalid[i] = i_axi_awvalid_bus[i];
            assign i_axi_awready_bus[i] = i_axi_awready[i];
            assign i_axi_awaddr[i] = i_axi_awaddr_bus[(i+1)*AW-1:i*AW];
            assign i_axi_awcache[i] = i_axi_awcache_bus[(i+1)*4-1:i*4];
            assign i_axi_awprot[i] = i_axi_awprot_bus[(i+1)*3-1:i*3];
            assign i_axi_awlock[i] = i_axi_awlock_bus[(i+1)*LOCKW-1:i*LOCKW];
            assign i_axi_awburst[i] = i_axi_awburst_bus[(i+1)*2-1:i*2];
            assign i_axi_awlen[i] = i_axi_awlen_bus[(i+1)*AXILENW-1:i*AXILENW];
            assign i_axi_awsize[i] = i_axi_awsize_bus[(i+1)*3-1:i*3];

            assign i_axi_rvalid_bus[i] = i_axi_rvalid[i];
            assign i_axi_rready[i] = i_axi_rready_bus[i];
            assign i_axi_rdata_bus[(i+1)*DW-1:i*DW] = i_axi_rdata[i];
            assign i_axi_rresp_bus[(i+1)*2-1:i*2] = i_axi_rresp[i];
            assign i_axi_rlast_bus[i] = i_axi_rlast[i];

            assign i_axi_wvalid[i] = i_axi_wvalid_bus[i];
            assign i_axi_wready_bus[i] = i_axi_wready[i];
            assign i_axi_wdata[i] = i_axi_wdata_bus[(i+1)*DW-1:i*DW];
            assign i_axi_wstrb[i] = i_axi_wstrb_bus[(i+1)*(DW/8)-1:i*(DW/8)];
            assign i_axi_wlast[i] = i_axi_wlast_bus[i];

            assign i_axi_bvalid_bus[i] = i_axi_bvalid[i];
            assign i_axi_bready[i] = i_axi_bready_bus[i];
            assign i_axi_bresp_bus[(i+1)*2-1:i*2] = i_axi_bresp[i];
        end//}
        //r: bus to arry(end)

        //r: w_channel_arbt(st)

        wire fifo_w_unfull;
        wire fifo_w_unempty;
        wire fifo_w_bypass;

        wire axi_wvalid_mid;
        wire axi_wready_mid;
        wire axi_awvalid_mid;
        wire axi_awready_mid;
        wire axi_bvalid_mid;
        wire axi_bready_mid;

        wire [ARBT_NUM-1:0] axi_w_pre_selet;
        wire [ARBT_NUM-1:0] axi_w_selet;
        wire [ARBT_NUM-1:0] axi_w_selet_r;

        for(i=0; i<ARBT_NUM; i=i+1) begin : cmd_selsig
            if(i==0) begin
                assign axi_w_pre_selet[i] = 1;
            end
            else begin
                assign axi_w_pre_selet[i] = ~(|i_axi_awvalid[i-1:0]);
            end
            assign axi_w_selet[i] = axi_w_pre_selet[i] & i_axi_awvalid[i];
        end

        assign axi_awvalid_mid = | axi_w_selet;
        for(i = 0; i < ARBT_NUM; i = i+1) begin: cmd_
            assign i_axi_awready[i] = axi_awready_mid & axi_w_selet[i];
        end
        assign o_axi_awvalid = axi_awvalid_mid & fifo_w_unfull;
        assign axi_awready_mid = o_axi_awready & fifo_w_unfull;
        

        reg     [AW-1:0]           sel_axi_awaddr;
        reg     [4-1:0]            sel_axi_awcache;
        reg     [3-1:0]            sel_axi_awprot;
        reg     [LOCKW-1:0]        sel_axi_awlock;
        reg     [2-1:0]            sel_axi_awburst;
        reg     [AXILENW-1:0]      sel_axi_awlen;
        reg     [3-1:0]            sel_axi_awsize;

        always@(*)begin : sel_axi_aw
            integer j;
            sel_axi_awaddr  = {AW {1'b0}};
            sel_axi_awcache = {4  {1'b0}};
            sel_axi_awprot  = {3  {1'b0}};
            sel_axi_awlock  = {LOCKW  {1'b0}};
            sel_axi_awburst = {2  {1'b0}};
            sel_axi_awlen   = {AXILENW  {1'b0}};
            sel_axi_awsize  = {3  {1'b0}};
            for(j = 0; j < ARBT_NUM; j = j+1) begin//{
                sel_axi_awaddr  = sel_axi_awaddr  | ({AW       {axi_w_selet[j]}} & i_axi_awaddr  [j]);
                sel_axi_awcache = sel_axi_awcache | ({4        {axi_w_selet[j]}} & i_axi_awcache [j]);
                sel_axi_awprot  = sel_axi_awprot  | ({3        {axi_w_selet[j]}} & i_axi_awprot  [j]);
                sel_axi_awlock  = sel_axi_awlock  | ({LOCKW    {axi_w_selet[j]}} & i_axi_awlock  [j]);
                sel_axi_awburst = sel_axi_awburst | ({2        {axi_w_selet[j]}} & i_axi_awburst [j]);
                sel_axi_awlen   = sel_axi_awlen   | ({AXILENW  {axi_w_selet[j]}} & i_axi_awlen   [j]);
                sel_axi_awsize  = sel_axi_awsize  | ({3        {axi_w_selet[j]}} & i_axi_awsize  [j]);
            end//}
        end

        assign o_axi_awaddr  = sel_axi_awaddr  ;
        assign o_axi_awcache = sel_axi_awcache ;
        assign o_axi_awprot  = sel_axi_awprot  ;
        assign o_axi_awlock  = sel_axi_awlock  ;
        assign o_axi_awburst = sel_axi_awburst ;
        assign o_axi_awlen   = sel_axi_awlen   ;
        assign o_axi_awsize  = sel_axi_awsize  ;

        wire aw_handshake = o_axi_awvalid & o_axi_awready;
        wire b_handshake  = o_axi_bvalid  & o_axi_bready;

        wire [ARBT_NUM-1 : 0] fifo_w_data_i = axi_w_selet;
        wire [ARBT_NUM-1 : 0] fifo_w_data_o;

        if(ALLOW_0CYCL_RSP != 0) begin : allow_0rsp
            assign fifo_w_bypass  = ~fifo_w_unempty & aw_handshake & b_handshake;
            assign axi_w_selet_r  = fifo_w_unempty ? fifo_w_data_o : axi_w_selet;
            // assign axi_bvalid_mid = o_axi_bvalid;
            // assign o_axi_bready   = axi_bready_mid;
            // assign axi_wready_mid = o_axi_wready;
            // assign o_axi_wvalid   = axi_wvalid_mid;
            //r: 响应通道的mid信号冗余了，本来是判断空满用的，实际在selet_r就完成了，于是注释了�?
        end
        else begin : no_allow_0rsp
            assign fifo_w_bypass  = 1'b0;
            assign axi_w_selet_r  = fifo_w_unempty ? fifo_w_data_o : {ARBT_NUM{1'b0}};
            // assign axi_bvalid_mid = o_axi_bvalid    & fifo_w_unempty;
            // assign o_axi_bready   = axi_bready_mid  & fifo_w_unempty;
            // assign axi_wready_mid = o_axi_wready    & fifo_w_unempty;
            // assign o_axi_wvalid   = axi_wvalid_mid  & fifo_w_unempty;
        end

        fifo_simple #(
            .CUT_READY    (TRUE_CUT_READY),
            .ZEROOUT_WHENEMPTY  (0),
            .DP           (FIFO_DP),
            .DW           (ARBT_NUM)
        )fifo_w_inst(
            .clk          (clk),
            .rst          (rst),

            .w_req        (aw_handshake & ~fifo_w_bypass),
            .unfull       (fifo_w_unfull),
            .data_i       (fifo_w_data_i),
            .r_req        (b_handshake & ~fifo_w_bypass),
            .unempty      (fifo_w_unempty),
            .data_o       (fifo_w_data_o)
        );

        // assign axi_bready_mid = |(i_axi_bready & axi_w_selet_r);
        assign o_axi_bready = |(i_axi_bready & axi_w_selet_r);
        for(i = 0; i < ARBT_NUM; i = i+1) begin: rsp_b
            // assign i_axi_bvalid[i] = axi_bvalid_mid & axi_w_selet_r[i];
            assign i_axi_bvalid[i] = o_axi_bvalid & axi_w_selet_r[i];
            assign i_axi_bresp  [i]  = o_axi_bresp  & {2{axi_w_selet_r[i]}};
        end
        
        // assign axi_wvalid_mid = | (i_axi_wvalid & axi_w_selet_r);
        assign o_axi_wvalid = | (i_axi_wvalid & axi_w_selet_r);
        assign o_axi_wlast =  | (i_axi_wlast & axi_w_selet_r);
        for(i = 0; i < ARBT_NUM; i = i+1) begin: rsp_w
            // assign i_axi_wready [i]  = axi_wready_mid & axi_w_selet_r[i];
            assign i_axi_wready [i]  = o_axi_wready & axi_w_selet_r[i];
        end
        
        reg [DW/8-1:0] sel_axi_wstrb;
        reg [DW-1:0] sel_axi_wdata;
        always@(*) begin : w_rsp_connect
            integer j;
            sel_axi_wstrb   = {(DW/8){1'b0}};
            sel_axi_wdata   = {DW{1'b0}};
            for(j = 0; j < ARBT_NUM; j = j+1) begin//{
              sel_axi_wdata  =  sel_axi_wdata   | (i_axi_wdata[j] & {DW{axi_w_selet_r[j]}});
              sel_axi_wstrb  =  sel_axi_wstrb   | (i_axi_wstrb[j] & {(DW/8){axi_w_selet_r[j]}});
            end
        end
        assign o_axi_wstrb = sel_axi_wstrb;
        assign o_axi_wdata = sel_axi_wdata;
        //r: w_channel_arbt(end)


        //r: r_channel_arbt(st)

        wire fifo_r_unfull;
        wire fifo_r_unempty;
        wire fifo_r_bypass;

        wire axi_arvalid_mid;
        wire axi_arready_mid;
        wire axi_rvalid_mid;
        wire axi_rready_mid;

        wire [ARBT_NUM-1:0] axi_r_pre_selet;
        wire [ARBT_NUM-1:0] axi_r_selet;
        wire [ARBT_NUM-1:0] axi_r_selet_r;

        for(i=0; i<ARBT_NUM; i=i+1) begin : sel_axi_r
            if(i==0) begin
                assign axi_r_pre_selet[i] = 1;
            end
            else begin
                assign axi_r_pre_selet[i] = ~(|i_axi_arvalid[i-1:0]);
            end
            assign axi_r_selet[i] = axi_r_pre_selet[i] & i_axi_arvalid[i];
        end

        assign axi_arvalid_mid = | axi_r_selet;
        for(i = 0; i < ARBT_NUM; i = i+1) begin: sel_axi_arready
            assign i_axi_arready[i] = axi_arready_mid & axi_r_selet[i];
        end
        assign o_axi_arvalid = axi_arvalid_mid & fifo_r_unfull;
        assign axi_arready_mid = o_axi_arready & fifo_r_unfull;
        

        reg     [AW-1:0]           sel_axi_araddr;
        reg     [4-1:0]            sel_axi_arcache;
        reg     [3-1:0]            sel_axi_arprot;
        reg     [LOCKW-1:0]        sel_axi_arlock;
        reg     [2-1:0]            sel_axi_arburst;
        reg     [AXILENW-1:0]      sel_axi_arlen;
        reg     [3-1:0]            sel_axi_arsize;

        always@(*)begin : sel_axi_ar
            integer j;
            sel_axi_araddr  = {AW {1'b0}};
            sel_axi_arcache = {4  {1'b0}};
            sel_axi_arprot  = {3  {1'b0}};
            sel_axi_arlock  = {LOCKW  {1'b0}};
            sel_axi_arburst = {2  {1'b0}};
            sel_axi_arlen   = {AXILENW  {1'b0}};
            sel_axi_arsize  = {3  {1'b0}};
            for(j = 0; j < ARBT_NUM; j = j+1) begin//{
                sel_axi_araddr  = sel_axi_araddr  | ({AW       {axi_r_selet[j]}} & i_axi_araddr  [j]);
                sel_axi_arcache = sel_axi_arcache | ({4        {axi_r_selet[j]}} & i_axi_arcache [j]);
                sel_axi_arprot  = sel_axi_arprot  | ({3        {axi_r_selet[j]}} & i_axi_arprot  [j]);
                sel_axi_arlock  = sel_axi_arlock  | ({LOCKW    {axi_r_selet[j]}} & i_axi_arlock  [j]);
                sel_axi_arburst = sel_axi_arburst | ({2        {axi_r_selet[j]}} & i_axi_arburst [j]);
                sel_axi_arlen   = sel_axi_arlen   | ({AXILENW  {axi_r_selet[j]}} & i_axi_arlen   [j]);
                sel_axi_arsize  = sel_axi_arsize  | ({3        {axi_r_selet[j]}} & i_axi_arsize  [j]);
            end//}
        end

        assign o_axi_araddr  = sel_axi_araddr  ;
        assign o_axi_arcache = sel_axi_arcache ;
        assign o_axi_arprot  = sel_axi_arprot  ;
        assign o_axi_arlock  = sel_axi_arlock  ;
        assign o_axi_arburst = sel_axi_arburst ;
        assign o_axi_arlen   = sel_axi_arlen   ;
        assign o_axi_arsize  = sel_axi_arsize  ;

        wire ar_handshake = o_axi_arvalid & o_axi_arready;
        wire r_handshake  = o_axi_rvalid  & o_axi_rready & o_axi_rlast;

        wire [ARBT_NUM-1 : 0] fifo_r_data_i = axi_r_selet;
        wire [ARBT_NUM-1 : 0] fifo_r_data_o;

        if(ALLOW_0CYCL_RSP != 0) begin : allow_0rsp_r
            assign fifo_r_bypass  = ~fifo_r_unempty & ar_handshake & r_handshake;
            assign axi_r_selet_r  = fifo_r_unempty ? fifo_r_data_o : axi_r_selet;
            // assign axi_rvalid_mid = o_axi_rvalid;
            // assign o_axi_rready   = axi_rready_mid;
            //r: 响应通道的mid信号冗余了，本来是判断空满用的，实际在selet_r就完成了，于是注释了�?
        end
        else begin : no_allow_0rsp_r
            assign fifo_r_bypass  = 1'b0;
            assign axi_r_selet_r  = fifo_r_unempty ? fifo_r_data_o : {ARBT_NUM{1'b0}};
            // assign axi_rvalid_mid = o_axi_rvalid    & fifo_r_unempty;
            // assign o_axi_rready   = axi_rready_mid  & fifo_r_unempty;
        end

        fifo_simple #(
            .CUT_READY    (TRUE_CUT_READY),
            .ZEROOUT_WHENEMPTY  (0),
            .DP           (FIFO_DP),
            .DW           (ARBT_NUM)
        )fifo_r_inst(
            .clk          (clk),
            .rst          (rst),

            .w_req        (ar_handshake & ~fifo_r_bypass),
            .unfull       (fifo_r_unfull),
            .data_i       (fifo_r_data_i),
            .r_req        (r_handshake & ~fifo_r_bypass),
            .unempty      (fifo_r_unempty),
            .data_o       (fifo_r_data_o)
        );

        // assign axi_rready_mid = |(i_axi_rready & axi_r_selet_r);   
        assign o_axi_rready = | (i_axi_rready & axi_r_selet_r);
        for(i = 0; i < ARBT_NUM; i = i+1) begin: selet_rsp
            // assign i_axi_rvalid[i] = axi_rvalid_mid & axi_r_selet_r[i];
            assign i_axi_rvalid[i] = o_axi_rvalid & axi_r_selet_r[i];
            assign i_axi_rlast[i]  = o_axi_rlast  & axi_r_selet_r[i];
        end
        
        // //r: mask rdata and rresp for no used channel.
        // for(i = 0; i < ARBT_NUM; i = i+1) begin: selet_rsp
        //     assign i_axi_rdata  [i]  = o_axi_rdata  & {DW{axi_r_selet_r[i]}};
        //     assign i_axi_rresp  [i]  = o_axi_rresp  & {2{axi_r_selet_r[i]}};
        // end
        // //r: not mask rdata and rresp for no used channel.
        for(i = 0; i < ARBT_NUM; i = i+1) begin: selet_rsp_r
            assign i_axi_rdata  [i]  = o_axi_rdata;
            assign i_axi_rresp  [i]  = o_axi_rresp;
        end


        //r: r_channel_arbt(end)
    end
endgenerate

endmodule
