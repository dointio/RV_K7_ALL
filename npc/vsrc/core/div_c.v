`include "mydefines.v"
`include "e203_defines.v"
module div_c(
    clk,
    rst,
    // from id
    disp2div_vld,
    disp2div_rdy,
    // input wire[`MYRISCV_INSTBUS] dec2ex_instr,            // 指令内容
    dec2ex_pc,   // 指令地址
    dec2ex_rs1_idx,
    dec2ex_rs2_idx,
    dec2ex_rs1,       // 通用寄存器1输入数据
    dec2ex_rs2,       // 通用寄存器2输入数据
    dec2ex_rdwen,                    // 是否写通用寄存器
    dec2ex_rdidx,    // 写通用寄存器地址
    dec2ex_info,

    // to regs
    div2wb_vld,                   // 是否写通用寄存器
    div2wb_rdy,
    div2wb_data,       // 写寄存器数据
    div2wb_rdidx   // 写通用寄存器地址
);
    
    input wire clk, rst;
    input wire disp2div_vld;
    output wire disp2div_rdy;
// input wire[`MYRISCV_INSTBUS] dec2ex_instr;            // 指令内容
    input wire[`MYRISCV_ADDRBUS] dec2ex_pc;   // 指令地址
    input wire [`MYRISCV_REGADDRBUS] dec2ex_rs1_idx;
    input wire [`MYRISCV_REGADDRBUS] dec2ex_rs2_idx;
    input wire  [`MYRISCV_REGBUS] dec2ex_rs1;       // 通用寄存器1输入数据
    input wire  [`MYRISCV_REGBUS] dec2ex_rs2;       // 通用寄存器2输入数据
    input wire  dec2ex_rdwen;                    // 是否写通用寄存器
    input wire  [`MYRISCV_REGADDRBUS] dec2ex_rdidx;    // 写通用寄存器地址
    input wire  [`MY_DECINFO_WIDTH-1 : 0] dec2ex_info;

    // to regs
    output wire div2wb_vld;                   // 是否写通用寄存器
    input wire div2wb_rdy;
    output wire [`MYRISCV_REGBUS] div2wb_data;// 写寄存器数据
    output wire[`MYRISCV_REGADDRBUS] div2wb_rdidx;   // 写通用寄存器地址

    wire [`MYRISCV_XLEN-1 : 0] op1 = dec2ex_rs1;
    wire [`MYRISCV_XLEN-1 : 0] op2 = dec2ex_rs2;

    reg [2:0] optype;
    
    always@(*) begin
        case(1'b1) 
            dec2ex_info[`MY_DECINFO_MULDIV_MUL]: begin
                optype = 3'b000;
            end
            dec2ex_info[`MY_DECINFO_MULDIV_MULH]: begin
                optype = 3'b001;
            end
            dec2ex_info[`MY_DECINFO_MULDIV_MULHSU]: begin
                optype = 3'b010;
            end
            dec2ex_info[`MY_DECINFO_MULDIV_MULHU]: begin
                optype = 3'b011;
            end
            dec2ex_info[`MY_DECINFO_MULDIV_DIV]: begin
                optype = 3'b100;
            end
            dec2ex_info[`MY_DECINFO_MULDIV_DIVU]: begin
                optype = 3'b101;
            end
            dec2ex_info[`MY_DECINFO_MULDIV_REM]: begin
                optype = 3'b110;
            end
            dec2ex_info[`MY_DECINFO_MULDIV_REMU]: begin
                optype = 3'b111;
            end
            default:begin
                optype = 3'b000;
            end
        endcase
    end

    wire [`MYRISCV_XLEN-1 : 0] result;
`ifdef USE_DPIC
    import "DPI-C" function void MULDIV(input bit[2:0] op_type, input bit [`MYRISCV_XLEN-1 : 0] op_1, 
        input bit [`MYRISCV_XLEN-1 : 0] op_2, output bit [`MYRISCV_XLEN-1 : 0] res);
    
    always@(optype, op1, op2) begin
        if(disp2div_vld) begin
            MULDIV(optype, op1, op2, result);
        end
    end
`else
    assign result = 0;
    initial begin
        $display("Error! Use div_c, but not open USE_DPIC!!");
        $finish;
    end
`endif
    
    assign disp2div_rdy = (disp2div_vld & dec2ex_rdwen) ? div2wb_rdy : 1'b1;
    assign div2wb_vld = disp2div_vld & dec2ex_rdwen;
    assign div2wb_rdidx = dec2ex_rdidx;
    assign div2wb_data = 
    `ifdef MYRISCV_ARCH_64
        dec2ex_info[`MY_DECINFO_MULDIV_RESW] ? {{32{result[31]}}, result[31:0]} :
    `endif
        result[`MYRISCV_XLEN-1 : 0];

endmodule
