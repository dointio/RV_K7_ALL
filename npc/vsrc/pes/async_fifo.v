`include "mydefines.v"
module async_fifo #(
    parameter integer DW = 32,
    parameter integer DP = 64
)
(
    input clk_i,
    input clk_o,
    input rst_n,

    input w_req,
    output full,
    input [DW-1 : 0] data_i,

    input r_req,
    output empty,
    output [DW-1 : 0] data_o
);

`include "myfuncs.v"

localparam ADDRW = myclog2(DP);

reg [ADDRW : 0] r_ptr;
reg [ADDRW : 0] w_ptr;
wire [ADDRW : 0] r_ptr_g;
wire [ADDRW : 0] w_ptr_g;

wire [DW-1 : 0] reg_r [DP-1 : 0];

always@(posedge clk_i or negedge rst_n) begin
    if(!rst_n) begin
        w_ptr <= 0;
    end
    else if(w_req & ~full) begin
        w_ptr <= w_ptr + 1;
    end
end

always@(posedge clk_o or negedge rst_n) begin
    if(!rst_n) begin
        r_ptr <= 0;
    end
    else if(r_req & ~empty) begin
        r_ptr <= r_ptr + 1;
    end
end

assign w_ptr_g = w_ptr^{1'b0, w_ptr[ADDRW:1]};
assign r_ptr_g = r_ptr^{1'b0, r_ptr[ADDRW:1]};

generate 
genvar i;
for(i=0; i<DP; i=i+1) begin
    reg_enrs #(DW, 0, "async_reg") async_reg (
        clk_i, 
        rst_n, 
        (w_ptr == i) & w_req & (~full),
        data_i,
        reg_r[i]
    );
end
endgenerate

assign data_o = reg_r[r_ptr[ADDRW-1:0]];

reg [ADDRW : 0] w_ptr_r, w_ptr_r2;
reg [ADDRW : 0] r_ptr_r, r_ptr_r2;

always@(posedge clk_i or negedge rst_n) begin
    if(~rst_n) begin
        r_ptr_r <= 0;
        r_ptr_r2 <= 0;
    end
    else begin
        r_ptr_r <= r_ptr_g;
        r_ptr_r2 <= r_ptr_r;
    end
end

always@(posedge clk_o or negedge rst_n) begin
    if(~rst_n) begin
        w_ptr_r <= 0;
        w_ptr_r2 <= 0;
    end
    else begin
        w_ptr_r <= w_ptr_g;
        w_ptr_r2 <= w_ptr_r;
    end
end

assign empty = (r_ptr_g == w_ptr_r2);
assign full  = (w_ptr_g == {~r_ptr_r2[ADDRW: ADDRW-2], r_ptr_r2[ADDRW-3 : 0]});

endmodule
