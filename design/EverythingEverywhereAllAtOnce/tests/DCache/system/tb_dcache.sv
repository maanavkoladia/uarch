import common_pkg::*;
import interconnect_pkg::*;

module tb_dcache ();

    localparam CLK_PERIOD = 10;

    task automatic DelayCLKs(input int cycles);
        #(CLK_PERIOD * cycles);
    endtask

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

    block_req_t block_req;
    dte_2_dcache_t dte_2_dcache;
    
    bool st_overide_fromArb;
    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    assign dataBus = driveDataBus ? dataForBus : 'z;
    assign addrBus = driveAddrBus ? addrForBus : 'z;

    

    DCache_Block uut0_dcache (
        .clk_i(clk),
        .rst_i(rst),
        .block_req_i(block_req),
        .mem_Valid_FromDte_i(dte_2_dcache.mem_valid[0]),
        .evictionBuf_clr_FromDTE_i(dte_2_dcache.evictionBuf_clr[0]),
        .evictionBuf_setCommiting_FromDTE_i(dte_2_dcache.evictionBuf_setCommiting[0]),
        .permissionToDriveDataBus_evictionBuf(dte_2_dcache.permissionToDriveDataBus_evictionBuf[0]),
        .permissionToDriveAddrBus_Ld(dte_2_dcache.permissionToDriveAddrBus_Ld[0]),
        .permissionToDriveAddrBus_eb(dte_2_dcache.permissionToDriveAddrBus_eb[0]),

        .st_override_for_sch_req(st_overide_fromArb),

        .dataBus(dataBus),
        .address_bus(addrBus),

        .outputs_o()
    );

    dcache_loader dcache_loader_unit ();

    initial begin
        `LOG("DCache Tb Starting up");
        rst = 0;  //actve low
        inFromCore = '{default: '0};
        inFromDTE = '{default: '0};
        driveAddrBus = 0;
        driveDataBus = 0;
        addrForBus = 0;
        dataForBus = 0;
        dte_2_dcache = '{default : '0};
        st_overide_fromArb = 0;

        block_req = '{default: '0}; 

        DelayCLKs(10);
        
        @(posedge clk)
        
        rst = 1;  //actve low
        DelayCLKs(10);
        @(posedge clk)
        block_req.p_addr = 15'h2000;
        block_req.oe = 1;
        block_req.we = 0;

        block_req.vec = 16'hFFFF;
        block_req.st_q_data = '{default: '1};
  
        @(posedge clk)
        DelayCLKs(10);
        @(posedge clk)
        dte_2_dcache.mem_valid[0] = 1;
        driveDataBus = 1;
        dataForBus = 32'h0101_0101;
        @(posedge clk)
        dataForBus = 32'h0202_0202;

        @(posedge clk)
        dataForBus = 32'h0303_0303;

        @(posedge clk)
        dataForBus = 32'h0404_0404;

        @(posedge clk)
        @(posedge clk)
        dte_2_dcache.mem_valid[0] = 0;
        driveDataBus = 0;
        block_req.oe = 0;


        DelayCLKs(10);
        block_req.p_addr = 15'h3000; //new address should cause evictions
        block_req.oe = 1;
        block_req.we = 0;
        block_req.vec = 16'hFFFF;
        block_req.st_q_data = '{default: '1};
        @(posedge clk)

        DelayCLKs(7);
        @(posedge clk)
        dte_2_dcache.mem_valid[0] = 1;
        driveDataBus = 1;
        dataForBus = 32'h1111_1111;
        @(posedge clk)
        dataForBus = 32'h1212_1212;
        @(posedge clk)
        dataForBus = 32'h1313_1313;
        @(posedge clk)
        dataForBus = 32'h1414_1414;
        @(posedge clk)
        dte_2_dcache.mem_valid[0] = 0;
        driveDataBus = 0;
        @(posedge clk)
        block_req.oe = 0;

        DelayCLKs(10);
        @(posedge clk)
        block_req.p_addr = 15'h2000; //new address should be in vcache
        block_req.oe = 1;
        block_req.we = 0;
        block_req.vec = 16'hFFFF;
        block_req.st_q_data = '{default: '1};
        @(posedge clk)
        block_req.oe = 0;

        //hit here and also latches updated at the same time 
        // block_req.oe = 0;
        // block_req.we = 1;
        // block_req.p_addr = 15'h3000; //write to the vcache after swap




        

        








        

        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        DelayCLKs(30);
        `LOG("DCache  Tb Complete");
        $finish;
    end
endmodule
