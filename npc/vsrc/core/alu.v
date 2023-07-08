// 执行模块
// 纯组合逻辑电路
`include "mydefines.v"
`include "e203_defines.v"
module alu(
    // from id
    disp2alu_vld,
    disp2alu_rdy,
    // input wire[`MYRISCV_INSTBUS] dec2ex_instr,            // 指令内容
    dec2ex_pc,   // 指令地址
    dec2ex_rs1_idx,
    dec2ex_rs2_idx,
    dec2ex_rs1,       // 通用寄存器1输入数据
    dec2ex_rs2,       // 通用寄存器2输入数据
    dec2ex_imm,
    dec2ex_rdwen,   // 是否写通用寄存器
    dec2ex_rdidx,    // 写通用寄存器地址
    dec2ex_info,

    // to regs
    alu2wb_vld,                   // 是否写通用寄存器
    alu2wb_rdy,
    alu2wb_data,       // 写寄存器数据
    alu2wb_rdidx,   // 写通用寄存器地址

    //to csrregs
    csr_ena,
    csr_wr_en,
    csr_rd_en,
    csr_idx,
    read_csr_dat,
    wbck_csr_dat,

    //
    alu_ecall_o,
    alu_ebreak_o,
    exu_bjp_mret,
    exu_bjp_taken,
    exu_bjp_prdt_taken,
    exu_bjp_pc,
    exu_bjp_jaddr
    );



//**************************************port********************************************
    // from id
    input wire disp2alu_vld;
    output wire disp2alu_rdy;
    // input wire[`MYRISCV_INSTBUS] dec2ex_instr;            // 指令内容
    input wire[`MYRISCV_ADDRBUS] dec2ex_pc;   // 指令地址
    input wire [`MYRISCV_REGADDRBUS] dec2ex_rs1_idx;
    input wire [`MYRISCV_REGADDRBUS] dec2ex_rs2_idx;
    input wire  [`MYRISCV_REGBUS] dec2ex_rs1;       // 通用寄存器1输入数据
    input wire  [`MYRISCV_REGBUS] dec2ex_rs2;       // 通用寄存器2输入数据
    input wire  [`MYRISCV_REGBUS] dec2ex_imm;
    input wire  dec2ex_rdwen;                    // 是否写通用寄存器
    input wire  [`MYRISCV_REGADDRBUS] dec2ex_rdidx;    // 写通用寄存器地址
    input wire  [`MY_DECINFO_WIDTH-1 : 0] dec2ex_info;

    // to regs
    output wire alu2wb_vld;                   // 是否写通用寄存器
    input wire alu2wb_rdy;
    output wire [`MYRISCV_REGBUS] alu2wb_data;// 写寄存器数据
    output wire[`MYRISCV_REGADDRBUS] alu2wb_rdidx;   // 写通用寄存器地址

    //to csrregs
    output csr_ena;
    output csr_wr_en;
    output csr_rd_en;
    output [12-1:0] csr_idx;
    input [`MYRISCV_REGBUS] read_csr_dat;
    output  [`MYRISCV_REGBUS] wbck_csr_dat;

    // output wire hold_flag_o;             // 是否暂停标志
    // output reg jump_flag_o;                // 是否跳转标志
    // output reg[`MYRISCV_ADDRBUS] jump_addr_o   // 跳转目的地址

    output wire alu_ecall_o;
    output wire alu_ebreak_o;

    output wire exu_bjp_mret;
    output reg exu_bjp_taken;
    output exu_bjp_prdt_taken;
    output [`MYRISCV_ADDRBUS] exu_bjp_pc;
    output [`MYRISCV_ADDRBUS] exu_bjp_jaddr;
