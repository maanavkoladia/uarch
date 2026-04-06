# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Mon Apr 6 02:23:40 2026
# Designs open: 1
#   V1: vcdplus.vpd
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: tb_DTE
#   Wave.1: 256 signals
#   Group count = 13
#   Group fetch_uut signal count = 38
#   Group idm_uut1 signal count = 6
#   Group icache_shit signal count = 5
#   Group mem_sys signal count = 3
#   Group Group1 signal count = 2
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


# Create and position top-level window: TopLevel.1

if {![gui_exist_window -window TopLevel.1]} {
    set TopLevel.1 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.1 TopLevel.1
}
gui_show_window -window ${TopLevel.1} -show_state maximized -rect {{0 887} {1535 1679}}

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
gui_hide_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 446]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 446
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 445} {height 520} {dock_state left} {dock_on_new_line true} {child_hier_colhier 335} {child_hier_coltype 107} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 339]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 339
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 549
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 338} {height 520} {dock_state left} {dock_on_new_line true} {child_data_colvariable 352} {child_data_colvalue 161} {child_data_coltype 159} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 174]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 1279
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 174
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 1535} {height 173} {dock_state bottom} {dock_on_new_line true}}
#### Start - Readjusting docked view's offset / size
set dockAreaList { top left right bottom }
foreach dockArea $dockAreaList {
  set viewList [gui_ekki_get_window_ids -active_parent -dock_area $dockArea]
  foreach view $viewList {
      if {[lsearch -exact [gui_get_window_pref_keys -window $view] dock_width] != -1} {
        set dockWidth [gui_get_window_pref_value -window $view -key dock_width]
        set dockHeight [gui_get_window_pref_value -window $view -key dock_height]
        set offset [gui_get_window_pref_value -window $view -key dock_offset]
        if { [string equal "top" $dockArea] || [string equal "bottom" $dockArea]} {
          gui_set_window_attributes -window $view -dock_offset $offset -width $dockWidth
        } else {
          gui_set_window_attributes -window $view -dock_offset $offset -height $dockHeight
        }
      }
  }
}
#### End - Readjusting docked view's offset / size
gui_sync_global -id ${TopLevel.1} -option true

# MDI window settings
set Source.1 [gui_create_window -type {Source}  -parent ${TopLevel.1}]
gui_show_window -window ${Source.1} -show_state maximized
gui_update_layout -id ${Source.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false}}

# End MDI window settings


# Create and position top-level window: TopLevel.2

if {![gui_exist_window -window TopLevel.2]} {
    set TopLevel.2 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.2 TopLevel.2
}
gui_show_window -window ${TopLevel.2} -show_state maximized -rect {{6 23} {1285 671}}

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
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 548} {child_wave_right 726} {child_wave_colname 295} {child_wave_colvalue 249} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings

gui_set_env TOPLEVELS::TARGET_FRAME(Source) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Schematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(PathSchematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Wave) none
gui_set_env TOPLEVELS::TARGET_FRAME(List) none
gui_set_env TOPLEVELS::TARGET_FRAME(Memory) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(DriverLoad) none
gui_update_statusbar_target_frame ${TopLevel.1}
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
gui_load_child_values {tb_DTE.uut0_scheduler}
gui_load_child_values {tb_DTE.uut1_icache.icache_contrller_fsm}
gui_load_child_values {tb_DTE.uut1_icache}
gui_load_child_values {tb_DTE.uut1_icache.i_vcache_unit}
gui_load_child_values {tb_DTE.idm_uut1}
gui_load_child_values {tb_DTE.uut1_mem}
gui_load_child_values {tb_DTE.uut1_icache.icache_dataStore_unit}
gui_load_child_values {tb_DTE.uut1_icache.icache_TagStore_unit}
gui_load_child_values {tb_DTE}


set _session_group_51 fetch_uut
gui_sg_create "$_session_group_51"
set fetch_uut "$_session_group_51"

