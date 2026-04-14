`ifndef TB_UTILS_DECODE_PATH
`define TB_UTILS_DECODE_PATH

//`ifndef DECODE_UNIT_PATH
//    `error "WB_UNIT_PATH not defined"
//`endif

`ifdef DECODE_UNIT_PATH
`define PRINT_DECODE \
    task automatic print_decode(); \
        $fdisplay(`LOG_FD, "[DECODE]"); \
        $fdisplay(`LOG_FD, "  valid=%0b  eip=0x%08h  invalid_instr=%0b  decode_gp=%0b  rr_latch_we=%0b", \
                  `DECODE_UNIT_PATH.decode_outputs.valid, `DECODE_UNIT_PATH.decode_outputs.eip, \
                  `DECODE_UNIT_PATH.decode_outputs.invalid_instruction, `DECODE_UNIT_PATH.decode_outputs.decode_gp, \
                  `DECODE_UNIT_PATH.decode_outputs.rr_stage_latch_we); \
    endtask
`endif




`endif
