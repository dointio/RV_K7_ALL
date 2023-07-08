`include "mydefines.v"
module uart_sim
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

assign icb_rsp_vld = icb_cmd_vld;
assign icb_cmd_rdy = icb_rsp_rdy;


wire [`MYRISCV_DATABUS] wmask;
genvar i;
generate
    for(i=0; i<(`MYRISCV_DATADW/8); i=i+1) begin:gen_wmask
        assign wmask[(i+1)*8-1 : i*8] = {8{icb_cmd_wmask[i]}};
    end
endgenerate
wire [`MYRISCV_DATABUS] wdata_mask = icb_cmd_wdata & wmask;


`ifdef MYRISCV_ARCH_64
    // wire w_low = (wmask[3:0] != 0);
    wire w_low = (icb_cmd_wmask[3:0] != 0);
`endif

`ifdef MYRISCV_ARCH_64
    wire rxreg_sel      = (icb_cmd_addr[11 : 0] == 12'h3f8) & w_low;
    wire txreg_sel      = (icb_cmd_addr[11 : 0] == 12'h3f8) & ~w_low;
    wire intreg_sel     = (icb_cmd_addr[11 : 0] == 12'h400) & w_low;
    wire ctrlreg_sel    = (icb_cmd_addr[11 : 0] == 12'h400) & ~w_low;
`else
    wire rxreg_sel      = (icb_cmd_addr[11 : 0] == 12'h3f8);
    wire txreg_sel      = (icb_cmd_addr[11 : 0] == 12'h3fc);
    wire intreg_sel     = (icb_cmd_addr[11 : 0] == 12'h400);
    wire ctrlreg_sel    = (icb_cmd_addr[11 : 0] == 12'h404);
`endif

wire [7:0] char_w = wdata_mask[39:32];

always@(posedge clk) begin
    if(~rst_n) begin
    end
    else if(icb_cmd_vld & icb_cmd_rdy
        & ~icb_cmd_read & txreg_sel) begin
        $write("%c", char_w);
    end
end

endmodule
