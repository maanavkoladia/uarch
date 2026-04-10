# Begin_DVE_Session_Save_Info
# DVE full session
<<<<<<< HEAD
# Saved on Thu Apr 9 02:35:33 2026
=======
# Saved on Thu Apr 9 15:07:29 2026
>>>>>>> 092ccefeba40bd12f97cd06dfb88c904c12ccb03
# Designs open: 1
#   V1: vcdplus.vpd
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
<<<<<<< HEAD
#   Source.1: tb_stages.uut_core.dc_unit
#   Wave.1: 949 signals
#   Group count = 45
#   Group busArb signal count = 3
#   Group dcache signal count = 7
#   Group icache signal count = 5
#   Group core signal count = 9
#   Group Group1 signal count = 1
#   Group execute_unit signal count = 143
=======
#   Source.1: tb_stages
#   Wave.1: 856 signals
#   Group count = 38
#   Group busArb signal count = 3
#   Group dcache signal count = 7
#   Group icache signal count = 5
#   Group core signal count = 14
#   Group Group1 signal count = 0
>>>>>>> 092ccefeba40bd12f97cd06dfb88c904c12ccb03
# End_DVE_Session_Save_Info

# DVE version: T-2022.06_Full64
# DVE build date: May 31 2022 20:53:03


#<Session mode="Full" path="/misc/scratch/he3837/UARCH/uarch/design/EverythingEverywhereAllAtOnce/tests/Stages/session.vcdplus.vpd.tcl" type="Debug">

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
<<<<<<< HEAD
gui_show_window -window ${TopLevel.1} -show_state normal -rect {{0 23} {1279 671}}
=======
gui_show_window -window ${TopLevel.1} -show_state normal -rect {{732 67} {2071 1010}}
>>>>>>> 092ccefeba40bd12f97cd06dfb88c904c12ccb03

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
<<<<<<< HEAD
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 596]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 596
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 595} {height 549} {dock_state left} {dock_on_new_line true} {child_hier_colhier 407} {child_hier_coltype 179} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 334]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 334
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 693
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 333} {height 549} {dock_state left} {dock_on_new_line true} {child_data_colvariable 352} {child_data_colvalue 161} {child_data_coltype 159} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
=======
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 441]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 441
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 440} {height 635} {dock_state left} {dock_on_new_line true} {child_hier_colhier 335} {child_hier_coltype 107} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 506]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 506
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 728
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 505} {height 635} {dock_state left} {dock_on_new_line true} {child_data_colvariable 279} {child_data_colvalue 57} {child_data_coltype 171} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 179]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 689
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 179
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 1339} {height 178} {dock_state bottom} {dock_on_new_line true}}
>>>>>>> 092ccefeba40bd12f97cd06dfb88c904c12ccb03
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
<<<<<<< HEAD
gui_show_window -window ${TopLevel.2} -show_state maximized -rect {{1536 23} {3071 815}}
=======
gui_show_window -window ${TopLevel.2} -show_state maximized -rect {{477 64} {2396 1079}}
>>>>>>> 092ccefeba40bd12f97cd06dfb88c904c12ccb03

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
<<<<<<< HEAD
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 727} {child_wave_right 803} {child_wave_colname 249} {child_wave_colvalue 474} {child_wave_col1 0} {child_wave_col2 1}}
=======
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 552} {child_wave_right 1362} {child_wave_colname 326} {child_wave_colvalue 222} {child_wave_col1 0} {child_wave_col2 1}}
>>>>>>> 092ccefeba40bd12f97cd06dfb88c904c12ccb03

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
gui_load_child_values {tb_stages.uut_dcache.mio_block_unit}
gui_load_child_values {tb_stages.uut_core.wb_latches_unit}
<<<<<<< HEAD
gui_load_child_values {tb_stages.uut_core.dc_unit.ld_neuralnet_part2}
gui_load_child_values {tb_stages.uut_core.write_back_unit.gen_st_q[0].stq_inst}
gui_load_child_values {tb_stages.uut_core.fetch_unit.exp_set_logic}
gui_load_child_values {tb_stages.uut_icache.icache_contrller_fsm}
gui_load_child_values {tb_stages.uut_core.write_back_unit.st_q_logic}
gui_load_child_values {tb_stages.uut_core.write_back_unit.mio_q_inst}
gui_load_child_values {tb_stages.uut_core.write_back_unit.gen_st_q[1].stq_inst}
=======
gui_load_child_values {tb_stages.uut_icache.icache_contrller_fsm}
>>>>>>> 092ccefeba40bd12f97cd06dfb88c904c12ccb03
gui_load_child_values {tb_stages.uut_core.write_back_unit.reg_wb}
gui_load_child_values {tb_stages.uut_dcache.g_dcache_block[1].block}
gui_load_child_values {tb_stages.uut_core}
gui_load_child_values {tb_stages.uut_core.dc_unit.mem_valid_unit}
gui_load_child_values {tb_stages.uut4_busArb.scheduler_unit}
gui_load_child_values {tb_stages.uut_core.mem_latches_unit}
gui_load_child_values {tb_stages.uut_core.write_back_unit.gen_st_q[2].stq_inst}
gui_load_child_values {tb_stages.uut4_busArb}
gui_load_child_values {tb_stages.uut_icache.i_vcache_unit}
gui_load_child_values {tb_stages.uut_dcache}
gui_load_child_values {tb_stages.uut_core.dc_latches_unit}
gui_load_child_values {tb_stages.uut_core.write_back_unit.gen_st_q[3].stq_inst}
gui_load_child_values {tb_stages.uut_core.rr_latches_unit}
gui_load_child_values {tb_stages.uut_dcache.g_dcache_block[3].block}
gui_load_child_values {tb_stages.uut_core.execute_unit}
gui_load_child_values {tb_stages.uut_core.write_back_unit}
gui_load_child_values {tb_stages.uut_dcache.g_dcache_block[0].block}
<<<<<<< HEAD
gui_load_child_values {tb_stages.uut_core.rr_unit.reg_sb_unit}
=======
gui_load_child_values {tb_stages.uut_core.mem_unit}
>>>>>>> 092ccefeba40bd12f97cd06dfb88c904c12ccb03
gui_load_child_values {tb_stages.uut_icache.icache_dataStore_unit}
gui_load_child_values {tb_stages.uut_icache}
gui_load_child_values {tb_stages.uut_core.fetch_unit}
gui_load_child_values {tb_stages.uut_core.idm_unit}
gui_load_child_values {tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen}
gui_load_child_values {tb_stages.uut_icache.icache_TagStore_unit}
gui_load_child_values {tb_stages.uut_core.exe_latches_unit}
gui_load_child_values {tb_stages.uut_core.decode_unit}
gui_load_child_values {tb_stages.uut_core.rr_unit.RegisterFile_unit}
<<<<<<< HEAD
gui_load_child_values {tb_stages.uut_core.write_back_unit.st_q_mio_logic}
gui_load_child_values {tb_stages.uut_dcache.g_dcache_block[2].block}
=======
>>>>>>> 092ccefeba40bd12f97cd06dfb88c904c12ccb03
gui_load_child_values {tb_stages.uut_dcache.dcache_arbitration}
gui_load_child_values {tb_stages.uut_dcache.g_dcache_block[2].block}
gui_load_child_values {tb_stages.uut4_busArb.dte_unit}


<<<<<<< HEAD
set _session_group_218 busArb
gui_sg_create "$_session_group_218"
set busArb "$_session_group_218"

gui_sg_addsignal -group "$_session_group_218" { }

set _session_group_219 $_session_group_218|
append _session_group_219 uut4_busArb
gui_sg_create "$_session_group_219"
set busArb|uut4_busArb "$_session_group_219"

gui_sg_addsignal -group "$_session_group_219" { {tb_stages.uut4_busArb.$unit} tb_stages.uut4_busArb.clk tb_stages.uut4_busArb.rst tb_stages.uut4_busArb.sch_best_pick tb_stages.uut4_busArb.sch_best_pick_bk_id tb_stages.uut4_busArb.iCache_2_Sch_i tb_stages.uut4_busArb.dte_out_2_icache_o tb_stages.uut4_busArb.dCache_2_Sch_i tb_stages.uut4_busArb.dte_out_2_dcache_o tb_stages.uut4_busArb.mem_2_Sch_i tb_stages.uut4_busArb.mem_2_dte_i tb_stages.uut4_busArb.dte_2_mem_o tb_stages.uut4_busArb.dma_2_sch_i tb_stages.uut4_busArb.dte_2_dma_o tb_stages.uut4_busArb.dte_2_ddr5_o }

gui_sg_move "$_session_group_219" -after "$_session_group_218" -pos 2 

set _session_group_220 $_session_group_218|
append _session_group_220 scheduler_unit
gui_sg_create "$_session_group_220"
set busArb|scheduler_unit "$_session_group_220"

gui_sg_addsignal -group "$_session_group_220" { {tb_stages.uut4_busArb.scheduler_unit.$unit} tb_stages.uut4_busArb.scheduler_unit.clk tb_stages.uut4_busArb.scheduler_unit.rst tb_stages.uut4_busArb.scheduler_unit.bestPick_o tb_stages.uut4_busArb.scheduler_unit.bestPick_bk_id_o tb_stages.uut4_busArb.scheduler_unit.dcache_Best_Pick tb_stages.uut4_busArb.scheduler_unit.dcache_Best_Pick_BK_ID tb_stages.uut4_busArb.scheduler_unit.dma_req tb_stages.uut4_busArb.scheduler_unit.IC_MIO_Pick tb_stages.uut4_busArb.scheduler_unit.IC_MIO_DMA_PICK tb_stages.uut4_busArb.scheduler_unit.bestPick tb_stages.uut4_busArb.scheduler_unit.iCache_2_Sch_i tb_stages.uut4_busArb.scheduler_unit.dCache_2_Sch_i tb_stages.uut4_busArb.scheduler_unit.mem_2_Sch_i tb_stages.uut4_busArb.scheduler_unit.dma_2_sch_i tb_stages.uut4_busArb.scheduler_unit.sch_latches }

set _session_group_221 $_session_group_218|
append _session_group_221 dte_unit
gui_sg_create "$_session_group_221"
set busArb|dte_unit "$_session_group_221"

gui_sg_addsignal -group "$_session_group_221" { {tb_stages.uut4_busArb.dte_unit.$unit} tb_stages.uut4_busArb.dte_unit.clk tb_stages.uut4_busArb.dte_unit.rst tb_stages.uut4_busArb.dte_unit.bestPick_i tb_stages.uut4_busArb.dte_unit.bestPick_bk_id_i tb_stages.uut4_busArb.dte_unit.dte_mem_2_icache_fsm_state tb_stages.uut4_busArb.dte_unit.dte_mem_2_icache_fsm_state_bits tb_stages.uut4_busArb.dte_unit.dte_mem_2_dcache_fsm_state tb_stages.uut4_busArb.dte_unit.dte_dcache_2_mem_fsm_state tb_stages.uut4_busArb.dte_unit.dte_ddr5_2_core_fsm_state tb_stages.uut4_busArb.dte_unit.dte_ddr5_2_core_fsm_state_bits tb_stages.uut4_busArb.dte_unit.dte_core_2_ddr5_fsm_state tb_stages.uut4_busArb.dte_unit.dte_core_2_ddr5_fsm_state_bits tb_stages.uut4_busArb.dte_unit.dte_core_2_dma_fsm_state tb_stages.uut4_busArb.dte_unit.dte_core_2_dma_fsm_state_bits tb_stages.uut4_busArb.dte_unit.dte_dma_2_mem_fsm_state tb_stages.uut4_busArb.dte_unit.dte_dma_2_mem_fsm_state_bits tb_stages.uut4_busArb.dte_unit.ddr5_2_core_fsmout_busy tb_stages.uut4_busArb.dte_unit.core_2_ddr5_fsmout_busy tb_stages.uut4_busArb.dte_unit.core_2_dma_fsmout_busy tb_stages.uut4_busArb.dte_unit.dma_2_mem_fsmout_busy tb_stages.uut4_busArb.dte_unit.mem_2_icache_fsmout_busy tb_stages.uut4_busArb.dte_unit.mem_2_dcache_fsmout_busy_per tb_stages.uut4_busArb.dte_unit.mem_2_dcache_fsmout_busy tb_stages.uut4_busArb.dte_unit.dcache_2_mem_fsmout_busy_per tb_stages.uut4_busArb.dte_unit.dcache_2_mem_fsmout_busy tb_stages.uut4_busArb.dte_unit.DTE_Busy tb_stages.uut4_busArb.dte_unit.mem_2_icache_ld_req_fsmOut tb_stages.uut4_busArb.dte_unit.mem_2_dcache_ld_req_fsmOut tb_stages.uut4_busArb.dte_unit.mem_2_icache_drv_db_fsmOut tb_stages.uut4_busArb.dte_unit.mem_2_dcache_drv_db_fsmOut tb_stages.uut4_busArb.dte_unit.dcache_2_mem_st_req_fsmOut tb_stages.uut4_busArb.dte_unit.dma_2_mem_st_req_fsmOut tb_stages.uut4_busArb.dte_unit.ddr5_2_core_reqServed_fsmOut tb_stages.uut4_busArb.dte_unit.core_2_ddr5_reqServed_fsmOut tb_stages.uut4_busArb.dte_unit.core_2_dma_reqServed_fsmOut tb_stages.uut4_busArb.dte_unit.ddr5_2_core_driveAddrBus_fsmOut tb_stages.uut4_busArb.dte_unit.core_2_ddr5_driveAddrBus_fsmOut tb_stages.uut4_busArb.dte_unit.core_2_dma_driveAddrBus_fsmOut tb_stages.uut4_busArb.dte_unit.core_2_ddr5_drvDB_fsmOut tb_stages.uut4_busArb.dte_unit.core_2_dma_drvDB_fsmOut tb_stages.uut4_busArb.dte_unit.mem_2_icache_req_hit tb_stages.uut4_busArb.dte_unit.mem_2_dcache_req_hit tb_stages.uut4_busArb.dte_unit.mem_2_dcache_bk_hit tb_stages.uut4_busArb.dte_unit.dcache_2_mem_req_hit tb_stages.uut4_busArb.dte_unit.dcache_2_mem_bk_hit tb_stages.uut4_busArb.dte_unit.ddr5_2_core_req_hit tb_stages.uut4_busArb.dte_unit.core_2_ddr5_req_hit tb_stages.uut4_busArb.dte_unit.core_2_dma_req_hit tb_stages.uut4_busArb.dte_unit.dma_2_mem_req_hit tb_stages.uut4_busArb.dte_unit.dte_mem_2_dcache_fsm_state_bits tb_stages.uut4_busArb.dte_unit.dte_dcache_2_mem_fsm_state_bits tb_stages.uut4_busArb.dte_unit.dte_out_2_icache_o tb_stages.uut4_busArb.dte_unit.dte_out_2_dcache_o tb_stages.uut4_busArb.dte_unit.mem_2_dte_i tb_stages.uut4_busArb.dte_unit.dte_2_mem_o tb_stages.uut4_busArb.dte_unit.dte_2_dma_o tb_stages.uut4_busArb.dte_unit.dte_2_ddr5_o }

gui_sg_move "$_session_group_221" -after "$_session_group_218" -pos 1 

set _session_group_222 dcache
gui_sg_create "$_session_group_222"
set dcache "$_session_group_222"

gui_sg_addsignal -group "$_session_group_222" { }

set _session_group_223 $_session_group_222|
append _session_group_223 {g_dcache_block[0].block}
gui_sg_create "$_session_group_223"
set {dcache|g_dcache_block[0].block} "$_session_group_223"

gui_sg_addsignal -group "$_session_group_223" { {tb_stages.uut_dcache.g_dcache_block[0].block.clk_i} {tb_stages.uut_dcache.g_dcache_block[0].block.rst_i} {tb_stages.uut_dcache.g_dcache_block[0].block.mem_Valid_FromDte_i} {tb_stages.uut_dcache.g_dcache_block[0].block.evictionBuf_clr_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[0].block.evictionBuf_setCommiting_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[0].block.permissionToDriveDataBus_evictionBuf} {tb_stages.uut_dcache.g_dcache_block[0].block.permissionToDriveAddrBus_Ld} {tb_stages.uut_dcache.g_dcache_block[0].block.permissionToDriveAddrBus_eb} {tb_stages.uut_dcache.g_dcache_block[0].block.st_override_for_sch_req} {tb_stages.uut_dcache.g_dcache_block[0].block.dataBus} {tb_stages.uut_dcache.g_dcache_block[0].block.address_bus} {tb_stages.uut_dcache.g_dcache_block[0].block.block_busy} {tb_stages.uut_dcache.g_dcache_block[0].block.makeBlockReq} {tb_stages.uut_dcache.g_dcache_block[0].block.eb_blockingVCache} {tb_stages.uut_dcache.g_dcache_block[0].block.eb_V} {tb_stages.uut_dcache.g_dcache_block[0].block.eb_curr_commiting} {tb_stages.uut_dcache.g_dcache_block[0].block.eb_blocking_Bank} {tb_stages.uut_dcache.g_dcache_block[0].block.address_bus_fake} {tb_stages.uut_dcache.g_dcache_block[0].block.startingOffset} {tb_stages.uut_dcache.g_dcache_block[0].block.dataBus_fake} {tb_stages.uut_dcache.g_dcache_block[0].block.block_req_i} {tb_stages.uut_dcache.g_dcache_block[0].block.outputs_o} {tb_stages.uut_dcache.g_dcache_block[0].block.dcache_bank_outputs} {tb_stages.uut_dcache.g_dcache_block[0].block.vcache_outputs} {tb_stages.uut_dcache.g_dcache_block[0].block.eb_outputs} }

gui_sg_move "$_session_group_223" -after "$_session_group_222" -pos 4 

set _session_group_224 $_session_group_222|
append _session_group_224 {g_dcache_block[3].block}
gui_sg_create "$_session_group_224"
set {dcache|g_dcache_block[3].block} "$_session_group_224"

gui_sg_addsignal -group "$_session_group_224" { {tb_stages.uut_dcache.g_dcache_block[3].block.clk_i} {tb_stages.uut_dcache.g_dcache_block[3].block.rst_i} {tb_stages.uut_dcache.g_dcache_block[3].block.mem_Valid_FromDte_i} {tb_stages.uut_dcache.g_dcache_block[3].block.evictionBuf_clr_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[3].block.evictionBuf_setCommiting_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[3].block.permissionToDriveDataBus_evictionBuf} {tb_stages.uut_dcache.g_dcache_block[3].block.permissionToDriveAddrBus_Ld} {tb_stages.uut_dcache.g_dcache_block[3].block.permissionToDriveAddrBus_eb} {tb_stages.uut_dcache.g_dcache_block[3].block.st_override_for_sch_req} {tb_stages.uut_dcache.g_dcache_block[3].block.dataBus} {tb_stages.uut_dcache.g_dcache_block[3].block.address_bus} {tb_stages.uut_dcache.g_dcache_block[3].block.block_busy} {tb_stages.uut_dcache.g_dcache_block[3].block.makeBlockReq} {tb_stages.uut_dcache.g_dcache_block[3].block.eb_blockingVCache} {tb_stages.uut_dcache.g_dcache_block[3].block.eb_V} {tb_stages.uut_dcache.g_dcache_block[3].block.eb_curr_commiting} {tb_stages.uut_dcache.g_dcache_block[3].block.eb_blocking_Bank} {tb_stages.uut_dcache.g_dcache_block[3].block.address_bus_fake} {tb_stages.uut_dcache.g_dcache_block[3].block.startingOffset} {tb_stages.uut_dcache.g_dcache_block[3].block.dataBus_fake} {tb_stages.uut_dcache.g_dcache_block[3].block.block_req_i} {tb_stages.uut_dcache.g_dcache_block[3].block.outputs_o} {tb_stages.uut_dcache.g_dcache_block[3].block.dcache_bank_outputs} {tb_stages.uut_dcache.g_dcache_block[3].block.vcache_outputs} {tb_stages.uut_dcache.g_dcache_block[3].block.eb_outputs} }

gui_sg_move "$_session_group_224" -after "$_session_group_222" -pos 2 

set _session_group_225 $_session_group_222|
append _session_group_225 mio_block_unit
gui_sg_create "$_session_group_225"
set dcache|mio_block_unit "$_session_group_225"

gui_sg_addsignal -group "$_session_group_225" { {tb_stages.uut_dcache.mio_block_unit.$unit} tb_stages.uut_dcache.mio_block_unit.clk tb_stages.uut_dcache.mio_block_unit.rst tb_stages.uut_dcache.mio_block_unit.reqServed_FromDTE_i tb_stages.uut_dcache.mio_block_unit.PermissionToDriveAddrBus tb_stages.uut_dcache.mio_block_unit.permission2DriveDataBus tb_stages.uut_dcache.mio_block_unit.ld_addr_MIO_V tb_stages.uut_dcache.mio_block_unit.ld_addr_MIO tb_stages.uut_dcache.mio_block_unit.memStalling_FromCore tb_stages.uut_dcache.mio_block_unit.address_bus tb_stages.uut_dcache.mio_block_unit.dataBus tb_stages.uut_dcache.mio_block_unit.block_idle tb_stages.uut_dcache.mio_block_unit.readyForNewReq tb_stages.uut_dcache.mio_block_unit.data_bus_fake tb_stages.uut_dcache.mio_block_unit.WE_ADDR_MASK tb_stages.uut_dcache.mio_block_unit.stq_info_mio tb_stages.uut_dcache.mio_block_unit.outputs_o tb_stages.uut_dcache.mio_block_unit.block_req }
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_dcache.mio_block_unit.WE_ADDR_MASK}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_dcache.mio_block_unit.WE_ADDR_MASK}