gui_sg_addsignal -group "$_session_group_51" { tb_DTE.clk {tb_DTE.fetch_uut.$unit} tb_DTE.fetch_uut.exp_mode_jk tb_DTE.fetch_uut.int_mode_jk tb_DTE.fetch_uut.DMA_int_jk tb_DTE.fetch_uut.SPC tb_DTE.fetch_uut.f_exp tb_DTE.fetch_uut.seg_xlation_out tb_DTE.fetch_uut.next_spc tb_DTE.fetch_uut.spc_16 tb_DTE.fetch_uut.br_restore_spc tb_DTE.fetch_uut.en_icache tb_DTE.fetch_uut.clk tb_DTE.fetch_uut.rst tb_DTE.fetch_uut.dma_int tb_DTE.fetch_uut.seg_xlation_gp_fault tb_DTE.fetch_uut.rom_data_out tb_DTE.fetch_uut.idm_ctrl_data_in tb_DTE.fetch_uut.br_target tb_DTE.fetch_uut.spc_2_IDM_CTRL tb_DTE.fetch_uut.btb_outs tb_DTE.fetch_uut.spc_sel_logic_outs tb_DTE.fetch_uut.predictor_outs tb_DTE.fetch_uut.idm_ctrl_logic_outs tb_DTE.fetch_uut.idm_invalidate_logic_outs tb_DTE.fetch_uut.tlb_outs tb_DTE.fetch_uut.exp_set_logic_outs tb_DTE.fetch_uut.icache_info_i tb_DTE.fetch_uut.idm_info_i tb_DTE.fetch_uut.decode_outs_i tb_DTE.fetch_uut.rr_outs_i tb_DTE.fetch_uut.dc_outs_i tb_DTE.fetch_uut.mem_outs_i tb_DTE.fetch_uut.exe_outs_i tb_DTE.fetch_uut.wb_outs_i tb_DTE.fetch_uut.outs_o tb_DTE.fetch_uut.predictor_inputs tb_DTE.fetch_uut.tlb_inputs }

set _session_group_52 idm_uut1
gui_sg_create "$_session_group_52"
set idm_uut1 "$_session_group_52"

gui_sg_addsignal -group "$_session_group_52" { {tb_DTE.idm_uut1.$unit} tb_DTE.idm_uut1.clk tb_DTE.idm_uut1.rst tb_DTE.idm_uut1.fetch_outs_i tb_DTE.idm_uut1.idm_outs_o tb_DTE.idm_uut1.idm }

set _session_group_53 icache_shit
gui_sg_create "$_session_group_53"
set icache_shit "$_session_group_53"

gui_sg_addsignal -group "$_session_group_53" { }

set _session_group_54 $_session_group_53|
append _session_group_54 icache_dataStore_unit
gui_sg_create "$_session_group_54"
set icache_shit|icache_dataStore_unit "$_session_group_54"

