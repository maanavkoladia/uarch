# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Mon Mar 30 23:49:59 2026
# Designs open: 1
#   V1: vcdplus.vpd
# Toplevel windows open: 1
# 	TopLevel.2
#   Wave.1: 166 signals
#   Group count = 8
#   Group tb_DTE signal count = 3
#   Group controller signal count = 20
#   Group tb_DTE_1 signal count = 15
#   Group uut1_mem signal count = 13
#   Group uut0_DTE signal count = 58
#   Group g_mem_banks[0].mem_bank signal count = 17
#   Group fetch_uut signal count = 37
#   Group idm_uut1 signal count = 6
# End_DVE_Session_Save_Info

# DVE version: T-2022.06_Full64
# DVE build date: May 31 2022 20:53:03


#<Session mode="Full" path="/home/ecelrc/students/je28497/uarch/design/EverythingEverywhereAllAtOnce/tests/BusArb/DTE/session.vcdplus.vpd.tcl" type="Debug">

gui_set_loading_session_type Post
gui_continuetime_set

# Close design
if { [gui_sim_state -check active] } {
    gui_sim_terminate
}
gui_close_db -all
gui_expr_clear_all

# Close all windows
gui_close_window -type Console
gui_close_window -type Wave
gui_close_window -type Source
gui_close_window -type Schematic
gui_close_window -type Data
gui_close_window -type DriverLoad
gui_close_window -type List
gui_close_window -type Memory
gui_close_window -type HSPane
gui_close_window -type DLPane
gui_close_window -type Assertion
gui_close_window -type CovHier
gui_close_window -type CoverageTable
gui_close_window -type CoverageMap
gui_close_window -type CovDetail
gui_close_window -type Local
gui_close_window -type Stack
gui_close_window -type Watch
gui_close_window -type Group
gui_close_window -type Transaction



# Application preferences
gui_set_pref_value -key app_default_font -value {Helvetica,10,-1,5,50,0,0,0,0,0}
gui_src_preferences -tabstop 8 -maxbits 24 -windownumber 1
#<WindowLayout>

# DVE top-level session


# Create and position top-level window: TopLevel.2

if {![gui_exist_window -window TopLevel.2]} {
    set TopLevel.2 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.2 TopLevel.2
}
gui_show_window -window ${TopLevel.2} -show_state normal -rect {{13 31} {1878 1005}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_hide_toolbar -toolbar {Simulator}
gui_hide_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
gui_sync_global -id ${TopLevel.2} -option true

# MDI window settings
set Wave.1 [gui_create_window -type {Wave}  -parent ${TopLevel.2}]
gui_show_window -window ${Wave.1} -show_state maximized
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 565} {child_wave_right 1295} {child_wave_colname 299} {child_wave_colvalue 262} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings

gui_set_env TOPLEVELS::TARGET_FRAME(Source) none
gui_set_env TOPLEVELS::TARGET_FRAME(Schematic) none
gui_set_env TOPLEVELS::TARGET_FRAME(PathSchematic) none
gui_set_env TOPLEVELS::TARGET_FRAME(Wave) none
gui_set_env TOPLEVELS::TARGET_FRAME(List) none
gui_set_env TOPLEVELS::TARGET_FRAME(Memory) none
gui_set_env TOPLEVELS::TARGET_FRAME(DriverLoad) none
gui_update_statusbar_target_frame ${TopLevel.2}

#</WindowLayout>

#<Database>

# DVE Open design session: 

if { ![gui_is_db_opened -db {vcdplus.vpd}] } {
	gui_open_db -design V1 -file vcdplus.vpd -nosource
}
gui_set_precision 1ps
gui_set_time_units 1ns
#</Database>

# DVE Global setting session: 


# Global: Bus

# Global: Expressions

# Global: Signal Time Shift

# Global: Signal Compare

# Global: Signal Groups
gui_load_child_values {tb_DTE.fetch_uut}
gui_load_child_values {tb_DTE.uut1_mem.g_mem_banks[0].mem_bank}
gui_load_child_values {tb_DTE.uut0_DTE}
gui_load_child_values {tb_DTE.uut1_mem.controller}
gui_load_child_values {tb_DTE.idm_uut1}
gui_load_child_values {tb_DTE.uut1_mem}


set _session_group_41 tb_DTE
gui_sg_create "$_session_group_41"
set tb_DTE "$_session_group_41"

gui_sg_addsignal -group "$_session_group_41" { {tb_DTE.$unit} tb_DTE.rst tb_DTE.clk }

set _session_group_42 controller
gui_sg_create "$_session_group_42"
set controller "$_session_group_42"

