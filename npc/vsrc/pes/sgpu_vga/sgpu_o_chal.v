`include "mydefines.v"
module sgpu_o_chal #(
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

    output  icb_cmd_vld,
    input   icb_cmd_rdy,
    output  icb_cmd_read,
    output  [`MYRISCV_ADDRBUS] icb_cmd_addr,
    output  [63:0] icb_cmd_wdata,
    output  [7:0]  icb_cmd_wmask,

    input   icb_rsp_vld,
    output  icb_rsp_rdy,
    input   [63:0] icb_rsp_rdata,
    input   icb_rsp_err
);

    wire [8:0] w_cnt;
    wire fifo_l_empty   = (w_cnt < 90);
    wire fifo_h_full    = (w_cnt >= 115);

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

    reg [`MYRISCV_ADDRBUS] r_addr;
    always@(posedge clk_w) begin
        if((rst == `RSTLEVEL) | ~openChal) begin
            r_addr <= 0;
        end
        else if(icb_cmd_vld & icb_cmd_rdy) begin
            r_addr <= r_addr + 8;
        end
    end

    reg [63:0] pix_cnt;
    always@(posedge clk_w) begin
        if((rst == `RSTLEVEL) | ~openChal) begin
            pix_cnt <= 0;
        end
        else if(icb_cmd_vld & icb_cmd_rdy) begin
            pix_cnt <= pix_cnt + 1'b1;
        end
    end

    wire fifo_rst_n = rst;
    fifo_async_autoDW #(
        .SIZE           (8*8*64)
    ) fifo_vga_ochal
    (
        .clk_w          (clk_w),
        .clk_r          (clk_r),
        .rst            (fifo_rst_n),

        .w_req          (icb_rsp_vld*icb_rsp_rdy),
        .data_i         (icb_rsp_rdata),
        .full           (),
        .w_cnt          (w_cnt),

        .r_req          (r_req),
        .data_o         (data_o),
        .empty          (empty),
        .r_cnt          ()        
    );
    assign icb_rsp_rdy = 1'b1;
    assign icb_cmd_vld  = need_read & (pix_cnt < (SCR_W*SCR_H/2));
    assign icb_cmd_addr = r_addr;
    assign icb_cmd_read = 1'b1;
    assign icb_cmd_wdata = 0;
    assign icb_cmd_wmask = 8'hff;

endmodule
