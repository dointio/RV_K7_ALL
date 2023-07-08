`include "mydefines.v"

module vgaVirScreen #(
    parameter integer SCR_W = `SCREEN_W,
    parameter integer SCR_H = `SCREEN_H
)
(
    //   input       link_i   , //0
  input       rst     ,
  input       clk   ,
  input       vs_i     ,
  input       hs_i     ,
  input       de_i     ,

  input [7:0] data_r_i,
  input [7:0] data_g_i,
  input [7:0] data_b_i
);


reg [31:0] reg_rgb [SCR_W*SCR_H-1 : 0];

`ifdef USE_DPIC
    import "DPI-C" function void screen_init(input integer width, input integer height, input reg [31:0] data []);
    import "DPI-C" function void screen_sync();

    initial begin
        screen_init(SCR_W, SCR_H, reg_rgb);
    end
`else
    initial begin
        $display("Error! Use virVgaScreen, but not open USE_DPIC!");
        $finish;
    end
`endif

wire vs_r, hs_r, de_r;
reg_rs #(3, 0) reg_sig_r (clk, rst, {vs_i, hs_i, de_i}, {vs_r, hs_r, de_r});

wire vs_rise = vs_i & (~vs_r);
// wire hs_rise = hs_i & (~hs_r);
// wire de_rise = de_i & (~de_r);

// wire [31:0] w_cnt;
// wire [31:0] h_cnt;
wire [31:0] p_cnt;

// wire [31:0] w_cnt_n = w_cnt + 1;
// wire [31:0] h_cnt_n = h_cnt + 1;
wire [31:0] p_cnt_n = (p_cnt==(`SCREEN_W*`SCREEN_H-1)) ? 0 : p_cnt + 1;

reg_enrs #(32, 0, "reg_pixel_cnt") reg_p_cnt (clk, (vs_rise ? `RSTLEVEL : ~`RSTLEVEL), de_i, p_cnt_n, p_cnt);

always@(posedge clk) begin
    if(de_i) begin
        reg_rgb[p_cnt] <= {8'd0, data_r_i, data_g_i, data_b_i};
    end
end

reg disp;
always@(posedge clk) begin
    if(rst == `RSTLEVEL || vs_rise) begin
        disp <= 0;
    end
    else if(disp == 0 && p_cnt == (`SCREEN_W*`SCREEN_H-1)) begin
`ifdef USE_DPIC
        screen_sync();
`endif
        disp <= 1;
    end
end

endmodule
