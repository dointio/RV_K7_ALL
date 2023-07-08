module icb_buffer # (
  parameter OUTS_CNT_W = 1,
  parameter AW = 32,
  parameter DW = 32,
  parameter CMD_CUT_READY = 0,
  parameter RSP_CUT_READY = 0,
  parameter CMD_DP = 0,
  parameter RSP_DP = 0,
  parameter USR_W = 1
) (
  output             icb_buffer_active,

  input              i_icb_cmd_valid, 
  output             i_icb_cmd_ready, 
  input  [1-1:0]     i_icb_cmd_read, 
  input  [AW-1:0]    i_icb_cmd_addr, 
  input  [DW-1:0]    i_icb_cmd_wdata, 
  input  [DW/8-1:0]  i_icb_cmd_wmask,
  input              i_icb_cmd_lock,
  input              i_icb_cmd_excl,
  input  [1:0]       i_icb_cmd_size,
  input  [1:0]       i_icb_cmd_burst,
  input  [1:0]       i_icb_cmd_beat,
  input  [USR_W-1:0] i_icb_cmd_usr,

  output             i_icb_rsp_valid, 
  input              i_icb_rsp_ready, 
  output             i_icb_rsp_err,
  output             i_icb_rsp_excl_ok,
  output [DW-1:0]    i_icb_rsp_rdata, 
  output [USR_W-1:0] i_icb_rsp_usr,
  
  output             o_icb_cmd_valid, 
  input              o_icb_cmd_ready, 
  output [1-1:0]     o_icb_cmd_read, 
  output [AW-1:0]    o_icb_cmd_addr, 
  output [DW-1:0]    o_icb_cmd_wdata, 
  output [DW/8-1:0]  o_icb_cmd_wmask,
  output             o_icb_cmd_lock,
  output             o_icb_cmd_excl,
  output [1:0]       o_icb_cmd_size,
  output [1:0]       o_icb_cmd_burst,
  output [1:0]       o_icb_cmd_beat,
  output [USR_W-1:0] o_icb_cmd_usr,

  input              o_icb_rsp_valid, 
  output             o_icb_rsp_ready, 
  input              o_icb_rsp_err,
  input              o_icb_rsp_excl_ok,
  input  [DW-1:0]    o_icb_rsp_rdata, 
  input  [USR_W-1:0] o_icb_rsp_usr,

  input  clk,  
  input  rst
  );

  localparam CMD_PACK_W = (1+AW+DW+(DW/8)+1+1+2+2+2+USR_W);

  wire [CMD_PACK_W-1:0] cmd_fifo_i_dat = {
                                 i_icb_cmd_read, 
                                 i_icb_cmd_addr, 
                                 i_icb_cmd_wdata, 
                                 i_icb_cmd_wmask,
                                 i_icb_cmd_lock,
                                 i_icb_cmd_excl,
                                 i_icb_cmd_size,
                                 i_icb_cmd_burst,
                                 i_icb_cmd_beat,
                                 i_icb_cmd_usr};

  wire [CMD_PACK_W-1:0] cmd_fifo_o_dat;

  assign {
                                 o_icb_cmd_read, 
                                 o_icb_cmd_addr, 
                                 o_icb_cmd_wdata, 
                                 o_icb_cmd_wmask,
                                 o_icb_cmd_lock,
                                 o_icb_cmd_excl,
                                 o_icb_cmd_size,
                                 o_icb_cmd_burst,
                                 o_icb_cmd_beat,
                                 o_icb_cmd_usr} = cmd_fifo_o_dat;
  fifo_simple # (
    .CUT_READY          (CMD_CUT_READY),
    .ZEROOUT_WHENEMPTY  (0),
    .DP                 (CMD_DP),
    .DW                 (CMD_PACK_W)
  ) u_sirv_gnrl_cmd_fifo (
    .w_req(i_icb_cmd_valid),
    .unfull(i_icb_cmd_ready),
    .data_i(cmd_fifo_i_dat ),
    .unempty(o_icb_cmd_valid),
    .r_req(o_icb_cmd_ready),  
    .data_o(cmd_fifo_o_dat ),  
  
    .clk  (clk),
    .rst(rst)
  );


  localparam RSP_PACK_W = (2+DW+USR_W);
  wire [RSP_PACK_W-1:0] rsp_fifo_i_dat = {
                                 o_icb_rsp_err,
                                 o_icb_rsp_excl_ok,
                                 o_icb_rsp_rdata, 
                                 o_icb_rsp_usr};

  wire [RSP_PACK_W-1:0] rsp_fifo_o_dat;

  assign {
                                 i_icb_rsp_err,
                                 i_icb_rsp_excl_ok,
                                 i_icb_rsp_rdata, 
                                 i_icb_rsp_usr} = rsp_fifo_o_dat;
  fifo_simple # (
    .CUT_READY          (RSP_CUT_READY),
    .ZEROOUT_WHENEMPTY  (0),
    .DP                 (RSP_DP),
    .DW                 (RSP_PACK_W)
  ) fifo_rsp (
    .w_req(o_icb_rsp_valid),
    .unfull(o_icb_rsp_ready),
    .data_i(rsp_fifo_i_dat ),
    .unempty(i_icb_rsp_valid),
    .r_req(i_icb_rsp_ready),  
    .data_o(rsp_fifo_o_dat ),  
  
    .clk    (clk),
    .rst    (rst)
  );

  wire outs_cnt_inc = i_icb_cmd_valid & i_icb_cmd_ready;
  wire outs_cnt_dec = i_icb_rsp_valid & i_icb_rsp_ready;
     // If meanwhile no or have set and clear, then no changes
  wire outs_cnt_ena = outs_cnt_inc ^ outs_cnt_dec;
     // If only inc or only dec
  wire [OUTS_CNT_W-1 : 0] outs_cnt_r;
  wire [OUTS_CNT_W-1 : 0] outs_cnt_nxt = outs_cnt_inc ? (outs_cnt_r + 1'b1) : (outs_cnt_r - 1'b1);
  reg_enrs #(OUTS_CNT_W, 0, "icb_buf_cnt") outs_cnt_dfflr (clk, rst, outs_cnt_ena, outs_cnt_nxt, outs_cnt_r);

  assign icb_buffer_active = i_icb_cmd_valid | (~(outs_cnt_r == {OUTS_CNT_W{1'b0}}));

endmodule

