 /*                                                                      
 Copyright 2020 Blue Liang, liangkangnan@163.com
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
 Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */

// `include "../core/defines.v"
`include "mydefines.v"

// JTAG顶层模块
module jtag_top #(
    parameter DMI_ADDR_BITS = 6,
    parameter DMI_DATA_BITS = 32,
    parameter DMI_OP_BITS = 2)(

    input wire clk,
    input wire jtag_rst_n,

    input wire jtag_pin_TCK,
    input wire jtag_pin_TMS,
    input wire jtag_pin_TDI,
    output wire jtag_pin_TDO,

    output wire [`MYRISCV_REGADDRBUS] jtag_reg_idx,
    output wire jtag_reg_we_vld,
    input wire jtag_reg_we_rdy,
    output wire [`MYRISCV_REGBUS] jtag_reg_wdata,
    input wire [`MYRISCV_REGBUS] jtag_reg_rdata,

    output wire jtag_cmd_vld,
    input wire jtag_cmd_rdy,
    output wire jtag_cmd_read,
    output wire [`MYRISCV_ADDRBUS] jtag_cmd_addr,
    output wire [`MYRISCV_XLEN-1 : 0] jtag_cmd_wdata,
    output wire [`MYRISCV_XLEN/8-1 : 0] jtag_cmd_wmask,

    input wire jtag_rsp_vld,
    output wire jtag_rsp_rdy,
    input wire jtag_rsp_err,
    input wire [`MYRISCV_XLEN-1 : 0] jtag_rsp_rdata,

    output wire halt_req_o,
    output wire reset_req_o

    );

    parameter DM_RESP_BITS = DMI_ADDR_BITS + DMI_DATA_BITS + DMI_OP_BITS;
    parameter DTM_REQ_BITS = DMI_ADDR_BITS + DMI_DATA_BITS + DMI_OP_BITS;

    // jtag_driver
    wire dtm_ack_o;
    wire dtm_req_valid_o;
    wire[DTM_REQ_BITS - 1:0] dtm_req_data_o;

    // jtag_dm
    wire dm_ack_o;
    wire[DM_RESP_BITS-1:0] dm_resp_data_o;
    wire dm_resp_valid_o;
    wire dm_op_req_o;
    wire dm_halt_req_o;
    wire dm_reset_req_o;

    jtag_driver #(
        .DMI_ADDR_BITS(DMI_ADDR_BITS),
        .DMI_DATA_BITS(DMI_DATA_BITS),
        .DMI_OP_BITS(DMI_OP_BITS)
    ) u_jtag_driver(
        .rst_n(jtag_rst_n),
        .jtag_TCK(jtag_pin_TCK),
        .jtag_TDI(jtag_pin_TDI),
        .jtag_TMS(jtag_pin_TMS),
        .jtag_TDO(jtag_pin_TDO),
        .dm_resp_i(dm_resp_valid_o),
        .dm_resp_data_i(dm_resp_data_o),
        .dtm_ack_o(dtm_ack_o),
        .dm_ack_i(dm_ack_o),
        .dtm_req_valid_o(dtm_req_valid_o),
        .dtm_req_data_o(dtm_req_data_o)
    );

    jtag_dm #(
        .DMI_ADDR_BITS(DMI_ADDR_BITS),
        .DMI_DATA_BITS(DMI_DATA_BITS),
        .DMI_OP_BITS(DMI_OP_BITS)
    ) u_jtag_dm(
        .clk(clk),
        .rst_n(jtag_rst_n),

        .dm_ack_o(dm_ack_o),
        .dm_req_vaild_i(dtm_req_valid_o),
        .dm_req_data_i(dtm_req_data_o),
        .dm_ack_i(dtm_ack_o),
        .dm_resp_data_o(dm_resp_data_o),
        .dm_resp_valid_o(dm_resp_valid_o),

        .jtag_reg_idx  (jtag_reg_idx),
        .jtag_reg_we_vld  (jtag_reg_we_vld),
        .jtag_reg_we_rdy  (jtag_reg_we_rdy),
        .jtag_reg_wdata  (jtag_reg_wdata),
        .jtag_reg_rdata  (jtag_reg_rdata),
                
        .jtag_cmd_vld  (jtag_cmd_vld),
        .jtag_cmd_rdy  (jtag_cmd_rdy),
        .jtag_cmd_read  (jtag_cmd_read),
        .jtag_cmd_addr  (jtag_cmd_addr),
        .jtag_cmd_wdata  (jtag_cmd_wdata),
        .jtag_cmd_wmask  (jtag_cmd_wmask),

        .jtag_rsp_vld  (jtag_rsp_vld),
        .jtag_rsp_rdy  (jtag_rsp_rdy),
        .jtag_rsp_err  (jtag_rsp_err),
        .jtag_rsp_rdata  (jtag_rsp_rdata),

        .dm_halt_req_o(halt_req_o),
        .dm_reset_req_o(reset_req_o)
    );

endmodule
