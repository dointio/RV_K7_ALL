`include "mydefines.v"
module uart_rx(
    input rx,
    input clk,
    input rst_n,
    input [1:0] parity,//需要持续赋值
    output reg framer_error,
    output reg parity_error,
    output reg [7:0] dataout,
    output reg rxdataupdate
);

reg [7:0]state;
reg rx_buffer;
reg rx_fall;
reg check;
reg busy;
reg command_end;
always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        rx_buffer<=1;
        rx_fall<=0;
    end
    else begin
        rx_buffer<=rx;
        rx_fall<=rx_buffer&(~rx);
    end
end


always@(posedge clk  or negedge rst_n)
begin
    if(~rst_n)
    begin
        state<=8'd0;
        dataout<=0;
        rxdataupdate <= 0;
        check<=0;
        busy<=1'b0;
        parity_error<=1'b0;
        framer_error<=1'b0;
    end
    else if(rx_fall&&(!busy))
    begin
        state<=8'd0;
        busy<=1'b1;
    end
    else if(busy)
    begin
        case(state)
            8'd10://0号位数据
            begin
                dataout[0]<=rx;
                check <= rx^parity[0];
                state<=state+1'b1;
            end
            8'd18://1位
            begin
                dataout[1]<=rx;
                check <= rx^check;
                state<=state+1'b1;
            end
            8'd26://2位
            begin
                dataout[2]<=rx;
                check <= rx^check;
                state<=state+1'b1;
            end
            8'd34://3位
            begin
                dataout[3]<=rx;
                check <= rx^check;
                state<=state+1'b1;
            end
            8'd42://4位
            begin
                dataout[4]<=rx;
                check <= rx^check;
                state<=state+1'b1;
            end
            8'd50://5位
            begin
                dataout[5]<=rx;
                check <= rx^check;
                state<=state+1'b1;
            end
            8'd58://6位
            begin
                dataout[6]<=rx;
                check <= rx^check;
                state<=state+1'b1;
            end
            8'd66://7位
            begin
                dataout[7]<=rx;
                check <= rx^check;
                state<=state+1'b1;
            end
            8'd74:
            begin
                if(parity[1])
                begin
                    if(check == rx) 
                    begin
                        state<=state+1'b1;
                    end
                    else 
                    begin
                        parity_error<=1'b1;
                        state<=state+1'b1;
                    end
                    
                end
                else
                begin
                    if(rx == 1'b1) begin
                        state<=8'd83;
                        rxdataupdate <= 1'b1;
                    end
                    else begin
                        framer_error<=1'b0;
                        state<=8'd83;
                        rxdataupdate <= 1'b1;
                    end
                end
            end
            8'd82:
            begin
                if(rx == 1'b1) begin
                    state<=8'd83;
                    rxdataupdate <= 1'b1;
                end
                else begin
                    framer_error<=1'b0;
                    state<=8'd83;
                    rxdataupdate <= 1'b1;
                end
            end
            8'd83:
            begin
                state <= 0;
                rxdataupdate <= 0;
                busy <= 0;
                framer_error <= 0;
                parity_error <= 0;
            end
            default:state<=state+1'b1;
        endcase
    end
end



endmodule
