`ifndef DCACHE_COMMON_DEFINE_VH
`define DCACHE_COMMON_DEFINE_VH

// Mirrors rtl/DCache/pkg/DCache_common_pkg.sv for Verilog-2005 structural use.
// This file is grown incrementally per module. Keep ordering identical to the
// SV typedef field declarations so field offsets are predictable.

`include "common_define.vh"
`include "interconnect_define.vh"

//////////////////////////////////////////////////////////////////////
// DCache geometry
//////////////////////////////////////////////////////////////////////
`define DCACHE_NUM_BLOCKS                   (4)

// p_address_t = [14:0] (15 bits, since PHY_MEM_SIZE = 1<<15)
`define P_ADDR_W                            (15)

// DCache Bank address field bit positions (p_addr[14:0])
`define DCACHE_BANK_TAG_UB                  (14)
`define DCACHE_BANK_TAG_LB                  (9)
`define DCACHE_BANK_INDEX_UB                (8)
`define DCACHE_BANK_INDEX_LB                (6)
`define DCACHE_BANK_BANK_UB                 (5)
`define DCACHE_BANK_BANK_LB                 (4)
`define DCACHE_BANK_OFFSET_UB               (3)
`define DCACHE_BANK_OFFSET_LB               (0)

`define DCACHE_BANK_TAG_W                   (6)   // 14-9+1
`define DCACHE_BANK_INDEX_W                 (3)   // 8-6+1
`define DCACHE_BANK_BANK_W                  (2)   // 5-4+1
`define DCACHE_BANK_OFFSET_W                (4)   // 3-0+1

`define DCACHE_BANK_NUM_LINES               (8)   // 1 << INDEX_W

// VCache address field bit positions
`define V_CACHE_TAG_UB                      (14)
`define V_CACHE_TAG_LB                      (6)
`define V_CACHE_BANK_UB                     (5)
`define V_CACHE_BANK_LB                     (4)
`define V_CACHE_OFFSET_UB                   (3)
`define V_CACHE_OFFSET_LB                   (0)

`define V_CACHE_TAG_W                       (9)   // 14-6+1
`define V_CACHE_BANK_W                      (2)
`define V_CACHE_OFFSET_W                    (4)

`define VCACHE_NUM_LINES                    (4)
`define VCACHE_LINE_IDX_W                   (2)   // $clog2(4)

// Phased-clock buffer stages: BUFFER_DELAY uses 0.25 ns per stage.
// CLK_PHASE_DELAY = 2.5 ns -> 10 stages.
`define CLK_PHASE_BUFFER_STAGES             (10)
// OE delay (#2 ns) -> 8 stages
`define OE_DELAY_BUFFER_STAGES              (8)

//////////////////////////////////////////////////////////////////////
// req_2_sch_t  (14-bit logic, integer-valued)
// See rtl/pkgs/interconnect_pkg.sv : enum logic [NUM_REQS-1:0] (NUM_REQS=14)
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

//////////////////////////////////////////////////////////////////////
// Cacheline & store-queue widths
//////////////////////////////////////////////////////////////////////
`define CL_W                                       (`CACHE_LINES_SIZE_BITS)  // 128
`define VEC_W                                      (16)                      // uint16_t

//////////////////////////////////////////////////////////////////////
// block_req_t flat layout (LSB -> MSB):
//   [0]               oe
//   [1]               we
//   [16:2]            p_addr        (15)
//   [32:17]           vec           (16)
//   [160:33]          st_q_data     (128)
// total = 161
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
// block_req_mio_t flat layout (LSB -> MSB):
//   [0]               oe
//   [1]               we
//   [16:2]            p_addr        (15)
//   [144:17]          st_q_data     (128)
// total = 145
//////////////////////////////////////////////////////////////////////
`define BREQ_MIO_W                   145
`define BREQ_MIO_OE                  0
`define BREQ_MIO_WE                  1
`define BREQ_MIO_PADDR_LB            2
`define BREQ_MIO_PADDR_UB            16
`define BREQ_MIO_DATA_LB             17
`define BREQ_MIO_DATA_UB             144

//////////////////////////////////////////////////////////////////////
// swap_buf_t flat layout (LSB -> MSB):
//   [0]               valid
//   [1]               dirty
//   [16:2]            lineAddr      (15)
//   [144:17]          line          (128)
// total = 145
//////////////////////////////////////////////////////////////////////
`define SWAP_W                       145
`define SWAP_VALID                   0
`define SWAP_DIRTY                   1
`define SWAP_ADDR_LB                 2
`define SWAP_ADDR_UB                 16
`define SWAP_LINE_LB                 17
`define SWAP_LINE_UB                 144

//////////////////////////////////////////////////////////////////////
// eb_outputs_t flat layout (LSB -> MSB):
//   [0]               valid
//   [1]               commiting
//   [16:2]            addr          (15)
//   [144:17]          lineOut       (128)
//   [145]             reqHit
// total = 146
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
// d_cache_bank_outputs_t flat layout (LSB -> MSB):
//   [0]               hit
//   [145:1]           dcache_swapBuf (145, layout = SWAP)
//   [146]             V_Cache_swapBuf_valid_clr
//   [147]             D_will_evict
//   [148]             busy
//   [276:149]         data_lineOut  (128)
//   [277]             MakeReq
//   [278]             eb_stalling
// total = 279
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
// v_cache_outputs_t flat layout (LSB -> MSB):
//   [0]               hit
//   [1]               miss
//   [146:2]           vcache_swapBuf (145, layout = SWAP)
//   [147]             D_Cache_swapBuf_valid_clr
//   [148]             LD_EB
//   [149]             busy
//   [150]             beingBlocked
//   [278:151]         lineOut       (128)
//   [293:279]         addrOut       (15)
// total = 294
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
// dcache_block_outputs_t flat layout (LSB -> MSB):
//   [127:0]           dataLineOut   (128)
//   [128]             hit_o
//   [143:129]         eb_addr       (15)
//   [157:144]         req_2_sch     (14)
// total = 158
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
// mio_block_outputs_t flat layout (LSB -> MSB):
//   [0]               writeSuccess
//   [1]               hit_o
//   [129:2]           dataLineOut   (128)
//   [143:130]         req_2_sch     (14)
//   [144]             reqServed
// total = 145
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
// st_q_2_dcache_t flat layout (LSB -> MSB):
//   [0]               full
//   [1]               empty
//   [16:2]            address       (15)
//   [32:17]           bit_vec       (16)
//   [160:33]          data          (128)
// total = 161
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

`endif
