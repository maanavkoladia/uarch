# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Wed Apr 22 01:49:51 2026
# Designs open: 1
#   V1: vcdplus.vpd
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: tb_stages
#   Wave.1: 786 signals
#   Group count = 36
#   Group uut_AllAtOnce signal count = 9
#   Group uut_AllAtOnce_1 signal count = 9
#   Group Core signal count = 39
#   Group Mem_System signal count = 26
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
gui_show_window -window ${TopLevel.1} -show_state normal -rect {{253 83} {1969 986}}

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
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 437]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 437
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 436} {height 631} {dock_state left} {dock_on_new_line true} {child_hier_colhier 335} {child_hier_coltype 107} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 502]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 502
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 517
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 501} {height 631} {dock_state left} {dock_on_new_line true} {child_data_colvariable 279} {child_data_colvalue 57} {child_data_coltype 171} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 175]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 1313
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 175
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 1716} {height 174} {dock_state bottom} {dock_on_new_line true}}
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
gui_show_window -window ${TopLevel.2} -show_state maximized -rect {{345 101} {2264 1116}}

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
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 557} {child_wave_right 1357} {child_wave_colname 361} {child_wave_colvalue 192} {child_wave_col1 0} {child_wave_col2 1}}

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
gui_load_child_values {tb_stages.uut_AllAtOnce}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.rr_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.write_back_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.evictionBuf_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.fetch_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.idm_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit}


set _session_group_107 uut_AllAtOnce
gui_sg_create "$_session_group_107"
set uut_AllAtOnce "$_session_group_107"

gui_sg_addsignal -group "$_session_group_107" { {tb_stages.uut_AllAtOnce.$unit} tb_stages.uut_AllAtOnce.clk tb_stages.uut_AllAtOnce.rst tb_stages.uut_AllAtOnce.icache2core tb_stages.uut_AllAtOnce.core2icache tb_stages.uut_AllAtOnce.stq2dcache tb_stages.uut_AllAtOnce.core2dcache tb_stages.uut_AllAtOnce.dcache2core tb_stages.uut_AllAtOnce.dma2core }

set _session_group_108 uut_AllAtOnce_1
gui_sg_create "$_session_group_108"
set uut_AllAtOnce_1 "$_session_group_108"

gui_sg_addsignal -group "$_session_group_108" { tb_stages.uut_AllAtOnce.stq2dcache tb_stages.uut_AllAtOnce.icache2core tb_stages.uut_AllAtOnce.core2dcache tb_stages.uut_AllAtOnce.clk tb_stages.uut_AllAtOnce.core2icache tb_stages.uut_AllAtOnce.dma2core tb_stages.uut_AllAtOnce.dcache2core {tb_stages.uut_AllAtOnce.$unit} tb_stages.uut_AllAtOnce.rst }

set _session_group_109 Core
gui_sg_create "$_session_group_109"
set Core "$_session_group_109"

