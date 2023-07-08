`include "mydefines.v"

module ddr_sim
(
    input             clk,
    input  [`MYRISCV_DATABUS] din, 
    input  [`MYRISCV_ADDRBUS] addr,
    input             cs,
    input             we,
    input  [(`MYRISCV_DATADW/8)-1:0]   wem,
    output [`MYRISCV_DATABUS]   dout
);

`ifdef MYRISCV_ARCH_64
    localparam integer ADDROFFSET = 3;
    localparam integer ADDR_WD_TRUE = 27;
`else
    localparam integer ADDROFFSET = 2;
    localparam integer ADDR_WD_TRUE = 28;
`endif
    localparam DW = `MYRISCV_DATADW;
    localparam AW = `MYRISCV_ADDRDW;
    localparam MW = `MYRISCV_DATADW/8;
    
    localparam DP_1 = `DDR_SIM_SIZE_CPU;
    localparam DP_2 = `DDR_SIM_SIZE_GPU;

    reg     [DW-1:0] mem_r  [0:DP_1-1];
    reg     [DW-1:0] mem_r2 [0:DP_2-1];

    wire    [MW-1:0] wen;
    wire    ren;

    assign ren = cs & (~we);
    assign wen = ({MW{cs & we}} & wem);


    genvar i;

    reg [DW-1:0] dout_pre;
    always @(posedge clk)
    begin
        if (ren) begin
            if(addr[ADDR_WD_TRUE+ADDROFFSET-1:(ADDROFFSET)] < `DDR_SIM_SIZE_CPU) begin
                dout_pre <= mem_r[addr[ADDR_WD_TRUE+ADDROFFSET-1:(ADDROFFSET)]];
            end
            else if(
                ((addr[ADDR_WD_TRUE+ADDROFFSET-1:0]) >= 30'h30000000) &
                ((addr[ADDR_WD_TRUE+ADDROFFSET-1-2:(ADDROFFSET)]) < `DDR_SIM_SIZE_GPU)
            )begin
                dout_pre <= mem_r2[addr[ADDR_WD_TRUE+ADDROFFSET-1-2:(ADDROFFSET)]];
            end
        end
    end
    assign dout = dout_pre;

    generate
      for (i = 0; i < MW; i = i+1) begin :mem
        always @(posedge clk) begin
            if (wen[i]) begin
                if(addr[ADDR_WD_TRUE+ADDROFFSET-1:(ADDROFFSET)] < `DDR_SIM_SIZE_CPU) begin
                    mem_r[addr[ADDR_WD_TRUE+ADDROFFSET-1:(ADDROFFSET)]][8*i+7:8*i] <= din[8*i+7:8*i];
                end
                else if(
                    ((addr[ADDR_WD_TRUE+ADDROFFSET-1:0]) >= 30'h30000000) &
                    ((addr[ADDR_WD_TRUE+ADDROFFSET-1-2:(ADDROFFSET)]) < `DDR_SIM_SIZE_CPU)
                )begin
                    mem_r2[addr[ADDR_WD_TRUE+ADDROFFSET-1-2:(ADDROFFSET)]][8*i+7:8*i] <= din[8*i+7:8*i];
                end
                else begin
                    $display("Error!, DDR Fetch Addr Overflow: %x", addr);
                    $finish;
                end
            end
        end
      end
    endgenerate

    wire [ADDR_WD_TRUE+ADDROFFSET-1-2:(ADDROFFSET)] addr_gpu = addr[ADDR_WD_TRUE+ADDROFFSET-1-2:(ADDROFFSET)];
    wire [ADDR_WD_TRUE+ADDROFFSET-1:(ADDROFFSET)] addr_cpu = addr[ADDR_WD_TRUE+ADDROFFSET-1:(ADDROFFSET)];

    always @(posedge clk) begin
        if (cs) begin
            if(addr[ADDR_WD_TRUE+ADDROFFSET-1:(ADDROFFSET)] < `DDR_SIM_SIZE_CPU) begin
            end
            else if(
                ((addr[ADDR_WD_TRUE+ADDROFFSET-1:0]) >= 30'h30000000) &
                ((addr[ADDR_WD_TRUE+ADDROFFSET-1-2:(ADDROFFSET)]) < `DDR_SIM_SIZE_GPU)
            )begin
            end
            else begin
                $display("Error!, DDR Fetch Addr Overflow: %x", addr);
                $finish;
            end
        end
    end
    
    `ifdef OPEN_VIRSCREEN_GPU
        `ifdef USE_DPIC
            import "DPI-C" function void screen_gpu_init(input integer width, input integer height, input reg [`MYRISCV_DATABUS] data []);
            initial begin
                screen_gpu_init(800, 600, mem_r2);
            end
        `else
            initial begin
            $display("Error! Use VIRSCREEN_GPU, but not open USE_DPIC!!");
            $finish;
            end
        `endif
    `endif

endmodule

