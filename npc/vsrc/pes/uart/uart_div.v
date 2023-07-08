`include "mydefines.v"
module uart_div(
    input clk,
    input rst_n,
    output reg uart_tx_clk,
    output reg uart_rx_clk,
    input   [11:0]tx_cnt, 
    input    [8:0]rx_cnt
);

reg [11:0] cnt;
reg [8:0] cnt2;

always@(posedge clk)
begin
    // if(~rst_n)
    // begin
    //     uart_tx_clk <= 0;
    //     cnt<= 0;
    // end
    // else 
    if(cnt >= tx_cnt)
    begin
        cnt<=0;
        uart_tx_clk <=~uart_tx_clk;
    end
    else begin
        cnt<= cnt+1'b1;
    end
end

always@(posedge clk)
begin
    // if(~rst_n)
    // begin
    //     uart_rx_clk <= 0;
    //     cnt2<= 0;
    // end
    // else 
    if(cnt2 >= rx_cnt)
    begin
        cnt2<=0;
        uart_rx_clk <=~uart_rx_clk;
    end
    else begin
        cnt2<= cnt2+1'b1;
    end
end
    

endmodule
