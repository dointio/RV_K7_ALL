`include "mydefines.v"


// PC寄存器模块
module pc(
    input wire clk,
    input wire rst,

    input wire jump_flag_i,                 // 跳转标志
    input wire[`MYRISCV_ADDRBUS] jump_addr_i,   // 跳转地址

    input bpu_prdt_taken,
    input [`MYRISCV_ADDRBUS] bpu_jump_op1,
    input [`MYRISCV_ADDRBUS] bpu_jump_op2,

    output wire pc_has_jump_o,
    output wire [`MYRISCV_ADDRBUS] pc_o,
    input wire dec_rdy,

    output wire [`MYRISCV_ADDRBUS] instr_req_pc,
    output wire instr_req_vld,
    input wire instr_req_rdy

);

//pc create 
reg [`MYRISCV_ADDRBUS] pc_r;
assign pc_o = pc_r;
wire instr_req_handshake = instr_req_vld & instr_req_rdy;
//
wire [`MYRISCV_ADDRBUS] pc_nxt_op1 =    jump_flag_i ? jump_addr_i : (
                                            (bpu_prdt_taken & ~pc_has_jump_o) ? bpu_jump_op1 : pc_r
                                            );
wire [`MYRISCV_ADDRBUS] pc_nxt_op2 =    jump_flag_i ? -4 : (
                                            (bpu_prdt_taken & ~pc_has_jump_o) ? bpu_jump_op2 : 
                                    `ifdef MYRISCV_ARCH_64
                                            {{(`MYRISCV_ADDRDW-3){1'b0}}, 3'd4}
                                    `else
                                            {{(`MYRISCV_ADDRDW-3){1'b0}}, 3'd4}
                                    `endif
                                            );
wire [`MYRISCV_ADDRBUS] pc_nxt = pc_nxt_op1 + pc_nxt_op2;

// sirv_gnrl_dfflr #(1) jump_dff (instr_req_handshake || jump_flag_i, jump_flag_i, pc_has_jump_o, clk, rst);
reg_enrs #(1, 0, "pcjmpdff") jmp_dff (clk, rst, instr_req_handshake || jump_flag_i, jump_flag_i, pc_has_jump_o);

assign instr_req_vld = 1 & (~jump_flag_i) & (dec_rdy);
always@(posedge clk) begin
    if(rst == `RSTLEVEL) begin
        pc_r <= `RISCV_STVEC-64'h4;
    end
    else if(instr_req_handshake || jump_flag_i) begin
        pc_r <= pc_nxt;
    end
end

assign instr_req_pc = pc_nxt;

endmodule
