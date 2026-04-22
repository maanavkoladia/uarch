# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Sun Apr 12 13:11:58 2026
# Designs open: 1
#   V1: vcdplus.vpd
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: tb_stages
#   Wave.1: 946 signals
#   Group count = 38
#   Group BusArb signal count = 3
#   Group MainMem signal count = 2
#   Group DCache signal count = 7
#   Group ICache signal count = 5
#   Group Core signal count = 14
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
gui_show_window -window ${TopLevel.1} -show_state normal -rect {{190 94} {1528 936}}

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
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 595]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 595
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 594} {height 535} {dock_state left} {dock_on_new_line true} {child_hier_colhier 407} {child_hier_coltype 179} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 333]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 333
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 693
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 332} {height 535} {dock_state left} {dock_on_new_line true} {child_data_colvariable 352} {child_data_colvalue 161} {child_data_coltype 159} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set HSPane.2 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 440]
catch { set Hier.2 [gui_share_window -id ${HSPane.2} -type Hier] }
gui_set_window_pref_key -window ${HSPane.2} -key dock_width -value_type integer -value 440
gui_set_window_pref_key -window ${HSPane.2} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.2} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.2} {{left 0} {top 0} {width 439} {height 535} {dock_state left} {dock_on_new_line true} {child_hier_colhier 335} {child_hier_coltype 107} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.2 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 505]
catch { set Data.2 [gui_share_window -id ${DLPane.2} -type Data] }
gui_set_window_pref_key -window ${DLPane.2} -key dock_width -value_type integer -value 505
gui_set_window_pref_key -window ${DLPane.2} -key dock_height -value_type integer -value 728
gui_set_window_pref_key -window ${DLPane.2} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.2} {{left 0} {top 0} {width 504} {height 535} {dock_state left} {dock_on_new_line true} {child_data_colvariable 279} {child_data_colvalue 57} {child_data_coltype 171} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 178]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 689
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 178
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 1338} {height 177} {dock_state bottom} {dock_on_new_line true}}
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
gui_show_window -window ${TopLevel.2} -show_state maximized -rect {{0 64} {1469 814}}

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
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 422} {child_wave_right 1042} {child_wave_colname 233} {child_wave_colvalue 185} {child_wave_col1 0} {child_wave_col2 1}}

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
gui_load_child_values {tb_stages.uut_icache.icache_contrller_fsm}
gui_load_child_values {tb_stages.uut_core.rr_unit}
gui_load_child_values {tb_stages.uut_dcache.g_dcache_block[1].block}
gui_load_child_values {tb_stages.uut_core}
gui_load_child_values {tb_stages.uut_mem.controller}
gui_load_child_values {tb_stages.uut4_busArb.scheduler_unit}
gui_load_child_values {tb_stages.uut_core.mem_latches_unit}
gui_load_child_values {tb_stages.uut4_busArb}
gui_load_child_values {tb_stages.uut_core.decode_unit.inst_processing}
gui_load_child_values {tb_stages.uut_icache.i_vcache_unit}
gui_load_child_values {tb_stages.uut_dcache}
gui_load_child_values {tb_stages.uut_core.dc_latches_unit}
gui_load_child_values {tb_stages.uut_core.rr_latches_unit}
gui_load_child_values {tb_stages.uut_dcache.g_dcache_block[3].block}
gui_load_child_values {tb_stages.uut_core.execute_unit}
gui_load_child_values {tb_stages.uut_core.write_back_unit}
gui_load_child_values {tb_stages.uut_dcache.g_dcache_block[0].block}
gui_load_child_values {tb_stages.uut_core.decode_unit.cs}
gui_load_child_values {tb_stages.uut_core.dc_unit}
gui_load_child_values {tb_stages.uut_core.mem_unit}
gui_load_child_values {tb_stages.uut_icache.icache_dataStore_unit}
gui_load_child_values {tb_stages.uut_icache}
gui_load_child_values {tb_stages.uut_core.fetch_unit}
gui_load_child_values {tb_stages.uut_core.idm_unit}
gui_load_child_values {tb_stages.uut_mem}
gui_load_child_values {tb_stages.uut_icache.icache_TagStore_unit}
gui_load_child_values {tb_stages.uut_core.decode_unit}
gui_load_child_values {tb_stages.uut_core.exe_latches_unit}
gui_load_child_values {tb_stages.uut_dcache.dcache_arbitration}
gui_load_child_values {tb_stages.uut_dcache.g_dcache_block[2].block}
gui_load_child_values {tb_stages.uut4_busArb.dte_unit}


set _session_group_77 BusArb
gui_sg_create "$_session_group_77"
set BusArb "$_session_group_77"

gui_sg_addsignal -group "$_session_group_77" { }

set _session_group_78 $_session_group_77|
append _session_group_78 dte_unit
gui_sg_create "$_session_group_78"
set BusArb|dte_unit "$_session_group_78"

gui_sg_addsignal -group "$_session_group_78" { tb_stages.uut4_busArb.dte_unit.mem_2_dcache_ld_req_fsmOut tb_stages.uut4_busArb.dte_unit.dte_core_2_dma_fsm_state_bits tb_stages.uut4_busArb.dte_unit.dcache_2_mem_fsmout_busy tb_stages.uut4_busArb.dte_unit.dcache_2_mem_fsmout_busy_per tb_stages.uut4_busArb.dte_unit.dte_ddr5_2_core_fsm_state tb_stages.uut4_busArb.dte_unit.rst tb_stages.uut4_busArb.dte_unit.ddr5_2_core_driveAddrBus_fsmOut tb_stages.uut4_busArb.dte_unit.dte_out_2_icache_o tb_stages.uut4_busArb.dte_unit.core_2_ddr5_driveAddrBus_fsmOut tb_stages.uut4_busArb.dte_unit.dma_2_mem_st_req_fsmOut tb_stages.uut4_busArb.dte_unit.clk tb_stages.uut4_busArb.dte_unit.dte_2_dma_o tb_stages.uut4_busArb.dte_unit.dcache_2_mem_req_hit tb_stages.uut4_busArb.dte_unit.dte_dma_2_mem_fsm_state tb_stages.uut4_busArb.dte_unit.ddr5_2_core_reqServed_fsmOut tb_stages.uut4_busArb.dte_unit.dte_mem_2_icache_fsm_state_bits tb_stages.uut4_busArb.dte_unit.mem_2_dcache_req_hit tb_stages.uut4_busArb.dte_unit.dcache_2_mem_bk_hit tb_stages.uut4_busArb.dte_unit.core_2_dma_driveAddrBus_fsmOut tb_stages.uut4_busArb.dte_unit.core_2_ddr5_reqServed_fsmOut tb_stages.uut4_busArb.dte_unit.mem_2_icache_fsmout_busy tb_stages.uut4_busArb.dte_unit.dte_dma_2_mem_fsm_state_bits tb_stages.uut4_busArb.dte_unit.dma_2_mem_req_hit tb_stages.uut4_busArb.dte_unit.core_2_dma_reqServed_fsmOut tb_stages.uut4_busArb.dte_unit.dte_mem_2_icache_fsm_state tb_stages.uut4_busArb.dte_unit.dte_dcache_2_mem_fsm_state_bits tb_stages.uut4_busArb.dte_unit.mem_2_dcache_fsmout_busy tb_stages.uut4_busArb.dte_unit.dte_out_2_dcache_o tb_stages.uut4_busArb.dte_unit.dma_2_mem_fsmout_busy tb_stages.uut4_busArb.dte_unit.dte_mem_2_dcache_fsm_state tb_stages.uut4_busArb.dte_unit.mem_2_dte_i tb_stages.uut4_busArb.dte_unit.core_2_dma_drvDB_fsmOut tb_stages.uut4_busArb.dte_unit.ddr5_2_core_req_hit tb_stages.uut4_busArb.dte_unit.dte_ddr5_2_core_fsm_state_bits tb_stages.uut4_busArb.dte_unit.mem_2_dcache_drv_db_fsmOut tb_stages.uut4_busArb.dte_unit.dcache_2_mem_st_req_fsmOut tb_stages.uut4_busArb.dte_unit.dte_core_2_ddr5_fsm_state tb_stages.uut4_busArb.dte_unit.ddr5_2_core_fsmout_busy tb_stages.uut4_busArb.dte_unit.core_2_dma_fsmout_busy tb_stages.uut4_busArb.dte_unit.mem_2_icache_req_hit tb_stages.uut4_busArb.dte_unit.mem_2_icache_ld_req_fsmOut tb_stages.uut4_busArb.dte_unit.mem_2_dcache_fsmout_busy_per tb_stages.uut4_busArb.dte_unit.core_2_ddr5_req_hit tb_stages.uut4_busArb.dte_unit.dte_mem_2_dcache_fsm_state_bits tb_stages.uut4_busArb.dte_unit.core_2_dma_req_hit tb_stages.uut4_busArb.dte_unit.dte_dcache_2_mem_fsm_state tb_stages.uut4_busArb.dte_unit.core_2_ddr5_drvDB_fsmOut tb_stages.uut4_busArb.dte_unit.dte_core_2_ddr5_fsm_state_bits tb_stages.uut4_busArb.dte_unit.dte_core_2_dma_fsm_state tb_stages.uut4_busArb.dte_unit.bestPick_bk_id_i tb_stages.uut4_busArb.dte_unit.dte_2_mem_o tb_stages.uut4_busArb.dte_unit.core_2_ddr5_fsmout_busy {tb_stages.uut4_busArb.dte_unit.$unit} tb_stages.uut4_busArb.dte_unit.mem_2_icache_drv_db_fsmOut tb_stages.uut4_busArb.dte_unit.dte_2_ddr5_o tb_stages.uut4_busArb.dte_unit.mem_2_dcache_bk_hit tb_stages.uut4_busArb.dte_unit.DTE_Busy tb_stages.uut4_busArb.dte_unit.bestPick_i }

gui_sg_move "$_session_group_78" -after "$_session_group_77" -pos 2 

set _session_group_79 $_session_group_77|
append _session_group_79 scheduler_unit
gui_sg_create "$_session_group_79"
set BusArb|scheduler_unit "$_session_group_79"

gui_sg_addsignal -group "$_session_group_79" { tb_stages.uut4_busArb.scheduler_unit.IC_MIO_Pick tb_stages.uut4_busArb.scheduler_unit.bestPick_o tb_stages.uut4_busArb.scheduler_unit.sch_latches tb_stages.uut4_busArb.scheduler_unit.dcache_Best_Pick tb_stages.uut4_busArb.scheduler_unit.mem_2_Sch_i tb_stages.uut4_busArb.scheduler_unit.dma_req tb_stages.uut4_busArb.scheduler_unit.iCache_2_Sch_i tb_stages.uut4_busArb.scheduler_unit.bestPick_bk_id_o tb_stages.uut4_busArb.scheduler_unit.clk tb_stages.uut4_busArb.scheduler_unit.dCache_2_Sch_i {tb_stages.uut4_busArb.scheduler_unit.$unit} tb_stages.uut4_busArb.scheduler_unit.IC_MIO_DMA_PICK tb_stages.uut4_busArb.scheduler_unit.dma_2_sch_i tb_stages.uut4_busArb.scheduler_unit.bestPick tb_stages.uut4_busArb.scheduler_unit.dcache_Best_Pick_BK_ID tb_stages.uut4_busArb.scheduler_unit.rst }