gui_sg_addsignal -group "$_session_group_42" { {tb_DTE.uut1_mem.controller.$unit} tb_DTE.uut1_mem.controller.DTE_i tb_DTE.uut1_mem.controller.ToDTE_o tb_DTE.uut1_mem.controller.ToScheduler_o tb_DTE.uut1_mem.controller.address_bus tb_DTE.uut1_mem.controller.bankBits_InChip tb_DTE.uut1_mem.controller.bankGroupTable tb_DTE.uut1_mem.controller.bankGroup tb_DTE.uut1_mem.controller.bank_cmds_o tb_DTE.uut1_mem.controller.banks_i tb_DTE.uut1_mem.controller.chipNum tb_DTE.uut1_mem.controller.chipTable tb_DTE.uut1_mem.controller.clk tb_DTE.uut1_mem.controller.data_bus tb_DTE.uut1_mem.controller.fsm_outs tb_DTE.uut1_mem.controller.fsm_state tb_DTE.uut1_mem.controller.hit_into_fsm tb_DTE.uut1_mem.controller.mem_controller_state_bits tb_DTE.uut1_mem.controller.rowBitFromChipAddress tb_DTE.uut1_mem.controller.rst }

set _session_group_43 tb_DTE_1
gui_sg_create "$_session_group_43"
set tb_DTE_1 "$_session_group_43"

gui_sg_addsignal -group "$_session_group_43" { {tb_DTE.$unit} tb_DTE.Clk_PERIOD tb_DTE.address_bus tb_DTE.bestPick_bk_id_2_dte tb_DTE.bestPick_req_2_dte tb_DTE.clk tb_DTE.data_bus tb_DTE.dte_2_dcache tb_DTE.dte_2_ddr5 tb_DTE.dte_2_dma tb_DTE.dte_2_icache tb_DTE.dte_2_mem tb_DTE.mem_2_dte tb_DTE.mem_2_sch tb_DTE.rst }
gui_set_radix -radix {decimal} -signals {V1:tb_DTE.Clk_PERIOD}
gui_set_radix -radix {twosComplement} -signals {V1:tb_DTE.Clk_PERIOD}

set _session_group_44 uut1_mem
gui_sg_create "$_session_group_44"
set uut1_mem "$_session_group_44"

gui_sg_addsignal -group "$_session_group_44" { {tb_DTE.uut1_mem.$unit} tb_DTE.uut1_mem.address_bus tb_DTE.uut1_mem.bank_out_2_controller tb_DTE.uut1_mem.clk tb_DTE.uut1_mem.controller_2_bank_Cmds tb_DTE.uut1_mem.dataToDrive tb_DTE.uut1_mem.data_bus tb_DTE.uut1_mem.drive_Data_Bus tb_DTE.uut1_mem.inFromDte tb_DTE.uut1_mem.mem_bus tb_DTE.uut1_mem.out2Dte tb_DTE.uut1_mem.out2Sch tb_DTE.uut1_mem.rst }

set _session_group_45 uut0_DTE
gui_sg_create "$_session_group_45"
set uut0_DTE "$_session_group_45"

