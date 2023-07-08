// `include "defines.v"
`include "mydefines.v"
module core_tb
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

// sim timeout
    initial begin
        // #200000
        #2000000
        $display("Time Out.");
        $finish;
    end

    `ifdef FSDB
        initial begin
            $fsdbDumpfile("../vcs/wave.fsdb");
            $fsdbDumpvars("+mda");
        end 
    `endif
    `ifdef VERILATOR_TB_DUMPFILE
    initial begin
        $dumpfile ("verilog_core.vcd");
        $dumpvars (8, core_inst);
    end
    `endif


    riscv_core_new core_inst
    (
        .clk                (clk),
        .rst                (rst)
    );


    // read mem data
    // initial begin
    //     `ifdef SIM_VERILATOR
    //         $readmemh ("./tests/mygpio_rv64.data", core_inst.flash_inst.mem_inst.mem_r);
    //         $display("%16h, %16h, %16h, %16h", core_inst.flash_inst.mem_inst.mem_r[0], core_inst.flash_inst.mem_inst.mem_r[1], core_inst.flash_inst.mem_inst.mem_r[2], core_inst.flash_inst.mem_inst.mem_r[3]);
    //     `endif        
    // end
 
    

endmodule