gui_sg_move "$_session_group_79" -after "$_session_group_77" -pos 1 

set _session_group_80 $_session_group_77|
append _session_group_80 uut4_busArb
gui_sg_create "$_session_group_80"
set BusArb|uut4_busArb "$_session_group_80"

gui_sg_addsignal -group "$_session_group_80" { tb_stages.uut4_busArb.mem_2_dte_i tb_stages.uut4_busArb.dte_2_mem_o tb_stages.uut4_busArb.dte_2_ddr5_o tb_stages.uut4_busArb.dte_out_2_dcache_o tb_stages.uut4_busArb.dte_out_2_icache_o tb_stages.uut4_busArb.sch_best_pick tb_stages.uut4_busArb.sch_best_pick_bk_id tb_stages.uut4_busArb.mem_2_Sch_i tb_stages.uut4_busArb.iCache_2_Sch_i tb_stages.uut4_busArb.clk tb_stages.uut4_busArb.dCache_2_Sch_i {tb_stages.uut4_busArb.$unit} tb_stages.uut4_busArb.dte_2_dma_o tb_stages.uut4_busArb.dma_2_sch_i tb_stages.uut4_busArb.rst }

set _session_group_81 MainMem
gui_sg_create "$_session_group_81"
set MainMem "$_session_group_81"

gui_sg_addsignal -group "$_session_group_81" { }

set _session_group_82 $_session_group_81|
append _session_group_82 controller
gui_sg_create "$_session_group_82"
set MainMem|controller "$_session_group_82"

gui_sg_addsignal -group "$_session_group_82" { {tb_stages.uut_mem.controller.$unit} tb_stages.uut_mem.controller.clk tb_stages.uut_mem.controller.rst tb_stages.uut_mem.controller.address_bus tb_stages.uut_mem.controller.data_bus tb_stages.uut_mem.controller.mem_controller_state_bits tb_stages.uut_mem.controller.fsm_state tb_stages.uut_mem.controller.hit_into_fsm tb_stages.uut_mem.controller.chipNum tb_stages.uut_mem.controller.bankBits_InChip tb_stages.uut_mem.controller.rowBitFromChipAddress tb_stages.uut_mem.controller.bank_num_for_chip tb_stages.uut_mem.controller.bankGroup tb_stages.uut_mem.controller.DTE_i tb_stages.uut_mem.controller.ToDTE_o tb_stages.uut_mem.controller.ToScheduler_o tb_stages.uut_mem.controller.bank_cmds_o tb_stages.uut_mem.controller.banks_i tb_stages.uut_mem.controller.bankGroupTable tb_stages.uut_mem.controller.chipTable tb_stages.uut_mem.controller.fsm_outs }

gui_sg_move "$_session_group_82" -after "$_session_group_81" -pos 1 

set _session_group_83 $_session_group_81|
append _session_group_83 uut_mem
gui_sg_create "$_session_group_83"
set MainMem|uut_mem "$_session_group_83"

gui_sg_addsignal -group "$_session_group_83" { {tb_stages.uut_mem.$unit} tb_stages.uut_mem.clk tb_stages.uut_mem.rst tb_stages.uut_mem.address_bus tb_stages.uut_mem.data_bus tb_stages.uut_mem.mem_bus tb_stages.uut_mem.drive_Data_Bus tb_stages.uut_mem.dataToDrive tb_stages.uut_mem.inFromDte tb_stages.uut_mem.out2Dte tb_stages.uut_mem.out2Sch tb_stages.uut_mem.controller_2_bank_Cmds tb_stages.uut_mem.bank_out_2_controller }

set _session_group_84 DCache
gui_sg_create "$_session_group_84"
set DCache "$_session_group_84"

gui_sg_addsignal -group "$_session_group_84" { }

set _session_group_85 $_session_group_84|
append _session_group_85 uut_dcache
gui_sg_create "$_session_group_85"
set DCache|uut_dcache "$_session_group_85"

gui_sg_addsignal -group "$_session_group_85" { tb_stages.uut_dcache.blockOutputs tb_stages.uut_dcache.out2Sch_o tb_stages.uut_dcache.out2Core_o tb_stages.uut_dcache.arb_req_served_1_out tb_stages.uut_dcache.arb_req_served_0_out tb_stages.uut_dcache.inFromDTE_i tb_stages.uut_dcache.address_bus tb_stages.uut_dcache.inFromCore_i tb_stages.uut_dcache.clk tb_stages.uut_dcache.mio_block_outputs tb_stages.uut_dcache.dataBus tb_stages.uut_dcache.req_2_blocks {tb_stages.uut_dcache.$unit} tb_stages.uut_dcache.arb_st_override_Out tb_stages.uut_dcache.hitVec tb_stages.uut_dcache.rst }

set _session_group_86 $_session_group_84|
append _session_group_86 {g_dcache_block[0].block}
gui_sg_create "$_session_group_86"
set {DCache|g_dcache_block[0].block} "$_session_group_86"

gui_sg_addsignal -group "$_session_group_86" { {tb_stages.uut_dcache.g_dcache_block[0].block.evictionBuf_clr_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[0].block.makeBlockReq} {tb_stages.uut_dcache.g_dcache_block[0].block.dcache_bank_outputs} {tb_stages.uut_dcache.g_dcache_block[0].block.mem_Valid_FromDte_i} {tb_stages.uut_dcache.g_dcache_block[0].block.address_bus_fake} {tb_stages.uut_dcache.g_dcache_block[0].block.eb_outputs} {tb_stages.uut_dcache.g_dcache_block[0].block.block_req_i} {tb_stages.uut_dcache.g_dcache_block[0].block.address_bus} {tb_stages.uut_dcache.g_dcache_block[0].block.eb_V} {tb_stages.uut_dcache.g_dcache_block[0].block.block_busy} {tb_stages.uut_dcache.g_dcache_block[0].block.permissionToDriveAddrBus_eb} {tb_stages.uut_dcache.g_dcache_block[0].block.startingOffset} {tb_stages.uut_dcache.g_dcache_block[0].block.eb_curr_commiting} {tb_stages.uut_dcache.g_dcache_block[0].block.permissionToDriveAddrBus_Ld} {tb_stages.uut_dcache.g_dcache_block[0].block.eb_blockingVCache} {tb_stages.uut_dcache.g_dcache_block[0].block.st_override_for_sch_req} {tb_stages.uut_dcache.g_dcache_block[0].block.rst_i} {tb_stages.uut_dcache.g_dcache_block[0].block.evictionBuf_setCommiting_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[0].block.outputs_o} {tb_stages.uut_dcache.g_dcache_block[0].block.permissionToDriveDataBus_evictionBuf} {tb_stages.uut_dcache.g_dcache_block[0].block.dataBus} {tb_stages.uut_dcache.g_dcache_block[0].block.eb_blocking_Bank} {tb_stages.uut_dcache.g_dcache_block[0].block.vcache_outputs} {tb_stages.uut_dcache.g_dcache_block[0].block.clk_i} {tb_stages.uut_dcache.g_dcache_block[0].block.perm2DriveDataBus_bar} {tb_stages.uut_dcache.g_dcache_block[0].block.eb_lineOut_vec} }

gui_sg_move "$_session_group_86" -after "$_session_group_84" -pos 6 

set _session_group_87 $_session_group_84|
append _session_group_87 {g_dcache_block[1].block}
gui_sg_create "$_session_group_87"
set {DCache|g_dcache_block[1].block} "$_session_group_87"

gui_sg_addsignal -group "$_session_group_87" { {tb_stages.uut_dcache.g_dcache_block[1].block.evictionBuf_clr_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[1].block.makeBlockReq} {tb_stages.uut_dcache.g_dcache_block[1].block.dcache_bank_outputs} {tb_stages.uut_dcache.g_dcache_block[1].block.mem_Valid_FromDte_i} {tb_stages.uut_dcache.g_dcache_block[1].block.address_bus_fake} {tb_stages.uut_dcache.g_dcache_block[1].block.eb_outputs} {tb_stages.uut_dcache.g_dcache_block[1].block.block_req_i} {tb_stages.uut_dcache.g_dcache_block[1].block.address_bus} {tb_stages.uut_dcache.g_dcache_block[1].block.eb_V} {tb_stages.uut_dcache.g_dcache_block[1].block.block_busy} {tb_stages.uut_dcache.g_dcache_block[1].block.permissionToDriveAddrBus_eb} {tb_stages.uut_dcache.g_dcache_block[1].block.startingOffset} {tb_stages.uut_dcache.g_dcache_block[1].block.eb_curr_commiting} {tb_stages.uut_dcache.g_dcache_block[1].block.permissionToDriveAddrBus_Ld} {tb_stages.uut_dcache.g_dcache_block[1].block.eb_blockingVCache} {tb_stages.uut_dcache.g_dcache_block[1].block.st_override_for_sch_req} {tb_stages.uut_dcache.g_dcache_block[1].block.rst_i} {tb_stages.uut_dcache.g_dcache_block[1].block.evictionBuf_setCommiting_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[1].block.outputs_o} {tb_stages.uut_dcache.g_dcache_block[1].block.permissionToDriveDataBus_evictionBuf} {tb_stages.uut_dcache.g_dcache_block[1].block.dataBus} {tb_stages.uut_dcache.g_dcache_block[1].block.eb_blocking_Bank} {tb_stages.uut_dcache.g_dcache_block[1].block.vcache_outputs} {tb_stages.uut_dcache.g_dcache_block[1].block.clk_i} {tb_stages.uut_dcache.g_dcache_block[1].block.perm2DriveDataBus_bar} {tb_stages.uut_dcache.g_dcache_block[1].block.eb_lineOut_vec} }

gui_sg_move "$_session_group_87" -after "$_session_group_84" -pos 5 

set _session_group_88 $_session_group_84|
append _session_group_88 {g_dcache_block[2].block}
gui_sg_create "$_session_group_88"
set {DCache|g_dcache_block[2].block} "$_session_group_88"

