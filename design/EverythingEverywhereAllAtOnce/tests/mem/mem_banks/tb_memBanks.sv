import common_pkg::*;
import interconnect_pkg::*;
import mem_common_pkg::*;

`define CYCLE_TIME (100)
`define DELAY_CYCLES(cycles) #(`CYCLE_TIME * cycles)

module tb_memBanks ();

    `CLK_INIT(`CYCLE_TIME) 
    `GEN_WAVEFORM_VCD("wave.vcd", tb_memBanks, 2);
    `GEN_WAVEFORM_VPD("wave.vpd");
    
    logic rst = 0;
    wire [MEM_BUS_SIZE - 1: 0] memBus;
    mem_controller_2_mem_bank_t bankCmds;

    mem_bank_out_t bankOut;

    //gate the bus
    assign memBus = 'z;

    mem_bank uut0(

        .clk(clk),
        .rst(rst),
        .controller2bank_i(bankCmds),
        .mem_bus(memBus),
        .outputs(bankOut)
    );
    
    initial begin
        `LOG("Mem Bank Tb Starting up");
        rst = 1;
        bankCmds.ld_address = 0;
        bankCmds.st_address = 0;
        bankCmds.start_store = 0;
        bankCmds.ld_address_change = 0;
        bankCmds.driveMemBus = 0;

        bankCmds.writeBuf = '{8'h11,8'h22,8'h11,8'h22,8'h11,8'h22,8'h11,8'h22,8'h11,8'h22,8'h11,8'h22,8'h11,8'h22,8'h11,8'h22};

        `DELAY_CYCLES(10);
        rst = 0;
        `DELAY_CYCLES(30);
        `LOG("Mem Bank Tb Complete");
        $finish;
    end

endmodule
