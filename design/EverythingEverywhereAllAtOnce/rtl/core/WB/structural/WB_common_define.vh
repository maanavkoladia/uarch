`ifndef WB_COMMON_DEFINE_VH
`define WB_COMMON_DEFINE_VH

// Flat layouts mirroring rtl/core/WB/pkg/WriteBack_pkg.sv and the WB-side
// fields of rtl/core/pkgs/core_stage_latches_pkg.sv / core_common_pkg.sv.
//
// Ordering convention: LSB-first per SV declaration order.
// (matches the convention used in rtl/DCache/structural/DCache_common_define.vh)

`include "common_define.vh"
`include "DCache_common_define.vh"

//////////////////////////////////////////////////////////////////////
// wb_cs_t (4 bits)
//   typedef struct { bool ST_OP; bool WB_DR; bool WB_SR; bool WB_EAX; } wb_cs_t;
//////////////////////////////////////////////////////////////////////
`define WBCS_W                 4
`define WBCS_ST_OP             0
`define WBCS_WB_DR             1
`define WBCS_WB_SR             2
`define WBCS_WB_EAX            3

//////////////////////////////////////////////////////////////////////
// st_q_entry_t (160 bits)
//   { valid(1), address(15), bit_vec(16), data(128) }
//////////////////////////////////////////////////////////////////////
`define STQE_W                 160
`define STQE_VALID             0
`define STQE_ADDR_LB           1
`define STQE_ADDR_UB           15
`define STQE_VEC_LB            16
`define STQE_VEC_UB            31
`define STQE_DATA_LB           32
`define STQE_DATA_UB           159

//////////////////////////////////////////////////////////////////////
// st_q_inputs_t (162 bits)
//   { entry(160), push(1), pop(1) }
//////////////////////////////////////////////////////////////////////
`define STQI_W                 162
`define STQI_ENTRY_LB          0
`define STQI_ENTRY_UB          159
`define STQI_PUSH              160
`define STQI_POP               161

//////////////////////////////////////////////////////////////////////
// mio_entry_t (144 bits)
//   { valid(1), address(15), data(128) }
//////////////////////////////////////////////////////////////////////
`define MIOE_W                 144
`define MIOE_VALID             0
`define MIOE_ADDR_LB           1
`define MIOE_ADDR_UB           15
`define MIOE_DATA_LB           16
`define MIOE_DATA_UB           143

//////////////////////////////////////////////////////////////////////
// mio_inputs_t (146 bits)
//   { entry(144), push(1), pop(1) }
//////////////////////////////////////////////////////////////////////
`define MIOI_W                 146
`define MIOI_ENTRY_LB          0
`define MIOI_ENTRY_UB          143
`define MIOI_PUSH              144
`define MIOI_POP               145

//////////////////////////////////////////////////////////////////////
// st_q_outputs_t (226 bits)  -- ST_Q internal output bus
//   { full(1), empty(1), valid[4](4), address[4](4*15=60),
//     head_address(15), bit_vec(16), data(128), push_fail(1) }
//////////////////////////////////////////////////////////////////////
`define STQO_W                 226
`define STQO_FULL              0
`define STQO_EMPTY             1
`define STQO_VALID(i)          (2 + (i))
`define STQO_VALIDS_LB         2
`define STQO_VALIDS_UB         5
`define STQO_ADDR_LB(i)        (6 + (i)*15)
`define STQO_ADDR_UB(i)        (6 + (i)*15 + 14)
`define STQO_ADDRS_LB          6
`define STQO_ADDRS_UB          65
`define STQO_HEAD_ADDR_LB      66
`define STQO_HEAD_ADDR_UB      80
`define STQO_BITVEC_LB         81
`define STQO_BITVEC_UB         96
`define STQO_DATA_LB           97
`define STQO_DATA_UB           224
`define STQO_PUSH_FAIL         225

//////////////////////////////////////////////////////////////////////
// mem_dep_check_info_t (16 bits)
//   { valid(1), address(15) }
//////////////////////////////////////////////////////////////////////
`define DEPI_W                 16
`define DEPI_VALID             0
`define DEPI_ADDR_LB           1
`define DEPI_ADDR_UB           15

