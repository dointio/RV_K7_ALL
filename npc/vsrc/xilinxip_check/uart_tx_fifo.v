module uart_tx_fifo (
    input rst,
    input wr_clk,
    input rd_clk,

    input wr_en,
    input [7:0] din,
    output full,

    input rd_en,
    output [7:0] dout,
    output empty
);


endmodule

