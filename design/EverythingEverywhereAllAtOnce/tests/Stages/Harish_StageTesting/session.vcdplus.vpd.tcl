# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Wed Apr 15 20:33:46 2026
# Designs open: 1
#   V1: vcdplus.vpd
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: tb_stages
#   Wave.1: 140 signals
#   Group count = 6
#   Group Core signal count = 4
#   Group OffCore signal count = 20
# End_DVE_Session_Save_Info

# DVE version: T-2022.06_Full64
# DVE build date: May 31 2022 20:53:03


#<Session mode="Full" path="/misc/scratch/he3837/UARCH/uarch/design/EverythingEverywhereAllAtOnce/tests/Stages/Harish_StageTesting/session.vcdplus.vpd.tcl" type="Debug">

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
gui_show_window -window ${TopLevel.1} -show_state normal -rect {{152 97} {1465 920}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_set_toolbar_attributes -toolbar {&File} -dock_state top
gui_set_toolbar_attributes -toolbar {&File} -offset 0
gui_show_toolbar -toolbar {&File}
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
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 594]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 594
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 593} {height 517} {dock_state left} {dock_on_new_line true} {child_hier_colhier 407} {child_hier_coltype 179} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 332]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 332
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 693
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 331} {height 517} {dock_state left} {dock_on_new_line true} {child_data_colvariable 352} {child_data_colvalue 161} {child_data_coltype 159} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set HSPane.2 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 439]
catch { set Hier.2 [gui_share_window -id ${HSPane.2} -type Hier] }
gui_set_window_pref_key -window ${HSPane.2} -key dock_width -value_type integer -value 439
gui_set_window_pref_key -window ${HSPane.2} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.2} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.2} {{left 0} {top 0} {width 438} {height 517} {dock_state left} {dock_on_new_line true} {child_hier_colhier 335} {child_hier_coltype 107} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.2 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 504]
catch { set Data.2 [gui_share_window -id ${DLPane.2} -type Data] }
gui_set_window_pref_key -window ${DLPane.2} -key dock_width -value_type integer -value 504
gui_set_window_pref_key -window ${DLPane.2} -key dock_height -value_type integer -value 728
gui_set_window_pref_key -window ${DLPane.2} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.2} {{left 0} {top 0} {width 503} {height 517} {dock_state left} {dock_on_new_line true} {child_data_colvariable 279} {child_data_colvalue 57} {child_data_coltype 171} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 177]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 689
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 177
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 1313} {height 176} {dock_state bottom} {dock_on_new_line true}}
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
gui_show_window -window ${TopLevel.2} -show_state maximized -rect {{0 101} {1469 959}}

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
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 422} {child_wave_right 1042} {child_wave_colname 207} {child_wave_colvalue 211} {child_wave_col1 0} {child_wave_col2 1}}

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
gui_set_time_units 1ps
#</Database>

# DVE Global setting session: 


# Global: Bus

# Global: Expressions

# Global: Signal Time Shift

# Global: Signal Compare

# Global: Signal Groups
gui_load_child_values {tb_stages.uut_core}
gui_load_child_values {tb_stages.uut_core.fetch_unit}
gui_load_child_values {tb_stages.uut_core.idm_unit}
gui_load_child_values {tb_stages.uut_offcore}
gui_load_child_values {tb_stages.uut_core.decode_unit}


set _session_group_31 Core
gui_sg_create "$_session_group_31"
set Core "$_session_group_31"

gui_sg_addsignal -group "$_session_group_31" { }

set _session_group_32 $_session_group_31|
append _session_group_32 uut_core
gui_sg_create "$_session_group_32"
set Core|uut_core "$_session_group_32"

