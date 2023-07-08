`include "mydefines.v"

module sgpu_control #(
    parameter [31:0] SCR_W = 800,
    parameter [31:0] SCR_H = 600,
    parameter [31:0] H_Sync_Time     = 40,
    parameter [31:0] H_Back_Porch    = 166,
    parameter [31:0] H_Front_Porch   = 50,
    parameter [31:0] V_Sync_Time     = 4,
    parameter [31:0] V_Back_Porch    = 19,
    parameter [31:0] V_Front_Porch   = 5,
`ifdef PLATFORM_SIM
    parameter [31:0] frame_staddr = 32'hc000_0000
`else
    parameter [31:0] frame_staddr = 32'hf000_0000
`endif
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

    fifo_r_req,
    fifo_empty,
    fifo_r_data,

    addr_offset,
    openChal,

    r_fifo_error,

    vga_clk,
    vga_vsync,
    vga_hsync,
    vga_en,
    vga_data
);

localparam [31:0] V_Total = SCR_H + V_Sync_Time + V_Back_Porch + V_Front_Porch;
localparam [31:0] H_Total = SCR_W + H_Sync_Time + H_Back_Porch + H_Front_Porch;

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

output      fifo_r_req;
input       fifo_empty;
input       [31:0]      fifo_r_data;

output      [31:0]      addr_offset;
output      openChal;

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

wire [`MYRISCV_DATABUS] wdata_mask = icb_cmd_wdata & wmask;


wire    [31:0]  gpu_config;
wire    [31:0]  gpu_sync;
wire    [31:0]  gpu_state; //r: not zero when out busy!!
wire    [31:0]  gpu_addr_offset;
assign  addr_offset  = gpu_addr_offset;

`ifdef MYRISCV_ARCH_64
    wire gpu_config_sel = (icb_cmd_addr[31 : 0] == 32'ha0000100 & w_low);
    wire gpu_sync_sel   = (icb_cmd_addr[31 : 0] == 32'ha0000100 & ~w_low);
    wire gpu_state_sel  = (icb_cmd_addr[31 : 0] == 32'ha0000108 & w_low);
    wire gpu_offset_sel = (icb_cmd_addr[31 : 0] == 32'ha0000108 & ~w_low);
`else
    wire gpu_config_sel = (icb_cmd_addr[31 : 0] == 32'ha0000100);
    wire gpu_sync_sel   = (icb_cmd_addr[31 : 0] == 32'ha0000104);
    wire gpu_state_sel  = (icb_cmd_addr[31 : 0] == 32'ha0000108);
    wire gpu_offset_sel = (icb_cmd_addr[31 : 0] == 32'ha000010c);
`endif

assign gpu_config = ((SCR_W & 32'h0000ffff)<<16) | (SCR_H & 32'h0000ffff);
assign gpu_sync = 0;
wire vga_busy;
assign gpu_state = {31'd0, vga_busy};

//o: wr sync_reg
reg frame_sel;
always@(posedge clk) begin
    if(rst == `RSTLEVEL) begin
        frame_sel <= 1;
    end
    else if(icb_cmd_rdy & icb_cmd_vld & ~icb_cmd_read & gpu_sync_sel & ~vga_busy)begin
        frame_sel <= ~frame_sel;
    end
end
assign gpu_addr_offset = frame_sel ? frame_staddr : frame_staddr + (SCR_H*SCR_W*4);

//o: rd regs
assign icb_rsp_err = 1'b0;
wire gpu_config_sel_r, gpu_sync_sel_r, gpu_state_sel_r;
reg_enrs #(3, 0, "gpu_sel_reg") sel_reg (clk, rst, icb_cmd_vld&icb_cmd_rdy, 
    {gpu_config_sel, gpu_sync_sel, gpu_state_sel}, 
    {gpu_config_sel_r, gpu_sync_sel_r, gpu_state_sel_r});

`ifdef MYRISCV_ARCH_64
    assign icb_rsp_rdata =  gpu_config_sel_r    ? {32'd0, gpu_config}    :   (
                            gpu_sync_sel_r      ? {gpu_sync, 32'd0}      :   (
                            gpu_state_sel_r     ? {32'd0, gpu_state} : {gpu_addr_offset, 32'd0}                                
                            ));
`else
    assign icb_rsp_rdata =  gpu_config_sel_r    ? gpu_config    :   (
                            gpu_sync_sel_r      ? gpu_sync      :   (
                            gpu_state_sel_r     ? gpu_state : gpu_addr_offset                                
                            ));
`endif


//o: ///////////////////////////////////vga clock domain!//////////////////////////////////////
reg [31:0] v_cnt;
reg [31:0] h_cnt;

always@(posedge vga_clk) begin
    if(rst == `RSTLEVEL) begin
        v_cnt <= 0;
    end
    else if(h_cnt == (H_Total-1)) begin
        if(v_cnt == (V_Total-1))
            v_cnt <= 0;
        else 
            v_cnt <= v_cnt + 1;
    end
end

always@(posedge vga_clk) begin
    if(rst == `RSTLEVEL) begin
        h_cnt <= 0;
    end
    else if(h_cnt == (H_Total-1)) begin
        h_cnt <= 0;
    end
    else begin
        h_cnt <= h_cnt + 1;
    end
end

//r: busy start before vga_en, because of reading data to fifo!
assign vga_busy = (v_cnt >= (V_Sync_Time + V_Back_Porch-4) && v_cnt < (V_Sync_Time + V_Back_Porch + SCR_H + 1));

wire vga_vsync_w = (v_cnt < V_Sync_Time);
wire vga_hsync_w = (h_cnt < H_Sync_Time);
wire vga_en_w = ((h_cnt >= (H_Sync_Time + H_Back_Porch)) && (h_cnt < (H_Sync_Time + H_Back_Porch + SCR_W))) 
                & ((v_cnt >= (V_Sync_Time + V_Back_Porch)) && (v_cnt < (V_Sync_Time + V_Back_Porch + SCR_H)));
wire [23:0] vga_data_w = fifo_r_data[23:0];
wire fifo_r_req_w = vga_en;
wire openChal_w = vga_busy;

assign vga_vsync    = vga_vsync_w;
assign vga_hsync    = vga_hsync_w;
assign vga_en       = vga_en_w;
assign vga_data     = vga_data_w;
assign fifo_r_req   = fifo_r_req_w;
assign openChal     = openChal_w;

//r: check fifo error!(empty)
output reg r_fifo_error;
always@(posedge vga_clk) begin
    if(rst == `RSTLEVEL) begin
        r_fifo_error <= 1'b0;
    end
    else if(vga_en & fifo_empty) begin
        r_fifo_error <= 1'b1;
    end
end

endmodule