gui_sg_addsignal -group "$_session_group_88" { {tb_stages.uut_dcache.g_dcache_block[2].block.evictionBuf_clr_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[2].block.makeBlockReq} {tb_stages.uut_dcache.g_dcache_block[2].block.dcache_bank_outputs} {tb_stages.uut_dcache.g_dcache_block[2].block.mem_Valid_FromDte_i} {tb_stages.uut_dcache.g_dcache_block[2].block.address_bus_fake} {tb_stages.uut_dcache.g_dcache_block[2].block.eb_outputs} {tb_stages.uut_dcache.g_dcache_block[2].block.block_req_i} {tb_stages.uut_dcache.g_dcache_block[2].block.address_bus} {tb_stages.uut_dcache.g_dcache_block[2].block.eb_V} {tb_stages.uut_dcache.g_dcache_block[2].block.block_busy} {tb_stages.uut_dcache.g_dcache_block[2].block.permissionToDriveAddrBus_eb} {tb_stages.uut_dcache.g_dcache_block[2].block.startingOffset} {tb_stages.uut_dcache.g_dcache_block[2].block.eb_curr_commiting} {tb_stages.uut_dcache.g_dcache_block[2].block.permissionToDriveAddrBus_Ld} {tb_stages.uut_dcache.g_dcache_block[2].block.eb_blockingVCache} {tb_stages.uut_dcache.g_dcache_block[2].block.st_override_for_sch_req} {tb_stages.uut_dcache.g_dcache_block[2].block.rst_i} {tb_stages.uut_dcache.g_dcache_block[2].block.evictionBuf_setCommiting_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[2].block.outputs_o} {tb_stages.uut_dcache.g_dcache_block[2].block.permissionToDriveDataBus_evictionBuf} {tb_stages.uut_dcache.g_dcache_block[2].block.dataBus} {tb_stages.uut_dcache.g_dcache_block[2].block.eb_blocking_Bank} {tb_stages.uut_dcache.g_dcache_block[2].block.vcache_outputs} {tb_stages.uut_dcache.g_dcache_block[2].block.clk_i} {tb_stages.uut_dcache.g_dcache_block[2].block.perm2DriveDataBus_bar} {tb_stages.uut_dcache.g_dcache_block[2].block.eb_lineOut_vec} }

gui_sg_move "$_session_group_88" -after "$_session_group_84" -pos 4 

set _session_group_89 $_session_group_84|
append _session_group_89 {g_dcache_block[3].block}
gui_sg_create "$_session_group_89"
set {DCache|g_dcache_block[3].block} "$_session_group_89"

gui_sg_addsignal -group "$_session_group_89" { {tb_stages.uut_dcache.g_dcache_block[3].block.evictionBuf_clr_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[3].block.makeBlockReq} {tb_stages.uut_dcache.g_dcache_block[3].block.dcache_bank_outputs} {tb_stages.uut_dcache.g_dcache_block[3].block.mem_Valid_FromDte_i} {tb_stages.uut_dcache.g_dcache_block[3].block.address_bus_fake} {tb_stages.uut_dcache.g_dcache_block[3].block.eb_outputs} {tb_stages.uut_dcache.g_dcache_block[3].block.block_req_i} {tb_stages.uut_dcache.g_dcache_block[3].block.address_bus} {tb_stages.uut_dcache.g_dcache_block[3].block.eb_V} {tb_stages.uut_dcache.g_dcache_block[3].block.block_busy} {tb_stages.uut_dcache.g_dcache_block[3].block.permissionToDriveAddrBus_eb} {tb_stages.uut_dcache.g_dcache_block[3].block.startingOffset} {tb_stages.uut_dcache.g_dcache_block[3].block.eb_curr_commiting} {tb_stages.uut_dcache.g_dcache_block[3].block.permissionToDriveAddrBus_Ld} {tb_stages.uut_dcache.g_dcache_block[3].block.eb_blockingVCache} {tb_stages.uut_dcache.g_dcache_block[3].block.st_override_for_sch_req} {tb_stages.uut_dcache.g_dcache_block[3].block.rst_i} {tb_stages.uut_dcache.g_dcache_block[3].block.evictionBuf_setCommiting_FromDTE_i} {tb_stages.uut_dcache.g_dcache_block[3].block.outputs_o} {tb_stages.uut_dcache.g_dcache_block[3].block.permissionToDriveDataBus_evictionBuf} {tb_stages.uut_dcache.g_dcache_block[3].block.dataBus} {tb_stages.uut_dcache.g_dcache_block[3].block.eb_blocking_Bank} {tb_stages.uut_dcache.g_dcache_block[3].block.vcache_outputs} {tb_stages.uut_dcache.g_dcache_block[3].block.clk_i} {tb_stages.uut_dcache.g_dcache_block[3].block.perm2DriveDataBus_bar} {tb_stages.uut_dcache.g_dcache_block[3].block.eb_lineOut_vec} }

gui_sg_move "$_session_group_89" -after "$_session_group_84" -pos 3 

set _session_group_90 $_session_group_84|
append _session_group_90 mio_block_unit
gui_sg_create "$_session_group_90"
set DCache|mio_block_unit "$_session_group_90"

gui_sg_addsignal -group "$_session_group_90" { tb_stages.uut_dcache.mio_block_unit.next_block_req tb_stages.uut_dcache.mio_block_unit.WE_ADDR_MASK tb_stages.uut_dcache.mio_block_unit.reqServed_FromDTE_i tb_stages.uut_dcache.mio_block_unit.memStage_CLR_REQ_MIO tb_stages.uut_dcache.mio_block_unit.ld_addr_MIO_V tb_stages.uut_dcache.mio_block_unit.data_bus_fake tb_stages.uut_dcache.mio_block_unit.PermissionToDriveAddrBus tb_stages.uut_dcache.mio_block_unit.permission2DriveDataBus tb_stages.uut_dcache.mio_block_unit.ld_addr_MIO tb_stages.uut_dcache.mio_block_unit.stq_info_mio tb_stages.uut_dcache.mio_block_unit.block_idle tb_stages.uut_dcache.mio_block_unit.address_bus tb_stages.uut_dcache.mio_block_unit.readyForNewReq tb_stages.uut_dcache.mio_block_unit.clk tb_stages.uut_dcache.mio_block_unit.outputs_o tb_stages.uut_dcache.mio_block_unit.block_req tb_stages.uut_dcache.mio_block_unit.dataBus {tb_stages.uut_dcache.mio_block_unit.$unit} tb_stages.uut_dcache.mio_block_unit.rst }
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_dcache.mio_block_unit.WE_ADDR_MASK}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_dcache.mio_block_unit.WE_ADDR_MASK}

gui_sg_move "$_session_group_90" -after "$_session_group_84" -pos 2 

set _session_group_91 $_session_group_84|
append _session_group_91 dcache_arbitration
gui_sg_create "$_session_group_91"
set DCache|dcache_arbitration "$_session_group_91"

gui_sg_addsignal -group "$_session_group_91" { tb_stages.uut_dcache.dcache_arbitration.core_i tb_stages.uut_dcache.dcache_arbitration.ldReq_2_BankPresent tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_LB tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_WIDTH tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_UB tb_stages.uut_dcache.dcache_arbitration.ld_req_0_bankNum tb_stages.uut_dcache.dcache_arbitration.block_idleness tb_stages.uut_dcache.dcache_arbitration.readyForNewReq tb_stages.uut_dcache.dcache_arbitration.st_override_o tb_stages.uut_dcache.dcache_arbitration.nextReqs tb_stages.uut_dcache.dcache_arbitration.writeSuccess_o tb_stages.uut_dcache.dcache_arbitration.st_override tb_stages.uut_dcache.dcache_arbitration.reqs tb_stages.uut_dcache.dcache_arbitration.ld_req_1_bankNum {tb_stages.uut_dcache.dcache_arbitration.$unit} tb_stages.uut_dcache.dcache_arbitration.block_hit_i tb_stages.uut_dcache.dcache_arbitration.reqs_2_blocks_o tb_stages.uut_dcache.dcache_arbitration.rst tb_stages.uut_dcache.dcache_arbitration.clk_i tb_stages.uut_dcache.dcache_arbitration.reqServed_0_o tb_stages.uut_dcache.dcache_arbitration.reqServed_1_o tb_stages.uut_dcache.dcache_arbitration.memStage_CLR_REQ }
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_LB}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_LB}
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_WIDTH}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_WIDTH}
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_UB}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_dcache.dcache_arbitration.LD_REQ_BANK_UB}

gui_sg_move "$_session_group_91" -after "$_session_group_84" -pos 1 

set _session_group_92 ICache
gui_sg_create "$_session_group_92"
set ICache "$_session_group_92"

gui_sg_addsignal -group "$_session_group_92" { }

set _session_group_93 $_session_group_92|
append _session_group_93 i_vcache_unit
gui_sg_create "$_session_group_93"
set ICache|i_vcache_unit "$_session_group_93"

gui_sg_addsignal -group "$_session_group_93" { tb_stages.uut_icache.i_vcache_unit.miss tb_stages.uut_icache.i_vcache_unit.I_VC_swapBuf tb_stages.uut_icache.i_vcache_unit.LRU_RIGHT_LEAF tb_stages.uut_icache.i_vcache_unit.NUM_LRU_BITS tb_stages.uut_icache.i_vcache_unit.miss_o tb_stages.uut_icache.i_vcache_unit.tagStore tb_stages.uut_icache.i_vcache_unit.currDataLine tb_stages.uut_icache.i_vcache_unit.dataLineOut_o tb_stages.uut_icache.i_vcache_unit.updateLRU tb_stages.uut_icache.i_vcache_unit.v_addr_i tb_stages.uut_icache.i_vcache_unit.hitHappened tb_stages.uut_icache.i_vcache_unit.IC_SwapBuf_V_clr_o tb_stages.uut_icache.i_vcache_unit.currTagHit tb_stages.uut_icache.i_vcache_unit.currLRU_IDX tb_stages.uut_icache.i_vcache_unit.RD_IC_SWAP_BUF tb_stages.uut_icache.i_vcache_unit.hit_o tb_stages.uut_icache.i_vcache_unit.v_addr_i_fields tb_stages.uut_icache.i_vcache_unit.LRU_LEFT_LEAF tb_stages.uut_icache.i_vcache_unit.busy_i tb_stages.uut_icache.i_vcache_unit.clk tb_stages.uut_icache.i_vcache_unit.currTag tb_stages.uut_icache.i_vcache_unit.en_i tb_stages.uut_icache.i_vcache_unit.ic_swapBuf_v_addr_fields tb_stages.uut_icache.i_vcache_unit.IC_SwapBuf_i tb_stages.uut_icache.i_vcache_unit.hit tb_stages.uut_icache.i_vcache_unit.I_VC_SwapBuf_o tb_stages.uut_icache.i_vcache_unit.LD_I_VC_SWAP_BUF tb_stages.uut_icache.i_vcache_unit.hit_idx {tb_stages.uut_icache.i_vcache_unit.$unit} tb_stages.uut_icache.i_vcache_unit.dataStore tb_stages.uut_icache.i_vcache_unit.NUM_LINES tb_stages.uut_icache.i_vcache_unit.LRU_ROOT tb_stages.uut_icache.i_vcache_unit.update_idx tb_stages.uut_icache.i_vcache_unit.IDX_2_Write tb_stages.uut_icache.i_vcache_unit.currMRU_IDX tb_stages.uut_icache.i_vcache_unit.rst }
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.i_vcache_unit.LRU_RIGHT_LEAF}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.i_vcache_unit.LRU_RIGHT_LEAF}
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.i_vcache_unit.NUM_LRU_BITS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.i_vcache_unit.NUM_LRU_BITS}
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.i_vcache_unit.LRU_LEFT_LEAF}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.i_vcache_unit.LRU_LEFT_LEAF}
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.i_vcache_unit.NUM_LINES}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.i_vcache_unit.NUM_LINES}
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.i_vcache_unit.LRU_ROOT}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.i_vcache_unit.LRU_ROOT}