gui_sg_addsignal -group "$_session_group_109" { {tb_stages.uut_AllAtOnce.core_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.clk tb_stages.uut_AllAtOnce.core_unit.rst tb_stages.uut_AllAtOnce.core_unit.ICacheIn_i tb_stages.uut_AllAtOnce.core_unit.out2ICache_o tb_stages.uut_AllAtOnce.core_unit.DCacheIn_i tb_stages.uut_AllAtOnce.core_unit.out2DCache_o tb_stages.uut_AllAtOnce.core_unit.inFromDMA_i tb_stages.uut_AllAtOnce.core_unit.idm_outputs tb_stages.uut_AllAtOnce.core_unit.fetch_outputs tb_stages.uut_AllAtOnce.core_unit.decode_outputs tb_stages.uut_AllAtOnce.core_unit.rr_outputs tb_stages.uut_AllAtOnce.core_unit.dc_outputs tb_stages.uut_AllAtOnce.core_unit.mem_outputs tb_stages.uut_AllAtOnce.core_unit.exe_outputs tb_stages.uut_AllAtOnce.core_unit.wb_outputs tb_stages.uut_AllAtOnce.core_unit.rr_latches tb_stages.uut_AllAtOnce.core_unit.rr_latches_next tb_stages.uut_AllAtOnce.core_unit.dc_latches tb_stages.uut_AllAtOnce.core_unit.dc_latches_next tb_stages.uut_AllAtOnce.core_unit.mem_latches tb_stages.uut_AllAtOnce.core_unit.mem_latches_next tb_stages.uut_AllAtOnce.core_unit.exe_latches tb_stages.uut_AllAtOnce.core_unit.exe_latches_next tb_stages.uut_AllAtOnce.core_unit.wb_latches tb_stages.uut_AllAtOnce.core_unit.wb_latches_next }

set _session_group_110 $_session_group_109|
append _session_group_110 write_back_unit
gui_sg_create "$_session_group_110"
set Core|write_back_unit "$_session_group_110"

gui_sg_addsignal -group "$_session_group_110" { {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.write_back_unit.clk tb_stages.uut_AllAtOnce.core_unit.write_back_unit.rst tb_stages.uut_AllAtOnce.core_unit.write_back_unit.write_success tb_stages.uut_AllAtOnce.core_unit.write_back_unit.write_success_mio tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stall_flop tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stall_flop_next tb_stages.uut_AllAtOnce.core_unit.write_back_unit.mio_push_fail tb_stages.uut_AllAtOnce.core_unit.write_back_unit.wb_latches tb_stages.uut_AllAtOnce.core_unit.write_back_unit.outputs tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stq_info tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stq_outputs tb_stages.uut_AllAtOnce.core_unit.write_back_unit.mio_q_input tb_stages.uut_AllAtOnce.core_unit.write_back_unit.reg_wb_logic_outs tb_stages.uut_AllAtOnce.core_unit.write_back_unit.dc_dep tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stq_heads tb_stages.uut_AllAtOnce.core_unit.write_back_unit.mio_q_output }

gui_sg_move "$_session_group_110" -after "$_session_group_109" -pos 12 

set _session_group_111 $_session_group_109|
append _session_group_111 wb_latches_unit
gui_sg_create "$_session_group_111"
set Core|wb_latches_unit "$_session_group_111"

gui_sg_addsignal -group "$_session_group_111" { {tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.rst tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.write_enable_i tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.latches }

gui_sg_move "$_session_group_111" -after "$_session_group_109" -pos 11 

set _session_group_112 $_session_group_109|
append _session_group_112 execute_unit
gui_sg_create "$_session_group_112"
set Core|execute_unit "$_session_group_112"

gui_sg_addsignal -group "$_session_group_112" { {tb_stages.uut_AllAtOnce.core_unit.execute_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.clk tb_stages.uut_AllAtOnce.core_unit.execute_unit.rst tb_stages.uut_AllAtOnce.core_unit.execute_unit.clr_ZF_sb tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_stage_we_valid_unit_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_stage_next_vaild_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.sr_data_size_vec tb_stages.uut_AllAtOnce.core_unit.execute_unit.flags_reg tb_stages.uut_AllAtOnce.core_unit.execute_unit.sr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.dr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.res_buf_next tb_stages.uut_AllAtOnce.core_unit.execute_unit.latches_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_outs_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_latches_next_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.outs_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.branch_resolution_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.next_wb_cs }

gui_sg_move "$_session_group_112" -after "$_session_group_109" -pos 10 

set _session_group_113 $_session_group_112|
append _session_group_113 u_push_op
gui_sg_create "$_session_group_113"
set Core|execute_unit|u_push_op "$_session_group_113"

gui_sg_addsignal -group "$_session_group_113" { {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.value tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.sp tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.data_size_vec tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.sr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.num_bytes }

gui_sg_move "$_session_group_113" -after "$_session_group_112" -pos 16 

set _session_group_114 $_session_group_112|
append _session_group_114 u_cmpxchg_op
gui_sg_create "$_session_group_114"
set Core|execute_unit|u_cmpxchg_op "$_session_group_114"

gui_sg_addsignal -group "$_session_group_114" { {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.EAX tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.rm tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.r tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.sr_data_size_vec tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.EAX_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.next_dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.rm_low tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.rm_upper tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.next_EAX tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.r_low tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.r_upper }

gui_sg_move "$_session_group_114" -after "$_session_group_112" -pos 10 

set _session_group_115 $_session_group_112|
append _session_group_115 u_alu_input_sel
gui_sg_create "$_session_group_115"
set Core|execute_unit|u_alu_input_sel "$_session_group_115"

gui_sg_addsignal -group "$_session_group_115" { {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.ld_addr_0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.imm64 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.sr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.dr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.EAX tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.NEIP tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.EIP tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.flags tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.alu_inputA_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.alu_inputB_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.shift_sr_down tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.shift_sr_up tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.br_input_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.srA_64 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.srB_64 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.br_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.res_buf_out tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.res_buf_offset }

gui_sg_move "$_session_group_115" -after "$_session_group_112" -pos 9 

set _session_group_116 $_session_group_109|
append _session_group_116 exe_latches_unit
gui_sg_create "$_session_group_116"
set Core|exe_latches_unit "$_session_group_116"

gui_sg_addsignal -group "$_session_group_116" { {tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.rst tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.write_enable_i tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.flush tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches }

gui_sg_move "$_session_group_116" -after "$_session_group_109" -pos 9 

set _session_group_117 $_session_group_109|
append _session_group_117 mem_unit
gui_sg_create "$_session_group_117"
set Core|mem_unit "$_session_group_117"

gui_sg_addsignal -group "$_session_group_117" { {tb_stages.uut_AllAtOnce.core_unit.mem_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.mem_unit.clk tb_stages.uut_AllAtOnce.core_unit.mem_unit.rst tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit tb_stages.uut_AllAtOnce.core_unit.mem_unit.cacheline tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_MIO tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_MIO tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_buf_mio_v tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_buf_mio tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_buf_v tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_buf tb_stages.uut_AllAtOnce.core_unit.mem_unit.clr_dcache_arb_latches tb_stages.uut_AllAtOnce.core_unit.mem_unit.clr_dcache_mio_latch tb_stages.uut_AllAtOnce.core_unit.mem_unit.ld_buf tb_stages.uut_AllAtOnce.core_unit.mem_unit.C0 tb_stages.uut_AllAtOnce.core_unit.mem_unit.up_buf tb_stages.uut_AllAtOnce.core_unit.mem_unit.low_buf tb_stages.uut_AllAtOnce.core_unit.mem_unit.miss_stall tb_stages.uut_AllAtOnce.core_unit.mem_unit.exe_stage_we_valid_unit_o tb_stages.uut_AllAtOnce.core_unit.mem_unit.exe_stage_next_vaild_o tb_stages.uut_AllAtOnce.core_unit.mem_unit.forward_valid tb_stages.uut_AllAtOnce.core_unit.mem_unit.bank_num_0 tb_stages.uut_AllAtOnce.core_unit.mem_unit.bank_num_1 tb_stages.uut_AllAtOnce.core_unit.mem_unit.rel_offset tb_stages.uut_AllAtOnce.core_unit.mem_unit.br_rel_target tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_0 tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_1 tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_mio tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_0_masked tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_1_masked tb_stages.uut_AllAtOnce.core_unit.mem_unit.latches_i tb_stages.uut_AllAtOnce.core_unit.mem_unit.exe_outs_i tb_stages.uut_AllAtOnce.core_unit.mem_unit.wb_outs_i tb_stages.uut_AllAtOnce.core_unit.mem_unit.exe_latches_next_o tb_stages.uut_AllAtOnce.core_unit.mem_unit.outs_o }

gui_sg_move "$_session_group_117" -after "$_session_group_109" -pos 8 

set _session_group_118 $_session_group_109|
append _session_group_118 mem_latches_unit
gui_sg_create "$_session_group_118"
set Core|mem_latches_unit "$_session_group_118"

gui_sg_addsignal -group "$_session_group_118" { {tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.rst tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.write_enable_i tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.flush tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.farFlush tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.latches }

gui_sg_move "$_session_group_118" -after "$_session_group_109" -pos 7 

set _session_group_119 $_session_group_109|
append _session_group_119 dc_unit
gui_sg_create "$_session_group_119"
set Core|dc_unit "$_session_group_119"

gui_sg_addsignal -group "$_session_group_119" { {tb_stages.uut_AllAtOnce.core_unit.dc_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_unit.clk tb_stages.uut_AllAtOnce.core_unit.dc_unit.rst tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_served_mio tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_served_0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_served_1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_stage_we_valid_unit_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_stage_next_vaild_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.in_flight_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.dep_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.arb_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.exp_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.dc_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_0_V tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_1_V tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_mio_V tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_mio tb_stages.uut_AllAtOnce.core_unit.dc_unit.shift_sr_up tb_stages.uut_AllAtOnce.core_unit.dc_unit.shift_sr_down tb_stages.uut_AllAtOnce.core_unit.dc_unit.data_size_vec tb_stages.uut_AllAtOnce.core_unit.dc_unit.sr_data_size_vec tb_stages.uut_AllAtOnce.core_unit.dc_unit.dc_ST_OP tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_ST_OP tb_stages.uut_AllAtOnce.core_unit.dc_unit.exe_ST_OP tb_stages.uut_AllAtOnce.core_unit.dc_unit.wb_ST_OP tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_exception tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_exception tb_stages.uut_AllAtOnce.core_unit.dc_unit.latches_i tb_stages.uut_AllAtOnce.core_unit.dc_unit.fetch_outs_i tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_outs_i tb_stages.uut_AllAtOnce.core_unit.dc_unit.exe_outs_i tb_stages.uut_AllAtOnce.core_unit.dc_unit.wb_outs_i tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_latches_next_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.dc_outs_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_out tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_out }

gui_sg_move "$_session_group_119" -after "$_session_group_109" -pos 6 

set _session_group_120 $_session_group_119|
append _session_group_120 ld_neuralnet_part2
gui_sg_create "$_session_group_120"
set Core|dc_unit|ld_neuralnet_part2 "$_session_group_120"

gui_sg_addsignal -group "$_session_group_120" { {tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.vaddy_start tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.seg_limit_w_datasize tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.datasize tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.write_intent tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.mem_op tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.next_page_vaddy tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.vaddy_end tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.cross_page_access tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb0_pagefault tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb0_generalprotection tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb1_pagefault tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb1_generalprotection tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.segx_gp tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.outputs tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.vaddy_start_fields tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.vaddy_end_fields tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb0_in tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb1_in tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb0_out tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb1_out }

gui_sg_move "$_session_group_120" -after "$_session_group_119" -pos 6 

set _session_group_121 $_session_group_119|
append _session_group_121 st_neuralnet_part2
gui_sg_create "$_session_group_121"
set Core|dc_unit|st_neuralnet_part2 "$_session_group_121"

gui_sg_addsignal -group "$_session_group_121" { {tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.vaddy_start tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.seg_limit_w_datasize tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.datasize tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.write_intent tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.mem_op tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.next_page_vaddy tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.vaddy_end tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.cross_page_access tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb0_pagefault tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb0_generalprotection tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb1_pagefault tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb1_generalprotection tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.segx_gp tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.outputs tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.vaddy_start_fields tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.vaddy_end_fields tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb0_in tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb1_in tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb0_out tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb1_out }

gui_sg_move "$_session_group_121" -after "$_session_group_119" -pos 5 

set _session_group_122 $_session_group_109|
append _session_group_122 dc_latches_unit
gui_sg_create "$_session_group_122"
set Core|dc_latches_unit "$_session_group_122"

gui_sg_addsignal -group "$_session_group_122" { {tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.rst tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.write_enable_i tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.flush tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.farFlush tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.latches }

gui_sg_move "$_session_group_122" -after "$_session_group_109" -pos 5 

set _session_group_123 $_session_group_109|
append _session_group_123 rr_unit
gui_sg_create "$_session_group_123"
set Core|rr_unit "$_session_group_123"

gui_sg_addsignal -group "$_session_group_123" { {tb_stages.uut_AllAtOnce.core_unit.rr_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.rr_unit.clk tb_stages.uut_AllAtOnce.core_unit.rr_unit.rst tb_stages.uut_AllAtOnce.core_unit.rr_unit.ecx_sb tb_stages.uut_AllAtOnce.core_unit.rr_unit.cs_sb tb_stages.uut_AllAtOnce.core_unit.rr_unit.depstall tb_stages.uut_AllAtOnce.core_unit.rr_unit.dc_latches_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.next_dc_valid tb_stages.uut_AllAtOnce.core_unit.rr_unit.rr_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_input_addy tb_stages.uut_AllAtOnce.core_unit.rr_unit.ld_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.seg0_limit_w_datasize tb_stages.uut_AllAtOnce.core_unit.rr_unit.next_ld_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.actual_st_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.seg1_limit_w_datasize tb_stages.uut_AllAtOnce.core_unit.rr_unit.actual_next_st_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.instructionforward tb_stages.uut_AllAtOnce.core_unit.rr_unit.RR_GP tb_stages.uut_AllAtOnce.core_unit.rr_unit.latches_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.fetch_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.decode_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.dc_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.mem_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.exe_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.wb_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.dc_latches_next tb_stages.uut_AllAtOnce.core_unit.rr_unit.outs_o tb_stages.uut_AllAtOnce.core_unit.rr_unit.latchesInUse tb_stages.uut_AllAtOnce.core_unit.rr_unit.SEGMENT_LIMITS tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_out }

gui_sg_move "$_session_group_123" -after "$_session_group_109" -pos 4 

set _session_group_124 $_session_group_123|
append _session_group_124 RegisterFile_unit
gui_sg_create "$_session_group_124"
set Core|rr_unit|RegisterFile_unit "$_session_group_124"

gui_sg_addsignal -group "$_session_group_124" { {tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.clk tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.rst tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.DR_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.SR_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.SIB_IDX_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.SIB_BASE_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR0_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR1_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR0_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR1_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR0_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR1_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.Segment0_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.Segment1_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.REGISTERS tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.outputs }

gui_sg_move "$_session_group_124" -after "$_session_group_123" -pos 4 

set _session_group_125 $_session_group_123|
append _session_group_125 reg_sb_unit
gui_sg_create "$_session_group_125"
set Core|rr_unit|reg_sb_unit "$_session_group_125"

gui_sg_addsignal -group "$_session_group_125" { {tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.clk tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.rst tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.instructionforward tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.dr_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sr_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_base_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_idx_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr0_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr0_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr1_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr1_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_sib_size tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_dr_wr tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_sr_wr tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_dr_rd tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_sr_rd tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_eax_rd tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_eax_wr tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.Segment0_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.Segment1_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.Segment1_valid tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.flush tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.farFlush tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.dep_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.ecx_sb tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.codeSeg_sb tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.depStall_Internal tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.updateSB tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_wr_to_both tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_wr_to_both tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.dr_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sr_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.seg0_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.seg1_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_base_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_idx_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.eax_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.SCORE_BOARD }

gui_sg_move "$_session_group_125" -after "$_session_group_123" -pos 3 

set _session_group_126 $_session_group_109|
append _session_group_126 rr_latches_unit
gui_sg_create "$_session_group_126"
set Core|rr_latches_unit "$_session_group_126"

gui_sg_addsignal -group "$_session_group_126" { {tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.rst tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.write_enable_i tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.flush tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.farFlush tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.latches }

gui_sg_move "$_session_group_126" -after "$_session_group_109" -pos 3 

set _session_group_127 $_session_group_109|
append _session_group_127 decode_unit
gui_sg_create "$_session_group_127"
set Core|decode_unit "$_session_group_127"

gui_sg_addsignal -group "$_session_group_127" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.clk tb_stages.uut_AllAtOnce.core_unit.decode_unit.rst tb_stages.uut_AllAtOnce.core_unit.decode_unit.PrevEIP tb_stages.uut_AllAtOnce.core_unit.decode_unit.EIP tb_stages.uut_AllAtOnce.core_unit.decode_unit.NEIP tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_length tb_stages.uut_AllAtOnce.core_unit.decode_unit.PrevLength tb_stages.uut_AllAtOnce.core_unit.decode_unit.sib_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.sib_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.disp_needed tb_stages.uut_AllAtOnce.core_unit.decode_unit.displacement tb_stages.uut_AllAtOnce.core_unit.decode_unit.disp_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.imm64 tb_stages.uut_AllAtOnce.core_unit.decode_unit.total_pf_vector tb_stages.uut_AllAtOnce.core_unit.decode_unit.invalid_inst tb_stages.uut_AllAtOnce.core_unit.decode_unit.opcode_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.modrm_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_gp tb_stages.uut_AllAtOnce.core_unit.decode_unit.flush tb_stages.uut_AllAtOnce.core_unit.decode_unit.REP_LATCH tb_stages.uut_AllAtOnce.core_unit.decode_unit.REP_CMP_LATCH tb_stages.uut_AllAtOnce.core_unit.decode_unit.REP_MOV_LATCH tb_stages.uut_AllAtOnce.core_unit.decode_unit.HALT_REG tb_stages.uut_AllAtOnce.core_unit.decode_unit.rr_latch_we_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.stall tb_stages.uut_AllAtOnce.core_unit.decode_unit.queue tb_stages.uut_AllAtOnce.core_unit.decode_unit.predicted_taken tb_stages.uut_AllAtOnce.core_unit.decode_unit.predicted_target tb_stages.uut_AllAtOnce.core_unit.decode_unit.branch_present tb_stages.uut_AllAtOnce.core_unit.decode_unit.sibbase tb_stages.uut_AllAtOnce.core_unit.decode_unit.sibidx tb_stages.uut_AllAtOnce.core_unit.decode_unit.sibscale tb_stages.uut_AllAtOnce.core_unit.decode_unit.clear_rep tb_stages.uut_AllAtOnce.core_unit.decode_unit.next_rr_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.segment0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.idm_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.fetch_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.rr_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.dc_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.mem_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.exe_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.wb_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.rr_latches_next tb_stages.uut_AllAtOnce.core_unit.decode_unit.outs_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_decode_cs tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_rr_cs tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_dc_cs tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_mem_cs tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_exe_cs tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_wb_cs tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_rr_latch tb_stages.uut_AllAtOnce.core_unit.decode_unit.br_info_for_latches tb_stages.uut_AllAtOnce.core_unit.decode_unit.rep_latch_holder }

gui_sg_move "$_session_group_127" -after "$_session_group_109" -pos 2 

set _session_group_128 $_session_group_127|
append _session_group_128 inst_processing
gui_sg_create "$_session_group_128"
set Core|decode_unit|inst_processing "$_session_group_128"

gui_sg_addsignal -group "$_session_group_128" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.clk tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.rst tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.queue tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.queue_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.EIP tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.NEIP tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.inst_length tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.sib_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.sib_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.opcode_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.modrm_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.disp tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.disp_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.disp_needed tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.imm64 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.total_pf_vector tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.invalid_inst tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.IR tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.IR_valid_vect tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_inst_length tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_imm_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_msd_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_sib_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_displacement tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_imm tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_needrm tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_disp_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_disp_needed tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_sib_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.num_pfs tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pf_vector0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pf_vector1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pf_vector2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.sext_inst_length tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.inst_length_cout tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.inst_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.true_inst_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.adder_cout tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.possible_eips tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pf0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pf1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pf2 }

gui_sg_move "$_session_group_128" -after "$_session_group_127" -pos 2 

set _session_group_129 $_session_group_128|
append _session_group_129 pfs1
gui_sg_create "$_session_group_129"
set Core|decode_unit|inst_processing|pfs1 "$_session_group_129"

gui_sg_addsignal -group "$_session_group_129" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.opcode_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.modrm_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.IR tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.IR_valid_vect tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.total_pf_vector tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.num_pfs_plusone tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.inst_length tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.msd_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.imm_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.disp_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.disp_needed tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.sib_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.needrm tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.sib_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.disp tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.imm64 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.inst_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.imm_size_fake tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.msd_size_fake tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.sib_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.imm_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.op_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.mod_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.sib_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.disp_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.disp_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.imm_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.imm_valid_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.imm_size_override }

gui_sg_move "$_session_group_129" -after "$_session_group_128" -pos 2 

set _session_group_130 $_session_group_109|
append _session_group_130 idm_unit
gui_sg_create "$_session_group_130"
set Core|idm_unit "$_session_group_130"

gui_sg_addsignal -group "$_session_group_130" { {tb_stages.uut_AllAtOnce.core_unit.idm_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.idm_unit.clk tb_stages.uut_AllAtOnce.core_unit.idm_unit.rst tb_stages.uut_AllAtOnce.core_unit.idm_unit.fetch_outs_i tb_stages.uut_AllAtOnce.core_unit.idm_unit.idm_outs_o tb_stages.uut_AllAtOnce.core_unit.idm_unit.idm }

gui_sg_move "$_session_group_130" -after "$_session_group_109" -pos 1 

set _session_group_131 $_session_group_109|
append _session_group_131 fetch_unit
gui_sg_create "$_session_group_131"
set Core|fetch_unit "$_session_group_131"

gui_sg_addsignal -group "$_session_group_131" { {tb_stages.uut_AllAtOnce.core_unit.fetch_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.fetch_unit.clk tb_stages.uut_AllAtOnce.core_unit.fetch_unit.rst tb_stages.uut_AllAtOnce.core_unit.fetch_unit.dma_int tb_stages.uut_AllAtOnce.core_unit.fetch_unit.exp_mode_jk tb_stages.uut_AllAtOnce.core_unit.fetch_unit.int_mode_jk tb_stages.uut_AllAtOnce.core_unit.fetch_unit.DMA_int_jk tb_stages.uut_AllAtOnce.core_unit.fetch_unit.SPC tb_stages.uut_AllAtOnce.core_unit.fetch_unit.f_exp tb_stages.uut_AllAtOnce.core_unit.fetch_unit.seg_xlation_out tb_stages.uut_AllAtOnce.core_unit.fetch_unit.rom_data_out tb_stages.uut_AllAtOnce.core_unit.fetch_unit.idm_ctrl_data_in tb_stages.uut_AllAtOnce.core_unit.fetch_unit.next_spc tb_stages.uut_AllAtOnce.core_unit.fetch_unit.spc_16 tb_stages.uut_AllAtOnce.core_unit.fetch_unit.br_restore_spc tb_stages.uut_AllAtOnce.core_unit.fetch_unit.br_target tb_stages.uut_AllAtOnce.core_unit.fetch_unit.spc_2_IDM_CTRL tb_stages.uut_AllAtOnce.core_unit.fetch_unit.en_icache tb_stages.uut_AllAtOnce.core_unit.fetch_unit.icache_info_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.idm_info_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.decode_outs_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.rr_outs_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.dc_outs_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.mem_outs_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.exe_outs_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.wb_outs_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.outs_o tb_stages.uut_AllAtOnce.core_unit.fetch_unit.predictor_inputs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.tlb_inputs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.btb_outs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.spc_sel_logic_outs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.predictor_outs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.idm_ctrl_logic_outs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.idm_invalidate_logic_outs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.tlb_outs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.exp_set_logic_outs }

set _session_group_132 Mem_System
gui_sg_create "$_session_group_132"
set Mem_System "$_session_group_132"

gui_sg_addsignal -group "$_session_group_132" { {tb_stages.uut_AllAtOnce.mem_sys_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.addressBus tb_stages.uut_AllAtOnce.mem_sys_unit.core2icache_i tb_stages.uut_AllAtOnce.mem_sys_unit.icache2core_o tb_stages.uut_AllAtOnce.mem_sys_unit.core2dcache_i tb_stages.uut_AllAtOnce.mem_sys_unit.dcache2core_o tb_stages.uut_AllAtOnce.mem_sys_unit.dma2core_o tb_stages.uut_AllAtOnce.mem_sys_unit.icache_2_sched tb_stages.uut_AllAtOnce.mem_sys_unit.dte_2_icache tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_2_sched tb_stages.uut_AllAtOnce.mem_sys_unit.dte_2_dcache tb_stages.uut_AllAtOnce.mem_sys_unit.mem_2_sched tb_stages.uut_AllAtOnce.mem_sys_unit.mem_2_dte tb_stages.uut_AllAtOnce.mem_sys_unit.dte_2_mem tb_stages.uut_AllAtOnce.mem_sys_unit.dma_2_sched tb_stages.uut_AllAtOnce.mem_sys_unit.dte_2_dma tb_stages.uut_AllAtOnce.mem_sys_unit.dte_2_ddr5 }

set _session_group_133 $_session_group_132|
append _session_group_133 bus_arbitration_unit
gui_sg_create "$_session_group_133"
set Mem_System|bus_arbitration_unit "$_session_group_133"

gui_sg_addsignal -group "$_session_group_133" { {tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.sch_best_pick tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.sch_best_pick_bk_id tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.iCache_2_Sch_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_out_2_icache_o tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dCache_2_Sch_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_out_2_dcache_o tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.mem_2_Sch_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.mem_2_dte_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_2_mem_o tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dma_2_sch_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_2_dma_o tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_2_ddr5_o }

gui_sg_move "$_session_group_133" -after "$_session_group_132" -pos 5 

set _session_group_134 $_session_group_132|
append _session_group_134 dcache_unit
gui_sg_create "$_session_group_134"
set Mem_System|dcache_unit "$_session_group_134"

gui_sg_addsignal -group "$_session_group_134" { {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.address_bus tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.hitVec tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.arb_st_override_Out tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.arb_req_served_0_out tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.arb_req_served_1_out tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.inFromCore_i tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.out2Core_o tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.inFromDTE_i tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.out2Sch_o tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.blockOutputs tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.req_2_blocks tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.mio_block_outputs }

gui_sg_move "$_session_group_134" -after "$_session_group_132" -pos 4 

set _session_group_135 $_session_group_134|
append _session_group_135 {g_dcache_block[0].block}
gui_sg_create "$_session_group_135"
set {Mem_System|dcache_unit|g_dcache_block[0].block} "$_session_group_135"

gui_sg_addsignal -group "$_session_group_135" { {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.$unit} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.clk_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.rst_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.mem_Valid_FromDte_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.evictionBuf_clr_FromDTE_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.evictionBuf_setCommiting_FromDTE_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.permissionToDriveDataBus_evictionBuf} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.permissionToDriveAddrBus_Ld} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.permissionToDriveAddrBus_eb} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.st_override_for_sch_req} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.dataBus} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.address_bus} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.block_busy} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.fatal_coming} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.makeBlockReq} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.eb_blockingVCache} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.eb_V} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.eb_curr_commiting} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.eb_blocking_Bank} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.address_bus_fake} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.startingOffset} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.perm2DriveDataBus_bar} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.eb_lineOut_vec} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.block_req_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.outputs_o} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.dcache_bank_outputs} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_outputs} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.eb_outputs} }

