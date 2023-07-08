`include "mydefines.v"
module sgpu_axi_chal #(
    parameter [31:0] SCR_W = 800,
    parameter [31:0] SCR_H = 600
)
(
    input clk_w,
    input clk_r,
    input rst,

    input   openChal,
    input   r_req,
    output  empty,
    output  [31:0] data_o,

    // output o_axi_awvalid,
    // input  o_axi_awready,
    // output [32-1:0] o_axi_awaddr,
    // output [3:0] o_axi_awcache,
    // output [2:0] o_axi_awprot,
    // output [1-1:0] o_axi_awlock,
    // output [1:0] o_axi_awburst,
    // output [8-1:0] o_axi_awlen,
    // output [2:0] o_axi_awsize,

    // output o_axi_wvalid,
    // input  o_axi_wready,
    // output [64-1:0] o_axi_wdata,
    // output [(64/8)-1:0] o_axi_wstrb,
    // output o_axi_wlast,

    // input  o_axi_bvalid,
    // output o_axi_bready,
    // input  [1:0] o_axi_bresp,

    output o_axi_arvalid,
    input  o_axi_arready,
    output [32-1:0] o_axi_araddr,
    output [3:0] o_axi_arcache,
    output [2:0] o_axi_arprot,
    output [1-1:0] o_axi_arlock,
    output [1:0] o_axi_arburst,
    output [8-1:0] o_axi_arlen,
    output [2:0] o_axi_arsize,

    input  o_axi_rvalid,
    output o_axi_rready,
    input  [64-1:0] o_axi_rdata,
    input  [1:0] o_axi_rresp,
    input  o_axi_rlast
);

    wire [8:0] w_cnt; //r: 512!
    wire fifo_l_empty   = (w_cnt < 300);
    wire fifo_h_full    = (w_cnt >= 320);

    
    reg wait_rrsp;
    always@(posedge clk_w) begin
        if((rst == `RSTLEVEL) | ~openChal) begin
            wait_rrsp <= 0;
        end
        else if(wait_rrsp) begin
            if(o_axi_rvalid & o_axi_rready & o_axi_rlast) begin
                wait_rrsp <= 0;
            end
            else begin
            //r: 啥也不干，等吧。。
            end
        end
        else if(o_axi_arvalid & o_axi_arready) begin
            wait_rrsp <= 1'b1;
        end
    end

    reg need_read;
    always@(posedge clk_w) begin
        if((rst == `RSTLEVEL) | ~openChal) begin
            need_read <= 0;
        end
        else if(fifo_l_empty) begin
            need_read <= 1'b1;
        end
        else if(fifo_h_full) begin
            need_read <= 1'b0;
        end
    end

    reg [31:0] r_addr;
    always@(posedge clk_w) begin
        if((rst == `RSTLEVEL) | ~openChal) begin
            r_addr <= 0;
        end
        else if(o_axi_arvalid & o_axi_arready) begin
            r_addr <= r_addr + (64*8);
        end
    end

    reg [63:0] pix_cnt;
    always@(posedge clk_w) begin
        if((rst == `RSTLEVEL) | ~openChal) begin
            pix_cnt <= 0;
        end
        else if(o_axi_arvalid & o_axi_arready) begin
            pix_cnt <= pix_cnt + 128;
        end
    end

    wire fifo_rst_n = rst;
    wire fifo_wr_en = o_axi_rvalid & o_axi_rready;
`ifdef USE_XILINXIP
    
    fifo_sgpu_chal fifo_vga_ochal
    (
        .rst         (~fifo_rst_n),
        .wr_clk      (clk_w),
        .rd_clk      (clk_r),
        
        .wr_en           (fifo_wr_en),
        .din             (o_axi_rdata),
        .full            (),
        .wr_data_count   (w_cnt),

        .rd_en           (r_req),
        .dout            (data_o),
        .empty           (empty),

        .wr_rst_busy     (),
        .rd_rst_busy     ()
    );
`else
    fifo_async_autoDW #(
        .SIZE           (8*8*64)
    ) fifo_vga_ochal
    (
        .clk_w          (clk_w),
        .clk_r          (clk_r),
        .rst            (fifo_rst_n),

        .w_req          (fifo_wr_en),
        .data_i         (o_axi_rdata),
        .full           (),
        .w_cnt          (w_cnt),

        .r_req          (r_req),
        .data_o         (data_o),
        .empty          (empty),
        .r_cnt          ()        
    );
`endif
    // output o_axi_arvalid,
    // input  o_axi_arready,
    // output [64-1:0] o_axi_araddr,
    // output [3:0] o_axi_arcache,
    // output [2:0] o_axi_arprot,
    // output [1-1:0] o_axi_arlock,
    // output [1:0] o_axi_arburst,
    // output [8-1:0] o_axi_arlen,
    // output [2:0] o_axi_arsize,

    // input  o_axi_rvalid,
    // output o_axi_rready,
    // input  [64-1:0] o_axi_rdata,
    // input  [1:0] o_axi_rresp,
    // input  o_axi_rlast

    assign o_axi_arvalid = need_read & ~wait_rrsp & (pix_cnt < SCR_H*SCR_W);
    assign o_axi_araddr = r_addr;
    assign o_axi_arcache = 0;
    assign o_axi_arprot = 3'b000;
    assign o_axi_arlock = 1'b0;
    assign o_axi_arburst = 2'b01; //2'b01: inc
    assign o_axi_arlen   = 8'd63; //
    assign o_axi_arsize  = 3'b011; //3:8byte-64bit

    assign o_axi_rready = 1'b1;
endmodule