//****************************************************************************************

    assign disp2alu_rdy = (disp2alu_vld & dec2ex_rdwen) ? alu2wb_rdy : 1'b1;
    assign alu2wb_vld = disp2alu_vld & dec2ex_rdwen;
    assign alu2wb_rdidx = dec2ex_rdidx;

    assign exu_bjp_pc = dec2ex_pc;
    // assign exu_bjp_prdt_taken

    reg [`MYRISCV_REGBUS] op1;
    reg [`MYRISCV_REGBUS] op2;
    reg [`MYRISCV_REGBUS] bjp_op1;
    reg [`MYRISCV_REGBUS] bjp_op2;

    wire [`MYRISCV_REGBUS] bjp_op1_add_bjp_op2_res = bjp_op1 + bjp_op2;
    wire [`MYRISCV_REGBUS] op1_add_op2_res = op1 + op2;
    wire [`MYRISCV_REGBUS] op1_sub_op2_res = op1 - op2;
    // assign op1_jump_add_op2_jump_res = dec2ex_op1_jump + dec2ex_op2_jump;

    // wire reg1_data_invert = ~op1 + 1;
    // wire reg2_data_invert = ~op2 + 1;

    // 有符号数比较
    wire op1_ge_op2_signed = $signed(op1) >= $signed(op2);
    // 无符号数比较
    wire op1_ge_op2_unsigned = op1 >= op2;
    wire op1_eq_op2 = (op1 == op2);

    assign exu_bjp_mret = ((dec2ex_info[`MY_DECINFO_GRP] == `MY_DECINFO_GRP_BJP) & dec2ex_info[`MY_DECINFO_BJP_MRET] & disp2alu_vld) ?
                            1'b1 : 1'b0;
    assign exu_bjp_prdt_taken = ((dec2ex_info[`MY_DECINFO_GRP] == `MY_DECINFO_GRP_BJP) & disp2alu_vld)? 
                dec2ex_info[`MY_DECINFO_BJP_BPRDT] : 1'b0;
    assign exu_bjp_jaddr = bjp_op1_add_bjp_op2_res;
    // output csr_ena,
    // output csr_wr_en,
    // output csr_rd_en,
    // output [12-1:0] csr_idx,
    // input [`MYRISCV_REGBUS] read_csr_dat,
    // output  [`MYRISCV_REGBUS] wbck_csr_dat,

    assign csr_ena = (dec2ex_info[`MY_DECINFO_GRP] == `MY_DECINFO_GRP_CSR) & disp2alu_vld;
    assign csr_wr_en = (dec2ex_info[`MY_DECINFO_GRP] == `MY_DECINFO_GRP_CSR) & disp2alu_vld;
    assign csr_rd_en = (dec2ex_info[`MY_DECINFO_GRP] == `MY_DECINFO_GRP_CSR) & disp2alu_vld;
    assign csr_idx = dec2ex_info[`MY_DECINFO_CSR_CSRIDX];
    wire [`MYRISCV_REGBUS] csr_rc = (dec2ex_info[`MY_DECINFO_CSR_CSRRC]
                                    & (~dec2ex_info[`MY_DECINFO_CSR_RS1IMM])) ?
                                    (read_csr_dat & (~dec2ex_rs1)) : {`MYRISCV_XLEN{1'b0}};
    wire [`MYRISCV_REGBUS] csr_rci = (dec2ex_info[`MY_DECINFO_CSR_CSRRC]
                                    & dec2ex_info[`MY_DECINFO_CSR_RS1IMM]) ?
                                    (read_csr_dat & (~{{(`MYRISCV_XLEN-32+27){1'b0}},dec2ex_rs1_idx})) : {`MYRISCV_XLEN{1'b0}};
    wire [`MYRISCV_REGBUS] csr_rs = (dec2ex_info[`MY_DECINFO_CSR_CSRRS]
                                & (~dec2ex_info[`MY_DECINFO_CSR_RS1IMM])) ?
                                (read_csr_dat | (dec2ex_rs1)) : {`MYRISCV_XLEN{1'b0}};
    wire [`MYRISCV_REGBUS] csr_rsi = (dec2ex_info[`MY_DECINFO_CSR_CSRRS]
                                & dec2ex_info[`MY_DECINFO_CSR_RS1IMM]) ?
                                (read_csr_dat | {{(`MYRISCV_XLEN-32+27){1'b0}},dec2ex_rs1_idx}) : {`MYRISCV_XLEN{1'b0}};
    wire [`MYRISCV_REGBUS] csr_rw = (dec2ex_info[`MY_DECINFO_CSR_CSRRW]
                                & (~dec2ex_info[`MY_DECINFO_CSR_RS1IMM])) ?
                                dec2ex_rs1 : {`MYRISCV_XLEN{1'b0}};
    wire [`MYRISCV_REGBUS] csr_rwi = (dec2ex_info[`MY_DECINFO_CSR_CSRRW]
                                & dec2ex_info[`MY_DECINFO_CSR_RS1IMM]) ?
                                {{(`MYRISCV_XLEN-32+27){1'b0}},dec2ex_rs1_idx} : {`MYRISCV_XLEN{1'b0}};

    assign wbck_csr_dat = csr_rc | csr_rci | csr_rs | csr_rsi | csr_rw | csr_rwi;

    reg[`MYRISCV_REGBUS] alu_wbdata;
`ifdef MYRISCV_ARCH_64
    assign alu2wb_data = (dec2ex_info[`MY_DECINFO_ALU_RESW] == 1'b1) ? {{32{alu_wbdata[31]}}, alu_wbdata[31:0]} : alu_wbdata;
`else
    assign alu2wb_data = alu_wbdata;
`endif

    //r: for ecall and ebreak;
    assign alu_ecall_o = disp2alu_vld & 
        (dec2ex_info[`MY_DECINFO_GRP] == `MY_DECINFO_GRP_ALU)
        & (dec2ex_info[`MY_DECINFO_ALU_ECAL]);
    assign alu_ebreak_o = disp2alu_vld & 
        (dec2ex_info[`MY_DECINFO_GRP] == `MY_DECINFO_GRP_ALU)
        & (dec2ex_info[`MY_DECINFO_ALU_EBRK]);
    
    // 执行
    always @(*) begin
        if(disp2alu_vld) begin
            case (dec2ex_info[`MY_DECINFO_GRP])
                `MY_DECINFO_GRP_ALU : begin 
                    op1 = dec2ex_info[`MY_DECINFO_ALU_OP1PC] ?
                                    dec2ex_pc : dec2ex_rs1;
                    op2 = dec2ex_info[`MY_DECINFO_ALU_OP2IMM] ? 
                            dec2ex_imm : dec2ex_rs2;
                    bjp_op1 = 0;
                    bjp_op2 = 0;
                end

                `MY_DECINFO_GRP_BJP : begin
                    op1 = dec2ex_rs1;
                    op2 = dec2ex_rs2;
                    bjp_op1 = dec2ex_info[`MY_DECINFO_BJP_JALR] ? 
                            dec2ex_rs1 : dec2ex_pc;
                    bjp_op2 = /*exu_bjp_prdt_taken ? 4 : */dec2ex_imm;
                end

                `MY_DECINFO_GRP_CSR : begin
                    op1 = 0;
                    op2 = 0;
                    bjp_op1 = 0;
                    bjp_op2 = 0;
                end

                default: begin
                    op1 = 0;
                    op2 = 0;
                    bjp_op1 = 0;
                    bjp_op2 = 0;
                end
            endcase
        end
        else begin
            op1 = 0;
            op2 = 0;
            bjp_op1 = 0;
            bjp_op2 = 0;
        end
    end

    always @ (*) begin
        if(disp2alu_vld) begin
            case (dec2ex_info[`MY_DECINFO_GRP])
                `MY_DECINFO_GRP_ALU : begin 
                   
                    exu_bjp_taken = 1'b0; 
                    // exu_bjp_jaddr = 32'd0;
                    case(1'b1)
                        dec2ex_info[`MY_DECINFO_ALU_ADD] : begin
                            alu_wbdata = op1_add_op2_res;
                        end
                        dec2ex_info[`MY_DECINFO_ALU_SUB] : begin
                            alu_wbdata = op1_sub_op2_res;
                        end
                        dec2ex_info[`MY_DECINFO_ALU_SLT] : begin
                            alu_wbdata = op1_ge_op2_signed ? 
                                    // 32'h0 : 32'h1;
                                    {`MYRISCV_REGWD{1'b0}} : {{(`MYRISCV_REGWD-1){1'b0}}, 1'b1};
                        end
                        dec2ex_info[`MY_DECINFO_ALU_SLTU] : begin
                            alu_wbdata = op1_ge_op2_unsigned ? 
                                    // 32'h0 : 32'h1;
                                    {`MYRISCV_REGWD{1'b0}} : {{(`MYRISCV_REGWD-1){1'b0}}, 1'b1};
                        end
                        dec2ex_info[`MY_DECINFO_ALU_XOR] : begin
                            alu_wbdata = op1 ^ op2;
                        end
                        dec2ex_info[`MY_DECINFO_ALU_SLL] : begin
                    `ifdef MYRISCV_ARCH_64
                            if(dec2ex_info[`MY_DECINFO_ALU_RESW])begin
                                alu_wbdata = {{(`MYRISCV_XLEN-32){1'b0}}, op1[31:0]} << op2;
                            end
                            else begin
                    `endif
                                alu_wbdata = op1 << op2;
                    `ifdef MYRISCV_ARCH_64
                            end
                    `endif
                                    // {op1[`MYRISCV_REGWD-op2-1 : op2], op2{1'b0}};
                        end
                        dec2ex_info[`MY_DECINFO_ALU_SRL] : begin
                    `ifdef MYRISCV_ARCH_64
                            if(dec2ex_info[`MY_DECINFO_ALU_RESW])begin
                                alu_wbdata = {{(`MYRISCV_XLEN-32){1'b0}}, op1[31:0]} >> op2;
                            end
                            else begin
                    `endif
                                alu_wbdata = op1 >> op2;
                    `ifdef MYRISCV_ARCH_64
                            end
                    `endif
                                    // {op2{1'b0}, op1[`MYRISCV_REGWD-1 : op2]};
                        end
                        dec2ex_info[`MY_DECINFO_ALU_SRA] : begin
                    `ifdef MYRISCV_ARCH_64
                            if(dec2ex_info[`MY_DECINFO_ALU_RESW])begin
                                alu_wbdata = ({{(`MYRISCV_XLEN-32){1'b0}}, op1[31:0]} >> op2) |
                                    (op1[31] ? (~({
                                        // (`MYRISCV_XLEN){1'b1}
                                        32'd0, {32{1'b1}}
                                    } >> op2)) : {`MYRISCV_XLEN{1'b0}});
                            end
                            else begin
                    `endif
                                alu_wbdata = (op1 >> op2) |
                                    (op1[`MYRISCV_XLEN-1] ? (~({(`MYRISCV_XLEN){1'b1}} >> op2)) : {`MYRISCV_XLEN{1'b0}});
                    `ifdef MYRISCV_ARCH_64
                            end
                    `endif
                        end
                        dec2ex_info[`MY_DECINFO_ALU_OR] : begin 
                            alu_wbdata = op1 | op2;
                        end
                        dec2ex_info[`MY_DECINFO_ALU_AND] : begin
                            alu_wbdata = op1 & op2;
                        end
                        dec2ex_info[`MY_DECINFO_ALU_LUI] : begin
                            alu_wbdata = op2;
                        end
                        dec2ex_info[`MY_DECINFO_ALU_NOP] : begin
                            alu_wbdata = 0;
                        end
                        dec2ex_info[`MY_DECINFO_ALU_ECAL] : begin

                            alu_wbdata = 0;
                        end
                        dec2ex_info[`MY_DECINFO_ALU_EBRK] : begin

                            alu_wbdata = 0;
                        end
                        dec2ex_info[`MY_DECINFO_ALU_WFI] : begin
                            $display("WFI instr! not implement, equal to nop!");
                            alu_wbdata = 0;
                        end
                        default : begin
                            alu_wbdata = 0;
                        end
                    endcase
                end

                `MY_DECINFO_GRP_BJP : begin
                   
                    alu_wbdata = dec2ex_pc + 4;
                    case(1'b1) 
                        dec2ex_info[`MY_DECINFO_BJP_JAL] : begin
                            exu_bjp_taken = 1;
                        end
                        dec2ex_info[`MY_DECINFO_BJP_JALR] : begin
                            exu_bjp_taken = 1;
                        end
                        dec2ex_info[`MY_DECINFO_BJP_BEQ] : begin
                            exu_bjp_taken = op1_eq_op2/* ^ exu_bjp_prdt_taken*/;
                        end
                        dec2ex_info[`MY_DECINFO_BJP_BNE] : begin
                            exu_bjp_taken = (~op1_eq_op2) /*^ exu_bjp_prdt_taken*/;
                        end
                        dec2ex_info[`MY_DECINFO_BJP_BLT] : begin
                            exu_bjp_taken = (~op1_ge_op2_signed) /*^ exu_bjp_prdt_taken*/;
                        end
                        dec2ex_info[`MY_DECINFO_BJP_BGT] : begin
                            exu_bjp_taken = op1_ge_op2_signed/* ^ exu_bjp_prdt_taken*/;
                        end
                        dec2ex_info[`MY_DECINFO_BJP_BLTU] : begin
                            exu_bjp_taken = (~op1_ge_op2_unsigned) /*^ exu_bjp_prdt_taken*/;
                        end
                        dec2ex_info[`MY_DECINFO_BJP_BGTU] : begin
                            exu_bjp_taken = op1_ge_op2_unsigned /*^ exu_bjp_prdt_taken*/;
                        end
                        default:begin
                            exu_bjp_taken = 0;
                        end
                    endcase
                end

                `MY_DECINFO_GRP_CSR : begin
                    exu_bjp_taken = 1'b0;
                    // exu_bjp_jaddr = 32'd0;
                    alu_wbdata = read_csr_dat;
                   
                end

                default: begin
                    exu_bjp_taken = 1'b0;
                    // exu_bjp_jaddr = 32'd0;
                    alu_wbdata = 64'd0;
        
                end
            endcase
        end
        else begin
            exu_bjp_taken = 1'b0;
            // exu_bjp_jaddr = 32'd0;
            alu_wbdata = 64'd0;
           
        end
    end

endmodule
