`include "mydefines.v"
module timer_c (
    clk,
    rst,

    icb_cmd_vld,
    icb_cmd_rdy,
    icb_cmd_addr,
    icb_cmd_read,
    icb_cmd_wdata,
    icb_cmd_wmask,

    icb_rsp_rdata,
    icb_rsp_err,
    icb_rsp_vld,
    icb_rsp_rdy
);

input   clk, rst;

input   icb_cmd_vld;
output  icb_cmd_rdy;
input   [`MYRISCV_ADDRBUS]          icb_cmd_addr;
input   icb_cmd_read;
input   [`MYRISCV_DATABUS]          icb_cmd_wdata;
input   [`MYRISCV_DATADW/8-1:0]     icb_cmd_wmask;

output reg  icb_rsp_vld;
input       icb_rsp_rdy;
output reg  [`MYRISCV_DATABUS]          icb_rsp_rdata;
output      icb_rsp_err;

wire cmd_handshake = icb_cmd_rdy & icb_cmd_vld;
wire rsp_handshake = icb_rsp_vld & icb_rsp_rdy;

assign icb_cmd_rdy = ~icb_rsp_vld | icb_rsp_rdy;

always@(posedge clk) begin
    if(rst == `RSTLEVEL) begin
        icb_rsp_vld <= 1'b0;
    end
    else if(icb_cmd_rdy) begin
        icb_rsp_vld <= icb_cmd_vld;
    end
end

// reg [31:0] cnt_l;
// reg [31:0] cnt_h;

wire cnt_l_sel = (icb_cmd_addr[3:0] == 4'b0000);
// wire cnt_h_sel = (icb_cmd_addr[3:0] == 4'b0100);

`ifdef USE_DPIC
    import "DPI-C" function bit[31:0] getTimerCnt(input bit lowCnt);
    always@(posedge clk) begin
        if(rst == `RSTLEVEL) begin
            icb_rsp_rdata <= 0;
        end
        else if(cmd_handshake) begin
            icb_rsp_rdata <= {{(`MYRISCV_DATADW-32){1'b0}} , getTimerCnt(cnt_l_sel)};
        end
    end
`else
    initial begin
        $display("Error! Use timer_c module, but not OPEN USE_DPIC");
        $finish;
    end
    always@(*) begin
        icb_rsp_rdata = 0;
    end
`endif
    
endmodule