gui_sg_move "$_session_group_135" -after "$_session_group_134" -pos 4 

set _session_group_136 $_session_group_135|
append _session_group_136 evictionBuf_unit
gui_sg_create "$_session_group_136"
set {Mem_System|dcache_unit|g_dcache_block[0].block|evictionBuf_unit} "$_session_group_136"

gui_sg_addsignal -group "$_session_group_136" { {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.evictionBuf_unit.$unit} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.evictionBuf_unit.clk_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.evictionBuf_unit.rst_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.evictionBuf_unit.eb_clr_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.evictionBuf_unit.set_commiting} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.evictionBuf_unit.validReq} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.evictionBuf_unit.hit} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.evictionBuf_unit.blockReq_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.evictionBuf_unit.vcache_outputs_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.evictionBuf_unit.outputs_o} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.evictionBuf_unit.eb} }

gui_sg_move "$_session_group_136" -after "$_session_group_135" -pos 4 

set _session_group_137 $_session_group_135|
append _session_group_137 vcache_unit
gui_sg_create "$_session_group_137"
set {Mem_System|dcache_unit|g_dcache_block[0].block|vcache_unit} "$_session_group_137"

gui_sg_addsignal -group "$_session_group_137" { {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.$unit} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.clk} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.rst} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.block_busy_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_fsm_state} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_fsm_state_bits} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.saveReq} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.useSavedReq} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.saveIDX} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.useSavedIDX} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.currTag} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.hit} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.miss} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.hitIDX} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.evictionIDX} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.savedIDX} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.V_Cache_needs_2_evict} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.V_Cache_TagStore_CurrLine_Dirty} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_dataStore_Line} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.blockReq_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.eb_outs_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.dcache_outs_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.outputs_o} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.fsmOuts} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.savedReq} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.reqInUse} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.block_req_p_addr_fields} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_swapBuf} }