gui_sg_addsignal -group "$_session_group_54" { {tb_DTE.uut1_icache.icache_dataStore_unit.$unit} tb_DTE.uut1_icache.icache_dataStore_unit.rst tb_DTE.uut1_icache.icache_dataStore_unit.clk tb_DTE.uut1_icache.icache_dataStore_unit.en tb_DTE.uut1_icache.icache_dataStore_unit.v_addr_i tb_DTE.uut1_icache.icache_dataStore_unit.LD_IC_SWAP_BUF tb_DTE.uut1_icache.icache_dataStore_unit.fill0_i tb_DTE.uut1_icache.icache_dataStore_unit.fill1_i tb_DTE.uut1_icache.icache_dataStore_unit.fill2_i tb_DTE.uut1_icache.icache_dataStore_unit.fill3_i tb_DTE.uut1_icache.icache_dataStore_unit.busy tb_DTE.uut1_icache.icache_dataStore_unit.ld_From_I_VC_Swap tb_DTE.uut1_icache.icache_dataStore_unit.dataBus tb_DTE.uut1_icache.icache_dataStore_unit.currLine_o tb_DTE.uut1_icache.icache_dataStore_unit.v_addr_i_index tb_DTE.uut1_icache.icache_dataStore_unit.clk_45_phase tb_DTE.uut1_icache.icache_dataStore_unit.ADDRESS_2_DataStore tb_DTE.uut1_icache.icache_dataStore_unit.dataLineOutSel tb_DTE.uut1_icache.icache_dataStore_unit.WR_2_DataStore_clk tb_DTE.uut1_icache.icache_dataStore_unit.WR_2_DataStore_actual tb_DTE.uut1_icache.icache_dataStore_unit.DIN_2_DataStore tb_DTE.uut1_icache.icache_dataStore_unit.OE_2_DataStore tb_DTE.uut1_icache.icache_dataStore_unit.DOUT_2_DataStore tb_DTE.uut1_icache.icache_dataStore_unit.LAYERS_OF_CELLS tb_DTE.uut1_icache.icache_dataStore_unit.NUM_CELLS tb_DTE.uut1_icache.icache_dataStore_unit.I_VC_SwapBuf_i }
gui_set_radix -radix {decimal} -signals {V1:tb_DTE.uut1_icache.icache_dataStore_unit.LAYERS_OF_CELLS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_DTE.uut1_icache.icache_dataStore_unit.LAYERS_OF_CELLS}
gui_set_radix -radix {decimal} -signals {V1:tb_DTE.uut1_icache.icache_dataStore_unit.NUM_CELLS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_DTE.uut1_icache.icache_dataStore_unit.NUM_CELLS}

gui_sg_move "$_session_group_54" -after "$_session_group_53" -pos 1 

set _session_group_55 $_session_group_53|
append _session_group_55 icache_TagStore_unit
gui_sg_create "$_session_group_55"
set icache_shit|icache_TagStore_unit "$_session_group_55"

gui_sg_addsignal -group "$_session_group_55" { {tb_DTE.uut1_icache.icache_TagStore_unit.$unit} tb_DTE.uut1_icache.icache_TagStore_unit.clk tb_DTE.uut1_icache.icache_TagStore_unit.rst tb_DTE.uut1_icache.icache_TagStore_unit.en tb_DTE.uut1_icache.icache_TagStore_unit.v_addr_i tb_DTE.uut1_icache.icache_TagStore_unit.ld_From_I_VC_Swap tb_DTE.uut1_icache.icache_TagStore_unit.LD_IC_SWAP_BUF tb_DTE.uut1_icache.icache_TagStore_unit.fill3_i tb_DTE.uut1_icache.icache_TagStore_unit.busy tb_DTE.uut1_icache.icache_TagStore_unit.currTag_o tb_DTE.uut1_icache.icache_TagStore_unit.currLine_V tb_DTE.uut1_icache.icache_TagStore_unit.clk_45_phase tb_DTE.uut1_icache.icache_TagStore_unit.validStore tb_DTE.uut1_icache.icache_TagStore_unit.ADDRESS_2_TagStore tb_DTE.uut1_icache.icache_TagStore_unit.tagCellOutSel tb_DTE.uut1_icache.icache_TagStore_unit.DIN_2_TagStore tb_DTE.uut1_icache.icache_TagStore_unit.OE_2_TagStore tb_DTE.uut1_icache.icache_TagStore_unit.DOUT_2_TagStore tb_DTE.uut1_icache.icache_TagStore_unit.WR_2_TagStore_clk tb_DTE.uut1_icache.icache_TagStore_unit.WR_2_TagStore_actual tb_DTE.uut1_icache.icache_TagStore_unit.DOUT_2_TagStore_net tb_DTE.uut1_icache.icache_TagStore_unit.NUM_LAYERS tb_DTE.uut1_icache.icache_TagStore_unit.NUM_CELLS tb_DTE.uut1_icache.icache_TagStore_unit.I_VC_SwapBuf_i tb_DTE.uut1_icache.icache_TagStore_unit.v_addr_i_fields }
gui_set_radix -radix {decimal} -signals {V1:tb_DTE.uut1_icache.icache_TagStore_unit.NUM_LAYERS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_DTE.uut1_icache.icache_TagStore_unit.NUM_LAYERS}
gui_set_radix -radix {decimal} -signals {V1:tb_DTE.uut1_icache.icache_TagStore_unit.NUM_CELLS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_DTE.uut1_icache.icache_TagStore_unit.NUM_CELLS}

