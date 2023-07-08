`include "mydefines.v"
module uart
(
    input clk,
    input rst_n,

    input   icb_cmd_vld,
    output  icb_cmd_rdy,
    input   icb_cmd_read,
    input [`MYRISCV_ADDRBUS]    icb_cmd_addr,
    input [`MYRISCV_DATABUS]                icb_cmd_wdata,
    input [`MYRISCV_DATADW/8-1:0]            icb_cmd_wmask,

    output  icb_rsp_vld,
    input   icb_rsp_rdy,
    output  [`MYRISCV_DATABUS] icb_rsp_rdata,
    output  icb_rsp_err,

    output interrupt_req,

    input   rx,
    output  tx
);

wire wfifofull;
wire wfifoempty;
wire [7:0] wfifodata;
wire [7:0] wfifoq;
wire wfifowrreq;
wire wfifordreq;
//wire wfifowrclk;
//wire wfifordclk;
wire [11:0] wtx_cnt;
wire [8:0] wrx_cnt;
wire [1:0] wparity;
wire wtxclk;
wire wrxclk;
wire wframeerror;
wire wparityerror;
wire [7:0] wrxdata;
wire wrxdataupdate;

//r: note: when tx fifo overflow, the new tx data will be ignore!

uart_ctrl uart_ctrl_inst(
    .clk(clk),
    .rst_n(rst_n),

    .icb_cmd_vld(icb_cmd_vld),
    .icb_cmd_rdy(icb_cmd_rdy),
    .icb_cmd_read(icb_cmd_read),
    .icb_cmd_addr(icb_cmd_addr),
    .icb_cmd_wdata(icb_cmd_wdata),
    .icb_cmd_wmask(icb_cmd_wmask),

    .icb_rsp_vld(icb_rsp_vld),
    .icb_rsp_rdy(icb_rsp_rdy),
    .icb_rsp_rdata(icb_rsp_rdata),
    .icb_rsp_err(icb_rsp_err),

    .interrupt_o(interrupt_req),

    .fifowrfull            (wfifofull),
    .fifowrreq            (wfifowrreq),
    .fifowdata            (wfifodata),
    
    .frameerror            (wframeerror),
    .parityerror        (wparityerror),
    .rxdata                (wrxdata),
    .rxdataupdate        (wrxdataupdate),
    
    .tx_cnt                (wtx_cnt),
    .rx_cnt                (wrx_cnt),
    .parity                (wparity)
);


// fifo_m f1(
//     .data            (wfifodata),
//     .rdclk        (wtxclk),
//     .rdreq        (wfifordreq),
//     .wrclk        (clk),
//     .wrreq        (wfifowrreq),
//     .q                (wfifoq),
//     .rdempty        (wfifoempty),
//     .wrfull        (wfifofull)
// );

// fifo_simple #(
//     .CUT_READY          (1),
//     .ZEROOUT_WHENEMPTY  (0),
//     .DP                 (4),
//     .DW                 (8)
// ) tx_fifo (
//     .clk            (clk),
//     .rst_n            (rst_n),
//     .w_req          (wfifowrreq),
//     .unfull         (wfifofull),
//     .data_i         (wfifodata),

//     .r_req          (wfifordreq),
//     .unempty        (wfifoempty),
//     .data_o         (wfifoq)
// );

`ifdef PLATFORM_SIM
async_fifo #(
    .DW (8),
    .DP (8)
) fifo_inst
(
    .clk_i      (clk),
    .clk_o      (wtxclk),
    .rst_n      (rst_n),

    .w_req      (wfifowrreq),
    .full       (wfifofull),
    .data_i     (wfifodata),

    .r_req      (wfifordreq),
    .empty      (wfifoempty),
    .data_o     (wfifoq)
);
`else
    uart_tx_fifo tx_fifo_inst(
        .rst    (~rst_n),
        .wr_clk (clk),
        .rd_clk (wtxclk),

        .wr_en  (wfifowrreq),
        .din    (wfifodata),
        .full   (wfifofull),

        .rd_en  (wfifordreq),
        .dout   (wfifoq),
        .empty  (wfifoempty)
    );
`endif

uart_div uart_clk1(
    .clk            (clk),
    .rst_n            (rst_n),
    .uart_tx_clk    (wtxclk),
    .uart_rx_clk    (wrxclk),
    .tx_cnt            (wtx_cnt), 
    .rx_cnt            (wrx_cnt)
);

uart_tx uart_tx1(
    .clk                    (wtxclk),
    .rst_n                (rst_n),
    .parity                (wparity),//需要持续赋值,偶0，奇1
    .fifordempty        (wfifoempty),
    .fifodata            (wfifoq),
    .fifordreq            (wfifordreq),
    .tx                    (tx)
);

uart_rx uart_rx1(
    .rx                    (rx),
    .clk                    (wrxclk),
    .rst_n                (rst_n),
    .parity                (wparity),//需要持续赋值
    .framer_error        (wframeerror),
    .parity_error        (wparityerror),
    .dataout                (wrxdata),
    .rxdataupdate        (wrxdataupdate)
);

endmodule