gui_sg_addsignal -group "$_session_group_45" { {tb_DTE.uut0_DTE.$unit} tb_DTE.uut0_DTE.DTE_Busy tb_DTE.uut0_DTE.bestPick_bk_id_i tb_DTE.uut0_DTE.bestPick_i tb_DTE.uut0_DTE.clk tb_DTE.uut0_DTE.core_2_ddr5_driveAddrBus_fsmOut tb_DTE.uut0_DTE.core_2_ddr5_drvDB_fsmOut tb_DTE.uut0_DTE.core_2_ddr5_fsmout_busy tb_DTE.uut0_DTE.core_2_ddr5_reqServed_fsmOut tb_DTE.uut0_DTE.core_2_ddr5_req_hit tb_DTE.uut0_DTE.core_2_dma_driveAddrBus_fsmOut tb_DTE.uut0_DTE.core_2_dma_drvDB_fsmOut tb_DTE.uut0_DTE.core_2_dma_fsmout_busy tb_DTE.uut0_DTE.core_2_dma_reqServed_fsmOut tb_DTE.uut0_DTE.core_2_dma_req_hit tb_DTE.uut0_DTE.dcache_2_mem_bk_hit tb_DTE.uut0_DTE.dcache_2_mem_fsmout_busy tb_DTE.uut0_DTE.dcache_2_mem_fsmout_busy_per tb_DTE.uut0_DTE.dcache_2_mem_req_hit tb_DTE.uut0_DTE.dcache_2_mem_st_req_fsmOut tb_DTE.uut0_DTE.ddr5_2_core_driveAddrBus_fsmOut tb_DTE.uut0_DTE.ddr5_2_core_fsmout_busy tb_DTE.uut0_DTE.ddr5_2_core_reqServed_fsmOut tb_DTE.uut0_DTE.ddr5_2_core_req_hit tb_DTE.uut0_DTE.dma_2_mem_fsmout_busy tb_DTE.uut0_DTE.dma_2_mem_req_hit tb_DTE.uut0_DTE.dma_2_mem_st_req_fsmOut tb_DTE.uut0_DTE.dte_2_ddr5_o tb_DTE.uut0_DTE.dte_2_dma_o tb_DTE.uut0_DTE.dte_2_mem_o tb_DTE.uut0_DTE.dte_core_2_ddr5_fsm_state tb_DTE.uut0_DTE.dte_core_2_ddr5_fsm_state_bits tb_DTE.uut0_DTE.dte_core_2_dma_fsm_state tb_DTE.uut0_DTE.dte_core_2_dma_fsm_state_bits tb_DTE.uut0_DTE.dte_dcache_2_mem_fsm_state tb_DTE.uut0_DTE.dte_dcache_2_mem_fsm_state_bits tb_DTE.uut0_DTE.dte_ddr5_2_core_fsm_state tb_DTE.uut0_DTE.dte_ddr5_2_core_fsm_state_bits tb_DTE.uut0_DTE.dte_dma_2_mem_fsm_state tb_DTE.uut0_DTE.dte_dma_2_mem_fsm_state_bits tb_DTE.uut0_DTE.dte_mem_2_dcache_fsm_state tb_DTE.uut0_DTE.dte_mem_2_dcache_fsm_state_bits tb_DTE.uut0_DTE.dte_mem_2_icache_fsm_state tb_DTE.uut0_DTE.dte_mem_2_icache_fsm_state_bits tb_DTE.uut0_DTE.dte_out_2_dcache_o tb_DTE.uut0_DTE.dte_out_2_icache_o tb_DTE.uut0_DTE.mem_2_dcache_bk_hit tb_DTE.uut0_DTE.mem_2_dcache_drv_db_fsmOut tb_DTE.uut0_DTE.mem_2_dcache_fsmout_busy tb_DTE.uut0_DTE.mem_2_dcache_fsmout_busy_per tb_DTE.uut0_DTE.mem_2_dcache_ld_req_fsmOut tb_DTE.uut0_DTE.mem_2_dcache_req_hit tb_DTE.uut0_DTE.mem_2_dte_i tb_DTE.uut0_DTE.mem_2_icache_drv_db_fsmOut tb_DTE.uut0_DTE.mem_2_icache_fsmout_busy tb_DTE.uut0_DTE.mem_2_icache_ld_req_fsmOut tb_DTE.uut0_DTE.mem_2_icache_req_hit tb_DTE.uut0_DTE.rst }

set _session_group_46 {g_mem_banks[0].mem_bank}
gui_sg_create "$_session_group_46"
set {g_mem_banks[0].mem_bank} "$_session_group_46"

gui_sg_addsignal -group "$_session_group_46" { {tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.$unit} {tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.BANK_ID} {tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.NUM_SRAM_CELLS} {tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.bank_address_i} {tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.bank_bus} {tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.bank_write_data} {tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.clk} {tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.controller2bank_i} {tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.fsm_state} {tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.mem_bank_controller_oe} {tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.mem_bank_controller_send_store_address} {tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.mem_bank_controller_send_store_address_delayed} {tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.mem_bank_controller_states_bits} {tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.mem_bank_controller_we} {tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.mem_bus} {tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.outputs} {tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.rst} }
gui_set_radix -radix {decimal} -signals {{V1:tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.BANK_ID}}
gui_set_radix -radix {twosComplement} -signals {{V1:tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.BANK_ID}}
gui_set_radix -radix {decimal} -signals {{V1:tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.NUM_SRAM_CELLS}}
gui_set_radix -radix {twosComplement} -signals {{V1:tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.NUM_SRAM_CELLS}}

set _session_group_47 fetch_uut
gui_sg_create "$_session_group_47"
set fetch_uut "$_session_group_47"

