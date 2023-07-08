`include "mydefines.v"
`include "e203_defines.v"
// lsu模块
module lsu(
    input wire clk,
    input wire rst,

    // from dec
    input wire disp2lsu_vld,
    output wire disp2lsu_rdy,
    input wire[`MYRISCV_ADDRBUS] ex2lsu_pc,   // 指令地址
    input wire  [`MYRISCV_REGBUS] ex2lsu_rs1,       // 通用寄存器1输入数据
    input wire  [`MYRISCV_REGBUS] ex2lsu_rs2,       // 通用寄存器2输入数据
    input wire  [`MYRISCV_REGBUS] ex2lsu_imm,
    input wire  ex2lsu_rdwen,                    // 是否写通用寄存器
    input wire  [`MYRISCV_REGADDRBUS] ex2lsu_rdidx,    // 写通用寄存器地址
    input wire  [`MY_DECINFO_WIDTH-1 : 0] ex2lsu_info,

    input wire nice2lsu_vld,
    output wire nice2lsu_rdy,
    input wire nice2lsu_read,   // 指令地址
    input wire [`MYRISCV_ADDRBUS] nice2lsu_addr,       // 通用寄存器1输入数据
    input wire [`MYRISCV_REGBUS] nice2lsu_wdata,       // 通用寄存器2输入数据
    input wire  [(`MYRISCV_XLEN/8-1):0] nice2lsu_wmask,
    input wire [1:0] nice2lsu_size,
    input wire nice2lsu_unsign,
    input wire [`MYRISCV_REGADDRBUS] nice2lsu_rdidx,
    input wire nice2lsu_ret,//将结果写回nice而不是reg中.

    output wire lsu_cmd_vld,
    input wire lsu_cmd_rdy,
    output wire lsu_cmd_read,
    output wire [`MYRISCV_ADDRBUS] lsu_cmd_addr,
    output wire [`MYRISCV_REGBUS] lsu_cmd_wdata,
    output wire [(`MYRISCV_XLEN/8-1):0] lsu_cmd_wmask,

    input wire lsu_rsp_vld,
    output wire lsu_rsp_rdy,
    input wire [`MYRISCV_REGBUS] lsu_rsp_rdata,
    input wire lsu_rsp_err,

    // to nice
    output wire lsu2nice_vld,                   // 
    input  wire lsu2nice_rdy,
    output wire [`MYRISCV_REGBUS] lsu2nice_wdata,       // 
    output wire [`MYRISCV_REGADDRBUS] lsu2nice_rdidx,   // 这个返回地址不知道有没有用，先留着。

    // to regs
    output wire lsu2wb_vld,                   // 是否写通用寄存器
    input  wire lsu2wb_rdy,
    output wire [`MYRISCV_REGBUS] lsu2wb_wdata,       // 写寄存器数据
    output wire [`MYRISCV_REGADDRBUS] lsu2wb_rdidx   // 写通用寄存器地址
    );

    //****************************signal decode**************************************

    wire ex2lsu_vld = disp2lsu_vld;
    wire ex2lsu_rdy;    assign disp2lsu_rdy = ex2lsu_rdy;
    wire ex2lsu_read = ex2lsu_info[`MY_DECINFO_AGU_LOAD];
    wire [`MYRISCV_ADDRBUS] ex2lsu_addr = ex2lsu_rs1 + ex2lsu_imm;
    wire [1:0] ex2lsu_size = ex2lsu_info[`MY_DECINFO_AGU_SIZE];
    wire [2:0] ex2lsu_offset = ex2lsu_addr[2:0];
    wire ex2lsu_unsign = ex2lsu_info[`MY_DECINFO_AGU_USIGN];
    wire wmask_1 = (ex2lsu_info[`MY_DECINFO_AGU_SIZE] == 0);
    wire wmask_2 = (ex2lsu_info[`MY_DECINFO_AGU_SIZE] == 1);
    wire wmask_4 = (ex2lsu_info[`MY_DECINFO_AGU_SIZE] == 2);
    wire wmask_8 = (ex2lsu_info[`MY_DECINFO_AGU_SIZE] == 3);
`ifdef MYRISCV_ARCH_64
    wire [7:0] ex2lsu_wmask; 
    assign ex2lsu_wmask[7] =    wmask_8 | 
                                (wmask_4 && (ex2lsu_addr[2:0] == 3'b100)) |
                                (wmask_2 && (ex2lsu_addr[2:0] == 3'b110)) | 
                                (wmask_1 && (ex2lsu_addr[2:0] == 3'b111));
    assign ex2lsu_wmask[6] =    wmask_8 | 
                                (wmask_4 && (ex2lsu_addr[2:0] == 3'b100)) |
                                (wmask_2 && (ex2lsu_addr[2:0] == 3'b110)) | 
                                (wmask_1 && (ex2lsu_addr[2:0] == 3'b110));
    assign ex2lsu_wmask[5] =    wmask_8 | 
                                (wmask_4 && (ex2lsu_addr[2:0] == 3'b100)) |
                                (wmask_2 && (ex2lsu_addr[2:0] == 3'b100)) | 
                                (wmask_1 && (ex2lsu_addr[2:0] == 3'b101));
    assign ex2lsu_wmask[4] =    wmask_8 | 
                                (wmask_4 && (ex2lsu_addr[2:0] == 3'b100)) |
                                (wmask_2 && (ex2lsu_addr[2:0] == 3'b100)) | 
                                (wmask_1 && (ex2lsu_addr[2:0] == 3'b100));
    assign ex2lsu_wmask[3] =    wmask_8 |
                                (wmask_4 && (ex2lsu_addr[2:0] == 3'b000)) | 
                                (wmask_2 && (ex2lsu_addr[2:0] == 3'b010)) | 
                                (wmask_1 && (ex2lsu_addr[2:0] == 3'b011));
    assign ex2lsu_wmask[2] =    wmask_8 |
                                (wmask_4 && (ex2lsu_addr[2:0] == 3'b000)) | 
                                (wmask_2 && (ex2lsu_addr[2:0] == 3'b010)) | 
                                (wmask_1 && (ex2lsu_addr[2:0] == 3'b010));
    assign ex2lsu_wmask[1] =    wmask_8 |
                                (wmask_4 && (ex2lsu_addr[2:0] == 3'b000)) | 
                                (wmask_2 && (ex2lsu_addr[2:0] == 3'b000)) | 
                                (wmask_1 && (ex2lsu_addr[2:0] == 3'b001));
    assign ex2lsu_wmask[0] =    wmask_8 |
                                (wmask_4 && (ex2lsu_addr[2:0] == 3'b000)) | 
                                (wmask_2 && (ex2lsu_addr[2:0] == 3'b000)) | 
                                (wmask_1 && (ex2lsu_addr[2:0] == 3'b000));
`else
    wire [3:0] ex2lsu_wmask;
    assign ex2lsu_wmask[3] = wmask_4 | (wmask_2 && (ex2lsu_addr[1:0] == 2'b10)) | (wmask_1 && (ex2lsu_addr[1:0] == 2'b11));
    assign ex2lsu_wmask[2] = wmask_4 | (wmask_2 && (ex2lsu_addr[1:0] == 2'b10)) | (wmask_1 && (ex2lsu_addr[1:0] == 2'b10));
    assign ex2lsu_wmask[1] = wmask_4 | (wmask_2 && (ex2lsu_addr[1:0] == 2'b00)) | (wmask_1 && (ex2lsu_addr[1:0] == 2'b01));
    assign ex2lsu_wmask[0] = wmask_4 | (wmask_2 && (ex2lsu_addr[1:0] == 2'b00)) | (wmask_1 && (ex2lsu_addr[1:0] == 2'b00));
`endif
    // wire [`MYRISCV_REGBUS] ex2lsu_wdata = ex2lsu_rs2;
    wire [`MYRISCV_REGBUS] ex2lsu_wdata;

`ifdef MYRISCV_ARCH_64
    assign ex2lsu_wdata[63:56] =    ({8{wmask_8}} & ex2lsu_rs2[63:56]) |
                                    ({8{wmask_4}} & {8{(ex2lsu_addr[2:0]==3'b100) ? 1'b1 : 1'b0}} & ex2lsu_rs2[31:24]) |
                                    ({8{wmask_2}} & {8{(ex2lsu_addr[2:0]==3'b110) ? 1'b1 : 1'b0}} & ex2lsu_rs2[15:8]) |
                                    ({8{wmask_1}} & {8{(ex2lsu_addr[2:0]==3'b111) ? 1'b1 : 1'b0}} & ex2lsu_rs2[7:0]);
    assign ex2lsu_wdata[55:48] =    ({8{wmask_8}} & ex2lsu_rs2[55:48]) |
                                    ({8{wmask_4}} & {8{(ex2lsu_addr[2:0]==3'b100) ? 1'b1 : 1'b0}} & ex2lsu_rs2[23:16]) |
                                    ({8{wmask_2}} & {8{(ex2lsu_addr[2:0]==3'b110) ? 1'b1 : 1'b0}} & ex2lsu_rs2[7:0]) |
                                    ({8{wmask_1}} & {8{(ex2lsu_addr[2:0]==3'b110) ? 1'b1 : 1'b0}} & ex2lsu_rs2[7:0]);
    assign ex2lsu_wdata[47:40] =    ({8{wmask_8}} & ex2lsu_rs2[47:40]) |
                                    ({8{wmask_4}} & {8{(ex2lsu_addr[2:0]==3'b100) ? 1'b1 : 1'b0}} & ex2lsu_rs2[15:8]) |
                                    ({8{wmask_2}} & {8{(ex2lsu_addr[2:0]==3'b100) ? 1'b1 : 1'b0}} & ex2lsu_rs2[15:8]) |
                                    ({8{wmask_1}} & {8{(ex2lsu_addr[2:0]==3'b101) ? 1'b1 : 1'b0}} & ex2lsu_rs2[7:0]);
    assign ex2lsu_wdata[39:32] =    ({8{wmask_8}} & ex2lsu_rs2[39:32]) |
                                    ({8{wmask_4}} & {8{(ex2lsu_addr[2:0]==3'b100) ? 1'b1 : 1'b0}} & ex2lsu_rs2[7:0]) |
                                    ({8{wmask_2}} & {8{(ex2lsu_addr[2:0]==3'b100) ? 1'b1 : 1'b0}} & ex2lsu_rs2[7:0]) |
                                    ({8{wmask_1}} & {8{(ex2lsu_addr[2:0]==3'b100) ? 1'b1 : 1'b0}} & ex2lsu_rs2[7:0]);
    assign ex2lsu_wdata[31:24] =    ({8{wmask_8}} & ex2lsu_rs2[31:24]) |
                                    ({8{wmask_4}} & {8{(ex2lsu_addr[2:0]==3'b000) ? 1'b1 : 1'b0}} & ex2lsu_rs2[31:24]) |
                                    ({8{wmask_2}} & {8{(ex2lsu_addr[2:0]==3'b010) ? 1'b1 : 1'b0}} & ex2lsu_rs2[15:8]) |
                                    ({8{wmask_1}} & {8{(ex2lsu_addr[2:0]==3'b011) ? 1'b1 : 1'b0}} & ex2lsu_rs2[7:0]);
    assign ex2lsu_wdata[23:16] =    ({8{wmask_8}} & ex2lsu_rs2[23:16]) |
                                    ({8{wmask_4}} & {8{(ex2lsu_addr[2:0]==3'b000) ? 1'b1 : 1'b0}} & ex2lsu_rs2[23:16]) |
                                    ({8{wmask_2}} & {8{(ex2lsu_addr[2:0]==3'b010) ? 1'b1 : 1'b0}} & ex2lsu_rs2[7:0]) |
                                    ({8{wmask_1}} & {8{(ex2lsu_addr[2:0]==3'b010) ? 1'b1 : 1'b0}} & ex2lsu_rs2[7:0]);
    assign ex2lsu_wdata[15:8] =     ({8{wmask_8}} & ex2lsu_rs2[15:8]) |
                                    ({8{wmask_4}} & {8{(ex2lsu_addr[2:0]==3'b000) ? 1'b1 : 1'b0}} & ex2lsu_rs2[15:8]) |
                                    ({8{wmask_2}} & {8{(ex2lsu_addr[2:0]==3'b000) ? 1'b1 : 1'b0}} & ex2lsu_rs2[15:8]) |
                                    ({8{wmask_1}} & {8{(ex2lsu_addr[2:0]==3'b001) ? 1'b1 : 1'b0}} & ex2lsu_rs2[7:0]);
    assign ex2lsu_wdata[7:0] =      ({8{wmask_8}} & ex2lsu_rs2[7:0]) |
                                    ({8{wmask_4}} & {8{(ex2lsu_addr[2:0]==3'b000) ? 1'b1 : 1'b0}} & ex2lsu_rs2[7:0]) |
                                    ({8{wmask_2}} & {8{(ex2lsu_addr[2:0]==3'b000) ? 1'b1 : 1'b0}} & ex2lsu_rs2[7:0]) |
                                    ({8{wmask_1}} & {8{(ex2lsu_addr[2:0]==3'b000) ? 1'b1 : 1'b0}} & ex2lsu_rs2[7:0]);

    // assign ex2lsu_wdata[31:24] = ({8{wmask_4}} & ex2lsu_rs2[31:24]) | ({8{wmask_2}} & {8{(ex2lsu_addr[1:0]==2'b10) ? 1'b1 : 1'b0}} & ex2lsu_rs2[15:8]) 
    //                         | {{8{wmask_1}} & {8{(ex2lsu_addr[1:0]==2'b11)}} & ex2lsu_rs2[7:0]};
    // assign ex2lsu_wdata[23:16] = ({8{wmask_4}} & ex2lsu_rs2[23:16]) | ({8{wmask_2}} & {8{(ex2lsu_addr[1:0]==2'b10) ? 1'b1 : 1'b0}} & ex2lsu_rs2[7:0])
    //                         | {{8{wmask_1}} & {8{(ex2lsu_addr[1:0]==2'b10)}} & ex2lsu_rs2[7:0]};
    // assign ex2lsu_wdata[15:8] = ({8{wmask_4}} & ex2lsu_rs2[15:8]) | ({8{wmask_2}} & {8{(ex2lsu_addr[1:0]==2'b00) ? 1'b1 : 1'b0}} & ex2lsu_rs2[15:8])
    //                         | {{8{wmask_1}} & {8{(ex2lsu_addr[1:0]==2'b01)}} & ex2lsu_rs2[7:0]};
    // assign ex2lsu_wdata[7:0] = ({8{wmask_4}} & ex2lsu_rs2[7:0]) | ({8{wmask_2}} & {8{(ex2lsu_addr[1:0]==2'b00) ? 1'b1 : 1'b0}} & ex2lsu_rs2[7:0])
    //                         | {{8{wmask_1}} & {8{(ex2lsu_addr[1:0]==2'b00)}} & ex2lsu_rs2[7:0]};
`else
    assign ex2lsu_wdata[31:24] = ({8{wmask_4}} & ex2lsu_rs2[31:24]) | ({8{wmask_2}} & {8{(ex2lsu_addr[1:0]==2'b10) ? 1'b1 : 1'b0}} & ex2lsu_rs2[15:8]) 
                            | {{8{wmask_1}} & {8{(ex2lsu_addr[1:0]==2'b11)}} & ex2lsu_rs2[7:0]};
    assign ex2lsu_wdata[23:16] = ({8{wmask_4}} & ex2lsu_rs2[23:16]) | ({8{wmask_2}} & {8{(ex2lsu_addr[1:0]==2'b10) ? 1'b1 : 1'b0}} & ex2lsu_rs2[7:0])
                            | {{8{wmask_1}} & {8{(ex2lsu_addr[1:0]==2'b10)}} & ex2lsu_rs2[7:0]};
    assign ex2lsu_wdata[15:8] = ({8{wmask_4}} & ex2lsu_rs2[15:8]) | ({8{wmask_2}} & {8{(ex2lsu_addr[1:0]==2'b00) ? 1'b1 : 1'b0}} & ex2lsu_rs2[15:8])
                            | {{8{wmask_1}} & {8{(ex2lsu_addr[1:0]==2'b01)}} & ex2lsu_rs2[7:0]};
    assign ex2lsu_wdata[7:0] = ({8{wmask_4}} & ex2lsu_rs2[7:0]) | ({8{wmask_2}} & {8{(ex2lsu_addr[1:0]==2'b00) ? 1'b1 : 1'b0}} & ex2lsu_rs2[7:0])
                            | {{8{wmask_1}} & {8{(ex2lsu_addr[1:0]==2'b00)}} & ex2lsu_rs2[7:0]};
`endif

    wire [2:0] nice2lsu_offset = nice2lsu_addr[2:0];

    //*******************************mux_in*********************************************
    wire mux_in_vld;
    wire mux_in_rdy;
    wire mux_in_read;   // 指令地址
    wire [`MYRISCV_ADDRBUS] mux_in_addr;       // 通用寄存器1输入数据
    wire [`MYRISCV_REGBUS] mux_in_wdata;       // 通用寄存器2输入数据
    // wire  [3:0] mux_in_wmask;
    wire [(`MYRISCV_XLEN/8-1) : 0] mux_in_wmask;
    wire [1:0] mux_in_size; 
    wire [2:0] mux_in_offset;
    wire mux_in_unsign;
    wire [`MYRISCV_REGADDRBUS] mux_in_rdidx;
    wire mux_in_ret;
    //r: nice has higher proprity.
    wire [`LSU_SELECT_MUXIN_BUS] mux_in_sel = nice2lsu_vld ? `LSU_SELECT_NICE : `LSU_SELECT_EXU;

    assign mux_in_vld = (mux_in_sel==`LSU_SELECT_NICE) ? nice2lsu_vld : ex2lsu_vld;
    assign mux_in_read = (mux_in_sel==`LSU_SELECT_NICE) ? nice2lsu_read : ex2lsu_read;
    // assign mux_in_addr = (mux_in_sel==`LSU_SELECT_NICE) ? nice2lsu_addr : ex2lsu_addr;
`ifdef MYRISCV_ARCH_64
    assign mux_in_addr  = (mux_in_sel == `LSU_SELECT_NICE) ? {nice2lsu_addr[`MYRISCV_ADDRDW-1:3], 3'b000} : {ex2lsu_addr[`MYRISCV_ADDRDW-1:3], 3'b000};
`else
    assign mux_in_addr  = (mux_in_sel == `LSU_SELECT_NICE) ? {nice2lsu_addr[`MYRISCV_ADDRDW-1:2], 2'b00} : {ex2lsu_addr[`MYRISCV_ADDRDW-1:2], 2'b00};
`endif
    assign mux_in_wdata = (mux_in_sel==`LSU_SELECT_NICE) ? nice2lsu_wdata : ex2lsu_wdata;
    assign mux_in_wmask = (mux_in_sel==`LSU_SELECT_NICE) ? nice2lsu_wmask : ex2lsu_wmask;
    assign mux_in_size = (mux_in_sel==`LSU_SELECT_NICE) ? nice2lsu_size : ex2lsu_size;
    assign mux_in_offset = (mux_in_sel==`LSU_SELECT_NICE) ? nice2lsu_offset : ex2lsu_offset;
    assign mux_in_unsign = (mux_in_sel==`LSU_SELECT_NICE) ? nice2lsu_unsign : ex2lsu_unsign;
    assign mux_in_rdidx = (mux_in_sel==`LSU_SELECT_NICE) ? nice2lsu_rdidx : ex2lsu_rdidx;
    assign mux_in_ret = (mux_in_sel == `LSU_SELECT_NICE) ? nice2lsu_ret : 1'b0;
    assign nice2lsu_rdy = (mux_in_sel == `LSU_SELECT_NICE) ? mux_in_rdy : 1'b0;
    assign ex2lsu_rdy = (mux_in_sel == `LSU_SELECT_EXU) ? mux_in_rdy : 1'b0;

    reg mux_o_vld;
    wire mux_o_rdy;
    reg mux_o_read;   // 指令地址
    reg [`MYRISCV_ADDRBUS] mux_o_addr;       // 通用寄存器1输入数据
    reg [`MYRISCV_REGBUS] mux_o_wdata;       // 通用寄存器2输入数据
    // reg  [3:0] mux_o_wmask;
    reg [(`MYRISCV_DATADW/8-1) : 0] mux_o_wmask;
    reg [1:0] mux_o_size;
    reg [2:0] mux_o_offset;
    reg mux_o_unsign;
    reg [`MYRISCV_REGADDRBUS] mux_o_rdidx;
    reg [`LSU_SELECT_MUXIN_BUS] mux_o_sel;
    reg mux_o_ret; //返回到reg还是nice


    wire loopcut_vld;
    wire loopcut_rdy;
    wire loopcut_read;   // 指令地址
    wire [`MYRISCV_ADDRBUS] loopcut_addr;       // 通用寄存器1输入数据
    wire [`MYRISCV_REGBUS] loopcut_wdata;       // 通用寄存器2输入数据
    wire [(`MYRISCV_DATADW/8-1) : 0] loopcut_wmask;
    wire [1:0] loopcut_size;
    wire [2:0] loopcut_offset;
    wire loopcut_unsign;
    wire [`MYRISCV_REGADDRBUS] loopcut_rdidx;
    wire [`LSU_SELECT_MUXIN_BUS] loopcut_sel;
    wire loopcut_ret; //返回到reg还是nice

    myloopcut #(
        .DW(1
            +`MYRISCV_ADDRDW
            +`MYRISCV_REGWD
            +(`MYRISCV_DATADW/8) 
            +2 
            +3 
            +1 
            +`MYRISCV_REGADDRWD 
            +`LSU_SELECT_MUXIN_WD
            +1
            ),
        .NAME("myloopcut")
    )loopcut_lsu(
        .clk        (clk),
        .rst        (rst),

        .i_vld      (mux_in_vld),
        .i_rdy      (mux_in_rdy),
        .data_i     ({
            mux_in_read,   // 指令地址
            mux_in_addr,       // 通用寄存器1输入数据
            mux_in_wdata,       // 通用寄存器2输入数据
            mux_in_wmask,
            mux_in_size,
            mux_in_offset,
            mux_in_unsign,
            mux_in_rdidx,
            mux_in_sel,
            mux_in_ret //返回到reg还是nice
        }),

        .o_vld      (loopcut_vld),
        .o_rdy      (loopcut_rdy),
        .data_o     ({
            loopcut_read,   // 指令地址
            loopcut_addr,       // 通用寄存器1输入数据
            loopcut_wdata,       // 通用寄存器2输入数据
            loopcut_wmask,
            loopcut_size,
            loopcut_offset,
            loopcut_unsign,
            loopcut_rdidx,
            loopcut_sel,
            loopcut_ret //返回到reg还是nice
        })
    );

    assign loopcut_rdy = mux_o_rdy | (~mux_o_vld);
    always@(posedge clk) begin
        if(rst == `RSTLEVEL) begin
            mux_o_vld <= 0;
        end
        else if(loopcut_rdy) begin
            mux_o_vld <= loopcut_vld;
        end
    end

    always@(posedge clk) begin
        if(rst == `RSTLEVEL) begin
            mux_o_read <= 1'b1;
            mux_o_addr <= 0;
            mux_o_wdata <= 0;
            mux_o_wmask <= 0;
            mux_o_rdidx <= 0;
            mux_o_unsign <= 0;
            mux_o_size <= 0;
            mux_o_offset <= 0;
            mux_o_sel <= 0;
            mux_o_ret <= 0;
        end
        else if(loopcut_rdy & loopcut_vld) begin
            mux_o_read <= loopcut_read;
            mux_o_addr <= loopcut_addr;
            mux_o_wdata <= loopcut_wdata;
            mux_o_wmask <= loopcut_wmask;
            mux_o_rdidx <= loopcut_rdidx;
            mux_o_unsign <= loopcut_unsign;
            mux_o_size <= loopcut_size;
            mux_o_offset <= loopcut_offset;
            mux_o_sel <= loopcut_sel;
            mux_o_ret <= loopcut_ret;
        end
    end

    // assign mux_in_rdy = mux_o_rdy | (~mux_o_vld);
    // always@(posedge clk) begin
    //     if(rst == `RSTLEVEL) begin
    //         mux_o_vld <= 0;
    //     end
    //     else if(mux_in_rdy) begin
    //         mux_o_vld <= mux_in_vld;
    //     end
    // end

    // always@(posedge clk) begin
    //     if(rst == `RSTLEVEL) begin
    //         mux_o_read <= 1'b1;
    //         mux_o_addr <= 0;
    //         mux_o_wdata <= 0;
    //         mux_o_wmask <= 0;
    //         mux_o_rdidx <= 0;
    //         mux_o_unsign <= 0;
    //         mux_o_size <= 0;
    //         mux_o_offset <= 0;
    //         mux_o_sel <= 0;
    //         mux_o_ret <= 0;
    //     end
    //     else if(mux_in_rdy & mux_in_vld) begin
    //         mux_o_read <= mux_in_read;
    //         mux_o_addr <= mux_in_addr;
    //         mux_o_wdata <= mux_in_wdata;
    //         mux_o_wmask <= mux_in_wmask;
    //         mux_o_rdidx <= mux_in_rdidx;
    //         mux_o_unsign <= mux_in_unsign;
    //         mux_o_size <= mux_in_size;
    //         mux_o_offset <= mux_in_offset;
    //         mux_o_sel <= mux_in_sel;
    //         mux_o_ret <= mux_in_ret;
    //     end
    // end

    assign lsu_cmd_read = mux_o_read;
    assign lsu_cmd_addr = mux_o_addr;
    assign lsu_cmd_wdata = mux_o_wdata;
    assign lsu_cmd_wmask = mux_o_wmask;

    //***************************connect out(with fifo)***********************************************
    wire fifo_unfull;
    wire fifo_unempty;
 
    wire lsu_fifo_read;   // 指令地址
    wire [`MYRISCV_REGADDRBUS] lsu_fifo_rdidx;
    wire lsu_fifo_unsign;
    wire [1:0] lsu_fifo_size;
    wire [2:0] lsu_fifo_offset;
    wire [`LSU_SELECT_MUXIN_BUS] lsu_fifo_sel;
    wire lsu_fifo_ret;
`ifdef SIM_VERILATOR_MTRACE
    wire [`MYRISCV_ADDRBUS] lsu_fifo_addr;
    wire [`MYRISCV_DATADW/8-1:0] lsu_fifo_mask;
`endif

    fifo_simple # (
        .CUT_READY          (1),
        .ZEROOUT_WHENEMPTY  (0),
        .DP                 (2),
        .DW                 (1+`MYRISCV_REGADDRWD+1+2+3+1+1
`ifdef SIM_VERILATOR_MTRACE
        + `MYRISCV_ADDRDW + (`MYRISCV_DATADW/8)
`endif
        )
    ) fifo_inst (
        .clk            (clk),
        .rst            (rst),

        .w_req          (lsu_cmd_vld & lsu_cmd_rdy), 
        .unfull         (fifo_unfull), 
        .data_i         ({mux_o_read, mux_o_rdidx, mux_o_unsign, mux_o_size, mux_o_offset, mux_o_sel, mux_o_ret
`ifdef SIM_VERILATOR_MTRACE
        , mux_o_addr, mux_o_wmask
`endif        
        }),
        .unempty        (fifo_unempty), 
        .r_req          (lsu_rsp_vld & lsu_rsp_rdy),  
        .data_o         ({lsu_fifo_read, lsu_fifo_rdidx, lsu_fifo_unsign, lsu_fifo_size, lsu_fifo_offset, lsu_fifo_sel, lsu_fifo_ret
`ifdef SIM_VERILATOR_MTRACE
        , lsu_fifo_addr, lsu_fifo_mask
`endif     
        })
    );

    assign mux_o_rdy = lsu_cmd_rdy & fifo_unfull;
    assign lsu_cmd_vld = mux_o_vld & fifo_unfull;

    //****************************rsp_decode***********************************************************
    reg [`MYRISCV_REGBUS] lsu_rsp_data_res_sign;
    reg [`MYRISCV_REGBUS] lsu_rsp_data_res_unsign;

`ifdef MYRISCV_ARCH_64
    always@(*) begin
        case(lsu_fifo_size)
            2'b00:begin
                case(lsu_fifo_offset[2:0]) 
                    3'b000:begin
                        lsu_rsp_data_res_sign = {{56{lsu_rsp_rdata[7]}}, lsu_rsp_rdata[7:0]};
                        lsu_rsp_data_res_unsign = {56'd0, lsu_rsp_rdata[7:0]};
                    end
                    3'b001:begin
                        lsu_rsp_data_res_sign = {{56{lsu_rsp_rdata[15]}}, lsu_rsp_rdata[15:8]};
                        lsu_rsp_data_res_unsign = {56'd0, lsu_rsp_rdata[15:8]};
                    end
                    3'b010:begin
                        lsu_rsp_data_res_sign = {{56{lsu_rsp_rdata[23]}}, lsu_rsp_rdata[23:16]};
                        lsu_rsp_data_res_unsign = {56'd0, lsu_rsp_rdata[23:16]};
                    end
                    3'b011:begin
                        lsu_rsp_data_res_sign = {{56{lsu_rsp_rdata[31]}}, lsu_rsp_rdata[31:24]};
                        lsu_rsp_data_res_unsign = {56'd0, lsu_rsp_rdata[31:24]};
                    end
                    3'b100:begin
                        lsu_rsp_data_res_sign = {{56{lsu_rsp_rdata[39]}}, lsu_rsp_rdata[39:32]};
                        lsu_rsp_data_res_unsign = {56'd0, lsu_rsp_rdata[39:32]};
                    end
                    3'b101:begin
                        lsu_rsp_data_res_sign = {{56{lsu_rsp_rdata[47]}}, lsu_rsp_rdata[47:40]};
                        lsu_rsp_data_res_unsign = {56'd0, lsu_rsp_rdata[47:40]};
                    end
                    3'b110:begin
                        lsu_rsp_data_res_sign = {{56{lsu_rsp_rdata[55]}}, lsu_rsp_rdata[55:48]};
                        lsu_rsp_data_res_unsign = {56'd0, lsu_rsp_rdata[55:48]};
                    end
                    // 3'b111:begin
                    default:begin
                        lsu_rsp_data_res_sign = {{56{lsu_rsp_rdata[63]}}, lsu_rsp_rdata[63:56]};
                        lsu_rsp_data_res_unsign = {56'd0, lsu_rsp_rdata[63:56]};
                    end
                endcase
            end

            2'b01:begin
                case(lsu_fifo_offset[2:0]) 
                    3'b000:begin
                        lsu_rsp_data_res_sign = {{48{lsu_rsp_rdata[15]}}, lsu_rsp_rdata[15:0]};
                        lsu_rsp_data_res_unsign = {48'd0, lsu_rsp_rdata[15:0]};
                    end
                    3'b010:begin
                        lsu_rsp_data_res_sign = {{48{lsu_rsp_rdata[31]}}, lsu_rsp_rdata[31:16]};
                        lsu_rsp_data_res_unsign = {48'd0, lsu_rsp_rdata[31:16]};
                    end
                    3'b100:begin
                        lsu_rsp_data_res_sign = {{48{lsu_rsp_rdata[47]}}, lsu_rsp_rdata[47:32]};
                        lsu_rsp_data_res_unsign = {48'd0, lsu_rsp_rdata[47:32]};
                    end
                    // 3'b110:begin
                    default:begin
                        lsu_rsp_data_res_sign = {{48{lsu_rsp_rdata[63]}}, lsu_rsp_rdata[63:48]};
                        lsu_rsp_data_res_unsign = {48'd0, lsu_rsp_rdata[63:48]};
                    end
                endcase
            end

            2'b10:begin
                case(lsu_fifo_offset[2:0])
                    3'b000:begin
                        lsu_rsp_data_res_sign = {{32{lsu_rsp_rdata[31]}}, lsu_rsp_rdata[31:0]};
                        lsu_rsp_data_res_unsign = {32'd0, lsu_rsp_rdata[31:0]};
                    end
                    // 3'b100:begin
                    default:begin
                        lsu_rsp_data_res_sign = {{32{lsu_rsp_rdata[63]}}, lsu_rsp_rdata[63:32]};
                        lsu_rsp_data_res_unsign = {32'd0, lsu_rsp_rdata[63:32]};
                    end
                endcase 
            end
            default:begin
                lsu_rsp_data_res_sign = lsu_rsp_rdata;
                lsu_rsp_data_res_unsign = lsu_rsp_rdata;
            end
        endcase
    end
`else
    always@(*) begin
        case(lsu_fifo_size)
            2'b00:begin
                case(lsu_fifo_offset[1:0]) 
                    2'b00:begin
                        lsu_rsp_data_res_sign = {{24{lsu_rsp_rdata[7]}}, lsu_rsp_rdata[7:0]};
                        lsu_rsp_data_res_unsign = {24'd0, lsu_rsp_rdata[7:0]};
                    end
                    2'b01:begin
                        lsu_rsp_data_res_sign = {{24{lsu_rsp_rdata[15]}}, lsu_rsp_rdata[15:8]};
                        lsu_rsp_data_res_unsign = {24'd0, lsu_rsp_rdata[15:8]};
                    end
                    2'b10:begin
                        lsu_rsp_data_res_sign = {{24{lsu_rsp_rdata[23]}}, lsu_rsp_rdata[23:16]};
                        lsu_rsp_data_res_unsign = {24'd0, lsu_rsp_rdata[23:16]};
                    end
                    // 2'b11:begin
                    default:begin
                        lsu_rsp_data_res_sign = {{24{lsu_rsp_rdata[31]}}, lsu_rsp_rdata[31:24]};
                        lsu_rsp_data_res_unsign = {24'd0, lsu_rsp_rdata[31:24]};
                    end
                endcase
            end

            2'b01:begin
                case(lsu_fifo_offset[1:0]) 
                    2'b00:begin
                        lsu_rsp_data_res_sign = {{16{lsu_rsp_rdata[15]}}, lsu_rsp_rdata[15:0]};
                        lsu_rsp_data_res_unsign = {16'd0, lsu_rsp_rdata[15:0]};
                    end
                    // 2'b10:begin
                    default:begin
                        lsu_rsp_data_res_sign = {{16{lsu_rsp_rdata[31]}}, lsu_rsp_rdata[31:16]};
                        lsu_rsp_data_res_unsign = {16'd0, lsu_rsp_rdata[31:16]};
                    end
                endcase
            end

            default:begin
                lsu_rsp_data_res_sign = lsu_rsp_rdata;
                lsu_rsp_data_res_unsign = lsu_rsp_rdata;
            end
        endcase
    end
`endif

    // wire [`MYRISCV_REGBUS] lsu_rsp_truedata = lsu_fifo_read ? (lsu_fifo_unsign ? lsu_rsp_data_res_unsign : lsu_rsp_data_res_sign) : 32'd0;
    wire [`MYRISCV_REGBUS] lsu_rsp_truedata = lsu_fifo_unsign ? lsu_rsp_data_res_unsign : lsu_rsp_data_res_sign;

    //****************************wb_buf**********************************************************
    wire ibuf_vld_i;
    wire ibuf_rdy_i;
    reg  ibuf_vld_o;
    wire ibuf_rdy_o;
    wire [(`MYRISCV_REGWD+`MYRISCV_REGADDRWD-1):0] ibuf_data_i;
    reg  [(`MYRISCV_REGWD+`MYRISCV_REGADDRWD-1):0] ibuf_data_o;
    reg  nice_ret_o;
    assign ibuf_rdy_i = ibuf_rdy_o | (~ibuf_vld_o);
    always@(posedge clk)
    begin
        if(rst == `RSTLEVEL) begin
            ibuf_vld_o <= 0;
        end
        else if(ibuf_rdy_i) begin
            ibuf_vld_o <= ibuf_vld_i;
        end
    end

    always@(posedge clk) 
    begin
        if(rst == `RSTLEVEL) begin
            ibuf_data_o <= 0;
            nice_ret_o <= 0;
        end
        else if(ibuf_rdy_i & ibuf_vld_i) begin
            ibuf_data_o <= ibuf_data_i;
            nice_ret_o  <= lsu_fifo_ret; //r: we can see, only the read op need to ret to nice.
        end
    end

    assign ibuf_vld_i = lsu_rsp_vld & lsu_fifo_read;
    assign lsu_rsp_rdy = lsu_fifo_read ? ibuf_rdy_i : 1'b1;
    assign ibuf_data_i = {lsu_fifo_rdidx, lsu_rsp_truedata};

    assign lsu2wb_vld = ibuf_vld_o & (~nice_ret_o);
    assign lsu2nice_vld = ibuf_vld_o & (nice_ret_o);
    assign ibuf_rdy_o = nice_ret_o ? lsu2nice_rdy : lsu2wb_rdy;
    assign lsu2nice_rdidx = ibuf_data_o[`MYRISCV_REGADDRWD + `MYRISCV_REGWD-1 : `MYRISCV_REGWD];//可以使用，也可以不用。
    assign lsu2nice_wdata = ibuf_data_o[`MYRISCV_REGBUS];
    assign lsu2wb_rdidx = ibuf_data_o[`MYRISCV_REGWD + `MYRISCV_REGADDRWD-1 : `MYRISCV_REGWD];
    assign lsu2wb_wdata = ibuf_data_o[`MYRISCV_REGBUS];

`ifdef SIM_VERILATOR_MTRACE  //r: wr
`ifdef USE_DPIC
    import "DPI-C" function void WrLog(input bit [`MYRISCV_ADDRBUS] lsu_wop_addr, input bit [`MYRISCV_DATABUS] lsu_wop_data, 
        input bit [`MYRISCV_DATADW/8-1 : 0] lsu_wop_wmask);
    always @(posedge clk) begin
        if((lsu_cmd_vld & lsu_cmd_rdy) & (rst != `RSTLEVEL) & (lsu_cmd_read == 1'b0)) begin
            WrLog(lsu_cmd_addr, lsu_cmd_wdata, lsu_cmd_wmask);
        end
    end
`endif
`endif


`ifdef SIM_VERILATOR_MTRACE  //r: rd
`ifdef USE_DPIC
    import "DPI-C" function void RdLog(input bit [`MYRISCV_ADDRBUS] lsu_rop_addr, input bit [`MYRISCV_DATABUS] lsu_rop_data, 
        input bit [`MYRISCV_DATADW/8-1 : 0] lsu_rop_rmask);

    // bit lsu_rop_ok;
    // bit [`MYRISCV_ADDRBUS] lsu_rop_addr;
    // bit [`MYRISCV_DATABUS] lsu_rop_truedata;
    // bit [`MYRISCV_DATADW/8-1 : 0] lsu_rop_mask;
    always @(posedge clk) begin
        if((lsu_rsp_vld & lsu_rsp_rdy) & (rst != `RSTLEVEL) & (lsu_fifo_read)) begin
            // lsu_rop_ok <= 1;
            // lsu_rop_addr <= lsu_fifo_addr;
            // lsu_rop_truedata <= lsu_rsp_truedata;
            // lsu_rop_mask <= lsu_fifo_mask;
            RdLog(lsu_fifo_addr, lsu_rsp_truedata, lsu_fifo_mask);
        end
        // else begin
        //     lsu_rop_ok <= 1'b0;
        // end
    end 

    // export "DPI-C" function getLsuRdInfo;
    // function void getLsuRdInfo;
    //     output bit [`MYRISCV_ADDRBUS] addr_o;
    //     output bit [`MYRISCV_DATABUS] data_o;
    //     output bit [`MYRISCV_DATADW/8-1 : 0] rmask_o;
    // begin
    //     addr_o = lsu_rop_addr;
    //     data_o = lsu_rop_truedata;
    //     rmask_o = lsu_rop_mask;
    // end
    // endfunction

    // export "DPI-C" function checkRd;
    // function bit checkRd;
    // begin
    //     checkRd = lsu_rop_ok;
    // end
    // endfunction
`endif
`endif



endmodule
