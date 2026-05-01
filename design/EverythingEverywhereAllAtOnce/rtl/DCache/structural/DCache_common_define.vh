`ifndef DCACHE_COMMON_DEFINE_VH
`define DCACHE_COMMON_DEFINE_VH

// Mirrors rtl/DCache/pkg/DCache_common_pkg.sv for Verilog-2005 structural use.

//////////////////////////////////////////////////////////////////////
// DCache geometry
//////////////////////////////////////////////////////////////////////
`define DCACHE_NUM_BLOCKS                   (4)

// p_address_t = [14:0]
`define P_ADDR_W                            (15)

// DCache Bank address fields
`define DCACHE_BANK_TAG_UB                  (14)
`define DCACHE_BANK_TAG_LB                  (9)
`define DCACHE_BANK_INDEX_UB                (8)
`define DCACHE_BANK_INDEX_LB                (6)
`define DCACHE_BANK_BANK_UB                 (5)
`define DCACHE_BANK_BANK_LB                 (4)
`define DCACHE_BANK_OFFSET_UB               (3)
`define DCACHE_BANK_OFFSET_LB               (0)

`define DCACHE_BANK_TAG_W                   (6)
`define DCACHE_BANK_INDEX_W                 (3)
`define DCACHE_BANK_BANK_W                  (2)
`define DCACHE_BANK_OFFSET_W                (4)

`define DCACHE_BANK_NUM_LINES               (8)

// VCache address fields
`define V_CACHE_TAG_UB                      (14)
`define V_CACHE_TAG_LB                      (6)
`define V_CACHE_BANK_UB                     (5)
`define V_CACHE_BANK_LB                     (4)
`define V_CACHE_OFFSET_UB                   (3)
`define V_CACHE_OFFSET_LB                   (0)

`define V_CACHE_TAG_W                       (9)
`define V_CACHE_BANK_W                      (2)
`define V_CACHE_OFFSET_W                    (4)

`define VCACHE_NUM_LINES                    (4)
`define VCACHE_LINE_IDX_W                   (2)

// BUFFER_DELAY uses 0.25 ns/stage. CLK_PHASE_DELAY=2.5ns -> 10 stages. OE delay #2 -> 8.
`define CLK_PHASE_BUFFER_STAGES             (14)
`define OE_DELAY_BUFFER_STAGES              (8)

//////////////////////////////////////////////////////////////////////
// req_2_sch_t  (14-bit, integer-valued, 15 named values)
//////////////////////////////////////////////////////////////////////
`define REQ_2_SCH_W                                14

`define REQ_NO_REQ                                 14'd0
`define REQ_DMA_WRITE_REQ                          14'd1
`define REQ_ICACHE_LOW_PRI_REQ                     14'd2
`define REQ_DCACHE_MIO_WR_SIMPLE                   14'd3
`define REQ_DCACHE_MIO_WR_COMPLEX                  14'd4
`define REQ_DCACHE_MIO_LD_FROM_SIMPLE              14'd5
`define REQ_DCACHE_EB_WR                           14'd6
`define REQ_DCACHE_FILL_ST                         14'd7
`define REQ_DCACHE_FILL_LD                         14'd8
`define REQ_DCACHE_FILL_ST_OVERRIDE                14'd9
`define REQ_DCACHE_EB_BLOCK_ST                     14'd10
`define REQ_DCACHE_EB_BLOCKING_LD                  14'd11
`define REQ_DCACHE_EB_BLOCKING_ST_OVERRIDE         14'd12
`define REQ_DCACHE_EB_BLOCKING_BANK                14'd13
`define REQ_ICACHE_HIGH_PRI                        14'd14

`define CL_W                                       (`CACHE_LINES_SIZE_BITS)
`define VEC_W                                      (16)

//////////////////////////////////////////////////////////////////////
// block_req_t flat layout (LSB -> MSB):
//   [0] oe, [1] we, [16:2] p_addr, [32:17] vec, [160:33] st_q_data
//////////////////////////////////////////////////////////////////////
`define BREQ_W                       161
`define BREQ_OE                      0
`define BREQ_WE                      1
`define BREQ_PADDR_LB                2
`define BREQ_PADDR_UB                16
`define BREQ_VEC_LB                  17
`define BREQ_VEC_UB                  32
`define BREQ_DATA_LB                 33
`define BREQ_DATA_UB                 160

