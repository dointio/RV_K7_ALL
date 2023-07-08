`include "mydefines.v"
/* verilator lint_off WIDTHEXPAND*/

module jtag_dm #(
    parameter DMI_ADDR_BITS = 6,
    parameter DMI_DATA_BITS = 32,
    parameter DMI_OP_BITS = 2)(

    clk,
    rst_n,

    // rx
    dm_ack_o,
    dm_req_vaild_i,
    dm_req_data_i,

    // tx
    dm_ack_i,
    dm_resp_data_o,
    dm_resp_valid_o,

    // dm_reg_we_o,
    // dm_reg_addr_o,
    // dm_reg_wdata_o,
    // dm_reg_rdata_i,

    jtag_reg_idx,
    jtag_reg_we_vld,
    jtag_reg_we_rdy,
    jtag_reg_wdata,
    jtag_reg_rdata,

    jtag_cmd_vld,
    jtag_cmd_rdy,
    jtag_cmd_read,
    jtag_cmd_addr,
    jtag_cmd_wdata,
    jtag_cmd_wmask,

    jtag_rsp_vld,
    jtag_rsp_rdy,
    jtag_rsp_err,
    jtag_rsp_rdata,

    // dm_op_req_o,
    dm_halt_req_o,
    dm_reset_req_o

    );
    `define DM_RESP_VALID     1'b1
    `define DM_RESP_INVALID   1'b0
    `define DTM_REQ_VALID     1'b1
    `define DTM_REQ_INVALID   1'b0

    `define DTM_OP_NOP        2'b00
    `define DTM_OP_READ       2'b01
    `define DTM_OP_WRITE      2'b10

    localparam DM_RESP_BITS = DMI_ADDR_BITS  + DMI_DATA_BITS + DMI_OP_BITS;
    localparam DTM_REQ_BITS = DMI_ADDR_BITS + DMI_DATA_BITS + DMI_OP_BITS;
    localparam SHIFT_REG_BITS = DTM_REQ_BITS;

    // 输入输出信号
    input wire clk;
    input wire rst_n;

    output wire dm_ack_o;
    input wire dm_req_vaild_i;
    input wire[DTM_REQ_BITS-1:0] dm_req_data_i;
    input wire dm_ack_i;
    output wire[DM_RESP_BITS-1:0] dm_resp_data_o;
    output wire dm_resp_valid_o;

    output wire [`MYRISCV_REGADDRBUS] jtag_reg_idx;
    output reg jtag_reg_we_vld;
    input wire jtag_reg_we_rdy;
    output reg [`MYRISCV_REGBUS] jtag_reg_wdata;
    input wire [`MYRISCV_REGBUS] jtag_reg_rdata;

    output reg jtag_cmd_vld;
    input wire jtag_cmd_rdy;
    output reg jtag_cmd_read;
    output reg [`MYRISCV_ADDRBUS] jtag_cmd_addr;
    output reg [`MYRISCV_DATADW-1 : 0] jtag_cmd_wdata;
    output reg [`MYRISCV_DATADW/8-1 : 0] jtag_cmd_wmask;

    input wire jtag_rsp_vld;
    output reg jtag_rsp_rdy;
    input wire jtag_rsp_err;
    // output wire [`MYRISCV_DATADW-1 : 0] jtag_rsp_rdata;
    input wire [`MYRISCV_DATADW-1 : 0] jtag_rsp_rdata;

    output wire dm_halt_req_o;
    output wire dm_reset_req_o;

    // DM模块寄存器
    reg[31:0] dcsr;
    reg[31:0] dmstatus;
    reg[31:0] dmcontrol;
    reg[31:0] hartinfo;
    reg[31:0] abstractcs;
    reg[31:0] data0;
    reg[31:0] sbcs;
    reg[31:0] sbaddress0;
    reg[31:0] sbdata0;
    reg[31:0] command;

    // DM模块寄存器地址
    localparam DCSR       = 16'h7b0;
    localparam DMSTATUS   = 6'h11;
    localparam DMCONTROL  = 6'h10;
    localparam HARTINFO   = 6'h12;
    localparam ABSTRACTCS = 6'h16;
    localparam DATA0      = 6'h04;
    localparam SBCS       = 6'h38;
    localparam SBADDRESS0 = 6'h39;
    localparam SBDATA0    = 6'h3C;
    localparam COMMAND    = 6'h17;
    localparam DPC        = 16'h7b1;

    localparam OP_SUCC = 2'b00;

    reg[31:0] resp_read_data;
    reg dm_halt_req;
    reg dm_reset_req;
    reg need_resp;

    wire[31:0] sbaddress0_next = sbaddress0 + 4;

    wire rx_valid;
    wire[DTM_REQ_BITS-1:0] recv_commandordata;
    wire[DMI_OP_BITS-1:0] rx_op = recv_commandordata[DMI_OP_BITS-1:0];
    wire[DMI_DATA_BITS-1:0] rx_data = recv_commandordata[DMI_DATA_BITS+DMI_OP_BITS-1:DMI_OP_BITS];
    wire[DMI_ADDR_BITS-1:0] rx_addr = recv_commandordata[DTM_REQ_BITS-1:DMI_DATA_BITS+DMI_OP_BITS];

    wire read_dmstatus = (rx_op == `DTM_OP_READ) & (rx_addr == DMSTATUS);

    reg req_reg;
    wire [15:0] jtag_reg_idx_ww = {rx_data[15:0] - 16'h1000};
    assign jtag_reg_idx = jtag_reg_idx_ww[4:0];
    reg req_mem;
    reg mem_waitrsp;
    reg [31:0] read_mem_data;

    always @ (posedge clk /*or negedge rst_n*/) begin
        if (!rst_n) begin
            dm_halt_req <= 1'b0;
            dm_reset_req <= 1'b0;
            sbaddress0 <= 32'h0;
            dcsr <= 32'h0;
            hartinfo <= 32'h0;
            sbcs <= 32'h20040404;
            dmcontrol <= 32'h0;
            abstractcs <= 32'h1000003;
            data0 <= 32'h0;
            sbdata0 <= 32'h0;
            command <= 32'h0;
            dmstatus <= 32'h430c82;
            resp_read_data <= 32'h0;
            need_resp <= 1'b0;
            req_reg <= 0;
            req_mem <= 0;
            mem_waitrsp <= 0;
            read_mem_data <= 0;

            jtag_reg_we_vld <= 0;
            jtag_reg_wdata <= 0;

            jtag_cmd_vld <= 0;
            jtag_cmd_read <= 0;
            jtag_cmd_addr <= 0;
            jtag_cmd_wdata <= 0;
            jtag_cmd_wmask <= 4'hf;

            jtag_rsp_rdy <= 0;
        end 
        else if(req_reg) begin
            if(jtag_reg_we_rdy) begin
                req_reg <= 0;
                jtag_reg_we_vld <= 0;
                need_resp <= 1'b1;
            end
        end
        else if(req_mem) begin
            if(jtag_cmd_read & jtag_cmd_rdy) begin
                if(jtag_rsp_vld) begin
                    need_resp <= 1'b1;
                    req_mem <= 1'b0;
                    jtag_cmd_vld <= 1'b0;
                    jtag_rsp_rdy <= 1'b0;
`ifdef MYRISCV_ARCH_64
                    sbdata0 <= jtag_cmd_addr[2] ? jtag_rsp_rdata[63:32] : jtag_rsp_rdata[31:0];
`else
                    sbdata0 <= jtag_rsp_rdata;
`endif
                end 
                else begin
                    mem_waitrsp <= 1'b1;
                    jtag_cmd_vld <= 1'b0;
                end
            end
            else if(jtag_cmd_read & mem_waitrsp & jtag_rsp_vld) begin
                need_resp <= 1'b1;
                req_mem <= 1'b0;
                jtag_rsp_rdy <= 1'b0;
                mem_waitrsp <= 1'b0;
`ifdef MYRISCV_ARCH_64
                sbdata0 <= jtag_cmd_addr[2] ? jtag_rsp_rdata[63:32] : jtag_rsp_rdata[31:0];
`else
                sbdata0 <= jtag_rsp_rdata;
`endif
            end

            if((~jtag_cmd_read) & jtag_cmd_rdy) begin
                if(jtag_rsp_vld) begin
                    need_resp <= 1'b1;
                    req_mem <= 1'b0;
                    jtag_cmd_vld <= 1'b0;
                    jtag_rsp_rdy <= 1'b0;
                end
                else begin
                    mem_waitrsp <= 1'b1;
                    jtag_cmd_vld <= 1'b0;
                end
            end
            else if((~jtag_cmd_read) & mem_waitrsp & jtag_rsp_vld) begin
                need_resp <= 1'b1;
                req_mem <= 1'b0;
                jtag_rsp_rdy <= 1'b0;
                mem_waitrsp <= 1'b0;
            end
        end
        else if (rx_valid) begin
            // need_resp <= 1'b1;
            case (rx_op)
                `DTM_OP_READ: begin
                    case (rx_addr)
                        DMSTATUS: begin
                            need_resp <= 1'b1;
                            resp_read_data <= dmstatus;
                        end
                        DMCONTROL: begin
                            need_resp <= 1'b1;
                            resp_read_data <= dmcontrol;
                        end
                        HARTINFO: begin
                            need_resp <= 1'b1;
                            resp_read_data <= hartinfo;
                        end
                        SBCS: begin
                            need_resp <= 1'b1;
                            resp_read_data <= sbcs;
                        end
                        ABSTRACTCS: begin
                            need_resp <= 1'b1;
                            resp_read_data <= abstractcs;
                        end
                        DATA0: begin
                            need_resp <= 1'b1;
                            resp_read_data <= data0;
                        end
                        SBDATA0: begin
                            resp_read_data <= sbdata0;
                            if (sbcs[16] == 1'b1) begin
                                sbaddress0 <= sbaddress0_next;
                            end

                            if (sbcs[15] == 1'b1) begin
                                need_resp <= 1'b0;
                                jtag_cmd_vld <= 1'b1;
                                jtag_cmd_read <= 1'b1;
                                jtag_cmd_addr <= sbaddress0_next;
`ifdef MYRISCV_ARCH_64
                                jtag_cmd_wmask <= rx_data[2] ? 8'hf0 : 8'h0f;
`else 
                                jtag_cmd_wmask <= 4'hf;
`endif
                                jtag_rsp_rdy <= 1'b1;
                                need_resp <= 1'b0;
                                req_mem <= 1'b1;
                            end
                            else begin
                                need_resp <= 1'b1;
                            end
                        end
                        default: begin
                            need_resp <= 1'b1;
                            resp_read_data <= {(DMI_DATA_BITS){1'b0}};
                        end
                    endcase
                end

                `DTM_OP_WRITE: begin
                    resp_read_data <= {(DMI_DATA_BITS){1'b0}};
                    case (rx_addr)
                        DMCONTROL: begin
                            // reset DM module
                            need_resp <= 1'b1;
                            if (rx_data[0] == 1'b0) begin
                                dcsr <= 32'hc0;
                                dmstatus <= 32'h430c82;  // not halted, all running
                                hartinfo <= 32'h0;
                                sbcs <= 32'h20040404;
                                abstractcs <= 32'h1000003;
                                dmcontrol <= rx_data;
                                dm_halt_req <= 1'b0;
                                dm_reset_req <= 1'b0;
                            // DM is active
                            end else begin
                                // we have only one hart
                                dmcontrol <= (rx_data & ~(32'h3fffc0)) | 32'h10000;
                                if((dmcontrol[1] == 1'b0) && (rx_data[1] == 1'b1)) begin //reset时会解除halt
                                    dm_halt_req <= 1'b0;
                                    dmstatus <= {dmstatus[31:12], 4'hc, dmstatus[7:0]};
                                end
                                // halt
                                if (rx_data[31] == 1'b1) begin
                                    dm_halt_req <= 1'b1;
                                    // clear ALLRUNNING ANYRUNNING and set ALLHALTED
                                    dmstatus <= {dmstatus[31:12], 4'h3, dmstatus[7:0]};
                                // resume
                                end else if (dm_halt_req == 1'b1 && rx_data[30] == 1'b1) begin
                                    dm_halt_req <= 1'b0;
                                    // set ALLRUNNING ANYRUNNING and clear ALLHALTED
                                    dmstatus <= {dmstatus[31:12], 4'hc, dmstatus[7:0]};
                                end
                            end
                        end
                        COMMAND: begin
                            // access reg
                            if (rx_data[31:24] == 8'h0) begin
                                if (rx_data[22:20] > 3'h2) begin
                                    abstractcs <= abstractcs | (1'b1 << 9); //如果读取寄存器数据超过32位，就会返回指令无法实现。
                                    need_resp <= 1'b1;
                                end else begin
                                    abstractcs <= abstractcs & (~(3'h7 << 8));
                                    // read or write
                                    if (rx_data[18] == 1'b0) begin
                                        // read
                                        if (rx_data[16] == 1'b0) begin
                                            need_resp <= 1'b1;
                                            if (rx_data[15:0] == DCSR) begin
                                                data0 <= dcsr;                                                
                                            end else if (rx_data[15:0] < 16'h1020) begin
                                                data0 <= jtag_reg_rdata;
                                            end
                                        // write
                                        end else begin                                            
                                            if (rx_data[15:0] == DPC) begin // when write dpc, we reset cpu here
                                                need_resp <= 1'b1;
                                                dm_reset_req <= 1'b1;
                                                dm_halt_req <= 1'b0;
                                                dmstatus <= {dmstatus[31:12], 4'hc, dmstatus[7:0]};
                                            end else if (rx_data[15:0] < 16'h1020) begin
                                                req_reg <= 1'b1;
                                                need_resp <= 1'b0;
                                                jtag_reg_we_vld <= 1'b1;
                                                jtag_reg_wdata <= data0;
                                                // dm_reg_we <= 1'b1;
                                                // dm_reg_wdata <= data0;
                                            end
                                        end
                                    end
                                    else begin
                                        need_resp <= 1'b1;
                                    end
                                end
                            end
                            else begin
                                need_resp <= 1'b1;
                            end
                        end
                        DATA0: begin
                            need_resp <= 1'b1;
                            data0 <= rx_data;
                        end
                        SBCS: begin
                            need_resp <= 1'b1;
                            sbcs <= rx_data;
                        end
                        SBADDRESS0: begin
                            sbaddress0 <= rx_data;
                            if (sbcs[20] == 1'b1) begin //写入addr触发自动读取
                                jtag_cmd_vld <= 1'b1;
                                jtag_cmd_read <= 1'b1;
                                jtag_cmd_addr <= rx_data;
`ifdef MYRISCV_ARCH_64
                                jtag_cmd_wmask <= rx_data[2] ? 8'hf0 : 8'h0f;
`else 
                                jtag_cmd_wmask <= 4'hf;
`endif
                                jtag_rsp_rdy <= 1'b1;
                                need_resp <= 1'b0;
                                req_mem <= 1'b1;
                            end
                            else begin
                                need_resp <= 1'b1;
                            end
                        end
                        SBDATA0: begin
                            sbdata0 <= rx_data;
                            jtag_cmd_vld <= 1'b1;
                            jtag_cmd_read <= 1'b0;
                            jtag_cmd_addr <= sbaddress0;
`ifdef MYRISCV_ARCH_64
                            jtag_cmd_wdata <= sbaddress0[2] ? {rx_data[31:0], 32'd0} : {32'd0, rx_data[31:0]};
                            jtag_cmd_wmask <= sbaddress0[2] ? 8'hf0 : 8'h0f;
`else
                            jtag_cmd_wdata <= rx_data[31:0];
                            jtag_cmd_wmask <= 4'hf;
`endif
                            jtag_rsp_rdy <= 1'b1;
                            need_resp <= 1'b0;
                            req_mem <= 1'b1;
                            if (sbcs[16] == 1'b1) begin
                                sbaddress0 <= sbaddress0_next;
                            end
                        end
                        default: begin
                            need_resp <= 1'b1;
                            resp_read_data <= {(DMI_DATA_BITS){1'b0}};
                        end
                    endcase
                end

                `DTM_OP_NOP: begin
                    resp_read_data <= {(DMI_DATA_BITS){1'b0}};
                    need_resp <= 1'b1;
                    // dm_reset_req <= 1'b0;
                end
                
                default: begin
                    resp_read_data <= {(DMI_DATA_BITS){1'b0}};
                    need_resp <= 1'b1;
                    // dm_reset_req <= 1'b0;
                end
            endcase
        end 
        else begin
            need_resp <= 1'b0;
            dm_reset_req <= 1'b0;
        end
    end

    // assign dm_op_req_o = (rx_valid & (~read_dmstatus)) | need_resp;
    assign dm_halt_req_o = dm_halt_req;
    wire dm_reset_req_w = dm_reset_req | dmcontrol[1];
    reg [2:0] dm_rst_cnt;
    always@(posedge clk) begin
        if(rst_n) begin
            dm_rst_cnt <= 0;
        end
        else if(dm_reset_req_w) begin
            dm_rst_cnt <= 3'd4;
        end
        else if(dm_rst_cnt != 0) begin
            dm_rst_cnt <= dm_rst_cnt - 1'b1;
        end
    end
    assign dm_reset_req_o = (dm_rst_cnt != 0);//r: 展宽一下reset信号。然后直接作为false path或多周期信号给pipe_ctrl。
                                                //r: 其实halt也是同理，不过halt都不需要硬件展宽，本身天然就很宽。。。

    wire[DM_RESP_BITS-1:0] dm_resp_data;
    assign dm_resp_data = {rx_addr, resp_read_data, OP_SUCC}; //有个问题，address在使用tx返回时，rx数据已经清零了，也就是address一定返回为0，可能本来就没用到？


    full_handshake_tx #(
        .DW(DM_RESP_BITS)
    ) tx(
        .clk(clk),
        .rst_n(rst_n),
        // .idle_o(tx_idle),
        .idle_o (),
        .req_i(need_resp),
        .req_data_i(dm_resp_data),
        .ack_i(dm_ack_i),
        .req_o(dm_resp_valid_o),
        .req_data_o(dm_resp_data_o)
    );

    full_handshake_rx #(
        .DW(DTM_REQ_BITS)
    ) rx(
        .clk(clk),
        .rst_n(rst_n),
        .req_i(dm_req_vaild_i),
        .req_data_i(dm_req_data_i),
        .ack_o(dm_ack_o),
        .recv_data_o(recv_commandordata),
        .recv_rdy_o(rx_valid)
    );

endmodule
/* verilator lint_on WIDTHEXPAND*/


