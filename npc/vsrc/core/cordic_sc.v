module cordic_sc #(
    parameter SC_DW = 32,
    parameter ANGLE_DW = 32,
    parameter ANGLE_PRECISION = 16,
    parameter angle_0 = 32'sd2949120,		//45度*2^16
    parameter angle_1 = 32'sd1740992,     //26.5651度*2^16
    parameter angle_2 = 32'sd919872,      //14.0362度*2^16
    parameter angle_3 = 32'sd466944,      //7.1250度*2^16
    parameter angle_4 = 32'sd234368,      //3.5763度*2^16
    parameter angle_5 = 32'sd117312,     //1.7899度*2^16
    parameter angle_6 = 32'sd58688,      //0.8952度*2^16
    parameter angle_7 = 32'sd29312,      //0.4476度*2^16
    parameter angle_8 = 32'sd14656,      //0.2238度*2^16
    parameter angle_9 = 32'sd7360,      //0.1119度*2^16
    parameter angle_10 = 32'sd3648,      //0.0560度*2^16
    parameter angle_11 = 32'sd1856,	    //0.0280度*2^16
    parameter angle_12 = 32'sd896,      //0.0140度*2^16
    parameter angle_13 = 32'sd448,      //0.0070度*2^16
    parameter angle_14 = 32'sd256,      //0.0035度*2^16
    parameter angle_15 = 32'sd128,      //0.0018度*2^16
    parameter Kn = 32'sh09b74//32'd39796 //约为65536/1.64676，因为迭代过程中扩大了约1.64676倍。
)
(
    clk,
    rst_n,
    en_i,
    en_o,
    angle_i,
    angle_o,
    sin_o,
    cos_o
);

input clk,rst_n;
input en_i;
output en_o;
input [ANGLE_DW-1 : 0] angle_i;
output [ANGLE_DW-1 : 0] angle_o;
output  [SC_DW-1 : 0] sin_o;
output  [SC_DW-1 : 0] cos_o;


localparam pipedeep = 16;

wire signed [ANGLE_DW-1:0] angle_regs [0:15];
assign angle_regs[0] = angle_0;
assign angle_regs[1] = angle_1;
assign angle_regs[2] = angle_2;
assign angle_regs[3] = angle_3;
assign angle_regs[4] = angle_4;
assign angle_regs[5] = angle_5;
assign angle_regs[6] = angle_6;
assign angle_regs[7] = angle_7;
assign angle_regs[8] = angle_8;
assign angle_regs[9] = angle_9;
assign angle_regs[10] = angle_10;
assign angle_regs[11] = angle_11;
assign angle_regs[12] = angle_12;
assign angle_regs[13] = angle_13;
assign angle_regs[14] = angle_14;
assign angle_regs[15] = angle_15;

reg signed [ANGLE_DW-1 : 0] angle_data [0 : pipedeep];
reg signed [ANGLE_DW-1 : 0] angle_diff [0 : pipedeep];
reg signed [SC_DW-1 : 0] y_data [0 : pipedeep];
reg signed [SC_DW-1 : 0] x_data [0 : pipedeep];
reg [pipedeep : 0] en_r;

always @(posedge clk /*or negedge rst_n*/) begin
    if(!rst_n) begin
        angle_data[0] <= 0;
        angle_diff[0] <= 0;
        y_data[0] <= 0;
        x_data[0] <= Kn;
        en_r[0] <= 0;
    end
    else if(en_i) begin
        // angle_data[0] = 0;
        en_r[0] <= 1;
        if(angle_i[ANGLE_DW-1 : ANGLE_PRECISION] < 90) begin
            angle_diff[0] <= angle_i;
            angle_data[0] <= 0;
            y_data[0] <= 0;
            x_data[0] <= Kn;
        end
        else if(angle_i[ANGLE_DW-1 : ANGLE_PRECISION] < 180) begin
            angle_diff[0] <= angle_i - (32'd90 << ANGLE_PRECISION);
            angle_data[0] <= (32'd90 << ANGLE_PRECISION);
            y_data[0] <= Kn;
            x_data[0] <= 0;
        end
        else if(angle_i[ANGLE_DW-1 : ANGLE_PRECISION] < 270) begin
            angle_diff[0] <= angle_i - (32'd180 << ANGLE_PRECISION);
            angle_data[0] <= (32'd180 << ANGLE_PRECISION);
            y_data[0] <= 0;
            x_data[0] <= -Kn;
        end
        else /*if(angle_i[ANGLE_DW-1 : ANGLE_PRECISION])*/ begin
            angle_diff[0] <= angle_i - (32'd270 << ANGLE_PRECISION);
            angle_data[0] <= (32'd270 << ANGLE_PRECISION);
            y_data[0] <= -Kn;
            x_data[0] <= 0;
        end
    end
    else begin
        en_r[0] <= 0;
    end
end


generate
    genvar i;
for(i=0; i<pipedeep; i=i+1) begin : pipestage
    always@(posedge clk /*or negedge rst_n*/)begin
        if(!rst_n) begin
            angle_data[i+1] <= 0;
            angle_diff[i+1] <= 0;
            y_data[i+1] <= 0;
            x_data[i+1] <= Kn;
            en_r[i+1] <= 0;
        end
        else if(en_r[i]) begin
            en_r[i+1] <= 1;
            if(angle_diff[i] > 32'sd0) begin
                x_data[i+1] <= x_data[i] - (y_data[i] >>> i);
                y_data[i+1] <= y_data[i] + (x_data[i] >>> i);
                angle_diff[i+1] <= angle_diff[i] - angle_regs[i];
                angle_data[i+1] <= angle_data[i] + angle_regs[i];
            end
            else begin
                x_data[i+1] <= x_data[i] + (y_data[i] >>> i);
                y_data[i+1] <= y_data[i] - (x_data[i] >>> i);
                angle_diff[i+1] <= angle_diff[i] + angle_regs[i];
                angle_data[i+1] <= angle_data[i] - angle_regs[i];
            end
        end
        else begin
            en_r[i+1] <= 0;
        end
    end
end
endgenerate

assign sin_o = y_data[pipedeep];
assign cos_o = x_data[pipedeep];
assign angle_o  = angle_data[pipedeep];
assign en_o = en_r[pipedeep];

endmodule
