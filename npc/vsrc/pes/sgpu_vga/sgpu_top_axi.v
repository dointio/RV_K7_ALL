`include "mydefines.v"
module sgpu_top_axi
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

    // o_axi_awvalid,
    // o_axi_awready,
    // o_axi_awaddr,
    // o_axi_awcache,
    // o_axi_awprot,
    // o_axi_awlock,
    // o_axi_awburst,
    // o_axi_awlen,
    // o_axi_awsize,

    // o_axi_wvalid,
    // o_axi_wready,
    // o_axi_wdata,
    // o_axi_wstrb,
    // o_axi_wlast,

    // o_axi_bvalid,
    // o_axi_bready,
    // o_axi_bresp,

    o_axi_arvalid,
    o_axi_arready,
    o_axi_araddr,
    o_axi_arcache,
    o_axi_arprot,
    o_axi_arlock,
    o_axi_arburst,
    o_axi_arlen,
    o_axi_arsize,

    o_axi_rvalid,
    o_axi_rready,
    o_axi_rdata,
    o_axi_rresp,
    o_axi_rlast,

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


// output o_axi_awvalid;
// input  o_axi_awready;
// output [32-1:0] o_axi_awaddr;
// output [3:0] o_axi_awcache;
// output [2:0] o_axi_awprot;
// output [1-1:0] o_axi_awlock;
// output [1:0] o_axi_awburst;
// output [8-1:0] o_axi_awlen;
// output [2:0] o_axi_awsize;

// output o_axi_wvalid;
// input  o_axi_wready;
// output [64-1:0] o_axi_wdata;
// output [(64/8)-1:0] o_axi_wstrb;
// output o_axi_wlast;

// input  o_axi_bvalid;
// output o_axi_bready;
// input  [1:0] o_axi_bresp;

output o_axi_arvalid;
input  o_axi_arready;
output [32-1:0] o_axi_araddr;
output [3:0] o_axi_arcache;
output [2:0] o_axi_arprot;
output [1-1:0] o_axi_arlock;
output [1:0] o_axi_arburst;
output [8-1:0] o_axi_arlen;
output [2:0] o_axi_arsize;

input  o_axi_rvalid;
output o_axi_rready;
input  [64-1:0] o_axi_rdata;
input  [1:0] o_axi_rresp;
input  o_axi_rlast;


output      vga_vsync;
output      vga_hsync;
output      vga_en;
output      [23:0]      vga_data;

output r_fifo_error;


wire openchal_w;
wire r_req_w;
wire empty_w;
wire [31:0] data_o_w;

wire [31:0] o_axi_araddr_w;
wire [31:0] addr_offset;
assign o_axi_araddr = o_axi_araddr_w +  addr_offset;
sgpu_axi_chal chal_inst
(
    .clk_w      (clk),
    .clk_r      (clk_pix),
    .rst        (rst),

    .openChal   (openchal_w),
    .r_req      (r_req_w),
    .empty      (empty_w),
    .data_o     (data_o_w),

    .o_axi_arvalid(o_axi_arvalid),
    .o_axi_arready(o_axi_arready),
    .o_axi_araddr(o_axi_araddr_w),
    .o_axi_arcache(o_axi_arcache),
    .o_axi_arprot(o_axi_arprot),
    .o_axi_arlock(o_axi_arlock),
    .o_axi_arburst(o_axi_arburst),
    .o_axi_arlen(o_axi_arlen),
    .o_axi_arsize(o_axi_arsize),

    .o_axi_rvalid(o_axi_rvalid),
    .o_axi_rready(o_axi_rready),
    .o_axi_rdata(o_axi_rdata),
    .o_axi_rresp(o_axi_rresp),
    .o_axi_rlast(o_axi_rlast)
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
