import common_pkg::*;
import interconnect_pkg::*;
import mem_common_pkg::*;

`define CYCLE_TIME (10)
`define DELAY_CYCLES(cycles) #(`CYCLE_TIME * cycles)

module tb_memBanks ();

    `CLK_INIT(`CYCLE_TIME)
    //`GEN_WAVEFORM_VCD("wave.vcd", tb_memBanks, 10);
    //`GEN_WAVEFORM_VPD("wave.vpd", tb_memBanks, 10);
    
    logic rst = 0;
    wire [MEM_BUS_SIZE - 1:0] memBus;
    mem_controller_2_mem_bank_t bankCmds;

    mem_bank_out_t bankOut;

    //gate the bus
    assign memBus = 'z;

    mem_bank uut0 (
        .clk(clk),
        .rst(rst),
        .controller2bank_i(bankCmds),
        .mem_bus(memBus),
        .outputs(bankOut)
    );

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    initial begin
        `DELAY_CYCLES(3);
        $readmemh("fakeData/mem0.hex", tb_memBanks.uut0.g_sram_cells[0].mem_cell.mem);
        $readmemh("fakeData/mem1.hex", tb_memBanks.uut0.g_sram_cells[1].mem_cell.mem);
        $readmemh("fakeData/mem2.hex", tb_memBanks.uut0.g_sram_cells[2].mem_cell.mem);
        $readmemh("fakeData/mem3.hex", tb_memBanks.uut0.g_sram_cells[3].mem_cell.mem);
    end

    initial begin
        `LOG("Mem Bank Tb Starting up");
        rst = 0;
        bankCmds.ld_address = 1;
        bankCmds.st_address = 3;
        bankCmds.start_store = 0;
        bankCmds.ld_address_change = 0;
        bankCmds.driveMemBus = 0;

        bankCmds.writeBuf = '{
            8'h00,
            8'h11,
            8'h22,
            8'h33,
            8'h44,
            8'h55,
            8'h66,
            8'h77,
            8'h88,
            8'h99,
            8'hAA,
            8'hBB,
            8'hCC,
            8'hDD,
            8'hEE,
            8'hFF
        };

/////////////////////////////////////////////////////////////////////////////////////
        //Give some time for start up, and precharging
/////////////////////////////////////////////////////////////////////////////////////
        `DELAY_CYCLES(10);
        rst = 1;
        `DELAY_CYCLES(20);
/////////////////////////////////////////////////////////////////////////////////////
        //testing ld_addr_changed;
/////////////////////////////////////////////////////////////////////////////////////
        bankCmds.ld_address = 20;
        bankCmds.ld_address_change = 1;
        `DELAY_CYCLES(1);
        bankCmds.ld_address_change = 0;
        `DELAY_CYCLES(20);
/////////////////////////////////////////////////////////////////////////////////////
        //testing ld_addr_changed while not precharged, shoudl restart
/////////////////////////////////////////////////////////////////////////////////////
        bankCmds.ld_address = 5;
        bankCmds.ld_address_change = 1;
        `DELAY_CYCLES(1);
        bankCmds.ld_address_change = 0;
        `DELAY_CYCLES(2);
        bankCmds.ld_address = 6;
        bankCmds.ld_address_change = 1;
        `DELAY_CYCLES(1);
        bankCmds.ld_address_change = 0;
        `DELAY_CYCLES(20);
/////////////////////////////////////////////////////////////////////////////////////
        //Doing store work and testing to make sure that the data is correct
        //also making sure that ld addr changed doesmnt fuck anything up
        //shoudlnt bc i tested the bankcontrller module seperatly
/////////////////////////////////////////////////////////////////////////////////////
        //start store
        bankCmds.start_store = 1;
        `DELAY_CYCLES(1);
        bankCmds.start_store = 0;
        `DELAY_CYCLES(2);
        //signal that the ld addr has changed
        bankCmds.ld_address = bankCmds.st_address;
        bankCmds.ld_address_change = 1;
        `DELAY_CYCLES(1);
        bankCmds.ld_address_change = 0;
        `DELAY_CYCLES(20);
/////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
/////////////////////////////////////////////////////////////////////////////////////
        `DELAY_CYCLES(30);
        `LOG("Mem Bank Tb Complete");
        $finish;
    end

endmodule