gui_sg_move "$_session_group_225" -after "$_session_group_222" -pos 1 

set _session_group_226 $_session_group_222|
append _session_group_226 dcache_arbitration
gui_sg_create "$_session_group_226"
set dcache|dcache_arbitration "$_session_group_226"

gui_sg_addsignal -group "$_session_group_226" { tb_stages.uut_dcache.dcache_arbitration.clk_i tb_stages.uut_dcache.dcache_arbitration.rst tb_stages.uut_dcache.dcache_arbitration.block_hit_i tb_stages.uut_dcache.dcache_arbitration.req_rejected_0_o tb_stages.uut_dcache.dcache_arbitration.req_rejected_1_o tb_stages.uut_dcache.dcache_arbitration.st_override_o tb_stages.uut_dcache.dcache_arbitration.writeSuccess_o tb_stages.uut_dcache.dcache_arbitration.block_idleness tb_stages.uut_dcache.dcache_arbitration.readyForNewReq tb_stages.uut_dcache.dcache_arbitration.ld_req_0_bankNum tb_stages.uut_dcache.dcache_arbitration.ld_req_1_bankNum tb_stages.uut_dcache.dcache_arbitration.st_override tb_stages.uut_dcache.dcache_arbitration.ldReq_2_BankPresent tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_UB tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_LB tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_WIDTH tb_stages.uut_dcache.dcache_arbitration.core_i tb_stages.uut_dcache.dcache_arbitration.reqs_2_blocks_o tb_stages.uut_dcache.dcache_arbitration.reqs tb_stages.uut_dcache.dcache_arbitration.nextReqs }
=======
set _session_group_270 busArb
gui_sg_create "$_session_group_270"
set busArb "$_session_group_270"

gui_sg_addsignal -group "$_session_group_270" { }

set _session_group_271 $_session_group_270|
append _session_group_271 dte_unit
gui_sg_create "$_session_group_271"
set busArb|dte_unit "$_session_group_271"

gui_sg_addsignal -group "$_session_group_271" { {tb_stages.uut4_busArb.dte_unit.$unit} tb_stages.uut4_busArb.dte_unit.clk tb_stages.uut4_busArb.dte_unit.rst tb_stages.uut4_busArb.dte_unit.bestPick_i tb_stages.uut4_busArb.dte_unit.bestPick_bk_id_i tb_stages.uut4_busArb.dte_unit.dte_mem_2_icache_fsm_state tb_stages.uut4_busArb.dte_unit.dte_mem_2_icache_fsm_state_bits tb_stages.uut4_busArb.dte_unit.dte_mem_2_dcache_fsm_state tb_stages.uut4_busArb.dte_unit.dte_dcache_2_mem_fsm_state tb_stages.uut4_busArb.dte_unit.dte_ddr5_2_core_fsm_state tb_stages.uut4_busArb.dte_unit.dte_ddr5_2_core_fsm_state_bits tb_stages.uut4_busArb.dte_unit.dte_core_2_ddr5_fsm_state tb_stages.uut4_busArb.dte_unit.dte_core_2_ddr5_fsm_state_bits tb_stages.uut4_busArb.dte_unit.dte_core_2_dma_fsm_state tb_stages.uut4_busArb.dte_unit.dte_core_2_dma_fsm_state_bits tb_stages.uut4_busArb.dte_unit.dte_dma_2_mem_fsm_state tb_stages.uut4_busArb.dte_unit.dte_dma_2_mem_fsm_state_bits tb_stages.uut4_busArb.dte_unit.ddr5_2_core_fsmout_busy tb_stages.uut4_busArb.dte_unit.core_2_ddr5_fsmout_busy tb_stages.uut4_busArb.dte_unit.core_2_dma_fsmout_busy tb_stages.uut4_busArb.dte_unit.dma_2_mem_fsmout_busy tb_stages.uut4_busArb.dte_unit.mem_2_icache_fsmout_busy tb_stages.uut4_busArb.dte_unit.mem_2_dcache_fsmout_busy_per tb_stages.uut4_busArb.dte_unit.mem_2_dcache_fsmout_busy tb_stages.uut4_busArb.dte_unit.dcache_2_mem_fsmout_busy_per tb_stages.uut4_busArb.dte_unit.dcache_2_mem_fsmout_busy tb_stages.uut4_busArb.dte_unit.DTE_Busy tb_stages.uut4_busArb.dte_unit.mem_2_icache_ld_req_fsmOut tb_stages.uut4_busArb.dte_unit.mem_2_dcache_ld_req_fsmOut tb_stages.uut4_busArb.dte_unit.mem_2_icache_drv_db_fsmOut tb_stages.uut4_busArb.dte_unit.mem_2_dcache_drv_db_fsmOut tb_stages.uut4_busArb.dte_unit.dcache_2_mem_st_req_fsmOut tb_stages.uut4_busArb.dte_unit.dma_2_mem_st_req_fsmOut tb_stages.uut4_busArb.dte_unit.ddr5_2_core_reqServed_fsmOut tb_stages.uut4_busArb.dte_unit.core_2_ddr5_reqServed_fsmOut tb_stages.uut4_busArb.dte_unit.core_2_dma_reqServed_fsmOut tb_stages.uut4_busArb.dte_unit.ddr5_2_core_driveAddrBus_fsmOut tb_stages.uut4_busArb.dte_unit.core_2_ddr5_driveAddrBus_fsmOut tb_stages.uut4_busArb.dte_unit.core_2_dma_driveAddrBus_fsmOut tb_stages.uut4_busArb.dte_unit.core_2_ddr5_drvDB_fsmOut tb_stages.uut4_busArb.dte_unit.core_2_dma_drvDB_fsmOut tb_stages.uut4_busArb.dte_unit.mem_2_icache_req_hit tb_stages.uut4_busArb.dte_unit.mem_2_dcache_req_hit tb_stages.uut4_busArb.dte_unit.mem_2_dcache_bk_hit tb_stages.uut4_busArb.dte_unit.dcache_2_mem_req_hit tb_stages.uut4_busArb.dte_unit.dcache_2_mem_bk_hit tb_stages.uut4_busArb.dte_unit.ddr5_2_core_req_hit tb_stages.uut4_busArb.dte_unit.core_2_ddr5_req_hit tb_stages.uut4_busArb.dte_unit.core_2_dma_req_hit tb_stages.uut4_busArb.dte_unit.dma_2_mem_req_hit tb_stages.uut4_busArb.dte_unit.dte_mem_2_dcache_fsm_state_bits tb_stages.uut4_busArb.dte_unit.dte_dcache_2_mem_fsm_state_bits tb_stages.uut4_busArb.dte_unit.dte_out_2_icache_o tb_stages.uut4_busArb.dte_unit.dte_out_2_dcache_o tb_stages.uut4_busArb.dte_unit.mem_2_dte_i tb_stages.uut4_busArb.dte_unit.dte_2_mem_o tb_stages.uut4_busArb.dte_unit.dte_2_dma_o tb_stages.uut4_busArb.dte_unit.dte_2_ddr5_o }

gui_sg_move "$_session_group_271" -after "$_session_group_270" -pos 1 

set _session_group_272 $_session_group_270|
append _session_group_272 scheduler_unit
gui_sg_create "$_session_group_272"
set busArb|scheduler_unit "$_session_group_272"

gui_sg_addsignal -group "$_session_group_272" { {tb_stages.uut4_busArb.scheduler_unit.$unit} tb_stages.uut4_busArb.scheduler_unit.clk tb_stages.uut4_busArb.scheduler_unit.rst tb_stages.uut4_busArb.scheduler_unit.bestPick_o tb_stages.uut4_busArb.scheduler_unit.bestPick_bk_id_o tb_stages.uut4_busArb.scheduler_unit.dcache_Best_Pick tb_stages.uut4_busArb.scheduler_unit.dcache_Best_Pick_BK_ID tb_stages.uut4_busArb.scheduler_unit.dma_req tb_stages.uut4_busArb.scheduler_unit.IC_MIO_Pick tb_stages.uut4_busArb.scheduler_unit.IC_MIO_DMA_PICK tb_stages.uut4_busArb.scheduler_unit.bestPick tb_stages.uut4_busArb.scheduler_unit.iCache_2_Sch_i tb_stages.uut4_busArb.scheduler_unit.dCache_2_Sch_i tb_stages.uut4_busArb.scheduler_unit.mem_2_Sch_i tb_stages.uut4_busArb.scheduler_unit.dma_2_sch_i tb_stages.uut4_busArb.scheduler_unit.sch_latches }

set _session_group_273 $_session_group_270|
append _session_group_273 uut4_busArb
gui_sg_create "$_session_group_273"
set busArb|uut4_busArb "$_session_group_273"

gui_sg_addsignal -group "$_session_group_273" { {tb_stages.uut4_busArb.$unit} tb_stages.uut4_busArb.clk tb_stages.uut4_busArb.rst tb_stages.uut4_busArb.sch_best_pick tb_stages.uut4_busArb.sch_best_pick_bk_id tb_stages.uut4_busArb.iCache_2_Sch_i tb_stages.uut4_busArb.dte_out_2_icache_o tb_stages.uut4_busArb.dCache_2_Sch_i tb_stages.uut4_busArb.dte_out_2_dcache_o tb_stages.uut4_busArb.mem_2_Sch_i tb_stages.uut4_busArb.mem_2_dte_i tb_stages.uut4_busArb.dte_2_mem_o tb_stages.uut4_busArb.dma_2_sch_i tb_stages.uut4_busArb.dte_2_dma_o tb_stages.uut4_busArb.dte_2_ddr5_o }

gui_sg_move "$_session_group_273" -after "$_session_group_270" -pos 2 

set _session_group_274 dcache
gui_sg_create "$_session_group_274"
set dcache "$_session_group_274"

gui_sg_addsignal -group "$_session_group_274" { }

set _session_group_275 $_session_group_274|
append _session_group_275 {g_dcache_block[0].block}
gui_sg_create "$_session_group_275"
set {dcache|g_dcache_block[0].block} "$_session_group_275"

gui_sg_addsignal -group "$_session_group_275" { {tb_stages.uut_dcache.g_dcache_block[0].block.clk_i} {tb_stages.uut_dcache.g_dcache_block[0].block.rst_i} {tb_stages.uut_dcache.g_dcache_block[0].block.mem_Valid_FromDte_i} {tb_stages.uut_dcache.g_dcache_block[0].block.evictionBuf_clr_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[0].block.evictionBuf_setCommiting_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[0].block.permissionToDriveDataBus_evictionBuf} {tb_stages.uut_dcache.g_dcache_block[0].block.permissionToDriveAddrBus_Ld} {tb_stages.uut_dcache.g_dcache_block[0].block.permissionToDriveAddrBus_eb} {tb_stages.uut_dcache.g_dcache_block[0].block.st_override_for_sch_req} {tb_stages.uut_dcache.g_dcache_block[0].block.dataBus} {tb_stages.uut_dcache.g_dcache_block[0].block.address_bus} {tb_stages.uut_dcache.g_dcache_block[0].block.block_busy} {tb_stages.uut_dcache.g_dcache_block[0].block.makeBlockReq} {tb_stages.uut_dcache.g_dcache_block[0].block.eb_blockingVCache} {tb_stages.uut_dcache.g_dcache_block[0].block.eb_V} {tb_stages.uut_dcache.g_dcache_block[0].block.eb_curr_commiting} {tb_stages.uut_dcache.g_dcache_block[0].block.eb_blocking_Bank} {tb_stages.uut_dcache.g_dcache_block[0].block.address_bus_fake} {tb_stages.uut_dcache.g_dcache_block[0].block.startingOffset} {tb_stages.uut_dcache.g_dcache_block[0].block.dataBus_fake} {tb_stages.uut_dcache.g_dcache_block[0].block.block_req_i} {tb_stages.uut_dcache.g_dcache_block[0].block.outputs_o} {tb_stages.uut_dcache.g_dcache_block[0].block.dcache_bank_outputs} {tb_stages.uut_dcache.g_dcache_block[0].block.vcache_outputs} {tb_stages.uut_dcache.g_dcache_block[0].block.eb_outputs} }

gui_sg_move "$_session_group_275" -after "$_session_group_274" -pos 4 

set _session_group_276 $_session_group_274|
append _session_group_276 {g_dcache_block[3].block}
gui_sg_create "$_session_group_276"
set {dcache|g_dcache_block[3].block} "$_session_group_276"

gui_sg_addsignal -group "$_session_group_276" { {tb_stages.uut_dcache.g_dcache_block[3].block.clk_i} {tb_stages.uut_dcache.g_dcache_block[3].block.rst_i} {tb_stages.uut_dcache.g_dcache_block[3].block.mem_Valid_FromDte_i} {tb_stages.uut_dcache.g_dcache_block[3].block.evictionBuf_clr_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[3].block.evictionBuf_setCommiting_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[3].block.permissionToDriveDataBus_evictionBuf} {tb_stages.uut_dcache.g_dcache_block[3].block.permissionToDriveAddrBus_Ld} {tb_stages.uut_dcache.g_dcache_block[3].block.permissionToDriveAddrBus_eb} {tb_stages.uut_dcache.g_dcache_block[3].block.st_override_for_sch_req} {tb_stages.uut_dcache.g_dcache_block[3].block.dataBus} {tb_stages.uut_dcache.g_dcache_block[3].block.address_bus} {tb_stages.uut_dcache.g_dcache_block[3].block.block_busy} {tb_stages.uut_dcache.g_dcache_block[3].block.makeBlockReq} {tb_stages.uut_dcache.g_dcache_block[3].block.eb_blockingVCache} {tb_stages.uut_dcache.g_dcache_block[3].block.eb_V} {tb_stages.uut_dcache.g_dcache_block[3].block.eb_curr_commiting} {tb_stages.uut_dcache.g_dcache_block[3].block.eb_blocking_Bank} {tb_stages.uut_dcache.g_dcache_block[3].block.address_bus_fake} {tb_stages.uut_dcache.g_dcache_block[3].block.startingOffset} {tb_stages.uut_dcache.g_dcache_block[3].block.dataBus_fake} {tb_stages.uut_dcache.g_dcache_block[3].block.block_req_i} {tb_stages.uut_dcache.g_dcache_block[3].block.outputs_o} {tb_stages.uut_dcache.g_dcache_block[3].block.dcache_bank_outputs} {tb_stages.uut_dcache.g_dcache_block[3].block.vcache_outputs} {tb_stages.uut_dcache.g_dcache_block[3].block.eb_outputs} }

gui_sg_move "$_session_group_276" -after "$_session_group_274" -pos 2 

set _session_group_277 $_session_group_274|
append _session_group_277 mio_block_unit
gui_sg_create "$_session_group_277"
set dcache|mio_block_unit "$_session_group_277"

gui_sg_addsignal -group "$_session_group_277" { {tb_stages.uut_dcache.mio_block_unit.$unit} tb_stages.uut_dcache.mio_block_unit.clk tb_stages.uut_dcache.mio_block_unit.rst tb_stages.uut_dcache.mio_block_unit.reqServed_FromDTE_i tb_stages.uut_dcache.mio_block_unit.PermissionToDriveAddrBus tb_stages.uut_dcache.mio_block_unit.permission2DriveDataBus tb_stages.uut_dcache.mio_block_unit.ld_addr_MIO_V tb_stages.uut_dcache.mio_block_unit.ld_addr_MIO tb_stages.uut_dcache.mio_block_unit.memStalling_FromCore tb_stages.uut_dcache.mio_block_unit.address_bus tb_stages.uut_dcache.mio_block_unit.dataBus tb_stages.uut_dcache.mio_block_unit.block_idle tb_stages.uut_dcache.mio_block_unit.readyForNewReq tb_stages.uut_dcache.mio_block_unit.data_bus_fake tb_stages.uut_dcache.mio_block_unit.WE_ADDR_MASK tb_stages.uut_dcache.mio_block_unit.stq_info_mio tb_stages.uut_dcache.mio_block_unit.outputs_o tb_stages.uut_dcache.mio_block_unit.block_req }
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_dcache.mio_block_unit.WE_ADDR_MASK}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_dcache.mio_block_unit.WE_ADDR_MASK}

gui_sg_move "$_session_group_277" -after "$_session_group_274" -pos 1 

set _session_group_278 $_session_group_274|
append _session_group_278 uut_dcache
gui_sg_create "$_session_group_278"
set dcache|uut_dcache "$_session_group_278"

gui_sg_addsignal -group "$_session_group_278" { {tb_stages.uut_dcache.$unit} tb_stages.uut_dcache.clk tb_stages.uut_dcache.rst tb_stages.uut_dcache.dataBus tb_stages.uut_dcache.address_bus tb_stages.uut_dcache.hitVec tb_stages.uut_dcache.arb_st_override_Out tb_stages.uut_dcache.arb_req_rejected_0_out tb_stages.uut_dcache.arb_req_rejected_1_out tb_stages.uut_dcache.inFromCore_i tb_stages.uut_dcache.out2Core_o tb_stages.uut_dcache.inFromDTE_i tb_stages.uut_dcache.out2Sch_o tb_stages.uut_dcache.blockOutputs tb_stages.uut_dcache.req_2_blocks tb_stages.uut_dcache.mio_block_outputs }

set _session_group_279 $_session_group_274|
append _session_group_279 {g_dcache_block[2].block}
gui_sg_create "$_session_group_279"
set {dcache|g_dcache_block[2].block} "$_session_group_279"

gui_sg_addsignal -group "$_session_group_279" { {tb_stages.uut_dcache.g_dcache_block[2].block.clk_i} {tb_stages.uut_dcache.g_dcache_block[2].block.rst_i} {tb_stages.uut_dcache.g_dcache_block[2].block.mem_Valid_FromDte_i} {tb_stages.uut_dcache.g_dcache_block[2].block.evictionBuf_clr_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[2].block.evictionBuf_setCommiting_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[2].block.permissionToDriveDataBus_evictionBuf} {tb_stages.uut_dcache.g_dcache_block[2].block.permissionToDriveAddrBus_Ld} {tb_stages.uut_dcache.g_dcache_block[2].block.permissionToDriveAddrBus_eb} {tb_stages.uut_dcache.g_dcache_block[2].block.st_override_for_sch_req} {tb_stages.uut_dcache.g_dcache_block[2].block.dataBus} {tb_stages.uut_dcache.g_dcache_block[2].block.address_bus} {tb_stages.uut_dcache.g_dcache_block[2].block.block_busy} {tb_stages.uut_dcache.g_dcache_block[2].block.makeBlockReq} {tb_stages.uut_dcache.g_dcache_block[2].block.eb_blockingVCache} {tb_stages.uut_dcache.g_dcache_block[2].block.eb_V} {tb_stages.uut_dcache.g_dcache_block[2].block.eb_curr_commiting} {tb_stages.uut_dcache.g_dcache_block[2].block.eb_blocking_Bank} {tb_stages.uut_dcache.g_dcache_block[2].block.address_bus_fake} {tb_stages.uut_dcache.g_dcache_block[2].block.startingOffset} {tb_stages.uut_dcache.g_dcache_block[2].block.dataBus_fake} {tb_stages.uut_dcache.g_dcache_block[2].block.block_req_i} {tb_stages.uut_dcache.g_dcache_block[2].block.outputs_o} {tb_stages.uut_dcache.g_dcache_block[2].block.dcache_bank_outputs} {tb_stages.uut_dcache.g_dcache_block[2].block.vcache_outputs} {tb_stages.uut_dcache.g_dcache_block[2].block.eb_outputs} }

gui_sg_move "$_session_group_279" -after "$_session_group_274" -pos 6 

set _session_group_280 $_session_group_274|
append _session_group_280 {g_dcache_block[1].block}
gui_sg_create "$_session_group_280"
set {dcache|g_dcache_block[1].block} "$_session_group_280"

