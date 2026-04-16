import interconnect_pkg::*;

`define CLK_PERIOD (8)

module tb_fasterTransfers ();

    //localparam int Clk_PERIOD = 8;
    `include "debugUtils/tb_utils_defs.svh"

    //task automatic DelayClks(input int cycles);
    //    #(Clk_PERIOD * cycles);
    //endtaskA

    core_2_icache_t core_2_icache;
    icache_2_core_t icache_2_core;
    core_2_dcache_t core_2_dcache;
    dcache_2_core_t dcache_2_core;
    dma_controller_2_core_t dma_2_core;

    `DEBUG_UTILS_INIT;
    

    logic rst;

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    Everywhere_TOP Everywhere_TOP (
        .clk(clk),
        .rst(rst),
        .core2icache_i(core_2_icache),
        .icache2core_o(icache_2_core),
        .core2dcache_i(core_2_dcache),
        .dcache2core_o(dcache_2_core),
        .dma2core_o(dma_2_core)
    );

    initial begin
        `LOG("Starting TB");
        rst = 0;
        core_2_icache = '{default: '0};
        core_2_dcache = '{default: '0};

        for(int i = 0; i < NUM_DCACHE_PORTS; i++) begin
            core_2_dcache.stq_heads[i].empty = 1;
        end
        core_2_dcache.stq_info_mio.empty = 1;

        rst = 1;




        DelayClks(20);
        `LOG("Tb Done");
        $finish;
    end

endmodule

