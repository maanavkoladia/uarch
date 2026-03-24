import common_pkg::*;
import interconnect_pkg::*;
import tb_dcache_pkg::*;
module tb_dcache ();

    `CLK_INIT(CLK_PERIOD)
    //`GEN_WAVEFORM_VCD("wave.vcd", tb_memBanks, 10);
    //`GEN_WAVEFORM_VPD("wave.vpd", tb_memBanks, 10);

    logic rst;
    wire [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus;
    wire [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addrBus;

    //to give the memmodule and addr
    p_address_t addrForBus;
    bool driveAddrBus;

    logic [31 : 0] dataForBus;
    bool driveDataBus;

    core_2_dcache_t inFromCore;
    dcache_2_core_t out2Core;
    dte_2_dcache_t inFromDTE;
    dcache_2_scheduler_t out2Sch;

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    assign dataBus = driveDataBus ? dataForBus : 'z;
    assign addrBus = driveAddrBus ? addrForBus : 'z;

    DCache_TOP uut0 (
        .clk(clk),
        .rst(rst),
        .inFromCore_i(inFromCore),
        .out2Core_o(out2Core),
        .inFromDTE_i(inFromDTE),
        .out2Sch_o(out2Sch),
        .dataBus(dataBus),
        .address_bus(addrBus)
    );

    initial begin
        `LOG("DCache Tb Starting up");
        rst = 0;  //actve low
        inFromCore = '{default: '0};
        inFromDTE = '{default: '0};
        driveAddrBus = 0;
        driveDataBus = 0;
        addrForBus = 0;
        dataForBus = 0;

        DelayCLKs(5);
        rst = 1;  //actve low


        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        DelayCLKs(30);
        `LOG("DCache  Tb Complete");
        $finish;
    end
endmodule
