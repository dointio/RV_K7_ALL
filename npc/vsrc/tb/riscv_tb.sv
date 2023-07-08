// `include "defines.v"
`include "mydefines.v"
`include "e203_defines.v"
module riscv_tb
();

    reg clk;
    reg rst;

    reg     jtag_TCK, jtag_TMS, jtag_TDI;
    wire    jtag_TDO;

    wire [7:0] gpio_o;

`ifndef JTAG_SIM
    initial begin
        jtag_TCK = 0;
        jtag_TMS = 0;
        jtag_TDI = 0;
    end
`endif

    initial begin
        clk = 0;
        forever begin
            #10 clk = ~clk;
        end
    end

    initial begin
        rst = 1;
        #50
        rst = 0;
        #50
        rst = 1;
    end

`ifdef Stop_Time
    localparam integer stopTime = `Stop_Time;
    initial begin
        if(stopTime != 0) begin
            # stopTime;
            $display("Time out");
            $finish;
        end
        else begin
            $display(stopTime);
        end
    end
`endif

    `ifdef VERILATOR_TB_DUMPFILE
    initial begin
        $dumpfile ("verilog.vcd");
        $dumpvars (8, soc_inst);
    end
    `endif
    
    //o: write to mems! (start)
    export "DPI-C" function writeVirDDR;
    function void writeVirDDR;
        input bit [`MYRISCV_ADDRBUS] addr;
        input bit [`MYRISCV_DATABUS] memData;
    begin
        if(addr[`DDR_SIM_ADDR_OFF+`DDR_SIM_ADDR_WD-1:`DDR_SIM_ADDR_OFF] >= `DDR_SIM_SIZE_CPU) begin
            $display("Error! WriteDDR overflow! Addr: %x", addr);
            $finish;
        end
        // soc_inst.ddr_flash_inst.mem_inst.mem_r[addr[`DDR_SIM_ADDR_OFF+`DDR_SIM_ADDR_WD-1 : `DDR_SIM_ADDR_OFF]] = memData;
        soc_inst.ddr_inst.mem_r[addr[`DDR_SIM_ADDR_OFF+`DDR_SIM_ADDR_WD-1 : `DDR_SIM_ADDR_OFF]] = memData;
        
    end
    endfunction

    export "DPI-C" function writeSRAM;
    function void writeSRAM;
        input bit [`MYRISCV_ADDRBUS] addr;
        input bit [`MYRISCV_DATABUS] memData;
    begin
        if(addr[27:`SRAM_ADDR_OFF]>`SRAM_SIZE) begin
            $display("Error! WriteSRAM overflow! Addr: %x", addr);
            $finish;
        end
        soc_inst.riscv_core_inst.sram_inst.mem_r[addr[`SRAM_ADDR_OFF+`SRAM_ADDR_WD-1 : `SRAM_ADDR_OFF]] = memData;
    end
    endfunction

    //o: write to mems! (end)

    //o: read mem.(start)
    export "DPI-C" function readMem;
    function void readMem;
        input bit [`MYRISCV_ADDRBUS] addr;
        output bit [`MYRISCV_DATABUS] data;
        begin
            if((addr & `SRAM_ADDR_MASK) == `SRAM_ADDR_INDEX) begin
                if(addr[27:`SRAM_ADDR_OFF]>`SRAM_SIZE) begin
                    $display("Error! ReadSRAM overflow! Addr: %x", addr);
                    $finish;
                end
                data = soc_inst.riscv_core_inst.sram_inst.mem_r[addr[`SRAM_ADDR_OFF+`SRAM_ADDR_WD-1 : `SRAM_ADDR_OFF]];
                
            end
            else begin
                if(addr[`DDR_SIM_ADDR_OFF+`DDR_SIM_ADDR_WD-1:`DDR_SIM_ADDR_OFF] >= `DDR_SIM_SIZE_CPU) begin
                    $display("Error! ReadDDR overflow! Addr: %x", addr);
                    $finish;
                end
                // data = soc_inst.ddr_flash_inst.mem_inst.mem_r[addr[`DDR_SIM_ADDR_OFF+`DDR_SIM_ADDR_WD-1 : `DDR_SIM_ADDR_OFF]];
                data = soc_inst.ddr_inst.mem_r[addr[`DDR_SIM_ADDR_OFF+`DDR_SIM_ADDR_WD-1 : `DDR_SIM_ADDR_OFF]];
            end
        end
    endfunction
    //o: read mem.(end)

    //o: monitor exu, function: halt test, difftest!(start)
    import "DPI-C" function void set_gpr_ptr(input logic [63:0] a []);
    initial set_gpr_ptr(soc_inst.riscv_core_inst.reg_inst.rf_r);
    
    import "DPI-C" function void halt();

    always @(posedge clk) begin
        // if((rst != `RSTLEVEL) 
        //     & (soc_inst.riscv_core_inst.dec2ex_vld_w2 & soc_inst.riscv_core_inst.dec2ex_rdy_w2) 
        //     & (soc_inst.riscv_core_inst.dec2ex_info_w2[`MY_DECINFO_ALU_EBRK]) 
        //     & (soc_inst.riscv_core_inst.dec2ex_info_w2[`MY_DECINFO_GRP_WIDTH-1 : 0] == `MY_DECINFO_GRP_ALU)) begin
        //     halt();
        // end
        if((rst != `RSTLEVEL) 
            & (soc_inst.riscv_core_inst.exu_inst.pipe_ctrl_inst.cpu_ebreak)) begin
            halt();
        end
    end

    bit [63:0] disp_instr_cnt; //= 64'd0;
    bit [`MYRISCV_ADDRBUS] disp_pc; //= {`MYRISCV_ADDRDW{1'b0}};
    bit [`MYRISCV_INSTBUS] disp_inst; //= {`MYRISCV_INSTWD{1'b0}};
    // initial begin
    //     disp_instr_cnt = 64'd0;
    //     disp_pc = {`MYRISCV_ADDRDW{1'b1}};
    //     disp_inst = {`MYRISCV_INSTWD{1'b0}};
    // end

    always@(posedge clk) begin
        if(rst == `RSTLEVEL) begin
            disp_instr_cnt <= 64'd0;
            disp_pc <= {`MYRISCV_ADDRDW{1'b1}};
            disp_inst <= {`MYRISCV_INSTWD{1'b0}};
        end
        else if((rst != `RSTLEVEL) & (soc_inst.riscv_core_inst.dec2ex_vld_w2 
            & soc_inst.riscv_core_inst.dec2ex_rdy_w2
            & ~soc_inst.riscv_core_inst.exu_inst.flush_req_o)) begin
            disp_instr_cnt <= disp_instr_cnt + 1'b1;
            disp_pc <= soc_inst.riscv_core_inst.dec2ex_pc_w2;
            `ifdef PLATFORM_SIM
                disp_inst <= soc_inst.riscv_core_inst.dec2ex_instr_w2;
            `else
                disp_inst <= {`MYRISCV_INSTWD{1'b0}};
                // $display("Please set Verilog define PLATFORM_SIM to get disp inst!!!");
                // $finish;
            `endif
        end
    end

    import "DPI-C" function void set_disp_ptr(inout bit [63:0] a, inout bit [`MYRISCV_ADDRBUS] b, inout bit [`MYRISCV_INSTBUS] c);
    initial set_disp_ptr(disp_instr_cnt, disp_pc, disp_inst);

    export "DPI-C" function getInstrCntDisp;
    export "DPI-C" function getInstCurrentDisp;
    export "DPI-C" function getPCCurrentDisp;

    function void getInstrCntDisp;
        output bit [63:0] DataOut;
        begin
            DataOut = disp_instr_cnt;
        end
    endfunction

    function void getInstCurrentDisp;
        output bit [`MYRISCV_INSTBUS] inst;
        begin
            inst = disp_inst;
        end
    endfunction
    
    function void getPCCurrentDisp;
        output bit [`MYRISCV_ADDRBUS] pc;
        begin
            pc = disp_pc;
        end
    endfunction

    //o: monitor exu(end)

    wire pix_clk;
    wire          vga_vsync;
    wire          vga_hsync;
    wire          vga_en;
    wire [23:0]   vga_data;

    riscv_soc soc_inst
    (
        .clk             (clk),
        .rst             (rst),
        
        .jtag_TCK        (jtag_TCK),
        .jtag_TMS        (jtag_TMS),
        .jtag_TDI        (jtag_TDI),
        .jtag_TDO        (jtag_TDO),

        .gpio_o          (gpio_o),

        .tx         (),
        .rx         ()

        // .pix_clk            (pix_clk),
        // .vga_vsync          (vga_vsync),
        // .vga_hsync          (vga_hsync),
        // .vga_en             (vga_en),
        // .vga_data           (vga_data)
    );
`ifdef OPEN_VIRSCREEN
    vgaVirScreen screen_inst
    (
        //   .link_i   , //0
    .rst      (rst),
    .clk      (pix_clk),
    .vs_i     (vga_vsync),
    .hs_i     (vga_hsync),
    .de_i     (vga_en),

    .data_r_i (vga_data[23:16]),
    .data_g_i (vga_data[15:8]),
    .data_b_i (vga_data[7:0])
    );
`endif


`ifdef JTAG_SIM
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
    
    `define DTM_OP_WRITE 2'b10
    `define DTM_OP_READ 2'b01
    `define DTM_OP_NOP 2'b00


    reg [39:0] jtag_wdata;
    reg TDO_buf;
    integer i;
    initial begin
        jtag_TCK = 0;
        forever begin
            #195;
            jtag_TCK = ~jtag_TCK;
        end
    end

    task WRITEJTAG;
        input [39:0] dr_data;
        @(negedge jtag_TCK);
// SELECT-DR
        jtag_TMS = 1;#195;#195;
// CAPTURE-DR
        jtag_TMS = 0;#195;#195;
// SHIFT-DR
        jtag_TMS = 0;#195;#195;

        // SHIFT-DR & EXIT1-DR
        for (i = 40; i > 0; i--) begin
            if (dr_data[0] == 1'b1)
                jtag_TDI = 1'b1;
            else
                jtag_TDI = 1'b0;

            if (i == 1)
                jtag_TMS = 1;

            #195;
            TDO_buf = jtag_TDO;
            #195;
            dr_data = {TDO_buf, dr_data[39:1]};
        end
// PAUSE-DR
        jtag_TMS = 0;#195;#195;
// EXIT2-DR
        jtag_TMS = 1;#195;#195;
// UPDATE-DR
        jtag_TMS = 1;#195;#195;
// IDLE
        jtag_TMS = 0;#195;#195;// IDLE
        jtag_TMS = 0;#195;#195;// IDLE
        jtag_TMS = 0;#195;#195;// IDLE
        jtag_TMS = 0;#195;#195;
    endtask

    initial begin
        jtag_TMS = 0;
        jtag_TDI = 0;
        #4000
        @ (negedge jtag_TCK);
        // reset
        for (i = 0; i < 8; i++) begin
            jtag_TMS = 1; #195; #195;
        end
// IR
        jtag_wdata = 40'b10001;
// IDLE
        jtag_TMS = 0; #195; #195;
// SELECT-DR
        jtag_TMS = 1; #195; #195;
// SELECT-IR
        jtag_TMS = 1; #195; #195;
// CAPTURE-IR
        jtag_TMS = 0; #195; #195;
// SHIFT-IR
        jtag_TMS = 0; #195; #195;
// SHIFT-IR & EXIT1-IR
        for (i = 5; i > 0; i--) begin
            if (jtag_wdata[0] == 1'b1)
                jtag_TDI = 1'b1;
            else
                jtag_TDI = 1'b0;

            if (i == 1)
                jtag_TMS = 1;

            #195;
            TDO_buf = jtag_TDO;
            #195;

            jtag_wdata = {{(35){1'b0}}, TDO_buf, jtag_wdata[4:1]};
        end
// PAUSE-IR
        jtag_TMS = 0;#195;#195;
// EXIT2-IR
        jtag_TMS = 1;#195;#195;
// UPDATE-IR
        jtag_TMS = 1; #195;#195;
// IDLE
        jtag_TMS = 0;#195;#195;
// IDLE
        jtag_TMS = 0;#195;#195;
// IDLE
        jtag_TMS = 0;#195;#195;
// IDLE
        jtag_TMS = 0;#195;#195;

        // #800;
        #100000 //6'h10, xxx, 2'b10
        jtag_wdata = {DMCONTROL, 32'h80010001,`DTM_OP_WRITE};
        WRITEJTAG(jtag_wdata);
        #100000
        jtag_wdata = {DMCONTROL, 32'h40000001, `DTM_OP_WRITE};
        WRITEJTAG(jtag_wdata);
        #100000
        jtag_wdata = {DMCONTROL, 32'h80010001,`DTM_OP_WRITE};
        WRITEJTAG(jtag_wdata);
        jtag_wdata = {6'h39, 32'h80000000, 2'b10};
        WRITEJTAG(jtag_wdata);
        #1000
        jtag_wdata = {6'h3c, 32'h0f2580000, 2'b10};
        WRITEJTAG(jtag_wdata);
        #100000
        jtag_wdata = {DMCONTROL, 32'h00000003, `DTM_OP_WRITE};
        WRITEJTAG(jtag_wdata);
        #100000
        jtag_wdata = {DMCONTROL, 32'h00000001, `DTM_OP_WRITE};
        WRITEJTAG(jtag_wdata);
    end
`endif

    //o: for lsu mtrace
// `ifdef SIM_VERILATOR_MTRACE
//     export "DPI-C" function getLsuRdInfo;
//     function void getLsuRdInfo;
//         output bit [`MYRISCV_ADDRBUS] addr_o;
//         output bit [`MYRISCV_DATABUS] data_o;
//         output bit [`MYRISCV_DATADW/8-1 : 0] rmask_o;
//     begin
//         addr_o = soc_inst.riscv_core_inst.exu_inst.lsu_inst.lsu_rop_addr;
//         data_o = soc_inst.riscv_core_inst.exu_inst.lsu_inst.lsu_rop_truedata;
//         rmask_o = soc_inst.riscv_core_inst.exu_inst.lsu_inst.lsu_rop_mask;
//     end
//     endfunction

//     export "DPI-C" function checkRd;
//     function bit checkRd;
//     begin
//         checkRd = soc_inst.riscv_core_inst.exu_inst.lsu_inst.lsu_rop_ok;
//     end
//     endfunction

//     export "DPI-C" function getLsuWrInfo;
//     function void getLsuWrInfo;
//         output bit [`MYRISCV_ADDRBUS] addr_o;
//         output bit [`MYRISCV_DATABUS] data_o;
//         output bit [`MYRISCV_DATADW/8-1 : 0] wmask_o;
//     begin
//         addr_o = soc_inst.riscv_core_inst.exu_inst.lsu_inst.lsu_wop_addr;
//         data_o = soc_inst.riscv_core_inst.exu_inst.lsu_inst.lsu_wop_data;
//         wmask_o = soc_inst.riscv_core_inst.exu_inst.lsu_inst.lsu_wop_wmask;
//     end
//     endfunction

//     export "DPI-C" function checkWr;
//     function bit checkWr;
//     begin
//         checkWr = soc_inst.riscv_core_inst.exu_inst.lsu_inst.lsu_wop_ok;
//     end
//     endfunction
// `endif

    //o: dont use in this layout, just look extern c param !
    import "DPI-C" function void MULDIV(input bit[2:0] op_type, input bit [`MYRISCV_XLEN-1 : 0] op_1, 
        input bit [`MYRISCV_XLEN-1 : 0] op_2, output bit [`MYRISCV_XLEN-1 : 0] res);
    
    
endmodule
