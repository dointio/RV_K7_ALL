`include "mydefines.v"

module regfile(
  input  [`MYRISCV_REGADDRBUS] read_src1_idx,
  input  [`MYRISCV_REGADDRBUS] read_src2_idx,
  output [`MYRISCV_REGBUS] read_src1_dat,
  output [`MYRISCV_REGBUS] read_src2_dat,

  input  wbck_dest_wen,
  input  [`MYRISCV_REGADDRBUS] wbck_dest_idx,
  input  [`MYRISCV_REGBUS] wbck_dest_dat,

  output [`MYRISCV_REGBUS] x1_r,

  input  test_mode,
  input  clk,
  input  rst_n
  );

  wire [`MYRISCV_REGBUS] rf_r [`MYRISCV_REGNUM-1:0];
  wire [`MYRISCV_REGNUM-1:0] rf_wen;

  
  genvar i;
  generate //{
      for (i=0; i<`MYRISCV_REGNUM; i=i+1) begin:regfile//{ 
  
        if(i==0) begin: rf0
          assign rf_wen[i] = 1'b0;
          assign rf_r[i] = `MYRISCV_REGWD'd0;
        end
        else begin: rfno0
          assign rf_wen[i] = wbck_dest_wen & (wbck_dest_idx == i) ;
          // sirv_gnrl_dffl #(`MYRISCV_REGWD) rf_dffl (rf_wen[i], wbck_dest_dat, rf_r[i], clk);
          reg_en #(
            .DW(`MYRISCV_REGWD), 
            .REG_NAME("Regfile")
          )rf_dffl(
            .clk  (clk),
            .en   (rf_wen[i]),
            .data_i   (wbck_dest_dat),
            .data_o   (rf_r[i])
          );
        end
  
      end//}
  endgenerate//}

  assign read_src1_dat = (read_src1_idx == 0) ? 0 :
    (((read_src1_idx == wbck_dest_idx) && (wbck_dest_wen == 1)) ? wbck_dest_dat : rf_r[read_src1_idx]);
  assign read_src2_dat = (read_src2_idx == 0) ? 0 :
    (((read_src2_idx == wbck_dest_idx) && (wbck_dest_wen == 1)) ? wbck_dest_dat :rf_r[read_src2_idx]);

  assign x1_r = rf_r[1];
      
endmodule

