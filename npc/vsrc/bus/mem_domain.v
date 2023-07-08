
`include "mydefines.v"


module mem_domain(
    //o: port to biu
    input                             mem_icb_cmd_valid,
    output                            mem_icb_cmd_ready,
    input  [`MYRISCV_ADDRBUS]         mem_icb_cmd_addr, 
    input                             mem_icb_cmd_read, 
    input  [`MYRISCV_DATADW-1:0]      mem_icb_cmd_wdata,
    input  [`MYRISCV_DATADW/8-1:0]    mem_icb_cmd_wmask,
    //
    output                            mem_icb_rsp_valid,
    input                             mem_icb_rsp_ready,
    output                            mem_icb_rsp_err,
    output [`MYRISCV_DATADW-1:0]      mem_icb_rsp_rdata,
    
    //o: no used
    output                          sysmem_icb_cmd_valid,
    input                           sysmem_icb_cmd_ready,
    output [`MYRISCV_ADDRBUS]       sysmem_icb_cmd_addr, 
    output                          sysmem_icb_cmd_read, 
    output [`MYRISCV_DATADW-1:0]    sysmem_icb_cmd_wdata,
    output [`MYRISCV_DATADW/8-1:0]  sysmem_icb_cmd_wmask,
    //
    input                           sysmem_icb_rsp_valid,
    output                          sysmem_icb_rsp_ready,
    input                           sysmem_icb_rsp_err,
    input  [`MYRISCV_DATADW-1:0]    sysmem_icb_rsp_rdata,

    //o: no used
    output                          qspi0_ro_icb_cmd_valid,
    input                           qspi0_ro_icb_cmd_ready,
    output [`MYRISCV_ADDRBUS]       qspi0_ro_icb_cmd_addr, 
    output                          qspi0_ro_icb_cmd_read, 
    output [`MYRISCV_DATADW-1:0]    qspi0_ro_icb_cmd_wdata,
    //
    input                           qspi0_ro_icb_rsp_valid,
    output                          qspi0_ro_icb_rsp_ready,
    input                           qspi0_ro_icb_rsp_err,
    input  [`MYRISCV_DATADW-1:0]    qspi0_ro_icb_rsp_rdata,

    //o: noused
    output                          dm_icb_cmd_valid,
    input                           dm_icb_cmd_ready,
    output [`MYRISCV_ADDRBUS]       dm_icb_cmd_addr, 
    output                          dm_icb_cmd_read, 
    output [`MYRISCV_DATADW-1:0]    dm_icb_cmd_wdata,
    //
    input                           dm_icb_rsp_valid,
    output                          dm_icb_rsp_ready,
    input  [`MYRISCV_DATADW-1:0]    dm_icb_rsp_rdata,
    
    //o: mig_port
    output                          mig_icb_cmd_valid,
    input                           mig_icb_cmd_ready,
    output [`MYRISCV_ADDRBUS]       mig_icb_cmd_addr, 
    output                          mig_icb_cmd_read, 
    output [2-1:0]                  mig_icb_cmd_burst,
    output [2-1:0]                  mig_icb_cmd_beat,
    output [`MYRISCV_DATADW-1:0]    mig_icb_cmd_wdata,
    output [`MYRISCV_DATADW/8-1:0]  mig_icb_cmd_wmask,
    output                          mig_icb_cmd_lock,
    output                          mig_icb_cmd_excl,
    output [1:0]                    mig_icb_cmd_size,

    input                           mig_icb_rsp_valid,
    output                          mig_icb_rsp_ready,
    input                           mig_icb_rsp_err  ,
    input                           mig_icb_rsp_excl_ok,
    input [`MYRISCV_DATADW-1:0]     mig_icb_rsp_rdata,
    // output o_axi_arvalid,
    // input  o_axi_arready,
    // output [`MYRISCV_ADDRBUS] o_axi_araddr,
    // output [3:0] o_axi_arcache,
    // output [2:0] o_axi_arprot,
    // output [1-1:0] o_axi_arlock,
    // output [1:0] o_axi_arburst,
    // output [8-1:0] o_axi_arlen,
    // output [2:0] o_axi_arsize,

    // output o_axi_awvalid,
    // input  o_axi_awready,
    // output [`MYRISCV_ADDRBUS] o_axi_awaddr,
    // output [3:0] o_axi_awcache,
    // output [2:0] o_axi_awprot,
    // output [1-1:0] o_axi_awlock,
    // output [1:0] o_axi_awburst,
    // output [8-1:0] o_axi_awlen,
    // output [2:0] o_axi_awsize,

    // input  o_axi_rvalid,
    // output o_axi_rready,
    // input  [`MYRISCV_DATABUS] o_axi_rdata,
    // input  [1:0] o_axi_rresp,
    // input  o_axi_rlast,

    // output o_axi_wvalid,
    // input  o_axi_wready,
    // output [`MYRISCV_DATABUS] o_axi_wdata,
    // output [(`MYRISCV_DATADW/8)-1:0] o_axi_wstrb,
    // output o_axi_wlast,

    // input  o_axi_bvalid,
    // output o_axi_bready,
    // input  [1:0] o_axi_bresp,

    input  clk,
    input  bus_rst_n,
    input  rst
);

    localparam MROM_AW = 12  ;
    localparam MROM_DP = 1024;
    // There are several slaves for Mem bus, including:
    //  * DM        : 0x0000 0000 -- 0x0000 0FFF
    //  * MROM      : 0x0000 1000 -- 0x0000 1FFF
    //  * QSPI0-RO  : 0x2000 0000 -- 0x3FFF FFFF
    //  * SysMem    : 0x8000 0000 -- 0xFFFF FFFF





    




    mem_bridge # (
    .ICB_FIFO_DP          (2),// We add a ping-pong buffer here to cut down the timing path
    .ICB_FIFO_CUT_READY   (1),// We configure it to cut down the back-pressure ready signal
    .AW                   (`MYRISCV_ADDRDW),
    .DW                   (`MYRISCV_DATADW),
    .SPLT_FIFO_OUTS_NUM   (1),// The Mem only allow 1 oustanding
    .SPLT_FIFO_CUT_READY  (1)// The Mem always cut ready

    //r: e203 setting, not used:
            //   //  * DM        : 0x0000 0000 -- 0x0000 0FFF
            //   .O0_BASE_ADDR       (32'h0000_0000),       
            //   .O0_BASE_REGION_LSB (12),
            //   //  * MROM      : 0x0000 1000 -- 0x0000 1FFF
            //   .O1_BASE_ADDR       (32'h0000_1000),       
            //   .O1_BASE_REGION_LSB (12),
            //   //  * Not used  : 0x0002 0000 -- 0x0003 FFFF
            //   .O2_BASE_ADDR       (32'h0002_0000),       
            //   .O2_BASE_REGION_LSB (17),
            //   //  * QSPI0-RO  : 0x2000 0000 -- 0x3FFF FFFF
            //   .O3_BASE_ADDR       (32'h2000_0000),       
            //   .O3_BASE_REGION_LSB (29),
            //   //  * SysMem    : 0x8000 0000 -- 0xFFFF FFFF
            //   //    Actually since the 0xFxxx xxxx have been occupied by FIO, 
            //   //    sysmem have no chance to access it
            //   .O4_BASE_ADDR       (32'h8000_0000),       
            //   .O4_BASE_REGION_LSB (31),

            //       // * Here is an example AXI Peripheral
            //   .O5_BASE_ADDR       (32'h4000_0000),       
            //   .O5_BASE_REGION_LSB (28),
            
            //       // Not used
            //   .O6_BASE_ADDR       (32'h0000_0000),       
            //   .O6_BASE_REGION_LSB (0),
            
            //       // Not used
            //   .O7_BASE_ADDR       (32'h0000_0000),       
            //   .O7_BASE_REGION_LSB (0)

    )u_sirv_mem_fab(

        .i_icb_cmd_valid  (mem_icb_cmd_valid),
        .i_icb_cmd_ready  (mem_icb_cmd_ready),
        .i_icb_cmd_addr   (mem_icb_cmd_addr ),
        .i_icb_cmd_read   (mem_icb_cmd_read ),
        .i_icb_cmd_wdata  (mem_icb_cmd_wdata),
        .i_icb_cmd_wmask  (mem_icb_cmd_wmask),
        .i_icb_cmd_lock   (1'b0 ),
        .i_icb_cmd_excl   (1'b0 ),
        .i_icb_cmd_size   (2'b0 ),
        .i_icb_cmd_burst  (2'b0),
        .i_icb_cmd_beat   (2'b0 ),
        
        .i_icb_rsp_valid  (mem_icb_rsp_valid),
        .i_icb_rsp_ready  (mem_icb_rsp_ready),
        .i_icb_rsp_err    (mem_icb_rsp_err  ),
        .i_icb_rsp_excl_ok(),
        .i_icb_rsp_rdata  (mem_icb_rsp_rdata), 
        
    //  * DM
        .dm_icb_enable     (1'b0),

        .dm_icb_cmd_valid  (dm_icb_cmd_valid),
        .dm_icb_cmd_ready  (dm_icb_cmd_ready),
        .dm_icb_cmd_addr   (dm_icb_cmd_addr ),
        .dm_icb_cmd_read   (dm_icb_cmd_read ),
        .dm_icb_cmd_wdata  (dm_icb_cmd_wdata),
        .dm_icb_cmd_wmask  (),
        .dm_icb_cmd_lock   (),
        .dm_icb_cmd_excl   (),
        .dm_icb_cmd_size   (),
        .dm_icb_cmd_burst  (),
        .dm_icb_cmd_beat   (),
        
        .dm_icb_rsp_valid  (dm_icb_rsp_valid),
        .dm_icb_rsp_ready  (dm_icb_rsp_ready),
        .dm_icb_rsp_err    (1'b0),
        .dm_icb_rsp_excl_ok(1'b0),
        .dm_icb_rsp_rdata  (dm_icb_rsp_rdata),

    //  * MROM      
        .o1_icb_enable     (1'b0),

        .o1_icb_cmd_valid  (),
        .o1_icb_cmd_ready  (),
        .o1_icb_cmd_addr   (),
        .o1_icb_cmd_read   (),
        .o1_icb_cmd_wdata  (),
        .o1_icb_cmd_wmask  (),
        .o1_icb_cmd_lock   (),
        .o1_icb_cmd_excl   (),
        .o1_icb_cmd_size   (),
        .o1_icb_cmd_burst  (),
        .o1_icb_cmd_beat   (),
        
        .o1_icb_rsp_valid  (),
        .o1_icb_rsp_ready  (),
        .o1_icb_rsp_err    (),
        .o1_icb_rsp_excl_ok(1'b0  ),
        .o1_icb_rsp_rdata  (),

    //  * Mig
// `ifdef USE_XILINXIP
//     `ifdef USE_MIG_IP
            .mig_icb_enable     (1'b1),
//     `elss
//             .mig_icb_enable     (1'b0),
//     `endif
// `else
//             .mig_icb_enable     (1'b0),
// `endif
        .mig_icb_cmd_valid  (mig_icb_cmd_valid  ),
        .mig_icb_cmd_ready  (mig_icb_cmd_ready  ),
        .mig_icb_cmd_addr   (mig_icb_cmd_addr   ),
        .mig_icb_cmd_read   (mig_icb_cmd_read   ),
        .mig_icb_cmd_wdata  (mig_icb_cmd_wdata  ),
        .mig_icb_cmd_wmask  (mig_icb_cmd_wmask  ),
        .mig_icb_cmd_lock   (mig_icb_cmd_lock   ),
        .mig_icb_cmd_excl   (mig_icb_cmd_excl   ),
        .mig_icb_cmd_size   (mig_icb_cmd_size   ),
        .mig_icb_cmd_burst  (mig_icb_cmd_burst  ),
        .mig_icb_cmd_beat   (mig_icb_cmd_beat   ),
        
        .mig_icb_rsp_valid  (mig_icb_rsp_valid  ),
        .mig_icb_rsp_ready  (mig_icb_rsp_ready  ),
        .mig_icb_rsp_err    (mig_icb_rsp_err    ),
        .mig_icb_rsp_excl_ok(mig_icb_rsp_excl_ok),
        .mig_icb_rsp_rdata  (mig_icb_rsp_rdata  ),


    //  * QSPI0-RO  
        .o3_icb_enable     (1'b0),

        .o3_icb_cmd_valid  (qspi0_ro_icb_cmd_valid),
        .o3_icb_cmd_ready  (qspi0_ro_icb_cmd_ready),
        .o3_icb_cmd_addr   (qspi0_ro_icb_cmd_addr ),
        .o3_icb_cmd_read   (qspi0_ro_icb_cmd_read ),
        .o3_icb_cmd_wdata  (qspi0_ro_icb_cmd_wdata),
        .o3_icb_cmd_wmask  (),
        .o3_icb_cmd_lock   (),
        .o3_icb_cmd_excl   (),
        .o3_icb_cmd_size   (),
        .o3_icb_cmd_burst  (),
        .o3_icb_cmd_beat   (),
        
        .o3_icb_rsp_valid  (qspi0_ro_icb_rsp_valid),
        .o3_icb_rsp_ready  (qspi0_ro_icb_rsp_ready),
        .o3_icb_rsp_err    (qspi0_ro_icb_rsp_err),
        .o3_icb_rsp_excl_ok(1'b0  ),
        .o3_icb_rsp_rdata  (qspi0_ro_icb_rsp_rdata),


    //  * SysMem
        .o4_icb_enable     (1'b0),

        .o4_icb_cmd_valid  (sysmem_icb_cmd_valid),
        .o4_icb_cmd_ready  (sysmem_icb_cmd_ready),
        .o4_icb_cmd_addr   (sysmem_icb_cmd_addr ),
        .o4_icb_cmd_read   (sysmem_icb_cmd_read ),
        .o4_icb_cmd_wdata  (sysmem_icb_cmd_wdata),
        .o4_icb_cmd_wmask  (sysmem_icb_cmd_wmask),
        .o4_icb_cmd_lock   (),
        .o4_icb_cmd_excl   (),
        .o4_icb_cmd_size   (),
        .o4_icb_cmd_burst  (),
        .o4_icb_cmd_beat   (),
        
        .o4_icb_rsp_valid  (sysmem_icb_rsp_valid),
        .o4_icb_rsp_ready  (sysmem_icb_rsp_ready),
        .o4_icb_rsp_err    (sysmem_icb_rsp_err    ),
        .o4_icb_rsp_excl_ok(1'b0),
        .o4_icb_rsp_rdata  (sysmem_icb_rsp_rdata),

    //  * Example AXI    
        .o5_icb_enable     (1'b0),

        .o5_icb_cmd_valid  (),
        .o5_icb_cmd_ready  (),
        .o5_icb_cmd_addr   (),
        .o5_icb_cmd_read   (),
        .o5_icb_cmd_wdata  (),
        .o5_icb_cmd_wmask  (),
        .o5_icb_cmd_lock   (),
        .o5_icb_cmd_excl   (),
        .o5_icb_cmd_size   (),
        .o5_icb_cmd_burst  (),
        .o5_icb_cmd_beat   (),
        
        .o5_icb_rsp_valid  (),
        .o5_icb_rsp_ready  (),
        .o5_icb_rsp_err    (),
        .o5_icb_rsp_excl_ok(1'b0  ),
        .o5_icb_rsp_rdata  (),


            //  * Not used
        .o6_icb_enable     (1'b0),

        .o6_icb_cmd_valid  (),
        .o6_icb_cmd_ready  (1'b0),
        .o6_icb_cmd_addr   (),
        .o6_icb_cmd_read   (),
        .o6_icb_cmd_wdata  (),
        .o6_icb_cmd_wmask  (),
        .o6_icb_cmd_lock   (),
        .o6_icb_cmd_excl   (),
        .o6_icb_cmd_size   (),
        .o6_icb_cmd_burst  (),
        .o6_icb_cmd_beat   (),
        
        .o6_icb_rsp_valid  (1'b0),
        .o6_icb_rsp_ready  (),
        .o6_icb_rsp_err    (1'b0  ),
        .o6_icb_rsp_excl_ok(1'b0  ),
        .o6_icb_rsp_rdata  (`MYRISCV_DATADW'b0),

            //  * Not used
        .o7_icb_enable     (1'b0),

        .o7_icb_cmd_valid  (),
        .o7_icb_cmd_ready  (1'b0),
        .o7_icb_cmd_addr   (),
        .o7_icb_cmd_read   (),
        .o7_icb_cmd_wdata  (),
        .o7_icb_cmd_wmask  (),
        .o7_icb_cmd_lock   (),
        .o7_icb_cmd_excl   (),
        .o7_icb_cmd_size   (),
        .o7_icb_cmd_burst  (),
        .o7_icb_cmd_beat   (),
        
        .o7_icb_rsp_valid  (1'b0),
        .o7_icb_rsp_ready  (),
        .o7_icb_rsp_err    (1'b0  ),
        .o7_icb_rsp_excl_ok(1'b0  ),
        .o7_icb_rsp_rdata  (`MYRISCV_DATADW'b0),

        .clk            (clk  ),
        .rst            (bus_rst_n) 
    );
    



endmodule
