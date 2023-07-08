# set high_sig [list]
# lappend high_sig "TOP.biu_module_tb.gpu_inst."
# set num_added [gtkwave::highlightSignalsFromList $high_sig]

set trace_sig [list]
lappend trace_sig "icb_wire_connect"
set num_added [gtkwave::addCommentTracesFromList $trace_sig]

set sig_list [list]
lappend sig_list "TOP.biu_module_tb.icb_cmd_vld"
lappend sig_list "TOP.biu_module_tb.icb_cmd_rdy"
lappend sig_list "TOP.biu_module_tb.icb_cmd_addr"
lappend sig_list "TOP.biu_module_tb.icb_cmd_read"
lappend sig_list "TOP.biu_module_tb.icb_cmd_wdata"
lappend sig_list "TOP.biu_module_tb.icb_cmd_wmask"

lappend sig_list "TOP.biu_module_tb.icb_rsp_rdata"
lappend sig_list "TOP.biu_module_tb.icb_rsp_err"
lappend sig_list "TOP.biu_module_tb.icb_rsp_vld"
lappend sig_list "TOP.biu_module_tb.icb_rsp_rdy"
set num_added [gtkwave::addSignalsFromList $sig_list]


#for gpu test (start)
set gpu_sel_sig [list]
lappend gpu_sel_sig "gpu_sels"
set num_added [gtkwave::addCommentTracesFromList $gpu_sel_sig]

set sig_list [list]
lappend sig_list "TOP.biu_module_tb.gpu_inst.gpu_config_sel"
lappend sig_list "TOP.biu_module_tb.gpu_inst.gpu_sync_sel"
lappend sig_list "TOP.biu_module_tb.gpu_inst.gpu_state_sel"
lappend sig_list "TOP.biu_module_tb.gpu_inst.reg_rgb_sel"
lappend sig_list "TOP.biu_module_tb.gpu_inst.gpu_config_sel_r"
lappend sig_list "TOP.biu_module_tb.gpu_inst.gpu_sync_sel_r"
lappend sig_list "TOP.biu_module_tb.gpu_inst.gpu_state_sel_r"
lappend sig_list "TOP.biu_module_tb.gpu_inst.reg_rgb_sel_r"
set num_added [gtkwave::addSignalsFromList $sig_list]

set gpu_sig_trace [list]
lappend gpu_sig_trace "vga_cnts"
set num_added [gtkwave::addCommentTracesFromList $gpu_sig_trace]

set sig_list [list]
lappend sig_list "TOP.biu_module_tb.gpu_inst.h_cnt"
lappend sig_list "TOP.biu_module_tb.gpu_inst.p_cnt"
lappend sig_list "TOP.biu_module_tb.gpu_inst.pix_cnt"
set num_added [gtkwave::addSignalsFromList $sig_list]

set gpu_sig_trace [list]
lappend gpu_sig_trace "vga_signal"
set num_added [gtkwave::addCommentTracesFromList $gpu_sig_trace]

set sig_list [list]
lappend sig_list "TOP.biu_module_tb.gpu_inst.vga_busy"
lappend sig_list "TOP.biu_module_tb.gpu_inst.vga_vsync"
lappend sig_list "TOP.biu_module_tb.gpu_inst.vga_hsync"
lappend sig_list "TOP.biu_module_tb.gpu_inst.vga_en"
lappend sig_list "TOP.biu_module_tb.gpu_inst.vga_data"
set num_added [gtkwave::addSignalsFromList $sig_list]

#for gpu test (end)