gui_sg_addsignal -group "$_session_group_32" { tb_stages.uut_core.mem_latches tb_stages.uut_core.wb_latches_next tb_stages.uut_core.DCacheIn_i tb_stages.uut_core.inFromDMA_i tb_stages.uut_core.dc_outputs tb_stages.uut_core.mem_latches_next tb_stages.uut_core.mem_outputs tb_stages.uut_core.dc_latches_next tb_stages.uut_core.wb_latches tb_stages.uut_core.rr_latches_next tb_stages.uut_core.rr_latches tb_stages.uut_core.exe_latches tb_stages.uut_core.idm_outputs tb_stages.uut_core.fetch_outputs tb_stages.uut_core.clk tb_stages.uut_core.wb_outputs tb_stages.uut_core.decode_outputs tb_stages.uut_core.rr_outputs tb_stages.uut_core.exe_latches_next tb_stages.uut_core.out2DCache_o tb_stages.uut_core.exe_outputs {tb_stages.uut_core.$unit} tb_stages.uut_core.ICacheIn_i tb_stages.uut_core.dc_latches tb_stages.uut_core.out2ICache_o tb_stages.uut_core.rst }

gui_sg_move "$_session_group_32" -after "$_session_group_31" -pos 1 

set _session_group_33 $_session_group_31|
append _session_group_33 decode_unit
gui_sg_create "$_session_group_33"
set Core|decode_unit "$_session_group_33"

gui_sg_addsignal -group "$_session_group_33" { tb_stages.uut_core.decode_unit.REP_LATCH tb_stages.uut_core.decode_unit.sib_size tb_stages.uut_core.decode_unit.outs_o tb_stages.uut_core.decode_unit.rst tb_stages.uut_core.decode_unit.rr_latches_next tb_stages.uut_core.decode_unit.modrm_byte tb_stages.uut_core.decode_unit.temp_mem_cs tb_stages.uut_core.decode_unit.branch_present tb_stages.uut_core.decode_unit.exe_outs_i tb_stages.uut_core.decode_unit.stall tb_stages.uut_core.decode_unit.next_rr_valid tb_stages.uut_core.decode_unit.clk tb_stages.uut_core.decode_unit.invalid_inst tb_stages.uut_core.decode_unit.sibscale tb_stages.uut_core.decode_unit.HALT_REG tb_stages.uut_core.decode_unit.predicted_target tb_stages.uut_core.decode_unit.temp_exe_cs tb_stages.uut_core.decode_unit.temp_decode_cs tb_stages.uut_core.decode_unit.clear_rep tb_stages.uut_core.decode_unit.rr_outs_i tb_stages.uut_core.decode_unit.predicted_taken tb_stages.uut_core.decode_unit.inst_length tb_stages.uut_core.decode_unit.PrevEIP tb_stages.uut_core.decode_unit.opcode_byte tb_stages.uut_core.decode_unit.temp_dc_cs tb_stages.uut_core.decode_unit.displacement tb_stages.uut_core.decode_unit.total_pf_vector tb_stages.uut_core.decode_unit.wb_outs_i tb_stages.uut_core.decode_unit.temp_rr_latch tb_stages.uut_core.decode_unit.rep_latch_holder tb_stages.uut_core.decode_unit.sibbase tb_stages.uut_core.decode_unit.REP_MOV_LATCH tb_stages.uut_core.decode_unit.segment0 tb_stages.uut_core.decode_unit.NEIP tb_stages.uut_core.decode_unit.temp_wb_cs tb_stages.uut_core.decode_unit.rr_latch_we_o tb_stages.uut_core.decode_unit.sib_byte tb_stages.uut_core.decode_unit.mem_outs_i tb_stages.uut_core.decode_unit.queue tb_stages.uut_core.decode_unit.disp_size tb_stages.uut_core.decode_unit.br_info_for_latches tb_stages.uut_core.decode_unit.EIP tb_stages.uut_core.decode_unit.PrevLength tb_stages.uut_core.decode_unit.fetch_outs_i tb_stages.uut_core.decode_unit.REP_CMP_LATCH tb_stages.uut_core.decode_unit.sibidx tb_stages.uut_core.decode_unit.decode_gp tb_stages.uut_core.decode_unit.idm_outs_i {tb_stages.uut_core.decode_unit.$unit} tb_stages.uut_core.decode_unit.flush tb_stages.uut_core.decode_unit.imm64 tb_stages.uut_core.decode_unit.temp_rr_cs tb_stages.uut_core.decode_unit.dc_outs_i tb_stages.uut_core.decode_unit.disp_needed }

