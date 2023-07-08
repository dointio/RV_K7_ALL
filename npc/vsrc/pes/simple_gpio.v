`include "mydefines.v"
module simple_gpio
(
    clk,
    rst,

    paddr,
    pstrb,
    pwdata,
    pwrite,
    psel,
    penable,
    prdata,
    pready,
    pslverr,

    gpio_o
);
//r: note !! only support write word!! dont support write doubleword/halfword/byte!!

    input clk, rst;
    input [`MYRISCV_ADDRBUS] paddr;
    input [`MYRISCV_DATADW/8-1 : 0] pstrb;
    input [`MYRISCV_DATABUS] pwdata;
    input pwrite;
    input psel;
    input penable;
    output reg [`MYRISCV_DATABUS] prdata;
    output reg pready;
    output reg pslverr = 1'b0;

    output reg [31:0] gpio_o;

`ifdef MYRISCV_ARCH_64
    wire sel_low = ((pstrb & 8'hf) != 0);
    wire [31:0] trueW = sel_low ? pwdata[31:0] : pwdata[63:32];
`endif

    always@(posedge clk /*or negedge rst*/) begin
        if(~rst) begin
            gpio_o<=0;
            prdata<=0;
            prdata<=0;
            pslverr<=0;
            pready<=0;
        end
        else if(pready) begin
            if(penable) begin
                pready <= 0;
            end
        end
        else if(psel) begin
            if(pwrite) begin
`ifdef MYRISCV_ARCH_64
                gpio_o <= trueW;
`else
                gpio_o <= pwdata;
`endif
            end
            else begin
                prdata <= {{(`MYRISCV_DATADW-32){1'b0}}, 32'hffeeaabb};
            end
            pready <= 1;
        end
    end
endmodule