//////////////////////////////////////////////////////////////////////
// block_req_mio_t flat layout:
//   [0] oe, [1] we, [16:2] p_addr, [144:17] st_q_data
//////////////////////////////////////////////////////////////////////
`define BREQ_MIO_W                   145
`define BREQ_MIO_OE                  0
`define BREQ_MIO_WE                  1
`define BREQ_MIO_PADDR_LB            2
`define BREQ_MIO_PADDR_UB            16
`define BREQ_MIO_DATA_LB             17
`define BREQ_MIO_DATA_UB             144

//////////////////////////////////////////////////////////////////////
// swap_buf_t flat layout:
//   [0] valid, [1] dirty, [16:2] lineAddr, [144:17] line
//////////////////////////////////////////////////////////////////////
`define SWAP_W                       145
`define SWAP_VALID                   0
`define SWAP_DIRTY                   1
`define SWAP_ADDR_LB                 2
`define SWAP_ADDR_UB                 16
`define SWAP_LINE_LB                 17
`define SWAP_LINE_UB                 144

//////////////////////////////////////////////////////////////////////
// eb_outputs_t flat layout:
//   [0] valid, [1] commiting, [16:2] addr, [144:17] lineOut, [145] reqHit
//////////////////////////////////////////////////////////////////////
`define EB_OUT_W                     146
`define EB_OUT_VALID                 0
`define EB_OUT_COMMITING             1
`define EB_OUT_ADDR_LB               2
`define EB_OUT_ADDR_UB               16
`define EB_OUT_LINE_LB               17
`define EB_OUT_LINE_UB               144
`define EB_OUT_REQHIT                145

//////////////////////////////////////////////////////////////////////
// d_cache_bank_outputs_t flat layout:
//   [0] hit, [145:1] dcache_swapBuf, [146] V_Cache_swapBuf_valid_clr,
//   [147] D_will_evict, [148] busy, [276:149] data_lineOut,
//   [277] MakeReq, [278] eb_stalling
//////////////////////////////////////////////////////////////////////
`define DCB_OUT_W                    279
`define DCB_OUT_HIT                  0
`define DCB_OUT_SWAP_LB              1
`define DCB_OUT_SWAP_UB              145
`define DCB_OUT_VSWAP_VCLR           146
`define DCB_OUT_DWILLEVICT           147
`define DCB_OUT_BUSY                 148
`define DCB_OUT_LINE_LB              149
`define DCB_OUT_LINE_UB              276
`define DCB_OUT_MAKEREQ              277
`define DCB_OUT_EBSTALL              278

//////////////////////////////////////////////////////////////////////
// v_cache_outputs_t flat layout:
//   [0] hit, [1] miss, [146:2] vcache_swapBuf,
//   [147] D_Cache_swapBuf_valid_clr, [148] LD_EB, [149] busy,
//   [150] beingBlocked, [278:151] lineOut, [293:279] addrOut
//////////////////////////////////////////////////////////////////////
`define VC_OUT_W                     294
`define VC_OUT_HIT                   0
`define VC_OUT_MISS                  1
`define VC_OUT_SWAP_LB               2
`define VC_OUT_SWAP_UB               146
`define VC_OUT_DSWAP_VCLR            147
`define VC_OUT_LD_EB                 148
`define VC_OUT_BUSY                  149
`define VC_OUT_BEINGBLOCKED          150
`define VC_OUT_LINE_LB               151
`define VC_OUT_LINE_UB               278
`define VC_OUT_ADDR_LB               279
`define VC_OUT_ADDR_UB               293

//////////////////////////////////////////////////////////////////////
// dcache_block_outputs_t flat layout:
//   [127:0] dataLineOut, [128] hit_o, [143:129] eb_addr, [157:144] req_2_sch
//////////////////////////////////////////////////////////////////////
`define DCBLK_OUT_W                  158
`define DCBLK_OUT_LINE_LB            0
`define DCBLK_OUT_LINE_UB            127
`define DCBLK_OUT_HIT                128
`define DCBLK_OUT_EBADDR_LB          129
`define DCBLK_OUT_EBADDR_UB          143
`define DCBLK_OUT_REQ_LB             144
`define DCBLK_OUT_REQ_UB             157

//////////////////////////////////////////////////////////////////////
// mio_block_outputs_t flat layout:
//   [0] writeSuccess, [1] hit_o, [129:2] dataLineOut,
//   [143:130] req_2_sch, [144] reqServed
//////////////////////////////////////////////////////////////////////
`define MIO_OUT_W                    145
`define MIO_OUT_WRSUCCESS            0
`define MIO_OUT_HIT                  1
`define MIO_OUT_LINE_LB              2
`define MIO_OUT_LINE_UB              129
`define MIO_OUT_REQ_LB               130
`define MIO_OUT_REQ_UB               143
`define MIO_OUT_REQSERVED            144

