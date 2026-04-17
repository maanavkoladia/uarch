`ifndef TB_UTILS_DCACHEPATH
`define TB_UTILS_DCACHEPATH

`ifndef DCACHE_UNIT_PATH
    `error "DCACHE_UNIT_PATH not defined"
`endif


// --- DCACHE ARBITRATION ---
`ifdef CORE_DUT_PATH
`ifdef DCACHE_DUT_PATH
`define PRINT_DCACHE_ARB \
    task automatic print_dcache_arb(); \
        $fdisplay(`LOG_FD, "[DCACHE ARB]"); \
        $fdisplay(`LOG_FD, "  req_served_0=%0b  req_served_1=%0b  req_served_mio=%0b", \
                  dcache_2_core.reqServed_0, dcache_2_core.reqServed_1, \
                  dcache_2_core.reqServed_MIO); \
        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) begin \
            $fdisplay(`LOG_FD, "  blk[%0d]: oe=%0b  we=%0b  addr=0x%04h  hit=%0b  ws=%0b  sch_req=%0d", i, \
                      `DCACHE_DUT_PATH.req_2_blocks[i].oe, `DCACHE_DUT_PATH.req_2_blocks[i].we, \
                      `DCACHE_DUT_PATH.req_2_blocks[i].p_addr, `DCACHE_DUT_PATH.hitVec[i], \
                      dcache_2_core.writeSuccess[i], `DCACHE_DUT_PATH.out2Sch_o.req[i]); \
        end \
    endtask
`endif
`endif

`endif