gui_sg_move "$_session_group_93" -after "$_session_group_92" -pos 4 

set _session_group_94 $_session_group_92|
append _session_group_94 icache_TagStore_unit
gui_sg_create "$_session_group_94"
set ICache|icache_TagStore_unit "$_session_group_94"

gui_sg_addsignal -group "$_session_group_94" { tb_stages.uut_icache.icache_TagStore_unit.NUM_CELLS tb_stages.uut_icache.icache_TagStore_unit.ld_From_I_VC_Swap tb_stages.uut_icache.icache_TagStore_unit.currTag_o tb_stages.uut_icache.icache_TagStore_unit.WR_2_TagStore_actual tb_stages.uut_icache.icache_TagStore_unit.DIN_2_TagStore tb_stages.uut_icache.icache_TagStore_unit.tagCellOutSel tb_stages.uut_icache.icache_TagStore_unit.fill3_i tb_stages.uut_icache.icache_TagStore_unit.v_addr_i tb_stages.uut_icache.icache_TagStore_unit.LD_IC_SWAP_BUF tb_stages.uut_icache.icache_TagStore_unit.DOUT_2_TagStore tb_stages.uut_icache.icache_TagStore_unit.OE_2_TagStore tb_stages.uut_icache.icache_TagStore_unit.validStore tb_stages.uut_icache.icache_TagStore_unit.DOUT_2_TagStore_net tb_stages.uut_icache.icache_TagStore_unit.clk_45_phase tb_stages.uut_icache.icache_TagStore_unit.v_addr_i_fields tb_stages.uut_icache.icache_TagStore_unit.busy tb_stages.uut_icache.icache_TagStore_unit.I_VC_SwapBuf_i tb_stages.uut_icache.icache_TagStore_unit.NUM_LAYERS tb_stages.uut_icache.icache_TagStore_unit.clk tb_stages.uut_icache.icache_TagStore_unit.currLine_V tb_stages.uut_icache.icache_TagStore_unit.WR_2_TagStore_clk tb_stages.uut_icache.icache_TagStore_unit.en tb_stages.uut_icache.icache_TagStore_unit.ADDRESS_2_TagStore tb_stages.uut_icache.icache_TagStore_unit.rst }
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.icache_TagStore_unit.NUM_CELLS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.icache_TagStore_unit.NUM_CELLS}
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.icache_TagStore_unit.NUM_LAYERS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.icache_TagStore_unit.NUM_LAYERS}

gui_sg_move "$_session_group_94" -after "$_session_group_92" -pos 3 

set _session_group_95 $_session_group_92|
append _session_group_95 icache_contrller_fsm
gui_sg_create "$_session_group_95"
set ICache|icache_contrller_fsm "$_session_group_95"

gui_sg_addsignal -group "$_session_group_95" { tb_stages.uut_icache.icache_contrller_fsm.S_1_inv tb_stages.uut_icache.icache_contrller_fsm.S_0_inv tb_stages.uut_icache.icache_contrller_fsm.mem_valid_i_inv tb_stages.uut_icache.icache_contrller_fsm.mem_valid_i tb_stages.uut_icache.icache_contrller_fsm.S_0 tb_stages.uut_icache.icache_contrller_fsm.S_1 tb_stages.uut_icache.icache_contrller_fsm.S_2 tb_stages.uut_icache.icache_contrller_fsm.NS_0_t0 tb_stages.uut_icache.icache_contrller_fsm.NS_0_t1 tb_stages.uut_icache.icache_contrller_fsm.NS_0_t2 tb_stages.uut_icache.icache_contrller_fsm.busy_o_t0 tb_stages.uut_icache.icache_contrller_fsm.NS_1_t0 tb_stages.uut_icache.icache_contrller_fsm.Fill3EN_o tb_stages.uut_icache.icache_contrller_fsm.IC_miss_i tb_stages.uut_icache.icache_contrller_fsm.busy_o_t1 tb_stages.uut_icache.icache_contrller_fsm.NS_1_t1 tb_stages.uut_icache.icache_contrller_fsm.busy_o_t2 tb_stages.uut_icache.icache_contrller_fsm.NS_1_t2 tb_stages.uut_icache.icache_contrller_fsm.Fill2EN_o tb_stages.uut_icache.icache_contrller_fsm.clk tb_stages.uut_icache.icache_contrller_fsm.NS_2_t0 tb_stages.uut_icache.icache_contrller_fsm.MakeReq_o tb_stages.uut_icache.icache_contrller_fsm.NS_2_t1 tb_stages.uut_icache.icache_contrller_fsm.en_i tb_stages.uut_icache.icache_contrller_fsm.NS_2_t2 tb_stages.uut_icache.icache_contrller_fsm.NS_2_t3 tb_stages.uut_icache.icache_contrller_fsm.NS_0 tb_stages.uut_icache.icache_contrller_fsm.Fill1EN_o tb_stages.uut_icache.icache_contrller_fsm.NS_1 tb_stages.uut_icache.icache_contrller_fsm.busy_o tb_stages.uut_icache.icache_contrller_fsm.NS_2 tb_stages.uut_icache.icache_contrller_fsm.RD_I_VC_SWAP_BUF_o tb_stages.uut_icache.icache_contrller_fsm.I_VC_Miss_i_inv tb_stages.uut_icache.icache_contrller_fsm.Fill0EN_o tb_stages.uut_icache.icache_contrller_fsm.LD_IC_SWAP_BUF_o tb_stages.uut_icache.icache_contrller_fsm.I_VC_Miss_i tb_stages.uut_icache.icache_contrller_fsm.S_2_inv tb_stages.uut_icache.icache_contrller_fsm.rst }

gui_sg_move "$_session_group_95" -after "$_session_group_92" -pos 2 

set _session_group_96 $_session_group_92|
append _session_group_96 icache_dataStore_unit
gui_sg_create "$_session_group_96"
set ICache|icache_dataStore_unit "$_session_group_96"

gui_sg_addsignal -group "$_session_group_96" { tb_stages.uut_icache.icache_dataStore_unit.rst tb_stages.uut_icache.icache_dataStore_unit.currLine_o tb_stages.uut_icache.icache_dataStore_unit.ADDRESS_2_DataStore tb_stages.uut_icache.icache_dataStore_unit.OE_2_DataStore tb_stages.uut_icache.icache_dataStore_unit.clk tb_stages.uut_icache.icache_dataStore_unit.dataLineOutSel tb_stages.uut_icache.icache_dataStore_unit.v_addr_i tb_stages.uut_icache.icache_dataStore_unit.dataBus tb_stages.uut_icache.icache_dataStore_unit.fill3_i tb_stages.uut_icache.icache_dataStore_unit.fill2_i tb_stages.uut_icache.icache_dataStore_unit.en tb_stages.uut_icache.icache_dataStore_unit.WR_2_DataStore_clk tb_stages.uut_icache.icache_dataStore_unit.fill1_i tb_stages.uut_icache.icache_dataStore_unit.fill0_i tb_stages.uut_icache.icache_dataStore_unit.clk_45_phase tb_stages.uut_icache.icache_dataStore_unit.I_VC_SwapBuf_i tb_stages.uut_icache.icache_dataStore_unit.WR_2_DataStore_actual tb_stages.uut_icache.icache_dataStore_unit.NUM_CELLS tb_stages.uut_icache.icache_dataStore_unit.busy tb_stages.uut_icache.icache_dataStore_unit.ld_From_I_VC_Swap tb_stages.uut_icache.icache_dataStore_unit.v_addr_i_index tb_stages.uut_icache.icache_dataStore_unit.DOUT_2_DataStore tb_stages.uut_icache.icache_dataStore_unit.LD_IC_SWAP_BUF tb_stages.uut_icache.icache_dataStore_unit.LAYERS_OF_CELLS tb_stages.uut_icache.icache_dataStore_unit.DIN_2_DataStore {tb_stages.uut_icache.icache_dataStore_unit.$unit} }
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.icache_dataStore_unit.NUM_CELLS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.icache_dataStore_unit.NUM_CELLS}
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_icache.icache_dataStore_unit.LAYERS_OF_CELLS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_icache.icache_dataStore_unit.LAYERS_OF_CELLS}

gui_sg_move "$_session_group_96" -after "$_session_group_92" -pos 1 

set _session_group_97 $_session_group_92|
append _session_group_97 uut_icache
gui_sg_create "$_session_group_97"
set ICache|uut_icache "$_session_group_97"

gui_sg_addsignal -group "$_session_group_97" { tb_stages.uut_icache.icache_miss tb_stages.uut_icache.out2Sch_o tb_stages.uut_icache.out2Core_o tb_stages.uut_icache.i_vcache_hit tb_stages.uut_icache.addrBus tb_stages.uut_icache.icache_tag tb_stages.uut_icache.i_vcache_swapBuf tb_stages.uut_icache.inFromDte_i tb_stages.uut_icache.saved_vAddr tb_stages.uut_icache.fsmOuts tb_stages.uut_icache.inFromCore_i tb_stages.uut_icache.i_vcache_dataLines tb_stages.uut_icache.icache_hit tb_stages.uut_icache.clk tb_stages.uut_icache.curr_v_addr_to_use tb_stages.uut_icache.icache_tag_V tb_stages.uut_icache.dataBus tb_stages.uut_icache.useSaved_v_Addr tb_stages.uut_icache.saved_pAddr tb_stages.uut_icache.addrBus_drv tb_stages.uut_icache.i_vcache_swapBuf_V_Clr tb_stages.uut_icache.i_vcache_miss tb_stages.uut_icache.controller_fsmState {tb_stages.uut_icache.$unit} tb_stages.uut_icache.icache_swapbuf tb_stages.uut_icache.icache_dataLines tb_stages.uut_icache.controller_fsmState_bits tb_stages.uut_icache.rst }

set _session_group_98 Core
gui_sg_create "$_session_group_98"
set Core "$_session_group_98"