gui_sg_move "$_session_group_137" -after "$_session_group_135" -pos 5 

set _session_group_138 $_session_group_137|
append _session_group_138 vcache_tag_store_unit
gui_sg_create "$_session_group_138"
set {Mem_System|dcache_unit|g_dcache_block[0].block|vcache_unit|vcache_tag_store_unit} "$_session_group_138"

gui_sg_addsignal -group "$_session_group_138" { {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.$unit} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.clk} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.rst} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.p_addr_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.oe_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.we_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.Read_DSWAP_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.D_Cache_SwapBuf_Addr} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.D_Cache_SwapBuf_DirtyBit} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.DCache_Will_Evict_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.saveIDX} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.use_savedIDX} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.busy_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.WR_2_EB_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.Write_VSWAP_i} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.Update_LRU} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.tagOut_o} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.hit_o} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.miss_o} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.hitIDX_o} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.evictionIDX_o} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.savedIDX_o} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.currLine_Dirty_o} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.VC_Will_Need_ToEvict_o} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.clk_phase_45} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.doAccess} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.hit} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.miss} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.writeSuccess} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.hitIdx} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.hitIdx_onehot} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.savedIDX} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.savedIDX_oneHot} }
gui_sg_addsignal -group "$_session_group_138" { {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.currLRU_IDX} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.DIN_2_TagStore} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.OE_2_TagStore_idx} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.DOUT_of_TagStore_Net} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.currLine_Dirty_idx} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.tag_out_write_to_vswap_idx} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.tag_out_write_to_eb_idx} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.tag_assigned} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.WR_2_TagStore_clk} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.WR_2_TagStore_actual} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.DIN_2_TagStore_net} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.OE_2_TagStore} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.DOUT_of_TagStore} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.NUM_CELLS_NEEDED} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.CELL_WIDTH_BITS} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.tagMetaStore} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.p_addr_fields} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.DCache_SwapBuf_lineAddr_fields} }
gui_set_radix -radix {decimal} -signals {{V1:tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.NUM_CELLS_NEEDED}}
gui_set_radix -radix {twosComplement} -signals {{V1:tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.NUM_CELLS_NEEDED}}
gui_set_radix -radix {decimal} -signals {{V1:tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.CELL_WIDTH_BITS}}
gui_set_radix -radix {twosComplement} -signals {{V1:tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.CELL_WIDTH_BITS}}

