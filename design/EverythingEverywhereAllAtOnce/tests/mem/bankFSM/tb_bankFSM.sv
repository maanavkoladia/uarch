import common_pkg::*;
import interconnect_pkg::*;
import mem_common_pkg::*;


module tb_bankFSM ();
    localparam int = 10;

    task automatic DelayClks(input int cycles);
        #(Clk_PERIOD * cycles);
    endtask

    `CLK_INIT(`CYCLE_TIME)

    //`GEN_WAVEFORM_VCD("wave.vcd", tb_memBanks, 10);
    //`GEN_WAVEFORM_VPD("wave.vpd", tb_memBanks, 10);

    logic rst;

    bank_fsm_controller_state_t fsm_state;
    logic [$clog2(
BANK_CONTROLLER_FSM_LOGIC_STATES
) - 1 : 0] mem_bank_controller_states_bits;  // packed 5-bit vector
    assign fsm_state = bank_fsm_controller_state_t'(mem_bank_controller_states_bits);

    logic mem_bank_controller_oe;
    logic mem_bank_controller_we;
    logic mem_bank_controller_send_store_address;
    logic clearWB;
    logic Precharged;
    logic cmd_ld_addr_changed;
    logic cmd_start_store;

    bank_controller_fsm_logic uut0 (
        .clk(clk),
        .rst(rst),
        .ld_address_change_i(cmd_ld_addr_changed),
        .start_store_i(cmd_start_store),
        .S_0(mem_bank_controller_states_bits[0]),  // current-state bit 0
        .S_1(mem_bank_controller_states_bits[1]),  // current-state bit 1
        .S_2(mem_bank_controller_states_bits[2]),  // current-state bit 2
        .S_3(mem_bank_controller_states_bits[3]),  // current-state bit 3
        .S_4(mem_bank_controller_states_bits[4]),  // current-state bit 4
        .st_addr_release_o(mem_bank_controller_send_store_address),
        .OE_o(mem_bank_controller_oe),
        .WE_o(mem_bank_controller_we),
        .clear_writebufV_o(clearWB),
        .PreCharged_o(Precharged)
    );

    property check_dataBus (
        logic                          trigger,
        logic [DATA_WIDTH_BITS - 1 : 0] expected,
        logic [DATA_WIDTH_BITS - 1 : 0] actual
    );
        @(posedge clk)
        disable iff (rst)
        $fell(trigger) |=> ##10 (actual == expected && !$isunknown(actual));
    endproperty

    // Cover: confirm the antecedent actually fires at least once.
    // If this cover is never hit the assertion was vacuously passing.
    cover property (@(posedge clk) disable iff (rst) $fell(sva_trigger))
        $display("[COVER] sva_trigger fell — SVA antecedent fired at time %0t", $realtime);

    // Assertion: expected value must match mem[8] from your hex file.
    // Replace 32'hDEADBEEF with the real expected value.
    assert property (check_dataBus(sva_trigger, 32'h ff777711, memCellBus))
        else $fatal(1, "[FAIL] check_dataBus SVA failed at time %0t — got %h",
                    $realtime, memCellBus);

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    initial begin
        `DELAY_CYCLES(5);
        for(int i = 0; i < 4; i++; i++) begin
            string fileName = $sformatf("fakeData/mem%d.hex", i);
            $readmemh(fileName, tb_bankFSM.uut0.g_sram_cells[i].mem_cell.mem);
        end
        //$readmemh(fileName, tb_bankFSM.uut0.g_sram_cells[0].mem_cell.mem);;
        //$readmemh(fileName, tb_bankFSM.uut0.g_sram_cells[1].mem_cell.mem);;
        //$readmemh(fileName, tb_bankFSM.uut0.g_sram_cells[2].mem_cell.mem);;
        //$readmemh(fileName, tb_bankFSM.uut0.g_sram_cells[3].mem_cell.mem);;
    end

    initial begin
        `DELAY_CYCLES(10);
        `LOG("Mem Bank Tb Starting up");
        rst = 0;
        cmd_start_store = 0;
        cmd_ld_addr_changed = 0;
        `DELAY_CYCLES(3);
        rst = 1;
        //testing precharging
        `DELAY_CYCLES(10);
        //testing ld addr changed functionality
        cmd_ld_addr_changed = 1;
        `DELAY_CYCLES(1);
        cmd_ld_addr_changed = 0;
        `DELAY_CYCLES(20);

        //testing store functionality
        cmd_start_store = 1;
        `DELAY_CYCLES(1);
        cmd_start_store = 0;
        `DELAY_CYCLES(13);

        //need to test: interrutip ld with ld_addr changed, should restart
        //load sequence
        cmd_ld_addr_changed = 1;
        `DELAY_CYCLES(1);
        cmd_ld_addr_changed = 0;
        `DELAY_CYCLES(20);

        //need to test: interppt store w ld addr chagned, shoudl not interrupt
        //write sequence
        cmd_start_store = 1;
        `DELAY_CYCLES(1);
        cmd_start_store = 0;
        `DELAY_CYCLES(5);
        cmd_ld_addr_changed = 1;
        `DELAY_CYCLES(1);
        cmd_ld_addr_changed = 0;

        //test: st interrutps a ld sequnce
        `DELAY_CYCLES(20);
        cmd_ld_addr_changed = 1;
        `DELAY_CYCLES(1);
        cmd_ld_addr_changed = 0;
        `DELAY_CYCLES(2);
        cmd_start_store = 1;
        `DELAY_CYCLES(1);
        cmd_start_store = 0;

        `DELAY_CYCLES(50);
 
        `LOG("Mem Bank Tb Complete");
        $finish;
    end

endmodule
