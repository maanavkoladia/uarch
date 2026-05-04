`ifndef COMMONDEFINES_VH
`define COMMONDEFINES_VH

`define CACHE_LINES_SIZE_B (16)
`define CACHE_LINES_SIZE_BITS (`CACHE_LINES_SIZE_B * 8)
`define ADDRESS_BITS (32)
`define PAGE_SIZE (4096)
`define PHY_MEM_SIZE (1 << 15)
`define DATA_BUS_WIDTH_BITS (32)
`define ADDRESS_BUS_WIDTH_BITS (32)
`define NUM_WB_ST_QS (4)
`define ST_Q_DEPTH (4)
`define NUM_IDM_SLOTS (4)
`define NUM_SBS (22)

`define UINT8_T_WIDTH (8);
`define UINT16_T_WIDTH (16);
`define UINT32_T_WIDTH (32);
`define UINT64_T_WIDTH (64);
`define UINTCL_T_WIDTH (128);

`define BYTE_T_WIDTH (8);
`define BOOL_WIDTH (1);
`define P_ADDRESS_T_WIDTH (15);
`define V_ADDRESS_T_WIDTH (32);
`define L_ADDRESS_T_WIDTH (32);

`endif
