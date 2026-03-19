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
        `DELAY_CYCLES(3);
        //$readmemh("fakeData/mem0.hex", tb_memBanks.uut0.g_sram_cells[0].mem_cell.mem);
        //$readmemh("fakeData/mem1.hex", tb_memBanks.uut0.g_sram_cells[1].mem_cell.mem);
        //$readmemh("fakeData/mem2.hex", tb_memBanks.uut0.g_sram_cells[2].mem_cell.mem);
        //$readmemh("fakeData/mem3.hex", tb_memBanks.uut0.g_sram_cells[3].mem_cell.mem);
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