gui_sg_move "$_session_group_55" -after "$_session_group_53" -pos 3 

set _session_group_56 $_session_group_53|
append _session_group_56 uut1_icache
gui_sg_create "$_session_group_56"
set icache_shit|uut1_icache "$_session_group_56"

gui_sg_addsignal -group "$_session_group_56" { {tb_DTE.uut1_icache.$unit} tb_DTE.uut1_icache.clk tb_DTE.uut1_icache.rst tb_DTE.uut1_icache.dataBus tb_DTE.uut1_icache.addrBus tb_DTE.uut1_icache.controller_fsmState tb_DTE.uut1_icache.controller_fsmState_bits tb_DTE.uut1_icache.icache_dataLines tb_DTE.uut1_icache.icache_tag tb_DTE.uut1_icache.icache_tag_V tb_DTE.uut1_icache.icache_hit tb_DTE.uut1_icache.icache_miss tb_DTE.uut1_icache.i_vcache_hit tb_DTE.uut1_icache.i_vcache_miss tb_DTE.uut1_icache.i_vcache_swapBuf_V_Clr tb_DTE.uut1_icache.i_vcache_dataLines tb_DTE.uut1_icache.saved_pAddr tb_DTE.uut1_icache.saved_vAddr tb_DTE.uut1_icache.curr_v_addr_to_use tb_DTE.uut1_icache.useSaved_v_Addr tb_DTE.uut1_icache.addrBus_drv tb_DTE.uut1_icache.inFromCore_i tb_DTE.uut1_icache.out2Core_o tb_DTE.uut1_icache.inFromDte_i tb_DTE.uut1_icache.out2Sch_o tb_DTE.uut1_icache.fsmOuts tb_DTE.uut1_icache.icache_swapbuf tb_DTE.uut1_icache.i_vcache_swapBuf }

set _session_group_57 $_session_group_53|
append _session_group_57 i_vcache_unit
gui_sg_create "$_session_group_57"
set icache_shit|i_vcache_unit "$_session_group_57"

