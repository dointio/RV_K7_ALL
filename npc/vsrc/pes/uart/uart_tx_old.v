module uart_tx_old(
    input clk,
    input rst_n,
    input [1:0] parity,//需要持续赋值,偶0，奇1
    input fifordempty,
    input [7:0] fifodata,
    output reg fifordreq,
    output reg tx
);
//r: old模型适用于一般的normal模式fifo ip核，也就是每次r_req之后，才会输出下一个数据。。而不是预置数据。。

reg check;
reg [3:0] state;
reg busy;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        busy<= 1'b0;
        fifordreq <= 1'b0;
        tx<=1'b1;
        state <=4'd0;
        check <= 1'b0;
    end
    else if(busy)
    begin
        case(state)
            4'd0:
            begin
                fifordreq <= 1'b1;
                state <= state +1'b1;
            end
            4'd1:
            begin
                fifordreq <= 1'b0;
                tx <= 1'b0;
                state <= state +1'b1;
                check<=parity[0];
            end
            4'd2:
            begin
                tx <= fifodata[0];
                state <= state + 1'b1;
                check <= check ^ fifodata[0];
            end
            4'd3:
            begin
                tx <= fifodata[1];
                state <= state + 1'b1;
                check <= check ^ fifodata[1];
            end
            4'd4:
            begin
                tx <= fifodata[2];
                state <= state + 1'b1;
                check <= check ^ fifodata[2];
            end
            4'd5:
            begin
                tx <= fifodata[3];
                state <= state + 1'b1;
                check <= check ^ fifodata[3];
            end
            4'd6:
            begin
                tx <= fifodata[4];
                state <= state + 1'b1;
                check <= check ^ fifodata[4];
            end
            4'd7:
            begin
                tx <= fifodata[5];
                state <= state + 1'b1;
                check <= check ^ fifodata[5];
            end
            4'd8:
            begin
                tx <= fifodata[6];
                state <= state + 1'b1;
                check <= check ^ fifodata[6];
            end
            4'd9:
            begin
                tx <= fifodata[7];
                state <= state + 1'b1;
                check <= check ^ fifodata[7];
            end
            4'd10:
            begin
                if(parity[1])
                begin
                    tx <= check;
                    state <= state + 1'b1;
                end
                else
                begin
                    tx <= 1'b1;
                    state <= 4'd0;
                    busy<=0;
                end
            end
            4'd11:
            begin
                tx <= 1'b1;
                state <= 4'd0;
                busy<=0;
            end
            default: state <= 4'd0;
        endcase
    end
    else if(!fifordempty)
    begin
        busy <= 1'b1;
        state <= 0;
    end
end

endmodule
