import common_pkg::*;
import core_common_pkg::*;
import core_stage_latches_pkg::*;

module tb_Dec();
    // Testbench signals
    reg clk;
    reg rst; // active low

    // Struct signals for Decode module
    idm_outputs_t idm_info_i;
    fetch_outputs_t fetch_outs_o;
    rr_outputs_t rr_outs_i;
    dc_outputs_t dc_outs_i;
    mem_outputs_t mem_outs_i;
    exe_outputs_t exe_outs_i;
    wb_outputs_t wb_outs_i;
    idm_slot_info_t idm_slot_actual, idm_slot_empty;
    rr_latches_t rr_latches_next, rr_latches;
    dc_latches_t dc_latches_next, dc_latches;
    decode_outputs_t decode_outs_i;

    // Example assign template for struct population:
    // assign idm_outs_i = '{ valid: 0, opcode: 0, ... };
    // assign fetch_outs_i = '{ fieldA: 0, ... };
    // assign rr_outs_i = '{ ... };
    // assign dc_outs_i = '{ ... };
    // assign mem_outs_i = '{ ... };
    // assign exe_outs_i = '{ ... };
    // assign wb_outs_i = '{ ... };
    // You can copy and edit these lines to populate the structs as needed.

    // Framework for struct population (edit these as needed)
    // Example: assign idm_outs_i = '{ field1: value1, field2: value2, ... };
    // Populate these assignments with your desired values

    //idm_slot init
    // assign idm_slot = '{
    //     valid           : 
    //     br_valid        :
    //     br_eip          :
    //     br_btb_target   :
    //     br_xcl          :
    //     data            :
    // };

    //assign idm_slot = '{default: '0};

    //actual idm init
    // assign idm_outs_i = '{
    //     idm_slots   : '{default: idm_slot},
    //     valid_slots : 3'd4
    // };

    //think i can get away with leaving zero for now
    idm_slot_req_t actual_test, empty;
    assign actual_test = '{
        ld_meta_data:       1'b0,
        ld_data:            1'b1,
        valid:              1'b1,
        br_valid:           1'b0,
        br_eip:             32'h0000_0000,
        br_target:          32'h0000_0000,
        br_xcl:             1'b0,
        data:   '{8'h00, 8'hFB, 8'h01, 8'h00,
                8'h00, 8'h56, 8'h78, 8'h57,
                8'hB4, 8'h01, 8'hD9, 8'h01,
                8'hDE, 8'hAD, 8'h05, 8'h66}
    };
    // 66 05 AD DE          ; ADD AX, 0xDEAD
    // 01 D9                ; ADD ECX, EBX
    // 01 B4 57 78 56 00 00 ; ADD [EDX*2 + EDI + 0x00005678], ESI

    assign empty = '{default : '0};


    fetch_idm_ctrl_2_idm_t idm_reqs_o;
    assign idm_reqs_o = '{
        req     : {empty, empty, empty, actual_test}
    };


    assign fetch_outs_o = '{
        idm_reqs    : idm_reqs_o,
        default     : '0
    };

    // assign dc_outs_i = '{default: '0};
    // assign mem_outs_i = '{default: '0};
    // assign exe_outs_i = '{default: '0};
    // assign wb_outs_i = '{default: '0};
    // Example for custom struct population:
    // idm_outs_i = '{valid: 1, opcode: 8'hFF, ...};
    // fetch_outs_i = '{fieldA: valueA, ...};

    // IDM idm_uut1(
    //     .clk(clk),
    //     .rst(rst),
    //     .fetch_outs_i(fetch_outs_o),
    //     .idm_outs_o(idm_outs_i)
    // );

    // 66 05 AD DE          ; ADD AX, 0xDEAD
    // 01 D9                ; ADD ECX, EBX
    // 01 B4 57 78 56 34 12 ; ADD [EDX*2 + EDI + 0x12345678], ESI
    // 01 FB                ; ADD EBX, EDI

    assign idm_slot_actual = '{
        valid       : 1'b1,
        br_valid    : 1'b0,
        br_eip      : 32'h0000_FFFF,
        br_btb_target   : 32'h0000_FFFF,  //this is the btbs predicted target, 
        br_xcl      : 1'b0,
        data        : '{8'h66, 8'h05, 8'hAD, 8'hDE,
                8'h01, 8'hD9, 8'h01, 8'hB4,
                8'h57, 8'h78, 8'h56, 8'h00,
                8'h00, 8'h01, 8'hFB, 8'h00}
    };

    assign idm_slot_empty = '{default : '0};

    assign idm_info_i = '{
        idm_slots : {idm_slot_actual, idm_slot_empty, idm_slot_empty, idm_slot_empty},
        valid_slots : 2'b01
    };

    Decode decode_uut(
        .clk(clk),
        .rst(rst),
        .idm_outs_i(idm_info_i),
        .fetch_outs_i(fetch_outs_o),
        .rr_outs_i(rr_outs_i),
        .dc_outs_i(dc_outs_i),
        .mem_outs_i(mem_outs_i),
        .exe_outs_i(exe_outs_i),
        .wb_outs_i(wb_outs_i),
        .rr_latches_next(rr_latches_next),
        .outs_o(decode_outs_i)
    );

    RR_Latches rr_latches_unit (
        .clk(clk),
        .rst(rst),
        .write_enable_i(decode_outs_i.rr_stage_latch_we),
        .flush(exe_outs_i.br_res_out.flush),
        .farFlush(exe_outs_i.br_res_out.farFlush),
        .nextLatches_i(rr_latches_next),
        .latches_o(rr_latches)
    );

    RR rr_uut(
        .clk(clk),
        .rst(rst),
        .latches_i(rr_latches),
        .fetch_outs_i(fetch_outs_o),
        .decode_outs_i(decode_outs_i),
        .dc_outs_i(dc_outs_i),
        .mem_outs_i(mem_outs_i),
        .exe_outs_i(exe_outs_i),
        .wb_outs_i(wb_outs_i),
        .dc_latches_next(dc_latches_next),
        .outs_o(rr_outs_i)
    );

    DC_Latches dc_latches_unit (
        .clk(clk),
        .rst(rst),
        .write_enable_i(rr_outs_i.dc_stage_latch_we),
        .flush(exe_outs_i.br_res_out.flush),
        .farFlush(exe_outs_i.br_res_out.farFlush),
        .nextLatches_i(dc_latches_next),
        .latches_o(dc_latches)
    );

    DC dc_unit (
        .clk(clk),
        .rst(rst),
        .latches_i(dc_latches),
        .mem_outs_i(mem_outs_i),
        .exe_outs_i(exe_outs_i),
        .wb_outs_i(wb_outs_i),
        .mem_latches_next_o(mem_latches_next),
        .req_rejected_mio(DCacheIn_i.req_rejected_mio),
        .req_rejected_0(DCacheIn_i.req_rejected_0),
        .req_rejected_1(DCacheIn_i.req_rejected_1),
        .dc_outs_o(dc_outs_i)
    );

    MEM_Latches mem_latches_unit (
        .clk(clk),
        .rst(rst),
        .nextLatches_i(mem_latches_next),
        .write_enable_i(dc_outs_i.mem_stage_latch_we),
        .flush(exe_outs_i.br_res_out.flush),
        .farFlush(exe_outs_i.br_res_out.farFlush),
        .latches_o(mem_latches)
    );

    // assign rr_outs_i = '{default: '0};
    //decode worked fine when I had this above line uncommented
    //need to check how the rr_outs_i is being set or initialized
    assign dc_outs_i = '{default: '0};
    assign mem_outs_i = '{default: '0};
    assign exe_outs_i = '{default: '0};
    assign wb_outs_i = '{default: '0};

    // Reset sequence
    initial begin
        rst = 0;   // assert reset (active low)
        #5;
        set_limit_regs();
        #10;
        force decode_uut.EIP = 32'h1000;
        rst = 1;   // deassert reset
        release decode_uut.EIP;

        #900;
        $finish;
    end

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end    
    // Clock generation (10ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 5ns high, 5ns low
    end

    //task to set limit regs
    task automatic set_limit_regs();
            rr_uut.SEGMENT_LIMITS[CS_LIMIT_ID] = 32'hFFFF_FFFF;
            rr_uut.SEGMENT_LIMITS[DS_LIMIT_ID] = 32'hFFFF_FFFF;
            rr_uut.SEGMENT_LIMITS[SS_LIMIT_ID] = 32'hFFFF_FFFF;
            rr_uut.SEGMENT_LIMITS[ES_LIMIT_ID] = 32'hFFFF_FFFF;
            rr_uut.SEGMENT_LIMITS[FS_LIMIT_ID] = 32'hFFFF_FFFF;
            rr_uut.SEGMENT_LIMITS[GS_LIMIT_ID] = 32'hFFFF_FFFF;
    endtask
endmodule
