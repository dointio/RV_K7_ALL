`include "mydefines.v"

module clint (
    clk,
    rst,

    timer_en,

    clint_icb_cmd_valid,
    clint_icb_cmd_ready,
    clint_icb_cmd_addr,                 
    clint_icb_cmd_read,                 
    clint_icb_cmd_wdata,                
    clint_icb_cmd_wmask,               
    clint_icb_cmd_burst,                
    clint_icb_cmd_beat,                 
    clint_icb_cmd_lock,                 
    clint_icb_cmd_excl,                 
    clint_icb_cmd_size,                 
    //
    //    * Bus RSP channel
    clint_icb_rsp_valid,                   
    clint_icb_rsp_ready,                   
    clint_icb_rsp_err,                     
    clint_icb_rsp_excl_ok,                 
    clint_icb_rsp_rdata,

    soft_irq_o,
    tmr_irq_o
);

input clk, rst;

input timer_en;

input                           clint_icb_cmd_valid;
output                          clint_icb_cmd_ready;
input [`MYRISCV_ADDRDW-1:0]     clint_icb_cmd_addr; 
input                           clint_icb_cmd_read; 
input [`MYRISCV_XLEN-1:0]       clint_icb_cmd_wdata;
input [`MYRISCV_XLEN/8-1:0]     clint_icb_cmd_wmask;
input [1:0]                   clint_icb_cmd_burst;
input [1:0]                   clint_icb_cmd_beat;
input                         clint_icb_cmd_lock;
input                         clint_icb_cmd_excl;
input [1:0]                   clint_icb_cmd_size;

output                          clint_icb_rsp_valid;
input                         clint_icb_rsp_ready;
output                          clint_icb_rsp_err  ;
output                          clint_icb_rsp_excl_ok;
output  [`MYRISCV_XLEN-1:0]        clint_icb_rsp_rdata;

output soft_irq_o;
output tmr_irq_o;

wire [`MYRISCV_DATABUS] wmask_data;
wire [`MYRISCV_DATABUS] wmask_ex;
genvar i;
generate
    for(i=0; i<(`MYRISCV_DATADW/8); i=i+1) begin : g_maskData
        assign wmask_ex [(i+1)*8-1 : i*8] = {8{clint_icb_cmd_wmask[i]}};
    end
endgenerate
assign wmask_data = clint_icb_cmd_wdata & wmask_ex;


