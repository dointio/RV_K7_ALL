`include "mydefines.v"
module pcside_splt(
    input wire clk,
    input wire rst,
    
    //pc port
    input wire [`MYRISCV_ADDRBUS] pc_req_addr,
    input wire pc_req_vld,
    output wire pc_req_rdy,

    output wire [`MYRISCV_DATABUS] pc_rsp_data,
    output wire pc_rsp_err,
    output wire pc_rsp_vld,
    input wire pc_rsp_rdy,
    
    //sram port
    output wire sram_req_vld,
    input wire sram_req_rdy,
    output wire [`MYRISCV_ADDRBUS] sram_req_addr,

    input wire [`MYRISCV_DATABUS] sram_rsp_data,
    input wire sram_rsp_err,
    input wire sram_rsp_vld,
    output wire sram_rsp_rdy,

    //icb port
    output wire icb_req_vld,
    input wire icb_req_rdy,
    output wire [`MYRISCV_ADDRBUS] icb_req_addr,

    input wire [`MYRISCV_DATABUS] icb_rsp_data,
    input wire icb_rsp_err,
    input wire icb_rsp_vld,
    output wire icb_rsp_rdy
);
//START_RTL
    wire req_chal_close;
    wire pc_req_vld_mid;
    assign pc_req_vld_mid = pc_req_vld & (~req_chal_close);
    wire pc_req_rdy_mid;
    assign pc_req_rdy = (~req_chal_close) & pc_req_rdy_mid;

    wire connect_sram_i = ((pc_req_addr & `SRAM_ADDR_MASK) == `SRAM_ADDR_INDEX);//addr check

    assign sram_req_vld = connect_sram_i ? pc_req_vld_mid : 1'b0;
    assign sram_req_addr = pc_req_addr;
    assign icb_req_vld = connect_sram_i ? 1'b0 : pc_req_vld_mid;
    assign icb_req_addr = pc_req_addr;
    assign pc_req_rdy_mid = connect_sram_i ? sram_req_rdy : icb_req_rdy;

    wire req_handshake = pc_req_vld & pc_req_rdy;
    wire rsp_handshake = pc_rsp_vld & pc_rsp_rdy;

    reg waitrsp;
    assign req_chal_close = waitrsp & (~rsp_handshake);//rsp握手成功当回合即解锁。//对于0周期返回，会导致逻辑环路！！！！
    reg connect_sram_r;
    always@(posedge clk /*or negedge rst*/) begin
        if(rst == `RSTLEVEL) begin
            waitrsp <= 1'b0;
        end
        else if(~req_chal_close) begin
        // else if((~req_chal_close) && ~(req_handshake & rsp_handshake)) begin //r: support req and rsp in one cycle!
            waitrsp <= req_handshake;
        end
    end

    always@(posedge clk /*or negedge rst*/) begin
        if(rst == `RSTLEVEL) begin
            connect_sram_r <= 1'b1;
        end
        //r: if req and rsp in one cycle, this reg still update,
        //r: but waitrsp is still 0, so it is no used!
        //r: so support req and rsp in one cycle!
        else if(~req_chal_close) begin
            connect_sram_r <= connect_sram_i;
        end
    end

    //r: dont support req and rsp in one cycle!
    assign pc_rsp_vld =     connect_sram_r ? sram_rsp_vld : icb_rsp_vld;
    assign pc_rsp_err =     connect_sram_r  ? sram_rsp_err : icb_rsp_err;
    assign pc_rsp_data =    connect_sram_r  ? sram_rsp_data : icb_rsp_data;
    assign sram_rsp_rdy =   connect_sram_r  ? pc_rsp_rdy : 1'b0; 
    assign icb_rsp_rdy =    connect_sram_r  ? 1'b0 : pc_rsp_rdy;

    //r: support req and rsp in one cycle!
    // assign pc_rsp_vld = (waitrsp ? connect_sram_r : connect_sram_i) ? sram_rsp_vld : icb_rsp_vld;
    // assign pc_rsp_err = (waitrsp ? connect_sram_r : connect_sram_i) ? sram_rsp_err : icb_rsp_err;
    // assign pc_rsp_data = (waitrsp ? connect_sram_r : connect_sram_i) ? sram_rsp_data : icb_rsp_data;
    // assign sram_rsp_rdy =   (waitrsp ? connect_sram_r : connect_sram_i) ? pc_rsp_rdy : 1'b0; 
    // assign icb_rsp_rdy =    (waitrsp ? connect_sram_r : connect_sram_i) ? 1'b0 : pc_rsp_rdy;
//END_RTL

endmodule