gui_sg_addsignal -group "$_session_group_280" { {tb_stages.uut_dcache.g_dcache_block[1].block.clk_i} {tb_stages.uut_dcache.g_dcache_block[1].block.rst_i} {tb_stages.uut_dcache.g_dcache_block[1].block.mem_Valid_FromDte_i} {tb_stages.uut_dcache.g_dcache_block[1].block.evictionBuf_clr_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[1].block.evictionBuf_setCommiting_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[1].block.permissionToDriveDataBus_evictionBuf} {tb_stages.uut_dcache.g_dcache_block[1].block.permissionToDriveAddrBus_Ld} {tb_stages.uut_dcache.g_dcache_block[1].block.permissionToDriveAddrBus_eb} {tb_stages.uut_dcache.g_dcache_block[1].block.st_override_for_sch_req} {tb_stages.uut_dcache.g_dcache_block[1].block.dataBus} {tb_stages.uut_dcache.g_dcache_block[1].block.address_bus} {tb_stages.uut_dcache.g_dcache_block[1].block.block_busy} {tb_stages.uut_dcache.g_dcache_block[1].block.makeBlockReq} {tb_stages.uut_dcache.g_dcache_block[1].block.eb_blockingVCache} {tb_stages.uut_dcache.g_dcache_block[1].block.eb_V} {tb_stages.uut_dcache.g_dcache_block[1].block.eb_curr_commiting} {tb_stages.uut_dcache.g_dcache_block[1].block.eb_blocking_Bank} {tb_stages.uut_dcache.g_dcache_block[1].block.address_bus_fake} {tb_stages.uut_dcache.g_dcache_block[1].block.startingOffset} {tb_stages.uut_dcache.g_dcache_block[1].block.dataBus_fake} {tb_stages.uut_dcache.g_dcache_block[1].block.block_req_i} {tb_stages.uut_dcache.g_dcache_block[1].block.outputs_o} {tb_stages.uut_dcache.g_dcache_block[1].block.dcache_bank_outputs} {tb_stages.uut_dcache.g_dcache_block[1].block.vcache_outputs} {tb_stages.uut_dcache.g_dcache_block[1].block.eb_outputs} }

gui_sg_move "$_session_group_280" -after "$_session_group_274" -pos 5 

set _session_group_281 $_session_group_274|
append _session_group_281 dcache_arbitration
gui_sg_create "$_session_group_281"
set dcache|dcache_arbitration "$_session_group_281"

gui_sg_addsignal -group "$_session_group_281" { tb_stages.uut_dcache.dcache_arbitration.clk_i tb_stages.uut_dcache.dcache_arbitration.rst tb_stages.uut_dcache.dcache_arbitration.block_hit_i tb_stages.uut_dcache.dcache_arbitration.req_rejected_0_o tb_stages.uut_dcache.dcache_arbitration.req_rejected_1_o tb_stages.uut_dcache.dcache_arbitration.st_override_o tb_stages.uut_dcache.dcache_arbitration.writeSuccess_o tb_stages.uut_dcache.dcache_arbitration.block_idleness tb_stages.uut_dcache.dcache_arbitration.readyForNewReq tb_stages.uut_dcache.dcache_arbitration.ld_req_0_bankNum tb_stages.uut_dcache.dcache_arbitration.ld_req_1_bankNum tb_stages.uut_dcache.dcache_arbitration.st_override tb_stages.uut_dcache.dcache_arbitration.ldReq_2_BankPresent tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_UB tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_LB tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_WIDTH tb_stages.uut_dcache.dcache_arbitration.core_i tb_stages.uut_dcache.dcache_arbitration.reqs_2_blocks_o tb_stages.uut_dcache.dcache_arbitration.reqs tb_stages.uut_dcache.dcache_arbitration.nextReqs }
>>>>>>> 092ccefeba40bd12f97cd06dfb88c904c12ccb03
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_UB}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_UB}
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_LB}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_LB}
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_WIDTH}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_WIDTH}

<<<<<<< HEAD
gui_sg_move "$_session_group_226" -after "$_session_group_222" -pos 3 

set _session_group_227 $_session_group_222|
append _session_group_227 {g_dcache_block[1].block}
gui_sg_create "$_session_group_227"
set {dcache|g_dcache_block[1].block} "$_session_group_227"

gui_sg_addsignal -group "$_session_group_227" { {tb_stages.uut_dcache.g_dcache_block[1].block.clk_i} {tb_stages.uut_dcache.g_dcache_block[1].block.rst_i} {tb_stages.uut_dcache.g_dcache_block[1].block.mem_Valid_FromDte_i} {tb_stages.uut_dcache.g_dcache_block[1].block.evictionBuf_clr_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[1].block.evictionBuf_setCommiting_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[1].block.permissionToDriveDataBus_evictionBuf} {tb_stages.uut_dcache.g_dcache_block[1].block.permissionToDriveAddrBus_Ld} {tb_stages.uut_dcache.g_dcache_block[1].block.permissionToDriveAddrBus_eb} {tb_stages.uut_dcache.g_dcache_block[1].block.st_override_for_sch_req} {tb_stages.uut_dcache.g_dcache_block[1].block.dataBus} {tb_stages.uut_dcache.g_dcache_block[1].block.address_bus} {tb_stages.uut_dcache.g_dcache_block[1].block.block_busy} {tb_stages.uut_dcache.g_dcache_block[1].block.makeBlockReq} {tb_stages.uut_dcache.g_dcache_block[1].block.eb_blockingVCache} {tb_stages.uut_dcache.g_dcache_block[1].block.eb_V} {tb_stages.uut_dcache.g_dcache_block[1].block.eb_curr_commiting} {tb_stages.uut_dcache.g_dcache_block[1].block.eb_blocking_Bank} {tb_stages.uut_dcache.g_dcache_block[1].block.address_bus_fake} {tb_stages.uut_dcache.g_dcache_block[1].block.startingOffset} {tb_stages.uut_dcache.g_dcache_block[1].block.dataBus_fake} {tb_stages.uut_dcache.g_dcache_block[1].block.block_req_i} {tb_stages.uut_dcache.g_dcache_block[1].block.outputs_o} {tb_stages.uut_dcache.g_dcache_block[1].block.dcache_bank_outputs} {tb_stages.uut_dcache.g_dcache_block[1].block.vcache_outputs} {tb_stages.uut_dcache.g_dcache_block[1].block.eb_outputs} }

gui_sg_move "$_session_group_227" -after "$_session_group_222" -pos 6 

set _session_group_228 $_session_group_222|
append _session_group_228 {g_dcache_block[2].block}
gui_sg_create "$_session_group_228"
set {dcache|g_dcache_block[2].block} "$_session_group_228"

gui_sg_addsignal -group "$_session_group_228" { {tb_stages.uut_dcache.g_dcache_block[2].block.clk_i} {tb_stages.uut_dcache.g_dcache_block[2].block.rst_i} {tb_stages.uut_dcache.g_dcache_block[2].block.mem_Valid_FromDte_i} {tb_stages.uut_dcache.g_dcache_block[2].block.evictionBuf_clr_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[2].block.evictionBuf_setCommiting_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[2].block.permissionToDriveDataBus_evictionBuf} {tb_stages.uut_dcache.g_dcache_block[2].block.permissionToDriveAddrBus_Ld} {tb_stages.uut_dcache.g_dcache_block[2].block.permissionToDriveAddrBus_eb} {tb_stages.uut_dcache.g_dcache_block[2].block.st_override_for_sch_req} {tb_stages.uut_dcache.g_dcache_block[2].block.dataBus} {tb_stages.uut_dcache.g_dcache_block[2].block.address_bus} {tb_stages.uut_dcache.g_dcache_block[2].block.block_busy} {tb_stages.uut_dcache.g_dcache_block[2].block.makeBlockReq} {tb_stages.uut_dcache.g_dcache_block[2].block.eb_blockingVCache} {tb_stages.uut_dcache.g_dcache_block[2].block.eb_V} {tb_stages.uut_dcache.g_dcache_block[2].block.eb_curr_commiting} {tb_stages.uut_dcache.g_dcache_block[2].block.eb_blocking_Bank} {tb_stages.uut_dcache.g_dcache_block[2].block.address_bus_fake} {tb_stages.uut_dcache.g_dcache_block[2].block.startingOffset} {tb_stages.uut_dcache.g_dcache_block[2].block.dataBus_fake} {tb_stages.uut_dcache.g_dcache_block[2].block.block_req_i} {tb_stages.uut_dcache.g_dcache_block[2].block.outputs_o} {tb_stages.uut_dcache.g_dcache_block[2].block.dcache_bank_outputs} {tb_stages.uut_dcache.g_dcache_block[2].block.vcache_outputs} {tb_stages.uut_dcache.g_dcache_block[2].block.eb_outputs} }

gui_sg_move "$_session_group_228" -after "$_session_group_222" -pos 5 

set _session_group_229 $_session_group_222|
append _session_group_229 uut_dcache
gui_sg_create "$_session_group_229"
set dcache|uut_dcache "$_session_group_229"

gui_sg_addsignal -group "$_session_group_229" { {tb_stages.uut_dcache.$unit} tb_stages.uut_dcache.clk tb_stages.uut_dcache.rst tb_stages.uut_dcache.dataBus tb_stages.uut_dcache.address_bus tb_stages.uut_dcache.hitVec tb_stages.uut_dcache.arb_st_override_Out tb_stages.uut_dcache.arb_req_rejected_0_out tb_stages.uut_dcache.arb_req_rejected_1_out tb_stages.uut_dcache.inFromCore_i tb_stages.uut_dcache.out2Core_o tb_stages.uut_dcache.inFromDTE_i tb_stages.uut_dcache.out2Sch_o tb_stages.uut_dcache.blockOutputs tb_stages.uut_dcache.req_2_blocks tb_stages.uut_dcache.mio_block_outputs }

set _session_group_230 icache
gui_sg_create "$_session_group_230"
set icache "$_session_group_230"

gui_sg_addsignal -group "$_session_group_230" { }

set _session_group_231 $_session_group_230|
append _session_group_231 icache_contrller_fsm
gui_sg_create "$_session_group_231"
set icache|icache_contrller_fsm "$_session_group_231"

gui_sg_addsignal -group "$_session_group_231" { tb_stages.uut_icache.icache_contrller_fsm.clk tb_stages.uut_icache.icache_contrller_fsm.rst tb_stages.uut_icache.icache_contrller_fsm.IC_miss_i tb_stages.uut_icache.icache_contrller_fsm.I_VC_Miss_i tb_stages.uut_icache.icache_contrller_fsm.mem_valid_i tb_stages.uut_icache.icache_contrller_fsm.en_i tb_stages.uut_icache.icache_contrller_fsm.S_0 tb_stages.uut_icache.icache_contrller_fsm.S_1 tb_stages.uut_icache.icache_contrller_fsm.S_2 tb_stages.uut_icache.icache_contrller_fsm.LD_IC_SWAP_BUF_o tb_stages.uut_icache.icache_contrller_fsm.RD_I_VC_SWAP_BUF_o tb_stages.uut_icache.icache_contrller_fsm.busy_o tb_stages.uut_icache.icache_contrller_fsm.MakeReq_o tb_stages.uut_icache.icache_contrller_fsm.Fill0EN_o tb_stages.uut_icache.icache_contrller_fsm.Fill1EN_o tb_stages.uut_icache.icache_contrller_fsm.Fill2EN_o tb_stages.uut_icache.icache_contrller_fsm.Fill3EN_o tb_stages.uut_icache.icache_contrller_fsm.NS_0 tb_stages.uut_icache.icache_contrller_fsm.NS_1 tb_stages.uut_icache.icache_contrller_fsm.NS_2 tb_stages.uut_icache.icache_contrller_fsm.I_VC_Miss_i_inv tb_stages.uut_icache.icache_contrller_fsm.S_0_inv tb_stages.uut_icache.icache_contrller_fsm.S_1_inv tb_stages.uut_icache.icache_contrller_fsm.S_2_inv tb_stages.uut_icache.icache_contrller_fsm.mem_valid_i_inv tb_stages.uut_icache.icache_contrller_fsm.NS_0_t0 tb_stages.uut_icache.icache_contrller_fsm.NS_0_t1 tb_stages.uut_icache.icache_contrller_fsm.NS_0_t2 tb_stages.uut_icache.icache_contrller_fsm.NS_1_t0 tb_stages.uut_icache.icache_contrller_fsm.NS_1_t1 tb_stages.uut_icache.icache_contrller_fsm.NS_1_t2 tb_stages.uut_icache.icache_contrller_fsm.NS_2_t0 tb_stages.uut_icache.icache_contrller_fsm.NS_2_t1 tb_stages.uut_icache.icache_contrller_fsm.NS_2_t2 tb_stages.uut_icache.icache_contrller_fsm.NS_2_t3 tb_stages.uut_icache.icache_contrller_fsm.busy_o_t0 tb_stages.uut_icache.icache_contrller_fsm.busy_o_t1 tb_stages.uut_icache.icache_contrller_fsm.busy_o_t2 }

gui_sg_move "$_session_group_231" -after "$_session_group_230" -pos 2 

set _session_group_232 $_session_group_230|
append _session_group_232 i_vcache_unit
gui_sg_create "$_session_group_232"
set icache|i_vcache_unit "$_session_group_232"

gui_sg_addsignal -group "$_session_group_232" { tb_stages.uut_icache.i_vcache_unit.clk tb_stages.uut_icache.i_vcache_unit.rst tb_stages.uut_icache.i_vcache_unit.busy_i tb_stages.uut_icache.i_vcache_unit.en_i tb_stages.uut_icache.i_vcache_unit.v_addr_i tb_stages.uut_icache.i_vcache_unit.hit_o tb_stages.uut_icache.i_vcache_unit.miss_o tb_stages.uut_icache.i_vcache_unit.dataLineOut_o tb_stages.uut_icache.i_vcache_unit.IC_SwapBuf_V_clr_o tb_stages.uut_icache.i_vcache_unit.LD_I_VC_SWAP_BUF tb_stages.uut_icache.i_vcache_unit.RD_IC_SWAP_BUF tb_stages.uut_icache.i_vcache_unit.hit_idx tb_stages.uut_icache.i_vcache_unit.currTag tb_stages.uut_icache.i_vcache_unit.currTagHit tb_stages.uut_icache.i_vcache_unit.currDataLine tb_stages.uut_icache.i_vcache_unit.hit tb_stages.uut_icache.i_vcache_unit.miss tb_stages.uut_icache.i_vcache_unit.hitHappened tb_stages.uut_icache.i_vcache_unit.updateLRU tb_stages.uut_icache.i_vcache_unit.currLRU_IDX tb_stages.uut_icache.i_vcache_unit.currMRU_IDX tb_stages.uut_icache.i_vcache_unit.IDX_2_Write tb_stages.uut_icache.i_vcache_unit.update_idx tb_stages.uut_icache.i_vcache_unit.NUM_LINES tb_stages.uut_icache.i_vcache_unit.NUM_LRU_BITS tb_stages.uut_icache.i_vcache_unit.LRU_ROOT tb_stages.uut_icache.i_vcache_unit.LRU_LEFT_LEAF tb_stages.uut_icache.i_vcache_unit.LRU_RIGHT_LEAF tb_stages.uut_icache.i_vcache_unit.IC_SwapBuf_i tb_stages.uut_icache.i_vcache_unit.I_VC_SwapBuf_o tb_stages.uut_icache.i_vcache_unit.tagStore tb_stages.uut_icache.i_vcache_unit.dataStore tb_stages.uut_icache.i_vcache_unit.I_VC_swapBuf tb_stages.uut_icache.i_vcache_unit.ic_swapBuf_v_addr_fields tb_stages.uut_icache.i_vcache_unit.v_addr_i_fields }
=======
gui_sg_move "$_session_group_281" -after "$_session_group_274" -pos 3 

set _session_group_282 icache
gui_sg_create "$_session_group_282"
set icache "$_session_group_282"

gui_sg_addsignal -group "$_session_group_282" { }

set _session_group_283 $_session_group_282|
append _session_group_283 icache_TagStore_unit
gui_sg_create "$_session_group_283"
set icache|icache_TagStore_unit "$_session_group_283"

gui_sg_addsignal -group "$_session_group_283" { tb_stages.uut_icache.icache_TagStore_unit.clk tb_stages.uut_icache.icache_TagStore_unit.rst tb_stages.uut_icache.icache_TagStore_unit.en tb_stages.uut_icache.icache_TagStore_unit.v_addr_i tb_stages.uut_icache.icache_TagStore_unit.ld_From_I_VC_Swap tb_stages.uut_icache.icache_TagStore_unit.LD_IC_SWAP_BUF tb_stages.uut_icache.icache_TagStore_unit.fill3_i tb_stages.uut_icache.icache_TagStore_unit.busy tb_stages.uut_icache.icache_TagStore_unit.currTag_o tb_stages.uut_icache.icache_TagStore_unit.currLine_V tb_stages.uut_icache.icache_TagStore_unit.clk_45_phase tb_stages.uut_icache.icache_TagStore_unit.validStore tb_stages.uut_icache.icache_TagStore_unit.ADDRESS_2_TagStore tb_stages.uut_icache.icache_TagStore_unit.tagCellOutSel tb_stages.uut_icache.icache_TagStore_unit.DIN_2_TagStore tb_stages.uut_icache.icache_TagStore_unit.OE_2_TagStore tb_stages.uut_icache.icache_TagStore_unit.DOUT_2_TagStore tb_stages.uut_icache.icache_TagStore_unit.WR_2_TagStore_clk tb_stages.uut_icache.icache_TagStore_unit.WR_2_TagStore_actual tb_stages.uut_icache.icache_TagStore_unit.DOUT_2_TagStore_net tb_stages.uut_icache.icache_TagStore_unit.NUM_LAYERS tb_stages.uut_icache.icache_TagStore_unit.NUM_CELLS tb_stages.uut_icache.icache_TagStore_unit.I_VC_SwapBuf_i tb_stages.uut_icache.icache_TagStore_unit.v_addr_i_fields }
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.icache_TagStore_unit.NUM_LAYERS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.icache_TagStore_unit.NUM_LAYERS}
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.icache_TagStore_unit.NUM_CELLS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.icache_TagStore_unit.NUM_CELLS}

gui_sg_move "$_session_group_283" -after "$_session_group_282" -pos 3 

set _session_group_284 $_session_group_282|
append _session_group_284 icache_dataStore_unit
gui_sg_create "$_session_group_284"
set icache|icache_dataStore_unit "$_session_group_284"

gui_sg_addsignal -group "$_session_group_284" { {tb_stages.uut_icache.icache_dataStore_unit.$unit} tb_stages.uut_icache.icache_dataStore_unit.rst tb_stages.uut_icache.icache_dataStore_unit.clk tb_stages.uut_icache.icache_dataStore_unit.en tb_stages.uut_icache.icache_dataStore_unit.v_addr_i tb_stages.uut_icache.icache_dataStore_unit.LD_IC_SWAP_BUF tb_stages.uut_icache.icache_dataStore_unit.fill0_i tb_stages.uut_icache.icache_dataStore_unit.fill1_i tb_stages.uut_icache.icache_dataStore_unit.fill2_i tb_stages.uut_icache.icache_dataStore_unit.fill3_i tb_stages.uut_icache.icache_dataStore_unit.busy tb_stages.uut_icache.icache_dataStore_unit.ld_From_I_VC_Swap tb_stages.uut_icache.icache_dataStore_unit.dataBus tb_stages.uut_icache.icache_dataStore_unit.currLine_o tb_stages.uut_icache.icache_dataStore_unit.v_addr_i_index tb_stages.uut_icache.icache_dataStore_unit.clk_45_phase tb_stages.uut_icache.icache_dataStore_unit.ADDRESS_2_DataStore tb_stages.uut_icache.icache_dataStore_unit.dataLineOutSel tb_stages.uut_icache.icache_dataStore_unit.WR_2_DataStore_clk tb_stages.uut_icache.icache_dataStore_unit.WR_2_DataStore_actual tb_stages.uut_icache.icache_dataStore_unit.DIN_2_DataStore tb_stages.uut_icache.icache_dataStore_unit.OE_2_DataStore tb_stages.uut_icache.icache_dataStore_unit.DOUT_2_DataStore tb_stages.uut_icache.icache_dataStore_unit.LAYERS_OF_CELLS tb_stages.uut_icache.icache_dataStore_unit.NUM_CELLS tb_stages.uut_icache.icache_dataStore_unit.I_VC_SwapBuf_i }
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.icache_dataStore_unit.LAYERS_OF_CELLS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.icache_dataStore_unit.LAYERS_OF_CELLS}
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.icache_dataStore_unit.NUM_CELLS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.icache_dataStore_unit.NUM_CELLS}

gui_sg_move "$_session_group_284" -after "$_session_group_282" -pos 1 

set _session_group_285 $_session_group_282|
append _session_group_285 uut_icache
gui_sg_create "$_session_group_285"
set icache|uut_icache "$_session_group_285"

gui_sg_addsignal -group "$_session_group_285" { {tb_stages.uut_icache.$unit} tb_stages.uut_icache.clk tb_stages.uut_icache.rst tb_stages.uut_icache.dataBus tb_stages.uut_icache.addrBus tb_stages.uut_icache.controller_fsmState tb_stages.uut_icache.controller_fsmState_bits tb_stages.uut_icache.icache_dataLines tb_stages.uut_icache.icache_tag tb_stages.uut_icache.icache_tag_V tb_stages.uut_icache.icache_hit tb_stages.uut_icache.icache_miss tb_stages.uut_icache.i_vcache_hit tb_stages.uut_icache.i_vcache_miss tb_stages.uut_icache.i_vcache_swapBuf_V_Clr tb_stages.uut_icache.i_vcache_dataLines tb_stages.uut_icache.saved_pAddr tb_stages.uut_icache.saved_vAddr tb_stages.uut_icache.curr_v_addr_to_use tb_stages.uut_icache.useSaved_v_Addr tb_stages.uut_icache.addrBus_drv tb_stages.uut_icache.inFromCore_i tb_stages.uut_icache.out2Core_o tb_stages.uut_icache.inFromDte_i tb_stages.uut_icache.out2Sch_o tb_stages.uut_icache.fsmOuts tb_stages.uut_icache.icache_swapbuf tb_stages.uut_icache.i_vcache_swapBuf }