`ifdef MYRISCV_ARCH_64
    wire low_w = (clint_icb_cmd_wmask[3:0] != 0);
    wire timer_l_sel = (clint_icb_cmd_addr[23:0] == 24'h0) & (low_w);
    wire timer_h_sel = (clint_icb_cmd_addr[23:0] == 24'h0) & (~low_w);
    wire timercmp_l_sel = (clint_icb_cmd_addr[23:0] == 24'h8) & (low_w);
    wire timercmp_h_sel = (clint_icb_cmd_addr[23:0] == 24'h8) & (~low_w);
    wire softintr_sel = (clint_icb_cmd_addr[23:0] == 24'h10) & (low_w);
`else
    wire timer_l_sel = (clint_icb_cmd_addr[23:0] == 24'h0);
    wire timer_h_sel = (clint_icb_cmd_addr[23:0] == 24'h4);
    wire timercmp_l_sel = (clint_icb_cmd_addr[23:0] == 24'h8);
    wire timercmp_h_sel = (clint_icb_cmd_addr[23:0] == 24'hc);
    wire softintr_sel = (clint_icb_cmd_addr[23:0] == 24'h10);
`endif


wire timer_l_sel_r;
wire timer_h_sel_r;
wire timercmp_l_sel_r;
wire timercmp_h_sel_r;
wire softintr_sel_r;
st_pipe_stage #(
    .CUT_READY     (1),
    .DP            (1),
    .DW            (5)
)pipe_reg(
    .i_vld        (clint_icb_cmd_valid),
    .i_rdy        (clint_icb_cmd_ready),
    .data_i       ({timer_l_sel, timer_h_sel, timercmp_l_sel, timercmp_h_sel, softintr_sel}),

    .o_vld        (clint_icb_rsp_valid),
    .o_rdy        (clint_icb_rsp_ready),
    .data_o       ({timer_l_sel_r, timer_h_sel_r, timercmp_l_sel_r, timercmp_h_sel_r, softintr_sel_r}),

    .clk        (clk),
    .rst        (rst)
);

assign clint_icb_rsp_err = 1'b0;
`ifdef MYRISCV_ARCH_64
    assign clint_icb_rsp_rdata =    ({64{timer_l_sel_r}} & {32'd0, timer_l_r}) |
                                    ({64{timer_h_sel_r}} & {timer_h_r, 32'd0}) |
                                    ({64{timercmp_l_sel_r}} & {32'd0, timercmp_l_r}) | 
                                    ({64{timercmp_h_sel_r}} & {timercmp_h_r, 32'd0}) |
                                    ({64{softintr_sel_r}} & {32'd0, softintr_r});
`else
    assign clint_icb_rsp_rdata =    ({32{timer_l_sel_r}} & timer_l_r) |
                                    ({32{timer_h_sel_r}} & timer_h_r) |
                                    ({32{timercmp_l_sel_r}} & timercmp_l_r) | 
                                    ({32{timercmp_h_sel_r}} & timercmp_h_r) |
                                    ({32{softintr_sel_r}} & softintr_r);
`endif

wire [31:0] timer_l_nxt;
wire [31:0] timer_l_r;
wire timer_l_wr = (timer_l_sel & clint_icb_cmd_valid & clint_icb_cmd_ready & ~clint_icb_cmd_read);
assign timer_l_nxt =  timer_l_wr ? wmask_data[31:0] : timer_l_r + 1'b1;
reg_enrs #(32, 0, "timer_l") timer_l_reg (clk, rst, timer_en | timer_l_wr, timer_l_nxt, timer_l_r);


wire [31:0] timer_h_nxt;
wire [31:0] timer_h_r;
wire timer_h_wr = (timer_h_sel & clint_icb_cmd_valid & clint_icb_cmd_ready & ~clint_icb_cmd_read);
assign timer_h_nxt =  timer_h_wr ?
                    `ifdef MYRISCV_ARCH_64
                        wmask_data[63:32]
                    `else
                        wmask_data[31:0]
                    `endif
                        : (
                            (timer_l_r == 32'hffffffff) ? (timer_h_r + 1'b1) : timer_h_r
                        );
reg_enrs #(32, 0, "timer_h") timer_h_reg (clk, rst, timer_en | timer_h_wr, timer_h_nxt, timer_h_r);

wire [31:0] timercmp_l_nxt;
wire [31:0] timercmp_l_r;
wire timercmp_l_wr = (timercmp_l_sel & clint_icb_cmd_valid & clint_icb_cmd_ready & ~clint_icb_cmd_read);
assign timercmp_l_nxt =  wmask_data[31:0];
reg_enrs #(32, 32'hffffffff, "cmp_l_r") cmp_l_reg (clk, rst, timercmp_l_wr, timercmp_l_nxt, timercmp_l_r);

wire [31:0] timercmp_h_nxt;
wire [31:0] timercmp_h_r;
wire timercmp_h_wr = (timercmp_h_sel & clint_icb_cmd_valid & clint_icb_cmd_ready & ~clint_icb_cmd_read);
assign timercmp_h_nxt = 
                    `ifdef MYRISCV_ARCH_64
                        wmask_data[63:32]
                    `else
                        wmask_data[31:0]
                    `endif
                    ;
reg_enrs #(32, 32'hffffffff, "cmp_h_r") cmp_h_reg (clk, rst, timercmp_h_wr, timercmp_h_nxt, timercmp_h_r);

wire [31:0] softintr_nxt;
wire [31:0] softintr_r;
wire softintr_wr = (softintr_sel & clint_icb_cmd_valid & clint_icb_cmd_ready & ~clint_icb_cmd_read);
assign softintr_nxt = wmask_data[31:0];
reg_enrs #(32, 0, "softintr_r") softintr_reg (clk, rst, softintr_wr, softintr_nxt, softintr_r);

assign soft_irq_o = softintr_r[0];
assign tmr_irq_o = ({timercmp_h_r, timercmp_l_r} <= {timer_h_r, timer_l_r});




endmodule
