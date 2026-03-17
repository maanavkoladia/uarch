import common_pkg::*;
import interconnect_pkg::*;
import mem_common_pkg::*;

`define CYCLE_TIME (100)
`define DELAY_CYCLES(cycles) #(`CYCLE_TIME * cycles)

module tb_bankFSM ();

    `CLK_INIT(`CYCLE_TIME) 
    //`GEN_WAVEFORM_VCD("wave.vcd", tb_memBanks, 10);
    //`GEN_WAVEFORM_VPD("wave.vpd", tb_memBanks, 10);
    initial begin
        $vcdpluson;
    end
    
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

    bank_controller_fsm_logic uut0 (
        .clk(clk),
        .rst(rst),
        .ld_address_change_i(1'b0),
        .start_store_i(1'b0),
        .S_0(mem_bank_controller_states_bits[4]),  // current-state bit 0
        .S_1(mem_bank_controller_states_bits[3]),  // current-state bit 1
        .S_2(mem_bank_controller_states_bits[2]),  // current-state bit 2
        .S_3(mem_bank_controller_states_bits[1]),  // current-state bit 3
        .S_4(mem_bank_controller_states_bits[0]),  // current-state bit 4
        .st_addr_release_o(mem_bank_controller_send_store_address),
        .OE_o(mem_bank_controller_oe),
        .WE_o(mem_bank_controller_we),
        .clear_writebufV_o(clearWB),
        .PreCharged_o(Precharged)
    );

    
    initial begin
        `LOG("Mem Bank Tb Starting up");
        rst = 0;
        `DELAY_CYCLES(10);
        rst = 1;
        `DELAY_CYCLES(30);
        `LOG("Mem Bank Tb Complete");
        $finish;
    end

endmodule