gui_sg_addsignal -group "$_session_group_98" { }

set _session_group_99 $_session_group_98|
append _session_group_99 wb_latches_unit
gui_sg_create "$_session_group_99"
set Core|wb_latches_unit "$_session_group_99"

gui_sg_addsignal -group "$_session_group_99" { tb_stages.uut_core.wb_latches_unit.latches tb_stages.uut_core.wb_latches_unit.latches_o tb_stages.uut_core.wb_latches_unit.nextLatches_i tb_stages.uut_core.wb_latches_unit.clk tb_stages.uut_core.wb_latches_unit.write_enable_i {tb_stages.uut_core.wb_latches_unit.$unit} tb_stages.uut_core.wb_latches_unit.rst }

gui_sg_move "$_session_group_99" -after "$_session_group_98" -pos 12 

set _session_group_100 $_session_group_98|
append _session_group_100 execute_unit
gui_sg_create "$_session_group_100"
set Core|execute_unit "$_session_group_100"

gui_sg_addsignal -group "$_session_group_100" { tb_stages.uut_core.execute_unit.sar_cf_o tb_stages.uut_core.execute_unit.cmp_pf_o tb_stages.uut_core.execute_unit.not_dr_o tb_stages.uut_core.execute_unit.iretd_stack_ptr_o tb_stages.uut_core.execute_unit.sbb_res_buf_o tb_stages.uut_core.execute_unit.st_op_next tb_stages.uut_core.execute_unit.and_of_o tb_stages.uut_core.execute_unit.outs_o tb_stages.uut_core.execute_unit.packssdw_dr_o tb_stages.uut_core.execute_unit.data_size tb_stages.uut_core.execute_unit.bsf_dr_o tb_stages.uut_core.execute_unit.add_cf_o tb_stages.uut_core.execute_unit.rst tb_stages.uut_core.execute_unit.cmp_sf_o tb_stages.uut_core.execute_unit.xchg_sr_o tb_stages.uut_core.execute_unit.paddd_dr_o tb_stages.uut_core.execute_unit.dr_next tb_stages.uut_core.execute_unit.flags_reg tb_stages.uut_core.execute_unit.call_res_buf tb_stages.uut_core.execute_unit.iretd_cf_o tb_stages.uut_core.execute_unit.sar_dr_o tb_stages.uut_core.execute_unit.sr_next tb_stages.uut_core.execute_unit.ret_far_imm_dr_o tb_stages.uut_core.execute_unit.and_res_buf_o tb_stages.uut_core.execute_unit.br_sel tb_stages.uut_core.execute_unit.adc_pf_o tb_stages.uut_core.execute_unit.cmpxchg_sr_o tb_stages.uut_core.execute_unit.pop_dr_o tb_stages.uut_core.execute_unit.bsf_zf_o tb_stages.uut_core.execute_unit.add_dr_o tb_stages.uut_core.execute_unit.adc_res_buf_o tb_stages.uut_core.execute_unit.sbb_pf_o tb_stages.uut_core.execute_unit.wb_latches_next_o tb_stages.uut_core.execute_unit.bit_vec_1_next tb_stages.uut_core.execute_unit.clk tb_stages.uut_core.execute_unit.ret_far_cs_o tb_stages.uut_core.execute_unit.adc_sf_o tb_stages.uut_core.execute_unit.not_res_buf_o tb_stages.uut_core.execute_unit.sar_zf_o tb_stages.uut_core.execute_unit.sal_pf_o tb_stages.uut_core.execute_unit.or_pf_o tb_stages.uut_core.execute_unit.sbb_sf_o tb_stages.uut_core.execute_unit.ret_imm_sr_o tb_stages.uut_core.execute_unit.add_zf_o tb_stages.uut_core.execute_unit.sar_of_o tb_stages.uut_core.execute_unit.sal_sf_o tb_stages.uut_core.execute_unit.or_sf_o tb_stages.uut_core.execute_unit.cancel_dr_we tb_stages.uut_core.execute_unit.cmpxchg_pf_o tb_stages.uut_core.execute_unit.push_res_buf tb_stages.uut_core.execute_unit.of_flag_o tb_stages.uut_core.execute_unit.iretd_zf_o tb_stages.uut_core.execute_unit.add_af_o tb_stages.uut_core.execute_unit.aaa_cf_o tb_stages.uut_core.execute_unit.bsf_res_buf_o tb_stages.uut_core.execute_unit.add_of_o tb_stages.uut_core.execute_unit.cmp_cf_o tb_stages.uut_core.execute_unit.push_sr_o tb_stages.uut_core.execute_unit.xchg_res_buf tb_stages.uut_core.execute_unit.mov_res_buf_o tb_stages.uut_core.execute_unit.wb_stage_next_vaild_o tb_stages.uut_core.execute_unit.iretd_af_o tb_stages.uut_core.execute_unit.cmpxchg_sf_o tb_stages.uut_core.execute_unit.far_call_res_buf tb_stages.uut_core.execute_unit.iretd_of_o tb_stages.uut_core.execute_unit.and_pf_o tb_stages.uut_core.execute_unit.ret_far_next_ptr_o tb_stages.uut_core.execute_unit.cf_flag_o tb_stages.uut_core.execute_unit.wb_dr_next tb_stages.uut_core.execute_unit.mov_dr_o tb_stages.uut_core.execute_unit.wb_stage_we_valid_unit_o tb_stages.uut_core.execute_unit.wb_sr_next tb_stages.uut_core.execute_unit.wb_outs_i tb_stages.uut_core.execute_unit.sal_res_buf_o tb_stages.uut_core.execute_unit.aaa_dr_o tb_stages.uut_core.execute_unit.branch_resolution_o tb_stages.uut_core.execute_unit.and_sf_o tb_stages.uut_core.execute_unit.ret_far_imm_sr_o tb_stages.uut_core.execute_unit.adc_cf_o tb_stages.uut_core.execute_unit.latches_i tb_stages.uut_core.execute_unit.far_call_dr_o tb_stages.uut_core.execute_unit.pop_sr_o tb_stages.uut_core.execute_unit.sbb_cf_o tb_stages.uut_core.execute_unit.cancel_sr_we tb_stages.uut_core.execute_unit.ret_sr_o tb_stages.uut_core.execute_unit.sal_cf_o tb_stages.uut_core.execute_unit.or_cf_o tb_stages.uut_core.execute_unit.cmp_zf_o tb_stages.uut_core.execute_unit.adc_dr_o tb_stages.uut_core.execute_unit.sar_res_buf_o tb_stages.uut_core.execute_unit.sf_flag_o tb_stages.uut_core.execute_unit.aaa_af_o tb_stages.uut_core.execute_unit.bit_vec_0_next }
gui_sg_addsignal -group "$_session_group_100" { tb_stages.uut_core.execute_unit.cmp_af_o tb_stages.uut_core.execute_unit.sar_pf_o tb_stages.uut_core.execute_unit.cmp_of_o tb_stages.uut_core.execute_unit.pf_flag_o tb_stages.uut_core.execute_unit.sbb_dr_o tb_stages.uut_core.execute_unit.op_type tb_stages.uut_core.execute_unit.cmpxchg_cf_o tb_stages.uut_core.execute_unit.sal_dr_o tb_stages.uut_core.execute_unit.or_dr_o tb_stages.uut_core.execute_unit.add_pf_o tb_stages.uut_core.execute_unit.adc_zf_o tb_stages.uut_core.execute_unit.sar_sf_o tb_stages.uut_core.execute_unit.xchg_dr_o tb_stages.uut_core.execute_unit.df_flag_o tb_stages.uut_core.execute_unit.clr_ZF_sb tb_stages.uut_core.execute_unit.iretd_pf_o tb_stages.uut_core.execute_unit.or_res_buf_o tb_stages.uut_core.execute_unit.af_flag_o tb_stages.uut_core.execute_unit.sbb_zf_o tb_stages.uut_core.execute_unit.adc_af_o tb_stages.uut_core.execute_unit.packsswb_dr_o tb_stages.uut_core.execute_unit.cmpxchg_dr_o tb_stages.uut_core.execute_unit.add_sf_o tb_stages.uut_core.execute_unit.adc_of_o tb_stages.uut_core.execute_unit.cmpxchg_buf_o tb_stages.uut_core.execute_unit.srA tb_stages.uut_core.execute_unit.srB tb_stages.uut_core.execute_unit.cancel_store tb_stages.uut_core.execute_unit.sal_zf_o tb_stages.uut_core.execute_unit.or_zf_o tb_stages.uut_core.execute_unit.iretd_sf_o tb_stages.uut_core.execute_unit.sbb_af_o tb_stages.uut_core.execute_unit.iretd_cs_o tb_stages.uut_core.execute_unit.sbb_of_o tb_stages.uut_core.execute_unit.and_dr_o tb_stages.uut_core.execute_unit.res_buf_next tb_stages.uut_core.execute_unit.sal_of_o tb_stages.uut_core.execute_unit.or_of_o tb_stages.uut_core.execute_unit.pavgw_dr_o tb_stages.uut_core.execute_unit.add_res_buf_o tb_stages.uut_core.execute_unit.cmpxchg_zf_o {tb_stages.uut_core.execute_unit.$unit} tb_stages.uut_core.execute_unit.pavgb_dr_o tb_stages.uut_core.execute_unit.paddw_dr_o tb_stages.uut_core.execute_unit.zf_flag_o tb_stages.uut_core.execute_unit.res_buf_selected tb_stages.uut_core.execute_unit.call_dr_o tb_stages.uut_core.execute_unit.cmpxchg_af_o tb_stages.uut_core.execute_unit.cmpxchg_of_o tb_stages.uut_core.execute_unit.and_zf_o }

gui_sg_move "$_session_group_100" -after "$_session_group_98" -pos 11 

set _session_group_101 $_session_group_98|
append _session_group_101 exe_latches_unit
gui_sg_create "$_session_group_101"
set Core|exe_latches_unit "$_session_group_101"

gui_sg_addsignal -group "$_session_group_101" { tb_stages.uut_core.exe_latches_unit.flush tb_stages.uut_core.exe_latches_unit.latches tb_stages.uut_core.exe_latches_unit.latches_o tb_stages.uut_core.exe_latches_unit.farFlush tb_stages.uut_core.exe_latches_unit.nextLatches_i tb_stages.uut_core.exe_latches_unit.clk tb_stages.uut_core.exe_latches_unit.write_enable_i {tb_stages.uut_core.exe_latches_unit.$unit} tb_stages.uut_core.exe_latches_unit.rst }

gui_sg_move "$_session_group_101" -after "$_session_group_98" -pos 10 

set _session_group_102 $_session_group_98|
append _session_group_102 mem_unit
gui_sg_create "$_session_group_102"
set Core|mem_unit "$_session_group_102"