//////////////////////////////////////////////////////////////////////
// wb_latches_t (527 bits)
//
//   typedef struct {
//       bool valid;                                  // 1
//       wb_cs_t cs;                                  // 4
//       bool ST_XCL;                                 // 1
//       p_address_t ST_PADDR_0;                      // 15
//       uint16_t ST_BIT_VEC_0;                       // 16
//       p_address_t ST_PADDR_1;                      // 15
//       uint16_t ST_BIT_VEC_1;                       // 16
//       bool MIO;                                    // 1
//       uint32_t EIP;                                // 32
//       byte_t res_buf[CACHE_LINES_SIZE_B*2];        // 256
//       reg_ids_e sr_id;                             // 5
//       uint64_t  sr_data;                           // 64
//       reg_ids_e dr_id;                             // 5
//       uint64_t  dr_data;                           // 64
//       uint32_t EAX;                                // 32
//   } wb_latches_t;
//////////////////////////////////////////////////////////////////////
`define WBL_W                  527
`define WBL_VALID              0
`define WBL_CS_LB              1
`define WBL_CS_UB              4
`define WBL_CS_ST_OP           1
`define WBL_CS_WB_DR           2
`define WBL_CS_WB_SR           3
`define WBL_CS_WB_EAX          4
`define WBL_ST_XCL             5
`define WBL_PADDR0_LB          6
`define WBL_PADDR0_UB          20
`define WBL_VEC0_LB            21
`define WBL_VEC0_UB            36
`define WBL_PADDR1_LB          37
`define WBL_PADDR1_UB          51
`define WBL_VEC1_LB            52
`define WBL_VEC1_UB            67
`define WBL_MIO                68
`define WBL_EIP_LB             69
`define WBL_EIP_UB             100
`define WBL_RESBUF_LB          101
`define WBL_RESBUF_UB          356
`define WBL_SR_ID_LB           357
`define WBL_SR_ID_UB           361
`define WBL_SR_DATA_LB         362
`define WBL_SR_DATA_UB         425
`define WBL_DR_ID_LB           426
`define WBL_DR_ID_UB           430
`define WBL_DR_DATA_LB         431
`define WBL_DR_DATA_UB         494
`define WBL_EAX_LB             495
`define WBL_EAX_UB             526

//////////////////////////////////////////////////////////////////////
// wb_outputs_t (1095 bits)
//
//   typedef struct {
//       bool valid;                                          // 1
//       bool wb_stall;                                       // 1
//       st_q_2_dcache_t stq_heads[NUM_WB_ST_QS];             // 4*161=644
//       st_q_2_dcache_t mio_head;                            // 161
//       st_q_2_dep_check_outputs_t dep_check;                // 16*16=256
//       bool ST_OP;                                          // 1
//       bool ST_XCL;                                         // 1
//       p_address_t ST_PADDR_0;                              // 15
//       p_address_t ST_PADDR_1;                              // 15
//   } wb_outputs_t;
//
// `STQ_W`/`STQ_*` come from DCache_common_define.vh (st_q_2_dcache_t).
//////////////////////////////////////////////////////////////////////
`define WBO_W                  1095
`define WBO_VALID              0
`define WBO_WB_STALL           1
`define WBO_STQ_LB(i)          (2 + (i)*161)
`define WBO_STQ_UB(i)          (2 + (i)*161 + 160)
`define WBO_MIO_HEAD_LB        646
`define WBO_MIO_HEAD_UB        806
`define WBO_DEP_LB(i)          (807 + (i)*16)
`define WBO_DEP_UB(i)          (807 + (i)*16 + 15)
`define WBO_DEP_VALID(i)       (807 + (i)*16)
`define WBO_DEP_ADDR_LB(i)     (807 + (i)*16 + 1)
`define WBO_DEP_ADDR_UB(i)     (807 + (i)*16 + 15)
`define WBO_ST_OP              1063
`define WBO_ST_XCL             1064
`define WBO_PADDR0_LB          1065
`define WBO_PADDR0_UB          1079
`define WBO_PADDR1_LB          1080
`define WBO_PADDR1_UB          1094

//////////////////////////////////////////////////////////////////////
// WB depth / count parameters
//////////////////////////////////////////////////////////////////////
`define WB_NUM_ST_QS           4
`define WB_ST_Q_DEPTH          4
`define WB_ST_Q_PTR_W          2   // $clog2(ST_Q_DEPTH)
`define WB_ST_Q_CNT_W          3   // ptr_w + 1 extra wraparound bit

`endif
