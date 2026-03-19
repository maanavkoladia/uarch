import tb_mainMem_pkg::*;

module tb_memGen_InitRitual();
    initial begin
        DelayCLKs(<startupDelay here>);
        $readmemh("memGen/", tb_mainMem.uut0.g_mem_banks[0].mem_bank.g_sram_cells[0].mem_cell.mem)
        //the rest of them
    end
endmodule