set _session_group_286 $_session_group_282|
append _session_group_286 i_vcache_unit
gui_sg_create "$_session_group_286"
set icache|i_vcache_unit "$_session_group_286"

gui_sg_addsignal -group "$_session_group_286" { tb_stages.uut_icache.i_vcache_unit.clk tb_stages.uut_icache.i_vcache_unit.rst tb_stages.uut_icache.i_vcache_unit.busy_i tb_stages.uut_icache.i_vcache_unit.en_i tb_stages.uut_icache.i_vcache_unit.v_addr_i tb_stages.uut_icache.i_vcache_unit.hit_o tb_stages.uut_icache.i_vcache_unit.miss_o tb_stages.uut_icache.i_vcache_unit.dataLineOut_o tb_stages.uut_icache.i_vcache_unit.IC_SwapBuf_V_clr_o tb_stages.uut_icache.i_vcache_unit.LD_I_VC_SWAP_BUF tb_stages.uut_icache.i_vcache_unit.RD_IC_SWAP_BUF tb_stages.uut_icache.i_vcache_unit.hit_idx tb_stages.uut_icache.i_vcache_unit.currTag tb_stages.uut_icache.i_vcache_unit.currTagHit tb_stages.uut_icache.i_vcache_unit.currDataLine tb_stages.uut_icache.i_vcache_unit.hit tb_stages.uut_icache.i_vcache_unit.miss tb_stages.uut_icache.i_vcache_unit.hitHappened tb_stages.uut_icache.i_vcache_unit.updateLRU tb_stages.uut_icache.i_vcache_unit.currLRU_IDX tb_stages.uut_icache.i_vcache_unit.currMRU_IDX tb_stages.uut_icache.i_vcache_unit.IDX_2_Write tb_stages.uut_icache.i_vcache_unit.update_idx tb_stages.uut_icache.i_vcache_unit.NUM_LINES tb_stages.uut_icache.i_vcache_unit.NUM_LRU_BITS tb_stages.uut_icache.i_vcache_unit.LRU_ROOT tb_stages.uut_icache.i_vcache_unit.LRU_LEFT_LEAF tb_stages.uut_icache.i_vcache_unit.LRU_RIGHT_LEAF tb_stages.uut_icache.i_vcache_unit.IC_SwapBuf_i tb_stages.uut_icache.i_vcache_unit.I_VC_SwapBuf_o tb_stages.uut_icache.i_vcache_unit.tagStore tb_stages.uut_icache.i_vcache_unit.dataStore tb_stages.uut_icache.i_vcache_unit.I_VC_swapBuf tb_stages.uut_icache.i_vcache_unit.ic_swapBuf_v_addr_fields tb_stages.uut_icache.i_vcache_unit.v_addr_i_fields }
>>>>>>> 092ccefeba40bd12f97cd06dfb88c904c12ccb03
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.i_vcache_unit.NUM_LINES}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.i_vcache_unit.NUM_LINES}
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.i_vcache_unit.NUM_LRU_BITS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.i_vcache_unit.NUM_LRU_BITS}
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.i_vcache_unit.LRU_ROOT}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.i_vcache_unit.LRU_ROOT}
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.i_vcache_unit.LRU_LEFT_LEAF}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.i_vcache_unit.LRU_LEFT_LEAF}
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.i_vcache_unit.LRU_RIGHT_LEAF}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.i_vcache_unit.LRU_RIGHT_LEAF}

<<<<<<< HEAD
gui_sg_move "$_session_group_232" -after "$_session_group_230" -pos 4 

set _session_group_233 $_session_group_230|
append _session_group_233 uut_icache
gui_sg_create "$_session_group_233"
set icache|uut_icache "$_session_group_233"

gui_sg_addsignal -group "$_session_group_233" { {tb_stages.uut_icache.$unit} tb_stages.uut_icache.clk tb_stages.uut_icache.rst tb_stages.uut_icache.dataBus tb_stages.uut_icache.addrBus tb_stages.uut_icache.controller_fsmState tb_stages.uut_icache.controller_fsmState_bits tb_stages.uut_icache.icache_dataLines tb_stages.uut_icache.icache_tag tb_stages.uut_icache.icache_tag_V tb_stages.uut_icache.icache_hit tb_stages.uut_icache.icache_miss tb_stages.uut_icache.i_vcache_hit tb_stages.uut_icache.i_vcache_miss tb_stages.uut_icache.i_vcache_swapBuf_V_Clr tb_stages.uut_icache.i_vcache_dataLines tb_stages.uut_icache.saved_pAddr tb_stages.uut_icache.saved_vAddr tb_stages.uut_icache.curr_v_addr_to_use tb_stages.uut_icache.useSaved_v_Addr tb_stages.uut_icache.addrBus_drv tb_stages.uut_icache.inFromCore_i tb_stages.uut_icache.out2Core_o tb_stages.uut_icache.inFromDte_i tb_stages.uut_icache.out2Sch_o tb_stages.uut_icache.fsmOuts tb_stages.uut_icache.icache_swapbuf tb_stages.uut_icache.i_vcache_swapBuf }

set _session_group_234 $_session_group_230|
append _session_group_234 icache_TagStore_unit
gui_sg_create "$_session_group_234"
set icache|icache_TagStore_unit "$_session_group_234"

gui_sg_addsignal -group "$_session_group_234" { tb_stages.uut_icache.icache_TagStore_unit.clk tb_stages.uut_icache.icache_TagStore_unit.rst tb_stages.uut_icache.icache_TagStore_unit.en tb_stages.uut_icache.icache_TagStore_unit.v_addr_i tb_stages.uut_icache.icache_TagStore_unit.ld_From_I_VC_Swap tb_stages.uut_icache.icache_TagStore_unit.LD_IC_SWAP_BUF tb_stages.uut_icache.icache_TagStore_unit.fill3_i tb_stages.uut_icache.icache_TagStore_unit.busy tb_stages.uut_icache.icache_TagStore_unit.currTag_o tb_stages.uut_icache.icache_TagStore_unit.currLine_V tb_stages.uut_icache.icache_TagStore_unit.clk_45_phase tb_stages.uut_icache.icache_TagStore_unit.validStore tb_stages.uut_icache.icache_TagStore_unit.ADDRESS_2_TagStore tb_stages.uut_icache.icache_TagStore_unit.tagCellOutSel tb_stages.uut_icache.icache_TagStore_unit.DIN_2_TagStore tb_stages.uut_icache.icache_TagStore_unit.OE_2_TagStore tb_stages.uut_icache.icache_TagStore_unit.DOUT_2_TagStore tb_stages.uut_icache.icache_TagStore_unit.WR_2_TagStore_clk tb_stages.uut_icache.icache_TagStore_unit.WR_2_TagStore_actual tb_stages.uut_icache.icache_TagStore_unit.DOUT_2_TagStore_net tb_stages.uut_icache.icache_TagStore_unit.NUM_LAYERS tb_stages.uut_icache.icache_TagStore_unit.NUM_CELLS tb_stages.uut_icache.icache_TagStore_unit.I_VC_SwapBuf_i tb_stages.uut_icache.icache_TagStore_unit.v_addr_i_fields }
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.icache_TagStore_unit.NUM_LAYERS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.icache_TagStore_unit.NUM_LAYERS}
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.icache_TagStore_unit.NUM_CELLS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.icache_TagStore_unit.NUM_CELLS}

gui_sg_move "$_session_group_234" -after "$_session_group_230" -pos 3 

set _session_group_235 $_session_group_230|
append _session_group_235 icache_dataStore_unit
gui_sg_create "$_session_group_235"
set icache|icache_dataStore_unit "$_session_group_235"

gui_sg_addsignal -group "$_session_group_235" { {tb_stages.uut_icache.icache_dataStore_unit.$unit} tb_stages.uut_icache.icache_dataStore_unit.rst tb_stages.uut_icache.icache_dataStore_unit.clk tb_stages.uut_icache.icache_dataStore_unit.en tb_stages.uut_icache.icache_dataStore_unit.v_addr_i tb_stages.uut_icache.icache_dataStore_unit.LD_IC_SWAP_BUF tb_stages.uut_icache.icache_dataStore_unit.fill0_i tb_stages.uut_icache.icache_dataStore_unit.fill1_i tb_stages.uut_icache.icache_dataStore_unit.fill2_i tb_stages.uut_icache.icache_dataStore_unit.fill3_i tb_stages.uut_icache.icache_dataStore_unit.busy tb_stages.uut_icache.icache_dataStore_unit.ld_From_I_VC_Swap tb_stages.uut_icache.icache_dataStore_unit.dataBus tb_stages.uut_icache.icache_dataStore_unit.currLine_o tb_stages.uut_icache.icache_dataStore_unit.v_addr_i_index tb_stages.uut_icache.icache_dataStore_unit.clk_45_phase tb_stages.uut_icache.icache_dataStore_unit.ADDRESS_2_DataStore tb_stages.uut_icache.icache_dataStore_unit.dataLineOutSel tb_stages.uut_icache.icache_dataStore_unit.WR_2_DataStore_clk tb_stages.uut_icache.icache_dataStore_unit.WR_2_DataStore_actual tb_stages.uut_icache.icache_dataStore_unit.DIN_2_DataStore tb_stages.uut_icache.icache_dataStore_unit.OE_2_DataStore tb_stages.uut_icache.icache_dataStore_unit.DOUT_2_DataStore tb_stages.uut_icache.icache_dataStore_unit.LAYERS_OF_CELLS tb_stages.uut_icache.icache_dataStore_unit.NUM_CELLS tb_stages.uut_icache.icache_dataStore_unit.I_VC_SwapBuf_i }
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.icache_dataStore_unit.LAYERS_OF_CELLS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.icache_dataStore_unit.LAYERS_OF_CELLS}
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.icache_dataStore_unit.NUM_CELLS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.icache_dataStore_unit.NUM_CELLS}

gui_sg_move "$_session_group_235" -after "$_session_group_230" -pos 1 

set _session_group_236 core
gui_sg_create "$_session_group_236"
set core "$_session_group_236"

gui_sg_addsignal -group "$_session_group_236" { }

set _session_group_237 $_session_group_236|
append _session_group_237 idm_unit
gui_sg_create "$_session_group_237"
set core|idm_unit "$_session_group_237"

gui_sg_addsignal -group "$_session_group_237" { tb_stages.uut_core.idm_unit.clk tb_stages.uut_core.idm_unit.rst tb_stages.uut_core.idm_unit.fetch_outs_i tb_stages.uut_core.idm_unit.idm_outs_o tb_stages.uut_core.idm_unit.idm }

gui_sg_move "$_session_group_237" -after "$_session_group_236" -pos 5 

set _session_group_238 $_session_group_236|
append _session_group_238 mem_latches_unit
gui_sg_create "$_session_group_238"
set core|mem_latches_unit "$_session_group_238"

gui_sg_addsignal -group "$_session_group_238" { tb_stages.uut_core.mem_latches_unit.clk tb_stages.uut_core.mem_latches_unit.rst tb_stages.uut_core.mem_latches_unit.write_enable_i tb_stages.uut_core.mem_latches_unit.flush tb_stages.uut_core.mem_latches_unit.farFlush tb_stages.uut_core.mem_latches_unit.nextLatches_i tb_stages.uut_core.mem_latches_unit.latches_o tb_stages.uut_core.mem_latches_unit.latches }

gui_sg_move "$_session_group_238" -after "$_session_group_236" -pos 4 

set _session_group_239 $_session_group_236|
append _session_group_239 rr_latches_unit
gui_sg_create "$_session_group_239"
set core|rr_latches_unit "$_session_group_239"

gui_sg_addsignal -group "$_session_group_239" { tb_stages.uut_core.rr_latches_unit.clk tb_stages.uut_core.rr_latches_unit.rst tb_stages.uut_core.rr_latches_unit.write_enable_i tb_stages.uut_core.rr_latches_unit.flush tb_stages.uut_core.rr_latches_unit.farFlush tb_stages.uut_core.rr_latches_unit.nextLatches_i tb_stages.uut_core.rr_latches_unit.latches_o tb_stages.uut_core.rr_latches_unit.latches }

gui_sg_move "$_session_group_239" -after "$_session_group_236" -pos 3 

set _session_group_240 $_session_group_236|
append _session_group_240 rr_unit
gui_sg_create "$_session_group_240"
set core|rr_unit "$_session_group_240"

gui_sg_addsignal -group "$_session_group_240" { {tb_stages.uut_core.rr_unit.$unit} tb_stages.uut_core.rr_unit.SEGMENT_LIMITS tb_stages.uut_core.rr_unit.clk tb_stages.uut_core.rr_unit.rst tb_stages.uut_core.rr_unit.RR_GP tb_stages.uut_core.rr_unit.ecx_sb tb_stages.uut_core.rr_unit.cs_sb tb_stages.uut_core.rr_unit.depstall tb_stages.uut_core.rr_unit.dc_latches_we tb_stages.uut_core.rr_unit.next_dc_valid tb_stages.uut_core.rr_unit.rr_stall tb_stages.uut_core.rr_unit.addygen_input_addy tb_stages.uut_core.rr_unit.latches_i tb_stages.uut_core.rr_unit.fetch_outs_i tb_stages.uut_core.rr_unit.decode_outs_i tb_stages.uut_core.rr_unit.dc_outs_i tb_stages.uut_core.rr_unit.mem_outs_i tb_stages.uut_core.rr_unit.exe_outs_i tb_stages.uut_core.rr_unit.wb_outs_i tb_stages.uut_core.rr_unit.dc_latches_next tb_stages.uut_core.rr_unit.outs_o tb_stages.uut_core.rr_unit.latchesInUse tb_stages.uut_core.rr_unit.reg_out }

gui_sg_move "$_session_group_240" -after "$_session_group_236" -pos 2 

set _session_group_241 $_session_group_240|
append _session_group_241 reg_sb_unit
gui_sg_create "$_session_group_241"
set core|rr_unit|reg_sb_unit "$_session_group_241"

gui_sg_addsignal -group "$_session_group_241" { {tb_stages.uut_core.rr_unit.reg_sb_unit.$unit} tb_stages.uut_core.rr_unit.reg_sb_unit.dep_stall tb_stages.uut_core.rr_unit.reg_sb_unit.ecx_sb tb_stages.uut_core.rr_unit.reg_sb_unit.codeSeg_sb tb_stages.uut_core.rr_unit.reg_sb_unit.clk tb_stages.uut_core.rr_unit.reg_sb_unit.rst tb_stages.uut_core.rr_unit.reg_sb_unit.dr_id tb_stages.uut_core.rr_unit.reg_sb_unit.sr_id tb_stages.uut_core.rr_unit.reg_sb_unit.sib_base_id tb_stages.uut_core.rr_unit.reg_sb_unit.sib_idx_id tb_stages.uut_core.rr_unit.reg_sb_unit.wb_dr0_id tb_stages.uut_core.rr_unit.reg_sb_unit.wb_dr0_we tb_stages.uut_core.rr_unit.reg_sb_unit.wb_dr1_id tb_stages.uut_core.rr_unit.reg_sb_unit.wb_dr1_we tb_stages.uut_core.rr_unit.reg_sb_unit.cs_sib_size tb_stages.uut_core.rr_unit.reg_sb_unit.cs_dr_wr tb_stages.uut_core.rr_unit.reg_sb_unit.cs_sr_wr tb_stages.uut_core.rr_unit.reg_sb_unit.cs_dr_rd tb_stages.uut_core.rr_unit.reg_sb_unit.cs_sr_rd tb_stages.uut_core.rr_unit.reg_sb_unit.Segment0_ID tb_stages.uut_core.rr_unit.reg_sb_unit.Segment1_ID tb_stages.uut_core.rr_unit.reg_sb_unit.Segment1_valid tb_stages.uut_core.rr_unit.reg_sb_unit.flush tb_stages.uut_core.rr_unit.reg_sb_unit.farFlush tb_stages.uut_core.rr_unit.reg_sb_unit.depStall_Internal tb_stages.uut_core.rr_unit.reg_sb_unit.dr_stall tb_stages.uut_core.rr_unit.reg_sb_unit.sr_stall tb_stages.uut_core.rr_unit.reg_sb_unit.seg0_stall tb_stages.uut_core.rr_unit.reg_sb_unit.seg1_stall tb_stages.uut_core.rr_unit.reg_sb_unit.sib_base_stall tb_stages.uut_core.rr_unit.reg_sb_unit.sib_idx_stall tb_stages.uut_core.rr_unit.reg_sb_unit.SCORE_BOARD }

gui_sg_move "$_session_group_241" -after "$_session_group_240" -pos 4 

set _session_group_242 $_session_group_240|
append _session_group_242 RegisterFile_unit
gui_sg_create "$_session_group_242"
set core|rr_unit|RegisterFile_unit "$_session_group_242"

gui_sg_addsignal -group "$_session_group_242" { {tb_stages.uut_core.rr_unit.RegisterFile_unit.$unit} tb_stages.uut_core.rr_unit.RegisterFile_unit.REGISTERS tb_stages.uut_core.rr_unit.RegisterFile_unit.clk tb_stages.uut_core.rr_unit.RegisterFile_unit.rst tb_stages.uut_core.rr_unit.RegisterFile_unit.DR_ID tb_stages.uut_core.rr_unit.RegisterFile_unit.SR_ID tb_stages.uut_core.rr_unit.RegisterFile_unit.SIB_IDX_ID tb_stages.uut_core.rr_unit.RegisterFile_unit.SIB_BASE_ID tb_stages.uut_core.rr_unit.RegisterFile_unit.WB_DR0_data tb_stages.uut_core.rr_unit.RegisterFile_unit.WB_DR1_data tb_stages.uut_core.rr_unit.RegisterFile_unit.WB_DR0_ID tb_stages.uut_core.rr_unit.RegisterFile_unit.WB_DR1_ID tb_stages.uut_core.rr_unit.RegisterFile_unit.WB_DR0_we tb_stages.uut_core.rr_unit.RegisterFile_unit.WB_DR1_we tb_stages.uut_core.rr_unit.RegisterFile_unit.Segment0_ID tb_stages.uut_core.rr_unit.RegisterFile_unit.Segment1_ID tb_stages.uut_core.rr_unit.RegisterFile_unit.outputs }

set _session_group_243 $_session_group_236|
append _session_group_243 uut_core
gui_sg_create "$_session_group_243"
set core|uut_core "$_session_group_243"

gui_sg_addsignal -group "$_session_group_243" { {tb_stages.uut_core.$unit} tb_stages.uut_core.clk tb_stages.uut_core.rst tb_stages.uut_core.ICacheIn_i tb_stages.uut_core.out2ICache_o tb_stages.uut_core.DCacheIn_i tb_stages.uut_core.out2DCache_o tb_stages.uut_core.inFromDMA_i tb_stages.uut_core.idm_outputs tb_stages.uut_core.fetch_outputs tb_stages.uut_core.decode_outputs tb_stages.uut_core.rr_outputs tb_stages.uut_core.dc_outputs tb_stages.uut_core.mem_outputs tb_stages.uut_core.exe_outputs tb_stages.uut_core.wb_outputs tb_stages.uut_core.rr_latches tb_stages.uut_core.rr_latches_next tb_stages.uut_core.dc_latches tb_stages.uut_core.dc_latches_next tb_stages.uut_core.mem_latches tb_stages.uut_core.mem_latches_next tb_stages.uut_core.exe_latches tb_stages.uut_core.exe_latches_next tb_stages.uut_core.wb_latches tb_stages.uut_core.wb_latches_next }

gui_sg_move "$_session_group_243" -after "$_session_group_236" -pos 1 

set _session_group_244 $_session_group_236|
append _session_group_244 decode_unit
gui_sg_create "$_session_group_244"
set core|decode_unit "$_session_group_244"

