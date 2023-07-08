// `include "mydefines.v"
// module flash_sim
// (
//     clk,
//     rst,

//     icb_cmd_vld,
//     icb_cmd_rdy,
//     icb_cmd_addr,
//     icb_cmd_read,
//     icb_cmd_wdata,
//     icb_cmd_wmask,

//     icb_rsp_rdata,
//     icb_rsp_err,
//     icb_rsp_vld, 
//     icb_rsp_rdy
// );
// input wire clk,rst;

// input wire icb_cmd_vld;
// output wire icb_cmd_rdy;
// input wire [`MYRISCV_ADDRBUS] icb_cmd_addr;
// input wire icb_cmd_read;
// input wire [`MYRISCV_DATABUS] icb_cmd_wdata;
// input wire [(`MYRISCV_DATADW/8-1):0] icb_cmd_wmask;

// output reg [`MYRISCV_DATABUS] icb_rsp_rdata;
// output reg icb_rsp_err;
// output reg icb_rsp_vld;
// input wire icb_rsp_rdy;

// `define IDLE 3'b000
// `define CMD_SEND 3'b001
// `define ADDRESS_SEND 3'b010
// `define READ_WAIT 3'b011
// `define WRITE_DATA 3'b101
// `define FINISH_DONE 3'b110

// reg [2:0] spi_state;
// reg not_busy;
// assign icb_cmd_rdy = not_busy & (icb_rsp_rdy | (~icb_rsp_vld));

// reg memory_cs;
// reg memory_we;
// reg [`MYRISCV_ADDRBUS] memory_addr;
// reg [(`MYRISCV_DATADW/8-1):0] memory_wem;
// reg [`MYRISCV_DATABUS] memory_wdata;
// wire [`MYRISCV_DATABUS] memory_rdata;

// always@(posedge clk /*or negedge rst*/)
// begin
//     if(!rst) begin
//         icb_rsp_vld <= 1'b0;
//         icb_rsp_rdata <= 0;
//         icb_rsp_err <= 0;
//         not_busy <= 1'b1;
//         spi_state <= `IDLE;
//         memory_cs <= 0;
//         memory_we <= 0;
//         memory_addr <= 0;
//         memory_wem <= 0;
//         memory_wdata <= 0;
//     end
//     else begin
//         icb_rsp_err <= 0;
//         case (spi_state)
//             `IDLE: begin
//                 if(icb_rsp_vld & icb_rsp_rdy) begin
//                     icb_rsp_vld <= 0;
//                 end
//                 if(icb_cmd_vld & icb_cmd_rdy) begin
//                     spi_state <= `CMD_SEND;
//                     not_busy <= 0;
//                     memory_cs <= 1'b1;
//                     memory_we <= (~icb_cmd_read);
//                     memory_wem <= icb_cmd_wmask;
//                     memory_addr <= icb_cmd_addr;
//                     memory_wdata <= icb_cmd_wdata;
//                 end
//             end     
//             `CMD_SEND: begin
//                 spi_state <= `ADDRESS_SEND;
//                 memory_cs <= 1'b0;
//                 memory_we <= 1'b0;
//             end
//             `ADDRESS_SEND: begin
//                 spi_state <= `WRITE_DATA;
//             end
//             `WRITE_DATA: begin
//                 spi_state <= `FINISH_DONE;
//             end
//             `FINISH_DONE: begin
//                 icb_rsp_vld <= 1;
//                 not_busy <= 1;
//                 spi_state <= `IDLE;
//                 icb_rsp_rdata <= memory_rdata;
//             end
//             default: begin
//                 spi_state <= `IDLE;
//             end
//         endcase
//     end
// end
// `ifdef USE_XILINXIP //Xilinx IP 
// `ifdef MYRISCV_ARCH_64
//     blk_mem_gen_0 mem_inst(
//         .clka       (clk),
//         .ena        (memory_cs),
//         .wea        ({(`MYRISCV_DATADW/8){memory_we}} & memory_wem),
//         .addra      (memory_addr[3+`DDR_SIM_ADDR_WD-1:3]),
//         .dina       (memory_wdata),
//         .douta      (memory_rdata)
//     );
// `else
//     blk_mem_gen_0 mem_inst(
//         .clka       (clk),
//         .ena        (memory_cs),
//         .wea        ({(`MYRISCV_DATADW/8){memory_we}} & memory_wem),
//         .addra      (memory_addr[2+`DDR_SIM_ADDR_WD-1:2]),
//         .dina       (memory_wdata),
//         .douta      (memory_rdata)
//     );
// `endif
// `else
//     sram_sim #(
//         .DP             (`DDR_SIM_SIZE), 
//         .FORCE_X2ZERO   (0),
//         .DW             (`MYRISCV_DATADW),
//         .MW             (`MYRISCV_DATADW/8),
//         .AW             (`MYRISCV_ADDRDW)
//     )mem_inst
//     (
//         .clk            (clk),
//         .cs             (memory_cs),
//         .we             (memory_we),
//         .addr           (memory_addr),
//         .din            (memory_wdata),
//         .wem            (memory_wem),
//         .dout           (memory_rdata)
//     );
//     always @(posedge clk) begin
//         if(memory_cs & memory_addr[27:`DDR_SIM_ADDR_OFF]>=`DDR_SIM_SIZE) begin
//             $display("Error! Mem Overflow! Addr: %x", memory_addr);
//             $finish;
//         end
//     end
// `endif
// endmodule
