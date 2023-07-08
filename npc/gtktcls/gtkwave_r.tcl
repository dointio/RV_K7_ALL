
set sig_list [list]
lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_instr_i\[31:0\]"
lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_pc_i\[31:0\]"
lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.reg_inst.rf_r\[0\]\[63:0\]"
lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.reg_inst.rf_r\[2\]\[63:0\]"
lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.reg_inst.rf_r\[15\]\[63:0\]"
lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.alu_inst.op1\[63:0\]"
lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.alu_inst.op2\[63:0\]"
lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.alu_inst.alu2wb_rdidx\[4:0\]"
lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.alu_inst.alu2wb_data\[63:0\]"
lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_disp_inst.dec2ex_vld"
lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_disp_inst.dec2ex_rdy"
lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_disp_inst.disp2alu_vld"
lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_disp_inst.disp2alu_rdy"
lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_disp_inst.disp2lsu_vld"
lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_disp_inst.disp2lsu_rdy"
lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.alu_inst.alu2wb_vld"
lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.alu_inst.alu2wb_rdy"

set num_added [gtkwave::addSignalsFromList $sig_list]