gui_sg_addsignal -group "$_session_group_244" { tb_stages.uut_core.decode_unit.EIP tb_stages.uut_core.decode_unit.clk tb_stages.uut_core.decode_unit.rst tb_stages.uut_core.decode_unit.PrevEIP tb_stages.uut_core.decode_unit.NEIP tb_stages.uut_core.decode_unit.inst_length tb_stages.uut_core.decode_unit.PrevLength tb_stages.uut_core.decode_unit.sib_byte tb_stages.uut_core.decode_unit.sib_size tb_stages.uut_core.decode_unit.disp_needed tb_stages.uut_core.decode_unit.displacement tb_stages.uut_core.decode_unit.disp_size tb_stages.uut_core.decode_unit.imm64 tb_stages.uut_core.decode_unit.total_pf_vector tb_stages.uut_core.decode_unit.invalid_inst tb_stages.uut_core.decode_unit.opcode_byte tb_stages.uut_core.decode_unit.modrm_byte tb_stages.uut_core.decode_unit.decode_gp tb_stages.uut_core.decode_unit.flush tb_stages.uut_core.decode_unit.stall tb_stages.uut_core.decode_unit.REP_CMP_LATCH tb_stages.uut_core.decode_unit.rr_latch_we_o tb_stages.uut_core.decode_unit.queue tb_stages.uut_core.decode_unit.predicted_taken tb_stages.uut_core.decode_unit.predicted_target tb_stages.uut_core.decode_unit.sibbase tb_stages.uut_core.decode_unit.sibidx tb_stages.uut_core.decode_unit.sibscale tb_stages.uut_core.decode_unit.rep_reg_value tb_stages.uut_core.decode_unit.rr_valid tb_stages.uut_core.decode_unit.segment0 tb_stages.uut_core.decode_unit.idm_outs_i tb_stages.uut_core.decode_unit.fetch_outs_i tb_stages.uut_core.decode_unit.rr_outs_i tb_stages.uut_core.decode_unit.dc_outs_i tb_stages.uut_core.decode_unit.mem_outs_i tb_stages.uut_core.decode_unit.exe_outs_i tb_stages.uut_core.decode_unit.wb_outs_i tb_stages.uut_core.decode_unit.rr_latches_next tb_stages.uut_core.decode_unit.outs_o tb_stages.uut_core.decode_unit.temp_decode_cs tb_stages.uut_core.decode_unit.temp_rr_cs tb_stages.uut_core.decode_unit.temp_dc_cs tb_stages.uut_core.decode_unit.temp_mem_cs tb_stages.uut_core.decode_unit.temp_exe_cs tb_stages.uut_core.decode_unit.temp_wb_cs tb_stages.uut_core.decode_unit.temp_rr_latch tb_stages.uut_core.decode_unit.br_info_for_latches tb_stages.uut_core.decode_unit.rep_latch_holder }

gui_sg_move "$_session_group_244" -after "$_session_group_236" -pos 7 

set _session_group_245 $_session_group_236|
append _session_group_245 wb_latches_unit
gui_sg_create "$_session_group_245"
set core|wb_latches_unit "$_session_group_245"

gui_sg_addsignal -group "$_session_group_245" { {tb_stages.uut_core.wb_latches_unit.$unit} tb_stages.uut_core.wb_latches_unit.clk tb_stages.uut_core.wb_latches_unit.rst tb_stages.uut_core.wb_latches_unit.write_enable_i tb_stages.uut_core.wb_latches_unit.nextLatches_i tb_stages.uut_core.wb_latches_unit.latches_o tb_stages.uut_core.wb_latches_unit.latches }

set _session_group_246 $_session_group_236|
append _session_group_246 write_back_unit
gui_sg_create "$_session_group_246"
set core|write_back_unit "$_session_group_246"

gui_sg_addsignal -group "$_session_group_246" { {tb_stages.uut_core.write_back_unit.$unit} tb_stages.uut_core.write_back_unit.clk tb_stages.uut_core.write_back_unit.rst tb_stages.uut_core.write_back_unit.write_success tb_stages.uut_core.write_back_unit.write_success_mio tb_stages.uut_core.write_back_unit.stall_flop tb_stages.uut_core.write_back_unit.stall_flop_next tb_stages.uut_core.write_back_unit.stq_outputs tb_stages.uut_core.write_back_unit.wb_latches tb_stages.uut_core.write_back_unit.outputs tb_stages.uut_core.write_back_unit.stq_info tb_stages.uut_core.write_back_unit.mio_q_input tb_stages.uut_core.write_back_unit.reg_wb_logic_outs tb_stages.uut_core.write_back_unit.dc_dep tb_stages.uut_core.write_back_unit.stq_heads tb_stages.uut_core.write_back_unit.mio_q_output }

set _session_group_247 $_session_group_246|
append _session_group_247 st_q_mio_logic
gui_sg_create "$_session_group_247"
set core|write_back_unit|st_q_mio_logic "$_session_group_247"

gui_sg_addsignal -group "$_session_group_247" { {tb_stages.uut_core.write_back_unit.st_q_mio_logic.$unit} tb_stages.uut_core.write_back_unit.st_q_mio_logic.wb_valid tb_stages.uut_core.write_back_unit.st_q_mio_logic.st_paddr_0_mio tb_stages.uut_core.write_back_unit.st_q_mio_logic.res_buf tb_stages.uut_core.write_back_unit.st_q_mio_logic.ST_OP tb_stages.uut_core.write_back_unit.st_q_mio_logic.MIO tb_stages.uut_core.write_back_unit.st_q_mio_logic.write_success_mio tb_stages.uut_core.write_back_unit.st_q_mio_logic.mio_q_input_o }

set _session_group_248 $_session_group_246|
append _session_group_248 st_q_logic
gui_sg_create "$_session_group_248"
set core|write_back_unit|st_q_logic "$_session_group_248"

gui_sg_addsignal -group "$_session_group_248" { tb_stages.uut_core.write_back_unit.st_q_logic.wb_valid tb_stages.uut_core.write_back_unit.st_q_logic.st_paddr_0 tb_stages.uut_core.write_back_unit.st_q_logic.st_paddr_1 tb_stages.uut_core.write_back_unit.st_q_logic.res_buf tb_stages.uut_core.write_back_unit.st_q_logic.bit_vect_0 tb_stages.uut_core.write_back_unit.st_q_logic.bit_vect_1 tb_stages.uut_core.write_back_unit.st_q_logic.ST_OP tb_stages.uut_core.write_back_unit.st_q_logic.ST_XCL tb_stages.uut_core.write_back_unit.st_q_logic.MIO tb_stages.uut_core.write_back_unit.st_q_logic.write_success tb_stages.uut_core.write_back_unit.st_q_logic.low_bank_num tb_stages.uut_core.write_back_unit.st_q_logic.high_bank_num tb_stages.uut_core.write_back_unit.st_q_logic.st_data_low_bank tb_stages.uut_core.write_back_unit.st_q_logic.st_data_high_bank tb_stages.uut_core.write_back_unit.st_q_logic.stq_info tb_stages.uut_core.write_back_unit.st_q_logic.entry0 tb_stages.uut_core.write_back_unit.st_q_logic.entry1 }

gui_sg_move "$_session_group_248" -after "$_session_group_246" -pos 1 

set _session_group_249 $_session_group_246|
append _session_group_249 reg_wb
gui_sg_create "$_session_group_249"
set core|write_back_unit|reg_wb "$_session_group_249"

gui_sg_addsignal -group "$_session_group_249" { tb_stages.uut_core.write_back_unit.reg_wb.stall_flop tb_stages.uut_core.write_back_unit.reg_wb.reg_info tb_stages.uut_core.write_back_unit.reg_wb.outs }

gui_sg_move "$_session_group_249" -after "$_session_group_246" -pos 2 

set _session_group_250 $_session_group_246|
append _session_group_250 mio_q_inst
gui_sg_create "$_session_group_250"
set core|write_back_unit|mio_q_inst "$_session_group_250"

gui_sg_addsignal -group "$_session_group_250" { tb_stages.uut_core.write_back_unit.mio_q_inst.full tb_stages.uut_core.write_back_unit.mio_q_inst.empty tb_stages.uut_core.write_back_unit.mio_q_inst.clk tb_stages.uut_core.write_back_unit.mio_q_inst.rst tb_stages.uut_core.write_back_unit.mio_q_inst.next_full tb_stages.uut_core.write_back_unit.mio_q_inst.next_empty tb_stages.uut_core.write_back_unit.mio_q_inst.valid_push tb_stages.uut_core.write_back_unit.mio_q_inst.valid_pop tb_stages.uut_core.write_back_unit.mio_q_inst.mio_q tb_stages.uut_core.write_back_unit.mio_q_inst.mio_input tb_stages.uut_core.write_back_unit.mio_q_inst.outs }

gui_sg_move "$_session_group_250" -after "$_session_group_246" -pos 3 

set _session_group_251 $_session_group_246|
append _session_group_251 {gen_st_q[3].stq_inst}
gui_sg_create "$_session_group_251"
set {core|write_back_unit|gen_st_q[3].stq_inst} "$_session_group_251"

gui_sg_addsignal -group "$_session_group_251" { {tb_stages.uut_core.write_back_unit.gen_st_q[3].stq_inst.q_empty} {tb_stages.uut_core.write_back_unit.gen_st_q[3].stq_inst.clk} {tb_stages.uut_core.write_back_unit.gen_st_q[3].stq_inst.rst} {tb_stages.uut_core.write_back_unit.gen_st_q[3].stq_inst.head} {tb_stages.uut_core.write_back_unit.gen_st_q[3].stq_inst.tail} {tb_stages.uut_core.write_back_unit.gen_st_q[3].stq_inst.head_ptr} {tb_stages.uut_core.write_back_unit.gen_st_q[3].stq_inst.tail_ptr} {tb_stages.uut_core.write_back_unit.gen_st_q[3].stq_inst.q_full} {tb_stages.uut_core.write_back_unit.gen_st_q[3].stq_inst.valid_push} {tb_stages.uut_core.write_back_unit.gen_st_q[3].stq_inst.valid_pop} {tb_stages.uut_core.write_back_unit.gen_st_q[3].stq_inst.wb_in} {tb_stages.uut_core.write_back_unit.gen_st_q[3].stq_inst.outputs} {tb_stages.uut_core.write_back_unit.gen_st_q[3].stq_inst.q} {tb_stages.uut_core.write_back_unit.gen_st_q[3].stq_inst.unnamed$$_10} }

gui_sg_move "$_session_group_251" -after "$_session_group_246" -pos 4 

set _session_group_252 $_session_group_246|
append _session_group_252 {gen_st_q[2].stq_inst}
gui_sg_create "$_session_group_252"
set {core|write_back_unit|gen_st_q[2].stq_inst} "$_session_group_252"

gui_sg_addsignal -group "$_session_group_252" { {tb_stages.uut_core.write_back_unit.gen_st_q[2].stq_inst.q_empty} {tb_stages.uut_core.write_back_unit.gen_st_q[2].stq_inst.clk} {tb_stages.uut_core.write_back_unit.gen_st_q[2].stq_inst.rst} {tb_stages.uut_core.write_back_unit.gen_st_q[2].stq_inst.head} {tb_stages.uut_core.write_back_unit.gen_st_q[2].stq_inst.tail} {tb_stages.uut_core.write_back_unit.gen_st_q[2].stq_inst.head_ptr} {tb_stages.uut_core.write_back_unit.gen_st_q[2].stq_inst.tail_ptr} {tb_stages.uut_core.write_back_unit.gen_st_q[2].stq_inst.q_full} {tb_stages.uut_core.write_back_unit.gen_st_q[2].stq_inst.valid_push} {tb_stages.uut_core.write_back_unit.gen_st_q[2].stq_inst.valid_pop} {tb_stages.uut_core.write_back_unit.gen_st_q[2].stq_inst.wb_in} {tb_stages.uut_core.write_back_unit.gen_st_q[2].stq_inst.outputs} {tb_stages.uut_core.write_back_unit.gen_st_q[2].stq_inst.q} {tb_stages.uut_core.write_back_unit.gen_st_q[2].stq_inst.unnamed$$_10} }

gui_sg_move "$_session_group_252" -after "$_session_group_246" -pos 5 

set _session_group_253 $_session_group_246|
append _session_group_253 {gen_st_q[1].stq_inst}
gui_sg_create "$_session_group_253"
set {core|write_back_unit|gen_st_q[1].stq_inst} "$_session_group_253"

gui_sg_addsignal -group "$_session_group_253" { {tb_stages.uut_core.write_back_unit.gen_st_q[1].stq_inst.q_empty} {tb_stages.uut_core.write_back_unit.gen_st_q[1].stq_inst.clk} {tb_stages.uut_core.write_back_unit.gen_st_q[1].stq_inst.rst} {tb_stages.uut_core.write_back_unit.gen_st_q[1].stq_inst.head} {tb_stages.uut_core.write_back_unit.gen_st_q[1].stq_inst.tail} {tb_stages.uut_core.write_back_unit.gen_st_q[1].stq_inst.head_ptr} {tb_stages.uut_core.write_back_unit.gen_st_q[1].stq_inst.tail_ptr} {tb_stages.uut_core.write_back_unit.gen_st_q[1].stq_inst.q_full} {tb_stages.uut_core.write_back_unit.gen_st_q[1].stq_inst.valid_push} {tb_stages.uut_core.write_back_unit.gen_st_q[1].stq_inst.valid_pop} {tb_stages.uut_core.write_back_unit.gen_st_q[1].stq_inst.wb_in} {tb_stages.uut_core.write_back_unit.gen_st_q[1].stq_inst.outputs} {tb_stages.uut_core.write_back_unit.gen_st_q[1].stq_inst.q} {tb_stages.uut_core.write_back_unit.gen_st_q[1].stq_inst.unnamed$$_10} }

gui_sg_move "$_session_group_253" -after "$_session_group_246" -pos 6 

set _session_group_254 $_session_group_246|
append _session_group_254 {gen_st_q[0].stq_inst}
gui_sg_create "$_session_group_254"
set {core|write_back_unit|gen_st_q[0].stq_inst} "$_session_group_254"

gui_sg_addsignal -group "$_session_group_254" { {tb_stages.uut_core.write_back_unit.gen_st_q[0].stq_inst.q_empty} {tb_stages.uut_core.write_back_unit.gen_st_q[0].stq_inst.clk} {tb_stages.uut_core.write_back_unit.gen_st_q[0].stq_inst.rst} {tb_stages.uut_core.write_back_unit.gen_st_q[0].stq_inst.head} {tb_stages.uut_core.write_back_unit.gen_st_q[0].stq_inst.tail} {tb_stages.uut_core.write_back_unit.gen_st_q[0].stq_inst.head_ptr} {tb_stages.uut_core.write_back_unit.gen_st_q[0].stq_inst.tail_ptr} {tb_stages.uut_core.write_back_unit.gen_st_q[0].stq_inst.q_full} {tb_stages.uut_core.write_back_unit.gen_st_q[0].stq_inst.valid_push} {tb_stages.uut_core.write_back_unit.gen_st_q[0].stq_inst.valid_pop} {tb_stages.uut_core.write_back_unit.gen_st_q[0].stq_inst.wb_in} {tb_stages.uut_core.write_back_unit.gen_st_q[0].stq_inst.outputs} {tb_stages.uut_core.write_back_unit.gen_st_q[0].stq_inst.q} {tb_stages.uut_core.write_back_unit.gen_st_q[0].stq_inst.unnamed$$_10} }

gui_sg_move "$_session_group_254" -after "$_session_group_246" -pos 7 

set _session_group_255 $_session_group_236|
append _session_group_255 dc_unit
gui_sg_create "$_session_group_255"
set core|dc_unit "$_session_group_255"

gui_sg_addsignal -group "$_session_group_255" { tb_stages.uut_core.dc_unit.mem_latches_next_o tb_stages.uut_core.dc_unit.dep_stall tb_stages.uut_core.dc_unit.mem_stage_we_valid_unit_o tb_stages.uut_core.dc_unit.mem_ST_OP tb_stages.uut_core.dc_unit.latches_i tb_stages.uut_core.dc_unit.fetch_outs_i tb_stages.uut_core.dc_unit.ld_addr_0_V tb_stages.uut_core.dc_unit.req_rejected_0 tb_stages.uut_core.dc_unit.mem_stage_next_vaild_o tb_stages.uut_core.dc_unit.stq_stall tb_stages.uut_core.dc_unit.req_rejected_1 tb_stages.uut_core.dc_unit.ld_addr_1_V tb_stages.uut_core.dc_unit.dc_ST_OP tb_stages.uut_core.dc_unit.ld_addr_0 tb_stages.uut_core.dc_unit.ld_addr_1 tb_stages.uut_core.dc_unit.in_flight_stall tb_stages.uut_core.dc_unit.exe_outs_i tb_stages.uut_core.dc_unit.arb_stall tb_stages.uut_core.dc_unit.dc_outs_o tb_stages.uut_core.dc_unit.wb_outs_i tb_stages.uut_core.dc_unit.mem_outs_i tb_stages.uut_core.dc_unit.req_rejected_mio tb_stages.uut_core.dc_unit.dc_stall tb_stages.uut_core.dc_unit.exe_ST_OP {tb_stages.uut_core.dc_unit.$unit} tb_stages.uut_core.dc_unit.wb_ST_OP tb_stages.uut_core.dc_unit.rst }

set _session_group_256 $_session_group_255|
append _session_group_256 mem_valid_unit
gui_sg_create "$_session_group_256"
set core|dc_unit|mem_valid_unit "$_session_group_256"

gui_sg_addsignal -group "$_session_group_256" { tb_stages.uut_core.dc_unit.mem_valid_unit.MEM_we_o tb_stages.uut_core.dc_unit.mem_valid_unit.N_MEM_V_o tb_stages.uut_core.dc_unit.mem_valid_unit.DC_stall_i tb_stages.uut_core.dc_unit.mem_valid_unit.DC_V_i tb_stages.uut_core.dc_unit.mem_valid_unit.MEM_V_i tb_stages.uut_core.dc_unit.mem_valid_unit.MEM_stall_i tb_stages.uut_core.dc_unit.mem_valid_unit.EXE_V_i tb_stages.uut_core.dc_unit.mem_valid_unit.WB_stall_i tb_stages.uut_core.dc_unit.mem_valid_unit.DC_stall_i_inv tb_stages.uut_core.dc_unit.mem_valid_unit.EXE_V_i_inv tb_stages.uut_core.dc_unit.mem_valid_unit.MEM_V_i_inv tb_stages.uut_core.dc_unit.mem_valid_unit.MEM_stall_i_inv tb_stages.uut_core.dc_unit.mem_valid_unit.WB_stall_i_inv tb_stages.uut_core.dc_unit.mem_valid_unit.MEM_we_o_t0 tb_stages.uut_core.dc_unit.mem_valid_unit.MEM_we_o_t1 tb_stages.uut_core.dc_unit.mem_valid_unit.MEM_we_o_t2 }

gui_sg_move "$_session_group_256" -after "$_session_group_255" -pos 5 

set _session_group_257 $_session_group_255|
append _session_group_257 ld_neuralnet_part2
gui_sg_create "$_session_group_257"
set core|dc_unit|ld_neuralnet_part2 "$_session_group_257"

gui_sg_addsignal -group "$_session_group_257" { tb_stages.uut_core.dc_unit.ld_neuralnet_part2.vaddy_start tb_stages.uut_core.dc_unit.ld_neuralnet_part2.seg_limit_w_datasize tb_stages.uut_core.dc_unit.ld_neuralnet_part2.datasize tb_stages.uut_core.dc_unit.ld_neuralnet_part2.write_intent tb_stages.uut_core.dc_unit.ld_neuralnet_part2.mem_op tb_stages.uut_core.dc_unit.ld_neuralnet_part2.rr_gp tb_stages.uut_core.dc_unit.ld_neuralnet_part2.next_page_vaddy tb_stages.uut_core.dc_unit.ld_neuralnet_part2.vaddy_end tb_stages.uut_core.dc_unit.ld_neuralnet_part2.cross_page_access tb_stages.uut_core.dc_unit.ld_neuralnet_part2.tlb0_pagefault tb_stages.uut_core.dc_unit.ld_neuralnet_part2.tlb0_generalprotection tb_stages.uut_core.dc_unit.ld_neuralnet_part2.tlb1_pagefault tb_stages.uut_core.dc_unit.ld_neuralnet_part2.tlb1_generalprotection tb_stages.uut_core.dc_unit.ld_neuralnet_part2.segx_gp tb_stages.uut_core.dc_unit.ld_neuralnet_part2.outputs tb_stages.uut_core.dc_unit.ld_neuralnet_part2.vaddy_start_fields tb_stages.uut_core.dc_unit.ld_neuralnet_part2.vaddy_end_fields tb_stages.uut_core.dc_unit.ld_neuralnet_part2.tlb0_in tb_stages.uut_core.dc_unit.ld_neuralnet_part2.tlb1_in tb_stages.uut_core.dc_unit.ld_neuralnet_part2.tlb0_out tb_stages.uut_core.dc_unit.ld_neuralnet_part2.tlb1_out }

gui_sg_move "$_session_group_257" -after "$_session_group_255" -pos 1 

set _session_group_258 $_session_group_236|
append _session_group_258 dc_latches_unit
gui_sg_create "$_session_group_258"
set core|dc_latches_unit "$_session_group_258"

gui_sg_addsignal -group "$_session_group_258" { tb_stages.uut_core.dc_latches_unit.clk tb_stages.uut_core.dc_latches_unit.rst tb_stages.uut_core.dc_latches_unit.write_enable_i tb_stages.uut_core.dc_latches_unit.flush tb_stages.uut_core.dc_latches_unit.farFlush tb_stages.uut_core.dc_latches_unit.nextLatches_i tb_stages.uut_core.dc_latches_unit.latches_o tb_stages.uut_core.dc_latches_unit.latches }

