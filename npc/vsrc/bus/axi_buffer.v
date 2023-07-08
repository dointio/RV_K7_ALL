
module axi_buffer
  #(
    parameter CHNL_FIFO_DP = 2,
    parameter CHNL_FIFO_CUT_READY = 2,
    parameter AW = 32,
    parameter DW = 32,
    parameter LOCKW = 2,
    parameter AXILENW = 4
  )
  (
  input  i_axi_arvalid,
  output i_axi_arready,
  input  [AW-1:0] i_axi_araddr,
  input  [3:0] i_axi_arcache,
  input  [2:0] i_axi_arprot,
  input  [LOCKW-1:0] i_axi_arlock,
  input  [1:0] i_axi_arburst,
  input  [AXILENW-1:0] i_axi_arlen,
  input  [2:0] i_axi_arsize,

  input  i_axi_awvalid,
  output i_axi_awready,
  input  [AW-1:0] i_axi_awaddr,
  input  [3:0] i_axi_awcache,
  input  [2:0] i_axi_awprot,
  input  [LOCKW-1:0] i_axi_awlock,
  input  [1:0] i_axi_awburst,
  input  [AXILENW-1:0] i_axi_awlen,
  input  [2:0] i_axi_awsize,

  output i_axi_rvalid,
  input  i_axi_rready,
  output [DW-1:0] i_axi_rdata,
  output [1:0] i_axi_rresp,
  output i_axi_rlast,

  input  i_axi_wvalid,
  output i_axi_wready,
  input  [DW-1:0] i_axi_wdata,
  input  [(DW/8)-1:0] i_axi_wstrb,
  input  i_axi_wlast,

  output i_axi_bvalid,
  input  i_axi_bready,
  output [1:0] i_axi_bresp,

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


localparam AR_CHNL_W = 4+3+LOCKW+AXILENW+3+2+AW;
localparam AW_CHNL_W = AR_CHNL_W;

wire [AR_CHNL_W -1:0] i_axi_ar_chnl = 
    {
    i_axi_araddr,
    i_axi_arcache,
    i_axi_arprot ,
    i_axi_arlock ,
    i_axi_arburst,
    i_axi_arlen  ,
    i_axi_arsize  
    };

wire [AR_CHNL_W -1:0] o_axi_ar_chnl;
assign   {
    o_axi_araddr,
    o_axi_arcache,
    o_axi_arprot ,
    o_axi_arlock ,
    o_axi_arburst,
    o_axi_arlen  ,
    o_axi_arsize   
    } = o_axi_ar_chnl;

fifo_simple #(
    .CUT_READY (CHNL_FIFO_CUT_READY),
    .ZEROOUT_WHENEMPTY      (0),
    .DP (CHNL_FIFO_DP),
    .DW  (AR_CHNL_W)
) o_axi_ar_fifo (
  .unfull    (i_axi_arready),
  .w_req    (i_axi_arvalid),
  .data_i    (i_axi_ar_chnl),

  .r_req    (o_axi_arready),
  .unempty    (o_axi_arvalid),
  .data_o    (o_axi_ar_chnl),

  .clk      (clk  ),
  .rst    (rst)
  );


wire [AW_CHNL_W-1:0] i_axi_aw_chnl = 
    {
    i_axi_awaddr,
    i_axi_awcache,
    i_axi_awprot ,
    i_axi_awlock ,
    i_axi_awburst,
    i_axi_awlen  ,
    i_axi_awsize  
    };

wire [AW_CHNL_W-1:0] o_axi_aw_chnl;
assign   {
    o_axi_awaddr,
    o_axi_awcache,
    o_axi_awprot ,
    o_axi_awlock ,
    o_axi_awburst,
    o_axi_awlen  ,
    o_axi_awsize  
    } = o_axi_aw_chnl;

fifo_simple #(
    .CUT_READY (CHNL_FIFO_CUT_READY),
    .ZEROOUT_WHENEMPTY      (0),
    .DP (CHNL_FIFO_DP),
    .DW  (AW_CHNL_W)
) o_axi_aw_fifo (
  .unfull    (i_axi_awready),
  .w_req    (i_axi_awvalid),
  .data_i    (i_axi_aw_chnl ),

  .r_req    (o_axi_awready ),
  .unempty    (o_axi_awvalid ),
  .data_o    (o_axi_aw_chnl),

  .clk      (clk  ),
  .rst    (rst)
  );


localparam W_CHNL_W = DW+(DW/8)+1;
wire [W_CHNL_W-1:0] i_axi_w_chnl = {
                                                i_axi_wdata,
                                                i_axi_wstrb,
                                                i_axi_wlast
                                                 };
wire [W_CHNL_W-1:0] o_axi_w_chnl;
assign { 
         o_axi_wdata,
         o_axi_wstrb,
         o_axi_wlast} = o_axi_w_chnl;

fifo_simple #(
    .CUT_READY (CHNL_FIFO_CUT_READY),
    .ZEROOUT_WHENEMPTY      (0),
    .DP (CHNL_FIFO_DP),
    .DW  (W_CHNL_W)
) o_axi_wdata_fifo(
  .unfull   (i_axi_wready),
  .w_req    (i_axi_wvalid),
  .data_i   (i_axi_w_chnl ),

  .r_req    (o_axi_wready),
  .unempty  (o_axi_wvalid),
  .data_o   (o_axi_w_chnl),

  .clk      (clk  ),
  .rst      (rst)
);
//


localparam R_CHNL_W = DW+2+1;
wire [R_CHNL_W-1:0] o_axi_r_chnl = {
                                                o_axi_rdata,
                                                o_axi_rresp,
                                                o_axi_rlast 
                                                 };
wire [R_CHNL_W-1:0] i_axi_r_chnl;
assign {
        i_axi_rdata,
        i_axi_rresp,
        i_axi_rlast} = i_axi_r_chnl;

fifo_simple # (
    .CUT_READY (CHNL_FIFO_CUT_READY),
    .ZEROOUT_WHENEMPTY      (0),
    .DP (CHNL_FIFO_DP),
    .DW  (R_CHNL_W)
) o_axi_rdata_fifo(
  .unfull    (o_axi_rready),
  .w_req    (o_axi_rvalid),
  .data_i    (o_axi_r_chnl ),


  .r_req    (i_axi_rready),
  .unempty    (i_axi_rvalid),
  .data_o    (i_axi_r_chnl),

  .clk      (clk  ),
  .rst    (rst)
);
//


localparam B_CHNL_W = 2;

wire [B_CHNL_W -1:0] o_axi_b_chnl = {
           o_axi_bresp
           };

wire [B_CHNL_W -1:0] i_axi_b_chnl;
assign {
           i_axi_bresp
           } = i_axi_b_chnl;

// wire ;
// wire bready_w;
fifo_simple #(
    .CUT_READY (CHNL_FIFO_CUT_READY),
    .ZEROOUT_WHENEMPTY      (0),
    .DP (CHNL_FIFO_DP),
    .DW  (B_CHNL_W)
) o_axi_bresp_fifo (
  .unfull    (o_axi_bready     ),
  .w_req    (o_axi_bvalid     ),
  .data_i    (o_axi_b_chnl),

  .r_req      (i_axi_bready),
  .unempty    (i_axi_bvalid),
  .data_o     (i_axi_b_chnl),

  .clk       (clk  ),
  .rst     (rst)
);



endmodule 

