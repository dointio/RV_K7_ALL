# puts 100 change of signal, from time 10 start
#set signal "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_instr_i\[31:0\]"
#set start_time 10
#foreach {time value} [gtkwave::signalChangeList $signal -start_time $start_time -max 10] {
#    puts "Time: $time value: $value"
#    if { $value == 0x01C50513 } {
#        gtkwave::setMarker $time
#    }
#}

#for {set x 0} {$x<5} {incr x} {
#    puts $x;
#}

#set signal "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_instr_i\[31:0\]"
#set start_time 0
#while {1} {
#    lassign [gtkwave::signalChangeList $signal -start_time $start_time -max 10] time value
#    if { $value == 0x01C50513 } {
#        gtkwave::setMarker $time
#        break
#    } else {
#        incr start_time
#    }
#}

set signal "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_instr_i\[31:0\]"
set start_time 0

foreach {time value} [gtkwave::signalChangeList $signal -start_time $start_time -max 1000] {
   if { $value == 0x01C50513 } {
    gtkwave::setMarker $time
    puts "Time: $time value: $value"
    break
   }
}

#lassign [gtkwave::signalChangeList $signal -start_time 100 -max 1] dont_care value

#gtkwave::setMarker time_value

#gtkwave::setBaselineMarker 800
#
#gtkwave::setMarker 1200
#
#
#gtkwave::setNamedMarker 1 1200 "maker 1"
#gtkwave::setNamedMarker 2 1480 7
#gtkwave::setNamedMarker 3 1380 5

# set sig_listt [list]
# lappend sig_listt "hhh"
# set num_added [gtkwave::addCommentTracesFromList $sig_listt]

# set sig_list [list]
# lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_instr_i\[31:0\]"
# lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_pc_i\[31:0\]"
# lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.reg_inst.rf_r\[0\]\[63:0\]"
# lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.reg_inst.rf_r\[2\]\[63:0\]"
# lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.reg_inst.rf_r\[15\]\[63:0\]"
# lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.alu_inst.op1\[63:0\]"
# lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.alu_inst.op2\[63:0\]"
# lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.alu_inst.alu2wb_rdidx\[4:0\]"
# lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.alu_inst.alu2wb_data\[63:0\]"
# lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_disp_inst.dec2ex_vld"
# lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_disp_inst.dec2ex_rdy"
# lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_disp_inst.disp2alu_vld"
# lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_disp_inst.disp2alu_rdy"
# lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_disp_inst.disp2lsu_vld"
# lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_disp_inst.disp2lsu_rdy"
# lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.alu_inst.alu2wb_vld"
# lappend sig_list "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.alu_inst.alu2wb_rdy"
# set num_added [gtkwave::addSignalsFromList $sig_list]

# set high_sig [list]
# lappend high_sig "TOP.riscv_tb.soc_inst.riscv_core_inst.exu_inst.exu_disp_inst.disp2alu_rdy"
# set num_added [gtkwave::highlightSignalsFromList $high_sig]