gui_sg_move "$_session_group_258" -after "$_session_group_236" -pos 8 

set _session_group_259 $_session_group_236|
append _session_group_259 fetch_unit
gui_sg_create "$_session_group_259"
set core|fetch_unit "$_session_group_259"

gui_sg_addsignal -group "$_session_group_259" { tb_stages.uut_core.fetch_unit.SPC tb_stages.uut_core.fetch_unit.clk tb_stages.uut_core.fetch_unit.rst tb_stages.uut_core.fetch_unit.dma_int tb_stages.uut_core.fetch_unit.exp_mode_jk tb_stages.uut_core.fetch_unit.int_mode_jk tb_stages.uut_core.fetch_unit.DMA_int_jk tb_stages.uut_core.fetch_unit.f_exp tb_stages.uut_core.fetch_unit.seg_xlation_out tb_stages.uut_core.fetch_unit.rom_data_out tb_stages.uut_core.fetch_unit.idm_ctrl_data_in tb_stages.uut_core.fetch_unit.next_spc tb_stages.uut_core.fetch_unit.spc_16 tb_stages.uut_core.fetch_unit.br_restore_spc tb_stages.uut_core.fetch_unit.br_target tb_stages.uut_core.fetch_unit.spc_2_IDM_CTRL tb_stages.uut_core.fetch_unit.en_icache tb_stages.uut_core.fetch_unit.icache_info_i tb_stages.uut_core.fetch_unit.idm_info_i tb_stages.uut_core.fetch_unit.decode_outs_i tb_stages.uut_core.fetch_unit.rr_outs_i tb_stages.uut_core.fetch_unit.dc_outs_i tb_stages.uut_core.fetch_unit.mem_outs_i tb_stages.uut_core.fetch_unit.exe_outs_i tb_stages.uut_core.fetch_unit.wb_outs_i tb_stages.uut_core.fetch_unit.outs_o tb_stages.uut_core.fetch_unit.predictor_inputs tb_stages.uut_core.fetch_unit.tlb_inputs tb_stages.uut_core.fetch_unit.btb_outs tb_stages.uut_core.fetch_unit.spc_sel_logic_outs tb_stages.uut_core.fetch_unit.predictor_outs tb_stages.uut_core.fetch_unit.idm_ctrl_logic_outs tb_stages.uut_core.fetch_unit.idm_invalidate_logic_outs tb_stages.uut_core.fetch_unit.tlb_outs tb_stages.uut_core.fetch_unit.exp_set_logic_outs }

gui_sg_move "$_session_group_259" -after "$_session_group_236" -pos 6 

set _session_group_260 $_session_group_259|
append _session_group_260 exp_set_logic
gui_sg_create "$_session_group_260"
set core|fetch_unit|exp_set_logic "$_session_group_260"

gui_sg_addsignal -group "$_session_group_260" { tb_stages.uut_core.fetch_unit.exp_set_logic.int_pipe_clear tb_stages.uut_core.fetch_unit.exp_set_logic.invalid_instruction tb_stages.uut_core.fetch_unit.exp_set_logic.rr_valid tb_stages.uut_core.fetch_unit.exp_set_logic.dc_valid tb_stages.uut_core.fetch_unit.exp_set_logic.mem_valid tb_stages.uut_core.fetch_unit.exp_set_logic.exe_valid tb_stages.uut_core.fetch_unit.exp_set_logic.wb_valid tb_stages.uut_core.fetch_unit.exp_set_logic.f_exp tb_stages.uut_core.fetch_unit.exp_set_logic.dc_exp tb_stages.uut_core.fetch_unit.exp_set_logic.int_set tb_stages.uut_core.fetch_unit.exp_set_logic.f_pipe_clear tb_stages.uut_core.fetch_unit.exp_set_logic.dc_pipe_clear tb_stages.uut_core.fetch_unit.exp_set_logic.not_rr_valid tb_stages.uut_core.fetch_unit.exp_set_logic.not_dc_valid tb_stages.uut_core.fetch_unit.exp_set_logic.not_mem_valid tb_stages.uut_core.fetch_unit.exp_set_logic.not_exe_valid tb_stages.uut_core.fetch_unit.exp_set_logic.not_wb_valid tb_stages.uut_core.fetch_unit.exp_set_logic.outputs }

gui_sg_move "$_session_group_260" -after "$_session_group_259" -pos 17 

set _session_group_261 Group1
gui_sg_create "$_session_group_261"
set Group1 "$_session_group_261"

gui_sg_addsignal -group "$_session_group_261" { tb_stages.uut_core.dc_unit.clk }

set _session_group_262 execute_unit
gui_sg_create "$_session_group_262"
set execute_unit "$_session_group_262"

gui_sg_addsignal -group "$_session_group_262" { {tb_stages.uut_core.execute_unit.$unit} tb_stages.uut_core.execute_unit.clk tb_stages.uut_core.execute_unit.rst tb_stages.uut_core.execute_unit.clr_ZF_sb tb_stages.uut_core.execute_unit.wb_stage_we_valid_unit_o tb_stages.uut_core.execute_unit.wb_stage_next_vaild_o tb_stages.uut_core.execute_unit.op_type tb_stages.uut_core.execute_unit.data_size tb_stages.uut_core.execute_unit.flags_reg tb_stages.uut_core.execute_unit.srA tb_stages.uut_core.execute_unit.srB tb_stages.uut_core.execute_unit.br_sel tb_stages.uut_core.execute_unit.res_buf_next tb_stages.uut_core.execute_unit.bit_vec_0_next tb_stages.uut_core.execute_unit.bit_vec_1_next tb_stages.uut_core.execute_unit.dr_next tb_stages.uut_core.execute_unit.sr_next tb_stages.uut_core.execute_unit.wb_dr_next tb_stages.uut_core.execute_unit.wb_sr_next tb_stages.uut_core.execute_unit.st_op_next tb_stages.uut_core.execute_unit.res_buf_selected tb_stages.uut_core.execute_unit.cancel_dr_we tb_stages.uut_core.execute_unit.cancel_sr_we tb_stages.uut_core.execute_unit.cancel_store tb_stages.uut_core.execute_unit.aaa_dr_o tb_stages.uut_core.execute_unit.adc_dr_o tb_stages.uut_core.execute_unit.adc_res_buf_o tb_stages.uut_core.execute_unit.add_dr_o tb_stages.uut_core.execute_unit.add_res_buf_o tb_stages.uut_core.execute_unit.and_dr_o tb_stages.uut_core.execute_unit.and_res_buf_o tb_stages.uut_core.execute_unit.bsf_dr_o tb_stages.uut_core.execute_unit.bsf_res_buf_o tb_stages.uut_core.execute_unit.call_dr_o tb_stages.uut_core.execute_unit.call_res_buf tb_stages.uut_core.execute_unit.cmpxchg_sr_o tb_stages.uut_core.execute_unit.cmpxchg_dr_o tb_stages.uut_core.execute_unit.cmpxchg_buf_o tb_stages.uut_core.execute_unit.far_call_dr_o tb_stages.uut_core.execute_unit.far_call_res_buf tb_stages.uut_core.execute_unit.iretd_cs_o tb_stages.uut_core.execute_unit.iretd_stack_ptr_o tb_stages.uut_core.execute_unit.mov_dr_o tb_stages.uut_core.execute_unit.mov_res_buf_o tb_stages.uut_core.execute_unit.not_dr_o tb_stages.uut_core.execute_unit.not_res_buf_o tb_stages.uut_core.execute_unit.or_dr_o tb_stages.uut_core.execute_unit.or_res_buf_o tb_stages.uut_core.execute_unit.packssdw_dr_o tb_stages.uut_core.execute_unit.packsswb_dr_o tb_stages.uut_core.execute_unit.paddd_dr_o tb_stages.uut_core.execute_unit.paddw_dr_o tb_stages.uut_core.execute_unit.pavgb_dr_o tb_stages.uut_core.execute_unit.pavgw_dr_o tb_stages.uut_core.execute_unit.pop_dr_o tb_stages.uut_core.execute_unit.pop_sr_o tb_stages.uut_core.execute_unit.push_res_buf tb_stages.uut_core.execute_unit.push_sr_o tb_stages.uut_core.execute_unit.ret_far_imm_dr_o tb_stages.uut_core.execute_unit.ret_far_imm_sr_o tb_stages.uut_core.execute_unit.ret_far_cs_o tb_stages.uut_core.execute_unit.ret_far_next_ptr_o tb_stages.uut_core.execute_unit.ret_imm_sr_o tb_stages.uut_core.execute_unit.ret_sr_o tb_stages.uut_core.execute_unit.sal_dr_o tb_stages.uut_core.execute_unit.sal_res_buf_o tb_stages.uut_core.execute_unit.sar_dr_o tb_stages.uut_core.execute_unit.sar_res_buf_o tb_stages.uut_core.execute_unit.sbb_dr_o tb_stages.uut_core.execute_unit.sbb_res_buf_o tb_stages.uut_core.execute_unit.xchg_dr_o tb_stages.uut_core.execute_unit.xchg_sr_o tb_stages.uut_core.execute_unit.xchg_res_buf tb_stages.uut_core.execute_unit.aaa_af_o tb_stages.uut_core.execute_unit.aaa_cf_o tb_stages.uut_core.execute_unit.adc_af_o tb_stages.uut_core.execute_unit.adc_cf_o tb_stages.uut_core.execute_unit.adc_of_o tb_stages.uut_core.execute_unit.adc_pf_o tb_stages.uut_core.execute_unit.adc_sf_o tb_stages.uut_core.execute_unit.adc_zf_o tb_stages.uut_core.execute_unit.add_af_o tb_stages.uut_core.execute_unit.add_cf_o tb_stages.uut_core.execute_unit.add_of_o tb_stages.uut_core.execute_unit.add_pf_o tb_stages.uut_core.execute_unit.add_sf_o tb_stages.uut_core.execute_unit.add_zf_o tb_stages.uut_core.execute_unit.and_of_o tb_stages.uut_core.execute_unit.and_pf_o tb_stages.uut_core.execute_unit.and_sf_o tb_stages.uut_core.execute_unit.and_zf_o tb_stages.uut_core.execute_unit.bsf_zf_o tb_stages.uut_core.execute_unit.cmp_cf_o }
gui_sg_addsignal -group "$_session_group_262" { tb_stages.uut_core.execute_unit.cmp_pf_o tb_stages.uut_core.execute_unit.cmp_af_o tb_stages.uut_core.execute_unit.cmp_zf_o tb_stages.uut_core.execute_unit.cmp_sf_o tb_stages.uut_core.execute_unit.cmp_of_o tb_stages.uut_core.execute_unit.cmpxchg_cf_o tb_stages.uut_core.execute_unit.cmpxchg_pf_o tb_stages.uut_core.execute_unit.cmpxchg_af_o tb_stages.uut_core.execute_unit.cmpxchg_zf_o tb_stages.uut_core.execute_unit.cmpxchg_sf_o tb_stages.uut_core.execute_unit.cmpxchg_of_o tb_stages.uut_core.execute_unit.or_cf_o tb_stages.uut_core.execute_unit.or_pf_o tb_stages.uut_core.execute_unit.or_zf_o tb_stages.uut_core.execute_unit.or_sf_o tb_stages.uut_core.execute_unit.or_of_o tb_stages.uut_core.execute_unit.sal_cf_o tb_stages.uut_core.execute_unit.sal_pf_o tb_stages.uut_core.execute_unit.sal_zf_o tb_stages.uut_core.execute_unit.sal_sf_o tb_stages.uut_core.execute_unit.sal_of_o tb_stages.uut_core.execute_unit.sar_cf_o tb_stages.uut_core.execute_unit.sar_pf_o tb_stages.uut_core.execute_unit.sar_zf_o tb_stages.uut_core.execute_unit.sar_sf_o tb_stages.uut_core.execute_unit.sar_of_o tb_stages.uut_core.execute_unit.sbb_cf_o tb_stages.uut_core.execute_unit.sbb_pf_o tb_stages.uut_core.execute_unit.sbb_af_o tb_stages.uut_core.execute_unit.sbb_zf_o tb_stages.uut_core.execute_unit.sbb_sf_o tb_stages.uut_core.execute_unit.sbb_of_o tb_stages.uut_core.execute_unit.iretd_cf_o tb_stages.uut_core.execute_unit.iretd_pf_o tb_stages.uut_core.execute_unit.iretd_af_o tb_stages.uut_core.execute_unit.iretd_zf_o tb_stages.uut_core.execute_unit.iretd_sf_o tb_stages.uut_core.execute_unit.iretd_of_o tb_stages.uut_core.execute_unit.af_flag_o tb_stages.uut_core.execute_unit.cf_flag_o tb_stages.uut_core.execute_unit.df_flag_o tb_stages.uut_core.execute_unit.of_flag_o tb_stages.uut_core.execute_unit.pf_flag_o tb_stages.uut_core.execute_unit.sf_flag_o tb_stages.uut_core.execute_unit.zf_flag_o tb_stages.uut_core.execute_unit.latches_i tb_stages.uut_core.execute_unit.wb_outs_i tb_stages.uut_core.execute_unit.wb_latches_next_o tb_stages.uut_core.execute_unit.outs_o tb_stages.uut_core.execute_unit.branch_resolution_o }
=======
gui_sg_move "$_session_group_286" -after "$_session_group_282" -pos 4 

set _session_group_287 $_session_group_282|
append _session_group_287 icache_contrller_fsm
gui_sg_create "$_session_group_287"
set icache|icache_contrller_fsm "$_session_group_287"

gui_sg_addsignal -group "$_session_group_287" { tb_stages.uut_icache.icache_contrller_fsm.clk tb_stages.uut_icache.icache_contrller_fsm.rst tb_stages.uut_icache.icache_contrller_fsm.IC_miss_i tb_stages.uut_icache.icache_contrller_fsm.I_VC_Miss_i tb_stages.uut_icache.icache_contrller_fsm.mem_valid_i tb_stages.uut_icache.icache_contrller_fsm.en_i tb_stages.uut_icache.icache_contrller_fsm.S_0 tb_stages.uut_icache.icache_contrller_fsm.S_1 tb_stages.uut_icache.icache_contrller_fsm.S_2 tb_stages.uut_icache.icache_contrller_fsm.LD_IC_SWAP_BUF_o tb_stages.uut_icache.icache_contrller_fsm.RD_I_VC_SWAP_BUF_o tb_stages.uut_icache.icache_contrller_fsm.busy_o tb_stages.uut_icache.icache_contrller_fsm.MakeReq_o tb_stages.uut_icache.icache_contrller_fsm.Fill0EN_o tb_stages.uut_icache.icache_contrller_fsm.Fill1EN_o tb_stages.uut_icache.icache_contrller_fsm.Fill2EN_o tb_stages.uut_icache.icache_contrller_fsm.Fill3EN_o tb_stages.uut_icache.icache_contrller_fsm.NS_0 tb_stages.uut_icache.icache_contrller_fsm.NS_1 tb_stages.uut_icache.icache_contrller_fsm.NS_2 tb_stages.uut_icache.icache_contrller_fsm.I_VC_Miss_i_inv tb_stages.uut_icache.icache_contrller_fsm.S_0_inv tb_stages.uut_icache.icache_contrller_fsm.S_1_inv tb_stages.uut_icache.icache_contrller_fsm.S_2_inv tb_stages.uut_icache.icache_contrller_fsm.mem_valid_i_inv tb_stages.uut_icache.icache_contrller_fsm.NS_0_t0 tb_stages.uut_icache.icache_contrller_fsm.NS_0_t1 tb_stages.uut_icache.icache_contrller_fsm.NS_0_t2 tb_stages.uut_icache.icache_contrller_fsm.NS_1_t0 tb_stages.uut_icache.icache_contrller_fsm.NS_1_t1 tb_stages.uut_icache.icache_contrller_fsm.NS_1_t2 tb_stages.uut_icache.icache_contrller_fsm.NS_2_t0 tb_stages.uut_icache.icache_contrller_fsm.NS_2_t1 tb_stages.uut_icache.icache_contrller_fsm.NS_2_t2 tb_stages.uut_icache.icache_contrller_fsm.NS_2_t3 tb_stages.uut_icache.icache_contrller_fsm.busy_o_t0 tb_stages.uut_icache.icache_contrller_fsm.busy_o_t1 tb_stages.uut_icache.icache_contrller_fsm.busy_o_t2 }

gui_sg_move "$_session_group_287" -after "$_session_group_282" -pos 2 

set _session_group_288 core
gui_sg_create "$_session_group_288"
set core "$_session_group_288"

gui_sg_addsignal -group "$_session_group_288" { }

set _session_group_289 $_session_group_288|
append _session_group_289 mem_unit
gui_sg_create "$_session_group_289"
set core|mem_unit "$_session_group_289"

gui_sg_addsignal -group "$_session_group_289" { {tb_stages.uut_core.mem_unit.$unit} tb_stages.uut_core.mem_unit.clk tb_stages.uut_core.mem_unit.rst tb_stages.uut_core.mem_unit.hit_line_0 tb_stages.uut_core.mem_unit.line_0 tb_stages.uut_core.mem_unit.hit_line_1 tb_stages.uut_core.mem_unit.line_1 tb_stages.uut_core.mem_unit.hit_line_MMIO tb_stages.uut_core.mem_unit.line_MMIO tb_stages.uut_core.mem_unit.ld_buf tb_stages.uut_core.mem_unit.C0 tb_stages.uut_core.mem_unit.up_buf tb_stages.uut_core.mem_unit.low_buf tb_stages.uut_core.mem_unit.miss_stall tb_stages.uut_core.mem_unit.exe_stage_we_valid_unit_o tb_stages.uut_core.mem_unit.exe_stage_next_vaild_o tb_stages.uut_core.mem_unit.latches_i tb_stages.uut_core.mem_unit.exe_outs_i tb_stages.uut_core.mem_unit.wb_outs_i tb_stages.uut_core.mem_unit.exe_latches_next_o tb_stages.uut_core.mem_unit.outs_o }

gui_sg_move "$_session_group_289" -after "$_session_group_288" -pos 9 

set _session_group_290 $_session_group_288|
append _session_group_290 mem_latches_unit
gui_sg_create "$_session_group_290"
set core|mem_latches_unit "$_session_group_290"

gui_sg_addsignal -group "$_session_group_290" { tb_stages.uut_core.mem_latches_unit.clk tb_stages.uut_core.mem_latches_unit.rst tb_stages.uut_core.mem_latches_unit.write_enable_i tb_stages.uut_core.mem_latches_unit.flush tb_stages.uut_core.mem_latches_unit.farFlush tb_stages.uut_core.mem_latches_unit.nextLatches_i tb_stages.uut_core.mem_latches_unit.latches_o tb_stages.uut_core.mem_latches_unit.latches }

gui_sg_move "$_session_group_290" -after "$_session_group_288" -pos 8 

set _session_group_291 $_session_group_288|
append _session_group_291 dc_unit
gui_sg_create "$_session_group_291"
set core|dc_unit "$_session_group_291"

gui_sg_addsignal -group "$_session_group_291" { tb_stages.uut_core.dc_unit.mem_latches_next_o tb_stages.uut_core.dc_unit.dep_stall tb_stages.uut_core.dc_unit.mem_stage_we_valid_unit_o tb_stages.uut_core.dc_unit.mem_ST_OP tb_stages.uut_core.dc_unit.latches_i tb_stages.uut_core.dc_unit.ld_addr_0_V tb_stages.uut_core.dc_unit.req_rejected_0 tb_stages.uut_core.dc_unit.mem_stage_next_vaild_o tb_stages.uut_core.dc_unit.stq_stall tb_stages.uut_core.dc_unit.req_rejected_1 tb_stages.uut_core.dc_unit.ld_addr_1_V tb_stages.uut_core.dc_unit.dc_ST_OP tb_stages.uut_core.dc_unit.ld_addr_0 tb_stages.uut_core.dc_unit.ld_addr_1 tb_stages.uut_core.dc_unit.in_flight_stall tb_stages.uut_core.dc_unit.exe_outs_i tb_stages.uut_core.dc_unit.arb_stall tb_stages.uut_core.dc_unit.clk tb_stages.uut_core.dc_unit.dc_outs_o tb_stages.uut_core.dc_unit.wb_outs_i tb_stages.uut_core.dc_unit.mem_outs_i tb_stages.uut_core.dc_unit.req_rejected_mio tb_stages.uut_core.dc_unit.dc_stall tb_stages.uut_core.dc_unit.exe_ST_OP {tb_stages.uut_core.dc_unit.$unit} tb_stages.uut_core.dc_unit.wb_ST_OP tb_stages.uut_core.dc_unit.rst }

gui_sg_move "$_session_group_291" -after "$_session_group_288" -pos 7 

set _session_group_292 $_session_group_288|
append _session_group_292 dc_latches_unit
gui_sg_create "$_session_group_292"
set core|dc_latches_unit "$_session_group_292"

