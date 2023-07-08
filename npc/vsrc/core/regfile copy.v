// `include "mydefines.v"

// module regfile(
//   input  [`MYRISCV_REGADDRBUS] read_src1_idx,
//   input  [`MYRISCV_REGADDRBUS] read_src2_idx,
//   output [`MYRISCV_REGBUS] read_src1_dat,
//   output [`MYRISCV_REGBUS] read_src2_dat,

//   input  wbck_dest_wen,
//   input  [`MYRISCV_REGADDRBUS] wbck_dest_idx,
//   input  [`MYRISCV_REGBUS] wbck_dest_dat,

//   output [`MYRISCV_REGBUS] x1_r,

//   input  test_mode,
//   input  clk,
//   input  rst_n
//   );

//   wire [`MYRISCV_REGBUS] rf_r [`MYRISCV_REGNUM-1:0];
//   wire [`MYRISCV_REGNUM-1:0] rf_wen;


  
//   // `ifdef E203_REGFILE_LATCH_BASED //{
//   //   // Use DFF to buffer the write-port
//   //   wire [`MYRISCV_REGBUS] wbck_dest_dat_r;
//   //   sirv_gnrl_dffl #(`MYRISCV_REGWD) wbck_dat_dffl (wbck_dest_wen, wbck_dest_dat, wbck_dest_dat_r, clk);
//   //   wire [`MYRISCV_REGNUM-1:0] clk_rf_ltch;
//   // `endif//}

  
//   genvar i;
//   generate //{
//       for (i=0; i<`MYRISCV_REGNUM; i=i+1) begin:regfile//{ 
  
//         if(i==0) begin: rf0
//             // x0 cannot be wrote since it is constant-zeros
//             assign rf_wen[i] = 1'b0;
//             assign rf_r[i] = `MYRISCV_REGWD'd0;
//           // `ifdef E203_REGFILE_LATCH_BASED //{
//           //   assign clk_rf_ltch[i] = 1'b0;
//           // `endif//}
//         end
//         else begin: rfno0
//             assign rf_wen[i] = wbck_dest_wen & (wbck_dest_idx == i) ;
//           // `ifdef E203_REGFILE_LATCH_BASED //{
//           //   clkgate u_e203_clkgate(
//           //     .clk_in  (clk  ),
//           //     .test_mode(test_mode),
//           //     .clock_en(rf_wen[i]),
//           //     .clk_out (clk_rf_ltch[i])
//           //   );
//           //       //from write-enable to clk_rf_ltch to rf_ltch
//           //   sirv_gnrl_ltch #(`MYRISCV_REGWD) rf_ltch (clk_rf_ltch[i], wbck_dest_dat_r, rf_r[i]);
//           // `else//}{  
//             sirv_gnrl_dffl #(`MYRISCV_REGWD) rf_dffl (rf_wen[i], wbck_dest_dat, rf_r[i], clk);
//           // `endif//}
//         end
  
//       end//}
//   endgenerate//}

//   assign read_src1_dat = (read_src1_idx == 0) ? 0 :
//     (((read_src1_idx == wbck_dest_idx) && (wbck_dest_wen == 1)) ? wbck_dest_dat : rf_r[read_src1_idx]);
//   assign read_src2_dat = (read_src2_idx == 0) ? 0 :
//     (((read_src2_idx == wbck_dest_idx) && (wbck_dest_wen == 1)) ? wbck_dest_dat :rf_r[read_src2_idx]);

//   assign x1_r = rf_r[1];
      
// endmodule

