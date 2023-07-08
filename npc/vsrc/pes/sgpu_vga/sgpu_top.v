`include "mydefines.v"
module sgpu_top
(
    i_icb_cmd_vld,
    i_icb_cmd_rdy,
    i_icb_cmd_read,
    i_icb_cmd_addr,
    i_icb_cmd_wdata,
    i_icb_cmd_wmask,

    i_icb_rsp_vld,
    i_icb_rsp_rdy,
    i_icb_rsp_rdata,
    i_icb_rsp_err,

    o_icb_cmd_vld,
    o_icb_cmd_rdy,
    o_icb_cmd_read,
    o_icb_cmd_addr,
    o_icb_cmd_wdata,
    o_icb_cmd_wmask,

    o_icb_rsp_vld,
    o_icb_rsp_rdy,
    o_icb_rsp_rdata,
    o_icb_rsp_err,

    vga_vsync,
    vga_hsync,
    vga_en,
    vga_data,

    r_fifo_error,

    clk_pix,
    clk,
    rst
);


input clk, rst;
input clk_pix;

input                           i_icb_cmd_vld; 
output                          i_icb_cmd_rdy; 
input  [1-1:0]                  i_icb_cmd_read; 
input  [`MYRISCV_ADDRBUS]       i_icb_cmd_addr; 
input  [`MYRISCV_DATABUS]       i_icb_cmd_wdata; 
input  [`MYRISCV_DATADW/8-1:0]  i_icb_cmd_wmask;
// input  [1:0]       i_icb_cmd_size;

output                          i_icb_rsp_vld; 
input                           i_icb_rsp_rdy; 
output                          i_icb_rsp_err;
output [`MYRISCV_DATABUS]       i_icb_rsp_rdata;


output                           o_icb_cmd_vld; 
input                            o_icb_cmd_rdy; 
output  [1-1:0]                  o_icb_cmd_read; 
output  [`MYRISCV_ADDRBUS]       o_icb_cmd_addr; 
output  [63:0]                  o_icb_cmd_wdata; 
output  [7:0]                   o_icb_cmd_wmask;
// output  [1:0]       o_icb_cmd_size;

input               o_icb_rsp_vld; 
output              o_icb_rsp_rdy; 
input               o_icb_rsp_err;
input   [63:0]     o_icb_rsp_rdata;


output      vga_vsync;
output      vga_hsync;
output      vga_en;
output      [23:0]      vga_data;

output r_fifo_error;


wire openchal_w;
wire r_req_w;
wire empty_w;
wire [31:0] data_o_w;

wire [`MYRISCV_ADDRBUS] o_icb_cmd_addr_w;
wire [31:0] addr_offset;
assign o_icb_cmd_addr = o_icb_cmd_addr_w + {{(`MYRISCV_ADDRDW-32){1'b0}}, addr_offset};
sgpu_o_chal chal_inst
(
    .clk_w      (clk),
    .clk_r      (clk_pix),
    .rst        (rst),

    .openChal   (openchal_w),
    .r_req      (r_req_w),
    .empty      (empty_w),
    .data_o     (data_o_w),

    .icb_cmd_vld(o_icb_cmd_vld),
    .icb_cmd_rdy(o_icb_cmd_rdy),
    .icb_cmd_read(o_icb_cmd_read),
    .icb_cmd_addr(o_icb_cmd_addr_w),
    .icb_cmd_wdata(o_icb_cmd_wdata),
    .icb_cmd_wmask(o_icb_cmd_wmask),

    .icb_rsp_vld(o_icb_rsp_vld),
    .icb_rsp_rdy(o_icb_rsp_rdy),
    .icb_rsp_rdata(o_icb_rsp_rdata),
    .icb_rsp_err    (o_icb_rsp_err)
);

//o: default setting for sgpu_ctrl
//     parameter [31:0] SCR_W = 800,
//     parameter [31:0] SCR_H = 600,
//     parameter [31:0] H_Sync_Time     = 40,
//     parameter [31:0] H_Back_Porch    = 166,
//     parameter [31:0] H_Front_Porch   = 50,
//     parameter [31:0] V_Sync_Time     = 4,
//     parameter [31:0] V_Back_Porch    = 19,
//     parameter [31:0] V_Front_Porch   = 5,
// `ifdef PLATFORM_SIM
//     parameter [31:0] frame_staddr = 32'hc000_0000
// `else
//     parameter [31:0] frame_staddr = 32'hf000_0000
// `endif

sgpu_control sgpu_ctrl_inst
(
    .clk        (clk),
    .rst        (rst),

    .icb_cmd_vld(i_icb_cmd_vld),
    .icb_cmd_rdy(i_icb_cmd_rdy),
    .icb_cmd_addr(i_icb_cmd_addr),
    .icb_cmd_read(i_icb_cmd_read),
    .icb_cmd_wdata(i_icb_cmd_wdata),
    .icb_cmd_wmask(i_icb_cmd_wmask),

    .icb_rsp_rdata(i_icb_rsp_rdata),
    .icb_rsp_err(i_icb_rsp_err),
    .icb_rsp_vld(i_icb_rsp_vld),
    .icb_rsp_rdy(i_icb_rsp_rdy),

    .fifo_r_req     (r_req_w),
    .fifo_empty     (empty_w),
    .fifo_r_data    (data_o_w),

    .addr_offset    (addr_offset),
    .openChal       (openchal_w),

    .vga_clk        (clk_pix),
    .vga_vsync      (vga_vsync),
    .vga_hsync      (vga_hsync),
    .vga_en         (vga_en),
    .vga_data       (vga_data),

    .r_fifo_error          (r_fifo_error)
);

endmodule