set _session_group_34 $_session_group_31|
append _session_group_34 idm_unit
gui_sg_create "$_session_group_34"
set Core|idm_unit "$_session_group_34"

gui_sg_addsignal -group "$_session_group_34" { tb_stages.uut_core.idm_unit.fetch_outs_i tb_stages.uut_core.idm_unit.idm_outs_o tb_stages.uut_core.idm_unit.clk tb_stages.uut_core.idm_unit.idm tb_stages.uut_core.idm_unit.rst }

gui_sg_move "$_session_group_34" -after "$_session_group_31" -pos 3 

set _session_group_35 $_session_group_31|
append _session_group_35 fetch_unit
gui_sg_create "$_session_group_35"
set Core|fetch_unit "$_session_group_35"

gui_sg_addsignal -group "$_session_group_35" { tb_stages.uut_core.fetch_unit.spc_sel_logic_outs tb_stages.uut_core.fetch_unit.SPC tb_stages.uut_core.fetch_unit.predictor_inputs tb_stages.uut_core.fetch_unit.seg_xlation_out tb_stages.uut_core.fetch_unit.rr_outs_i tb_stages.uut_core.fetch_unit.idm_ctrl_data_in tb_stages.uut_core.fetch_unit.rom_data_out tb_stages.uut_core.fetch_unit.icache_info_i tb_stages.uut_core.fetch_unit.spc_16 tb_stages.uut_core.fetch_unit.idm_invalidate_logic_outs tb_stages.uut_core.fetch_unit.DMA_int_jk tb_stages.uut_core.fetch_unit.br_target tb_stages.uut_core.fetch_unit.btb_outs tb_stages.uut_core.fetch_unit.predictor_outs tb_stages.uut_core.fetch_unit.dc_outs_i tb_stages.uut_core.fetch_unit.exe_outs_i tb_stages.uut_core.fetch_unit.outs_o tb_stages.uut_core.fetch_unit.clk tb_stages.uut_core.fetch_unit.tlb_inputs tb_stages.uut_core.fetch_unit.wb_outs_i tb_stages.uut_core.fetch_unit.idm_info_i tb_stages.uut_core.fetch_unit.en_icache tb_stages.uut_core.fetch_unit.mem_outs_i tb_stages.uut_core.fetch_unit.f_exp tb_stages.uut_core.fetch_unit.exp_mode_jk tb_stages.uut_core.fetch_unit.br_restore_spc tb_stages.uut_core.fetch_unit.dma_int tb_stages.uut_core.fetch_unit.exp_set_logic_outs tb_stages.uut_core.fetch_unit.int_mode_jk tb_stages.uut_core.fetch_unit.idm_ctrl_logic_outs tb_stages.uut_core.fetch_unit.next_spc tb_stages.uut_core.fetch_unit.spc_2_IDM_CTRL tb_stages.uut_core.fetch_unit.tlb_outs tb_stages.uut_core.fetch_unit.rst tb_stages.uut_core.fetch_unit.decode_outs_i }

gui_sg_move "$_session_group_35" -after "$_session_group_31" -pos 2 

set _session_group_36 OffCore
gui_sg_create "$_session_group_36"
set OffCore "$_session_group_36"

