    `include "e203_defines.v"
    `include "mydefines.v"
/* verilator lint_off WIDTHEXPAND*/
    module dec(

    //////////////////////////////////////////////////////////////
    // The IR stage to Decoder
    input  [`MYRISCV_INSTBUS] if2dec_instr, //当前指令，来自ifu
    input  [`MYRISCV_ADDRBUS] if2dec_pc, //当前pc，来自ifu
    input  if2dec_vld,
    output if2dec_rdy,
    input  if2dec_prdt_taken,  //
    input  i_misalgn,              // 指令未对齐异常
    input  i_buserr,               // 总线访问错误
    input  i_muldiv_b2b,           // The back2back case for mul/div

    input  dbg_mode,
    //////////////////////////////////////////////////////////////
    // The Decoded Info-Bus
    output dec2ex_vld,
    input  dec2ex_rdy,
    `ifdef PLATFORM_SIM
        output [`MYRISCV_INSTBUS] dec2ex_instr,
    `endif

    output dec2ex_rs1x0, //源操作数1的寄存器索引为x0
    output dec2ex_rs2x0, //2的寄存器索引为x0
    output dec2ex_rs1en, //该指令需要读取源操作数1
    output dec2ex_rs2en, //该指令需要读取源操作数2
    output dec2ex_rdwen, //该指令需要写结果操作数
    output [`MYRISCV_REGADDRBUS] dec2ex_rs1idx, //1索引
    output [`MYRISCV_REGADDRBUS] dec2ex_rs2idx, //2索引
    output [`MYRISCV_REGADDRBUS] dec2ex_rdidx, //结果索引
    output [`MY_DECINFO_WIDTH-1:0] dec2ex_info,   //指令其他信息，一组打包的信号
    output [`MYRISCV_XLEN-1:0] dec2ex_imm, //指令使用的立即数值
    output [`MYRISCV_ADDRBUS] dec2ex_pc,
    output dec_misalgn,
    output dec_buserr,
    output dec_ilegl, //指令译码结果为非法

    `ifdef MYRISCV_HAS_NICE//{
        //nice decode
        input  nice_xs_off,  
        output dec_nice,
        output nice_cmt_off_ilgl_o,      
    `endif//}

    output dec_mulhsu,
    output dec_mul   ,
    output dec_div   ,
    output dec_rem   ,
    output dec_divu  ,
    output dec_remu  ,

    output dec_rv32,
    output dec_bjp,
    output dec_jal,
    output dec_jalr,
    output dec_bxx,

    output [`MYRISCV_REGADDRBUS] dec_jalr_rs1idx,
    output [`MYRISCV_XLEN-1:0] dec_bjp_imm,

    output is_long_instr,
    input oitf_hold
    );

    assign dec2ex_vld = if2dec_vld & (~oitf_hold);
    assign if2dec_rdy = dec2ex_rdy & (~oitf_hold);

    `ifdef PLATFORM_SIM
        assign dec2ex_instr = if2dec_instr;
    `endif


    wire [32-1:0] instr_32 = if2dec_instr;
    wire [16-1:0] instr_16 = if2dec_instr[15:0];

    wire [6:0]  opcode = instr_32[6:0];

    wire opcode_1_0_00  = (opcode[1:0] == 2'b00);
    wire opcode_1_0_01  = (opcode[1:0] == 2'b01);
    wire opcode_1_0_10  = (opcode[1:0] == 2'b10);
    wire opcode_1_0_11  = (opcode[1:0] == 2'b11);
    wire opcode_4_2_000 = (opcode[4:2] == 3'b000);
    wire opcode_4_2_001 = (opcode[4:2] == 3'b001);
    wire opcode_4_2_010 = (opcode[4:2] == 3'b010);
    wire opcode_4_2_011 = (opcode[4:2] == 3'b011);
    wire opcode_4_2_100 = (opcode[4:2] == 3'b100);
    wire opcode_4_2_101 = (opcode[4:2] == 3'b101);
    wire opcode_4_2_110 = (opcode[4:2] == 3'b110);
    wire opcode_4_2_111 = (opcode[4:2] == 3'b111);
    wire opcode_6_5_00  = (opcode[6:5] == 2'b00);
    wire opcode_6_5_01  = (opcode[6:5] == 2'b01);
    wire opcode_6_5_10  = (opcode[6:5] == 2'b10);
    wire opcode_6_5_11  = (opcode[6:5] == 2'b11);

    wire is_instr_32 = (~(if2dec_instr[4:2] == 3'b111)) & opcode_1_0_11;

    wire [4:0]  rv32_rd     = instr_32[11:7];
    wire [2:0]  rv32_func3  = instr_32[14:12];
    wire [4:0]  rv32_rs1    = instr_32[19:15];
    wire [4:0]  rv32_rs2    = instr_32[24:20];
    wire [6:0]  rv32_func7  = instr_32[31:25];

    wire [4:0]  rv16_rd     = rv32_rd;
    wire [4:0]  rv16_rs1    = rv16_rd; 
    wire [4:0]  rv16_rs2    = instr_32[6:2];
    wire [4:0]  rv16_rdd    = {2'b01,instr_32[4:2]};
    wire [4:0]  rv16_rss1   = {2'b01,instr_32[9:7]};
    wire [4:0]  rv16_rss2   = rv16_rdd;
    wire [2:0]  rv16_func3  = instr_32[15:13];

    
    // We generate the signals and reused them as much as possible to save gatecounts
    

    wire rv32_func3_000 = (rv32_func3 == 3'b000);
    wire rv32_func3_001 = (rv32_func3 == 3'b001);
    wire rv32_func3_010 = (rv32_func3 == 3'b010);
    wire rv32_func3_011 = (rv32_func3 == 3'b011);
    wire rv32_func3_100 = (rv32_func3 == 3'b100);
    wire rv32_func3_101 = (rv32_func3 == 3'b101);
    wire rv32_func3_110 = (rv32_func3 == 3'b110);
    wire rv32_func3_111 = (rv32_func3 == 3'b111);

    wire rv16_func3_000 = (rv16_func3 == 3'b000);
    wire rv16_func3_001 = (rv16_func3 == 3'b001);
    wire rv16_func3_010 = (rv16_func3 == 3'b010);
    wire rv16_func3_011 = (rv16_func3 == 3'b011);
    wire rv16_func3_100 = (rv16_func3 == 3'b100);
    wire rv16_func3_101 = (rv16_func3 == 3'b101);
    wire rv16_func3_110 = (rv16_func3 == 3'b110);
    wire rv16_func3_111 = (rv16_func3 == 3'b111);

    wire rv32_func7_0000000 = (rv32_func7 == 7'b0000000);
    wire rv32_func7_0100000 = (rv32_func7 == 7'b0100000);
    wire rv32_func7_0000001 = (rv32_func7 == 7'b0000001);
    wire rv32_func7_0000101 = (rv32_func7 == 7'b0000101);
    wire rv32_func7_0001001 = (rv32_func7 == 7'b0001001);
    wire rv32_func7_0001101 = (rv32_func7 == 7'b0001101);
    wire rv32_func7_0010101 = (rv32_func7 == 7'b0010101);
    wire rv32_func7_0100001 = (rv32_func7 == 7'b0100001);
    wire rv32_func7_0010001 = (rv32_func7 == 7'b0010001);
    wire rv32_func7_0101101 = (rv32_func7 == 7'b0101101);
    wire rv32_func7_1111111 = (rv32_func7 == 7'b1111111);
    wire rv32_func7_0000100 = (rv32_func7 == 7'b0000100); 
    wire rv32_func7_0001000 = (rv32_func7 == 7'b0001000); 
    wire rv32_func7_0001100 = (rv32_func7 == 7'b0001100); 
    wire rv32_func7_0101100 = (rv32_func7 == 7'b0101100); 
    wire rv32_func7_0010000 = (rv32_func7 == 7'b0010000); 
    wire rv32_func7_0010100 = (rv32_func7 == 7'b0010100); 
    wire rv32_func7_1100000 = (rv32_func7 == 7'b1100000); 
    wire rv32_func7_1110000 = (rv32_func7 == 7'b1110000); 
    wire rv32_func7_1010000 = (rv32_func7 == 7'b1010000); 
    wire rv32_func7_1101000 = (rv32_func7 == 7'b1101000); 
    wire rv32_func7_1111000 = (rv32_func7 == 7'b1111000); 
    wire rv32_func7_1010001 = (rv32_func7 == 7'b1010001);  
    wire rv32_func7_1110001 = (rv32_func7 == 7'b1110001);  
    wire rv32_func7_1100001 = (rv32_func7 == 7'b1100001);  
    wire rv32_func7_1101001 = (rv32_func7 == 7'b1101001);  

    //r: spiceal case (idx)!!!(st)
    wire rv32_rs1_x0 = (rv32_rs1 == 5'b00000);
    wire rv32_rs2_x0 = (rv32_rs2 == 5'b00000);
    wire rv32_rs2_x1 = (rv32_rs2 == 5'b00001);
    wire rv32_rd_x0  = (rv32_rd  == 5'b00000);
    wire rv32_rd_x2  = (rv32_rd  == 5'b00010);

    wire rv16_rs1_x0 = (rv16_rs1 == 5'b00000);
    wire rv16_rs2_x0 = (rv16_rs2 == 5'b00000);
    wire rv16_rd_x0  = (rv16_rd  == 5'b00000);
    wire rv16_rd_x2  = (rv16_rd  == 5'b00010);

    wire rv32_rs1_x31 = (rv32_rs1 == 5'b11111);
    wire rv32_rs2_x31 = (rv32_rs2 == 5'b11111);
    wire rv32_rd_x31  = (rv32_rd  == 5'b11111);
    //r: spiceal case (idx)!!!(ed)

    //r: instruction type check!(start)
    wire rv32_load     = opcode_6_5_00 & opcode_4_2_000 & opcode_1_0_11; 
    wire rv32_store    = opcode_6_5_01 & opcode_4_2_000 & opcode_1_0_11; 
    wire rv32_madd     = opcode_6_5_10 & opcode_4_2_000 & opcode_1_0_11; 
    wire rv32_branch   = opcode_6_5_11 & opcode_4_2_000 & opcode_1_0_11; 

    wire rv32_load_fp  = opcode_6_5_00 & opcode_4_2_001 & opcode_1_0_11; 
    wire rv32_store_fp = opcode_6_5_01 & opcode_4_2_001 & opcode_1_0_11; 
    wire rv32_msub     = opcode_6_5_10 & opcode_4_2_001 & opcode_1_0_11; 
    wire rv32_jalr     = opcode_6_5_11 & opcode_4_2_001 & opcode_1_0_11; 

    wire rv32_custom0  = opcode_6_5_00 & opcode_4_2_010 & opcode_1_0_11; 
    wire rv32_custom1  = opcode_6_5_01 & opcode_4_2_010 & opcode_1_0_11; 
    wire rv32_nmsub    = opcode_6_5_10 & opcode_4_2_010 & opcode_1_0_11; 
    wire rv32_resved0  = opcode_6_5_11 & opcode_4_2_010 & opcode_1_0_11; 

    wire rv32_miscmem  = opcode_6_5_00 & opcode_4_2_011 & opcode_1_0_11; 
`ifdef MYRISCV_SUPPORT_AMO//{
    wire rv32_amo      = opcode_6_5_01 & opcode_4_2_011 & opcode_1_0_11; 
`else
    wire rv32_amo      = 1'b0;
`endif//}
    wire rv32_nmadd    = opcode_6_5_10 & opcode_4_2_011 & opcode_1_0_11; 
    wire rv32_jal      = opcode_6_5_11 & opcode_4_2_011 & opcode_1_0_11; 

    wire rv32_op_imm   = opcode_6_5_00 & opcode_4_2_100 & opcode_1_0_11; 
    wire rv32_op       = (opcode_6_5_01 & opcode_4_2_100 & opcode_1_0_11);
    wire rv32_op_fp    = opcode_6_5_10 & opcode_4_2_100 & opcode_1_0_11; 
    wire rv32_system   = opcode_6_5_11 & opcode_4_2_100 & opcode_1_0_11; 

    wire rv32_auipc    = opcode_6_5_00 & opcode_4_2_101 & opcode_1_0_11; 
    wire rv32_lui      = opcode_6_5_01 & opcode_4_2_101 & opcode_1_0_11; 
    wire rv32_resved1  = opcode_6_5_10 & opcode_4_2_101 & opcode_1_0_11; 
    wire rv32_resved2  = opcode_6_5_11 & opcode_4_2_101 & opcode_1_0_11; 

    wire rv32_op_imm_32= opcode_6_5_00 & opcode_4_2_110 & opcode_1_0_11; 
    wire rv32_op_32    = opcode_6_5_01 & opcode_4_2_110 & opcode_1_0_11; 
    wire rv32_custom2  = opcode_6_5_10 & opcode_4_2_110 & opcode_1_0_11; 
    wire rv32_custom3  = opcode_6_5_11 & opcode_4_2_110 & opcode_1_0_11; 

    wire rv16_addi4spn     = opcode_1_0_00 & rv16_func3_000;//
    wire rv16_lw           = opcode_1_0_00 & rv16_func3_010;//
    wire rv16_sw           = opcode_1_0_00 & rv16_func3_110;//

    wire rv16_addi         = opcode_1_0_01 & rv16_func3_000;//
    wire rv16_jal          = opcode_1_0_01 & rv16_func3_001;//
    wire rv16_li           = opcode_1_0_01 & rv16_func3_010;//
    wire rv16_lui_addi16sp = opcode_1_0_01 & rv16_func3_011;//--
    wire rv16_miscalu      = opcode_1_0_01 & rv16_func3_100;//--
    wire rv16_j            = opcode_1_0_01 & rv16_func3_101;//
    wire rv16_beqz         = opcode_1_0_01 & rv16_func3_110;//
    wire rv16_bnez         = opcode_1_0_01 & rv16_func3_111;//

    wire rv16_slli         = opcode_1_0_10 & rv16_func3_000;//
    wire rv16_lwsp         = opcode_1_0_10 & rv16_func3_010;//
    wire rv16_jalr_mv_add  = opcode_1_0_10 & rv16_func3_100;//--
    wire rv16_swsp         = opcode_1_0_10 & rv16_func3_110;//

`ifndef MYRISCV_HAS_FPU//{
    wire rv16_flw          = 1'b0;
    wire rv16_fld          = 1'b0;
    wire rv16_fsw          = 1'b0;
    wire rv16_fsd          = 1'b0;
    wire rv16_fldsp        = 1'b0;
    wire rv16_flwsp        = 1'b0;
    wire rv16_fsdsp        = 1'b0;
    wire rv16_fswsp        = 1'b0;
`else
        //r: fpu instr check is unimplemented!
`endif//}

    wire rv16_lwsp_ilgl    = rv16_lwsp & rv16_rd_x0;//(RES, rd=0)

    wire rv16_nop          = rv16_addi  
                            & (~instr_16[12]) & (rv16_rd_x0) & (rv16_rs2_x0);

    wire rv16_srli         = rv16_miscalu  & (instr_16[11:10] == 2'b00);
    wire rv16_srai         = rv16_miscalu  & (instr_16[11:10] == 2'b01);
    wire rv16_andi         = rv16_miscalu  & (instr_16[11:10] == 2'b10);

    wire rv16_instr_12_is0   = (instr_16[12] == 1'b0);
    wire rv16_instr_6_2_is0s = (instr_16[6:2] == 5'b0);

    wire rv16_sxxi_shamt_legl = 
                    rv16_instr_12_is0 //shamt[5] must be zero for RV32C
                & (~(rv16_instr_6_2_is0s)) //shamt[4:0] must be non-zero for RV32C
                    ;
    wire rv16_sxxi_shamt_ilgl =  (rv16_slli | rv16_srli | rv16_srai) & (~rv16_sxxi_shamt_legl);

    wire rv16_addi16sp     = rv16_lui_addi16sp & rv32_rd_x2;//
    wire rv16_lui          = rv16_lui_addi16sp & (~rv32_rd_x0) & (~rv32_rd_x2);//
    
    //C.LI is only valid when rd!=x0.
    wire rv16_li_ilgl = rv16_li & (rv16_rd_x0);
    //C.LUI is only valid when rd!=x0 or x2, and when the immediate is not equal to zero.
    wire rv16_lui_ilgl = rv16_lui & (rv16_rd_x0 | rv16_rd_x2 | (rv16_instr_6_2_is0s & rv16_instr_12_is0));

    wire rv16_li_lui_ilgl = rv16_li_ilgl | rv16_lui_ilgl;

    wire rv16_addi4spn_ilgl = rv16_addi4spn & (rv16_instr_12_is0 & rv16_rd_x0 & opcode_6_5_00);//(RES, nzimm=0, bits[12:5])
    wire rv16_addi16sp_ilgl = rv16_addi16sp & rv16_instr_12_is0 & rv16_instr_6_2_is0s; //(RES, nzimm=0, bits 12,6:2)

    wire rv16_subxororand  = rv16_miscalu  & (instr_16[12:10] == 3'b011);//
    wire rv16_sub          = rv16_subxororand & (instr_16[6:5] == 2'b00);//
    wire rv16_xor          = rv16_subxororand & (instr_16[6:5] == 2'b01);//
    wire rv16_or           = rv16_subxororand & (instr_16[6:5] == 2'b10);//
    wire rv16_and          = rv16_subxororand & (instr_16[6:5] == 2'b11);//

    wire rv16_jr           = rv16_jalr_mv_add //
                            & (~instr_16[12]) & (~rv16_rs1_x0) & (rv16_rs2_x0);// The RES rs1=0 illegal is already covered here
    wire rv16_mv           = rv16_jalr_mv_add //
                            & (~instr_16[12]) & (~rv16_rd_x0) & (~rv16_rs2_x0);
    wire rv16_ebreak       = rv16_jalr_mv_add //
                            & (instr_16[12]) & (rv16_rd_x0) & (rv16_rs2_x0);
    wire rv16_jalr         = rv16_jalr_mv_add //
                            & (instr_16[12]) & (~rv16_rs1_x0) & (rv16_rs2_x0);
    wire rv16_add          = rv16_jalr_mv_add // 
                            & (instr_16[12]) & (~rv16_rd_x0) & (~rv16_rs2_x0);

//r: nice instr, spiceal R-type instruction!
//r: bit 14-13: if need rd,rs2,rs1
`ifdef MYRISCV_HAS_NICE//{
    // ==========================================================================
    // add nice logic 
    wire nice_need_rs1 = instr_32[13];
    wire nice_need_rs2 = instr_32[12];
    wire nice_need_rd  = instr_32[14];
    wire [31:5] nice_instr  = instr_32[31:5];

    wire nice_op = rv32_custom0 | rv32_custom1 | rv32_custom2 | rv32_custom3;
    assign dec_nice = nice_op;
    
    assign nice_cmt_off_ilgl_o = nice_xs_off & nice_op; //r: nice_xs_off:close nice by hard(but arch may support.)

    wire [`MY_DECINFO_NICE_WIDTH-1:0] nice_info_bus;
    assign nice_info_bus[`MY_DECINFO_GRP    ]    = `MY_DECINFO_GRP_NICE;
    assign nice_info_bus[`MY_DECINFO_RV32   ]    = is_instr_32;
    assign nice_info_bus[`MY_DECINFO_NICE_INSTR]  = nice_instr;
`endif//}

    // ===========================================================================
    // Branch Instructions
    wire rv32_beq      = rv32_branch & rv32_func3_000;
    wire rv32_bne      = rv32_branch & rv32_func3_001;
    wire rv32_blt      = rv32_branch & rv32_func3_100;
    wire rv32_bgt      = rv32_branch & rv32_func3_101;
    wire rv32_bltu     = rv32_branch & rv32_func3_110;
    wire rv32_bgtu     = rv32_branch & rv32_func3_111;

    // ===========================================================================
    // System Instructions
    wire rv32_ecall    = rv32_system & rv32_func3_000 & (instr_32[31:20] == 12'b0000_0000_0000);
    wire rv32_ebreak   = rv32_system & rv32_func3_000 & (instr_32[31:20] == 12'b0000_0000_0001);
    wire rv32_mret     = rv32_system & rv32_func3_000 & (instr_32[31:20] == 12'b0011_0000_0010);
    wire rv32_dret     = rv32_system & rv32_func3_000 & (instr_32[31:20] == 12'b0111_1011_0010);
    wire rv32_wfi      = rv32_system & rv32_func3_000 & (instr_32[31:20] == 12'b0001_0000_0101);
    // We dont implement the WFI and MRET illegal exception when the rs and rd is not zeros

    wire rv32_csrrw    = rv32_system & rv32_func3_001; 
    wire rv32_csrrs    = rv32_system & rv32_func3_010; 
    wire rv32_csrrc    = rv32_system & rv32_func3_011; 
    wire rv32_csrrwi   = rv32_system & rv32_func3_101; 
    wire rv32_csrrsi   = rv32_system & rv32_func3_110; 
    wire rv32_csrrci   = rv32_system & rv32_func3_111; 

    wire rv32_dret_ilgl = rv32_dret & (~dbg_mode);

    wire rv32_ecall_ebreak_ret_wfi = rv32_system & rv32_func3_000;
    wire rv32_csr          = rv32_system & (~rv32_func3_000);


    // ===========================================================================
        // The Branch and system group of instructions will be handled by BJP

    assign dec_jal     = rv32_jal    | rv16_jal  | rv16_j;
    assign dec_jalr    = rv32_jalr   | rv16_jalr | rv16_jr;
    assign dec_bxx     = rv32_branch | rv16_beqz | rv16_bnez;
    assign dec_bjp     = dec_jal | dec_jalr | dec_bxx; 


    wire rv32_fence  ;
    wire rv32_fence_i;
    wire rv32_fence_fencei;
    wire bjp_op = dec_bjp | rv32_mret | (rv32_dret & (~rv32_dret_ilgl)) | rv32_fence_fencei;

    wire [`MY_DECINFO_BJP_WIDTH-1:0] bjp_info_bus;
    assign bjp_info_bus[`MY_DECINFO_GRP    ]    = `MY_DECINFO_GRP_BJP;
    assign bjp_info_bus[`MY_DECINFO_RV32   ]    = is_instr_32;
    assign bjp_info_bus[`MY_DECINFO_BJP_JAL ]  = dec_jal;
    assign bjp_info_bus[`MY_DECINFO_BJP_JALR ]  = dec_jalr;
    assign bjp_info_bus[`MY_DECINFO_BJP_BPRDT]  = if2dec_prdt_taken;
    assign bjp_info_bus[`MY_DECINFO_BJP_BEQ  ]  = rv32_beq | rv16_beqz;
    assign bjp_info_bus[`MY_DECINFO_BJP_BNE  ]  = rv32_bne | rv16_bnez;
    assign bjp_info_bus[`MY_DECINFO_BJP_BLT  ]  = rv32_blt; 
    assign bjp_info_bus[`MY_DECINFO_BJP_BGT  ]  = rv32_bgt ;
    assign bjp_info_bus[`MY_DECINFO_BJP_BLTU ]  = rv32_bltu;
    assign bjp_info_bus[`MY_DECINFO_BJP_BGTU ]  = rv32_bgtu;
    assign bjp_info_bus[`MY_DECINFO_BJP_BXX  ]  = dec_bxx;
    assign bjp_info_bus[`MY_DECINFO_BJP_MRET ]  = rv32_mret;
    assign bjp_info_bus[`MY_DECINFO_BJP_DRET ]  = rv32_dret;
    assign bjp_info_bus[`MY_DECINFO_BJP_FENCE ]  = rv32_fence;
    assign bjp_info_bus[`MY_DECINFO_BJP_FENCEI]  = rv32_fence_i;


    // ===========================================================================
    // ALU Instructions
    wire rv32_addi     = rv32_op_imm & rv32_func3_000;
    wire rv32_slti     = rv32_op_imm & rv32_func3_010;
    wire rv32_sltiu    = rv32_op_imm & rv32_func3_011;
    wire rv32_xori     = rv32_op_imm & rv32_func3_100;
    wire rv32_ori      = rv32_op_imm & rv32_func3_110;
    wire rv32_andi     = rv32_op_imm & rv32_func3_111;

    wire rv32_slli     = rv32_op_imm & rv32_func3_001 & (instr_32[31:26] == 6'b000000);
    wire rv32_srli     = rv32_op_imm & rv32_func3_101 & (instr_32[31:26] == 6'b000000);
    wire rv32_srai     = rv32_op_imm & rv32_func3_101 & (instr_32[31:26] == 6'b010000);

    wire rv32_add      = rv32_op     & rv32_func3_000 & rv32_func7_0000000;
    wire rv32_sub      = rv32_op     & rv32_func3_000 & rv32_func7_0100000;
    wire rv32_sll      = rv32_op     & rv32_func3_001 & rv32_func7_0000000;
    wire rv32_slt      = rv32_op     & rv32_func3_010 & rv32_func7_0000000;
    wire rv32_sltu     = rv32_op     & rv32_func3_011 & rv32_func7_0000000;
    wire rv32_xor      = rv32_op     & rv32_func3_100 & rv32_func7_0000000;
    wire rv32_srl      = rv32_op     & rv32_func3_101 & rv32_func7_0000000;
    wire rv32_sra      = rv32_op     & rv32_func3_101 & rv32_func7_0100000;
    wire rv32_or       = rv32_op     & rv32_func3_110 & rv32_func7_0000000;
    wire rv32_and      = rv32_op     & rv32_func3_111 & rv32_func7_0000000;

`ifdef MYRISCV_ARCH_64
    wire rv32_addiw    = rv32_op_imm_32 & rv32_func3_000;
    wire rv32_slliw    = rv32_op_imm_32 & rv32_func3_001 & rv32_func7_0000000;
    wire rv32_srliw    = rv32_op_imm_32 & rv32_func3_101 & rv32_func7_0000000;
    wire rv32_sraiw    = rv32_op_imm_32 & rv32_func3_101 & rv32_func7_0100000;
    wire rv32_addw     = rv32_op_32     & rv32_func3_000 & rv32_func7_0000000;
    wire rv32_subw     = rv32_op_32     & rv32_func3_000 & rv32_func7_0100000;
    wire rv32_sllw     = rv32_op_32     & rv32_func3_001 & rv32_func7_0000000;
    wire rv32_srlw     = rv32_op_32     & rv32_func3_101 & rv32_func7_0000000;
    wire rv32_sraw     = rv32_op_32     & rv32_func3_101 & rv32_func7_0100000;
`endif

`ifdef MYRISCV_ARCH_64 
    wire rv32_sxxi_shamt_ilgl = 1'b0;
`else
    wire rv32_sxxi_shamt_legl = (instr_32[25] == 1'b0); //shamt[5] must be zero for RV32I
    wire rv32_sxxi_shamt_ilgl =  (rv32_slli | rv32_srli | rv32_srai) & (~rv32_sxxi_shamt_legl);
`endif


    wire rv32_nop      = rv32_addi & rv32_rs1_x0 & rv32_rd_x0 & (~(|instr_32[31:20]));
    // The ALU group of instructions will be handled by 1cycle ALU-datapath
    wire ecall_ebreak = rv32_ecall | rv32_ebreak | rv16_ebreak;

    wire alu_op = (~rv32_sxxi_shamt_ilgl) & (~rv16_sxxi_shamt_ilgl) 
                & (~rv16_li_lui_ilgl) & (~rv16_addi4spn_ilgl) & (~rv16_addi16sp_ilgl) & 
                ( rv32_op_imm
        `ifdef MYRISCV_ARCH_64
                | rv32_op_imm_32
                | rv32_op_32
        `endif
                | rv32_op & (~rv32_func7_0000001) // Exclude the MULDIV
                | rv32_auipc
                | rv32_lui
                | rv16_addi4spn
                | rv16_addi         
                | rv16_lui_addi16sp 
                | rv16_li | rv16_mv
                | rv16_slli         
                | rv16_miscalu  
                | rv16_add
                | rv16_nop | rv32_nop
                | rv32_wfi // We just put WFI into ALU and do nothing in ALU
                | ecall_ebreak)
                ;
    wire need_imm;
    wire [`MY_DECINFO_ALU_WIDTH-1:0] alu_info_bus;
    assign alu_info_bus[`MY_DECINFO_GRP    ]    = `MY_DECINFO_GRP_ALU;
    assign alu_info_bus[`MY_DECINFO_RV32   ]    = is_instr_32;
    assign alu_info_bus[`MY_DECINFO_ALU_ADD]    = rv32_add  | rv32_addi | rv32_auipc |
                                                    rv16_addi4spn | rv16_addi | rv16_addi16sp | rv16_add |
                                                `ifdef MYRISCV_ARCH_64
                                                    rv32_addiw | rv32_addw |
                                                `endif
                                // We also decode LI and MV as the add instruction, becuase
                                //   they all add x0 with a RS2 or Immeidate, and then write into RD
                                                    rv16_li | rv16_mv;
    assign alu_info_bus[`MY_DECINFO_ALU_SUB]    = rv32_sub  |
                                                `ifdef MYRISCV_ARCH_64
                                                    rv32_subw |
                                                `endif                                                    
                                                    rv16_sub; 
    assign alu_info_bus[`MY_DECINFO_ALU_SLT]    = rv32_slt  | rv32_slti;     
    assign alu_info_bus[`MY_DECINFO_ALU_SLTU]   = rv32_sltu | rv32_sltiu;  
    assign alu_info_bus[`MY_DECINFO_ALU_XOR]    = rv32_xor  | rv32_xori | rv16_xor;    
    assign alu_info_bus[`MY_DECINFO_ALU_SLL]    = rv32_sll  | rv32_slli | 
                                                `ifdef MYRISCV_ARCH_64
                                                    rv32_sllw | rv32_slliw |
                                                `endif   
                                                    rv16_slli;   
    assign alu_info_bus[`MY_DECINFO_ALU_SRL]    = rv32_srl  | rv32_srli | 
                                                `ifdef MYRISCV_ARCH_64
                                                    rv32_srlw | rv32_srliw |
                                                `endif   
                                                    rv16_srli;
    assign alu_info_bus[`MY_DECINFO_ALU_SRA]    = rv32_sra  | rv32_srai | 
                                                `ifdef MYRISCV_ARCH_64
                                                    rv32_sraw | rv32_sraiw |
                                                `endif   
                                                    rv16_srai;   
    assign alu_info_bus[`MY_DECINFO_ALU_OR ]    = rv32_or   | rv32_ori  | rv16_or;     
    assign alu_info_bus[`MY_DECINFO_ALU_AND]    = rv32_and  | rv32_andi | rv16_andi | rv16_and;
    assign alu_info_bus[`MY_DECINFO_ALU_LUI]    = rv32_lui  | rv16_lui; 
    assign alu_info_bus[`MY_DECINFO_ALU_OP2IMM] = need_imm; 
    assign alu_info_bus[`MY_DECINFO_ALU_OP1PC ] = rv32_auipc;
`ifdef MYRISCV_ARCH_64
    assign alu_info_bus[`MY_DECINFO_ALU_RESW]   = rv32_addiw | rv32_addw | rv32_subw 
        | rv32_sllw     | rv32_srlw     | rv32_sraw 
        | rv32_slliw    | rv32_srliw    | rv32_sraiw;
`else
    assign alu_info_bus[`MY_DECINFO_ALU_RESW]   = 1'b0;
`endif
    assign alu_info_bus[`MY_DECINFO_ALU_NOP ]   = rv16_nop | rv32_nop;
    assign alu_info_bus[`MY_DECINFO_ALU_ECAL ]  = rv32_ecall; 
    assign alu_info_bus[`MY_DECINFO_ALU_EBRK ]  = rv32_ebreak | rv16_ebreak;
    assign alu_info_bus[`MY_DECINFO_ALU_WFI  ]  = rv32_wfi;

    
    wire csr_op = rv32_csr;
    wire [`MY_DECINFO_CSR_WIDTH-1:0] csr_info_bus;
    assign csr_info_bus[`MY_DECINFO_GRP    ]    = `MY_DECINFO_GRP_CSR;
    assign csr_info_bus[`MY_DECINFO_RV32   ]    = is_instr_32;
    assign csr_info_bus[`MY_DECINFO_CSR_CSRRW ] = rv32_csrrw | rv32_csrrwi; 
    assign csr_info_bus[`MY_DECINFO_CSR_CSRRS ] = rv32_csrrs | rv32_csrrsi;
    assign csr_info_bus[`MY_DECINFO_CSR_CSRRC ] = rv32_csrrc | rv32_csrrci;
    assign csr_info_bus[`MY_DECINFO_CSR_RS1IMM] = rv32_csrrwi | rv32_csrrsi | rv32_csrrci;
    assign csr_info_bus[`MY_DECINFO_CSR_ZIMMM ] = rv32_rs1;
    assign csr_info_bus[`MY_DECINFO_CSR_RS1IS0] = rv32_rs1_x0;
    assign csr_info_bus[`MY_DECINFO_CSR_CSRIDX] = instr_32[31:20];

    
    // ===========================================================================
    // Memory Order Instructions
    assign rv32_fence    = rv32_miscmem & rv32_func3_000;
    assign rv32_fence_i  = rv32_miscmem & rv32_func3_001;

    assign rv32_fence_fencei  = rv32_miscmem;


    // ===========================================================================
    // MUL/DIV Instructions
    wire rv32_mul      = rv32_op    & rv32_func3_000 & rv32_func7_0000001;
    wire rv32_mulh     = rv32_op    & rv32_func3_001 & rv32_func7_0000001;
    wire rv32_mulhsu   = rv32_op    & rv32_func3_010 & rv32_func7_0000001;
    wire rv32_mulhu    = rv32_op    & rv32_func3_011 & rv32_func7_0000001;
    wire rv32_div      = rv32_op    & rv32_func3_100 & rv32_func7_0000001;
    wire rv32_divu     = rv32_op    & rv32_func3_101 & rv32_func7_0000001;
    wire rv32_rem      = rv32_op    & rv32_func3_110 & rv32_func7_0000001;
    wire rv32_remu     = rv32_op    & rv32_func3_111 & rv32_func7_0000001;

`ifdef MYRISCV_ARCH_64
    wire rv32_mulw     = rv32_op_32    & rv32_func3_000 & rv32_func7_0000001;
    wire rv32_divw     = rv32_op_32    & rv32_func3_100 & rv32_func7_0000001;
    wire rv32_divuw    = rv32_op_32    & rv32_func3_101 & rv32_func7_0000001;
    wire rv32_remw     = rv32_op_32    & rv32_func3_110 & rv32_func7_0000001;
    wire rv32_remuw    = rv32_op_32    & rv32_func3_111 & rv32_func7_0000001;
`else

`endif
    
    // The MULDIV group of instructions will be handled by MUL-DIV-datapath
    `ifdef MYRISCV_SUPPORT_MULDIV//{
        wire muldiv_op = (rv32_op 
    `ifdef MYRISCV_ARCH_64
        | rv32_op_32
    `endif
        ) & rv32_func7_0000001;
    `endif//}
    `ifndef MYRISCV_SUPPORT_MULDIV//{
        wire muldiv_op = 1'b0;
    `endif//}

    wire [`MY_DECINFO_MULDIV_WIDTH-1:0] muldiv_info_bus;
    assign muldiv_info_bus[`MY_DECINFO_GRP          ] = `MY_DECINFO_GRP_MULDIV;
    assign muldiv_info_bus[`MY_DECINFO_RV32         ] = is_instr_32;
`ifdef MYRISCV_ARCH_64
    assign muldiv_info_bus[`MY_DECINFO_MULDIV_RESW  ]   = rv32_mulw | rv32_divw | rv32_divuw | rv32_remw | rv32_remuw;
`else
    assign muldiv_info_bus[`MY_DECINFO_MULDIV_RESW  ]   = 1'b0;
`endif
    assign muldiv_info_bus[`MY_DECINFO_MULDIV_MUL   ] = rv32_mul    
`ifdef MYRISCV_ARCH_64
        | rv32_mulw
`endif
    ;
    assign muldiv_info_bus[`MY_DECINFO_MULDIV_MULH  ] = rv32_mulh   ;
    assign muldiv_info_bus[`MY_DECINFO_MULDIV_MULHSU] = rv32_mulhsu ;
    assign muldiv_info_bus[`MY_DECINFO_MULDIV_MULHU ] = rv32_mulhu  ;
    assign muldiv_info_bus[`MY_DECINFO_MULDIV_DIV   ] = rv32_div    
`ifdef MYRISCV_ARCH_64
        | rv32_divw
`endif
    ;
    assign muldiv_info_bus[`MY_DECINFO_MULDIV_DIVU  ] = rv32_divu   
`ifdef MYRISCV_ARCH_64
    | rv32_divuw
`endif
    ;
    assign muldiv_info_bus[`MY_DECINFO_MULDIV_REM   ] = rv32_rem    
`ifdef MYRISCV_ARCH_64
    | rv32_remw
`endif
    ;
    assign muldiv_info_bus[`MY_DECINFO_MULDIV_REMU  ] = rv32_remu   
`ifdef MYRISCV_ARCH_64    
    | rv32_remuw
`endif
    ;
    assign muldiv_info_bus[`MY_DECINFO_MULDIV_B2B   ] = i_muldiv_b2b;

    assign dec_mulhsu = rv32_mulh | rv32_mulhsu | rv32_mulhu;
    assign dec_mul    = rv32_mul
`ifdef MYRISCV_ARCH_64
    | rv32_mulw
`endif
    ;
    assign dec_div    = rv32_div
`ifdef MYRISCV_ARCH_64
    | rv32_divw
`endif
    ;
    assign dec_divu   = rv32_divu
`ifdef MYRISCV_ARCH_64
    | rv32_divuw
`endif
    ;
    assign dec_rem    = rv32_rem
`ifdef MYRISCV_ARCH_64
    | rv32_remw;
`endif
    ;
    assign dec_remu   = rv32_remu
`ifdef MYRISCV_ARCH_64
    | rv32_remuw;
`endif
    ;
    
    // ===========================================================================
    // Load/Store Instructions
    wire rv32_lb       = rv32_load  & rv32_func3_000;
    wire rv32_lh       = rv32_load  & rv32_func3_001;
    wire rv32_lw       = rv32_load  & rv32_func3_010;
    wire rv32_lbu      = rv32_load  & rv32_func3_100;
    wire rv32_lhu      = rv32_load  & rv32_func3_101;

    wire rv32_sb       = rv32_store  & rv32_func3_000;
    wire rv32_sh       = rv32_store  & rv32_func3_001;
    wire rv32_sw       = rv32_store  & rv32_func3_010;

`ifdef MYRISCV_ARCH_64
    wire rv32_lwu     = rv32_load   & rv32_func3_110;
    wire rv32_ld      = rv32_load   & rv32_func3_011;
    wire rv32_sd      = rv32_store  & rv32_func3_011;
`endif

    // ===========================================================================
    // Atomic Instructions
    `ifdef MYRISCV_SUPPORT_AMO//{
    wire rv32_lr_w      = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b00010);
    wire rv32_sc_w      = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b00011);
    wire rv32_amoswap_w = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b00001);
    wire rv32_amoadd_w  = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b00000);
    wire rv32_amoxor_w  = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b00100);
    wire rv32_amoand_w  = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b01100);
    wire rv32_amoor_w   = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b01000);
    wire rv32_amomin_w  = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b10000);
    wire rv32_amomax_w  = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b10100);
    wire rv32_amominu_w = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b11000);
    wire rv32_amomaxu_w = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b11100);

    `endif//MYRISCV_SUPPORT_AMO}
    `ifndef MYRISCV_SUPPORT_AMO//{
    wire rv32_lr_w      = 1'b0;
    wire rv32_sc_w      = 1'b0;
    wire rv32_amoswap_w = 1'b0;
    wire rv32_amoadd_w  = 1'b0;
    wire rv32_amoxor_w  = 1'b0;
    wire rv32_amoand_w  = 1'b0;
    wire rv32_amoor_w   = 1'b0;
    wire rv32_amomin_w  = 1'b0;
    wire rv32_amomax_w  = 1'b0;
    wire rv32_amominu_w = 1'b0;
    wire rv32_amomaxu_w = 1'b0;

    `endif//}

    wire   amoldst_op = rv32_amo | rv32_load | rv32_store | rv16_lw | rv16_sw | (rv16_lwsp & (~rv16_lwsp_ilgl)) | rv16_swsp;
        // The RV16 always is word
    wire [1:0] lsu_info_size  = is_instr_32 ? rv32_func3[1:0] : 2'b10;
        // The RV16 always is signed
    wire       lsu_info_usign = is_instr_32? rv32_func3[2] : 1'b0;

    wire [`MY_DECINFO_AGU_WIDTH-1:0] agu_info_bus;
    assign agu_info_bus[`MY_DECINFO_GRP    ] = `MY_DECINFO_GRP_AGU;
    assign agu_info_bus[`MY_DECINFO_RV32   ] = is_instr_32;
    assign agu_info_bus[`MY_DECINFO_AGU_LOAD   ] = rv32_load  | rv32_lr_w | rv16_lw | rv16_lwsp;
    assign agu_info_bus[`MY_DECINFO_AGU_STORE  ] = rv32_store | rv32_sc_w | rv16_sw | rv16_swsp;
    assign agu_info_bus[`MY_DECINFO_AGU_SIZE   ] = lsu_info_size;
    assign agu_info_bus[`MY_DECINFO_AGU_USIGN  ] = lsu_info_usign;
    assign agu_info_bus[`MY_DECINFO_AGU_EXCL   ] = rv32_lr_w | rv32_sc_w;
    assign agu_info_bus[`MY_DECINFO_AGU_AMO    ] = rv32_amo & (~(rv32_lr_w | rv32_sc_w));// We seperated the EXCL out of AMO in LSU handling
    assign agu_info_bus[`MY_DECINFO_AGU_AMOSWAP] = rv32_amoswap_w;
    assign agu_info_bus[`MY_DECINFO_AGU_AMOADD ] = rv32_amoadd_w ;
    assign agu_info_bus[`MY_DECINFO_AGU_AMOAND ] = rv32_amoand_w ;
    assign agu_info_bus[`MY_DECINFO_AGU_AMOOR  ] = rv32_amoor_w ;
    assign agu_info_bus[`MY_DECINFO_AGU_AMOXOR ] = rv32_amoxor_w  ;
    assign agu_info_bus[`MY_DECINFO_AGU_AMOMAX ] = rv32_amomax_w ;
    assign agu_info_bus[`MY_DECINFO_AGU_AMOMIN ] = rv32_amomin_w ;
    assign agu_info_bus[`MY_DECINFO_AGU_AMOMAXU] = rv32_amomaxu_w;
    assign agu_info_bus[`MY_DECINFO_AGU_AMOMINU] = rv32_amominu_w;
    assign agu_info_bus[`MY_DECINFO_AGU_OP2IMM ] = need_imm;

    localparam agu_load_bit = `MY_DECINFO_AGU_LOAD_LSB;

    // ===========================================================================


    // Reuse the common signals as much as possible to save gatecounts
    wire rv32_all0s_ilgl  = rv32_func7_0000000 
                            & rv32_rs2_x0 
                            & rv32_rs1_x0 
                            & rv32_func3_000 
                            & rv32_rd_x0 
                            & opcode_6_5_00 
                            & opcode_4_2_000 
                            & (opcode[1:0] == 2'b00); 

    wire rv32_all1s_ilgl  = rv32_func7_1111111 
                            & rv32_rs2_x31 
                            & rv32_rs1_x31 
                            & rv32_func3_111 
                            & rv32_rd_x31 
                            & opcode_6_5_11 
                            & opcode_4_2_111 
                            & (opcode[1:0] == 2'b11); 

    wire rv16_all0s_ilgl  = rv16_func3_000 //rv16_func3  = instr_32[15:13];
                            & rv32_func3_000 //rv32_func3  = instr_32[14:12];
                            & rv32_rd_x0     //rv32_rd     = instr_32[11:7];
                            & opcode_6_5_00 
                            & opcode_4_2_000 
                            & (opcode[1:0] == 2'b00); 

    wire rv16_all1s_ilgl  = rv16_func3_111
                            & rv32_func3_111 
                            & rv32_rd_x31 
                            & opcode_6_5_11 
                            & opcode_4_2_111 
                            & (opcode[1:0] == 2'b11);
    
    wire rv_all0s1s_ilgl = is_instr_32 ?  (rv32_all0s_ilgl | rv32_all1s_ilgl)
                                :  (rv16_all0s_ilgl | rv16_all1s_ilgl);

    //
    // All the RV32IMA need RD register except the
    //   * Branch, Store,
    //   * fence, fence_i 
    //   * ecall, ebreak  
    wire rv32_need_rd = 
                        (~rv32_rd_x0) & (
                        `ifdef MYRISCV_HAS_NICE//{
                        nice_op ? nice_need_rd :
                        `endif//}
                        (
                        (~rv32_branch) & (~rv32_store)
                        & (~rv32_fence_fencei)
                        & (~rv32_ecall_ebreak_ret_wfi) 
                        )
                    );

    // All the RV32IMA need RS1 register except the
    //   * lui
    //   * auipc
    //   * jal
    //   * fence, fence_i 
    //   * ecall, ebreak  
    //   * csrrwi
    //   * csrrsi
    //   * csrrci
    wire rv32_need_rs1 =
                        (~rv32_rs1_x0) & (
                `ifdef MYRISCV_HAS_NICE//{
                        nice_op ? nice_need_rs1 :
                `endif//}
                        (
                        (~rv32_lui)
                        & (~rv32_auipc)
                        & (~rv32_jal)
                        & (~rv32_fence_fencei)
                        & (~rv32_ecall_ebreak_ret_wfi)
                        & (~rv32_csrrwi)
                        & (~rv32_csrrsi)
                        & (~rv32_csrrci)
                        )
                    );
                        
    // Following RV32IMA instructions need RS2 register
    //   * branch
    //   * store
    //   * rv32_op
    //   * rv32_amo except the rv32_lr_w
    wire rv32_need_rs2 = (~rv32_rs2_x0) & (
                    `ifdef MYRISCV_HAS_NICE//{
                    nice_op ? nice_need_rs2 :
                    `endif//}
                    (
                    (rv32_branch)
                | (rv32_store)
                | (rv32_op)
                | (rv32_amo & (~rv32_lr_w))
                    )
                    );

    wire [`MYRISCV_XLEN-1:0]  rv32_i_imm = ( (rv32_slli
                                    | rv32_srli
                                    | rv32_srai
                            `ifdef MYRISCV_ARCH_64
                                    | rv32_slliw
                                    | rv32_srliw
                                    | rv32_sraiw
                            `endif
                                ) ? 
                                ({{(`MYRISCV_XLEN-32+20){instr_32[31]}}
                                , instr_32[31:20]} & (
                            `ifdef MYRISCV_ARCH_64
                                {{(`MYRISCV_XLEN-6){1'b0}}, 6'b111111}
                            `else
                                {{(`MYRISCV_XLEN-5){1'b0}}, 5'b11111}
                            `endif
                                ))
                                : { 
                                    {(`MYRISCV_XLEN-32+20){instr_32[31]}} 
                                    , instr_32[31:20]
                                });

    wire [`MYRISCV_XLEN-1:0]  rv32_s_imm = {
                                {(`MYRISCV_XLEN-32+20){instr_32[31]}} 
                                , instr_32[31:25] 
                                , instr_32[11:7]
                                };


    wire [`MYRISCV_XLEN-1:0]  rv32_b_imm = {
                                {(`MYRISCV_XLEN-32+19){instr_32[31]}} 
                                , instr_32[31] 
                                , instr_32[7] 
                                , instr_32[30:25] 
                                , instr_32[11:8]
                                , 1'b0
                                };

    wire [`MYRISCV_XLEN-1:0]  rv32_u_imm = {{(`MYRISCV_XLEN-32){instr_32[31]}}, instr_32[31:12],12'b0};

    wire [`MYRISCV_XLEN-1:0]  rv32_j_imm = {
                                {(`MYRISCV_XLEN-32+11){instr_32[31]}} 
                                , instr_32[31] 
                                , instr_32[19:12] 
                                , instr_32[20] 
                                , instr_32[30:21]
                                , 1'b0
                                };

                    // It will select i-type immediate when
                    //    * rv32_op_imm
                    //    * rv32_jalr
                    //    * rv32_load
    wire rv32_imm_sel_i = rv32_op_imm | rv32_jalr | rv32_load
                        `ifdef MYRISCV_ARCH_64
                            | rv32_op_imm_32
                        `endif
                        ;
    wire rv32_imm_sel_jalr = rv32_jalr;
    wire [`MYRISCV_XLEN-1:0]  rv32_jalr_imm = rv32_i_imm;

                    // It will select u-type immediate when
                    //    * rv32_lui, rv32_auipc 
    wire rv32_imm_sel_u = rv32_lui | rv32_auipc;

                    // It will select j-type immediate when
                    //    * rv32_jal
    wire rv32_imm_sel_j = rv32_jal;
    wire rv32_imm_sel_jal = rv32_jal;
    wire [`MYRISCV_XLEN-1:0]  rv32_jal_imm = rv32_j_imm;

                    // It will select b-type immediate when
                    //    * rv32_branch
    wire rv32_imm_sel_b = rv32_branch;
    wire rv32_imm_sel_bxx = rv32_branch;
    wire [`MYRISCV_XLEN-1:0]  rv32_bxx_imm = rv32_b_imm;
                    
                    // It will select s-type immediate when
                    //    * rv32_store
    wire rv32_imm_sel_s = rv32_store;



    //   * Note: this CIS/CILI/CILUI/CI16SP-type is named by myself, because in 
    //           ISA doc, the CI format for LWSP is different
    //           with other CI formats in terms of immediate
    
                    // It will select CIS-type immediate when
                    //    * rv16_lwsp
    wire rv16_imm_sel_cis = rv16_lwsp;
    wire [31:0]  rv16_cis_imm ={
                            24'b0
                            , instr_16[3:2]
                            , instr_16[12]
                            , instr_16[6:4]
                            , 2'b0
                            };
                    
    wire [31:0]  rv16_cis_d_imm ={
                            23'b0
                            , instr_16[4:2]
                            , instr_16[12]
                            , instr_16[6:5]
                            , 3'b0
                            };
                    // It will select CILI-type immediate when
                    //    * rv16_li
                    //    * rv16_addi
                    //    * rv16_slli
                    //    * rv16_srai
                    //    * rv16_srli
                    //    * rv16_andi
    wire rv16_imm_sel_cili = rv16_li | rv16_addi | rv16_slli
                    | rv16_srai | rv16_srli | rv16_andi;
    wire [31:0]  rv16_cili_imm ={
                            {26{instr_16[12]}}
                            , instr_16[12]
                            , instr_16[6:2]
                            };
                    
                    // It will select CILUI-type immediate when
                    //    * rv16_lui
    wire rv16_imm_sel_cilui = rv16_lui;
    wire [31:0]  rv16_cilui_imm ={
                            {14{instr_16[12]}}
                            , instr_16[12]
                            , instr_16[6:2]
                            , 12'b0
                            };
                    
                    // It will select CI16SP-type immediate when
                    //    * rv16_addi16sp
    wire rv16_imm_sel_ci16sp = rv16_addi16sp;
    wire [31:0]  rv16_ci16sp_imm ={
                            {22{instr_16[12]}}
                            , instr_16[12]
                            , instr_16[4]
                            , instr_16[3]
                            , instr_16[5]
                            , instr_16[2]
                            , instr_16[6]
                            , 4'b0
                            };
                    
                    // It will select CSS-type immediate when
                    //    * rv16_swsp
    wire rv16_imm_sel_css = rv16_swsp;
    wire [31:0]  rv16_css_imm ={
                            24'b0
                            , instr_16[8:7]
                            , instr_16[12:9]
                            , 2'b0
                            };
    wire [31:0]  rv16_css_d_imm ={
                            23'b0
                            , instr_16[9:7]
                            , instr_16[12:10]
                            , 3'b0
                            };
                    // It will select CIW-type immediate when
                    //    * rv16_addi4spn
    wire rv16_imm_sel_ciw = rv16_addi4spn;
    wire [31:0]  rv16_ciw_imm ={
                            22'b0
                            , instr_16[10:7]
                            , instr_16[12]
                            , instr_16[11]
                            , instr_16[5]
                            , instr_16[6]
                            , 2'b0
                            };

                    // It will select CL-type immediate when
                    //    * rv16_lw
    wire rv16_imm_sel_cl = rv16_lw;
    wire [31:0]  rv16_cl_imm ={
                            25'b0
                            , instr_16[5]
                            , instr_16[12]
                            , instr_16[11]
                            , instr_16[10]
                            , instr_16[6]
                            , 2'b0
                            };
                    
    wire [31:0]  rv16_cl_d_imm ={
                            24'b0
                            , instr_16[6]
                            , instr_16[5]
                            , instr_16[12]
                            , instr_16[11]
                            , instr_16[10]
                            , 3'b0
                            };
                    // It will select CS-type immediate when
                    //    * rv16_sw
    wire rv16_imm_sel_cs = rv16_sw;
    wire [31:0]  rv16_cs_imm ={
                            25'b0
                            , instr_16[5]
                            , instr_16[12]
                            , instr_16[11]
                            , instr_16[10]
                            , instr_16[6]
                            , 2'b0
                            };
    wire [31:0]  rv16_cs_d_imm ={
                            24'b0
                            , instr_16[6]
                            , instr_16[5]
                            , instr_16[12]
                            , instr_16[11]
                            , instr_16[10]
                            , 3'b0
                            };

                    // It will select CB-type immediate when
                    //    * rv16_beqz
                    //    * rv16_bnez
    wire rv16_imm_sel_cb = rv16_beqz | rv16_bnez;
    wire [31:0]  rv16_cb_imm ={
                            {23{instr_16[12]}}
                            , instr_16[12]
                            , instr_16[6:5]
                            , instr_16[2]
                            , instr_16[11:10]
                            , instr_16[4:3]
                            , 1'b0
                            };
    wire [31:0]  rv16_bxx_imm = rv16_cb_imm;

                    // It will select CJ-type immediate when
                    //    * rv16_j
                    //    * rv16_jal
    wire rv16_imm_sel_cj = rv16_j | rv16_jal;
    wire [31:0]  rv16_cj_imm ={
                            {20{instr_16[12]}}
                            , instr_16[12]
                            , instr_16[8]
                            , instr_16[10:9]
                            , instr_16[6]
                            , instr_16[7]
                            , instr_16[2]
                            , instr_16[11]
                            , instr_16[5:3]
                            , 1'b0
                            };
    wire [31:0]  rv16_jjal_imm = rv16_cj_imm;

                    // It will select CR-type register (no-imm) when
                    //    * rv16_jalr_mv_add
    wire [31:0]  rv16_jrjalr_imm = 32'b0;
                    
                    // It will select CSR-type register (no-imm) when
                    //    * rv16_subxororand

                    
    wire [`MYRISCV_XLEN-1:0]  rv32_load_fp_imm  = rv32_i_imm;
    wire [`MYRISCV_XLEN-1:0]  rv32_store_fp_imm = rv32_s_imm;
    wire [`MYRISCV_XLEN-1:0]  rv32_imm = 
                        ({(`MYRISCV_XLEN){rv32_imm_sel_i}} & rv32_i_imm)
                    | ({(`MYRISCV_XLEN){rv32_imm_sel_s}} & rv32_s_imm)
                    | ({(`MYRISCV_XLEN){rv32_imm_sel_b}} & rv32_b_imm)
                    | ({(`MYRISCV_XLEN){rv32_imm_sel_u}} & rv32_u_imm)
                    | ({(`MYRISCV_XLEN){rv32_imm_sel_j}} & rv32_j_imm)
                    ;
                    
    wire  rv32_need_imm = 
                        rv32_imm_sel_i
                    | rv32_imm_sel_s
                    | rv32_imm_sel_b
                    | rv32_imm_sel_u
                    | rv32_imm_sel_j
                    ;

    wire [31:0]  rv16_imm = 
                        ({32{rv16_imm_sel_cis   }} & rv16_cis_imm)
                    | ({32{rv16_imm_sel_cili  }} & rv16_cili_imm)
                    | ({32{rv16_imm_sel_cilui }} & rv16_cilui_imm)
                    | ({32{rv16_imm_sel_ci16sp}} & rv16_ci16sp_imm)
                    | ({32{rv16_imm_sel_css   }} & rv16_css_imm)
                    | ({32{rv16_imm_sel_ciw   }} & rv16_ciw_imm)
                    | ({32{rv16_imm_sel_cl    }} & rv16_cl_imm)
                    | ({32{rv16_imm_sel_cs    }} & rv16_cs_imm)
                    | ({32{rv16_imm_sel_cb    }} & rv16_cb_imm)
                    | ({32{rv16_imm_sel_cj    }} & rv16_cj_imm)
                    ;

    wire rv16_need_imm = 
                        rv16_imm_sel_cis   
                    | rv16_imm_sel_cili  
                    | rv16_imm_sel_cilui 
                    | rv16_imm_sel_ci16sp
                    | rv16_imm_sel_css   
                    | rv16_imm_sel_ciw   
                    | rv16_imm_sel_cl    
                    | rv16_imm_sel_cs    
                    | rv16_imm_sel_cb    
                    | rv16_imm_sel_cj    
                    ;


    assign need_imm = is_instr_32 ? rv32_need_imm : rv16_need_imm; 

    assign dec2ex_imm = is_instr_32 ? rv32_imm : rv16_imm;
    assign dec2ex_pc  = if2dec_pc;

    

    assign dec2ex_info = 
                ({`MY_DECINFO_WIDTH{alu_op}}     & {{`MY_DECINFO_WIDTH-`MY_DECINFO_ALU_WIDTH{1'b0}},alu_info_bus})
                | ({`MY_DECINFO_WIDTH{amoldst_op}} & {{`MY_DECINFO_WIDTH-`MY_DECINFO_AGU_WIDTH{1'b0}},agu_info_bus})
                | ({`MY_DECINFO_WIDTH{bjp_op}}     & {{`MY_DECINFO_WIDTH-`MY_DECINFO_BJP_WIDTH{1'b0}},bjp_info_bus})
                | ({`MY_DECINFO_WIDTH{csr_op}}     & {{`MY_DECINFO_WIDTH-`MY_DECINFO_CSR_WIDTH{1'b0}},csr_info_bus})
                | ({`MY_DECINFO_WIDTH{muldiv_op}}  & {{`MY_DECINFO_WIDTH-`MY_DECINFO_CSR_WIDTH{1'b0}},muldiv_info_bus})
            `ifdef MYRISCV_HAS_NICE//{
                | ({`MY_DECINFO_WIDTH{nice_op}}     & {{`MY_DECINFO_WIDTH-`MY_DECINFO_NICE_WIDTH{1'b0}},nice_info_bus})
            `endif//}
                ;


    wire legl_ops = //r: leagl op,check by instr type
                alu_op
                | amoldst_op
                | bjp_op
                | csr_op
                | muldiv_op
            `ifdef MYRISCV_HAS_NICE//{
                | nice_op
            `endif//}
                ;

    // To decode the registers for Rv16, divided into 8 groups
    wire rv16_format_cr  = rv16_jalr_mv_add;
    wire rv16_format_ci  = rv16_lwsp | rv16_flwsp | rv16_fldsp | rv16_li | rv16_lui_addi16sp | rv16_addi | rv16_slli; 
    wire rv16_format_css = rv16_swsp | rv16_fswsp | rv16_fsdsp; 
    wire rv16_format_ciw = rv16_addi4spn; 
    wire rv16_format_cl  = rv16_lw | rv16_flw | rv16_fld; 
    wire rv16_format_cs  = rv16_sw | rv16_fsw | rv16_fsd | rv16_subxororand; 
    wire rv16_format_cb  = rv16_beqz | rv16_bnez | rv16_srli | rv16_srai | rv16_andi; 
    wire rv16_format_cj  = rv16_j | rv16_jal; 


    // In CR Cases:
    //   * JR:     rs1= rs1(coded),     rs2= x0 (coded),   rd = x0 (implicit)
    //   * JALR:   rs1= rs1(coded),     rs2= x0 (coded),   rd = x1 (implicit)
    //   * MV:     rs1= x0 (implicit),  rs2= rs2(coded),   rd = rd (coded)
    //   * ADD:    rs1= rs1(coded),     rs2= rs2(coded),   rd = rd (coded)
    //   * eBreak: rs1= rs1(coded),     rs2= x0 (coded),   rd = x0 (coded)
    wire rv16_need_cr_rs1   = rv16_format_cr & 1'b1;
    wire rv16_need_cr_rs2   = rv16_format_cr & 1'b1;
    wire rv16_need_cr_rd    = rv16_format_cr & 1'b1;
    wire [`MYRISCV_REGADDRBUS] rv16_cr_rs1 = rv16_mv ? `MYRISCV_REGADDRWD'd0 : rv16_rs1[`MYRISCV_REGADDRBUS];
    wire [`MYRISCV_REGADDRBUS] rv16_cr_rs2 = rv16_rs2[`MYRISCV_REGADDRBUS];
        // The JALR and JR difference in encoding is just the instr_16[12]
    wire [`MYRISCV_REGADDRBUS] rv16_cr_rd  = (rv16_jalr | rv16_jr)? 
                    {{`MYRISCV_REGADDRWD-1{1'b0}},instr_16[12]} : rv16_rd[`MYRISCV_REGADDRBUS];
                            
    // In CI Cases:
    //   * LWSP:     rs1= x2 (implicit),  rd = rd 
    //   * LI/LUI:   rs1= x0 (implicit),  rd = rd
    //   * ADDI:     rs1= rs1(implicit),  rd = rd
    //   * ADDI16SP: rs1= rs1(implicit),  rd = rd
    //   * SLLI:     rs1= rs1(implicit),  rd = rd
    wire rv16_need_ci_rs1   = rv16_format_ci & 1'b1;
    wire rv16_need_ci_rs2   = rv16_format_ci & 1'b0;
    wire rv16_need_ci_rd    = rv16_format_ci & 1'b1;
    wire [`MYRISCV_REGADDRBUS] rv16_ci_rs1 = (rv16_lwsp | rv16_flwsp | rv16_fldsp) ? `MYRISCV_REGADDRWD'd2 :
                                    (rv16_li | rv16_lui) ? `MYRISCV_REGADDRWD'd0 : rv16_rs1[`MYRISCV_REGADDRBUS];
    wire [`MYRISCV_REGADDRBUS] rv16_ci_rs2 = `MYRISCV_REGADDRWD'd0;
    wire [`MYRISCV_REGADDRBUS] rv16_ci_rd  = rv16_rd[`MYRISCV_REGADDRBUS];
                            
    // In CSS Cases:
    //   * SWSP:     rs1 = x2 (implicit), rs2= rs2 
    wire rv16_need_css_rs1  = rv16_format_css & 1'b1;
    wire rv16_need_css_rs2  = rv16_format_css & 1'b1;
    wire rv16_need_css_rd   = rv16_format_css & 1'b0;
    wire [`MYRISCV_REGADDRBUS] rv16_css_rs1 = `MYRISCV_REGADDRWD'd2;
    wire [`MYRISCV_REGADDRBUS] rv16_css_rs2 = rv16_rs2[`MYRISCV_REGADDRBUS];
    wire [`MYRISCV_REGADDRBUS] rv16_css_rd  = `MYRISCV_REGADDRWD'd0;
                        
    // In CIW cases:
    //   * ADDI4SPN:   rdd = rdd, rss1= x2 (implicit)
    wire rv16_need_ciw_rss1 = rv16_format_ciw & 1'b1;
    wire rv16_need_ciw_rss2 = rv16_format_ciw & 1'b0;
    wire rv16_need_ciw_rdd  = rv16_format_ciw & 1'b1;
    wire [`MYRISCV_REGADDRBUS] rv16_ciw_rss1  = `MYRISCV_REGADDRWD'd2;
    wire [`MYRISCV_REGADDRBUS] rv16_ciw_rss2  = `MYRISCV_REGADDRWD'd0;
    wire [`MYRISCV_REGADDRBUS] rv16_ciw_rdd  = rv16_rdd[`MYRISCV_REGADDRBUS];
                        
    // In CL cases:
    //   * LW:   rss1 = rss1, rdd= rdd
    wire rv16_need_cl_rss1  = rv16_format_cl & 1'b1;
    wire rv16_need_cl_rss2  = rv16_format_cl & 1'b0;
    wire rv16_need_cl_rdd   = rv16_format_cl & 1'b1;
    wire [`MYRISCV_REGADDRBUS] rv16_cl_rss1 = rv16_rss1[`MYRISCV_REGADDRBUS];
    wire [`MYRISCV_REGADDRBUS] rv16_cl_rss2 = `MYRISCV_REGADDRWD'd0;
    wire [`MYRISCV_REGADDRBUS] rv16_cl_rdd  = rv16_rdd[`MYRISCV_REGADDRBUS];
                        
    // In CS cases:
    //   * SW:            rdd = none(implicit), rss1= rss1       , rss2=rss2
    //   * SUBXORORAND:   rdd = rss1,           rss1= rss1(coded), rss2=rss2
    wire rv16_need_cs_rss1  = rv16_format_cs & 1'b1;
    wire rv16_need_cs_rss2  = rv16_format_cs & 1'b1;
    wire rv16_need_cs_rdd   = rv16_format_cs & rv16_subxororand;
    wire [`MYRISCV_REGADDRBUS] rv16_cs_rss1 = rv16_rss1[`MYRISCV_REGADDRBUS];
    wire [`MYRISCV_REGADDRBUS] rv16_cs_rss2 = rv16_rss2[`MYRISCV_REGADDRBUS];
    wire [`MYRISCV_REGADDRBUS] rv16_cs_rdd  = rv16_rss1[`MYRISCV_REGADDRBUS];
                        
    // In CB cases:
    //   * BEQ/BNE:            rdd = none(implicit), rss1= rss1, rss2=x0(implicit)
    //   * SRLI/SRAI/ANDI:     rdd = rss1          , rss1= rss1, rss2=none(implicit)
    wire rv16_need_cb_rss1  = rv16_format_cb & 1'b1;
    wire rv16_need_cb_rss2  = rv16_format_cb & (rv16_beqz | rv16_bnez);
    wire rv16_need_cb_rdd   = rv16_format_cb & (~(rv16_beqz | rv16_bnez));
    wire [`MYRISCV_REGADDRBUS] rv16_cb_rss1 = rv16_rss1[`MYRISCV_REGADDRBUS];
    wire [`MYRISCV_REGADDRBUS] rv16_cb_rss2 = `MYRISCV_REGADDRWD'd0;
    wire [`MYRISCV_REGADDRBUS] rv16_cb_rdd  = rv16_rss1[`MYRISCV_REGADDRBUS];
    
    // In CJ cases:
    //   * J:            rdd = x0(implicit)
    //   * JAL:          rdd = x1(implicit)
    wire rv16_need_cj_rss1  = rv16_format_cj & 1'b0;
    wire rv16_need_cj_rss2  = rv16_format_cj & 1'b0;
    wire rv16_need_cj_rdd   = rv16_format_cj & 1'b1;
    wire [`MYRISCV_REGADDRBUS] rv16_cj_rss1 = `MYRISCV_REGADDRWD'd0;
    wire [`MYRISCV_REGADDRBUS] rv16_cj_rss2 = `MYRISCV_REGADDRWD'd0;
    wire [`MYRISCV_REGADDRBUS] rv16_cj_rdd  = rv16_j ? `MYRISCV_REGADDRWD'd0 : `MYRISCV_REGADDRWD'd1;

    // rv16_format_cr  
    // rv16_format_ci  
    // rv16_format_css 
    // rv16_format_ciw 
    // rv16_format_cl  
    // rv16_format_cs  
    // rv16_format_cb  
    // rv16_format_cj  
    wire rv16_need_rs1 = rv16_need_cr_rs1 | rv16_need_ci_rs1 | rv16_need_css_rs1;
    wire rv16_need_rs2 = rv16_need_cr_rs2 | rv16_need_ci_rs2 | rv16_need_css_rs2;
    wire rv16_need_rd  = rv16_need_cr_rd  | rv16_need_ci_rd  | rv16_need_css_rd;

    wire rv16_need_rss1 = rv16_need_ciw_rss1|rv16_need_cl_rss1|rv16_need_cs_rss1|rv16_need_cb_rss1|rv16_need_cj_rss1;
    wire rv16_need_rss2 = rv16_need_ciw_rss2|rv16_need_cl_rss2|rv16_need_cs_rss2|rv16_need_cb_rss2|rv16_need_cj_rss2;
    wire rv16_need_rdd  = rv16_need_ciw_rdd |rv16_need_cl_rdd |rv16_need_cs_rdd |rv16_need_cb_rdd |rv16_need_cj_rdd ;

    wire rv16_rs1en = (rv16_need_rs1 | rv16_need_rss1);
    wire rv16_rs2en = (rv16_need_rs2 | rv16_need_rss2);
    wire rv16_rden  = (rv16_need_rd  | rv16_need_rdd );

    wire [`MYRISCV_REGADDRBUS] rv16_rs1idx;
    wire [`MYRISCV_REGADDRBUS] rv16_rs2idx;
    wire [`MYRISCV_REGADDRBUS] rv16_rdidx ;

    assign rv16_rs1idx = 
            ({`MYRISCV_REGADDRWD{rv16_need_cr_rs1 }} & rv16_cr_rs1)
        | ({`MYRISCV_REGADDRWD{rv16_need_ci_rs1 }} & rv16_ci_rs1)
        | ({`MYRISCV_REGADDRWD{rv16_need_css_rs1}} & rv16_css_rs1)
        | ({`MYRISCV_REGADDRWD{rv16_need_ciw_rss1}} & rv16_ciw_rss1)
        | ({`MYRISCV_REGADDRWD{rv16_need_cl_rss1}}  & rv16_cl_rss1)
        | ({`MYRISCV_REGADDRWD{rv16_need_cs_rss1}}  & rv16_cs_rss1)
        | ({`MYRISCV_REGADDRWD{rv16_need_cb_rss1}}  & rv16_cb_rss1)
        | ({`MYRISCV_REGADDRWD{rv16_need_cj_rss1}}  & rv16_cj_rss1)
        ;

    assign rv16_rs2idx = 
            ({`MYRISCV_REGADDRWD{rv16_need_cr_rs2 }} & rv16_cr_rs2)
        | ({`MYRISCV_REGADDRWD{rv16_need_ci_rs2 }} & rv16_ci_rs2)
        | ({`MYRISCV_REGADDRWD{rv16_need_css_rs2}} & rv16_css_rs2)
        | ({`MYRISCV_REGADDRWD{rv16_need_ciw_rss2}} & rv16_ciw_rss2)
        | ({`MYRISCV_REGADDRWD{rv16_need_cl_rss2}}  & rv16_cl_rss2)
        | ({`MYRISCV_REGADDRWD{rv16_need_cs_rss2}}  & rv16_cs_rss2)
        | ({`MYRISCV_REGADDRWD{rv16_need_cb_rss2}}  & rv16_cb_rss2)
        | ({`MYRISCV_REGADDRWD{rv16_need_cj_rss2}}  & rv16_cj_rss2)
        ;

    assign rv16_rdidx = 
            ({`MYRISCV_REGADDRWD{rv16_need_cr_rd }} & rv16_cr_rd)
        | ({`MYRISCV_REGADDRWD{rv16_need_ci_rd }} & rv16_ci_rd)
        | ({`MYRISCV_REGADDRWD{rv16_need_css_rd}} & rv16_css_rd)
        | ({`MYRISCV_REGADDRWD{rv16_need_ciw_rdd}} & rv16_ciw_rdd)
        | ({`MYRISCV_REGADDRWD{rv16_need_cl_rdd}}  & rv16_cl_rdd)
        | ({`MYRISCV_REGADDRWD{rv16_need_cs_rdd}}  & rv16_cs_rdd)
        | ({`MYRISCV_REGADDRWD{rv16_need_cb_rdd}}  & rv16_cb_rdd)
        | ({`MYRISCV_REGADDRWD{rv16_need_cj_rdd}}  & rv16_cj_rdd)
        ;

    assign dec2ex_rs1idx = is_instr_32 ? rv32_rs1[`MYRISCV_REGADDRBUS] : rv16_rs1idx;
    assign dec2ex_rs2idx = is_instr_32 ? rv32_rs2[`MYRISCV_REGADDRBUS] : rv16_rs2idx;
    assign dec2ex_rdidx  = is_instr_32 ? rv32_rd [`MYRISCV_REGADDRBUS] : rv16_rdidx ;


    assign dec2ex_rs1en = is_instr_32 ? rv32_need_rs1 : (rv16_rs1en & (~(rv16_rs1idx == `MYRISCV_REGADDRWD'b0))); 
    assign dec2ex_rs2en = is_instr_32 ? rv32_need_rs2 : (rv16_rs2en & (~(rv16_rs2idx == `MYRISCV_REGADDRWD'b0)));
    assign dec2ex_rdwen = is_instr_32 ? rv32_need_rd  : (rv16_rden  & (~(rv16_rdidx  == `MYRISCV_REGADDRWD'b0)));

    assign dec2ex_rs1x0 = (dec2ex_rs1idx == `MYRISCV_REGADDRWD'b0);
    assign dec2ex_rs2x0 = (dec2ex_rs2idx == `MYRISCV_REGADDRWD'b0);
                        
    wire rv_index_ilgl;
    //   `ifdef E203_RFREG_NUM_IS_4 //{ 
    //   assign rv_index_ilgl =
    //                  (| dec2ex_rs1idx[`MYRISCV_REGADDRWD-1:2])
    //                 |(| dec2ex_rs2idx[`MYRISCV_REGADDRWD-1:2])
    //                 |(| dec2ex_rdidx [`MYRISCV_REGADDRWD-1:2])
    //                 ;
    //   `endif//}
    //   `ifdef E203_RFREG_NUM_IS_8 //{ 
    //   assign rv_index_ilgl =
    //                  (| dec2ex_rs1idx[`MYRISCV_REGADDRWD-1:3])
    //                 |(| dec2ex_rs2idx[`MYRISCV_REGADDRWD-1:3])
    //                 |(| dec2ex_rdidx [`MYRISCV_REGADDRWD-1:3])
    //                 ;
    //   `endif//}
    //   `ifdef E203_RFREG_NUM_IS_16 //{ 
    //   assign rv_index_ilgl =
    //                  (| dec2ex_rs1idx[`MYRISCV_REGADDRWD-1:4])
    //                 |(| dec2ex_rs2idx[`MYRISCV_REGADDRWD-1:4])
    //                 |(| dec2ex_rdidx [`MYRISCV_REGADDRWD-1:4])
    //                 ;
    //   `endif//}
    //   `ifdef E203_RFREG_NUM_IS_32 //{ 
        //Never happen this illegal exception
    assign rv_index_ilgl = 1'b0;
    //   `endif//}

    assign dec_rv32 = is_instr_32;

    assign dec_bjp_imm = 
                        ({32{rv16_jal | rv16_j     }} & rv16_jjal_imm)
                    | ({32{rv16_jalr_mv_add      }} & rv16_jrjalr_imm)
                    | ({32{rv16_beqz | rv16_bnez }} & rv16_bxx_imm)
                    | ({(`MYRISCV_XLEN){rv32_jal              }} & rv32_jal_imm)
                    | ({(`MYRISCV_XLEN){rv32_jalr             }} & rv32_jalr_imm)
                    | ({(`MYRISCV_XLEN){rv32_branch           }} & rv32_bxx_imm)
                    ;

    assign dec_jalr_rs1idx = is_instr_32 ? rv32_rs1[`MYRISCV_REGADDRBUS] : rv16_rs1[`MYRISCV_REGADDRBUS]; 

    assign dec_misalgn = i_misalgn;
    assign dec_buserr  = i_buserr ;


    assign dec_ilegl = 
                (rv_all0s1s_ilgl) 
            | (rv_index_ilgl)  
            | (rv16_addi16sp_ilgl)
            | (rv16_addi4spn_ilgl)
            | (rv16_li_lui_ilgl)
            | (rv16_sxxi_shamt_ilgl)
            | (rv32_sxxi_shamt_ilgl)
            | (rv32_dret_ilgl)
            | (rv16_lwsp_ilgl)
            | (~legl_ops);
    //muldiv, load都是长指令。
    assign is_long_instr = 
    `ifndef DIV_CC //r:note! div_cc is on cycle module!
        muldiv_op | 
    `endif
        (amoldst_op & agu_info_bus[`MY_DECINFO_AGU_LOAD]);

    endmodule                                      
/* verilator lint_on WIDTHEXPAND*/
                                    
                                                
                                                
