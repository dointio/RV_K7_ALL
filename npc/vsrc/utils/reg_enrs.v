`include "mydefines.v"
module reg_enrs #(
    parameter DW = 1, 
    parameter RESET_VAL = 0,
    parameter REG_NAME = "reg_enrs"
) (
    input clk,
    input rst,
    input en,
    input [DW-1:0] data_i,
    output reg [DW-1:0] data_o
);
    always @(posedge clk) begin
        if (rst == `RSTLEVEL) data_o <= RESET_VAL;
        else if (en) data_o <= data_i;
    end
`ifdef PLATFORM_SIM
    xchecker_reg #(
        .DW             (1),
        .SIGNAL_NAME    ({"en of ", REG_NAME})
    )xchecker_en(
        .clk        (clk),
        .data_i      (en)
    );
`endif
endmodule