gui_sg_addsignal -group "$_session_group_292" { tb_stages.uut_core.dc_latches_unit.clk tb_stages.uut_core.dc_latches_unit.rst tb_stages.uut_core.dc_latches_unit.write_enable_i tb_stages.uut_core.dc_latches_unit.flush tb_stages.uut_core.dc_latches_unit.farFlush tb_stages.uut_core.dc_latches_unit.nextLatches_i tb_stages.uut_core.dc_latches_unit.latches_o tb_stages.uut_core.dc_latches_unit.latches }

gui_sg_move "$_session_group_292" -after "$_session_group_288" -pos 6 

set _session_group_293 $_session_group_288|
append _session_group_293 rr_unit
gui_sg_create "$_session_group_293"
set core|rr_unit "$_session_group_293"

gui_sg_addsignal -group "$_session_group_293" { {tb_stages.uut_core.rr_unit.$unit} tb_stages.uut_core.rr_unit.SEGMENT_LIMITS tb_stages.uut_core.rr_unit.clk tb_stages.uut_core.rr_unit.rst tb_stages.uut_core.rr_unit.RR_GP tb_stages.uut_core.rr_unit.ecx_sb tb_stages.uut_core.rr_unit.cs_sb tb_stages.uut_core.rr_unit.depstall tb_stages.uut_core.rr_unit.dc_latches_we tb_stages.uut_core.rr_unit.next_dc_valid tb_stages.uut_core.rr_unit.rr_stall tb_stages.uut_core.rr_unit.addygen_input_addy tb_stages.uut_core.rr_unit.latches_i tb_stages.uut_core.rr_unit.fetch_outs_i tb_stages.uut_core.rr_unit.decode_outs_i tb_stages.uut_core.rr_unit.dc_outs_i tb_stages.uut_core.rr_unit.mem_outs_i tb_stages.uut_core.rr_unit.exe_outs_i tb_stages.uut_core.rr_unit.wb_outs_i tb_stages.uut_core.rr_unit.dc_latches_next tb_stages.uut_core.rr_unit.outs_o tb_stages.uut_core.rr_unit.latchesInUse tb_stages.uut_core.rr_unit.reg_out }

gui_sg_move "$_session_group_293" -after "$_session_group_288" -pos 5 

set _session_group_294 $_session_group_293|
append _session_group_294 RegisterFile_unit
gui_sg_create "$_session_group_294"
set core|rr_unit|RegisterFile_unit "$_session_group_294"

gui_sg_addsignal -group "$_session_group_294" { {tb_stages.uut_core.rr_unit.RegisterFile_unit.$unit} tb_stages.uut_core.rr_unit.RegisterFile_unit.REGISTERS tb_stages.uut_core.rr_unit.RegisterFile_unit.clk tb_stages.uut_core.rr_unit.RegisterFile_unit.rst tb_stages.uut_core.rr_unit.RegisterFile_unit.DR_ID tb_stages.uut_core.rr_unit.RegisterFile_unit.SR_ID tb_stages.uut_core.rr_unit.RegisterFile_unit.SIB_IDX_ID tb_stages.uut_core.rr_unit.RegisterFile_unit.SIB_BASE_ID tb_stages.uut_core.rr_unit.RegisterFile_unit.WB_DR0_data tb_stages.uut_core.rr_unit.RegisterFile_unit.WB_DR1_data tb_stages.uut_core.rr_unit.RegisterFile_unit.WB_DR0_ID tb_stages.uut_core.rr_unit.RegisterFile_unit.WB_DR1_ID tb_stages.uut_core.rr_unit.RegisterFile_unit.WB_DR0_we tb_stages.uut_core.rr_unit.RegisterFile_unit.WB_DR1_we tb_stages.uut_core.rr_unit.RegisterFile_unit.Segment0_ID tb_stages.uut_core.rr_unit.RegisterFile_unit.Segment1_ID tb_stages.uut_core.rr_unit.RegisterFile_unit.outputs }

gui_sg_move "$_session_group_294" -after "$_session_group_293" -pos 6 

set _session_group_295 $_session_group_293|
append _session_group_295 reg_sb_unit
gui_sg_create "$_session_group_295"
set core|rr_unit|reg_sb_unit "$_session_group_295"

gui_sg_addsignal -group "$_session_group_295" { {tb_stages.uut_core.rr_unit.reg_sb_unit.$unit} tb_stages.uut_core.rr_unit.reg_sb_unit.dep_stall tb_stages.uut_core.rr_unit.reg_sb_unit.ecx_sb tb_stages.uut_core.rr_unit.reg_sb_unit.codeSeg_sb tb_stages.uut_core.rr_unit.reg_sb_unit.clk tb_stages.uut_core.rr_unit.reg_sb_unit.rst tb_stages.uut_core.rr_unit.reg_sb_unit.dr_id tb_stages.uut_core.rr_unit.reg_sb_unit.sr_id tb_stages.uut_core.rr_unit.reg_sb_unit.sib_base_id tb_stages.uut_core.rr_unit.reg_sb_unit.sib_idx_id tb_stages.uut_core.rr_unit.reg_sb_unit.wb_dr0_id tb_stages.uut_core.rr_unit.reg_sb_unit.wb_dr0_we tb_stages.uut_core.rr_unit.reg_sb_unit.wb_dr1_id tb_stages.uut_core.rr_unit.reg_sb_unit.wb_dr1_we tb_stages.uut_core.rr_unit.reg_sb_unit.cs_sib_size tb_stages.uut_core.rr_unit.reg_sb_unit.cs_dr_wr tb_stages.uut_core.rr_unit.reg_sb_unit.cs_sr_wr tb_stages.uut_core.rr_unit.reg_sb_unit.cs_dr_rd tb_stages.uut_core.rr_unit.reg_sb_unit.cs_sr_rd tb_stages.uut_core.rr_unit.reg_sb_unit.Segment0_ID tb_stages.uut_core.rr_unit.reg_sb_unit.Segment1_ID tb_stages.uut_core.rr_unit.reg_sb_unit.Segment1_valid tb_stages.uut_core.rr_unit.reg_sb_unit.flush tb_stages.uut_core.rr_unit.reg_sb_unit.farFlush tb_stages.uut_core.rr_unit.reg_sb_unit.depStall_Internal tb_stages.uut_core.rr_unit.reg_sb_unit.dr_stall tb_stages.uut_core.rr_unit.reg_sb_unit.sr_stall tb_stages.uut_core.rr_unit.reg_sb_unit.seg0_stall tb_stages.uut_core.rr_unit.reg_sb_unit.seg1_stall tb_stages.uut_core.rr_unit.reg_sb_unit.sib_base_stall tb_stages.uut_core.rr_unit.reg_sb_unit.sib_idx_stall tb_stages.uut_core.rr_unit.reg_sb_unit.SCORE_BOARD }

gui_sg_move "$_session_group_295" -after "$_session_group_293" -pos 5 

set _session_group_296 $_session_group_288|
append _session_group_296 rr_latches_unit
gui_sg_create "$_session_group_296"
set core|rr_latches_unit "$_session_group_296"

gui_sg_addsignal -group "$_session_group_296" { tb_stages.uut_core.rr_latches_unit.clk tb_stages.uut_core.rr_latches_unit.rst tb_stages.uut_core.rr_latches_unit.write_enable_i tb_stages.uut_core.rr_latches_unit.flush tb_stages.uut_core.rr_latches_unit.farFlush tb_stages.uut_core.rr_latches_unit.nextLatches_i tb_stages.uut_core.rr_latches_unit.latches_o tb_stages.uut_core.rr_latches_unit.latches }

gui_sg_move "$_session_group_296" -after "$_session_group_288" -pos 4 

set _session_group_297 $_session_group_288|
append _session_group_297 decode_unit
gui_sg_create "$_session_group_297"
set core|decode_unit "$_session_group_297"

gui_sg_addsignal -group "$_session_group_297" { tb_stages.uut_core.decode_unit.EIP tb_stages.uut_core.decode_unit.clk tb_stages.uut_core.decode_unit.rst tb_stages.uut_core.decode_unit.PrevEIP tb_stages.uut_core.decode_unit.NEIP tb_stages.uut_core.decode_unit.inst_length tb_stages.uut_core.decode_unit.PrevLength tb_stages.uut_core.decode_unit.sib_byte tb_stages.uut_core.decode_unit.sib_size tb_stages.uut_core.decode_unit.disp_needed tb_stages.uut_core.decode_unit.displacement tb_stages.uut_core.decode_unit.disp_size tb_stages.uut_core.decode_unit.imm64 tb_stages.uut_core.decode_unit.total_pf_vector tb_stages.uut_core.decode_unit.invalid_inst tb_stages.uut_core.decode_unit.opcode_byte tb_stages.uut_core.decode_unit.modrm_byte tb_stages.uut_core.decode_unit.decode_gp tb_stages.uut_core.decode_unit.flush tb_stages.uut_core.decode_unit.REP_LATCH tb_stages.uut_core.decode_unit.REP_CMP_LATCH tb_stages.uut_core.decode_unit.HALT_REG tb_stages.uut_core.decode_unit.rr_latch_we_o tb_stages.uut_core.decode_unit.stall tb_stages.uut_core.decode_unit.queue tb_stages.uut_core.decode_unit.predicted_taken tb_stages.uut_core.decode_unit.predicted_target tb_stages.uut_core.decode_unit.sibbase tb_stages.uut_core.decode_unit.sibidx tb_stages.uut_core.decode_unit.sibscale tb_stages.uut_core.decode_unit.rep_reg_value tb_stages.uut_core.decode_unit.next_rr_valid tb_stages.uut_core.decode_unit.segment0 tb_stages.uut_core.decode_unit.idm_outs_i tb_stages.uut_core.decode_unit.fetch_outs_i tb_stages.uut_core.decode_unit.rr_outs_i tb_stages.uut_core.decode_unit.dc_outs_i tb_stages.uut_core.decode_unit.mem_outs_i tb_stages.uut_core.decode_unit.exe_outs_i tb_stages.uut_core.decode_unit.wb_outs_i tb_stages.uut_core.decode_unit.rr_latches_next tb_stages.uut_core.decode_unit.outs_o tb_stages.uut_core.decode_unit.temp_decode_cs tb_stages.uut_core.decode_unit.temp_rr_cs tb_stages.uut_core.decode_unit.temp_dc_cs tb_stages.uut_core.decode_unit.temp_mem_cs tb_stages.uut_core.decode_unit.temp_exe_cs tb_stages.uut_core.decode_unit.temp_wb_cs tb_stages.uut_core.decode_unit.temp_rr_latch tb_stages.uut_core.decode_unit.br_info_for_latches tb_stages.uut_core.decode_unit.rep_latch_holder {tb_stages.uut_core.decode_unit.$unit} }

gui_sg_move "$_session_group_297" -after "$_session_group_288" -pos 3 

set _session_group_298 $_session_group_297|
append _session_group_298 mod_rm_cs_gen
gui_sg_create "$_session_group_298"
set core|decode_unit|mod_rm_cs_gen "$_session_group_298"

gui_sg_addsignal -group "$_session_group_298" { {tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.$unit} tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.modrm_byte tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.datasize tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.dr_id tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.sr_id tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.dr_rd tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.sr_rd tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.dr_wr tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.sr_wr tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.ld_op tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.st_op tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.reg_is_dr tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.reg_is_segment tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.alu_inputA_override tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.alu_inputB_override tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.high8 tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.alu_inputA_override_sel tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.alu_inputB_override_sel tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.rm_is_dr tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.decode_cs_inputs tb_stages.uut_core.decode_unit.cs.mod_rm_cs_gen.outputs }

gui_sg_move "$_session_group_298" -after "$_session_group_297" -pos 52 

set _session_group_299 $_session_group_288|
append _session_group_299 idm_unit
gui_sg_create "$_session_group_299"
set core|idm_unit "$_session_group_299"

gui_sg_addsignal -group "$_session_group_299" { tb_stages.uut_core.idm_unit.clk tb_stages.uut_core.idm_unit.rst tb_stages.uut_core.idm_unit.fetch_outs_i tb_stages.uut_core.idm_unit.idm_outs_o tb_stages.uut_core.idm_unit.idm }

gui_sg_move "$_session_group_299" -after "$_session_group_288" -pos 2 

set _session_group_300 $_session_group_288|
append _session_group_300 fetch_unit
gui_sg_create "$_session_group_300"
set core|fetch_unit "$_session_group_300"

gui_sg_addsignal -group "$_session_group_300" { tb_stages.uut_core.fetch_unit.SPC tb_stages.uut_core.fetch_unit.clk tb_stages.uut_core.fetch_unit.rst tb_stages.uut_core.fetch_unit.dma_int tb_stages.uut_core.fetch_unit.exp_mode_jk tb_stages.uut_core.fetch_unit.int_mode_jk tb_stages.uut_core.fetch_unit.DMA_int_jk tb_stages.uut_core.fetch_unit.f_exp tb_stages.uut_core.fetch_unit.seg_xlation_out tb_stages.uut_core.fetch_unit.rom_data_out tb_stages.uut_core.fetch_unit.idm_ctrl_data_in tb_stages.uut_core.fetch_unit.next_spc tb_stages.uut_core.fetch_unit.spc_16 tb_stages.uut_core.fetch_unit.br_restore_spc tb_stages.uut_core.fetch_unit.br_target tb_stages.uut_core.fetch_unit.spc_2_IDM_CTRL tb_stages.uut_core.fetch_unit.en_icache tb_stages.uut_core.fetch_unit.icache_info_i tb_stages.uut_core.fetch_unit.idm_info_i tb_stages.uut_core.fetch_unit.decode_outs_i tb_stages.uut_core.fetch_unit.rr_outs_i tb_stages.uut_core.fetch_unit.dc_outs_i tb_stages.uut_core.fetch_unit.mem_outs_i tb_stages.uut_core.fetch_unit.exe_outs_i tb_stages.uut_core.fetch_unit.wb_outs_i tb_stages.uut_core.fetch_unit.outs_o tb_stages.uut_core.fetch_unit.predictor_inputs tb_stages.uut_core.fetch_unit.tlb_inputs tb_stages.uut_core.fetch_unit.btb_outs tb_stages.uut_core.fetch_unit.spc_sel_logic_outs tb_stages.uut_core.fetch_unit.predictor_outs tb_stages.uut_core.fetch_unit.idm_ctrl_logic_outs tb_stages.uut_core.fetch_unit.idm_invalidate_logic_outs tb_stages.uut_core.fetch_unit.tlb_outs tb_stages.uut_core.fetch_unit.exp_set_logic_outs }

gui_sg_move "$_session_group_300" -after "$_session_group_288" -pos 1 

set _session_group_301 $_session_group_288|
append _session_group_301 execute_unit
gui_sg_create "$_session_group_301"
set core|execute_unit "$_session_group_301"

gui_sg_addsignal -group "$_session_group_301" { {tb_stages.uut_core.execute_unit.$unit} tb_stages.uut_core.execute_unit.clk tb_stages.uut_core.execute_unit.rst tb_stages.uut_core.execute_unit.clr_ZF_sb tb_stages.uut_core.execute_unit.wb_stage_we_valid_unit_o tb_stages.uut_core.execute_unit.wb_stage_next_vaild_o tb_stages.uut_core.execute_unit.op_type tb_stages.uut_core.execute_unit.data_size tb_stages.uut_core.execute_unit.flags_reg tb_stages.uut_core.execute_unit.srA tb_stages.uut_core.execute_unit.srB tb_stages.uut_core.execute_unit.br_sel tb_stages.uut_core.execute_unit.res_buf_next tb_stages.uut_core.execute_unit.bit_vec_0_next tb_stages.uut_core.execute_unit.bit_vec_1_next tb_stages.uut_core.execute_unit.dr_next tb_stages.uut_core.execute_unit.sr_next tb_stages.uut_core.execute_unit.wb_dr_next tb_stages.uut_core.execute_unit.wb_sr_next tb_stages.uut_core.execute_unit.st_op_next tb_stages.uut_core.execute_unit.res_buf_selected tb_stages.uut_core.execute_unit.cancel_dr_we tb_stages.uut_core.execute_unit.cancel_sr_we tb_stages.uut_core.execute_unit.cancel_store tb_stages.uut_core.execute_unit.aaa_dr_o tb_stages.uut_core.execute_unit.adc_dr_o tb_stages.uut_core.execute_unit.adc_res_buf_o tb_stages.uut_core.execute_unit.add_dr_o tb_stages.uut_core.execute_unit.add_res_buf_o tb_stages.uut_core.execute_unit.and_dr_o tb_stages.uut_core.execute_unit.and_res_buf_o tb_stages.uut_core.execute_unit.bsf_dr_o tb_stages.uut_core.execute_unit.bsf_res_buf_o tb_stages.uut_core.execute_unit.call_dr_o tb_stages.uut_core.execute_unit.call_res_buf tb_stages.uut_core.execute_unit.cmpxchg_sr_o tb_stages.uut_core.execute_unit.cmpxchg_dr_o tb_stages.uut_core.execute_unit.cmpxchg_buf_o tb_stages.uut_core.execute_unit.far_call_dr_o tb_stages.uut_core.execute_unit.far_call_res_buf tb_stages.uut_core.execute_unit.iretd_cs_o tb_stages.uut_core.execute_unit.iretd_stack_ptr_o tb_stages.uut_core.execute_unit.mov_dr_o tb_stages.uut_core.execute_unit.mov_res_buf_o tb_stages.uut_core.execute_unit.not_dr_o tb_stages.uut_core.execute_unit.not_res_buf_o tb_stages.uut_core.execute_unit.or_dr_o tb_stages.uut_core.execute_unit.or_res_buf_o tb_stages.uut_core.execute_unit.packssdw_dr_o tb_stages.uut_core.execute_unit.packsswb_dr_o tb_stages.uut_core.execute_unit.paddd_dr_o tb_stages.uut_core.execute_unit.paddw_dr_o tb_stages.uut_core.execute_unit.pavgb_dr_o tb_stages.uut_core.execute_unit.pavgw_dr_o tb_stages.uut_core.execute_unit.pop_dr_o tb_stages.uut_core.execute_unit.pop_sr_o tb_stages.uut_core.execute_unit.push_res_buf tb_stages.uut_core.execute_unit.push_sr_o tb_stages.uut_core.execute_unit.ret_far_imm_dr_o tb_stages.uut_core.execute_unit.ret_far_imm_sr_o tb_stages.uut_core.execute_unit.ret_far_cs_o tb_stages.uut_core.execute_unit.ret_far_next_ptr_o tb_stages.uut_core.execute_unit.ret_imm_sr_o tb_stages.uut_core.execute_unit.ret_sr_o tb_stages.uut_core.execute_unit.sal_dr_o tb_stages.uut_core.execute_unit.sal_res_buf_o tb_stages.uut_core.execute_unit.sar_dr_o tb_stages.uut_core.execute_unit.sar_res_buf_o tb_stages.uut_core.execute_unit.sbb_dr_o tb_stages.uut_core.execute_unit.sbb_res_buf_o tb_stages.uut_core.execute_unit.xchg_dr_o tb_stages.uut_core.execute_unit.xchg_sr_o tb_stages.uut_core.execute_unit.xchg_res_buf tb_stages.uut_core.execute_unit.aaa_af_o tb_stages.uut_core.execute_unit.aaa_cf_o tb_stages.uut_core.execute_unit.adc_af_o tb_stages.uut_core.execute_unit.adc_cf_o tb_stages.uut_core.execute_unit.adc_of_o tb_stages.uut_core.execute_unit.adc_pf_o tb_stages.uut_core.execute_unit.adc_sf_o tb_stages.uut_core.execute_unit.adc_zf_o tb_stages.uut_core.execute_unit.add_af_o tb_stages.uut_core.execute_unit.add_cf_o tb_stages.uut_core.execute_unit.add_of_o tb_stages.uut_core.execute_unit.add_pf_o tb_stages.uut_core.execute_unit.add_sf_o tb_stages.uut_core.execute_unit.add_zf_o tb_stages.uut_core.execute_unit.and_of_o tb_stages.uut_core.execute_unit.and_pf_o tb_stages.uut_core.execute_unit.and_sf_o tb_stages.uut_core.execute_unit.and_zf_o tb_stages.uut_core.execute_unit.bsf_zf_o tb_stages.uut_core.execute_unit.cmp_cf_o }
gui_sg_addsignal -group "$_session_group_301" { tb_stages.uut_core.execute_unit.cmp_pf_o tb_stages.uut_core.execute_unit.cmp_af_o tb_stages.uut_core.execute_unit.cmp_zf_o tb_stages.uut_core.execute_unit.cmp_sf_o tb_stages.uut_core.execute_unit.cmp_of_o tb_stages.uut_core.execute_unit.cmpxchg_cf_o tb_stages.uut_core.execute_unit.cmpxchg_pf_o tb_stages.uut_core.execute_unit.cmpxchg_af_o tb_stages.uut_core.execute_unit.cmpxchg_zf_o tb_stages.uut_core.execute_unit.cmpxchg_sf_o tb_stages.uut_core.execute_unit.cmpxchg_of_o tb_stages.uut_core.execute_unit.or_cf_o tb_stages.uut_core.execute_unit.or_pf_o tb_stages.uut_core.execute_unit.or_zf_o tb_stages.uut_core.execute_unit.or_sf_o tb_stages.uut_core.execute_unit.or_of_o tb_stages.uut_core.execute_unit.sal_cf_o tb_stages.uut_core.execute_unit.sal_pf_o tb_stages.uut_core.execute_unit.sal_zf_o tb_stages.uut_core.execute_unit.sal_sf_o tb_stages.uut_core.execute_unit.sal_of_o tb_stages.uut_core.execute_unit.sar_cf_o tb_stages.uut_core.execute_unit.sar_pf_o tb_stages.uut_core.execute_unit.sar_zf_o tb_stages.uut_core.execute_unit.sar_sf_o tb_stages.uut_core.execute_unit.sar_of_o tb_stages.uut_core.execute_unit.sbb_cf_o tb_stages.uut_core.execute_unit.sbb_pf_o tb_stages.uut_core.execute_unit.sbb_af_o tb_stages.uut_core.execute_unit.sbb_zf_o tb_stages.uut_core.execute_unit.sbb_sf_o tb_stages.uut_core.execute_unit.sbb_of_o tb_stages.uut_core.execute_unit.iretd_cf_o tb_stages.uut_core.execute_unit.iretd_pf_o tb_stages.uut_core.execute_unit.iretd_af_o tb_stages.uut_core.execute_unit.iretd_zf_o tb_stages.uut_core.execute_unit.iretd_sf_o tb_stages.uut_core.execute_unit.iretd_of_o tb_stages.uut_core.execute_unit.af_flag_o tb_stages.uut_core.execute_unit.cf_flag_o tb_stages.uut_core.execute_unit.df_flag_o tb_stages.uut_core.execute_unit.of_flag_o tb_stages.uut_core.execute_unit.pf_flag_o tb_stages.uut_core.execute_unit.sf_flag_o tb_stages.uut_core.execute_unit.zf_flag_o tb_stages.uut_core.execute_unit.latches_i tb_stages.uut_core.execute_unit.wb_outs_i tb_stages.uut_core.execute_unit.wb_latches_next_o tb_stages.uut_core.execute_unit.outs_o tb_stages.uut_core.execute_unit.branch_resolution_o }

