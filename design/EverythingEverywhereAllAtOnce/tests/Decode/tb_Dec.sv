import common_pkg::*;
import core_common_pkg::*;
import core_stage_latches_pkg::*;

module tb_Dec();
    // Testbench signals
    reg clk;
    reg rst; // active low

    // Struct signals for Decode module
    reg [31:0] cs_limit;
    idm_outputs_t idm_outs_i;
    fetch_outputs_t fetch_outs_i;
    rr_outputs_t rr_outs_i;
    dc_outputs_t dc_outs_i;
    mem_outputs_t mem_outs_i;
    exe_outputs_t exe_outs_i;
    wb_outputs_t wb_outs_i;
    idm_slot_info_t idm_slot;
    rr_latches_t rr_latches_next;
    decode_outputs_t outs_o;




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
    assign cs_limit = 32'hFFFF_FFFF;

    //idm_slot init
    // assign idm_slot = '{
    //     valid           : 
    //     br_valid        :
    //     br_eip          :
    //     br_btb_target   :
    //     br_xcl          :
    //     data            :
    // };

    assign idm_slot = '{default: '0};

    //actual idm init
    assign idm_outs_i = '{
        idm_slots   : '{default: idm_slot},
        valid_slots : 3'd4
    };

    //think i can get away with leaving zero for now
    assign fetch_outs_i = '{default: '0};
    assign rr_outs_i = '{default: '0};
    assign dc_outs_i = '{default: '0};
    assign mem_outs_i = '{default: '0};
    assign exe_outs_i = '{default: '0};
    assign wb_outs_i = '{default: '0};
    // Example for custom struct population:
    // idm_outs_i = '{valid: 1, opcode: 8'hFF, ...};
    // fetch_outs_i = '{fieldA: valueA, ...};


    Decode decode_uut(
        .clk(clk),
        .rst(rst),
        .cs_limit(cs_limit),
        .idm_outs_i(idm_outs_i),
        .fetch_outs_i(fetch_outs_i),
        .rr_outs_i(rr_outs_i),
        .dc_outs_i(dc_outs_i),
        .mem_outs_i(mem_outs_i),
        .exe_outs_i(exe_outs_i),
        .wb_outs_i(wb_outs_i),
        .rr_latches_next(rr_latches_next),
        .outs_o(outs_o)
    );

    // Reset sequence
    initial begin
        rst = 0;   // assert reset (active low)
        #15;
        rst = 1;   // deassert reset

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
        forever #5 clk = ~clk; // 5ns high, 5ns low
    end
endmodule
