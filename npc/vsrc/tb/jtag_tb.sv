// `include "defines.v"
`include "mydefines.v"
module jtag_tb
();

    reg clk;
    reg rst;

    initial begin
        clk = 0;
        forever begin
            #10 clk = ~clk;
        end
    end

    initial begin
        rst = 0;
        #45
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
    end
`endif

`ifdef VERILATOR_TB_DUMPFILE
    initial begin
        $dumpfile ("jtag_tb.vcd");
        $dumpvars (8, soc_inst);
    end
`endif

    // read mem data
    initial begin
        $readmemh ("./tests/mygpio_rv64.data", soc_inst.flash_inst.mem_inst.mem_r);
    end

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

    reg jtag_TCK, jtag_TMS, jtag_TDI;
    wire jtag_TDO;
    reg [39:0] jtag_wdata;
    reg TDO_buf;
    integer i;
    initial begin
        jtag_TCK = 0;
        `ifdef TEST_JTAG
            forever begin
                #195;
                jtag_TCK = ~jtag_TCK;
            end
        `endif
    end

    task WRITEJTAG;
        input [39:0] dr_data;

        // wait(jtag_TCK == 0);
        @(negedge jtag_TCK);

        // SELECT-DR
        jtag_TMS = 1;
        #195;
        #195;

        // CAPTURE-DR
        jtag_TMS = 0;
        #195;
        #195;

        // SHIFT-DR
        jtag_TMS = 0;
        #195;
        #195;

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
        jtag_TMS = 0;
        #195;
        #195;

        // EXIT2-DR
        jtag_TMS = 1;
        #195;
        #195;

        // UPDATE-DR
        jtag_TMS = 1;
        #195;
        #195;

        // IDLE
        jtag_TMS = 0;
        #195;
        #195;
        // IDLE
        jtag_TMS = 0;
        #195;
        #195;
        // IDLE
        jtag_TMS = 0;
        #195;
        #195;
        // IDLE
        jtag_TMS = 0;
        #195;
        #195;
    endtask

    initial begin
        jtag_TMS = 0;
        jtag_TDI = 0;
        `ifdef TEST_JTAG
            #4000
            @ (negedge jtag_TCK);
            // reset
            for (i = 0; i < 8; i++) begin
                jtag_TMS = 1;
                #195;
                #195;
            end

            // IR
            jtag_wdata = 40'b10001;

            // IDLE
            jtag_TMS = 0;
            #195;
            #195;

            // SELECT-DR
            jtag_TMS = 1;
            #195;
            #195;

            // SELECT-IR
            jtag_TMS = 1;
            #195;
            #195;

            // CAPTURE-IR
            jtag_TMS = 0;
            #195;
            #195;

            // SHIFT-IR
            jtag_TMS = 0;
            #195;
            #195;

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
            jtag_TMS = 0;
            #195;
            #195;

            // EXIT2-IR
            jtag_TMS = 1;
            #195;
            #195;

            // UPDATE-IR
            jtag_TMS = 1; 
            #195;
            #195;

            // IDLE
            jtag_TMS = 0;
            #195;
            #195;

            // IDLE
            jtag_TMS = 0;
            #195;
            #195;

            // IDLE
            jtag_TMS = 0;
            #195;
            #195;

            // IDLE
            jtag_TMS = 0;
            #195;
            #195;

            // #800;
            #50000
            jtag_wdata = {DMCONTROL, 32'h80010001,`DTM_OP_WRITE};
            WRITEJTAG(jtag_wdata);
            #100000
            jtag_wdata = {DMCONTROL, 32'h40000001, `DTM_OP_WRITE};
            WRITEJTAG(jtag_wdata);
            #100000
            jtag_wdata = {DMCONTROL, 6'h39, 32'h80000000, 2'b10,,`DTM_OP_WRITE};
            WRITEJTAG(jtag_wdata);
            #1000
            jtag_wdata = {DMCONTROL, 6'h3c, 32'h0f2580000, 2'b10,,`DTM_OP_WRITE};
            WRITEJTAG(jtag_wdata);
            #100000
            jtag_wdata = {DMCONTROL, 32'h0011,`DTM_OP_WRITE};
            WRITEJTAG(jtag_wdata);
            // #500000
            // jtag_wdata = {DMCONTROL, 32'h00000003, `DTM_OP_WRITE};
            // WRITEJTAG(jtag_wdata);
            // #500000
            // jtag_wdata = {DMCONTROL, 32'h00000001, `DTM_OP_WRITE};
            // WRITEJTAG(jtag_wdata);
        `endif
    end




    wire [7:0] gpio_o;

    riscv_soc soc_inst
    (
        .clk             (clk),
        .rst             (rst),
        
        .jtag_TCK        (jtag_TCK),
        .jtag_TMS        (jtag_TMS),
        .jtag_TDI        (jtag_TDI),
        .jtag_TDO        (jtag_TDO),

        .gpio_o          (gpio_o)//,

        // .pix_clk            (),
        // .vga_vsync          (),
        // .vga_hsync          (),
        // .vga_en             (),
        // .vga_data           ()
    );

endmodule
