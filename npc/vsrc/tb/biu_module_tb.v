`include "mydefines.v"
module biu_module_tb
(

);
`ifdef VERILATOR_TB_DUMPFILE
    initial begin
        $dumpfile ("sv_dump_mdtb.vcd");
        $dumpvars (8, soc_inst);
    end
`endif

reg clk, rst;

wire icb_cmd_vld;
wire icb_cmd_rdy;
wire [`MYRISCV_ADDRBUS] icb_cmd_addr;
wire icb_cmd_read;
wire [`MYRISCV_DATABUS] icb_cmd_wdata;
wire [`MYRISCV_DATADW/8-1 : 0] icb_cmd_wmask;

wire [`MYRISCV_DATABUS] icb_rsp_rdata;
wire icb_rsp_err;
wire icb_rsp_vld;
wire icb_rsp_rdy;

initial begin
    clk = 0;
    forever begin
        #10 clk = ~clk;
    end
end

initial begin
    rst= 0;
    #45;
    rst= 1;
end

`ifdef Stop_Time
    localparam integer stopTime = `Stop_Time;
    initial begin
        if(stopTime != 0) begin
            # stopTime;
            $display("Time out");
            $finish;
        end
    end
`endif

biu_master #(
    .clk_cycle  (10)
) biu_m_inst
(
    .clk            (clk),
    .rst            (rst),

    .icb_cmd_vld    (icb_cmd_vld),
    .icb_cmd_rdy    (icb_cmd_rdy),
    .icb_cmd_addr   (icb_cmd_addr),
    .icb_cmd_read   (icb_cmd_read),
    .icb_cmd_wdata  (icb_cmd_wdata),
    .icb_cmd_wmask  (icb_cmd_wmask),

    .icb_rsp_rdata  (icb_rsp_rdata),
    .icb_rsp_err    (icb_rsp_err),
    .icb_rsp_vld    (icb_rsp_vld),
    .icb_rsp_rdy    (icb_rsp_rdy)
);

//o: (start) no slave, for master test
    assign icb_cmd_rdy = 1'b1;
//o: (end)

wire vga_vsync;
wire vga_hsync;
wire vga_en;
wire [23:0] vga_data;

gpu_simple gpu_inst
(
    .clk            (clk),
    .rst            (rst),

    .icb_cmd_vld    (icb_cmd_vld),
    .icb_cmd_rdy    (icb_cmd_rdy),
    .icb_cmd_addr   (icb_cmd_addr),
    .icb_cmd_read   (icb_cmd_read),
    .icb_cmd_wdata  (icb_cmd_wdata),
    .icb_cmd_wmask  (icb_cmd_wmask),

    .icb_rsp_rdata  (icb_rsp_rdata),
    .icb_rsp_err    (icb_rsp_err),
    .icb_rsp_vld    (icb_rsp_vld),
    .icb_rsp_rdy    (icb_rsp_rdy),

    .vga_clk        (clk),
    .vga_vsync      (vga_vsync),
    .vga_hsync      (vga_hsync),
    .vga_en         (vga_en),
    .vga_data       (vga_data)
);


vgaVirScreen screen_inst
(
    //   .link_i   , //0
  .rst      (rst),
  .clk      (clk),
  .vs_i     (vga_vsync),
  .hs_i     (vga_hsync),
  .de_i     (vga_en),

  .data_r_i (vga_data[23:16]),
  .data_g_i (vga_data[15:8]),
  .data_b_i (vga_data[7:0])
);


endmodule
