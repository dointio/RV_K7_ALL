`include "mydefines.v"
module oitf_fifo
(
    clk,
    rst,

    // instr_rdidx,
    is_long_instr,
    instr_vld,

    rs1_idx,
    rs2_idx,
    rdidx,

    dec2oitf_hold,
    // cur_w_index,
    clr_req,
    clr_idx
);

input clk, rst;
input is_long_instr;
input instr_vld;
// input [`MYRISCV_REGADDRBUS] instr_rdidx;

input [`MYRISCV_REGADDRBUS] rs1_idx;
input [`MYRISCV_REGADDRBUS] rs2_idx;
input [`MYRISCV_REGADDRBUS] rdidx;

output dec2oitf_hold;
// output [`MYRISCV_REGADDRBUS] cur_w_index;
input clr_req;
input[`MYRISCV_REGADDRBUS] clr_idx;

reg [`OitfSizeWD-1+1 : 0] idx_cnt;

wire [`OitfSize-1 : 0] idxdff_en;
wire [`OitfSize-1 : 0] idxdff_wd;
wire [`OitfSize-1 : 0] idxdff_clr;
wire [`OitfSize-1 : 0] idxdff_clr_shr;
wire [`MYRISCV_REGADDRWD : 0] idxdff_i [0 : `OitfSize-1];
wire [`MYRISCV_REGADDRWD : 0] idxdff_o [0 : `OitfSize-1+1];
assign idxdff_o[`OitfSize] = {(`MYRISCV_REGADDRWD+1){1'b0}};
wire [`OitfSize-1 : 0] idx_conflict;

wire check_conflict = (idx_conflict != {`OitfSize{1'b0}});
wire ins_insert = is_long_instr & (~check_conflict) & instr_vld;
wire w_and_clr = ins_insert & clr_req;

//-->0-->1-->2-->3...
//-->3-->2-->1-->0...
assign idxdff_wd[0] = w_and_clr ? (idx_cnt == 1) : (ins_insert /*& (~oitf_full)*/ & (idx_cnt == 0));
assign idxdff_clr[0] = (idxdff_o[0][`MYRISCV_REGADDRBUS] == clr_idx) & clr_req & idxdff_o[0][`MYRISCV_REGADDRWD];
assign idxdff_clr_shr[0] = 1'b0;
assign idxdff_en[0] = idxdff_wd[0] || idxdff_clr[0] || idxdff_clr_shr[0];
assign idxdff_i[0] = idxdff_wd[0] ? {1'b1, rdidx} : /*{(`MYRISCV_REGADDRWD+1){1'b0}}*/idxdff_o[1];
// sirv_gnrl_dfflr #(`MYRISCV_REGADDRWD+1) idx_reg(idxdff_en[0], idxdff_i[0], idxdff_o[0], clk, rst);
reg_enrs #(`MYRISCV_REGADDRWD+1, 0, "idx_reg") idx_reg (clk, rst, idxdff_en[0], idxdff_i[0], idxdff_o[0]);
assign idx_conflict[0] = //idxdff_o[0][`MYRISCV_REGADDRWD] & 
                        (idx_cnt >= 1) &
                        ((idxdff_o[0][`MYRISCV_REGADDRBUS] == rs1_idx) 
                        || (idxdff_o[0][`MYRISCV_REGADDRBUS] == rs2_idx) 
                        || (idxdff_o[0][`MYRISCV_REGADDRBUS] == rdidx));

genvar i;
genvar j;
for(i=1; i<`OitfSize; i=i+1) begin
    assign idxdff_wd[i] = w_and_clr ? (idx_cnt == i+1) : (ins_insert /*& (~oitf_full)*/ & (idx_cnt == i)); 
    assign idxdff_clr[i] = (idxdff_o[i][`MYRISCV_REGADDRBUS] == clr_idx) & clr_req & idxdff_o[i][`MYRISCV_REGADDRWD];
    assign idxdff_clr_shr[i] = idxdff_clr[i-1] | idxdff_clr_shr[i-1];        
    assign idxdff_en[i] = idxdff_wd[i] || idxdff_clr[i] || idxdff_clr_shr[i];
    assign idxdff_i[i] = idxdff_wd[i] ?{1'b1, rdidx} : /*{(`MYRISCV_REGADDRWD+1){1'b0}}*/idxdff_o[i+1];
    // sirv_gnrl_dfflr #(`MYRISCV_REGADDRWD+1) idx_reg(idxdff_en[i], idxdff_i[i], idxdff_o[i], clk, rst);
    reg_enrs #(`MYRISCV_REGADDRWD+1, 0, "idx_reg") idx_reg (clk, rst, idxdff_en[i], idxdff_i[i], idxdff_o[i]);
    assign idx_conflict[i] = //idxdff_o[i][`MYRISCV_REGADDRWD] & 
                            (idx_cnt >= i+1) &
                            ((idxdff_o[i][`MYRISCV_REGADDRBUS] == rs1_idx) 
                            || (idxdff_o[i][`MYRISCV_REGADDRBUS] == rs2_idx) 
                            || (idxdff_o[i][`MYRISCV_REGADDRBUS] == rdidx));
end


wire oitf_full =  (idx_cnt == `OitfSize);
wire oitf_empty = (idx_cnt == 0);
wire can_insert = (~oitf_full) || clr_req;

assign dec2oitf_hold = (ins_insert & (~can_insert)) || (idx_conflict != {`OitfSize{1'b0}});

// assign cur_w_index = idxdff_o[0];


always@(posedge clk /*or negedge rst*/) begin
    if(!rst) begin
        idx_cnt <= 0;
    end
    else if(clr_req && (~ins_insert) && (~oitf_empty)) begin
        idx_cnt <= idx_cnt - 1'b1;
    end
    else if(ins_insert && (~oitf_full) && (~clr_req)) begin
        idx_cnt <= idx_cnt + 1'b1;
    end
end

endmodule