gui_sg_addsignal -group "$_session_group_102" { tb_stages.uut_core.mem_unit.hit_buf_v tb_stages.uut_core.mem_unit.line_in_1_masked tb_stages.uut_core.mem_unit.C0 tb_stages.uut_core.mem_unit.hit_buf_mio tb_stages.uut_core.mem_unit.hit_MIO tb_stages.uut_core.mem_unit.low_buf tb_stages.uut_core.mem_unit.line_in_0 tb_stages.uut_core.mem_unit.latches_i tb_stages.uut_core.mem_unit.line_in_1 tb_stages.uut_core.mem_unit.hit_buf_mio_v tb_stages.uut_core.mem_unit.miss_stall tb_stages.uut_core.mem_unit.line_MIO tb_stages.uut_core.mem_unit.cacheline tb_stages.uut_core.mem_unit.line_in_0_masked tb_stages.uut_core.mem_unit.clr_dcache_mio_latch tb_stages.uut_core.mem_unit.exe_latches_next_o tb_stages.uut_core.mem_unit.forward_valid tb_stages.uut_core.mem_unit.exe_stage_next_vaild_o tb_stages.uut_core.mem_unit.hit_buf tb_stages.uut_core.mem_unit.exe_outs_i tb_stages.uut_core.mem_unit.outs_o tb_stages.uut_core.mem_unit.clk tb_stages.uut_core.mem_unit.line_in_mio tb_stages.uut_core.mem_unit.bank_num_0 tb_stages.uut_core.mem_unit.wb_outs_i tb_stages.uut_core.mem_unit.bank_num_1 tb_stages.uut_core.mem_unit.ld_buf tb_stages.uut_core.mem_unit.hit tb_stages.uut_core.mem_unit.up_buf tb_stages.uut_core.mem_unit.exe_stage_we_valid_unit_o {tb_stages.uut_core.mem_unit.$unit} tb_stages.uut_core.mem_unit.clr_dcache_arb_latches tb_stages.uut_core.mem_unit.rst }

gui_sg_move "$_session_group_102" -after "$_session_group_98" -pos 9 

set _session_group_103 $_session_group_98|
append _session_group_103 mem_latches_unit
gui_sg_create "$_session_group_103"
set Core|mem_latches_unit "$_session_group_103"

gui_sg_addsignal -group "$_session_group_103" { tb_stages.uut_core.mem_latches_unit.flush tb_stages.uut_core.mem_latches_unit.latches tb_stages.uut_core.mem_latches_unit.latches_o tb_stages.uut_core.mem_latches_unit.farFlush tb_stages.uut_core.mem_latches_unit.nextLatches_i tb_stages.uut_core.mem_latches_unit.clk tb_stages.uut_core.mem_latches_unit.write_enable_i tb_stages.uut_core.mem_latches_unit.rst }

gui_sg_move "$_session_group_103" -after "$_session_group_98" -pos 8 

set _session_group_104 $_session_group_98|
append _session_group_104 dc_unit
gui_sg_create "$_session_group_104"
set Core|dc_unit "$_session_group_104"

gui_sg_addsignal -group "$_session_group_104" { tb_stages.uut_core.dc_unit.st_neuralnet_out tb_stages.uut_core.dc_unit.fetch_outs_i tb_stages.uut_core.dc_unit.ld_addr_mio_V tb_stages.uut_core.dc_unit.mem_latches_next_o tb_stages.uut_core.dc_unit.dep_stall tb_stages.uut_core.dc_unit.req_served_0 tb_stages.uut_core.dc_unit.req_served_1 tb_stages.uut_core.dc_unit.mem_ST_OP tb_stages.uut_core.dc_unit.mem_stage_we_valid_unit_o tb_stages.uut_core.dc_unit.data_size_vec tb_stages.uut_core.dc_unit.exp_stall tb_stages.uut_core.dc_unit.ld_addr_mio tb_stages.uut_core.dc_unit.latches_i tb_stages.uut_core.dc_unit.ld_addr_0_V tb_stages.uut_core.dc_unit.stq_stall tb_stages.uut_core.dc_unit.mem_stage_next_vaild_o tb_stages.uut_core.dc_unit.ld_neuralnet_out tb_stages.uut_core.dc_unit.rh_into_mem_o tb_stages.uut_core.dc_unit.ld_addr_1_V tb_stages.uut_core.dc_unit.ld_addr_0 tb_stages.uut_core.dc_unit.dc_ST_OP tb_stages.uut_core.dc_unit.mem_into_rh_o tb_stages.uut_core.dc_unit.ld_addr_1 tb_stages.uut_core.dc_unit.in_flight_stall tb_stages.uut_core.dc_unit.req_served_mio tb_stages.uut_core.dc_unit.exe_outs_i tb_stages.uut_core.dc_unit.arb_stall tb_stages.uut_core.dc_unit.clk tb_stages.uut_core.dc_unit.wb_outs_i tb_stages.uut_core.dc_unit.dc_outs_o tb_stages.uut_core.dc_unit.mem_outs_i tb_stages.uut_core.dc_unit.dc_stall tb_stages.uut_core.dc_unit.exe_ST_OP {tb_stages.uut_core.dc_unit.$unit} tb_stages.uut_core.dc_unit.wb_ST_OP tb_stages.uut_core.dc_unit.rst }

gui_sg_move "$_session_group_104" -after "$_session_group_98" -pos 7 

set _session_group_105 $_session_group_98|
append _session_group_105 dc_latches_unit
gui_sg_create "$_session_group_105"
set Core|dc_latches_unit "$_session_group_105"

gui_sg_addsignal -group "$_session_group_105" { tb_stages.uut_core.dc_latches_unit.flush tb_stages.uut_core.dc_latches_unit.latches tb_stages.uut_core.dc_latches_unit.latches_o tb_stages.uut_core.dc_latches_unit.farFlush tb_stages.uut_core.dc_latches_unit.nextLatches_i tb_stages.uut_core.dc_latches_unit.clk tb_stages.uut_core.dc_latches_unit.write_enable_i {tb_stages.uut_core.dc_latches_unit.$unit} tb_stages.uut_core.dc_latches_unit.rst }

gui_sg_move "$_session_group_105" -after "$_session_group_98" -pos 6 

set _session_group_106 $_session_group_98|
append _session_group_106 rr_unit
gui_sg_create "$_session_group_106"
set Core|rr_unit "$_session_group_106"

gui_sg_addsignal -group "$_session_group_106" { tb_stages.uut_core.rr_unit.fetch_outs_i tb_stages.uut_core.rr_unit.next_ld_vaddy tb_stages.uut_core.rr_unit.cs_sb tb_stages.uut_core.rr_unit.RR_GP tb_stages.uut_core.rr_unit.addygen_input_addy tb_stages.uut_core.rr_unit.ecx_sb tb_stages.uut_core.rr_unit.ld_vaddy tb_stages.uut_core.rr_unit.next_dc_valid tb_stages.uut_core.rr_unit.latches_i tb_stages.uut_core.rr_unit.dc_latches_next tb_stages.uut_core.rr_unit.seg0_limit_w_datasize tb_stages.uut_core.rr_unit.seg1_limit_w_datasize tb_stages.uut_core.rr_unit.latchesInUse tb_stages.uut_core.rr_unit.SEGMENT_LIMITS tb_stages.uut_core.rr_unit.reg_out tb_stages.uut_core.rr_unit.instructionforward tb_stages.uut_core.rr_unit.rr_stall tb_stages.uut_core.rr_unit.dc_latches_we tb_stages.uut_core.rr_unit.dc_outs_i tb_stages.uut_core.rr_unit.exe_outs_i tb_stages.uut_core.rr_unit.outs_o tb_stages.uut_core.rr_unit.clk tb_stages.uut_core.rr_unit.wb_outs_i tb_stages.uut_core.rr_unit.mem_outs_i tb_stages.uut_core.rr_unit.depstall {tb_stages.uut_core.rr_unit.$unit} tb_stages.uut_core.rr_unit.actual_st_vaddy tb_stages.uut_core.rr_unit.rst tb_stages.uut_core.rr_unit.decode_outs_i tb_stages.uut_core.rr_unit.actual_next_st_vaddy }

gui_sg_move "$_session_group_106" -after "$_session_group_98" -pos 5 

set _session_group_107 $_session_group_98|
append _session_group_107 rr_latches_unit
gui_sg_create "$_session_group_107"
set Core|rr_latches_unit "$_session_group_107"

gui_sg_addsignal -group "$_session_group_107" { tb_stages.uut_core.rr_latches_unit.flush tb_stages.uut_core.rr_latches_unit.latches tb_stages.uut_core.rr_latches_unit.latches_o tb_stages.uut_core.rr_latches_unit.farFlush tb_stages.uut_core.rr_latches_unit.nextLatches_i tb_stages.uut_core.rr_latches_unit.clk tb_stages.uut_core.rr_latches_unit.write_enable_i tb_stages.uut_core.rr_latches_unit.rst }

gui_sg_move "$_session_group_107" -after "$_session_group_98" -pos 4 

set _session_group_108 $_session_group_98|
append _session_group_108 decode_unit
gui_sg_create "$_session_group_108"
set Core|decode_unit "$_session_group_108"

gui_sg_addsignal -group "$_session_group_108" { tb_stages.uut_core.decode_unit.outs_o tb_stages.uut_core.decode_unit.rst tb_stages.uut_core.decode_unit.rr_latches_next tb_stages.uut_core.decode_unit.modrm_byte tb_stages.uut_core.decode_unit.temp_mem_cs tb_stages.uut_core.decode_unit.exe_outs_i tb_stages.uut_core.decode_unit.stall tb_stages.uut_core.decode_unit.REP_LATCH tb_stages.uut_core.decode_unit.sib_size tb_stages.uut_core.decode_unit.next_rr_valid tb_stages.uut_core.decode_unit.clk tb_stages.uut_core.decode_unit.invalid_inst tb_stages.uut_core.decode_unit.sibscale tb_stages.uut_core.decode_unit.HALT_REG tb_stages.uut_core.decode_unit.predicted_target tb_stages.uut_core.decode_unit.temp_exe_cs tb_stages.uut_core.decode_unit.temp_decode_cs tb_stages.uut_core.decode_unit.rr_outs_i tb_stages.uut_core.decode_unit.predicted_taken tb_stages.uut_core.decode_unit.inst_length tb_stages.uut_core.decode_unit.PrevEIP tb_stages.uut_core.decode_unit.opcode_byte tb_stages.uut_core.decode_unit.temp_dc_cs tb_stages.uut_core.decode_unit.displacement tb_stages.uut_core.decode_unit.total_pf_vector tb_stages.uut_core.decode_unit.wb_outs_i tb_stages.uut_core.decode_unit.temp_rr_latch tb_stages.uut_core.decode_unit.rep_latch_holder tb_stages.uut_core.decode_unit.sibbase tb_stages.uut_core.decode_unit.segment0 tb_stages.uut_core.decode_unit.NEIP tb_stages.uut_core.decode_unit.temp_wb_cs tb_stages.uut_core.decode_unit.rr_latch_we_o tb_stages.uut_core.decode_unit.sib_byte tb_stages.uut_core.decode_unit.mem_outs_i tb_stages.uut_core.decode_unit.queue tb_stages.uut_core.decode_unit.disp_size tb_stages.uut_core.decode_unit.br_info_for_latches tb_stages.uut_core.decode_unit.EIP tb_stages.uut_core.decode_unit.PrevLength tb_stages.uut_core.decode_unit.fetch_outs_i tb_stages.uut_core.decode_unit.rep_reg_value tb_stages.uut_core.decode_unit.REP_CMP_LATCH tb_stages.uut_core.decode_unit.sibidx tb_stages.uut_core.decode_unit.decode_gp tb_stages.uut_core.decode_unit.idm_outs_i {tb_stages.uut_core.decode_unit.$unit} tb_stages.uut_core.decode_unit.flush tb_stages.uut_core.decode_unit.imm64 tb_stages.uut_core.decode_unit.temp_rr_cs tb_stages.uut_core.decode_unit.dc_outs_i tb_stages.uut_core.decode_unit.disp_needed }

