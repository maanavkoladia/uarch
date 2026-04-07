import common_pkg::*;
import interconnect_pkg::*;
import core_common_pkg::*;
import core_stage_latches_pkg::*;

module EveryThing_TOP (
    input wire clk,
    input wire rst,

    //icache 2 core
    input  icache_2_core_t ICacheIn_i,
    output core_2_icache_t out2ICache_o,
    //core2 icache
    //
    //core 2 dcache
    input  dcache_2_core_t DCacheIn_i,

    //dcache 2 core these need to be assinged from dc outs and wb outs
    output core_2_dcache_t out2DCache_o,

    input dma_controller_2_core_t inFromDMA_i

);
    idm_outputs_t idm_outputs;
    fetch_outputs_t fetch_outputs;
    decode_outputs_t decode_outputs;
    rr_outputs_t rr_outputs;
    dc_outputs_t dc_outputs;
    mem_outputs_t mem_outputs;
    exe_outputs_t exe_outputs;
    wb_outputs_t wb_outputs;

    rr_latches_t rr_latches, rr_latches_next;
    dc_latches_t dc_latches, dc_latches_next;
    mem_latches_t mem_latches, mem_latches_next;
    exe_latches_t exe_latches, exe_latches_next;
    wb_latches_t wb_latches, wb_latches_next;

    //assign icache out and dache out
    assign out2ICache_o = fetch_outputs.fetch_2_icache;

    //dealing with dc to dcache
    assign out2DCache_o = '{
            ld_addr_0_V : dc_outputs.ld_addr_0_V,
            ld_addr_0 : dc_outputs.ld_addr_0,
            ld_addr_1_V : dc_outputs.ld_addr_1_V,
            ld_addr_1 : dc_outputs.ld_addr_1,
            ld_addr_MIO_V : dc_outputs.ld_addr_MIO_V,
            ld_addr_MIO : dc_outputs.ld_addr_MIO,
            memStalling : mem_outputs.stall,
            stq_heads : wb_outputs.stq_heads,
            stq_info_mio : wb_outputs.mio_head
        };
    
    always_comb begin
        wb_outputs = '{default: '0};
        for(int i=0; i < 4; i++) begin
            wb_outputs.stq_heads[i].empty = 1;
        end
        wb_outputs.mio_head.empty = 1;
        
    end

    Fetch fetch_unit (
        .clk(clk),
        .rst(rst),
        .icache_info_i(ICacheIn_i),
        .idm_info_i(idm_outputs),
        .decode_outs_i(decode_outputs),
        .rr_outs_i(rr_outputs),
        .dc_outs_i(dc_outputs),
        .mem_outs_i(mem_outputs),
        .exe_outs_i(exe_outputs),
        .dma_int(inFromDMA_i.intOut),
        .wb_outs_i(wb_outputs),
        .outs_o(fetch_outputs)
    );

    IDM idm_unit (
        .clk(clk),
        .rst(rst),
        .fetch_outs_i(fetch_outputs),
        .idm_outs_o(idm_outputs)
    );

    Decode decode_unit (
        .clk(clk),
        .rst(rst),  
        .idm_outs_i(idm_outputs),
        .fetch_outs_i(fetch_outputs),
        .rr_outs_i(rr_outputs),
        .dc_outs_i(dc_outputs),
        .mem_outs_i(mem_outputs),
        .exe_outs_i(exe_outputs),
        .wb_outs_i(wb_outputs),
        .rr_latches_next(rr_latches_next),
        .outs_o(decode_outputs)
    );

    RR_Latches rr_latches_unit (
        .clk(clk),
        .rst(rst),
        .nextLatches_i(rr_latches_next),
        .latches_o(rr_latches),
        .write_enable_i(decode_outputs.rr_stage_latch_we),
        .flush(exe_outputs.br_res_out.flush),
        .farFlush(exe_outputs.br_res_out.farFlush)
    );

    RR rr_unit (
        .clk(clk),
        .rst(rst),
        .latches_i(rr_latches),
        .fetch_outs_i(fetch_outputs),
        .decode_outs_i(decode_outputs),
        .dc_outs_i(dc_outputs),
        .mem_outs_i(mem_outputs),
        .exe_outs_i(exe_outputs),
        .wb_outs_i(wb_outputs),
        .dc_latches_next(dc_latches_next),
        .outs_o(rr_outputs)
    );

    DC_Latches dc_latches_unit (
        .clk(clk),
        .rst(rst),
        .nextLatches_i(dc_latches_next),
        .latches_o(dc_latches),
        .write_enable_i(rr_outputs.dc_stage_latch_we),
        .flush(exe_outputs.br_res_out.flush),
        .farFlush(exe_outputs.br_res_out.farFlush)
    );

    DC dc_unit (
        .clk(clk),
        .rst(rst),
        .latches_i(dc_latches),
        .mem_outs_i(mem_outputs),
        .exe_outs_i(exe_outputs),
        .wb_outs_i(wb_outputs),
        .mem_latches_next_o(mem_latches_next),
        .req_rejected_mio(DCacheIn_i.req_rejected_mio),
        .req_rejected_0(DCacheIn_i.req_rejected_0),
        .req_rejected_1(DCacheIn_i.req_rejected_1),
        .dc_outs_o(dc_outputs)
    );

    MEM_Latches mem_latches_unit (
        .clk(clk),
        .rst(rst),
        .nextLatches_i(mem_latches_next),
        .write_enable_i(dc_outputs.mem_stage_latch_we),
        .flush(exe_outputs.br_res_out.flush),
        .farFlush(exe_outputs.br_res_out.farFlush),
        .latches_o(mem_latches)
    );


    MEM mem_unit (
        .clk(clk),
        .rst(rst),

        .latches_i (mem_latches),
        .exe_outs_i(exe_outputs),
        .wb_outs_i (wb_outputs),

        .hit_line_0(DCacheIn_i.hit_line_0),  //this onyl goes high if valid
        .line_0(DCacheIn_i.line_0),
        .hit_line_1(DCacheIn_i.hit_line_1),
        .line_1(DCacheIn_i.line_1),
        .exe_latches_next_o(exe_latches_next),
        .hit_line_MMIO(DCacheIn_i.hit_line_MIO),
        .line_MMIO(DCacheIn_i.line_MIO),
        .outs_o(mem_outputs)
    );


    EXE_Latches exe_latches_unit (
        .clk(clk),
        .rst(rst),
        .nextLatches_i(exe_latches_next),
        .write_enable_i(mem_outputs.exe_stage_latch_we),
        .flush(exe_outputs.br_res_out.flush),
        .farFlush(exe_outputs.br_res_out.farFlush),
        .latches_o(exe_latches)
    );


    EXE execute_unit (
        .clk(clk),
        .rst(rst),
        .latches_i(exe_latches),
        .wb_outs_i(wb_outputs),
        .wb_latches_next_o(wb_latches_next),
        .outs_o(exe_outputs)
    );

    WB_Latches wb_latches_unit (
        .clk(clk),
        .rst(rst),
        .nextLatches_i(wb_latches_next),
        .write_enable_i(exe_outputs.wb_stage_latch_we),
        .latches_o(wb_latches)
    );

    // WB write_back_unit (
    //     .clk(clk),
    //     .rst(rst),
    //     .wb_latches(wb_latches),
    //     .write_success(DCacheIn_i.writeSuccess),
    //     .write_success_mio(DCacheIn_i.writeSuccess_MIO),
    //     .outputs(wb_outputs)
    // );



endmodule
