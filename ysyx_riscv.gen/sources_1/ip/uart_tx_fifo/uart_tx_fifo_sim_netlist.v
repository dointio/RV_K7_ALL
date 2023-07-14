// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Sat Jul  8 20:59:52 2023
// Host        : DESKTOP-T33H4FP running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               e:/Study-riscv-all-zxp/ysyx_riscv.gen/sources_1/ip/uart_tx_fifo/uart_tx_fifo_sim_netlist.v
// Design      : uart_tx_fifo
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k325tffg676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "uart_tx_fifo,fifo_generator_v13_2_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "fifo_generator_v13_2_5,Vivado 2020.2" *) 
(* NotValidForBitStream *)
module uart_tx_fifo
   (rst,
    wr_clk,
    rd_clk,
    din,
    wr_en,
    rd_en,
    dout,
    full,
    empty);
  input rst;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 write_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME write_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0" *) input wr_clk;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 read_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME read_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0" *) input rd_clk;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_DATA" *) input [7:0]din;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_EN" *) input wr_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_EN" *) input rd_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_DATA" *) output [7:0]dout;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE FULL" *) output full;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ EMPTY" *) output empty;

  wire [7:0]din;
  wire [7:0]dout;
  wire empty;
  wire full;
  wire rd_clk;
  wire rd_en;
  wire rst;
  wire wr_clk;
  wire wr_en;
  wire NLW_U0_almost_empty_UNCONNECTED;
  wire NLW_U0_almost_full_UNCONNECTED;
  wire NLW_U0_axi_ar_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_ar_overflow_UNCONNECTED;
  wire NLW_U0_axi_ar_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_ar_prog_full_UNCONNECTED;
  wire NLW_U0_axi_ar_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_ar_underflow_UNCONNECTED;
  wire NLW_U0_axi_aw_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_aw_overflow_UNCONNECTED;
  wire NLW_U0_axi_aw_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_aw_prog_full_UNCONNECTED;
  wire NLW_U0_axi_aw_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_aw_underflow_UNCONNECTED;
  wire NLW_U0_axi_b_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_b_overflow_UNCONNECTED;
  wire NLW_U0_axi_b_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_b_prog_full_UNCONNECTED;
  wire NLW_U0_axi_b_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_b_underflow_UNCONNECTED;
  wire NLW_U0_axi_r_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_r_overflow_UNCONNECTED;
  wire NLW_U0_axi_r_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_r_prog_full_UNCONNECTED;
  wire NLW_U0_axi_r_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_r_underflow_UNCONNECTED;
  wire NLW_U0_axi_w_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_w_overflow_UNCONNECTED;
  wire NLW_U0_axi_w_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_w_prog_full_UNCONNECTED;
  wire NLW_U0_axi_w_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_w_underflow_UNCONNECTED;
  wire NLW_U0_axis_dbiterr_UNCONNECTED;
  wire NLW_U0_axis_overflow_UNCONNECTED;
  wire NLW_U0_axis_prog_empty_UNCONNECTED;
  wire NLW_U0_axis_prog_full_UNCONNECTED;
  wire NLW_U0_axis_sbiterr_UNCONNECTED;
  wire NLW_U0_axis_underflow_UNCONNECTED;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_m_axi_arvalid_UNCONNECTED;
  wire NLW_U0_m_axi_awvalid_UNCONNECTED;
  wire NLW_U0_m_axi_bready_UNCONNECTED;
  wire NLW_U0_m_axi_rready_UNCONNECTED;
  wire NLW_U0_m_axi_wlast_UNCONNECTED;
  wire NLW_U0_m_axi_wvalid_UNCONNECTED;
  wire NLW_U0_m_axis_tlast_UNCONNECTED;
  wire NLW_U0_m_axis_tvalid_UNCONNECTED;
  wire NLW_U0_overflow_UNCONNECTED;
  wire NLW_U0_prog_empty_UNCONNECTED;
  wire NLW_U0_prog_full_UNCONNECTED;
  wire NLW_U0_rd_rst_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_s_axis_tready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire NLW_U0_underflow_UNCONNECTED;
  wire NLW_U0_valid_UNCONNECTED;
  wire NLW_U0_wr_ack_UNCONNECTED;
  wire NLW_U0_wr_rst_busy_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_wr_data_count_UNCONNECTED;
  wire [5:0]NLW_U0_data_count_UNCONNECTED;
  wire [31:0]NLW_U0_m_axi_araddr_UNCONNECTED;
  wire [1:0]NLW_U0_m_axi_arburst_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arcache_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_arid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_arlen_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_arlock_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_arprot_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arqos_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arregion_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_arsize_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_aruser_UNCONNECTED;
  wire [31:0]NLW_U0_m_axi_awaddr_UNCONNECTED;
  wire [1:0]NLW_U0_m_axi_awburst_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awcache_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_awlen_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awlock_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_awprot_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awqos_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awregion_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_awsize_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awuser_UNCONNECTED;
  wire [63:0]NLW_U0_m_axi_wdata_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_wid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_wstrb_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_wuser_UNCONNECTED;
  wire [7:0]NLW_U0_m_axis_tdata_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tdest_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tid_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tkeep_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tstrb_UNCONNECTED;
  wire [3:0]NLW_U0_m_axis_tuser_UNCONNECTED;
  wire [5:0]NLW_U0_rd_data_count_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_buser_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_ruser_UNCONNECTED;
  wire [5:0]NLW_U0_wr_data_count_UNCONNECTED;

  (* C_ADD_NGC_CONSTRAINT = "0" *) 
  (* C_APPLICATION_TYPE_AXIS = "0" *) 
  (* C_APPLICATION_TYPE_RACH = "0" *) 
  (* C_APPLICATION_TYPE_RDCH = "0" *) 
  (* C_APPLICATION_TYPE_WACH = "0" *) 
  (* C_APPLICATION_TYPE_WDCH = "0" *) 
  (* C_APPLICATION_TYPE_WRCH = "0" *) 
  (* C_AXIS_TDATA_WIDTH = "8" *) 
  (* C_AXIS_TDEST_WIDTH = "1" *) 
  (* C_AXIS_TID_WIDTH = "1" *) 
  (* C_AXIS_TKEEP_WIDTH = "1" *) 
  (* C_AXIS_TSTRB_WIDTH = "1" *) 
  (* C_AXIS_TUSER_WIDTH = "4" *) 
  (* C_AXIS_TYPE = "0" *) 
  (* C_AXI_ADDR_WIDTH = "32" *) 
  (* C_AXI_ARUSER_WIDTH = "1" *) 
  (* C_AXI_AWUSER_WIDTH = "1" *) 
  (* C_AXI_BUSER_WIDTH = "1" *) 
  (* C_AXI_DATA_WIDTH = "64" *) 
  (* C_AXI_ID_WIDTH = "1" *) 
  (* C_AXI_LEN_WIDTH = "8" *) 
  (* C_AXI_LOCK_WIDTH = "1" *) 
  (* C_AXI_RUSER_WIDTH = "1" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_AXI_WUSER_WIDTH = "1" *) 
  (* C_COMMON_CLOCK = "0" *) 
  (* C_COUNT_TYPE = "0" *) 
  (* C_DATA_COUNT_WIDTH = "6" *) 
  (* C_DEFAULT_VALUE = "BlankString" *) 
  (* C_DIN_WIDTH = "8" *) 
  (* C_DIN_WIDTH_AXIS = "1" *) 
  (* C_DIN_WIDTH_RACH = "32" *) 
  (* C_DIN_WIDTH_RDCH = "64" *) 
  (* C_DIN_WIDTH_WACH = "1" *) 
  (* C_DIN_WIDTH_WDCH = "64" *) 
  (* C_DIN_WIDTH_WRCH = "2" *) 
  (* C_DOUT_RST_VAL = "0" *) 
  (* C_DOUT_WIDTH = "8" *) 
  (* C_ENABLE_RLOCS = "0" *) 
  (* C_ENABLE_RST_SYNC = "1" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_ERROR_INJECTION_TYPE = "0" *) 
  (* C_ERROR_INJECTION_TYPE_AXIS = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WRCH = "0" *) 
  (* C_FAMILY = "kintex7" *) 
  (* C_FULL_FLAGS_RST_VAL = "1" *) 
  (* C_HAS_ALMOST_EMPTY = "0" *) 
  (* C_HAS_ALMOST_FULL = "0" *) 
  (* C_HAS_AXIS_TDATA = "1" *) 
  (* C_HAS_AXIS_TDEST = "0" *) 
  (* C_HAS_AXIS_TID = "0" *) 
  (* C_HAS_AXIS_TKEEP = "0" *) 
  (* C_HAS_AXIS_TLAST = "0" *) 
  (* C_HAS_AXIS_TREADY = "1" *) 
  (* C_HAS_AXIS_TSTRB = "0" *) 
  (* C_HAS_AXIS_TUSER = "1" *) 
  (* C_HAS_AXI_ARUSER = "0" *) 
  (* C_HAS_AXI_AWUSER = "0" *) 
  (* C_HAS_AXI_BUSER = "0" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_AXI_RD_CHANNEL = "1" *) 
  (* C_HAS_AXI_RUSER = "0" *) 
  (* C_HAS_AXI_WR_CHANNEL = "1" *) 
  (* C_HAS_AXI_WUSER = "0" *) 
  (* C_HAS_BACKUP = "0" *) 
  (* C_HAS_DATA_COUNT = "0" *) 
  (* C_HAS_DATA_COUNTS_AXIS = "0" *) 
  (* C_HAS_DATA_COUNTS_RACH = "0" *) 
  (* C_HAS_DATA_COUNTS_RDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WACH = "0" *) 
  (* C_HAS_DATA_COUNTS_WDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WRCH = "0" *) 
  (* C_HAS_INT_CLK = "0" *) 
  (* C_HAS_MASTER_CE = "0" *) 
  (* C_HAS_MEMINIT_FILE = "0" *) 
  (* C_HAS_OVERFLOW = "0" *) 
  (* C_HAS_PROG_FLAGS_AXIS = "0" *) 
  (* C_HAS_PROG_FLAGS_RACH = "0" *) 
  (* C_HAS_PROG_FLAGS_RDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WACH = "0" *) 
  (* C_HAS_PROG_FLAGS_WDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WRCH = "0" *) 
  (* C_HAS_RD_DATA_COUNT = "0" *) 
  (* C_HAS_RD_RST = "0" *) 
  (* C_HAS_RST = "1" *) 
  (* C_HAS_SLAVE_CE = "0" *) 
  (* C_HAS_SRST = "0" *) 
  (* C_HAS_UNDERFLOW = "0" *) 
  (* C_HAS_VALID = "0" *) 
  (* C_HAS_WR_ACK = "0" *) 
  (* C_HAS_WR_DATA_COUNT = "0" *) 
  (* C_HAS_WR_RST = "0" *) 
  (* C_IMPLEMENTATION_TYPE = "2" *) 
  (* C_IMPLEMENTATION_TYPE_AXIS = "1" *) 
  (* C_IMPLEMENTATION_TYPE_RACH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_RDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WACH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WRCH = "1" *) 
  (* C_INIT_WR_PNTR_VAL = "0" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_MEMORY_TYPE = "2" *) 
  (* C_MIF_FILE_NAME = "BlankString" *) 
  (* C_MSGON_VAL = "1" *) 
  (* C_OPTIMIZATION_MODE = "0" *) 
  (* C_OVERFLOW_LOW = "0" *) 
  (* C_POWER_SAVING_MODE = "0" *) 
  (* C_PRELOAD_LATENCY = "0" *) 
  (* C_PRELOAD_REGS = "1" *) 
  (* C_PRIM_FIFO_TYPE = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_AXIS = "1kx18" *) 
  (* C_PRIM_FIFO_TYPE_RACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_RDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_WDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WRCH = "512x36" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL = "4" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_NEGATE_VAL = "5" *) 
  (* C_PROG_EMPTY_TYPE = "0" *) 
  (* C_PROG_EMPTY_TYPE_AXIS = "0" *) 
  (* C_PROG_EMPTY_TYPE_RACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_RDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WRCH = "0" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL = "63" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_AXIS = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WRCH = "1023" *) 
  (* C_PROG_FULL_THRESH_NEGATE_VAL = "62" *) 
  (* C_PROG_FULL_TYPE = "0" *) 
  (* C_PROG_FULL_TYPE_AXIS = "0" *) 
  (* C_PROG_FULL_TYPE_RACH = "0" *) 
  (* C_PROG_FULL_TYPE_RDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WACH = "0" *) 
  (* C_PROG_FULL_TYPE_WDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WRCH = "0" *) 
  (* C_RACH_TYPE = "0" *) 
  (* C_RDCH_TYPE = "0" *) 
  (* C_RD_DATA_COUNT_WIDTH = "6" *) 
  (* C_RD_DEPTH = "64" *) 
  (* C_RD_FREQ = "1" *) 
  (* C_RD_PNTR_WIDTH = "6" *) 
  (* C_REG_SLICE_MODE_AXIS = "0" *) 
  (* C_REG_SLICE_MODE_RACH = "0" *) 
  (* C_REG_SLICE_MODE_RDCH = "0" *) 
  (* C_REG_SLICE_MODE_WACH = "0" *) 
  (* C_REG_SLICE_MODE_WDCH = "0" *) 
  (* C_REG_SLICE_MODE_WRCH = "0" *) 
  (* C_SELECT_XPM = "0" *) 
  (* C_SYNCHRONIZER_STAGE = "2" *) 
  (* C_UNDERFLOW_LOW = "0" *) 
  (* C_USE_COMMON_OVERFLOW = "0" *) 
  (* C_USE_COMMON_UNDERFLOW = "0" *) 
  (* C_USE_DEFAULT_SETTINGS = "0" *) 
  (* C_USE_DOUT_RST = "1" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_ECC_AXIS = "0" *) 
  (* C_USE_ECC_RACH = "0" *) 
  (* C_USE_ECC_RDCH = "0" *) 
  (* C_USE_ECC_WACH = "0" *) 
  (* C_USE_ECC_WDCH = "0" *) 
  (* C_USE_ECC_WRCH = "0" *) 
  (* C_USE_EMBEDDED_REG = "0" *) 
  (* C_USE_FIFO16_FLAGS = "0" *) 
  (* C_USE_FWFT_DATA_COUNT = "0" *) 
  (* C_USE_PIPELINE_REG = "0" *) 
  (* C_VALID_LOW = "0" *) 
  (* C_WACH_TYPE = "0" *) 
  (* C_WDCH_TYPE = "0" *) 
  (* C_WRCH_TYPE = "0" *) 
  (* C_WR_ACK_LOW = "0" *) 
  (* C_WR_DATA_COUNT_WIDTH = "6" *) 
  (* C_WR_DEPTH = "64" *) 
  (* C_WR_DEPTH_AXIS = "1024" *) 
  (* C_WR_DEPTH_RACH = "16" *) 
  (* C_WR_DEPTH_RDCH = "1024" *) 
  (* C_WR_DEPTH_WACH = "16" *) 
  (* C_WR_DEPTH_WDCH = "1024" *) 
  (* C_WR_DEPTH_WRCH = "16" *) 
  (* C_WR_FREQ = "1" *) 
  (* C_WR_PNTR_WIDTH = "6" *) 
  (* C_WR_PNTR_WIDTH_AXIS = "10" *) 
  (* C_WR_PNTR_WIDTH_RACH = "4" *) 
  (* C_WR_PNTR_WIDTH_RDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WACH = "4" *) 
  (* C_WR_PNTR_WIDTH_WDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WRCH = "4" *) 
  (* C_WR_RESPONSE_LATENCY = "1" *) 
  (* is_du_within_envelope = "true" *) 
  uart_tx_fifo_fifo_generator_v13_2_5 U0
       (.almost_empty(NLW_U0_almost_empty_UNCONNECTED),
        .almost_full(NLW_U0_almost_full_UNCONNECTED),
        .axi_ar_data_count(NLW_U0_axi_ar_data_count_UNCONNECTED[4:0]),
        .axi_ar_dbiterr(NLW_U0_axi_ar_dbiterr_UNCONNECTED),
        .axi_ar_injectdbiterr(1'b0),
        .axi_ar_injectsbiterr(1'b0),
        .axi_ar_overflow(NLW_U0_axi_ar_overflow_UNCONNECTED),
        .axi_ar_prog_empty(NLW_U0_axi_ar_prog_empty_UNCONNECTED),
        .axi_ar_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_prog_full(NLW_U0_axi_ar_prog_full_UNCONNECTED),
        .axi_ar_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_rd_data_count(NLW_U0_axi_ar_rd_data_count_UNCONNECTED[4:0]),
        .axi_ar_sbiterr(NLW_U0_axi_ar_sbiterr_UNCONNECTED),
        .axi_ar_underflow(NLW_U0_axi_ar_underflow_UNCONNECTED),
        .axi_ar_wr_data_count(NLW_U0_axi_ar_wr_data_count_UNCONNECTED[4:0]),
        .axi_aw_data_count(NLW_U0_axi_aw_data_count_UNCONNECTED[4:0]),
        .axi_aw_dbiterr(NLW_U0_axi_aw_dbiterr_UNCONNECTED),
        .axi_aw_injectdbiterr(1'b0),
        .axi_aw_injectsbiterr(1'b0),
        .axi_aw_overflow(NLW_U0_axi_aw_overflow_UNCONNECTED),
        .axi_aw_prog_empty(NLW_U0_axi_aw_prog_empty_UNCONNECTED),
        .axi_aw_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_prog_full(NLW_U0_axi_aw_prog_full_UNCONNECTED),
        .axi_aw_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_rd_data_count(NLW_U0_axi_aw_rd_data_count_UNCONNECTED[4:0]),
        .axi_aw_sbiterr(NLW_U0_axi_aw_sbiterr_UNCONNECTED),
        .axi_aw_underflow(NLW_U0_axi_aw_underflow_UNCONNECTED),
        .axi_aw_wr_data_count(NLW_U0_axi_aw_wr_data_count_UNCONNECTED[4:0]),
        .axi_b_data_count(NLW_U0_axi_b_data_count_UNCONNECTED[4:0]),
        .axi_b_dbiterr(NLW_U0_axi_b_dbiterr_UNCONNECTED),
        .axi_b_injectdbiterr(1'b0),
        .axi_b_injectsbiterr(1'b0),
        .axi_b_overflow(NLW_U0_axi_b_overflow_UNCONNECTED),
        .axi_b_prog_empty(NLW_U0_axi_b_prog_empty_UNCONNECTED),
        .axi_b_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_prog_full(NLW_U0_axi_b_prog_full_UNCONNECTED),
        .axi_b_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_rd_data_count(NLW_U0_axi_b_rd_data_count_UNCONNECTED[4:0]),
        .axi_b_sbiterr(NLW_U0_axi_b_sbiterr_UNCONNECTED),
        .axi_b_underflow(NLW_U0_axi_b_underflow_UNCONNECTED),
        .axi_b_wr_data_count(NLW_U0_axi_b_wr_data_count_UNCONNECTED[4:0]),
        .axi_r_data_count(NLW_U0_axi_r_data_count_UNCONNECTED[10:0]),
        .axi_r_dbiterr(NLW_U0_axi_r_dbiterr_UNCONNECTED),
        .axi_r_injectdbiterr(1'b0),
        .axi_r_injectsbiterr(1'b0),
        .axi_r_overflow(NLW_U0_axi_r_overflow_UNCONNECTED),
        .axi_r_prog_empty(NLW_U0_axi_r_prog_empty_UNCONNECTED),
        .axi_r_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_prog_full(NLW_U0_axi_r_prog_full_UNCONNECTED),
        .axi_r_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_rd_data_count(NLW_U0_axi_r_rd_data_count_UNCONNECTED[10:0]),
        .axi_r_sbiterr(NLW_U0_axi_r_sbiterr_UNCONNECTED),
        .axi_r_underflow(NLW_U0_axi_r_underflow_UNCONNECTED),
        .axi_r_wr_data_count(NLW_U0_axi_r_wr_data_count_UNCONNECTED[10:0]),
        .axi_w_data_count(NLW_U0_axi_w_data_count_UNCONNECTED[10:0]),
        .axi_w_dbiterr(NLW_U0_axi_w_dbiterr_UNCONNECTED),
        .axi_w_injectdbiterr(1'b0),
        .axi_w_injectsbiterr(1'b0),
        .axi_w_overflow(NLW_U0_axi_w_overflow_UNCONNECTED),
        .axi_w_prog_empty(NLW_U0_axi_w_prog_empty_UNCONNECTED),
        .axi_w_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_prog_full(NLW_U0_axi_w_prog_full_UNCONNECTED),
        .axi_w_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_rd_data_count(NLW_U0_axi_w_rd_data_count_UNCONNECTED[10:0]),
        .axi_w_sbiterr(NLW_U0_axi_w_sbiterr_UNCONNECTED),
        .axi_w_underflow(NLW_U0_axi_w_underflow_UNCONNECTED),
        .axi_w_wr_data_count(NLW_U0_axi_w_wr_data_count_UNCONNECTED[10:0]),
        .axis_data_count(NLW_U0_axis_data_count_UNCONNECTED[10:0]),
        .axis_dbiterr(NLW_U0_axis_dbiterr_UNCONNECTED),
        .axis_injectdbiterr(1'b0),
        .axis_injectsbiterr(1'b0),
        .axis_overflow(NLW_U0_axis_overflow_UNCONNECTED),
        .axis_prog_empty(NLW_U0_axis_prog_empty_UNCONNECTED),
        .axis_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_prog_full(NLW_U0_axis_prog_full_UNCONNECTED),
        .axis_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_rd_data_count(NLW_U0_axis_rd_data_count_UNCONNECTED[10:0]),
        .axis_sbiterr(NLW_U0_axis_sbiterr_UNCONNECTED),
        .axis_underflow(NLW_U0_axis_underflow_UNCONNECTED),
        .axis_wr_data_count(NLW_U0_axis_wr_data_count_UNCONNECTED[10:0]),
        .backup(1'b0),
        .backup_marker(1'b0),
        .clk(1'b0),
        .data_count(NLW_U0_data_count_UNCONNECTED[5:0]),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .din(din),
        .dout(dout),
        .empty(empty),
        .full(full),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .int_clk(1'b0),
        .m_aclk(1'b0),
        .m_aclk_en(1'b0),
        .m_axi_araddr(NLW_U0_m_axi_araddr_UNCONNECTED[31:0]),
        .m_axi_arburst(NLW_U0_m_axi_arburst_UNCONNECTED[1:0]),
        .m_axi_arcache(NLW_U0_m_axi_arcache_UNCONNECTED[3:0]),
        .m_axi_arid(NLW_U0_m_axi_arid_UNCONNECTED[0]),
        .m_axi_arlen(NLW_U0_m_axi_arlen_UNCONNECTED[7:0]),
        .m_axi_arlock(NLW_U0_m_axi_arlock_UNCONNECTED[0]),
        .m_axi_arprot(NLW_U0_m_axi_arprot_UNCONNECTED[2:0]),
        .m_axi_arqos(NLW_U0_m_axi_arqos_UNCONNECTED[3:0]),
        .m_axi_arready(1'b0),
        .m_axi_arregion(NLW_U0_m_axi_arregion_UNCONNECTED[3:0]),
        .m_axi_arsize(NLW_U0_m_axi_arsize_UNCONNECTED[2:0]),
        .m_axi_aruser(NLW_U0_m_axi_aruser_UNCONNECTED[0]),
        .m_axi_arvalid(NLW_U0_m_axi_arvalid_UNCONNECTED),
        .m_axi_awaddr(NLW_U0_m_axi_awaddr_UNCONNECTED[31:0]),
        .m_axi_awburst(NLW_U0_m_axi_awburst_UNCONNECTED[1:0]),
        .m_axi_awcache(NLW_U0_m_axi_awcache_UNCONNECTED[3:0]),
        .m_axi_awid(NLW_U0_m_axi_awid_UNCONNECTED[0]),
        .m_axi_awlen(NLW_U0_m_axi_awlen_UNCONNECTED[7:0]),
        .m_axi_awlock(NLW_U0_m_axi_awlock_UNCONNECTED[0]),
        .m_axi_awprot(NLW_U0_m_axi_awprot_UNCONNECTED[2:0]),
        .m_axi_awqos(NLW_U0_m_axi_awqos_UNCONNECTED[3:0]),
        .m_axi_awready(1'b0),
        .m_axi_awregion(NLW_U0_m_axi_awregion_UNCONNECTED[3:0]),
        .m_axi_awsize(NLW_U0_m_axi_awsize_UNCONNECTED[2:0]),
        .m_axi_awuser(NLW_U0_m_axi_awuser_UNCONNECTED[0]),
        .m_axi_awvalid(NLW_U0_m_axi_awvalid_UNCONNECTED),
        .m_axi_bid(1'b0),
        .m_axi_bready(NLW_U0_m_axi_bready_UNCONNECTED),
        .m_axi_bresp({1'b0,1'b0}),
        .m_axi_buser(1'b0),
        .m_axi_bvalid(1'b0),
        .m_axi_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_axi_rid(1'b0),
        .m_axi_rlast(1'b0),
        .m_axi_rready(NLW_U0_m_axi_rready_UNCONNECTED),
        .m_axi_rresp({1'b0,1'b0}),
        .m_axi_ruser(1'b0),
        .m_axi_rvalid(1'b0),
        .m_axi_wdata(NLW_U0_m_axi_wdata_UNCONNECTED[63:0]),
        .m_axi_wid(NLW_U0_m_axi_wid_UNCONNECTED[0]),
        .m_axi_wlast(NLW_U0_m_axi_wlast_UNCONNECTED),
        .m_axi_wready(1'b0),
        .m_axi_wstrb(NLW_U0_m_axi_wstrb_UNCONNECTED[7:0]),
        .m_axi_wuser(NLW_U0_m_axi_wuser_UNCONNECTED[0]),
        .m_axi_wvalid(NLW_U0_m_axi_wvalid_UNCONNECTED),
        .m_axis_tdata(NLW_U0_m_axis_tdata_UNCONNECTED[7:0]),
        .m_axis_tdest(NLW_U0_m_axis_tdest_UNCONNECTED[0]),
        .m_axis_tid(NLW_U0_m_axis_tid_UNCONNECTED[0]),
        .m_axis_tkeep(NLW_U0_m_axis_tkeep_UNCONNECTED[0]),
        .m_axis_tlast(NLW_U0_m_axis_tlast_UNCONNECTED),
        .m_axis_tready(1'b0),
        .m_axis_tstrb(NLW_U0_m_axis_tstrb_UNCONNECTED[0]),
        .m_axis_tuser(NLW_U0_m_axis_tuser_UNCONNECTED[3:0]),
        .m_axis_tvalid(NLW_U0_m_axis_tvalid_UNCONNECTED),
        .overflow(NLW_U0_overflow_UNCONNECTED),
        .prog_empty(NLW_U0_prog_empty_UNCONNECTED),
        .prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full(NLW_U0_prog_full_UNCONNECTED),
        .prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .rd_clk(rd_clk),
        .rd_data_count(NLW_U0_rd_data_count_UNCONNECTED[5:0]),
        .rd_en(rd_en),
        .rd_rst(1'b0),
        .rd_rst_busy(NLW_U0_rd_rst_busy_UNCONNECTED),
        .rst(rst),
        .s_aclk(1'b0),
        .s_aclk_en(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arid(1'b0),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlock(1'b0),
        .s_axi_arprot({1'b0,1'b0,1'b0}),
        .s_axi_arqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_aruser(1'b0),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awid(1'b0),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlock(1'b0),
        .s_axi_awprot({1'b0,1'b0,1'b0}),
        .s_axi_awqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awuser(1'b0),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_buser(NLW_U0_s_axi_buser_UNCONNECTED[0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[63:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_ruser(NLW_U0_s_axi_ruser_UNCONNECTED[0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wid(1'b0),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wuser(1'b0),
        .s_axi_wvalid(1'b0),
        .s_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tdest(1'b0),
        .s_axis_tid(1'b0),
        .s_axis_tkeep(1'b0),
        .s_axis_tlast(1'b0),
        .s_axis_tready(NLW_U0_s_axis_tready_UNCONNECTED),
        .s_axis_tstrb(1'b0),
        .s_axis_tuser({1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .sleep(1'b0),
        .srst(1'b0),
        .underflow(NLW_U0_underflow_UNCONNECTED),
        .valid(NLW_U0_valid_UNCONNECTED),
        .wr_ack(NLW_U0_wr_ack_UNCONNECTED),
        .wr_clk(wr_clk),
        .wr_data_count(NLW_U0_wr_data_count_UNCONNECTED[5:0]),
        .wr_en(wr_en),
        .wr_rst(1'b0),
        .wr_rst_busy(NLW_U0_wr_rst_busy_UNCONNECTED));
endmodule

(* DEF_VAL = "1'b0" *) (* DEST_SYNC_FF = "2" *) (* INIT_SYNC_FF = "0" *) 
(* INV_DEF_VAL = "1'b1" *) (* ORIG_REF_NAME = "xpm_cdc_async_rst" *) (* RST_ACTIVE_HIGH = "1" *) 
(* VERSION = "0" *) (* XPM_MODULE = "TRUE" *) (* is_du_within_envelope = "true" *) 
(* keep_hierarchy = "true" *) (* xpm_cdc = "ASYNC_RST" *) 
module uart_tx_fifo_xpm_cdc_async_rst
   (src_arst,
    dest_clk,
    dest_arst);
  input src_arst;
  input dest_clk;
  output dest_arst;

  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "ASYNC_RST" *) wire [1:0]arststages_ff;
  wire dest_clk;
  wire src_arst;

  assign dest_arst = arststages_ff[1];
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "ASYNC_RST" *) 
  FDPE #(
    .INIT(1'b0)) 
    \arststages_ff_reg[0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(1'b0),
        .PRE(src_arst),
        .Q(arststages_ff[0]));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "ASYNC_RST" *) 
  FDPE #(
    .INIT(1'b0)) 
    \arststages_ff_reg[1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(arststages_ff[0]),
        .PRE(src_arst),
        .Q(arststages_ff[1]));
endmodule

(* DEF_VAL = "1'b0" *) (* DEST_SYNC_FF = "2" *) (* INIT_SYNC_FF = "0" *) 
(* INV_DEF_VAL = "1'b1" *) (* ORIG_REF_NAME = "xpm_cdc_async_rst" *) (* RST_ACTIVE_HIGH = "1" *) 
(* VERSION = "0" *) (* XPM_MODULE = "TRUE" *) (* is_du_within_envelope = "true" *) 
(* keep_hierarchy = "true" *) (* xpm_cdc = "ASYNC_RST" *) 
module uart_tx_fifo_xpm_cdc_async_rst__1
   (src_arst,
    dest_clk,
    dest_arst);
  input src_arst;
  input dest_clk;
  output dest_arst;

  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "ASYNC_RST" *) wire [1:0]arststages_ff;
  wire dest_clk;
  wire src_arst;

  assign dest_arst = arststages_ff[1];
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "ASYNC_RST" *) 
  FDPE #(
    .INIT(1'b0)) 
    \arststages_ff_reg[0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(1'b0),
        .PRE(src_arst),
        .Q(arststages_ff[0]));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "ASYNC_RST" *) 
  FDPE #(
    .INIT(1'b0)) 
    \arststages_ff_reg[1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(arststages_ff[0]),
        .PRE(src_arst),
        .Q(arststages_ff[1]));
endmodule

(* DEST_SYNC_FF = "2" *) (* INIT_SYNC_FF = "0" *) (* ORIG_REF_NAME = "xpm_cdc_gray" *) 
(* REG_OUTPUT = "1" *) (* SIM_ASSERT_CHK = "0" *) (* SIM_LOSSLESS_GRAY_CHK = "0" *) 
(* VERSION = "0" *) (* WIDTH = "6" *) (* XPM_MODULE = "TRUE" *) 
(* is_du_within_envelope = "true" *) (* keep_hierarchy = "true" *) (* xpm_cdc = "GRAY" *) 
module uart_tx_fifo_xpm_cdc_gray
   (src_clk,
    src_in_bin,
    dest_clk,
    dest_out_bin);
  input src_clk;
  input [5:0]src_in_bin;
  input dest_clk;
  output [5:0]dest_out_bin;

  wire [5:0]async_path;
  wire [4:0]binval;
  wire dest_clk;
  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "GRAY" *) wire [5:0]\dest_graysync_ff[0] ;
  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "GRAY" *) wire [5:0]\dest_graysync_ff[1] ;
  wire [5:0]dest_out_bin;
  wire [4:0]gray_enc;
  wire src_clk;
  wire [5:0]src_in_bin;

  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[0]),
        .Q(\dest_graysync_ff[0] [0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[1]),
        .Q(\dest_graysync_ff[0] [1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[2]),
        .Q(\dest_graysync_ff[0] [2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[3]),
        .Q(\dest_graysync_ff[0] [3]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][4] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[4]),
        .Q(\dest_graysync_ff[0] [4]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][5] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[5]),
        .Q(\dest_graysync_ff[0] [5]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [0]),
        .Q(\dest_graysync_ff[1] [0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [1]),
        .Q(\dest_graysync_ff[1] [1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [2]),
        .Q(\dest_graysync_ff[1] [2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [3]),
        .Q(\dest_graysync_ff[1] [3]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][4] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [4]),
        .Q(\dest_graysync_ff[1] [4]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][5] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [5]),
        .Q(\dest_graysync_ff[1] [5]),
        .R(1'b0));
  LUT6 #(
    .INIT(64'h6996966996696996)) 
    \dest_out_bin_ff[0]_i_1 
       (.I0(\dest_graysync_ff[1] [0]),
        .I1(\dest_graysync_ff[1] [2]),
        .I2(\dest_graysync_ff[1] [4]),
        .I3(\dest_graysync_ff[1] [5]),
        .I4(\dest_graysync_ff[1] [3]),
        .I5(\dest_graysync_ff[1] [1]),
        .O(binval[0]));
  LUT5 #(
    .INIT(32'h96696996)) 
    \dest_out_bin_ff[1]_i_1 
       (.I0(\dest_graysync_ff[1] [1]),
        .I1(\dest_graysync_ff[1] [3]),
        .I2(\dest_graysync_ff[1] [5]),
        .I3(\dest_graysync_ff[1] [4]),
        .I4(\dest_graysync_ff[1] [2]),
        .O(binval[1]));
  LUT4 #(
    .INIT(16'h6996)) 
    \dest_out_bin_ff[2]_i_1 
       (.I0(\dest_graysync_ff[1] [2]),
        .I1(\dest_graysync_ff[1] [4]),
        .I2(\dest_graysync_ff[1] [5]),
        .I3(\dest_graysync_ff[1] [3]),
        .O(binval[2]));
  LUT3 #(
    .INIT(8'h96)) 
    \dest_out_bin_ff[3]_i_1 
       (.I0(\dest_graysync_ff[1] [3]),
        .I1(\dest_graysync_ff[1] [5]),
        .I2(\dest_graysync_ff[1] [4]),
        .O(binval[3]));
  LUT2 #(
    .INIT(4'h6)) 
    \dest_out_bin_ff[4]_i_1 
       (.I0(\dest_graysync_ff[1] [4]),
        .I1(\dest_graysync_ff[1] [5]),
        .O(binval[4]));
  FDRE \dest_out_bin_ff_reg[0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[0]),
        .Q(dest_out_bin[0]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[1]),
        .Q(dest_out_bin[1]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[2]),
        .Q(dest_out_bin[2]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[3]),
        .Q(dest_out_bin[3]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[4] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[4]),
        .Q(dest_out_bin[4]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[5] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[1] [5]),
        .Q(dest_out_bin[5]),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[0]_i_1 
       (.I0(src_in_bin[1]),
        .I1(src_in_bin[0]),
        .O(gray_enc[0]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[1]_i_1 
       (.I0(src_in_bin[2]),
        .I1(src_in_bin[1]),
        .O(gray_enc[1]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[2]_i_1 
       (.I0(src_in_bin[3]),
        .I1(src_in_bin[2]),
        .O(gray_enc[2]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[3]_i_1 
       (.I0(src_in_bin[4]),
        .I1(src_in_bin[3]),
        .O(gray_enc[3]));
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[4]_i_1 
       (.I0(src_in_bin[5]),
        .I1(src_in_bin[4]),
        .O(gray_enc[4]));
  FDRE \src_gray_ff_reg[0] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[0]),
        .Q(async_path[0]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[1] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[1]),
        .Q(async_path[1]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[2] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[2]),
        .Q(async_path[2]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[3] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[3]),
        .Q(async_path[3]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[4] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[4]),
        .Q(async_path[4]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[5] 
       (.C(src_clk),
        .CE(1'b1),
        .D(src_in_bin[5]),
        .Q(async_path[5]),
        .R(1'b0));
endmodule

(* DEST_SYNC_FF = "2" *) (* INIT_SYNC_FF = "0" *) (* ORIG_REF_NAME = "xpm_cdc_gray" *) 
(* REG_OUTPUT = "1" *) (* SIM_ASSERT_CHK = "0" *) (* SIM_LOSSLESS_GRAY_CHK = "0" *) 
(* VERSION = "0" *) (* WIDTH = "6" *) (* XPM_MODULE = "TRUE" *) 
(* is_du_within_envelope = "true" *) (* keep_hierarchy = "true" *) (* xpm_cdc = "GRAY" *) 
module uart_tx_fifo_xpm_cdc_gray__2
   (src_clk,
    src_in_bin,
    dest_clk,
    dest_out_bin);
  input src_clk;
  input [5:0]src_in_bin;
  input dest_clk;
  output [5:0]dest_out_bin;

  wire [5:0]async_path;
  wire [4:0]binval;
  wire dest_clk;
  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "GRAY" *) wire [5:0]\dest_graysync_ff[0] ;
  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "GRAY" *) wire [5:0]\dest_graysync_ff[1] ;
  wire [5:0]dest_out_bin;
  wire [4:0]gray_enc;
  wire src_clk;
  wire [5:0]src_in_bin;

  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[0]),
        .Q(\dest_graysync_ff[0] [0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[1]),
        .Q(\dest_graysync_ff[0] [1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[2]),
        .Q(\dest_graysync_ff[0] [2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[3]),
        .Q(\dest_graysync_ff[0] [3]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][4] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[4]),
        .Q(\dest_graysync_ff[0] [4]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][5] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[5]),
        .Q(\dest_graysync_ff[0] [5]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [0]),
        .Q(\dest_graysync_ff[1] [0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [1]),
        .Q(\dest_graysync_ff[1] [1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [2]),
        .Q(\dest_graysync_ff[1] [2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [3]),
        .Q(\dest_graysync_ff[1] [3]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][4] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [4]),
        .Q(\dest_graysync_ff[1] [4]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][5] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [5]),
        .Q(\dest_graysync_ff[1] [5]),
        .R(1'b0));
  LUT6 #(
    .INIT(64'h6996966996696996)) 
    \dest_out_bin_ff[0]_i_1 
       (.I0(\dest_graysync_ff[1] [0]),
        .I1(\dest_graysync_ff[1] [2]),
        .I2(\dest_graysync_ff[1] [4]),
        .I3(\dest_graysync_ff[1] [5]),
        .I4(\dest_graysync_ff[1] [3]),
        .I5(\dest_graysync_ff[1] [1]),
        .O(binval[0]));
  LUT5 #(
    .INIT(32'h96696996)) 
    \dest_out_bin_ff[1]_i_1 
       (.I0(\dest_graysync_ff[1] [1]),
        .I1(\dest_graysync_ff[1] [3]),
        .I2(\dest_graysync_ff[1] [5]),
        .I3(\dest_graysync_ff[1] [4]),
        .I4(\dest_graysync_ff[1] [2]),
        .O(binval[1]));
  LUT4 #(
    .INIT(16'h6996)) 
    \dest_out_bin_ff[2]_i_1 
       (.I0(\dest_graysync_ff[1] [2]),
        .I1(\dest_graysync_ff[1] [4]),
        .I2(\dest_graysync_ff[1] [5]),
        .I3(\dest_graysync_ff[1] [3]),
        .O(binval[2]));
  LUT3 #(
    .INIT(8'h96)) 
    \dest_out_bin_ff[3]_i_1 
       (.I0(\dest_graysync_ff[1] [3]),
        .I1(\dest_graysync_ff[1] [5]),
        .I2(\dest_graysync_ff[1] [4]),
        .O(binval[3]));
  LUT2 #(
    .INIT(4'h6)) 
    \dest_out_bin_ff[4]_i_1 
       (.I0(\dest_graysync_ff[1] [4]),
        .I1(\dest_graysync_ff[1] [5]),
        .O(binval[4]));
  FDRE \dest_out_bin_ff_reg[0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[0]),
        .Q(dest_out_bin[0]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[1]),
        .Q(dest_out_bin[1]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[2]),
        .Q(dest_out_bin[2]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[3]),
        .Q(dest_out_bin[3]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[4] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[4]),
        .Q(dest_out_bin[4]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[5] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[1] [5]),
        .Q(dest_out_bin[5]),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[0]_i_1 
       (.I0(src_in_bin[1]),
        .I1(src_in_bin[0]),
        .O(gray_enc[0]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[1]_i_1 
       (.I0(src_in_bin[2]),
        .I1(src_in_bin[1]),
        .O(gray_enc[1]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[2]_i_1 
       (.I0(src_in_bin[3]),
        .I1(src_in_bin[2]),
        .O(gray_enc[2]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[3]_i_1 
       (.I0(src_in_bin[4]),
        .I1(src_in_bin[3]),
        .O(gray_enc[3]));
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[4]_i_1 
       (.I0(src_in_bin[5]),
        .I1(src_in_bin[4]),
        .O(gray_enc[4]));
  FDRE \src_gray_ff_reg[0] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[0]),
        .Q(async_path[0]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[1] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[1]),
        .Q(async_path[1]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[2] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[2]),
        .Q(async_path[2]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[3] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[3]),
        .Q(async_path[3]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[4] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[4]),
        .Q(async_path[4]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[5] 
       (.C(src_clk),
        .CE(1'b1),
        .D(src_in_bin[5]),
        .Q(async_path[5]),
        .R(1'b0));
endmodule

(* DEST_SYNC_FF = "4" *) (* INIT_SYNC_FF = "0" *) (* ORIG_REF_NAME = "xpm_cdc_single" *) 
(* SIM_ASSERT_CHK = "0" *) (* SRC_INPUT_REG = "0" *) (* VERSION = "0" *) 
(* XPM_MODULE = "TRUE" *) (* is_du_within_envelope = "true" *) (* keep_hierarchy = "true" *) 
(* xpm_cdc = "SINGLE" *) 
module uart_tx_fifo_xpm_cdc_single
   (src_clk,
    src_in,
    dest_clk,
    dest_out);
  input src_clk;
  input src_in;
  input dest_clk;
  output dest_out;

  wire dest_clk;
  wire src_in;
  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "SINGLE" *) wire [3:0]syncstages_ff;

  assign dest_out = syncstages_ff[3];
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SINGLE" *) 
  FDRE \syncstages_ff_reg[0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(src_in),
        .Q(syncstages_ff[0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SINGLE" *) 
  FDRE \syncstages_ff_reg[1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[0]),
        .Q(syncstages_ff[1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SINGLE" *) 
  FDRE \syncstages_ff_reg[2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[1]),
        .Q(syncstages_ff[2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SINGLE" *) 
  FDRE \syncstages_ff_reg[3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[2]),
        .Q(syncstages_ff[3]),
        .R(1'b0));
endmodule

(* DEST_SYNC_FF = "4" *) (* INIT_SYNC_FF = "0" *) (* ORIG_REF_NAME = "xpm_cdc_single" *) 
(* SIM_ASSERT_CHK = "0" *) (* SRC_INPUT_REG = "0" *) (* VERSION = "0" *) 
(* XPM_MODULE = "TRUE" *) (* is_du_within_envelope = "true" *) (* keep_hierarchy = "true" *) 
(* xpm_cdc = "SINGLE" *) 
module uart_tx_fifo_xpm_cdc_single__2
   (src_clk,
    src_in,
    dest_clk,
    dest_out);
  input src_clk;
  input src_in;
  input dest_clk;
  output dest_out;

  wire dest_clk;
  wire src_in;
  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "SINGLE" *) wire [3:0]syncstages_ff;

  assign dest_out = syncstages_ff[3];
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SINGLE" *) 
  FDRE \syncstages_ff_reg[0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(src_in),
        .Q(syncstages_ff[0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SINGLE" *) 
  FDRE \syncstages_ff_reg[1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[0]),
        .Q(syncstages_ff[1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SINGLE" *) 
  FDRE \syncstages_ff_reg[2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[1]),
        .Q(syncstages_ff[2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SINGLE" *) 
  FDRE \syncstages_ff_reg[3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[2]),
        .Q(syncstages_ff[3]),
        .R(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2020.2"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
SFoQ2tXDMrL2nCJbfpmHXuteJlKaWDWl3o9OY1miFvmYb8EDywmDpLUHQktJ/VoW+17fK5WHgFVI
FZV1B91GDQ==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
mxGWDRjEAsKmBqldxevT1RKZvqK7vn0KlTODVXNGlRcGf9zOAmj0Z7Ppu79POBDb8oNQyCY+2q1q
BddzhQfh5WLIVX9BNUMIF6M6IF0elM4GMSLHGeYEwqSaMPC+thuR8FGj1J7z6rH+43gDYhtIeyY+
ZuZUz/Pqg8Lu63Xwe+0=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
HLwPjQzkuqv5FEDBriEJS2DikBeIHB/bWuVWooHY5ChdoHatcmqCHpSvnGxVzLwObZWHFys2nR9y
P3zxywjtgtOWq/n3cYVa5li6eyiUmGXv2OE8nw1nLnAY1kzBvGd6VwQ45t6l4Hx5+oqpIfuU2KI2
7/Qpj2atiTN3Y+q5He/BMXLIxF9vWuU6XL/+HsxriGAumcZDuESdidlxOztbW1bFhYr1/qWwou2q
wynnRVKYHL41aWycgFdkDoDEFFxv8ft8+F5Ux+J5Hg5XdgRULJc6uUQE/lDG3zOqzPftlODB52zU
d0cm8gFOvSZ2nO8ZB8THnxoAGe33iIZJfMcefA==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
jlR0iZ4fp9QXiFgaT07DMAK1YFLyBpsOGOOR9j2PWImFEh8oTBt4cvmGo+2z1Umbt9OMQwOhyepO
QIsKLFzUXYUba+SFFLBoCiaww24KICecbUfd3VV5sg2bEJjAdtYTT6mJqyc3vQRvBlONeBFdIGy2
AXqdK7QtXGLsLAIF/z4FG8cfG6nSD6e16gccBC6+kl5MoShdnmebKLyoo6UKFdMbDK88sHvTcD9S
LNCau6RK7FkTZg23FV0tf6cTP9Rray9YEcowm2AAh51Wldo2lGJ2W5iiDatRKH/W1bu7FGWZG+OT
+VZE+Ckiuf4T6cuu+G5IbrtMv6a4U93R0gtxXQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
p/kq+JjPPJbOTWT2SRiPJ99/iH6kkVGEiluRRXpuRN+j+cVPgJD1v4QVjw3zMWLlvTGB7OOqC+JG
Lc62Wiizd/BFfGj2JYkTZMatcOWok7A87HK+vRTjr4nZMApD2jKaneJdU1279KsIEeRfImCQ2uRl
QRNMH3PPdNGYCnOGgNk=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
kyyI/O29YYc5VBwhz19i7AV7MC75r43hHVKAOTBiGBhRu8zZxCwGGcNFqc2HgHcWC6nq4jCIbIXf
S3FDzPdasegnERlWvoob9/SXM88zKsyeTbUf+DRu5lB8SPROBMaIhnj375C5XLowL17MXZdmB6fV
X5ukCg7cNhCjssKt/bIJibWkfna7hvj4ye+CLWmi3LdEiix8KTwRoBS3ZJrjM4/N6FfZkXerVxs+
txkhdsmG9ga1g/xErhTRilhqrV2WetlpX86qH/64sRGVxrWeEfNoHhMZsqEK0jWDx4WavKt8XY7W
NDzMXLZ2m5Dv5HMiJWgFG+ntPwgiYYtBuwu7Eg==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
tv6UL1ZWqo3dAIlhN5UTNGzJyqzdHpCqh217JPvIvHiWJgcFh2tw1n7HWnOPcK3VhCt31AGnCEFe
HpTiinXvHna65L2X2HhtNUrsgvZlUuh/oQR273wp5JPFDPD97NQ4ELkGI+w26HTYLgZ70K5rQo87
D4AkQNRuzTRS5G12yb4RU7ZYgmkYLuq1UyqjlxyN62Del4XoqZyivOGw5H+7wlfkNRu98iQwqq12
jthZbH/ue5wxZJUcb7NmEwL+3abpyDNmWs1qORHOFoE3t97/9XMmeSCpM2+KnSKJvsV5VbuoTCOT
964fsEh7ey4IVb4aum095gQjLCqTmDm8DWFmaw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2020_08", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Oxo3AgNmVWgrXtMKDIThYfXr0YJfyFr7Bsjn2ge/G72mb25MA8Dbkd9ZZPtwqU1poazNnTng5Cx5
s8C1zMNEoo38jNY8zEUBjCCuasJgeMo5xsiha+3ZIBiuHS0KLrjLaPFIQZdsYevb44fg6J5YQLn5
jd1M6YdNMd1VwSezDxtbk9sN8ExPrmtwum/6L1ia9j9UlIzPTEaJ60Xz7tloPsgsbkborO2JLiIk
kIAY2q1b8tuhHzJ5DoXlvIo49wSDj75ncLrkwbAd26huob7aOmX1bS34pJLF17JzqYH0MoPJbHxb
RPdD+qUawXFsMSs2fOLnZrNxeG8L+TyAT0N8tQ==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
CIR/vwxo0IBrPr5+bMp2YuBCQTNBRIIbqgEB18Oewkc8CuHzGCAgPyQUBUKaUG3bBy+KDOPVxBP5
cE/d3QYZAT11fyB1OMMTrjmEIZcr0Vk3nVTAnivoxxxkmdzPjkj0OcGcU9fMArPi3dfTgIsKdtCq
94+mV/70WeprgijzuZFWD7uH+gVioY/+rq/Wc1O6x1n949w8YGgSCTurUvhsobx2bonoC317J0Wm
IX17XRkSBIFgzqA8iC+GV5oCfxIGkihKmXxjIJbMamlOdCOycEkjkh3JYmm7TLNxmI65iffsabR0
t5+iI0l8eJxFhElzWeREqE43cnJYLaKZBUA+DA==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 84224)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