gui_sg_move "$_session_group_108" -after "$_session_group_98" -pos 3 

set _session_group_109 $_session_group_108|
append _session_group_109 cs
gui_sg_create "$_session_group_109"
set Core|decode_unit|cs "$_session_group_109"

gui_sg_addsignal -group "$_session_group_109" { {tb_stages.uut_core.decode_unit.cs.$unit} tb_stages.uut_core.decode_unit.cs.total_pf_vector tb_stages.uut_core.decode_unit.cs.opcode tb_stages.uut_core.decode_unit.cs.modrm tb_stages.uut_core.decode_unit.cs.input_bus tb_stages.uut_core.decode_unit.cs.REP_o tb_stages.uut_core.decode_unit.cs.REP_CMP_o tb_stages.uut_core.decode_unit.cs.HALT_o tb_stages.uut_core.decode_unit.cs.MOVS_o tb_stages.uut_core.decode_unit.cs.SHIFT_BY_ONE_o tb_stages.uut_core.decode_unit.cs.MODRM_NEEDED_o tb_stages.uut_core.decode_unit.cs.RM_IS_DR_o tb_stages.uut_core.decode_unit.cs.REG_IS_DR_o tb_stages.uut_core.decode_unit.cs.REG_IS_SEGMENT_o tb_stages.uut_core.decode_unit.cs.HARD_CODED_DR_o tb_stages.uut_core.decode_unit.cs.HARD_CODED_SR_o tb_stages.uut_core.decode_unit.cs.OP_IN_MODRM_o tb_stages.uut_core.decode_unit.cs.HARDCODED_DR_RD_o tb_stages.uut_core.decode_unit.cs.HARDCODED_SR_RD_o tb_stages.uut_core.decode_unit.cs.ST_SEL_o tb_stages.uut_core.decode_unit.cs.br_uncond_o tb_stages.uut_core.decode_unit.cs.relative_branch_o tb_stages.uut_core.decode_unit.cs.special_br_o tb_stages.uut_core.decode_unit.cs.is_far_o tb_stages.uut_core.decode_unit.cs.second_flag_needed_o tb_stages.uut_core.decode_unit.cs.will_mod_zf_o tb_stages.uut_core.decode_unit.cs.HARDCODED_SEGMENT1_V_o tb_stages.uut_core.decode_unit.cs.HARD_CODED_DR_ID_o tb_stages.uut_core.decode_unit.cs.HARD_CODED_SR_ID_o tb_stages.uut_core.decode_unit.cs.DATA_SIZE_o tb_stages.uut_core.decode_unit.cs.OP_IN_MODRM_SUBSET_o tb_stages.uut_core.decode_unit.cs.alu_inputA_sel_o tb_stages.uut_core.decode_unit.cs.alu_inputB_sel_o tb_stages.uut_core.decode_unit.cs.branch_target_sel_o tb_stages.uut_core.decode_unit.cs.OP_TYPE_o tb_stages.uut_core.decode_unit.cs.HARDCODED_SEGMENT0_o tb_stages.uut_core.decode_unit.cs.HARDCODED_SEGMENT1_o tb_stages.uut_core.decode_unit.cs.decode_cs tb_stages.uut_core.decode_unit.cs.rr_cs tb_stages.uut_core.decode_unit.cs.dc_cs tb_stages.uut_core.decode_unit.cs.mem_cs tb_stages.uut_core.decode_unit.cs.exe_cs tb_stages.uut_core.decode_unit.cs.wb_cs tb_stages.uut_core.decode_unit.cs.temp_decode_cs tb_stages.uut_core.decode_unit.cs.temp_rr_cs tb_stages.uut_core.decode_unit.cs.temp_dc_cs tb_stages.uut_core.decode_unit.cs.temp_mem_cs tb_stages.uut_core.decode_unit.cs.temp_exe_cs tb_stages.uut_core.decode_unit.cs.temp_wb_cs tb_stages.uut_core.decode_unit.cs.mod_rm_cs_outs }

gui_sg_move "$_session_group_109" -after "$_session_group_108" -pos 1 

set _session_group_110 $_session_group_108|
append _session_group_110 inst_processing
gui_sg_create "$_session_group_110"
set Core|decode_unit|inst_processing "$_session_group_110"

gui_sg_addsignal -group "$_session_group_110" { {tb_stages.uut_core.decode_unit.inst_processing.$unit} tb_stages.uut_core.decode_unit.inst_processing.clk tb_stages.uut_core.decode_unit.inst_processing.rst tb_stages.uut_core.decode_unit.inst_processing.queue tb_stages.uut_core.decode_unit.inst_processing.queue_valid tb_stages.uut_core.decode_unit.inst_processing.EIP tb_stages.uut_core.decode_unit.inst_processing.NEIP tb_stages.uut_core.decode_unit.inst_processing.inst_length tb_stages.uut_core.decode_unit.inst_processing.sib_byte tb_stages.uut_core.decode_unit.inst_processing.sib_size tb_stages.uut_core.decode_unit.inst_processing.opcode_byte tb_stages.uut_core.decode_unit.inst_processing.modrm_byte tb_stages.uut_core.decode_unit.inst_processing.disp tb_stages.uut_core.decode_unit.inst_processing.disp_size tb_stages.uut_core.decode_unit.inst_processing.disp_needed tb_stages.uut_core.decode_unit.inst_processing.imm64 tb_stages.uut_core.decode_unit.inst_processing.total_pf_vector tb_stages.uut_core.decode_unit.inst_processing.invalid_inst tb_stages.uut_core.decode_unit.inst_processing.IR tb_stages.uut_core.decode_unit.inst_processing.IR_valid_vect tb_stages.uut_core.decode_unit.inst_processing.ppu_inst_length tb_stages.uut_core.decode_unit.inst_processing.ppu_imm_size tb_stages.uut_core.decode_unit.inst_processing.ppu_msd_size tb_stages.uut_core.decode_unit.inst_processing.ppu_sib_byte tb_stages.uut_core.decode_unit.inst_processing.ppu_displacement tb_stages.uut_core.decode_unit.inst_processing.ppu_imm tb_stages.uut_core.decode_unit.inst_processing.ppu_needrm tb_stages.uut_core.decode_unit.inst_processing.ppu_disp_size tb_stages.uut_core.decode_unit.inst_processing.ppu_disp_needed tb_stages.uut_core.decode_unit.inst_processing.ppu_sib_size tb_stages.uut_core.decode_unit.inst_processing.num_pfs tb_stages.uut_core.decode_unit.inst_processing.pf_vector0 tb_stages.uut_core.decode_unit.inst_processing.pf_vector1 tb_stages.uut_core.decode_unit.inst_processing.pf_vector2 tb_stages.uut_core.decode_unit.inst_processing.sext_inst_length tb_stages.uut_core.decode_unit.inst_processing.inst_length_cout tb_stages.uut_core.decode_unit.inst_processing.inst_valid tb_stages.uut_core.decode_unit.inst_processing.true_inst_valid tb_stages.uut_core.decode_unit.inst_processing.adder_cout tb_stages.uut_core.decode_unit.inst_processing.possible_eips tb_stages.uut_core.decode_unit.inst_processing.pf0 tb_stages.uut_core.decode_unit.inst_processing.pf1 tb_stages.uut_core.decode_unit.inst_processing.pf2 }

set _session_group_111 $_session_group_98|
append _session_group_111 idm_unit
gui_sg_create "$_session_group_111"
set Core|idm_unit "$_session_group_111"

gui_sg_addsignal -group "$_session_group_111" { tb_stages.uut_core.idm_unit.fetch_outs_i tb_stages.uut_core.idm_unit.idm_outs_o tb_stages.uut_core.idm_unit.clk tb_stages.uut_core.idm_unit.idm tb_stages.uut_core.idm_unit.rst }

gui_sg_move "$_session_group_111" -after "$_session_group_98" -pos 2 

set _session_group_112 $_session_group_98|
append _session_group_112 fetch_unit
gui_sg_create "$_session_group_112"
set Core|fetch_unit "$_session_group_112"

gui_sg_addsignal -group "$_session_group_112" { tb_stages.uut_core.fetch_unit.spc_sel_logic_outs tb_stages.uut_core.fetch_unit.SPC tb_stages.uut_core.fetch_unit.predictor_inputs tb_stages.uut_core.fetch_unit.seg_xlation_out tb_stages.uut_core.fetch_unit.rr_outs_i tb_stages.uut_core.fetch_unit.idm_ctrl_data_in tb_stages.uut_core.fetch_unit.rom_data_out tb_stages.uut_core.fetch_unit.icache_info_i tb_stages.uut_core.fetch_unit.spc_16 tb_stages.uut_core.fetch_unit.idm_invalidate_logic_outs tb_stages.uut_core.fetch_unit.DMA_int_jk tb_stages.uut_core.fetch_unit.br_target tb_stages.uut_core.fetch_unit.btb_outs tb_stages.uut_core.fetch_unit.predictor_outs tb_stages.uut_core.fetch_unit.dc_outs_i tb_stages.uut_core.fetch_unit.exe_outs_i tb_stages.uut_core.fetch_unit.outs_o tb_stages.uut_core.fetch_unit.clk tb_stages.uut_core.fetch_unit.tlb_inputs tb_stages.uut_core.fetch_unit.wb_outs_i tb_stages.uut_core.fetch_unit.idm_info_i tb_stages.uut_core.fetch_unit.en_icache tb_stages.uut_core.fetch_unit.mem_outs_i tb_stages.uut_core.fetch_unit.f_exp tb_stages.uut_core.fetch_unit.exp_mode_jk tb_stages.uut_core.fetch_unit.br_restore_spc tb_stages.uut_core.fetch_unit.dma_int tb_stages.uut_core.fetch_unit.exp_set_logic_outs tb_stages.uut_core.fetch_unit.int_mode_jk tb_stages.uut_core.fetch_unit.idm_ctrl_logic_outs tb_stages.uut_core.fetch_unit.next_spc tb_stages.uut_core.fetch_unit.spc_2_IDM_CTRL tb_stages.uut_core.fetch_unit.tlb_outs tb_stages.uut_core.fetch_unit.rst tb_stages.uut_core.fetch_unit.decode_outs_i }