gui_sg_addsignal -group "$_session_group_57" { {tb_DTE.uut1_icache.i_vcache_unit.$unit} tb_DTE.uut1_icache.i_vcache_unit.clk tb_DTE.uut1_icache.i_vcache_unit.rst tb_DTE.uut1_icache.i_vcache_unit.busy_i tb_DTE.uut1_icache.i_vcache_unit.en_i tb_DTE.uut1_icache.i_vcache_unit.v_addr_i tb_DTE.uut1_icache.i_vcache_unit.hit_o tb_DTE.uut1_icache.i_vcache_unit.miss_o tb_DTE.uut1_icache.i_vcache_unit.dataLineOut_o tb_DTE.uut1_icache.i_vcache_unit.IC_SwapBuf_V_clr_o tb_DTE.uut1_icache.i_vcache_unit.LD_I_VC_SWAP_BUF tb_DTE.uut1_icache.i_vcache_unit.RD_IC_SWAP_BUF tb_DTE.uut1_icache.i_vcache_unit.hit_idx tb_DTE.uut1_icache.i_vcache_unit.currTag tb_DTE.uut1_icache.i_vcache_unit.currTagHit tb_DTE.uut1_icache.i_vcache_unit.currDataLine tb_DTE.uut1_icache.i_vcache_unit.hit tb_DTE.uut1_icache.i_vcache_unit.miss tb_DTE.uut1_icache.i_vcache_unit.hitHappened tb_DTE.uut1_icache.i_vcache_unit.updateLRU tb_DTE.uut1_icache.i_vcache_unit.currLRU_IDX tb_DTE.uut1_icache.i_vcache_unit.currMRU_IDX tb_DTE.uut1_icache.i_vcache_unit.IDX_2_Write tb_DTE.uut1_icache.i_vcache_unit.update_idx tb_DTE.uut1_icache.i_vcache_unit.NUM_LINES tb_DTE.uut1_icache.i_vcache_unit.NUM_LRU_BITS tb_DTE.uut1_icache.i_vcache_unit.LRU_ROOT tb_DTE.uut1_icache.i_vcache_unit.LRU_LEFT_LEAF tb_DTE.uut1_icache.i_vcache_unit.LRU_RIGHT_LEAF tb_DTE.uut1_icache.i_vcache_unit.IC_SwapBuf_i tb_DTE.uut1_icache.i_vcache_unit.I_VC_SwapBuf_o tb_DTE.uut1_icache.i_vcache_unit.tagStore tb_DTE.uut1_icache.i_vcache_unit.dataStore tb_DTE.uut1_icache.i_vcache_unit.I_VC_swapBuf tb_DTE.uut1_icache.i_vcache_unit.ic_swapBuf_v_addr_fields tb_DTE.uut1_icache.i_vcache_unit.v_addr_i_fields }
gui_set_radix -radix {decimal} -signals {V1:tb_DTE.uut1_icache.i_vcache_unit.NUM_LINES}
gui_set_radix -radix {twosComplement} -signals {V1:tb_DTE.uut1_icache.i_vcache_unit.NUM_LINES}
gui_set_radix -radix {decimal} -signals {V1:tb_DTE.uut1_icache.i_vcache_unit.NUM_LRU_BITS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_DTE.uut1_icache.i_vcache_unit.NUM_LRU_BITS}
gui_set_radix -radix {decimal} -signals {V1:tb_DTE.uut1_icache.i_vcache_unit.LRU_ROOT}
gui_set_radix -radix {twosComplement} -signals {V1:tb_DTE.uut1_icache.i_vcache_unit.LRU_ROOT}
gui_set_radix -radix {decimal} -signals {V1:tb_DTE.uut1_icache.i_vcache_unit.LRU_LEFT_LEAF}
gui_set_radix -radix {twosComplement} -signals {V1:tb_DTE.uut1_icache.i_vcache_unit.LRU_LEFT_LEAF}
gui_set_radix -radix {decimal} -signals {V1:tb_DTE.uut1_icache.i_vcache_unit.LRU_RIGHT_LEAF}
gui_set_radix -radix {twosComplement} -signals {V1:tb_DTE.uut1_icache.i_vcache_unit.LRU_RIGHT_LEAF}

gui_sg_move "$_session_group_57" -after "$_session_group_53" -pos 4 

set _session_group_58 $_session_group_53|
append _session_group_58 icache_contrller_fsm
gui_sg_create "$_session_group_58"
set icache_shit|icache_contrller_fsm "$_session_group_58"

