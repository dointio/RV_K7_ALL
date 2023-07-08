`include "mydefines.v" 
`include "e203_defines.v"

module exu_cordic (
    clk,
    rst_n,

    disp2cordic_vld,
    disp2cordic_rdy,
    ex2cordic_info,
    ex2cordic_rs1,
    ex2cordic_rdidx,

    cordic2wb_vld,
    cordic2wb_rdy,
    rdidx_o,
    rddata_o
);

input clk, rst_n;

input disp2cordic_vld;
output disp2cordic_rdy;
input [`E203_DECINFO_WIDTH-1 : 0] ex2cordic_info;
input [`MYRISCV_REGBUS] ex2cordic_rs1;
input [`MYRISCV_REGADDRBUS] ex2cordic_rdidx;

output cordic2wb_vld;
input cordic2wb_rdy;
output reg [`MYRISCV_REGADDRBUS] rdidx_o;
output [`MYRISCV_REGBUS] rddata_o;

wire out_handshake = cordic2wb_vld & cordic2wb_rdy;
wire in_handshake = disp2cordic_vld & disp2cordic_rdy;

reg hold_data;
always@(posedge clk /*or negedge rst_n*/) begin
    if(!rst_n) begin
        hold_data <= 1'b0;
        rdidx_o <= 0;
    end
    else if(in_handshake) begin
        hold_data <= 1'b1;
        rdidx_o <= ex2cordic_rdidx;
    end
    else if(out_handshake) begin
        hold_data <= 1'b0;
    end
end
assign disp2cordic_rdy = (~hold_data) || (out_handshake);

wire en_i; assign en_i = disp2cordic_vld & disp2cordic_rdy;
wire en_o;
wire [31:0] res_cos;
cordic_sc cordic_sc_inst(
    .clk            (clk),
    .rst_n          (rst_n),
    .en_i           (en_i),
    .en_o           (en_o),
    .angle_i        (ex2cordic_rs1[31:0]),
    .angle_o        (),
    .sin_o          (),
    .cos_o          (res_cos)
);
assign rddata_o = {{(`MYRISCV_DATADW-32){1'b0}}, res_cos};

reg vld_o;
always@(posedge clk /*or negedge rst_n*/) begin
    if(!rst_n) begin
        vld_o <= 1'b0;
    end 
    else if(en_o) begin
        vld_o <= 1'b1;
    end
    else if(out_handshake) begin
        vld_o <= 1'b0;
    end
end
assign cordic2wb_vld = vld_o;

endmodule