gui_sg_move "$_session_group_112" -after "$_session_group_98" -pos 1 

set _session_group_113 $_session_group_98|
append _session_group_113 uut_core
gui_sg_create "$_session_group_113"
set Core|uut_core "$_session_group_113"

gui_sg_addsignal -group "$_session_group_113" { tb_stages.uut_core.mem_latches tb_stages.uut_core.wb_latches_next tb_stages.uut_core.DCacheIn_i tb_stages.uut_core.inFromDMA_i tb_stages.uut_core.dc_outputs tb_stages.uut_core.mem_latches_next tb_stages.uut_core.mem_outputs tb_stages.uut_core.dc_latches_next tb_stages.uut_core.wb_latches tb_stages.uut_core.rr_latches_next tb_stages.uut_core.rr_latches tb_stages.uut_core.exe_latches tb_stages.uut_core.idm_outputs tb_stages.uut_core.fetch_outputs tb_stages.uut_core.clk tb_stages.uut_core.wb_outputs tb_stages.uut_core.decode_outputs tb_stages.uut_core.rr_outputs tb_stages.uut_core.exe_latches_next tb_stages.uut_core.out2DCache_o tb_stages.uut_core.exe_outputs {tb_stages.uut_core.$unit} tb_stages.uut_core.ICacheIn_i tb_stages.uut_core.dc_latches tb_stages.uut_core.out2ICache_o tb_stages.uut_core.rst }

set _session_group_114 $_session_group_98|
append _session_group_114 write_back_unit
gui_sg_create "$_session_group_114"
set Core|write_back_unit "$_session_group_114"

gui_sg_addsignal -group "$_session_group_114" { tb_stages.uut_core.write_back_unit.write_success tb_stages.uut_core.write_back_unit.reg_wb_logic_outs tb_stages.uut_core.write_back_unit.stq_info tb_stages.uut_core.write_back_unit.mio_q_output tb_stages.uut_core.write_back_unit.write_success_mio tb_stages.uut_core.write_back_unit.stq_heads tb_stages.uut_core.write_back_unit.wb_latches tb_stages.uut_core.write_back_unit.outputs tb_stages.uut_core.write_back_unit.mio_q_input tb_stages.uut_core.write_back_unit.stq_outputs tb_stages.uut_core.write_back_unit.dc_dep tb_stages.uut_core.write_back_unit.clk tb_stages.uut_core.write_back_unit.stall_flop_next tb_stages.uut_core.write_back_unit.stall_flop {tb_stages.uut_core.write_back_unit.$unit} tb_stages.uut_core.write_back_unit.rst }

gui_sg_move "$_session_group_114" -after "$_session_group_98" -pos 13 

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 558164



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
catch {gui_list_expand -id ${Hier.1} tb_stages.uut_core.decode_unit}
catch {gui_list_select -id ${Hier.1} {tb_stages.uut_core.decode_unit.cs}}
gui_view_scroll -id ${Hier.1} -vertical -set 130
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {tb_stages.uut_core.decode_unit.inst_processing}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 130
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Hier 'Hier.2'
gui_show_window -window ${Hier.2}
gui_list_set_filter -id ${Hier.2} -list { {Package 1} {All 0} {Process 1} {VirtPowSwitch 0} {UnnamedProcess 1} {UDP 0} {Function 0} {Block 1} {SrsnAndSpaCell 0} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {LeafVhdCell 1} {$unit 1} {NamedBlock 0} {Task 0} {VlgPackage 0} {ClassDef 1} {VirtIsoCell 0} }
gui_list_set_filter -id ${Hier.2} -text {*}
gui_hier_list_init -id ${Hier.2}
gui_change_design -id ${Hier.2} -design V1
catch {gui_list_expand -id ${Hier.2} tb_stages}
catch {gui_list_expand -id ${Hier.2} tb_stages.uut_core}
catch {gui_list_expand -id ${Hier.2} tb_stages.uut_core.rr_unit}
catch {gui_list_select -id ${Hier.2} {tb_stages.uut_core.rr_unit.RegisterFile_unit}}
gui_view_scroll -id ${Hier.2} -vertical -set 156
gui_view_scroll -id ${Hier.2} -horizontal -set 0

# Data 'Data.2'
gui_list_set_filter -id ${Data.2} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.2} -text {*}
gui_list_show_data -id ${Data.2} {tb_stages.uut_core.decode_unit.inst_processing}
gui_view_scroll -id ${Data.2} -vertical -set 0
gui_view_scroll -id ${Data.2} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 130
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
gui_wv_zoom_timerange -id ${Wave.1} 246427 525948
gui_list_add_group -id ${Wave.1} -after {New Group} {MainMem}
gui_list_add_group -id ${Wave.1}  -after MainMem {MainMem|uut_mem}
gui_list_add_group -id ${Wave.1} -after MainMem|uut_mem {MainMem|controller}
gui_list_add_group -id ${Wave.1} -after {New Group} {BusArb}
gui_list_add_group -id ${Wave.1}  -after BusArb {BusArb|uut4_busArb}
gui_list_add_group -id ${Wave.1} -after BusArb|uut4_busArb {BusArb|scheduler_unit}
gui_list_add_group -id ${Wave.1} -after BusArb|scheduler_unit {BusArb|dte_unit}
gui_list_add_group -id ${Wave.1} -after {New Group} {DCache}
gui_list_add_group -id ${Wave.1}  -after DCache {DCache|uut_dcache}
gui_list_add_group -id ${Wave.1} -after DCache|uut_dcache {DCache|dcache_arbitration}
gui_list_add_group -id ${Wave.1} -after DCache|dcache_arbitration {DCache|mio_block_unit}
gui_list_add_group -id ${Wave.1} -after DCache|mio_block_unit {{DCache|g_dcache_block[3].block}}
gui_list_add_group -id ${Wave.1} -after {{DCache|g_dcache_block[3].block}} {{DCache|g_dcache_block[2].block}}
gui_list_add_group -id ${Wave.1} -after {{DCache|g_dcache_block[2].block}} {{DCache|g_dcache_block[1].block}}
gui_list_add_group -id ${Wave.1} -after {{DCache|g_dcache_block[1].block}} {{DCache|g_dcache_block[0].block}}
gui_list_add_group -id ${Wave.1} -after {New Group} {ICache}
gui_list_add_group -id ${Wave.1}  -after ICache {ICache|uut_icache}
gui_list_add_group -id ${Wave.1} -after ICache|uut_icache {ICache|icache_dataStore_unit}
gui_list_add_group -id ${Wave.1} -after ICache|icache_dataStore_unit {ICache|icache_contrller_fsm}
gui_list_add_group -id ${Wave.1} -after ICache|icache_contrller_fsm {ICache|icache_TagStore_unit}
gui_list_add_group -id ${Wave.1} -after ICache|icache_TagStore_unit {ICache|i_vcache_unit}
gui_list_add_group -id ${Wave.1} -after {New Group} {Core}
gui_list_add_group -id ${Wave.1}  -after Core {Core|uut_core}
gui_list_add_group -id ${Wave.1} -after Core|uut_core {Core|fetch_unit}
gui_list_add_group -id ${Wave.1} -after Core|fetch_unit {Core|idm_unit}
gui_list_add_group -id ${Wave.1} -after Core|idm_unit {Core|decode_unit}
gui_list_add_group -id ${Wave.1}  -after Core|decode_unit {Core|decode_unit|inst_processing}
gui_list_add_group -id ${Wave.1} -after Core|decode_unit|inst_processing {Core|decode_unit|cs}
gui_list_add_group -id ${Wave.1} -after Core|decode_unit {Core|rr_latches_unit}
gui_list_add_group -id ${Wave.1} -after Core|rr_latches_unit {Core|rr_unit}
gui_list_add_group -id ${Wave.1} -after Core|rr_unit {Core|dc_latches_unit}
gui_list_add_group -id ${Wave.1} -after Core|dc_latches_unit {Core|dc_unit}
gui_list_add_group -id ${Wave.1} -after Core|dc_unit {Core|mem_latches_unit}
gui_list_add_group -id ${Wave.1} -after Core|mem_latches_unit {Core|mem_unit}
gui_list_add_group -id ${Wave.1} -after Core|mem_unit {Core|exe_latches_unit}
gui_list_add_group -id ${Wave.1} -after Core|exe_latches_unit {Core|execute_unit}
gui_list_add_group -id ${Wave.1} -after Core|execute_unit {Core|wb_latches_unit}
gui_list_add_group -id ${Wave.1} -after Core|wb_latches_unit {Core|write_back_unit}
gui_list_collapse -id ${Wave.1} MainMem
gui_list_collapse -id ${Wave.1} BusArb
gui_list_collapse -id ${Wave.1} DCache
gui_list_collapse -id ${Wave.1} ICache
gui_list_collapse -id ${Wave.1} Core|uut_core
gui_list_collapse -id ${Wave.1} Core|fetch_unit
gui_list_collapse -id ${Wave.1} Core|idm_unit
gui_list_collapse -id ${Wave.1} Core|decode_unit|inst_processing
gui_list_collapse -id ${Wave.1} Core|decode_unit|cs
gui_list_collapse -id ${Wave.1} Core|rr_latches_unit
gui_list_collapse -id ${Wave.1} Core|rr_unit
gui_list_collapse -id ${Wave.1} Core|dc_latches_unit
gui_list_collapse -id ${Wave.1} Core|dc_unit
gui_list_collapse -id ${Wave.1} Core|mem_latches_unit
gui_list_collapse -id ${Wave.1} Core|mem_unit
gui_list_collapse -id ${Wave.1} Core|exe_latches_unit
gui_list_collapse -id ${Wave.1} Core|execute_unit
gui_list_collapse -id ${Wave.1} Core|wb_latches_unit
gui_list_collapse -id ${Wave.1} Core|write_back_unit
gui_list_select -id ${Wave.1} {tb_stages.uut_core.decode_unit.sib_size }
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
gui_list_set_insertion_bar  -id ${Wave.1} -group Core|decode_unit  -item tb_stages.uut_core.decode_unit.sib_size -position below

gui_marker_move -id ${Wave.1} {C1} 558164
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

