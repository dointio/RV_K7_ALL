`include "mydefines.v"

module gpu_simple #(
    parameter integer SCR_W = `SCREEN_W,
    parameter integer SCR_H = `SCREEN_H,
    parameter integer V_Back_Porch    = 4,
    parameter integer V_Front_Porch   = 4,
    parameter integer H_Back_Porch    = 4,
    parameter integer H_Front_Porch   = 4
    
)
(
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
    icb_rsp_rdy,

    vga_clk,
    vga_vsync,
    vga_hsync,
    vga_en,
    vga_data
);

localparam integer VS_LEN = SCR_H + V_Back_Porch + V_Front_Porch;
localparam integer HS_LEN = SCR_W + H_Back_Porch + H_Front_Porch;

input   clk, rst;

input   icb_cmd_vld;
output  icb_cmd_rdy;
input   [`MYRISCV_ADDRBUS]          icb_cmd_addr;
input   icb_cmd_read;
input   [`MYRISCV_DATABUS]          icb_cmd_wdata;
input   [`MYRISCV_DATADW/8-1:0]     icb_cmd_wmask;

output reg  icb_rsp_vld;
input       icb_rsp_rdy;
output      [`MYRISCV_DATABUS]          icb_rsp_rdata;
output      icb_rsp_err;

input       vga_clk;
output      vga_vsync;
output      vga_hsync;
output      vga_en;
output      [23:0]      vga_data;

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


wire    [31:0]  gpu_config;
reg     [31:0]  gpu_sync;
wire    [31:0]  gpu_state; //r: not zero when out busy!!
reg     [31:0]  reg_rgb [SCR_W*SCR_H-1 : 0];

wire gpu_config_sel = (icb_cmd_addr[31 : 0] == 32'ha0000100);
wire gpu_sync_sel   = (icb_cmd_addr[31 : 0] == 32'ha0000104);
wire gpu_state_sel  = (icb_cmd_addr[31 : 0] == 32'ha0000108);
wire reg_rgb_sel    = (icb_cmd_addr[31 : 24] == 8'ha1);

`include "myfuncs.v"
localparam reg_rgb_busWd = myclog2(SCR_W*SCR_H);

assign gpu_config = ((SCR_W & 32'h0000ffff)<<16) | (SCR_H & 32'h0000ffff);

wire vga_busy;
assign gpu_state = {31'd0, vga_busy};

wire [`MYRISCV_DATABUS] wmask;
genvar i;
generate
    for(i=0; i<(`MYRISCV_DATADW/8); i=i+1) begin:gen_wmask
        assign wmask[(i+1)*8-1 : i*8] = {8{icb_cmd_wmask[i]}};
    end
endgenerate

`ifdef MYRISCV_ARCH_64
    // wire w_low = (wmask[3:0] != 0);
    wire w_low = (icb_cmd_wmask[3:0] != 0);
`endif

wire vga_busy_r;
reg_rs #(1, 0) reg_vga_busy_r (clk, rst, vga_busy, vga_busy_r);
wire vga_busy_fall = vga_busy_r & (~vga_busy);

//o: wr sync_reg
wire [`MYRISCV_DATABUS] wdata_mask = icb_cmd_wdata & wmask;
always@(posedge clk) begin
    if(rst == `RSTLEVEL) begin
        gpu_sync <= 0;
    end
    else if(icb_cmd_rdy & icb_cmd_vld & ~icb_cmd_read & gpu_sync_sel & ~gpu_sync[0])begin
`ifdef MYRISCV_ARCH_64
        gpu_sync <= w_low ? 
                        wdata_mask[31:0] :
                        wdata_mask[63:32];
//                    {icb_cmd_wdata & wmask}[31:0] : 
//                    {icb_cmd_wdata & wmask}[63:32];
`else
        gpu_sync <= icb_cmd_wdata & wmask;
`endif
    end
    else if(vga_busy_fall) begin
        gpu_sync <= 0;
    end
end

//o: wr reg_rgb
always@(posedge clk) begin
    if(icb_cmd_rdy & icb_cmd_vld & ~icb_cmd_read & reg_rgb_sel)begin
`ifdef MYRISCV_ARCH_64
        reg_rgb[icb_cmd_addr[reg_rgb_busWd+2-1 : 2]] <= 
                    w_low ? 
                    wdata_mask[31:0] : 
                    wdata_mask[63:32];
//                    {8'd0, {icb_cmd_wdata & wmask}[23:0]} : 
//                    {8'd0, {icb_cmd_wdata & wmask}[32+23:32]};
        // $display("WR_SGPU!! %x", w_low ? 
        //             {icb_cmd_wdata & wmask}[23:0] : 
        //             {icb_cmd_wdata & wmask}[32+23:32]);
`else
        reg_rgb[icb_cmd_addr[reg_rgb_busWd+2-1 : 2]] <= {8'd0, {icb_cmd_wdata & wmask}[23:0]};
`endif
    end
end

`ifdef OPEN_VIRSCREEN_GPU
`ifdef USE_DPIC
    import "DPI-C" function void screen_gpu_init(input integer width, input integer height, input reg [31:0] data []);
    initial begin
        screen_gpu_init(SCR_W, SCR_H, reg_rgb);
    end
`else
    initial begin
       $display("Error! Use VIRSCREEN_GPU, but not open USE_DPIC!!");
       $finish;
    end
`endif
`endif

//o: rd reg_state
assign icb_rsp_err = 1'b0;
wire gpu_config_sel_r, gpu_sync_sel_r, gpu_state_sel_r, reg_rgb_sel_r;
reg_enrs #(4, 0, "gpu_sel_reg") sel_reg (clk, rst, icb_cmd_vld&icb_cmd_rdy, 
    {gpu_config_sel, gpu_sync_sel, gpu_state_sel, reg_rgb_sel}, 
    {gpu_config_sel_r, gpu_sync_sel_r, gpu_state_sel_r, reg_rgb_sel_r});

wire [31:0] rgb_addr_r;
reg_enrs #(32, 0, "rgb_addr_reg") rgb_addr_reg (clk, rst, icb_cmd_vld&icb_cmd_rdy&reg_rgb_sel, icb_cmd_addr[31:0], rgb_addr_r);

assign icb_rsp_rdata[63:32] = 32'd0;
assign icb_rsp_rdata[31:0] =  gpu_config_sel_r    ? gpu_config :          (
                        gpu_sync_sel_r      ? gpu_sync :            (
                        gpu_state_sel_r     ? {31'd0, ~vga_busy} :  (
                        /*reg_rgb_sel_r       ?*/ reg_rgb[rgb_addr_r[reg_rgb_busWd+2-1 : 2]]
                        )));


//o: ///////////////////////////////////vga clock domain!//////////////////////////////////////
reg [31:0] pix_cnt;
reg [31:0] h_cnt;
reg [31:0] p_cnt;


wire vga_sync = gpu_sync[0];
wire vga_sync_r;
reg_rs #(1, 0) reg_vga_sync_r (clk, rst, vga_sync, vga_sync_r);
wire vga_sync_rise = vga_sync & (~vga_sync_r);

wire vga_frame_end = (h_cnt == (VS_LEN-1) && p_cnt == (HS_LEN-1));

// wire vga_busy;
wire vga_busy_nxt = vga_sync_rise ? 1'b1 : 1'b0;
reg_enrs #(1, 0, "reg_busy") reg_busy (clk, rst, 
    vga_sync_rise | vga_frame_end,
    vga_busy_nxt,
    vga_busy
);



always@(posedge vga_clk) begin
    if(rst == `RSTLEVEL) begin
        h_cnt <= 0;
    end
    else if(vga_sync_rise) begin
        h_cnt <= 0;
    end
    else if(vga_frame_end) begin
        h_cnt <= h_cnt;
    end
    else if(p_cnt == (HS_LEN-1)) begin
        h_cnt <= h_cnt + 1;
    end
end

always@(posedge vga_clk) begin
    if(rst == `RSTLEVEL) begin
        p_cnt <= 0;
    end
    else if(vga_sync_rise) begin
        p_cnt <= 0;
    end
    else if(vga_frame_end) begin
        p_cnt <= p_cnt;
    end
    else if(p_cnt == (HS_LEN-1) & vga_busy) begin
        p_cnt <= 0;
    end
    else if(vga_busy) begin
        p_cnt <= p_cnt + 1;
    end
end

assign vga_vsync = (h_cnt == 1);
assign vga_hsync = (p_cnt == 1);

assign vga_en = (p_cnt >= H_Back_Porch && p_cnt < H_Back_Porch + SCR_W) & (h_cnt >= V_Back_Porch && h_cnt < V_Back_Porch + SCR_H);

always@(posedge clk) begin
    if(rst == `RSTLEVEL) begin
        pix_cnt <= 0;
    end
    else if(vga_sync_rise) begin
        pix_cnt <= 0;
    end
    else if(vga_en) begin
        pix_cnt <= pix_cnt + 1'b1;
    end
end

assign vga_data = reg_rgb[pix_cnt][23:0];

endmodule