gui_sg_addsignal -group "$_session_group_58" { {tb_DTE.uut1_icache.icache_contrller_fsm.$unit} tb_DTE.uut1_icache.icache_contrller_fsm.clk tb_DTE.uut1_icache.icache_contrller_fsm.rst tb_DTE.uut1_icache.icache_contrller_fsm.IC_miss_i tb_DTE.uut1_icache.icache_contrller_fsm.I_VC_Miss_i tb_DTE.uut1_icache.icache_contrller_fsm.mem_valid_i tb_DTE.uut1_icache.icache_contrller_fsm.en_i tb_DTE.uut1_icache.icache_contrller_fsm.S_0 tb_DTE.uut1_icache.icache_contrller_fsm.S_1 tb_DTE.uut1_icache.icache_contrller_fsm.S_2 tb_DTE.uut1_icache.icache_contrller_fsm.LD_IC_SWAP_BUF_o tb_DTE.uut1_icache.icache_contrller_fsm.RD_I_VC_SWAP_BUF_o tb_DTE.uut1_icache.icache_contrller_fsm.busy_o tb_DTE.uut1_icache.icache_contrller_fsm.MakeReq_o tb_DTE.uut1_icache.icache_contrller_fsm.Fill0EN_o tb_DTE.uut1_icache.icache_contrller_fsm.Fill1EN_o tb_DTE.uut1_icache.icache_contrller_fsm.Fill2EN_o tb_DTE.uut1_icache.icache_contrller_fsm.Fill3EN_o tb_DTE.uut1_icache.icache_contrller_fsm.NS_0 tb_DTE.uut1_icache.icache_contrller_fsm.NS_1 tb_DTE.uut1_icache.icache_contrller_fsm.NS_2 tb_DTE.uut1_icache.icache_contrller_fsm.I_VC_Miss_i_inv tb_DTE.uut1_icache.icache_contrller_fsm.S_0_inv tb_DTE.uut1_icache.icache_contrller_fsm.S_1_inv tb_DTE.uut1_icache.icache_contrller_fsm.S_2_inv tb_DTE.uut1_icache.icache_contrller_fsm.mem_valid_i_inv tb_DTE.uut1_icache.icache_contrller_fsm.NS_0_t0 tb_DTE.uut1_icache.icache_contrller_fsm.NS_0_t1 tb_DTE.uut1_icache.icache_contrller_fsm.NS_0_t2 tb_DTE.uut1_icache.icache_contrller_fsm.NS_1_t0 tb_DTE.uut1_icache.icache_contrller_fsm.NS_1_t1 tb_DTE.uut1_icache.icache_contrller_fsm.NS_1_t2 tb_DTE.uut1_icache.icache_contrller_fsm.NS_2_t0 tb_DTE.uut1_icache.icache_contrller_fsm.NS_2_t1 tb_DTE.uut1_icache.icache_contrller_fsm.NS_2_t2 tb_DTE.uut1_icache.icache_contrller_fsm.NS_2_t3 tb_DTE.uut1_icache.icache_contrller_fsm.busy_o_t0 tb_DTE.uut1_icache.icache_contrller_fsm.busy_o_t1 tb_DTE.uut1_icache.icache_contrller_fsm.busy_o_t2 }

gui_sg_move "$_session_group_58" -after "$_session_group_53" -pos 2 

set _session_group_59 mem_sys
gui_sg_create "$_session_group_59"
set mem_sys "$_session_group_59"

gui_sg_addsignal -group "$_session_group_59" { }

set _session_group_60 $_session_group_59|
append _session_group_60 uut1_mem
gui_sg_create "$_session_group_60"
set mem_sys|uut1_mem "$_session_group_60"

gui_sg_addsignal -group "$_session_group_60" { {tb_DTE.uut1_mem.$unit} tb_DTE.uut1_mem.clk tb_DTE.uut1_mem.rst tb_DTE.uut1_mem.address_bus tb_DTE.uut1_mem.data_bus tb_DTE.uut1_mem.mem_bus tb_DTE.uut1_mem.drive_Data_Bus tb_DTE.uut1_mem.dataToDrive tb_DTE.uut1_mem.inFromDte tb_DTE.uut1_mem.out2Dte tb_DTE.uut1_mem.out2Sch tb_DTE.uut1_mem.controller_2_bank_Cmds tb_DTE.uut1_mem.bank_out_2_controller }

