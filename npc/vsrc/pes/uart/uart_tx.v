`include "mydefines.v"
module uart_tx(
    input clk,
    input rst_n,
    input [1:0] parity,//需要持续赋值,偶0，奇1
    input fifordempty,
    input [7:0] fifodata,
    output reg fifordreq,
    output reg tx
);
//r: old模型适用于一般的normal模式fifo ip核，也就是每次r_req之后，才会输出下一个数据。。而不是预置数据。。
//r: 这里是基于FWFT模式fifo!
reg check;
reg [3:0] state;
reg busy;
reg [7:0] data_buf;
always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)
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
                fifordreq <= 1'b0;
                tx <= 1'b0;
                state <= 4'd2;
                check<=parity[0];
            end
            4'd2:
            begin
                tx <= data_buf[0];
                state <= state + 1'b1;
                check <= check ^ data_buf[0];
            end
            4'd3:
            begin
                tx <= data_buf[1];
                state <= state + 1'b1;
                check <= check ^ data_buf[1];
            end
            4'd4:
            begin
                tx <= data_buf[2];
                state <= state + 1'b1;
                check <= check ^ data_buf[2];
            end
            4'd5:
            begin
                tx <= data_buf[3];
                state <= state + 1'b1;
                check <= check ^ data_buf[3];
            end
            4'd6:
            begin
                tx <= data_buf[4];
                state <= state + 1'b1;
                check <= check ^ data_buf[4];
            end
            4'd7:
            begin
                tx <= data_buf[5];
                state <= state + 1'b1;
                check <= check ^ data_buf[5];
            end
            4'd8:
            begin
                tx <= data_buf[6];
                state <= state + 1'b1;
                check <= check ^ data_buf[6];
            end
            4'd9:
            begin
                tx <= data_buf[7];
                state <= state + 1'b1;
                check <= check ^ data_buf[7];
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
        fifordreq <= 1'b1;
        data_buf <= fifodata;
    end
end

endmodule