gui_sg_move "$_session_group_138" -after "$_session_group_137" -pos 4 

set _session_group_139 $_session_group_132|
append _session_group_139 ddr5_unit
gui_sg_create "$_session_group_139"
set Mem_System|ddr5_unit "$_session_group_139"

gui_sg_addsignal -group "$_session_group_139" { {tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.addrBus tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.tempValue tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.powerGate tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.dataBus_fake tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.inFromDTE_i }

gui_sg_move "$_session_group_139" -after "$_session_group_132" -pos 3 

set _session_group_140 $_session_group_132|
append _session_group_140 dma_controller_unit
gui_sg_create "$_session_group_140"
set Mem_System|dma_controller_unit "$_session_group_140"

gui_sg_addsignal -group "$_session_group_140" { {tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.addrBus tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.fsmState tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.fsmState_bits tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.commiting tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.disk_ld_Buffer_V tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.disk_ld_Buffer tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.counter tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.writeBuf tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.writeBuf_addr tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.writeBuf_V tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.writeComplete tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.write2_srcAddr_req tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.write2_destAddr_req tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.write2_numBytes_req tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.write2_startWrite_req tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.addrBus_drv tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.dataBus_drv tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.driveDataBus tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.inFromDTE_i tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.out2Core_o tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.out2Sch_o tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.dma_Regs tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.fsmOuts }

gui_sg_move "$_session_group_140" -after "$_session_group_132" -pos 2 

set _session_group_141 $_session_group_132|
append _session_group_141 icache_unit
gui_sg_create "$_session_group_141"
set Mem_System|icache_unit "$_session_group_141"

gui_sg_addsignal -group "$_session_group_141" { {tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.addrBus tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.controller_fsmState tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.controller_fsmState_bits tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataLines tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_tag tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_tag_V tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_hit tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_miss tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_hit tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_miss tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_swapBuf_V_Clr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_dataLines tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.saved_pAddr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.saved_vAddr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.curr_v_addr_to_use tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.useSaved_v_Addr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.save_v_addr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.addrBus_drv tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.inFromCore_i tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.out2Core_o tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.inFromDte_i tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.out2Sch_o tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.fsmOuts tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_swapbuf tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_swapBuf }

gui_sg_move "$_session_group_141" -after "$_session_group_132" -pos 1 

set _session_group_142 $_session_group_132|
append _session_group_142 mem_unit_1
gui_sg_create "$_session_group_142"
set Mem_System|mem_unit_1 "$_session_group_142"

gui_sg_addsignal -group "$_session_group_142" { {tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.address_bus tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.data_bus tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.mem_bus tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.drive_Data_Bus tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.dataToDrive tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.inFromDte tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.out2Dte tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.out2Sch tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.controller_2_bank_Cmds tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.bank_out_2_controller }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 10003.181



# Save global setting...

# Wave/List view global setting
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
catch {gui_list_expand -id ${Hier.1} tb_stages}
catch {gui_list_expand -id ${Hier.1} tb_stages.uut_AllAtOnce}
catch {gui_list_expand -id ${Hier.1} tb_stages.uut_AllAtOnce.mem_sys_unit}
catch {gui_list_expand -id ${Hier.1} tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit}
catch {gui_list_expand -id ${Hier.1} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block}}
catch {gui_list_select -id ${Hier.1} {{tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.evictionBuf_unit}}}
gui_view_scroll -id ${Hier.1} -vertical -set 402
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.evictionBuf_unit}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 402
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active tb_stages tb_stages.sv
gui_view_scroll -id ${Source.1} -vertical -set 252
gui_src_set_reusable -id ${Source.1}

# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_create -id ${Wave.1} M1 364
gui_marker_create -id ${Wave.1} M2 9898.931
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 9947.145 10068.965
gui_list_add_group -id ${Wave.1} -after {New Group} {uut_AllAtOnce_1}
gui_list_add_group -id ${Wave.1} -after {New Group} {Core}
gui_list_add_group -id ${Wave.1}  -after Core {Core|fetch_unit}
gui_list_add_group -id ${Wave.1} -after Core|fetch_unit {Core|idm_unit}
gui_list_add_group -id ${Wave.1} -after Core|idm_unit {Core|decode_unit}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.decode_unit.clk {Core|decode_unit|inst_processing}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.clk {Core|decode_unit|inst_processing|pfs1}
gui_list_add_group -id ${Wave.1} -after Core|decode_unit {Core|rr_latches_unit}
gui_list_add_group -id ${Wave.1} -after Core|rr_latches_unit {Core|rr_unit}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.rr_unit.rst {Core|rr_unit|reg_sb_unit}
gui_list_add_group -id ${Wave.1} -after Core|rr_unit|reg_sb_unit {Core|rr_unit|RegisterFile_unit}
gui_list_add_group -id ${Wave.1} -after Core|rr_unit {Core|dc_latches_unit}
gui_list_add_group -id ${Wave.1} -after Core|dc_latches_unit {Core|dc_unit}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_served_0 {Core|dc_unit|st_neuralnet_part2}
gui_list_add_group -id ${Wave.1} -after Core|dc_unit|st_neuralnet_part2 {Core|dc_unit|ld_neuralnet_part2}
gui_list_add_group -id ${Wave.1} -after Core|dc_unit {Core|mem_latches_unit}
gui_list_add_group -id ${Wave.1} -after Core|mem_latches_unit {Core|mem_unit}
gui_list_add_group -id ${Wave.1} -after Core|mem_unit {Core|exe_latches_unit}
gui_list_add_group -id ${Wave.1} -after Core|exe_latches_unit {Core|execute_unit}
gui_list_add_group -id ${Wave.1} -after {{tb_stages.uut_AllAtOnce.core_unit.execute_unit.sr_data_size_vec[3:0]}} {Core|execute_unit|u_alu_input_sel}
gui_list_add_group -id ${Wave.1} -after Core|execute_unit|u_alu_input_sel {Core|execute_unit|u_cmpxchg_op}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.execute_unit.latches_i {Core|execute_unit|u_push_op}
gui_list_add_group -id ${Wave.1} -after Core|execute_unit {Core|wb_latches_unit}
gui_list_add_group -id ${Wave.1} -after Core|wb_latches_unit {Core|write_back_unit}
gui_list_add_group -id ${Wave.1} -after {New Group} {Mem_System}
gui_list_add_group -id ${Wave.1}  -after Mem_System {Mem_System|mem_unit_1}
gui_list_add_group -id ${Wave.1} -after Mem_System|mem_unit_1 {Mem_System|icache_unit}
gui_list_add_group -id ${Wave.1} -after Mem_System|icache_unit {Mem_System|dma_controller_unit}
gui_list_add_group -id ${Wave.1} -after Mem_System|dma_controller_unit {Mem_System|ddr5_unit}
gui_list_add_group -id ${Wave.1} -after Mem_System|ddr5_unit {Mem_System|dcache_unit}
gui_list_add_group -id ${Wave.1} -after {{tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.dataBus[31:0]}} {{Mem_System|dcache_unit|g_dcache_block[0].block}}
gui_list_add_group -id ${Wave.1} -after {{tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.mem_Valid_FromDte_i}} {{Mem_System|dcache_unit|g_dcache_block[0].block|evictionBuf_unit}}
gui_list_add_group -id ${Wave.1} -after {{Mem_System|dcache_unit|g_dcache_block[0].block|evictionBuf_unit}} {{Mem_System|dcache_unit|g_dcache_block[0].block|vcache_unit}}
gui_list_add_group -id ${Wave.1} -after {{tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.g_dcache_block[0].block.vcache_unit.block_busy_i}} {{Mem_System|dcache_unit|g_dcache_block[0].block|vcache_unit|vcache_tag_store_unit}}
gui_list_add_group -id ${Wave.1} -after Mem_System|dcache_unit {Mem_System|bus_arbitration_unit}
gui_list_collapse -id ${Wave.1} uut_AllAtOnce_1
gui_list_collapse -id ${Wave.1} Core
gui_list_collapse -id ${Wave.1} Mem_System|icache_unit
gui_list_collapse -id ${Wave.1} Mem_System|dma_controller_unit
gui_list_collapse -id ${Wave.1} Mem_System|ddr5_unit
gui_list_collapse -id ${Wave.1} Mem_System|dcache_unit
gui_list_collapse -id ${Wave.1} Mem_System|bus_arbitration_unit
gui_list_expand -id ${Wave.1} tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.inFromDte
gui_list_select -id ${Wave.1} {tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.inFromDte.ld_req }
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
gui_list_set_insertion_bar  -id ${Wave.1} -group {Mem_System|dcache_unit|g_dcache_block[0].block}  -position in

gui_marker_move -id ${Wave.1} {C1} 10003.181
gui_view_scroll -id ${Wave.1} -vertical -set 0
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

