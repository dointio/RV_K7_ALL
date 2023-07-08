module icb2apb # (
  parameter AW = 32,
  parameter FIFO_OUTS_NUM = 8,
  parameter FIFO_CUT_READY = 0,
  parameter DW = 64 // 64 or 32 bits
) (
  input              i_icb_cmd_valid, 
  output             i_icb_cmd_ready, 
  input  [1-1:0]     i_icb_cmd_read, 
  input  [AW-1:0]    i_icb_cmd_addr, 
  input  [DW-1:0]    i_icb_cmd_wdata, 
  input  [DW/8-1:0]  i_icb_cmd_wmask,
  input  [1:0]       i_icb_cmd_size,

  output             i_icb_rsp_valid, 
  input              i_icb_rsp_ready, 
  output             i_icb_rsp_err,
  output [DW-1:0]    i_icb_rsp_rdata, 
  
  output [AW-1:0]   apb_paddr,
  output            apb_pwrite,
  output            apb_pselx,
  output            apb_penable,
  output [DW-1:0]   apb_pwdata,
  output [DW/8-1:0] apb_pstrb,
  input  [DW-1:0]   apb_prdata,

  input  clk,  
  input  rst
  );

  // Since the APB reponse channel does not have handhake scheme, but the
  //   ICB have, so the response may not be accepted by the upstream master
  //   So in order to make sure the functionality is correct, we must put
  //   a reponse bypass-buffer here, to always be able to accept response from apb
  //
  wire apb_enable_r;

  fifo_simple # (
   .CUT_READY           (1),
   .ZEROOUT_WHENEMPTY   (0),
   .DP                  (1),
   .DW                  (DW)
  ) u_rsp_fifo(
    .w_req          (apb_enable_r), 
    .unfull         (), 
    .data_i         (apb_prdata),
    .unempty        (i_icb_rsp_valid), 
    .r_req          (i_icb_rsp_ready), 
    .data_o         (i_icb_rsp_rdata),
  
    .clk            (clk),
    .rst            (rst)  
   );

  assign i_icb_rsp_err = 1'b0;// Wishbone have no error response

    // apb enable will be set if it is now not set and the new icb valid is coming
          // And we only initiate the reqeust when the response buffer is empty, to make
          //   sure when the response back from APB we can alway be able to 
  wire apb_enable_set = (~apb_enable_r) & i_icb_cmd_valid & (~i_icb_rsp_valid);
    // apb enable will be clear if it is now already set
  wire apb_enable_clr = apb_enable_r; //r: apb_enable onty hold one cycle ??!!!
  wire apb_enable_ena = apb_enable_set | apb_enable_clr;
  wire apb_enable_nxt = apb_enable_set & (~apb_enable_clr);
//   sirv_gnrl_dfflr #(1) apb_enable_dfflr (apb_enable_ena, apb_enable_nxt, apb_enable_r, clk, rst);
  reg_enrs #(1, 0, "en_reg") apg_en_reg 
    (clk, rst, apb_enable_ena, apb_enable_nxt, apb_enable_r);

  //r: icb_cmd_ready high on next cycle!
  assign i_icb_cmd_ready = apb_enable_r & (~i_icb_rsp_valid); 

  assign apb_paddr   = i_icb_cmd_addr;
  assign apb_pwrite  = (~i_icb_cmd_read);
  assign apb_pselx   = i_icb_cmd_valid;
  assign apb_penable = apb_enable_r;
  assign apb_pwdata  = i_icb_cmd_wdata;
  assign apb_pstrb   = i_icb_cmd_wmask;

endmodule