gui_sg_addsignal -group "$_session_group_36" { {tb_stages.uut_offcore.$unit} tb_stages.uut_offcore.clk tb_stages.uut_offcore.rst tb_stages.uut_offcore.dataBus tb_stages.uut_offcore.addressBus tb_stages.uut_offcore.core2icache_i tb_stages.uut_offcore.icache2core_o tb_stages.uut_offcore.core2dcache_i tb_stages.uut_offcore.dcache2core_o tb_stages.uut_offcore.dma2core_o tb_stages.uut_offcore.icache2sched tb_stages.uut_offcore.dte2icache tb_stages.uut_offcore.dcache2sched tb_stages.uut_offcore.dte2dcache tb_stages.uut_offcore.mem2sched tb_stages.uut_offcore.mem2dte tb_stages.uut_offcore.dte2mem tb_stages.uut_offcore.dma2sched tb_stages.uut_offcore.dte2dma tb_stages.uut_offcore.dte2ddr5 }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 2229440



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
gui_list_set_filter -id ${Hier.1} -list { {Package 1} {All 0} {Process 1} {VirtPowSwitch 0} {UnnamedProcess 1} {UDP 0} {Function 0} {Block 1} {SrsnAndSpaCell 0} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {LeafVhdCell 1} {$unit 0} {NamedBlock 0} {Task 0} {VlgPackage 0} {ClassDef 1} {VirtIsoCell 0} }
gui_list_set_filter -id ${Hier.1} -text {*}
gui_hier_list_init -id ${Hier.1}
gui_change_design -id ${Hier.1} -design V1
catch {gui_list_expand -id ${Hier.1} tb_stages}
catch {gui_list_expand -id ${Hier.1} tb_stages.uut_core}
catch {gui_list_select -id ${Hier.1} {tb_stages.uut_core.decode_unit}}
gui_view_scroll -id ${Hier.1} -vertical -set 84
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {tb_stages.uut_core.decode_unit}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 84
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Hier 'Hier.2'
gui_show_window -window ${Hier.2}
gui_list_set_filter -id ${Hier.2} -list { {Package 1} {All 0} {Process 1} {VirtPowSwitch 0} {UnnamedProcess 1} {UDP 0} {Function 0} {Block 1} {SrsnAndSpaCell 0} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {LeafVhdCell 1} {$unit 1} {NamedBlock 0} {Task 0} {VlgPackage 0} {ClassDef 1} {VirtIsoCell 0} }
gui_list_set_filter -id ${Hier.2} -text {*}
gui_hier_list_init -id ${Hier.2}
gui_change_design -id ${Hier.2} -design V1
gui_view_scroll -id ${Hier.2} -vertical -set 0
gui_view_scroll -id ${Hier.2} -horizontal -set 0

# Data 'Data.2'
gui_list_set_filter -id ${Data.2} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.2} -text {*}
gui_list_show_data -id ${Data.2} {tb_stages.uut_core.decode_unit}
gui_view_scroll -id ${Data.2} -vertical -set 0
gui_view_scroll -id ${Data.2} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 84
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active tb_stages tb_stages.sv
gui_view_scroll -id ${Source.1} -vertical -set 168
gui_src_set_reusable -id ${Source.1}

# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_create -id ${Wave.1} M1 692000
gui_marker_select -id ${Wave.1} {  M1 }
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 0 633546
gui_list_add_group -id ${Wave.1} -after {New Group} {OffCore}
gui_list_add_group -id ${Wave.1} -after {New Group} {Core}
gui_list_add_group -id ${Wave.1}  -after Core {Core|decode_unit}
gui_list_add_group -id ${Wave.1} -after Core|decode_unit {Core|uut_core}
gui_list_add_group -id ${Wave.1} -after Core|uut_core {Core|fetch_unit}
gui_list_add_group -id ${Wave.1} -after Core|fetch_unit {Core|idm_unit}
gui_list_collapse -id ${Wave.1} OffCore
gui_list_collapse -id ${Wave.1} Core|uut_core
gui_list_collapse -id ${Wave.1} Core|fetch_unit
gui_list_collapse -id ${Wave.1} Core|idm_unit
gui_list_expand -id ${Wave.1} tb_stages.uut_core.decode_unit.rr_outs_i
gui_list_select -id ${Wave.1} {tb_stages.uut_core.decode_unit.decode_gp }
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
gui_list_set_insertion_bar  -id ${Wave.1} -group Core  -position in

gui_marker_move -id ${Wave.1} {C1} 2229440
gui_view_scroll -id ${Wave.1} -vertical -set 50
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