gui_sg_move "$_session_group_60" -after "$_session_group_59" -pos 1 

set _session_group_61 $_session_group_59|
append _session_group_61 uut0_DTE
gui_sg_create "$_session_group_61"
set mem_sys|uut0_DTE "$_session_group_61"

gui_sg_addsignal -group "$_session_group_61" { {tb_DTE.uut0_DTE.$unit} tb_DTE.uut0_DTE.clk tb_DTE.uut0_DTE.rst tb_DTE.uut0_DTE.bestPick_i tb_DTE.uut0_DTE.bestPick_bk_id_i tb_DTE.uut0_DTE.dte_mem_2_icache_fsm_state tb_DTE.uut0_DTE.dte_dcache_2_mem_fsm_state tb_DTE.uut0_DTE.core_2_ddr5_fsmout_busy tb_DTE.uut0_DTE.core_2_dma_fsmout_busy tb_DTE.uut0_DTE.mem_2_icache_fsmout_busy tb_DTE.uut0_DTE.mem_2_dcache_fsmout_busy_per tb_DTE.uut0_DTE.mem_2_dcache_fsmout_busy tb_DTE.uut0_DTE.DTE_Busy tb_DTE.uut0_DTE.mem_2_icache_ld_req_fsmOut tb_DTE.uut0_DTE.mem_2_icache_drv_db_fsmOut tb_DTE.uut0_DTE.dcache_2_mem_st_req_fsmOut tb_DTE.uut0_DTE.core_2_ddr5_reqServed_fsmOut tb_DTE.uut0_DTE.core_2_dma_reqServed_fsmOut tb_DTE.uut0_DTE.mem_2_icache_req_hit tb_DTE.uut0_DTE.mem_2_dcache_req_hit tb_DTE.uut0_DTE.mem_2_dcache_bk_hit tb_DTE.uut0_DTE.core_2_ddr5_req_hit tb_DTE.uut0_DTE.core_2_dma_req_hit tb_DTE.uut0_DTE.dte_out_2_icache_o tb_DTE.uut0_DTE.dte_out_2_dcache_o tb_DTE.uut0_DTE.mem_2_dte_i tb_DTE.uut0_DTE.dte_2_mem_o }

gui_sg_move "$_session_group_61" -after "$_session_group_59" -pos 2 

set _session_group_62 $_session_group_59|
append _session_group_62 uut0_scheduler
gui_sg_create "$_session_group_62"
set mem_sys|uut0_scheduler "$_session_group_62"

gui_sg_addsignal -group "$_session_group_62" { {tb_DTE.uut0_scheduler.$unit} tb_DTE.uut0_scheduler.clk tb_DTE.uut0_scheduler.rst tb_DTE.uut0_scheduler.bestPick_o tb_DTE.uut0_scheduler.bestPick_bk_id_o tb_DTE.uut0_scheduler.dcache_Best_Pick tb_DTE.uut0_scheduler.dcache_Best_Pick_BK_ID tb_DTE.uut0_scheduler.dma_req tb_DTE.uut0_scheduler.IC_MIO_Pick tb_DTE.uut0_scheduler.IC_MIO_DMA_PICK tb_DTE.uut0_scheduler.bestPick tb_DTE.uut0_scheduler.iCache_2_Sch_i tb_DTE.uut0_scheduler.dCache_2_Sch_i tb_DTE.uut0_scheduler.mem_2_Sch_i tb_DTE.uut0_scheduler.dma_2_sch_i tb_DTE.uut0_scheduler.sch_latches }

set _session_group_63 Group1
gui_sg_create "$_session_group_63"
set Group1 "$_session_group_63"

gui_sg_addsignal -group "$_session_group_63" { tb_DTE.rst tb_DTE.clk }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 405.85



# Save global setting...

# Wave/List view global setting
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