gui_sg_move "$_session_group_301" -after "$_session_group_288" -pos 11 

set _session_group_302 $_session_group_288|
append _session_group_302 write_back_unit
gui_sg_create "$_session_group_302"
set core|write_back_unit "$_session_group_302"

gui_sg_addsignal -group "$_session_group_302" { {tb_stages.uut_core.write_back_unit.$unit} tb_stages.uut_core.write_back_unit.clk tb_stages.uut_core.write_back_unit.rst tb_stages.uut_core.write_back_unit.write_success tb_stages.uut_core.write_back_unit.write_success_mio tb_stages.uut_core.write_back_unit.stall_flop tb_stages.uut_core.write_back_unit.stall_flop_next tb_stages.uut_core.write_back_unit.stq_outputs tb_stages.uut_core.write_back_unit.wb_latches tb_stages.uut_core.write_back_unit.outputs tb_stages.uut_core.write_back_unit.stq_info tb_stages.uut_core.write_back_unit.mio_q_input tb_stages.uut_core.write_back_unit.reg_wb_logic_outs tb_stages.uut_core.write_back_unit.dc_dep tb_stages.uut_core.write_back_unit.stq_heads tb_stages.uut_core.write_back_unit.mio_q_output }

gui_sg_move "$_session_group_302" -after "$_session_group_288" -pos 13 

set _session_group_303 $_session_group_302|
append _session_group_303 reg_wb
gui_sg_create "$_session_group_303"
set core|write_back_unit|reg_wb "$_session_group_303"

gui_sg_addsignal -group "$_session_group_303" { {tb_stages.uut_core.write_back_unit.reg_wb.$unit} tb_stages.uut_core.write_back_unit.reg_wb.stall_flop tb_stages.uut_core.write_back_unit.reg_wb.reg_info tb_stages.uut_core.write_back_unit.reg_wb.outs }

gui_sg_move "$_session_group_303" -after "$_session_group_302" -pos 13 

set _session_group_304 $_session_group_288|
append _session_group_304 uut_core
gui_sg_create "$_session_group_304"
set core|uut_core "$_session_group_304"

gui_sg_addsignal -group "$_session_group_304" { {tb_stages.uut_core.$unit} tb_stages.uut_core.clk tb_stages.uut_core.rst tb_stages.uut_core.ICacheIn_i tb_stages.uut_core.out2ICache_o tb_stages.uut_core.DCacheIn_i tb_stages.uut_core.out2DCache_o tb_stages.uut_core.inFromDMA_i tb_stages.uut_core.idm_outputs tb_stages.uut_core.fetch_outputs tb_stages.uut_core.decode_outputs tb_stages.uut_core.rr_outputs tb_stages.uut_core.dc_outputs tb_stages.uut_core.mem_outputs tb_stages.uut_core.exe_outputs tb_stages.uut_core.wb_outputs tb_stages.uut_core.rr_latches tb_stages.uut_core.rr_latches_next tb_stages.uut_core.dc_latches tb_stages.uut_core.dc_latches_next tb_stages.uut_core.mem_latches tb_stages.uut_core.mem_latches_next tb_stages.uut_core.exe_latches tb_stages.uut_core.exe_latches_next tb_stages.uut_core.wb_latches tb_stages.uut_core.wb_latches_next }

set _session_group_305 $_session_group_288|
append _session_group_305 wb_latches_unit
gui_sg_create "$_session_group_305"
set core|wb_latches_unit "$_session_group_305"

gui_sg_addsignal -group "$_session_group_305" { {tb_stages.uut_core.wb_latches_unit.$unit} tb_stages.uut_core.wb_latches_unit.clk tb_stages.uut_core.wb_latches_unit.rst tb_stages.uut_core.wb_latches_unit.write_enable_i tb_stages.uut_core.wb_latches_unit.nextLatches_i tb_stages.uut_core.wb_latches_unit.latches_o tb_stages.uut_core.wb_latches_unit.latches }

gui_sg_move "$_session_group_305" -after "$_session_group_288" -pos 12 

set _session_group_306 $_session_group_288|
append _session_group_306 exe_latches_unit
gui_sg_create "$_session_group_306"
set core|exe_latches_unit "$_session_group_306"

gui_sg_addsignal -group "$_session_group_306" { {tb_stages.uut_core.exe_latches_unit.$unit} tb_stages.uut_core.exe_latches_unit.clk tb_stages.uut_core.exe_latches_unit.rst tb_stages.uut_core.exe_latches_unit.write_enable_i tb_stages.uut_core.exe_latches_unit.flush tb_stages.uut_core.exe_latches_unit.farFlush tb_stages.uut_core.exe_latches_unit.nextLatches_i tb_stages.uut_core.exe_latches_unit.latches_o tb_stages.uut_core.exe_latches_unit.latches }

gui_sg_move "$_session_group_306" -after "$_session_group_288" -pos 10 

set _session_group_307 Group1
gui_sg_create "$_session_group_307"
set Group1 "$_session_group_307"

>>>>>>> 092ccefeba40bd12f97cd06dfb88c904c12ccb03

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
<<<<<<< HEAD
gui_set_time -C1_only 505000
=======
gui_set_time -C1_only 905078
>>>>>>> 092ccefeba40bd12f97cd06dfb88c904c12ccb03



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
gui_list_set_filter -id ${Hier.1} -list { {Package 1} {All 0} {Process 1} {VirtPowSwitch 0} {UnnamedProcess 1} {UDP 0} {Function 0} {Block 1} {SrsnAndSpaCell 0} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {LeafVhdCell 1} {$unit 1} {NamedBlock 1} {Task 0} {VlgPackage 0} {ClassDef 1} {VirtIsoCell 0} }
gui_list_set_filter -id ${Hier.1} -text {*}
gui_hier_list_init -id ${Hier.1}
gui_change_design -id ${Hier.1} -design V1
catch {gui_list_expand -id ${Hier.1} tb_stages}
catch {gui_list_expand -id ${Hier.1} tb_stages.uut_core}
catch {gui_list_expand -id ${Hier.1} tb_stages.uut_core.rr_unit}
catch {gui_list_select -id ${Hier.1} {tb_stages.uut_core.rr_unit.RegisterFile_unit}}
gui_view_scroll -id ${Hier.1} -vertical -set 156
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
<<<<<<< HEAD
gui_open_source -id ${Source.1}  -replace -active tb_stages.uut_core.dc_unit /home/ecelrc/students/je28497/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/DC/DC.sv
gui_view_scroll -id ${Source.1} -vertical -set 0
=======
gui_open_source -id ${Source.1}  -replace -active tb_stages tb_stages.sv
gui_view_scroll -id ${Source.1} -vertical -set 168
>>>>>>> 092ccefeba40bd12f97cd06dfb88c904c12ccb03
gui_src_set_reusable -id ${Source.1}

# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_create -id ${Wave.1} M1 445098
gui_marker_set_ref -id ${Wave.1}  C1
<<<<<<< HEAD
gui_wv_zoom_timerange -id ${Wave.1} 477570 533315
=======
gui_wv_zoom_timerange -id ${Wave.1} 366635 999056
>>>>>>> 092ccefeba40bd12f97cd06dfb88c904c12ccb03
gui_list_add_group -id ${Wave.1} -after {New Group} {busArb}
gui_list_add_group -id ${Wave.1}  -after busArb {busArb|scheduler_unit}
gui_list_add_group -id ${Wave.1} -after busArb|scheduler_unit {busArb|dte_unit}
gui_list_add_group -id ${Wave.1} -after busArb|dte_unit {busArb|uut4_busArb}
gui_list_add_group -id ${Wave.1} -after {New Group} {dcache}
gui_list_add_group -id ${Wave.1}  -after dcache {dcache|uut_dcache}
gui_list_add_group -id ${Wave.1} -after dcache|uut_dcache {dcache|mio_block_unit}
gui_list_add_group -id ${Wave.1} -after dcache|mio_block_unit {{dcache|g_dcache_block[3].block}}
gui_list_add_group -id ${Wave.1} -after {{dcache|g_dcache_block[3].block}} {dcache|dcache_arbitration}
gui_list_add_group -id ${Wave.1} -after dcache|dcache_arbitration {{dcache|g_dcache_block[0].block}}
gui_list_add_group -id ${Wave.1} -after {{dcache|g_dcache_block[0].block}} {{dcache|g_dcache_block[1].block}}
gui_list_add_group -id ${Wave.1} -after {{dcache|g_dcache_block[1].block}} {{dcache|g_dcache_block[2].block}}
gui_list_add_group -id ${Wave.1} -after {New Group} {icache}
gui_list_add_group -id ${Wave.1}  -after icache {icache|uut_icache}
gui_list_add_group -id ${Wave.1} -after icache|uut_icache {icache|icache_dataStore_unit}
gui_list_add_group -id ${Wave.1} -after icache|icache_dataStore_unit {icache|icache_contrller_fsm}
gui_list_add_group -id ${Wave.1} -after icache|icache_contrller_fsm {icache|icache_TagStore_unit}
gui_list_add_group -id ${Wave.1} -after icache|icache_TagStore_unit {icache|i_vcache_unit}
gui_list_add_group -id ${Wave.1} -after {New Group} {core}
<<<<<<< HEAD
gui_list_add_group -id ${Wave.1}  -after core {core|dc_unit}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_core.dc_unit.mem_latches_next_o {core|dc_unit|ld_neuralnet_part2}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_core.dc_unit.mem_ST_OP {core|dc_unit|mem_valid_unit}
gui_list_add_group -id ${Wave.1} -after core|dc_unit {core|uut_core}
gui_list_add_group -id ${Wave.1} -after core|uut_core {core|rr_unit}
gui_list_add_group -id ${Wave.1}  -after core|rr_unit {core|rr_unit|RegisterFile_unit}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_core.rr_unit.clk {core|rr_unit|reg_sb_unit}
gui_list_add_group -id ${Wave.1} -after core|rr_unit {core|rr_latches_unit}
gui_list_add_group -id ${Wave.1} -after core|rr_latches_unit {core|mem_latches_unit}
gui_list_add_group -id ${Wave.1} -after core|mem_latches_unit {core|idm_unit}
gui_list_add_group -id ${Wave.1} -after core|idm_unit {core|fetch_unit}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_core.fetch_unit.en_icache {core|fetch_unit|exp_set_logic}
gui_list_add_group -id ${Wave.1} -after core|fetch_unit {core|decode_unit}
gui_list_add_group -id ${Wave.1} -after core|decode_unit {core|wb_latches_unit}
gui_list_add_group -id ${Wave.1} -after core|wb_latches_unit {core|write_back_unit}
gui_list_add_group -id ${Wave.1}  -after core|write_back_unit {core|write_back_unit|st_q_mio_logic}
gui_list_add_group -id ${Wave.1} -after core|write_back_unit|st_q_mio_logic {core|write_back_unit|st_q_logic}
gui_list_add_group -id ${Wave.1} -after core|write_back_unit|st_q_logic {core|write_back_unit|reg_wb}
gui_list_add_group -id ${Wave.1} -after core|write_back_unit|reg_wb {core|write_back_unit|mio_q_inst}
gui_list_add_group -id ${Wave.1} -after core|write_back_unit|mio_q_inst {{core|write_back_unit|gen_st_q[3].stq_inst}}
gui_list_add_group -id ${Wave.1} -after {{core|write_back_unit|gen_st_q[3].stq_inst}} {{core|write_back_unit|gen_st_q[2].stq_inst}}
gui_list_add_group -id ${Wave.1} -after {{core|write_back_unit|gen_st_q[2].stq_inst}} {{core|write_back_unit|gen_st_q[1].stq_inst}}
gui_list_add_group -id ${Wave.1} -after {{core|write_back_unit|gen_st_q[1].stq_inst}} {{core|write_back_unit|gen_st_q[0].stq_inst}}
gui_list_add_group -id ${Wave.1} -after core|write_back_unit {core|dc_latches_unit}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group1}
gui_list_add_group -id ${Wave.1} -after {New Group} {execute_unit}
=======
gui_list_add_group -id ${Wave.1}  -after core {core|uut_core}
gui_list_add_group -id ${Wave.1} -after core|uut_core {core|fetch_unit}
gui_list_add_group -id ${Wave.1} -after core|fetch_unit {core|idm_unit}
gui_list_add_group -id ${Wave.1} -after core|idm_unit {core|decode_unit}
gui_list_add_group -id ${Wave.1} -after {{tb_stages.uut_core.decode_unit.$unit}} {core|decode_unit|mod_rm_cs_gen}
gui_list_add_group -id ${Wave.1} -after core|decode_unit {core|rr_latches_unit}
gui_list_add_group -id ${Wave.1} -after core|rr_latches_unit {core|rr_unit}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_core.rr_unit.RR_GP {core|rr_unit|reg_sb_unit}
gui_list_add_group -id ${Wave.1} -after core|rr_unit|reg_sb_unit {core|rr_unit|RegisterFile_unit}
gui_list_add_group -id ${Wave.1} -after core|rr_unit {core|dc_latches_unit}
gui_list_add_group -id ${Wave.1} -after core|dc_latches_unit {core|dc_unit}
gui_list_add_group -id ${Wave.1} -after core|dc_unit {core|mem_latches_unit}
gui_list_add_group -id ${Wave.1} -after core|mem_latches_unit {core|mem_unit}
gui_list_add_group -id ${Wave.1} -after core|mem_unit {core|exe_latches_unit}
gui_list_add_group -id ${Wave.1} -after core|exe_latches_unit {core|execute_unit}
gui_list_add_group -id ${Wave.1} -after core|execute_unit {core|wb_latches_unit}
gui_list_add_group -id ${Wave.1} -after core|wb_latches_unit {core|write_back_unit}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_core.write_back_unit.reg_wb_logic_outs {core|write_back_unit|reg_wb}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group1}
>>>>>>> 092ccefeba40bd12f97cd06dfb88c904c12ccb03
gui_list_collapse -id ${Wave.1} busArb
gui_list_collapse -id ${Wave.1} dcache
gui_list_collapse -id ${Wave.1} icache
gui_list_collapse -id ${Wave.1} core|uut_core
<<<<<<< HEAD
gui_list_collapse -id ${Wave.1} core|rr_unit
gui_list_collapse -id ${Wave.1} core|rr_unit|RegisterFile_unit
gui_list_collapse -id ${Wave.1} core|rr_unit|reg_sb_unit
gui_list_collapse -id ${Wave.1} core|rr_latches_unit
gui_list_collapse -id ${Wave.1} core|mem_latches_unit
gui_list_collapse -id ${Wave.1} core|idm_unit
gui_list_collapse -id ${Wave.1} core|fetch_unit
gui_list_collapse -id ${Wave.1} core|wb_latches_unit
gui_list_collapse -id ${Wave.1} core|write_back_unit
gui_list_collapse -id ${Wave.1} core|write_back_unit|st_q_mio_logic
gui_list_collapse -id ${Wave.1} core|write_back_unit|st_q_logic
gui_list_collapse -id ${Wave.1} core|write_back_unit|reg_wb
gui_list_collapse -id ${Wave.1} core|write_back_unit|mio_q_inst
gui_list_collapse -id ${Wave.1} {core|write_back_unit|gen_st_q[3].stq_inst}
gui_list_collapse -id ${Wave.1} core|dc_latches_unit
gui_list_collapse -id ${Wave.1} execute_unit
gui_list_expand -id ${Wave.1} tb_stages.uut_core.decode_unit.rr_latches_next
gui_list_expand -id ${Wave.1} tb_stages.uut_core.decode_unit.rr_latches_next.normal_latches
gui_list_expand -id ${Wave.1} tb_stages.uut_core.decode_unit.rr_latches_next.normal_latches.cs
gui_list_select -id ${Wave.1} {tb_stages.uut_core.decode_unit.rr_latches_next.normal_latches.cs.sr_rd }
=======
gui_list_collapse -id ${Wave.1} core|fetch_unit
gui_list_collapse -id ${Wave.1} core|idm_unit
gui_list_collapse -id ${Wave.1} core|rr_latches_unit
gui_list_collapse -id ${Wave.1} core|rr_unit
gui_list_collapse -id ${Wave.1} core|dc_latches_unit
gui_list_collapse -id ${Wave.1} core|dc_unit
gui_list_collapse -id ${Wave.1} core|mem_latches_unit
gui_list_collapse -id ${Wave.1} core|mem_unit
gui_list_collapse -id ${Wave.1} core|execute_unit
gui_list_collapse -id ${Wave.1} core|wb_latches_unit
gui_list_collapse -id ${Wave.1} core|write_back_unit
gui_list_expand -id ${Wave.1} tb_stages.uut_core.exe_latches_unit.latches
gui_list_select -id ${Wave.1} {tb_stages.uut_core.decode_unit.HALT_REG }
>>>>>>> 092ccefeba40bd12f97cd06dfb88c904c12ccb03
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
<<<<<<< HEAD
gui_list_set_insertion_bar  -id ${Wave.1} -group core|write_back_unit  -position below

gui_marker_move -id ${Wave.1} {C1} 505000
gui_view_scroll -id ${Wave.1} -vertical -set 1141
gui_show_grid -id ${Wave.1} -enable false

# Hier 'Hier.1'
gui_show_window -window ${Hier.1}
gui_list_set_filter -id ${Hier.1} -list { {Package 1} {All 0} {Process 1} {VirtPowSwitch 0} {UnnamedProcess 1} {UDP 0} {Function 0} {Block 1} {SrsnAndSpaCell 0} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {LeafVhdCell 1} {$unit 1} {NamedBlock 0} {Task 0} {VlgPackage 0} {ClassDef 1} {VirtIsoCell 0} }
gui_list_set_filter -id ${Hier.1} -text {*}
gui_hier_list_init -id ${Hier.1}
gui_change_design -id ${Hier.1} -design V1
catch {gui_list_expand -id ${Hier.1} tb_stages}
catch {gui_list_expand -id ${Hier.1} tb_stages.uut_core}
catch {gui_list_expand -id ${Hier.1} tb_stages.uut_core.write_back_unit}
catch {gui_list_select -id ${Hier.1} {{tb_stages.uut_core.write_back_unit.gen_st_q[0].stq_inst}}}
gui_view_scroll -id ${Hier.1} -vertical -set 181
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {tb_stages.uut_core.write_back_unit.st_q_mio_logic}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 181
=======
gui_list_set_insertion_bar  -id ${Wave.1} -group core|rr_unit  -position in

gui_marker_move -id ${Wave.1} {C1} 905078
gui_view_scroll -id ${Wave.1} -vertical -set 175
gui_show_grid -id ${Wave.1} -enable false

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {tb_stages.uut_core.rr_unit.RegisterFile_unit}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 156
>>>>>>> 092ccefeba40bd12f97cd06dfb88c904c12ccb03
gui_view_scroll -id ${Hier.1} -horizontal -set 0
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

