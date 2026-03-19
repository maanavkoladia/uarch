import common_pkg::*;
import interconnect_pkg::*;
import mem_common_pkg::*;
/*
typedef struct {
    bool ld_req;
    bool st_req;
    bool start_transaction;
    bool permission2DriveBus[MEM_BUS_SIZE/DATA_BUS_WIDTH_BITS];
} dte_2_mem_t;

typedef struct {
    logic writeBuf_V[numWriteBufsInMem];
} mem_2_scheduler_t;

typedef struct {
    bool mem_Ready;
} mem_2_dte_t;

*/


`define CYCLE_TIME (10)
`define DELAY_CYCLES(cycles) #(`CYCLE_TIME * cycles)

module tb_mainMem ();

    `CLK_INIT(`CYCLE_TIME)
    //`GEN_WAVEFORM_VCD("wave.vcd", tb_memBanks, 10);
    //`GEN_WAVEFORM_VPD("wave.vpd", tb_memBanks, 10);

    logic rst;
    wire [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus;
    wire [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addrBus;
    dte_2_mem_t fromDte;
    mem_2_dte_t mem2dte;
    mem_2_scheduler_t mem2Sch;

    //gate the bus
    assign dataBus = 'z;
    assign addrBus = 'z;


    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    mem_TOP uut0 (
        .clk(clk),
        .rst(rst),
        .address_bus(addrBus),
        .data_bus(dataBus),
        .inFromDte(fromDte),
        .out2Dte(mem2dte),
        .out2Sch(mem2Sch)
    );

    initial begin
        string fileName;
        `DELAY_CYCLES(3);
        //for (int i = 0; i < NUM_BANKS; i++) begin
        //    for (int j = 0; j < 4; j++) begin
        //        fileName = $sformatf("./memGen/hexLoad/mem_%d_%d.hex", i, j);
        //        `LOG("Wrote in : %s", fileName);
        //        $readmemh(fileName,
        //                  tb_mainMem.uut0.g_mem_banks[i].mem_bank.g_sram_cells[j].mem_cell.mem);
        //    end
        //end
        $readmemh("./memGen/hexLoad/mem_0_0.hex",
                  tb_mainMem.uut0.g_mem_banks[0].mem_bank.g_sram_cells[0].mem_cell.mem);
        `LOG("Mem Read in");
    end

    initial begin
        `LOG("Main Mem Tb Starting up");
        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        `DELAY_CYCLES(30);
        `LOG("Mem Bank Tb Complete");
        $finish;
    end
endmodule
