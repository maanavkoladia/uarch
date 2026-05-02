// Structural Verilog 2005 port of MIO_Block.
// Reference SV: rtl/DCache/structural/MIO_Block.sv
// No always blocks, no ternary operators, no logic/bitwise operators in logic.
// All logic via STDCell_Macros.vh gate instances.
// assign used only for wire aliasing or bit-replication ({N{x}}).

import common_pkg::*;
import interconnect_pkg::*;
import DCache_common_pkg::*;

module MIO_Block (
    input wire clk,
    input wire rst,  // active low

    // from DTE
    input wire reqServed_FromDTE_i,
    input wire PermissionToDriveAddrBus,
    input wire permission2DriveDataBus,

    // from core (scalar — already flat in SV)
    input wire        ld_addr_MIO_V,
    input wire [14:0] ld_addr_MIO,
    input wire        memStage_CLR_REQ_MIO,

    // flat expansion of st_q_2_dcache_t stq_info_mio
    // (only the fields actually consumed by MIO_Block logic)
    input wire        stq_info_mio_empty_i,
    input wire [14:0] stq_info_mio_addr_i,
    input wire [127:0] stq_info_mio_data_i,  // data[15..0] MSB-first: [127:120]=data[15], [7:0]=data[0]

    // buses
    inout wire [ADDRESS_BUS_WIDTH_BITS - 1 : 0] address_bus,
    inout wire [DATA_BUS_WIDTH_BITS    - 1 : 0] dataBus,

    // flat expansion of mio_block_outputs_t outputs_o
    output wire        writeSuccess_o,
    output wire        hit_o,
    output wire [127:0] dataLineOut_o,  // LSB-first: [7:0]=byte[0], [127:120]=byte[15]
    output wire [13:0]  req_2_sch_o,
    output wire        reqServed_o
);

    // ---------------------------------------------------------------
    // Registered state: block_req_mio_t block_req
    //   Fields: oe(1), we(1), p_addr(15), st_q_data[16]=128-bit flat
    // ---------------------------------------------------------------
    wire        block_req_oe_q;
    wire        block_req_we_q;
    wire [14:0] block_req_paddr_q;
    wire [127:0] block_req_data_q;

    // ---------------------------------------------------------------
    // Prerequisite inverters
    // INV_N signature: (name, width, IN, OUT)
    // ---------------------------------------------------------------
    wire not_we_q, not_oe_q, not_stq_empty, not_ld_V;
    `INV_N(u_not_we,    1, block_req_we_q,       not_we_q)
    `INV_N(u_not_oe,    1, block_req_oe_q,        not_oe_q)
    `INV_N(u_not_empty, 1, stq_info_mio_empty_i,  not_stq_empty)
    `INV_N(u_not_ld_V,  1, ld_addr_MIO_V,         not_ld_V)

    // ---------------------------------------------------------------
    // block_idle = NOR(we, oe)
    // SV: assign block_idle = !block_req.oe && !block_req.we
    // ---------------------------------------------------------------
    wire block_idle;
    `NOR_2(u_block_idle, 1, block_idle, block_req_we_q, block_req_oe_q)

    // ---------------------------------------------------------------
    // readyForNewReq
    // SV: (block_req.we && reqServed_FromDTE_i)
    //   || (memStage_CLR_REQ_MIO && block_req.oe)
    //   || block_idle
    // ---------------------------------------------------------------
    wire we_and_served, clr_and_oe, readyForNewReq;
    `AND_2(u_we_and_served, 1, we_and_served, block_req_we_q,       reqServed_FromDTE_i)
    `AND_2(u_clr_and_oe,    1, clr_and_oe,    memStage_CLR_REQ_MIO, block_req_oe_q)
    `OR_3(u_rfnr,           1, readyForNewReq, we_and_served, clr_and_oe, block_idle)

    // keep_select = ~readyForNewReq: hold current block_req when not ready
    wire keep_select;
    `INV_N(u_keep_sel, 1, readyForNewReq, keep_select)

    // ---------------------------------------------------------------
    // Mutually exclusive case selects
    // SV: if (readyForNewReq) {
    //       if (ld_addr_MIO_V)      -> ld_select
    //       else if (!stq.empty)    -> st_select
    //       else                    -> idle (all gated ORs produce 0 naturally)
    //     }
    // ---------------------------------------------------------------
    wire ld_select, st_select;
    `AND_2(u_ld_sel, 1, ld_select, readyForNewReq, ld_addr_MIO_V)
    `AND_3(u_st_sel, 1, st_select, readyForNewReq, not_ld_V, not_stq_empty)

    // ---------------------------------------------------------------
    // Replication enables (assign only — bit-replication, no logic)
    // ---------------------------------------------------------------
    wire [14:0]  ld_sel_15, st_sel_15, keep_sel_15;
    wire [127:0] st_sel_128, keep_sel_128;
    assign ld_sel_15    = {15{ld_select}};
    assign st_sel_15    = {15{st_select}};
    assign keep_sel_15  = {15{keep_select}};
    assign st_sel_128   = {128{st_select}};
    assign keep_sel_128 = {128{keep_select}};

    // ---------------------------------------------------------------
    // next_block_req.oe
    // SV: ld_case -> oe=1, we=0; st_case -> oe=0, we=1; idle -> oe=0, we=0; keep -> as-is
    // ---------------------------------------------------------------
    wire oe_keep_gated, next_oe;
    `AND_2(u_oe_keep, 1, oe_keep_gated, keep_select, block_req_oe_q)
    `OR_2(u_next_oe,  1, next_oe,       ld_select,   oe_keep_gated)

    // ---------------------------------------------------------------
    // next_block_req.we
    // ---------------------------------------------------------------
    wire we_keep_gated, next_we;
    `AND_2(u_we_keep, 1, we_keep_gated, keep_select, block_req_we_q)
    `OR_2(u_next_we,  1, next_we,       st_select,   we_keep_gated)

    // ---------------------------------------------------------------
    // next_block_req.p_addr (15-bit, 3-way gated OR)
    // SV: ld->ld_addr_MIO, st->stq.address, idle->0 (no term), keep->as-is
    // ---------------------------------------------------------------
    wire [14:0] paddr_ld_g, paddr_st_g, paddr_keep_g, next_paddr;
    `AND_2(u_pa_ld,   15, paddr_ld_g,   ld_addr_MIO,         ld_sel_15)
    `AND_2(u_pa_st,   15, paddr_st_g,   stq_info_mio_addr_i, st_sel_15)
    `AND_2(u_pa_keep, 15, paddr_keep_g, block_req_paddr_q,   keep_sel_15)
    `OR_3(u_next_pa,  15, next_paddr,   paddr_ld_g, paddr_st_g, paddr_keep_g)

    // ---------------------------------------------------------------
    // next_block_req.data (128-bit, 2-way gated OR)
    // SV: st->stq.data; ld/idle->'{default:'0} (no term needed); keep->as-is
    // ---------------------------------------------------------------
    wire [127:0] data_st_g, data_keep_g, next_data;
    `AND_2(u_dat_st,   128, data_st_g,   stq_info_mio_data_i, st_sel_128)
    `AND_2(u_dat_keep, 128, data_keep_g, block_req_data_q,    keep_sel_128)
    `OR_2(u_next_dat,  128, next_data,   data_st_g, data_keep_g)

    // ---------------------------------------------------------------
    // Registers (REG_RST: always-enabled write, active-low async reset)
    // ---------------------------------------------------------------
    `REG_RST(u_reg_oe,  1,   clk, rst, next_oe,    block_req_oe_q)
    `REG_RST(u_reg_we,  1,   clk, rst, next_we,    block_req_we_q)
    `REG_RST(u_reg_pa,  15,  clk, rst, next_paddr, block_req_paddr_q)
    `REG_RST(u_reg_dat, 128, clk, rst, next_data,  block_req_data_q)

    // ---------------------------------------------------------------
    // Combinational outputs — derived from registered state only (no loop)
    // ---------------------------------------------------------------

    // SV: outputs_o.writeSuccess = 1 in st_case (store dispatched this cycle)
    assign writeSuccess_o = st_select;

    // SV: outputs_o.reqServed = 1 in ld_case (load dispatched this cycle)
    assign reqServed_o = ld_select;

    // SV: outputs_o.hit_o = reqServed_FromDTE_i && block_req.oe
    `AND_2(u_hit_o, 1, hit_o, reqServed_FromDTE_i, block_req_oe_q)

    // SV: outputs_o.dataLineOut[0..3] = dataBus[i*8+:8]; rest = '{default:'0}
    // Flat 128-bit, LSB-first encoding: byte[0]=[7:0], byte[15]=[127:120]
    // bytes 0-3 come from dataBus[31:0]; bytes 4-15 remain 0
    assign dataLineOut_o = {96'b0, dataBus[31:0]};

    // ---------------------------------------------------------------
    // req_2_sch_o (14-bit encoded, read from registered state only)
    // SV case({block_req.we, block_req.oe}):
    //   2'b00 -> NO_REQ              = 0  = 14'b00000000000000
    //   2'b01 -> LD_FROM_SIMPLE      = 5  = 14'b00000000000101
    //   2'b10 -> WR_SIMPLE (bit6=1)  = 3  = 14'b00000000000011
    //   2'b10 -> WR_COMPLEX (bit6=0) = 4  = 14'b00000000000100
    // Per-bit: bit0=ld|wr_simple, bit1=wr_simple, bit2=ld|wr_complex, bits13:3=0
    // ---------------------------------------------------------------

    // ld_req_sel: case 2'b01 (oe=1, we=0) — reads registered state, no loop
    wire ld_req_sel, st_req_sel;
    `AND_2(u_ld_req_sel, 1, ld_req_sel, not_we_q,       block_req_oe_q)
    `AND_2(u_st_req_sel, 1, st_req_sel, block_req_we_q, not_oe_q)

    // WE_ADDR_MASK = 15'h0040 = bit 6 only
    wire addr_bit6;
    assign addr_bit6 = block_req_paddr_q[6];
    wire not_addr6;
    `INV_N(u_not_addr6, 1, addr_bit6, not_addr6)

    wire wr_simple_sel, wr_complex_sel;
    `AND_2(u_wr_simple,  1, wr_simple_sel,  st_req_sel, addr_bit6)
    `AND_2(u_wr_complex, 1, wr_complex_sel, st_req_sel, not_addr6)

    wire req_sch_bit0, req_sch_bit2;
    `OR_2(u_bit0, 1, req_sch_bit0, ld_req_sel, wr_simple_sel)
    `OR_2(u_bit2, 1, req_sch_bit2, ld_req_sel, wr_complex_sel)
    // {13'b0, bit2, bit1=wr_simple_sel, bit0}
    assign req_2_sch_o = {11'b0, req_sch_bit2, wr_simple_sel, req_sch_bit0};

    // ---------------------------------------------------------------
    // Tri-state buses
    // ---------------------------------------------------------------

    // Address bus: SV: assign address_bus = PermissionToDriveAddrBus ? block_req.p_addr : 'z
    wire addr_perm_bar;
    `INV_N(u_addr_perm_bar, 1, PermissionToDriveAddrBus, addr_perm_bar)
    wire [ADDRESS_BUS_WIDTH_BITS-1:0] addr_bus_drv;
    assign addr_bus_drv = {17'b0, block_req_paddr_q};   // zero-extend 15→32
    `BUS_TRISTATE(u_addr_bus, ADDRESS_BUS_WIDTH_BITS, addr_perm_bar, addr_bus_drv, address_bus)

    // Data bus: SV: dataBus_drv = {data[3],data[2],data[1],data[0]}
    // MSB-first flat encoding: data[0]=[7:0], so {data[3],data[2],data[1],data[0]} = [31:0]
    wire data_perm_bar;
    `INV_N(u_data_perm_bar, 1, permission2DriveDataBus, data_perm_bar)
    wire [DATA_BUS_WIDTH_BITS-1:0] dataBus_drv;
    assign dataBus_drv = block_req_data_q[31:0];
    `BUS_TRISTATE(u_mio_block_busTristate, DATA_BUS_WIDTH_BITS, data_perm_bar, dataBus_drv, dataBus)

endmodule
