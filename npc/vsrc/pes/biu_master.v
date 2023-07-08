`include "mydefines.v"

module biu_master #(
    parameter clk_cycle = 10
)
(
    clk,
    rst,

    icb_cmd_vld,
    icb_cmd_rdy,
    icb_cmd_addr,
    icb_cmd_read,
    icb_cmd_wdata,
    icb_cmd_wmask,

    icb_rsp_rdata,
    icb_rsp_err,
    icb_rsp_vld,
    icb_rsp_rdy
);

input       clk, rst;

output reg      icb_cmd_vld;
input           icb_cmd_rdy;
output reg      [`MYRISCV_ADDRBUS]          icb_cmd_addr;
output reg      icb_cmd_read;
output reg      [`MYRISCV_DATABUS]          icb_cmd_wdata;
output reg      [`MYRISCV_DATADW/8-1:0]     icb_cmd_wmask;

input       icb_rsp_vld;
output      icb_rsp_rdy;
input       [`MYRISCV_DATABUS]          icb_rsp_rdata;
input       icb_rsp_err;

assign icb_rsp_rdy = 1'b1;

task sendCommand;
    // input [`MYRISCV_ADDRDW + 1 + `MYRISCV_DATADW + `MYRISCV_DATADW/8 -1 : 0] command;
    input [`MYRISCV_ADDRBUS] addr_i;
    input read_i;
    input [`MYRISCV_DATABUS] data_i;
    input [`MYRISCV_DATADW/8-1 : 0] wmask_i;
    @(posedge clk);
    wait(icb_cmd_rdy == 1'b1);
    fork
        icb_cmd_vld = 1;
        icb_cmd_addr = addr_i;
        icb_cmd_read = read_i;
        icb_cmd_wdata = data_i;
        icb_cmd_wmask = wmask_i;
    join
    // @(posedge clk);
endtask

task clearCmd;
    @(posedge clk);
    wait(icb_cmd_rdy == 1'b1);
    fork
        icb_cmd_vld = 0;
        icb_cmd_addr = 0;
        icb_cmd_read = 1;
        icb_cmd_wdata = 0;
        icb_cmd_wmask = 0;
    join
    // @(posedge clk);
endtask

//o: just a example!!
// integer i;
// integer eventnum = 10;
// initial begin
//     @(posedge rst);
//     for(i=0; i<eventnum; i=i+1) begin
//         sendCommand(1,1,64'(i),8'hf);
//     end
//     #100;
//     $finish;
// end
//o: end

//o: for simple gpu test + vga test
integer i;
reg [23:0] color = 24'hff00ff;
initial begin
    @(posedge rst);
    for(i=0; i<2400; i=i+1) begin
        sendCommand(64'h00000000a1000000+i*4, 0, {8'd0, color, 8'd0, color},8'hff);
    end
    sendCommand(64'h00000000a0000104, 0, 64'd1,8'hf);
    clearCmd();
    #40;
    // #100;
    // $finish;
end
//o: end

endmodule