gui_sg_addsignal -group "$_session_group_47" { {tb_DTE.fetch_uut.$unit} tb_DTE.fetch_uut.exp_mode_jk tb_DTE.fetch_uut.int_mode_jk tb_DTE.fetch_uut.DMA_int_jk tb_DTE.fetch_uut.SPC tb_DTE.fetch_uut.f_exp tb_DTE.fetch_uut.seg_xlation_out tb_DTE.fetch_uut.next_spc tb_DTE.fetch_uut.spc_16 tb_DTE.fetch_uut.br_restore_spc tb_DTE.fetch_uut.en_icache tb_DTE.fetch_uut.clk tb_DTE.fetch_uut.rst tb_DTE.fetch_uut.dma_int tb_DTE.fetch_uut.seg_xlation_gp_fault tb_DTE.fetch_uut.rom_data_out tb_DTE.fetch_uut.idm_ctrl_data_in tb_DTE.fetch_uut.br_target tb_DTE.fetch_uut.spc_2_IDM_CTRL tb_DTE.fetch_uut.btb_outs tb_DTE.fetch_uut.spc_sel_logic_outs tb_DTE.fetch_uut.predictor_outs tb_DTE.fetch_uut.idm_ctrl_logic_outs tb_DTE.fetch_uut.idm_invalidate_logic_outs tb_DTE.fetch_uut.tlb_outs tb_DTE.fetch_uut.exp_set_logic_outs tb_DTE.fetch_uut.icache_info_i tb_DTE.fetch_uut.idm_info_i tb_DTE.fetch_uut.decode_outs_i tb_DTE.fetch_uut.rr_outs_i tb_DTE.fetch_uut.dc_outs_i tb_DTE.fetch_uut.mem_outs_i tb_DTE.fetch_uut.exe_outs_i tb_DTE.fetch_uut.wb_outs_i tb_DTE.fetch_uut.outs_o tb_DTE.fetch_uut.predictor_inputs tb_DTE.fetch_uut.tlb_inputs }

set _session_group_48 idm_uut1
gui_sg_create "$_session_group_48"
set idm_uut1 "$_session_group_48"

gui_sg_addsignal -group "$_session_group_48" { {tb_DTE.idm_uut1.$unit} tb_DTE.idm_uut1.clk tb_DTE.idm_uut1.rst tb_DTE.idm_uut1.fetch_outs_i tb_DTE.idm_uut1.idm_outs_o tb_DTE.idm_uut1.idm }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 344.813



# Save global setting...

# Wave/List view global setting
gui_list_create_group_when_add -list -enable
gui_list_create_group_when_add -wave -enable
gui_cov_show_value -switch false

# Close all empty TopLevel windows
foreach __top [gui_ekki_get_window_ids -type TopLevel] {
    if { [llength [gui_ekki_get_window_ids -parent $__top]] == 0} {
        gui_close_window -window $__top
    }
}
gui_set_loading_session_type noSession
# DVE View/pane content session: 


# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 323.266 399.171
gui_list_add_group -id ${Wave.1} -after {New Group} {tb_DTE_1}
gui_list_add_group -id ${Wave.1} -after {New Group} {controller}
gui_list_add_group -id ${Wave.1} -after {New Group} {uut1_mem}
gui_list_add_group -id ${Wave.1} -after {New Group} {uut0_DTE}
gui_list_add_group -id ${Wave.1} -after {New Group} {{g_mem_banks[0].mem_bank}}
gui_list_add_group -id ${Wave.1} -after {New Group} {fetch_uut}
gui_list_add_group -id ${Wave.1} -after {New Group} {idm_uut1}
gui_list_collapse -id ${Wave.1} uut1_mem
gui_list_collapse -id ${Wave.1} uut0_DTE
gui_list_expand -id ${Wave.1} tb_DTE.dte_2_icache
gui_list_expand -id ${Wave.1} tb_DTE.mem_2_dte
gui_list_expand -id ${Wave.1} {tb_DTE.uut1_mem.g_mem_banks[0].mem_bank.outputs}
gui_list_expand -id ${Wave.1} tb_DTE.idm_uut1.idm_outs_o
gui_list_expand -id ${Wave.1} tb_DTE.idm_uut1.idm_outs_o.idm_slots
gui_list_expand -id ${Wave.1} {tb_DTE.idm_uut1.idm_outs_o.idm_slots[0]}
gui_list_expand -id ${Wave.1} {tb_DTE.idm_uut1.idm_outs_o.idm_slots[1]}
gui_list_expand -id ${Wave.1} {tb_DTE.idm_uut1.idm_outs_o.idm_slots[2]}
gui_list_expand -id ${Wave.1} {tb_DTE.idm_uut1.idm_outs_o.idm_slots[3]}
gui_list_select -id ${Wave.1} {tb_DTE.data_bus }
gui_set_radix -radix enum_toggle -signal {{tb_DTE.idm_uut1.idm_outs_o.idm_slots[0].data}}
gui_set_radix -radix enum_toggle -signal {{tb_DTE.idm_uut1.idm_outs_o.idm_slots[1].data}}
gui_set_radix -radix enum_toggle -signal {{tb_DTE.idm_uut1.idm_outs_o.idm_slots[2].data}}
gui_set_radix -radix enum_toggle -signal {{tb_DTE.idm_uut1.idm_outs_o.idm_slots[3].data}}
gui_seek_criteria -id ${Wave.1} {Any Edge}



gui_set_env TOGGLE::DEFAULT_WAVE_WINDOW ${Wave.1}
gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group idm_uut1  -position in

gui_marker_move -id ${Wave.1} {C1} 344.813
gui_view_scroll -id ${Wave.1} -vertical -set 0
gui_show_grid -id ${Wave.1} -enable false
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
#</Session>

