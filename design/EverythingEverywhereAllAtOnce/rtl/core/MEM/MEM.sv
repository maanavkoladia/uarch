import core_common_pkg::*;
import core_stage_latches_pkg::*;
import common_pkg::*;

module MEM (
    input wire clk,
    input wire rst,


    input mem_latches_t latches_i,

    //these are for valid bit shit and flushing
    input exe_outputs_t exe_outs_i,

    //only used for valid logic
    input wb_outputs_t wb_outs_i,

    //not sure if valid are needed, leaving for now
    //if not XCL, then wait for line_0 to hit, if XCL, wait for both line_0
    //and line_1
    input bool hit_line_0,  //this onyl goes high if valid
    input byte_t line_0[CACHE_LINES_SIZE_B],

    input bool hit_line_1,
    input byte_t line_1[CACHE_LINES_SIZE_B],

    input bool hit_line_MMIO,
    input byte_t line_MMIO[CACHE_LINES_SIZE_B],

    output exe_latches_t exe_latches_next_o,
    output mem_outputs_t outs_o
);

    byte_t C0[CACHE_LINES_SIZE_B];
    byte_t up_buf[CACHE_LINES_SIZE_B];
    byte_t low_buf[CACHE_LINES_SIZE_B];
    bool miss_stall;

    always_comb begin
        C0 = latches_i.MIO ? line_MMIO : line_0; //mux
        up_buf = latches_i.swapLines ? C0 : line_1;
        low_buf = latches_i.swapLines ? line_1 : C0;
    end

    mem_miss_stall_logic mem_stall(
        .valid(latches_i.valid),
        .LD_XCL(latches_i.LD_XCL),
        .LD_MEM_OP(latches_i.cs.LD_OP),
        .hit0(hit_line_0),
        .hit1(hit_line_1),
        .hit_MIO(hit_line_MMIO),
        .MIO(latches_i.MIO),
        .miss_stall(miss_stall)
    );

    assign exe_latches_next_o = '{
        valid: latches_i.valid,  //TODO need to actually create logic here (handle stall/flush)
        cs: latches_i.exe_cs,
        wb_cs: latches_i.wb_cs,
        ST_XCL: latches_i.ST_XCL,
        ST_PADDR_0: latches_i.ST_PADDR_0,
        ST_PADDR_1: latches_i.ST_PADDR_1,
        MIO: latches_i.MIO,
        br_info: latches_i.br_info,
        NEIP: latches_i.NEIP,
        imm64: latches_i.imm64,
        ld_buf: {up_buf, low_buf},
        sr_id: latches_i.sr_id,
        sr_data: latches_i.sr_data,
        dr_id: latches_i.dr_id,
        dr_data: latches_i.dr_data,
        ld_addy: latches_i.LD_PADDR_0
    };

    assign outs_o = '{
        valid: latches_i.valid,
        stall: miss_stall 
    };



endmodule