//////////////////////////////////////////////////////////////////////
// st_q_2_dcache_t flat layout:
//   [0] full, [1] empty, [16:2] address, [32:17] bit_vec, [160:33] data
//////////////////////////////////////////////////////////////////////
`define STQ_W                        161
`define STQ_FULL                     0
`define STQ_EMPTY                    1
`define STQ_ADDR_LB                  2
`define STQ_ADDR_UB                  16
`define STQ_VEC_LB                   17
`define STQ_VEC_UB                   32
`define STQ_DATA_LB                  33
`define STQ_DATA_UB                  160

//////////////////////////////////////////////////////////////////////
// dte_2_dcache_t flat layout, per-block elements (NUM_DCACHE_PORTS=4):
//   per-block (PB): mem_valid + 4 perm-data + perm-addr-Ld + perm-addr-eb
//                   + eb_clr + eb_setCommiting = 9 bits
//   plus reqServed_mio + perm_addr_mio + perm_data_mio = 3 bits
// total = 4*9 + 3 = 39 bits.
//////////////////////////////////////////////////////////////////////
`define DTE_PB_W                     9
`define DTE_PB_MEM_VALID             0
`define DTE_PB_PERM_DATA_LB          1
`define DTE_PB_PERM_DATA_UB          4
`define DTE_PB_PERM_ADDR_LD          5
`define DTE_PB_PERM_ADDR_EB          6
`define DTE_PB_EB_CLR                7
`define DTE_PB_EB_SETCOMMITING       8

`define DTE_PB_LB(I)                 ((I)*9)
`define DTE_PB_UB(I)                 ((I)*9+8)
`define DTE_REQSERVED_MIO            36
`define DTE_PERM_ADDR_MIO            37
`define DTE_PERM_DATA_MIO            38
`define DTE_W                        39

//////////////////////////////////////////////////////////////////////
// dcache_2_scheduler_t flat layout:
//   per-block: req(14) + ebAddr(15) = 29 bits, x4 blocks = 116
//   plus req_mio(14)
//   total = 130
//////////////////////////////////////////////////////////////////////
`define D2S_PB_W                     29
`define D2S_PB_REQ_LB                0
`define D2S_PB_REQ_UB                13
`define D2S_PB_EBADDR_LB             14
`define D2S_PB_EBADDR_UB             28

`define D2S_W                        130
`define D2S_PB_LB(I)                 ((I)*29)
`define D2S_PB_UB(I)                 ((I)*29+28)
`define D2S_REQ_MIO_LB               116
`define D2S_REQ_MIO_UB               129

//////////////////////////////////////////////////////////////////////
// core_2_dcache_t flat layout:
//   ld_addr_0_V(1) + ld_addr_0(15) + ld_addr_1_V(1) + ld_addr_1(15)
//   + 4*stq_heads(161 each = 644)
//   + ld_addr_MIO_V(1) + ld_addr_MIO(15)
//   + 4*memStage_CLR_REQ(1 each = 4) + memStage_CLR_REQ_MIO(1)
//   + stq_info_mio(161)
// total = 1+15+1+15+644+1+15+4+1+161 = 858
//////////////////////////////////////////////////////////////////////
`define C2D_W                        858
`define C2D_LD0_V                    0
`define C2D_LD0_LB                   1
`define C2D_LD0_UB                   15
`define C2D_LD1_V                    16
`define C2D_LD1_LB                   17
`define C2D_LD1_UB                   31
`define C2D_STQ_BASE                 32
`define C2D_STQ_LB(I)                (32 + (I)*161)
`define C2D_STQ_UB(I)                (32 + (I)*161 + 160)
`define C2D_LD_MIO_V                 676
`define C2D_LD_MIO_LB                677
`define C2D_LD_MIO_UB                691
`define C2D_CLR_REQ_LB               692
`define C2D_CLR_REQ_UB               695
`define C2D_CLR_REQ_MIO              696
`define C2D_STQ_MIO_LB               697
`define C2D_STQ_MIO_UB               857

//////////////////////////////////////////////////////////////////////
// dcache_2_core_t flat layout:
//   reqServed_0(1) + reqServed_1(1)
//   + 4*hit(1) + 4*cacheline(128 each = 512)
//   + 4*writeSuccess(1)
//   + writeSuccess_MIO(1) + hit_MIO(1) + reqServed_MIO(1) + line_MIO(128)
// total = 2 + 4 + 512 + 4 + 3 + 128 = 653
//////////////////////////////////////////////////////////////////////
`define D2C_W                        653
`define D2C_REQSERVED_0              0
`define D2C_REQSERVED_1              1
`define D2C_HIT_LB                   2
`define D2C_HIT_UB                   5
`define D2C_LINE_BASE                6
`define D2C_LINE_LB(I)               (6 + (I)*128)
`define D2C_LINE_UB(I)               (6 + (I)*128 + 127)
`define D2C_WRSUCC_LB                518
`define D2C_WRSUCC_UB                521
`define D2C_WRSUCC_MIO               522
`define D2C_HIT_MIO                  523
`define D2C_REQSERVED_MIO            524
`define D2C_LINE_MIO_LB              525
`define D2C_LINE_MIO_UB              652

`endif