# Hier 'Hier.1'
gui_show_window -window ${Hier.1}
gui_list_set_filter -id ${Hier.1} -list { {Package 1} {All 0} {Process 1} {VirtPowSwitch 0} {UnnamedProcess 1} {UDP 0} {Function 1} {Block 1} {SrsnAndSpaCell 0} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {LeafVhdCell 1} {$unit 1} {NamedBlock 1} {Task 1} {VlgPackage 1} {ClassDef 1} {VirtIsoCell 0} }
gui_list_set_filter -id ${Hier.1} -text {*}
gui_hier_list_init -id ${Hier.1}
gui_change_design -id ${Hier.1} -design V1
catch {gui_list_expand -id ${Hier.1} tb_DTE}
catch {gui_list_select -id ${Hier.1} {tb_DTE.uut0_scheduler}}
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {tb_DTE.uut0_scheduler}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active tb_DTE tb_DTE.sv
gui_view_scroll -id ${Source.1} -vertical -set 1320
gui_src_set_reusable -id ${Source.1}

# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_create -id ${Wave.1} M1 450
gui_marker_create -id ${Wave.1} M2 750
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 1114.315 1595.187
gui_list_add_group -id ${Wave.1} -after {New Group} {fetch_uut}
gui_list_add_group -id ${Wave.1} -after {New Group} {idm_uut1}
gui_list_add_group -id ${Wave.1} -after {New Group} {icache_shit}
gui_list_add_group -id ${Wave.1}  -after icache_shit {icache_shit|uut1_icache}
gui_list_add_group -id ${Wave.1} -after icache_shit|uut1_icache {icache_shit|icache_dataStore_unit}
gui_list_add_group -id ${Wave.1} -after icache_shit|icache_dataStore_unit {icache_shit|icache_contrller_fsm}
gui_list_add_group -id ${Wave.1} -after icache_shit|icache_contrller_fsm {icache_shit|icache_TagStore_unit}
gui_list_add_group -id ${Wave.1} -after icache_shit|icache_TagStore_unit {icache_shit|i_vcache_unit}
gui_list_add_group -id ${Wave.1} -after {New Group} {mem_sys}
gui_list_add_group -id ${Wave.1}  -after mem_sys {mem_sys|uut0_scheduler}
gui_list_add_group -id ${Wave.1} -after mem_sys|uut0_scheduler {mem_sys|uut1_mem}
gui_list_add_group -id ${Wave.1} -after mem_sys|uut1_mem {mem_sys|uut0_DTE}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group1}
gui_list_collapse -id ${Wave.1} icache_shit|icache_contrller_fsm
gui_list_collapse -id ${Wave.1} mem_sys|uut1_mem
gui_list_expand -id ${Wave.1} tb_DTE.idm_uut1.idm_outs_o
gui_list_expand -id ${Wave.1} tb_DTE.idm_uut1.idm
gui_list_expand -id ${Wave.1} tb_DTE.idm_uut1.idm.slots
gui_list_expand -id ${Wave.1} tb_DTE.uut0_DTE.dte_out_2_icache_o
gui_list_expand -id ${Wave.1} tb_DTE.uut0_DTE.mem_2_dte_i
gui_list_expand -id ${Wave.1} tb_DTE.uut0_DTE.dte_2_mem_o
gui_list_select -id ${Wave.1} {tb_DTE.idm_uut1.idm_outs_o.valid_slots }
gui_set_radix -radix enum_toggle -signal tb_DTE.idm_uut1.idm_outs_o.idm_slots
gui_set_radix -radix enum_toggle -signal tb_DTE.idm_uut1.idm.slots
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
gui_list_set_insertion_bar  -id ${Wave.1} -group mem_sys  -position below

gui_marker_move -id ${Wave.1} {C1} 405.85
gui_view_scroll -id ${Wave.1} -vertical -set 910
gui_show_grid -id ${Wave.1} -enable false
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Source.1}
	gui_set_active_window -window ${HSPane.1}
}
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
#</Session>

