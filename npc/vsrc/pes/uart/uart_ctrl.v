`include "mydefines.v"
module uart_ctrl(
    input clk,
    input rst_n,

    input   icb_cmd_vld,
    output  icb_cmd_rdy,
    input   icb_cmd_read,
    input [`MYRISCV_ADDRBUS]    icb_cmd_addr,
    input [`MYRISCV_DATABUS]                icb_cmd_wdata,
    input [`MYRISCV_DATADW/8-1:0]            icb_cmd_wmask,

    output  icb_rsp_vld,
    input   icb_rsp_rdy,
    output  [`MYRISCV_DATABUS] icb_rsp_rdata,
    output  icb_rsp_err,

    output reg interrupt_o,

    input               fifowrfull,
    output reg          fifowrreq,
    output [7:0]        fifowdata,
     
    input frameerror,
    input parityerror,
    input [7:0] rxdata,
    input rxdataupdate,
     
    output [11:0] tx_cnt,
    output [8:0]  rx_cnt,
    output [1:0]  parity
);

st_pipe_stage #(
    .CUT_READY     (1),
    .DP            (1),
    .DW            (1)
)pipe_reg(
    .i_vld        (icb_cmd_vld),
    .i_rdy        (icb_cmd_rdy),
    .data_i        (),

    .o_vld        (icb_rsp_vld),
    .o_rdy        (icb_rsp_rdy),
    .data_o        (),

    .clk        (clk),
    .rst        (rst_n)
);

/*
0:rx数据（[7:0]为数据；[8]校验位错误；[9]帧校验错误；查询读取时，[10]为1表示是一个新数据，为0表示数据已读取）
1:tx数据
2:rx中断激活
3:tx模式、rx模式、波特率与奇偶校验设置（[24]:0为niosii core控制tx，1为透传模式；[23]:0为rx查询读取，1为rx中断读取；
[22:21]:校验设置，00不校验，11奇校验，10偶校验；[20:12]:rx时钟计数值；[11:0]:tx时钟计数值）
*/
wire [`MYRISCV_DATABUS] wmask;
genvar i;
generate
    for(i=0; i<(`MYRISCV_DATADW/8); i=i+1) begin:gen_wmask
        assign wmask[(i+1)*8-1 : i*8] = {8{icb_cmd_wmask[i]}};
    end
endgenerate
wire [`MYRISCV_DATABUS] wdata_mask = icb_cmd_wdata & wmask;


`ifdef MYRISCV_ARCH_64
    // wire w_low = (wmask[3:0] != 0);
    wire w_low = (icb_cmd_wmask[3:0] != 0);
`endif

reg [31:0] rxreg;
reg [31:0] txreg;
reg [31:0] intreg;
reg [31:0] ctrlreg;

`ifdef MYRISCV_ARCH_64
    wire rxreg_sel      = (icb_cmd_addr[11 : 0] == 12'h3f8) & w_low;
    wire txreg_sel      = (icb_cmd_addr[11 : 0] == 12'h3f8) & ~w_low;
    wire intreg_sel     = (icb_cmd_addr[11 : 0] == 12'h400) & w_low;
    wire ctrlreg_sel    = (icb_cmd_addr[11 : 0] == 12'h400) & ~w_low;
`else
    wire rxreg_sel      = (icb_cmd_addr[11 : 0] == 12'h3f8);
    wire txreg_sel      = (icb_cmd_addr[11 : 0] == 12'h3fc);
    wire intreg_sel     = (icb_cmd_addr[11 : 0] == 12'h400);
    wire ctrlreg_sel    = (icb_cmd_addr[11 : 0] == 12'h404);
`endif

//o: wr txreg
always@(posedge clk) begin
    if(~rst_n) begin
        txreg <= 0;
    end
    else if(icb_cmd_rdy & icb_cmd_vld & ~icb_cmd_read & txreg_sel)begin
`ifdef MYRISCV_ARCH_64
        txreg <= wdata_mask[63:32];
`else
        txreg <= wdata_mask;
`endif
        fifowrreq <= 1'b1;
    end
    else begin
        fifowrreq <= 1'b0;
    end
end
assign fifowdata = txreg[7:0];
//o: wr ctrlreg
/*clk计数器等设置处理*/
/*寄存器3
3:tx模式、rx模式、波特率与奇偶校验设置（[24]:0为niosii core控制tx，1为透传模式；[23]:0为rx查询读取，1为rx中断读取；
[22:21]:校验设置，00不校验，11奇校验，10偶校验；[20:12]:rx时钟计数值；[11:0]:tx时钟计数值）
*/
/* Main fclk = 50MHz
parameter BPS9600_t = 2603;
parameter BPS9600_r = 325;
parameter BPS14400_t = 1735;
parameter BPS14400_r = 216;
parameter BPS19200_t = 1301;
parameter BPS19200_r = 162;
parameter BPS38400_t = 650;
parameter BPS38400_r = 80;
parameter BPS43000_t = 580;
parameter BPS43000_r = 72;
parameter BPS57600_t = 433;
parameter BPS57600_r = 53;
parameter BPS76800_t = 325;
parameter BPS76800_r = 40;
parameter BPS115200_t = 216;
parameter BPS115200_r = 26;
*/
wire txmode = ctrlreg[24];
wire rx_interrupt = ctrlreg[23];
assign parity = ctrlreg[22:21];
`ifdef PLATFORM_SIM
assign rx_cnt = 10;
assign tx_cnt = 10;
`else
assign rx_cnt = ctrlreg[20:12];
assign tx_cnt = ctrlreg[11:0];
`endif
always@(posedge clk) begin
    if(~rst_n) begin
        // ctrlreg <= 0;
        ctrlreg[31:25] <= 0;
        ctrlreg[24] <= 0;
        ctrlreg[23] <= 1;
        ctrlreg[22:21] <= 0;
        ctrlreg[20:12] <= 325;
        ctrlreg[11:0] <= 2603;
    end
    else if(icb_cmd_rdy & icb_cmd_vld & ~icb_cmd_read & ctrlreg_sel)begin
`ifdef MYRISCV_ARCH_64
        ctrlreg <= wdata_mask[63:32];
`else
        ctrlreg <= wdata_mask;
`endif
    end
end
//o: rx update
/*rx处理*/
reg rxupdate_buffer;
always@(posedge clk)
begin
    if(~rst_n)
    begin
        rxupdate_buffer <=0;
    end
    else
    begin
        rxupdate_buffer <= rxdataupdate;
    end
end
wire rxupdata_upedge = rxdataupdate & (~rxupdate_buffer);
always@(posedge clk)
begin
    if(~rst_n)
    begin
        rxreg <=0;
    end
    else if(rxupdata_upedge)
    begin
        rxreg <= {22'd1,frameerror,parityerror,rxdata[7:0]};
    end
    else if(icb_cmd_vld & icb_cmd_rdy & icb_cmd_read & rxreg_sel) begin
        rxreg <= 0;
    end
    // else if(avalon_rdreq && (avalon_addr== 2'd0)) //r: clear after read! 
    // begin
    //     avalon_data_read <= rxreg;
    //     rxreg[10] <= 1'b0;
    // end
end
//o: wr intreg
always@(posedge clk)
begin
    if(~rst_n)
    begin
        interrupt_o <= 0;
    end
    else if(interrupt_o)
    begin
        if(icb_cmd_vld & icb_cmd_rdy & ~icb_cmd_read & intreg_sel)
        begin
            interrupt_o <= 0;
        end
    end
    else if(rx_interrupt && rxupdata_upedge)
    begin
        interrupt_o <= 1'b1;
    end
end

//o: read reg
assign icb_rsp_err = 1'b0;
wire rxreg_sel_r, txreg_sel_r, intreg_sel_r, ctrlreg_sel_r;
reg_enrs #(4, 0, "gpu_sel_reg") sel_reg (clk, rst_n, icb_cmd_vld&icb_cmd_rdy, 
    {rxreg_sel, txreg_sel, intreg_sel, ctrlreg_sel}, 
    {rxreg_sel_r, txreg_sel_r, intreg_sel_r, ctrlreg_sel_r});

wire [31:0] rxreg_r;
reg_enrs #(32, 0, "out_reg") out_reg (clk, rst_n, icb_cmd_vld&icb_cmd_rdy&icb_cmd_read,
    rxreg, rxreg_r);

// wire rxreg_sel      = (icb_cmd_addr[11 : 0] == 12'h3f8);
// wire txreg_sel      = (icb_cmd_addr[11 : 0] == 12'h3fc);
// wire intreg_sel     = (icb_cmd_addr[11 : 0] == 12'h400);
// wire ctrlreg_sel    = (icb_cmd_addr[11 : 0] == 12'h404);

`ifdef MYRISCV_ARCH_64
    assign icb_rsp_rdata =    rxreg_sel_r     ? {32'd0, rxreg_r} :(
                            ctrlreg_sel_r   ? {ctrlreg, 32'd0} :(
                            txreg_sel_r     ? {{31'd0, fifowrfull}, 32'd0} :
                            0//r: intreg cannot be read! ret 0
                            ));

`else
    assign icb_rsp_rdata =    txreg_sel_r     ? rxreg_r :(
                            ctrlreg_sel_r   ? ctrlreg :(
                            txreg_sel_r     ? {31'd0, fifowrfull} :
                            0//r: intreg cannot be read! ret 0
                            ));
`endif


/*
reg [25:0] cnt;
reg [31:0] s;
always@(negedge rst_n or posedge clk)
begin
    if(!rst_n)
    begin
        avalon_irq <= 0;
        cnt <= 0;
        s<=32'd1;
    end
    else if(cnt == 26'd49_999_999)
    begin
        cnt <= 0;
        avalon_irq <= 1'b1;
        s <= s+1'b1;
    end
    else
    begin
        cnt <= cnt +1'b1;
        avalon_irq <= 1'b0;
    end
end


always@(negedge rst_n or posedge clk)
begin
    if(!rst_n)
    begin
        avalon_data_read <= 0;
        //avalon_irq <= 0;
        wrreq <= 0;
        fifodata <= 0;
        tx_cnt <= 0;
        rx_cnt <= 0;
    end
    else if(avalon_wrreq && (avalon_addr == 2'd0))
    begin
        avalon_data_read <= s;
    end
end*/


endmodule
