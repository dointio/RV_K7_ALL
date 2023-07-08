`include "mydefines.v"
module ifu_monitor
(
    pc_req_vld,
    pc_req_rdy,

    pc_rsp_vld_i,
    pc_rsp_rdy_i,

    pc_rsp_vld_o,
    pc_rsp_rdy_o,

    bpu_prdt_taken,

    clk,
    rst
);
input clk, rst;

input pc_req_vld;
input pc_req_rdy;

input pc_rsp_vld_i;
output pc_rsp_rdy_i;

output pc_rsp_vld_o;
input pc_rsp_rdy_o;

input bpu_prdt_taken;

wire req_handshake = pc_req_vld & pc_req_rdy;
wire rsp_handshake = pc_rsp_vld_i & pc_rsp_rdy_i;
wire abandon_instr;
assign pc_rsp_vld_o = abandon_instr ? 1'b0 : pc_rsp_vld_i;
assign pc_rsp_rdy_i = abandon_instr ? 1'b1 : pc_rsp_rdy_o;

reg [2:0] req_cnt;
always @(clk) begin
    if(rst == `RSTLEVEL) begin
        req_cnt <= 0;
    end
    else if(req_handshake & ~rsp_handshake) begin
        req_cnt <= req_cnt + 1'b1;
    end
    else if(~req_handshake & rsp_handshake) begin
        req_cnt <= req_cnt - 1'b1;
    end
end

reg [2:0] abandon_cnt;
always@(clk) begin
    if(rst == `RSTLEVEL) begin
        abandon_cnt <= 0;
    end
    else if((abandon_cnt==0) & bpu_prdt_taken & (req_cnt>1)) begin
        abandon_cnt <= req_cnt-1;
    end
    else if(abandon_cnt != 0 & rsp_handshake) begin
        abandon_cnt <= abandon_cnt-1;
    end
end
assign abandon_instr = (abandon_cnt != 0);

endmodule
