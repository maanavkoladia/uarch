# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Mon Mar 30 01:30:45 2026
# Designs open: 1
#   V1: vcdplus.vpd
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: tb_DTE.uut0_DTE
#   Wave.1: 720 signals
#   Group count = 22
#   Group tb_DTE signal count = 12
#   Group Group1 signal count = 14
#   Group tb_DTE_1 signal count = 16
#   Group uut0_DTE signal count = 57
#   Group uut1_mem signal count = 13
#   Group uut0_DTE_1 signal count = 58
#   Group DTE_MEM_2_ICache signal count = 43
#   Group controller signal count = 20
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
gui_show_window -window ${TopLevel.1} -show_state normal -rect {{17 31} {1918 1006}}

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
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 454]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 454
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 453} {height 740} {dock_state left} {dock_on_new_line true} {child_hier_colhier 328} {child_hier_coltype 100} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 684]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 684
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 933
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 683} {height 740} {dock_state left} {dock_on_new_line true} {child_data_colvariable 352} {child_data_colvalue 161} {child_data_coltype 159} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 161]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 1868
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 161
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 1901} {height 160} {dock_state bottom} {dock_on_new_line true}}
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
gui_show_window -window ${TopLevel.2} -show_state normal -rect {{13 31} {1879 1006}}

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
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 542} {child_wave_right 1319} {child_wave_colname 288} {child_wave_colvalue 250} {child_wave_col1 0} {child_wave_col2 1}}

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
gui_load_child_values {tb_DTE.uut0_DTE.core_2_ddr5_fsm}
gui_load_child_values {tb_DTE.uut0_DTE.dma_2_mem_fsm}
gui_load_child_values {tb_DTE.uut0_DTE.ddr5_2_core_fsm}
gui_load_child_values {tb_DTE.uut0_DTE}
gui_load_child_values {tb_DTE.uut1_mem.controller}
gui_load_child_values {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm}
gui_load_child_values {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm}
gui_load_child_values {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm}
gui_load_child_values {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm}
gui_load_child_values {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm}
gui_load_child_values {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm}
gui_load_child_values {tb_DTE.uut0_DTE.core_2_dma_fsm}
gui_load_child_values {tb_DTE.uut1_mem}
gui_load_child_values {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm}
gui_load_child_values {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm}
gui_load_child_values {tb_DTE}
gui_load_child_values {tb_DTE.uut0_DTE.DTE_MEM_2_ICache}


set _session_group_161 tb_DTE
gui_sg_create "$_session_group_161"
set tb_DTE "$_session_group_161"

gui_sg_addsignal -group "$_session_group_161" { {tb_DTE.$unit} tb_DTE.rst tb_DTE.clk tb_DTE.bestPick_req_2_dte tb_DTE.bestPick_bk_id_2_dte tb_DTE.Clk_PERIOD tb_DTE.dte_2_icache tb_DTE.dte_2_dcache tb_DTE.mem_2_dte tb_DTE.dte_2_mem tb_DTE.dte_2_dma tb_DTE.dte_2_ddr5 }
gui_set_radix -radix {decimal} -signals {V1:tb_DTE.Clk_PERIOD}
gui_set_radix -radix {twosComplement} -signals {V1:tb_DTE.Clk_PERIOD}

set _session_group_162 Group1
gui_sg_create "$_session_group_162"
set Group1 "$_session_group_162"

gui_sg_addsignal -group "$_session_group_162" { }

set _session_group_163 $_session_group_162|
append _session_group_163 uut0_DTE
gui_sg_create "$_session_group_163"
set Group1|uut0_DTE "$_session_group_163"

gui_sg_addsignal -group "$_session_group_163" { {tb_DTE.uut0_DTE.$unit} tb_DTE.uut0_DTE.clk tb_DTE.uut0_DTE.DTE_Busy tb_DTE.uut0_DTE.bestPick_bk_id_i tb_DTE.uut0_DTE.bestPick_i tb_DTE.uut0_DTE.core_2_ddr5_driveAddrBus_fsmOut tb_DTE.uut0_DTE.core_2_ddr5_drvDB_fsmOut tb_DTE.uut0_DTE.core_2_ddr5_reqServed_fsmOut tb_DTE.uut0_DTE.core_2_ddr5_req_hit tb_DTE.uut0_DTE.core_2_dma_driveAddrBus_fsmOut tb_DTE.uut0_DTE.core_2_dma_drvDB_fsmOut tb_DTE.uut0_DTE.core_2_dma_reqServed_fsmOut tb_DTE.uut0_DTE.core_2_dma_req_hit tb_DTE.uut0_DTE.dcache_2_mem_bk_hit tb_DTE.uut0_DTE.dcache_2_mem_fsmout_busy_per tb_DTE.uut0_DTE.dcache_2_mem_req_hit tb_DTE.uut0_DTE.dcache_2_mem_st_req_fsmOut tb_DTE.uut0_DTE.ddr5_2_core_driveAddrBus_fsmOut tb_DTE.uut0_DTE.ddr5_2_core_reqServed_fsmOut tb_DTE.uut0_DTE.ddr5_2_core_req_hit tb_DTE.uut0_DTE.dma_2_mem_req_hit tb_DTE.uut0_DTE.dma_2_mem_st_req_fsmOut tb_DTE.uut0_DTE.dte_2_ddr5_o tb_DTE.uut0_DTE.dte_2_dma_o tb_DTE.uut0_DTE.dte_2_mem_o tb_DTE.uut0_DTE.dte_dcache_2_mem_fsm_state tb_DTE.uut0_DTE.dte_mem_2_dcache_fsm_state tb_DTE.uut0_DTE.dte_mem_2_icache_fsm_state tb_DTE.uut0_DTE.dte_out_2_dcache_o tb_DTE.uut0_DTE.dte_out_2_icache_o tb_DTE.uut0_DTE.mem_2_dcache_bk_hit tb_DTE.uut0_DTE.mem_2_dcache_drv_db_fsmOut tb_DTE.uut0_DTE.mem_2_dcache_fsmout_busy_per tb_DTE.uut0_DTE.mem_2_dcache_ld_req_fsmOut tb_DTE.uut0_DTE.mem_2_dcache_req_hit tb_DTE.uut0_DTE.mem_2_dte_i tb_DTE.uut0_DTE.mem_2_icache_drv_db_fsmOut tb_DTE.uut0_DTE.mem_2_icache_ld_req_fsmOut tb_DTE.uut0_DTE.mem_2_icache_req_hit tb_DTE.uut0_DTE.rst }

gui_sg_move "$_session_group_163" -after "$_session_group_162" -pos 10 

set _session_group_164 $_session_group_162|
append _session_group_164 DTE_MEM_2_ICache
gui_sg_create "$_session_group_164"
set Group1|DTE_MEM_2_ICache "$_session_group_164"

gui_sg_addsignal -group "$_session_group_164" { {tb_DTE.uut0_DTE.DTE_MEM_2_ICache.$unit} tb_DTE.uut0_DTE.DTE_MEM_2_ICache.Drive_Addr_Bus_o tb_DTE.uut0_DTE.DTE_MEM_2_ICache.Drive_Addr_Bus_o_t0 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.Drive_Addr_Bus_o_t1 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.Drive_Addr_Bus_o_t2 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.Drive_Addr_Bus_o_t3 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.Drv_DB_0_o tb_DTE.uut0_DTE.DTE_MEM_2_ICache.Drv_DB_1_o tb_DTE.uut0_DTE.DTE_MEM_2_ICache.Drv_DB_2_o tb_DTE.uut0_DTE.DTE_MEM_2_ICache.Drv_DB_3_o tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_0 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_0_t0 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_0_t1 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_0_t2 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_1 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_1_t0 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_1_t1 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_2 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_2_t0 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_2_t1 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_2_t2 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.S_0_inv tb_DTE.uut0_DTE.DTE_MEM_2_ICache.S_1_inv tb_DTE.uut0_DTE.DTE_MEM_2_ICache.S_2_inv tb_DTE.uut0_DTE.DTE_MEM_2_ICache.busy_o tb_DTE.uut0_DTE.DTE_MEM_2_ICache.busy_o_t0 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.busy_o_t1 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.busy_o_t2 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.clk tb_DTE.uut0_DTE.DTE_MEM_2_ICache.ld_req_o tb_DTE.uut0_DTE.DTE_MEM_2_ICache.mem_ready_i tb_DTE.uut0_DTE.DTE_MEM_2_ICache.mem_ready_i_inv tb_DTE.uut0_DTE.DTE_MEM_2_ICache.mem_valid_o tb_DTE.uut0_DTE.DTE_MEM_2_ICache.mem_valid_o_t0 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.mem_valid_o_t1 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.mem_valid_o_t2 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.others_busy_i tb_DTE.uut0_DTE.DTE_MEM_2_ICache.others_busy_i_inv tb_DTE.uut0_DTE.DTE_MEM_2_ICache.req_hit_i tb_DTE.uut0_DTE.DTE_MEM_2_ICache.rst }

gui_sg_move "$_session_group_164" -after "$_session_group_162" -pos 9 

set _session_group_165 $_session_group_162|
append _session_group_165 core_2_ddr5_fsm
gui_sg_create "$_session_group_165"
set Group1|core_2_ddr5_fsm "$_session_group_165"

gui_sg_addsignal -group "$_session_group_165" { {tb_DTE.uut0_DTE.core_2_ddr5_fsm.$unit} tb_DTE.uut0_DTE.core_2_ddr5_fsm.Drive_Addr_Bus_o tb_DTE.uut0_DTE.core_2_ddr5_fsm.Drive_Addr_Bus_o_t0 tb_DTE.uut0_DTE.core_2_ddr5_fsm.Drive_Addr_Bus_o_t1 tb_DTE.uut0_DTE.core_2_ddr5_fsm.Drv_DB_o tb_DTE.uut0_DTE.core_2_ddr5_fsm.NS_0 tb_DTE.uut0_DTE.core_2_ddr5_fsm.NS_1 tb_DTE.uut0_DTE.core_2_ddr5_fsm.NS_1_t0 tb_DTE.uut0_DTE.core_2_ddr5_fsm.NS_1_t1 tb_DTE.uut0_DTE.core_2_ddr5_fsm.S_0 tb_DTE.uut0_DTE.core_2_ddr5_fsm.S_0_inv tb_DTE.uut0_DTE.core_2_ddr5_fsm.S_1 tb_DTE.uut0_DTE.core_2_ddr5_fsm.S_1_inv tb_DTE.uut0_DTE.core_2_ddr5_fsm.busy_o tb_DTE.uut0_DTE.core_2_ddr5_fsm.busy_o_t0 tb_DTE.uut0_DTE.core_2_ddr5_fsm.busy_o_t1 tb_DTE.uut0_DTE.core_2_ddr5_fsm.clk tb_DTE.uut0_DTE.core_2_ddr5_fsm.newPowerGateValueFromCore_o tb_DTE.uut0_DTE.core_2_ddr5_fsm.others_busy_i tb_DTE.uut0_DTE.core_2_ddr5_fsm.others_busy_i_inv tb_DTE.uut0_DTE.core_2_ddr5_fsm.reqServed_o tb_DTE.uut0_DTE.core_2_ddr5_fsm.req_hit_i tb_DTE.uut0_DTE.core_2_ddr5_fsm.rst }

gui_sg_move "$_session_group_165" -after "$_session_group_162" -pos 8 

set _session_group_166 $_session_group_162|
append _session_group_166 core_2_dma_fsm
gui_sg_create "$_session_group_166"
set Group1|core_2_dma_fsm "$_session_group_166"

gui_sg_addsignal -group "$_session_group_166" { {tb_DTE.uut0_DTE.core_2_dma_fsm.$unit} tb_DTE.uut0_DTE.core_2_dma_fsm.Drive_Addr_Bus_o tb_DTE.uut0_DTE.core_2_dma_fsm.Drive_Addr_Bus_o_t0 tb_DTE.uut0_DTE.core_2_dma_fsm.Drive_Addr_Bus_o_t1 tb_DTE.uut0_DTE.core_2_dma_fsm.Drv_DB_o tb_DTE.uut0_DTE.core_2_dma_fsm.NS_0 tb_DTE.uut0_DTE.core_2_dma_fsm.NS_1 tb_DTE.uut0_DTE.core_2_dma_fsm.NS_1_t0 tb_DTE.uut0_DTE.core_2_dma_fsm.NS_1_t1 tb_DTE.uut0_DTE.core_2_dma_fsm.S_0 tb_DTE.uut0_DTE.core_2_dma_fsm.S_0_inv tb_DTE.uut0_DTE.core_2_dma_fsm.S_1 tb_DTE.uut0_DTE.core_2_dma_fsm.S_1_inv tb_DTE.uut0_DTE.core_2_dma_fsm.busy_o tb_DTE.uut0_DTE.core_2_dma_fsm.busy_o_t0 tb_DTE.uut0_DTE.core_2_dma_fsm.busy_o_t1 tb_DTE.uut0_DTE.core_2_dma_fsm.clk tb_DTE.uut0_DTE.core_2_dma_fsm.coreValOnBus_o tb_DTE.uut0_DTE.core_2_dma_fsm.others_busy_i tb_DTE.uut0_DTE.core_2_dma_fsm.others_busy_i_inv tb_DTE.uut0_DTE.core_2_dma_fsm.reqServed_o tb_DTE.uut0_DTE.core_2_dma_fsm.req_hit_i tb_DTE.uut0_DTE.core_2_dma_fsm.rst }

gui_sg_move "$_session_group_166" -after "$_session_group_162" -pos 7 

set _session_group_167 $_session_group_162|
append _session_group_167 ddr5_2_core_fsm
gui_sg_create "$_session_group_167"
set Group1|ddr5_2_core_fsm "$_session_group_167"

gui_sg_addsignal -group "$_session_group_167" { {tb_DTE.uut0_DTE.ddr5_2_core_fsm.$unit} tb_DTE.uut0_DTE.ddr5_2_core_fsm.Drive_Addr_Bus_o tb_DTE.uut0_DTE.ddr5_2_core_fsm.Drive_Addr_Bus_o_t0 tb_DTE.uut0_DTE.ddr5_2_core_fsm.Drive_Addr_Bus_o_t1 tb_DTE.uut0_DTE.ddr5_2_core_fsm.Drv_DB_o tb_DTE.uut0_DTE.ddr5_2_core_fsm.NS_0 tb_DTE.uut0_DTE.ddr5_2_core_fsm.NS_1 tb_DTE.uut0_DTE.ddr5_2_core_fsm.NS_1_t0 tb_DTE.uut0_DTE.ddr5_2_core_fsm.NS_1_t1 tb_DTE.uut0_DTE.ddr5_2_core_fsm.S_0 tb_DTE.uut0_DTE.ddr5_2_core_fsm.S_0_inv tb_DTE.uut0_DTE.ddr5_2_core_fsm.S_1 tb_DTE.uut0_DTE.ddr5_2_core_fsm.S_1_inv tb_DTE.uut0_DTE.ddr5_2_core_fsm.busy_o tb_DTE.uut0_DTE.ddr5_2_core_fsm.busy_o_t0 tb_DTE.uut0_DTE.ddr5_2_core_fsm.busy_o_t1 tb_DTE.uut0_DTE.ddr5_2_core_fsm.clk tb_DTE.uut0_DTE.ddr5_2_core_fsm.others_busy_i tb_DTE.uut0_DTE.ddr5_2_core_fsm.others_busy_i_inv tb_DTE.uut0_DTE.ddr5_2_core_fsm.reqServed_o tb_DTE.uut0_DTE.ddr5_2_core_fsm.req_hit_i tb_DTE.uut0_DTE.ddr5_2_core_fsm.rst }

gui_sg_move "$_session_group_167" -after "$_session_group_162" -pos 6 

set _session_group_168 $_session_group_162|
append _session_group_168 dma_2_mem_fsm
gui_sg_create "$_session_group_168"
set Group1|dma_2_mem_fsm "$_session_group_168"

gui_sg_addsignal -group "$_session_group_168" { {tb_DTE.uut0_DTE.dma_2_mem_fsm.$unit} tb_DTE.uut0_DTE.dma_2_mem_fsm.Drive_Addr_Bus_o tb_DTE.uut0_DTE.dma_2_mem_fsm.Drive_Addr_Bus_o_t0 tb_DTE.uut0_DTE.dma_2_mem_fsm.Drive_Addr_Bus_o_t1 tb_DTE.uut0_DTE.dma_2_mem_fsm.Drive_Addr_Bus_o_t2 tb_DTE.uut0_DTE.dma_2_mem_fsm.Drive_Addr_Bus_o_t3 tb_DTE.uut0_DTE.dma_2_mem_fsm.Drv_DB_0_o tb_DTE.uut0_DTE.dma_2_mem_fsm.Drv_DB_1_o tb_DTE.uut0_DTE.dma_2_mem_fsm.Drv_DB_2_o tb_DTE.uut0_DTE.dma_2_mem_fsm.Drv_DB_3_o tb_DTE.uut0_DTE.dma_2_mem_fsm.NS_0 tb_DTE.uut0_DTE.dma_2_mem_fsm.NS_0_t0 tb_DTE.uut0_DTE.dma_2_mem_fsm.NS_0_t1 tb_DTE.uut0_DTE.dma_2_mem_fsm.NS_1 tb_DTE.uut0_DTE.dma_2_mem_fsm.NS_1_t0 tb_DTE.uut0_DTE.dma_2_mem_fsm.NS_1_t1 tb_DTE.uut0_DTE.dma_2_mem_fsm.NS_2 tb_DTE.uut0_DTE.dma_2_mem_fsm.NS_2_t0 tb_DTE.uut0_DTE.dma_2_mem_fsm.NS_2_t1 tb_DTE.uut0_DTE.dma_2_mem_fsm.S_0 tb_DTE.uut0_DTE.dma_2_mem_fsm.S_0_inv tb_DTE.uut0_DTE.dma_2_mem_fsm.S_1 tb_DTE.uut0_DTE.dma_2_mem_fsm.S_1_inv tb_DTE.uut0_DTE.dma_2_mem_fsm.S_2 tb_DTE.uut0_DTE.dma_2_mem_fsm.S_2_inv tb_DTE.uut0_DTE.dma_2_mem_fsm.WriteComplete_o tb_DTE.uut0_DTE.dma_2_mem_fsm.busy_o tb_DTE.uut0_DTE.dma_2_mem_fsm.busy_o_t0 tb_DTE.uut0_DTE.dma_2_mem_fsm.busy_o_t1 tb_DTE.uut0_DTE.dma_2_mem_fsm.busy_o_t2 tb_DTE.uut0_DTE.dma_2_mem_fsm.busy_o_t3 tb_DTE.uut0_DTE.dma_2_mem_fsm.clk tb_DTE.uut0_DTE.dma_2_mem_fsm.others_busy_i tb_DTE.uut0_DTE.dma_2_mem_fsm.others_busy_i_inv tb_DTE.uut0_DTE.dma_2_mem_fsm.req_hit_i tb_DTE.uut0_DTE.dma_2_mem_fsm.rst tb_DTE.uut0_DTE.dma_2_mem_fsm.st_req_o }

gui_sg_move "$_session_group_168" -after "$_session_group_162" -pos 5 

set _session_group_169 $_session_group_162|
append _session_group_169 {g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm}
gui_sg_create "$_session_group_169"
set {Group1|g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm} "$_session_group_169"

gui_sg_addsignal -group "$_session_group_169" { {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.$unit} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.Drive_Addr_Bus_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.Drive_Addr_Bus_o_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.Drive_Addr_Bus_o_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.Drive_Addr_Bus_o_t2} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.Drive_Addr_Bus_o_t3} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.Drv_DB_0_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.Drv_DB_1_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.Drv_DB_2_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.Drv_DB_3_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.NS_0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.NS_0_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.NS_0_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.NS_1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.NS_1_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.NS_1_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.NS_2} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.NS_2_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.NS_2_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.S_0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.S_0_inv} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.S_1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.S_1_inv} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.S_2} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.S_2_inv} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.bank_hit_i} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.busy_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.busy_o_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.busy_o_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.busy_o_t2} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.clk} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.eb_clear_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.others_busy_i} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.others_busy_i_inv} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.req_hit_i} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.rst} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.set_eb_commit_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm.st_req_o} }

gui_sg_move "$_session_group_169" -after "$_session_group_162" -pos 13 

set _session_group_170 $_session_group_162|
append _session_group_170 {g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm}
gui_sg_create "$_session_group_170"
set {Group1|g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm} "$_session_group_170"

gui_sg_addsignal -group "$_session_group_170" { {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.$unit} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.Drive_Addr_Bus_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.Drive_Addr_Bus_o_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.Drive_Addr_Bus_o_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.Drive_Addr_Bus_o_t2} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.Drive_Addr_Bus_o_t3} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.Drv_DB_0_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.Drv_DB_1_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.Drv_DB_2_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.Drv_DB_3_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.NS_0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.NS_0_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.NS_0_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.NS_1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.NS_1_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.NS_1_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.NS_2} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.NS_2_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.NS_2_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.S_0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.S_0_inv} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.S_1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.S_1_inv} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.S_2} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.S_2_inv} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.bank_hit_i} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.busy_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.busy_o_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.busy_o_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.busy_o_t2} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.clk} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.eb_clear_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.others_busy_i} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.others_busy_i_inv} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.req_hit_i} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.rst} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.set_eb_commit_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm.st_req_o} }

gui_sg_move "$_session_group_170" -after "$_session_group_162" -pos 12 

set _session_group_171 $_session_group_162|
append _session_group_171 {g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm}
gui_sg_create "$_session_group_171"
set {Group1|g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm} "$_session_group_171"

gui_sg_addsignal -group "$_session_group_171" { {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.$unit} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.Drive_Addr_Bus_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.Drive_Addr_Bus_o_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.Drive_Addr_Bus_o_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.Drive_Addr_Bus_o_t2} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.Drive_Addr_Bus_o_t3} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.Drv_DB_0_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.Drv_DB_1_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.Drv_DB_2_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.Drv_DB_3_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.NS_0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.NS_0_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.NS_0_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.NS_1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.NS_1_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.NS_1_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.NS_2} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.NS_2_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.NS_2_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.S_0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.S_0_inv} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.S_1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.S_1_inv} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.S_2} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.S_2_inv} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.bank_hit_i} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.busy_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.busy_o_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.busy_o_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.busy_o_t2} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.clk} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.eb_clear_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.others_busy_i} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.others_busy_i_inv} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.req_hit_i} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.rst} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.set_eb_commit_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm.st_req_o} }

gui_sg_move "$_session_group_171" -after "$_session_group_162" -pos 4 

set _session_group_172 $_session_group_162|
append _session_group_172 {g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm}
gui_sg_create "$_session_group_172"
set {Group1|g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm} "$_session_group_172"

gui_sg_addsignal -group "$_session_group_172" { {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.$unit} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.Drive_Addr_Bus_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.Drive_Addr_Bus_o_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.Drive_Addr_Bus_o_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.Drive_Addr_Bus_o_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.Drive_Addr_Bus_o_t3} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.Drv_DB_0_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.Drv_DB_1_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.Drv_DB_2_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.Drv_DB_3_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.NS_0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.NS_0_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.NS_0_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.NS_0_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.NS_1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.NS_1_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.NS_1_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.NS_2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.NS_2_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.NS_2_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.NS_2_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.S_0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.S_0_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.S_1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.S_1_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.S_2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.S_2_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.bank_hit_i} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.busy_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.busy_o_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.busy_o_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.busy_o_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.clk} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.ld_req_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.mem_ready_i} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.mem_ready_i_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.mem_valid_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.mem_valid_o_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.mem_valid_o_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.mem_valid_o_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.others_busy_i} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.others_busy_i_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.req_hit_i} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm.rst} }

gui_sg_move "$_session_group_172" -after "$_session_group_162" -pos 3 

set _session_group_173 $_session_group_162|
append _session_group_173 {g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm}
gui_sg_create "$_session_group_173"
set {Group1|g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm} "$_session_group_173"

gui_sg_addsignal -group "$_session_group_173" { {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.$unit} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.Drive_Addr_Bus_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.Drive_Addr_Bus_o_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.Drive_Addr_Bus_o_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.Drive_Addr_Bus_o_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.Drive_Addr_Bus_o_t3} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.Drv_DB_0_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.Drv_DB_1_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.Drv_DB_2_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.Drv_DB_3_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.NS_0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.NS_0_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.NS_0_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.NS_0_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.NS_1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.NS_1_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.NS_1_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.NS_2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.NS_2_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.NS_2_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.NS_2_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.S_0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.S_0_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.S_1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.S_1_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.S_2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.S_2_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.bank_hit_i} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.busy_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.busy_o_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.busy_o_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.busy_o_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.clk} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.ld_req_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.mem_ready_i} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.mem_ready_i_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.mem_valid_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.mem_valid_o_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.mem_valid_o_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.mem_valid_o_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.others_busy_i} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.others_busy_i_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.req_hit_i} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm.rst} }

gui_sg_move "$_session_group_173" -after "$_session_group_162" -pos 2 

set _session_group_174 $_session_group_162|
append _session_group_174 {g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm}
gui_sg_create "$_session_group_174"
set {Group1|g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm} "$_session_group_174"

gui_sg_addsignal -group "$_session_group_174" { {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.$unit} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.Drive_Addr_Bus_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.Drive_Addr_Bus_o_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.Drive_Addr_Bus_o_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.Drive_Addr_Bus_o_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.Drive_Addr_Bus_o_t3} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.Drv_DB_0_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.Drv_DB_1_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.Drv_DB_2_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.Drv_DB_3_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.NS_0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.NS_0_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.NS_0_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.NS_0_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.NS_1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.NS_1_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.NS_1_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.NS_2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.NS_2_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.NS_2_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.NS_2_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.S_0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.S_0_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.S_1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.S_1_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.S_2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.S_2_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.bank_hit_i} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.busy_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.busy_o_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.busy_o_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.busy_o_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.clk} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.ld_req_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.mem_ready_i} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.mem_ready_i_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.mem_valid_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.mem_valid_o_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.mem_valid_o_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.mem_valid_o_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.others_busy_i} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.others_busy_i_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.req_hit_i} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm.rst} }

gui_sg_move "$_session_group_174" -after "$_session_group_162" -pos 1 

set _session_group_175 $_session_group_162|
append _session_group_175 {g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm}
gui_sg_create "$_session_group_175"
set {Group1|g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm} "$_session_group_175"

gui_sg_addsignal -group "$_session_group_175" { {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.$unit} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.Drive_Addr_Bus_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.Drive_Addr_Bus_o_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.Drive_Addr_Bus_o_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.Drive_Addr_Bus_o_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.Drive_Addr_Bus_o_t3} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.Drv_DB_0_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.Drv_DB_1_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.Drv_DB_2_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.Drv_DB_3_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.NS_0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.NS_0_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.NS_0_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.NS_0_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.NS_1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.NS_1_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.NS_1_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.NS_2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.NS_2_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.NS_2_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.NS_2_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.S_0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.S_0_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.S_1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.S_1_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.S_2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.S_2_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.bank_hit_i} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.busy_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.busy_o_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.busy_o_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.busy_o_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.clk} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.ld_req_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.mem_ready_i} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.mem_ready_i_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.mem_valid_o} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.mem_valid_o_t0} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.mem_valid_o_t1} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.mem_valid_o_t2} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.others_busy_i} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.others_busy_i_inv} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.req_hit_i} {tb_DTE.uut0_DTE.g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm.rst} }

set _session_group_176 $_session_group_162|
append _session_group_176 {g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm}
gui_sg_create "$_session_group_176"
set {Group1|g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm} "$_session_group_176"

gui_sg_addsignal -group "$_session_group_176" { {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.$unit} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.Drive_Addr_Bus_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.Drive_Addr_Bus_o_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.Drive_Addr_Bus_o_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.Drive_Addr_Bus_o_t2} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.Drive_Addr_Bus_o_t3} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.Drv_DB_0_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.Drv_DB_1_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.Drv_DB_2_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.Drv_DB_3_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.NS_0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.NS_0_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.NS_0_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.NS_1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.NS_1_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.NS_1_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.NS_2} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.NS_2_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.NS_2_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.S_0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.S_0_inv} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.S_1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.S_1_inv} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.S_2} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.S_2_inv} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.bank_hit_i} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.busy_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.busy_o_t0} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.busy_o_t1} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.busy_o_t2} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.clk} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.eb_clear_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.others_busy_i} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.others_busy_i_inv} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.req_hit_i} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.rst} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.set_eb_commit_o} {tb_DTE.uut0_DTE.g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm.st_req_o} }

gui_sg_move "$_session_group_176" -after "$_session_group_162" -pos 11 

set _session_group_177 tb_DTE_1
gui_sg_create "$_session_group_177"
set tb_DTE_1 "$_session_group_177"

gui_sg_addsignal -group "$_session_group_177" { {tb_DTE.$unit} tb_DTE.Clk_PERIOD tb_DTE.addres_bus_drv tb_DTE.address_bus tb_DTE.bestPick_bk_id_2_dte tb_DTE.uut0_DTE.dte_mem_2_icache_fsm_state tb_DTE.bestPick_req_2_dte tb_DTE.clk tb_DTE.data_bus tb_DTE.dte_2_dcache tb_DTE.dte_2_ddr5 tb_DTE.dte_2_dma tb_DTE.dte_2_icache tb_DTE.dte_2_mem tb_DTE.mem_2_dte tb_DTE.rst }
gui_set_radix -radix {decimal} -signals {V1:tb_DTE.Clk_PERIOD}
gui_set_radix -radix {twosComplement} -signals {V1:tb_DTE.Clk_PERIOD}

set _session_group_178 uut0_DTE
gui_sg_create "$_session_group_178"
set uut0_DTE "$_session_group_178"

gui_sg_addsignal -group "$_session_group_178" { {tb_DTE.uut0_DTE.$unit} tb_DTE.uut0_DTE.DTE_Busy tb_DTE.uut0_DTE.bestPick_bk_id_i tb_DTE.uut0_DTE.bestPick_i tb_DTE.uut0_DTE.clk tb_DTE.uut0_DTE.core_2_ddr5_driveAddrBus_fsmOut tb_DTE.uut0_DTE.core_2_ddr5_drvDB_fsmOut tb_DTE.uut0_DTE.core_2_ddr5_fsmout_busy tb_DTE.uut0_DTE.core_2_ddr5_reqServed_fsmOut tb_DTE.uut0_DTE.core_2_ddr5_req_hit tb_DTE.uut0_DTE.core_2_dma_driveAddrBus_fsmOut tb_DTE.uut0_DTE.core_2_dma_drvDB_fsmOut tb_DTE.uut0_DTE.core_2_dma_fsmout_busy tb_DTE.uut0_DTE.core_2_dma_reqServed_fsmOut tb_DTE.uut0_DTE.core_2_dma_req_hit tb_DTE.uut0_DTE.dcache_2_mem_bk_hit tb_DTE.uut0_DTE.dcache_2_mem_fsmout_busy tb_DTE.uut0_DTE.dcache_2_mem_fsmout_busy_per tb_DTE.uut0_DTE.dcache_2_mem_req_hit tb_DTE.uut0_DTE.dcache_2_mem_st_req_fsmOut tb_DTE.uut0_DTE.ddr5_2_core_driveAddrBus_fsmOut tb_DTE.uut0_DTE.ddr5_2_core_fsmout_busy tb_DTE.uut0_DTE.ddr5_2_core_reqServed_fsmOut tb_DTE.uut0_DTE.ddr5_2_core_req_hit tb_DTE.uut0_DTE.dma_2_mem_fsmout_busy tb_DTE.uut0_DTE.dma_2_mem_req_hit tb_DTE.uut0_DTE.dma_2_mem_st_req_fsmOut tb_DTE.uut0_DTE.dte_2_ddr5_o tb_DTE.uut0_DTE.dte_2_dma_o tb_DTE.uut0_DTE.dte_2_mem_o tb_DTE.uut0_DTE.dte_core_2_ddr5_fsm_state tb_DTE.uut0_DTE.dte_core_2_ddr5_fsm_state_bits tb_DTE.uut0_DTE.dte_core_2_dma_fsm_state tb_DTE.uut0_DTE.dte_core_2_dma_fsm_state_bits tb_DTE.uut0_DTE.dte_dcache_2_mem_fsm_state tb_DTE.uut0_DTE.dte_dcache_2_mem_fsm_state_bits tb_DTE.uut0_DTE.dte_ddr5_2_core_fsm_state tb_DTE.uut0_DTE.dte_ddr5_2_core_fsm_state_bits tb_DTE.uut0_DTE.dte_dma_2_mem_fsm_state tb_DTE.uut0_DTE.dte_dma_2_mem_fsm_state_bits tb_DTE.uut0_DTE.dte_mem_2_dcache_fsm_state tb_DTE.uut0_DTE.dte_mem_2_dcache_fsm_state_bits tb_DTE.uut0_DTE.dte_mem_2_icache_fsm_state_bits tb_DTE.uut0_DTE.dte_out_2_dcache_o tb_DTE.uut0_DTE.dte_out_2_icache_o tb_DTE.uut0_DTE.mem_2_dcache_bk_hit tb_DTE.uut0_DTE.mem_2_dcache_drv_db_fsmOut tb_DTE.uut0_DTE.mem_2_dcache_fsmout_busy tb_DTE.uut0_DTE.mem_2_dcache_fsmout_busy_per tb_DTE.uut0_DTE.mem_2_dcache_ld_req_fsmOut tb_DTE.uut0_DTE.mem_2_dcache_req_hit tb_DTE.uut0_DTE.mem_2_dte_i tb_DTE.uut0_DTE.mem_2_icache_drv_db_fsmOut tb_DTE.uut0_DTE.mem_2_icache_fsmout_busy tb_DTE.uut0_DTE.mem_2_icache_ld_req_fsmOut tb_DTE.uut0_DTE.mem_2_icache_req_hit tb_DTE.uut0_DTE.rst }

set _session_group_179 uut1_mem
gui_sg_create "$_session_group_179"
set uut1_mem "$_session_group_179"

gui_sg_addsignal -group "$_session_group_179" { {tb_DTE.uut1_mem.$unit} tb_DTE.uut1_mem.address_bus tb_DTE.uut1_mem.bank_out_2_controller tb_DTE.uut1_mem.clk tb_DTE.uut1_mem.controller_2_bank_Cmds tb_DTE.uut1_mem.dataToDrive tb_DTE.uut1_mem.data_bus tb_DTE.uut1_mem.drive_Data_Bus tb_DTE.uut1_mem.inFromDte tb_DTE.uut1_mem.mem_bus tb_DTE.uut1_mem.out2Dte tb_DTE.uut1_mem.out2Sch tb_DTE.uut1_mem.rst }

set _session_group_180 uut0_DTE_1
gui_sg_create "$_session_group_180"
set uut0_DTE_1 "$_session_group_180"

gui_sg_addsignal -group "$_session_group_180" { {tb_DTE.uut0_DTE.$unit} tb_DTE.uut0_DTE.DTE_Busy tb_DTE.uut0_DTE.bestPick_bk_id_i tb_DTE.uut0_DTE.bestPick_i tb_DTE.uut0_DTE.clk tb_DTE.uut0_DTE.core_2_ddr5_driveAddrBus_fsmOut tb_DTE.uut0_DTE.core_2_ddr5_drvDB_fsmOut tb_DTE.uut0_DTE.core_2_ddr5_fsmout_busy tb_DTE.uut0_DTE.core_2_ddr5_reqServed_fsmOut tb_DTE.uut0_DTE.core_2_ddr5_req_hit tb_DTE.uut0_DTE.core_2_dma_driveAddrBus_fsmOut tb_DTE.uut0_DTE.core_2_dma_drvDB_fsmOut tb_DTE.uut0_DTE.core_2_dma_fsmout_busy tb_DTE.uut0_DTE.core_2_dma_reqServed_fsmOut tb_DTE.uut0_DTE.core_2_dma_req_hit tb_DTE.uut0_DTE.dcache_2_mem_bk_hit tb_DTE.uut0_DTE.dcache_2_mem_fsmout_busy tb_DTE.uut0_DTE.dcache_2_mem_fsmout_busy_per tb_DTE.uut0_DTE.dcache_2_mem_req_hit tb_DTE.uut0_DTE.dcache_2_mem_st_req_fsmOut tb_DTE.uut0_DTE.ddr5_2_core_driveAddrBus_fsmOut tb_DTE.uut0_DTE.ddr5_2_core_fsmout_busy tb_DTE.uut0_DTE.ddr5_2_core_reqServed_fsmOut tb_DTE.uut0_DTE.ddr5_2_core_req_hit tb_DTE.uut0_DTE.dma_2_mem_fsmout_busy tb_DTE.uut0_DTE.dma_2_mem_req_hit tb_DTE.uut0_DTE.dma_2_mem_st_req_fsmOut tb_DTE.uut0_DTE.dte_2_ddr5_o tb_DTE.uut0_DTE.dte_2_dma_o tb_DTE.uut0_DTE.dte_2_mem_o tb_DTE.uut0_DTE.dte_core_2_ddr5_fsm_state tb_DTE.uut0_DTE.dte_core_2_ddr5_fsm_state_bits tb_DTE.uut0_DTE.dte_core_2_dma_fsm_state tb_DTE.uut0_DTE.dte_core_2_dma_fsm_state_bits tb_DTE.uut0_DTE.dte_dcache_2_mem_fsm_state tb_DTE.uut0_DTE.dte_dcache_2_mem_fsm_state_bits tb_DTE.uut0_DTE.dte_ddr5_2_core_fsm_state tb_DTE.uut0_DTE.dte_ddr5_2_core_fsm_state_bits tb_DTE.uut0_DTE.dte_dma_2_mem_fsm_state tb_DTE.uut0_DTE.dte_dma_2_mem_fsm_state_bits tb_DTE.uut0_DTE.dte_mem_2_dcache_fsm_state tb_DTE.uut0_DTE.dte_mem_2_dcache_fsm_state_bits tb_DTE.uut0_DTE.dte_mem_2_icache_fsm_state tb_DTE.uut0_DTE.dte_mem_2_icache_fsm_state_bits tb_DTE.uut0_DTE.dte_out_2_dcache_o tb_DTE.uut0_DTE.dte_out_2_icache_o tb_DTE.uut0_DTE.mem_2_dcache_bk_hit tb_DTE.uut0_DTE.mem_2_dcache_drv_db_fsmOut tb_DTE.uut0_DTE.mem_2_dcache_fsmout_busy tb_DTE.uut0_DTE.mem_2_dcache_fsmout_busy_per tb_DTE.uut0_DTE.mem_2_dcache_ld_req_fsmOut tb_DTE.uut0_DTE.mem_2_dcache_req_hit tb_DTE.uut0_DTE.mem_2_dte_i tb_DTE.uut0_DTE.mem_2_icache_drv_db_fsmOut tb_DTE.uut0_DTE.mem_2_icache_fsmout_busy tb_DTE.uut0_DTE.mem_2_icache_ld_req_fsmOut tb_DTE.uut0_DTE.mem_2_icache_req_hit tb_DTE.uut0_DTE.rst }

set _session_group_181 DTE_MEM_2_ICache
gui_sg_create "$_session_group_181"
set DTE_MEM_2_ICache "$_session_group_181"

gui_sg_addsignal -group "$_session_group_181" { {tb_DTE.uut0_DTE.DTE_MEM_2_ICache.$unit} tb_DTE.uut0_DTE.DTE_MEM_2_ICache.Drive_Addr_Bus_o tb_DTE.uut0_DTE.DTE_MEM_2_ICache.Drive_Addr_Bus_o_t0 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.Drive_Addr_Bus_o_t1 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.Drive_Addr_Bus_o_t2 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.Drive_Addr_Bus_o_t3 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.Drv_DB_0_o tb_DTE.uut0_DTE.DTE_MEM_2_ICache.Drv_DB_1_o tb_DTE.uut0_DTE.DTE_MEM_2_ICache.Drv_DB_2_o tb_DTE.uut0_DTE.DTE_MEM_2_ICache.Drv_DB_3_o tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_0 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_0_t0 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_0_t1 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_0_t2 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_1 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_1_t0 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_1_t1 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_2 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_2_t0 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_2_t1 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.NS_2_t2 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.S_0 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.S_0_inv tb_DTE.uut0_DTE.DTE_MEM_2_ICache.S_1 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.S_1_inv tb_DTE.uut0_DTE.DTE_MEM_2_ICache.S_2 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.S_2_inv tb_DTE.uut0_DTE.DTE_MEM_2_ICache.busy_o tb_DTE.uut0_DTE.DTE_MEM_2_ICache.busy_o_t0 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.busy_o_t1 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.busy_o_t2 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.clk tb_DTE.uut0_DTE.DTE_MEM_2_ICache.ld_req_o tb_DTE.uut0_DTE.DTE_MEM_2_ICache.mem_ready_i tb_DTE.uut0_DTE.DTE_MEM_2_ICache.mem_ready_i_inv tb_DTE.uut0_DTE.DTE_MEM_2_ICache.mem_valid_o tb_DTE.uut0_DTE.DTE_MEM_2_ICache.mem_valid_o_t0 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.mem_valid_o_t1 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.mem_valid_o_t2 tb_DTE.uut0_DTE.DTE_MEM_2_ICache.others_busy_i tb_DTE.uut0_DTE.DTE_MEM_2_ICache.others_busy_i_inv tb_DTE.uut0_DTE.DTE_MEM_2_ICache.req_hit_i tb_DTE.uut0_DTE.DTE_MEM_2_ICache.rst }

set _session_group_182 controller
gui_sg_create "$_session_group_182"
set controller "$_session_group_182"

gui_sg_addsignal -group "$_session_group_182" { {tb_DTE.uut1_mem.controller.$unit} tb_DTE.uut1_mem.controller.DTE_i tb_DTE.uut1_mem.controller.ToDTE_o tb_DTE.uut1_mem.controller.ToScheduler_o tb_DTE.uut1_mem.controller.address_bus tb_DTE.uut1_mem.controller.bankBits_InChip tb_DTE.uut1_mem.controller.bankGroupTable tb_DTE.uut1_mem.controller.bankGroup tb_DTE.uut1_mem.controller.bank_cmds_o tb_DTE.uut1_mem.controller.banks_i tb_DTE.uut1_mem.controller.chipNum tb_DTE.uut1_mem.controller.chipTable tb_DTE.uut1_mem.controller.clk tb_DTE.uut1_mem.controller.data_bus tb_DTE.uut1_mem.controller.fsm_outs tb_DTE.uut1_mem.controller.fsm_state tb_DTE.uut1_mem.controller.hit_into_fsm tb_DTE.uut1_mem.controller.mem_controller_state_bits tb_DTE.uut1_mem.controller.rowBitFromChipAddress tb_DTE.uut1_mem.controller.rst }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 155.7



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


# Hier 'Hier.1'
gui_show_window -window ${Hier.1}
gui_list_set_filter -id ${Hier.1} -list { {Package 1} {All 0} {Process 1} {VirtPowSwitch 0} {UnnamedProcess 1} {UDP 0} {Function 1} {Block 1} {SrsnAndSpaCell 0} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {LeafVhdCell 1} {$unit 1} {NamedBlock 1} {Task 1} {VlgPackage 1} {ClassDef 1} {VirtIsoCell 0} }
gui_list_set_filter -id ${Hier.1} -text {*}
gui_hier_list_init -id ${Hier.1}
gui_change_design -id ${Hier.1} -design V1
catch {gui_list_expand -id ${Hier.1} tb_DTE}
catch {gui_list_expand -id ${Hier.1} tb_DTE.uut1_mem}
catch {gui_list_select -id ${Hier.1} {tb_DTE.uut1_mem.controller}}
gui_view_scroll -id ${Hier.1} -vertical -set 1174
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {tb_DTE.uut1_mem.controller}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 1174
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active tb_DTE.uut0_DTE /home/ecelrc/students/je28497/uarch/design/EverythingEverywhereAllAtOnce/rtl/BusArbitration/DTE.sv
gui_view_scroll -id ${Source.1} -vertical -set 1350
gui_src_set_reusable -id ${Source.1}

# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 121.697 207.01
gui_list_add_group -id ${Wave.1} -after {New Group} {Group1}
gui_list_add_group -id ${Wave.1}  -after Group1 {{Group1|g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm}}
gui_list_add_group -id ${Wave.1} -after {{Group1|g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm}} {{Group1|g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm}}
gui_list_add_group -id ${Wave.1} -after {{Group1|g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm}} {{Group1|g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm}}
gui_list_add_group -id ${Wave.1} -after {{Group1|g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm}} {{Group1|g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm}}
gui_list_add_group -id ${Wave.1} -after {{Group1|g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm}} {{Group1|g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm}}
gui_list_add_group -id ${Wave.1} -after {{Group1|g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm}} {Group1|dma_2_mem_fsm}
gui_list_add_group -id ${Wave.1} -after Group1|dma_2_mem_fsm {Group1|ddr5_2_core_fsm}
gui_list_add_group -id ${Wave.1} -after Group1|ddr5_2_core_fsm {Group1|core_2_dma_fsm}
gui_list_add_group -id ${Wave.1} -after Group1|core_2_dma_fsm {Group1|core_2_ddr5_fsm}
gui_list_add_group -id ${Wave.1} -after Group1|core_2_ddr5_fsm {Group1|DTE_MEM_2_ICache}
gui_list_add_group -id ${Wave.1} -after Group1|DTE_MEM_2_ICache {Group1|uut0_DTE}
gui_list_add_group -id ${Wave.1} -after Group1|uut0_DTE {{Group1|g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm}}
gui_list_add_group -id ${Wave.1} -after {{Group1|g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm}} {{Group1|g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm}}
gui_list_add_group -id ${Wave.1} -after {{Group1|g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm}} {{Group1|g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm}}
gui_list_add_group -id ${Wave.1} -after {New Group} {tb_DTE_1}
gui_list_add_group -id ${Wave.1} -after {New Group} {uut0_DTE}
gui_list_add_group -id ${Wave.1} -after {New Group} {uut1_mem}
gui_list_add_group -id ${Wave.1} -after {New Group} {uut0_DTE_1}
gui_list_add_group -id ${Wave.1} -after {New Group} {DTE_MEM_2_ICache}
gui_list_add_group -id ${Wave.1} -after {New Group} {controller}
gui_list_collapse -id ${Wave.1} Group1
gui_list_collapse -id ${Wave.1} {Group1|g_mem_2_dcache_bank_fsms[3].mem_2_dcache_fsm}
gui_list_collapse -id ${Wave.1} {Group1|g_mem_2_dcache_bank_fsms[2].mem_2_dcache_fsm}
gui_list_collapse -id ${Wave.1} {Group1|g_mem_2_dcache_bank_fsms[1].mem_2_dcache_fsm}
gui_list_collapse -id ${Wave.1} {Group1|g_mem_2_dcache_bank_fsms[0].mem_2_dcache_fsm}
gui_list_collapse -id ${Wave.1} {Group1|g_dcache_2_mem_bank_fsms[3].dcache_2_mem_fsm}
gui_list_collapse -id ${Wave.1} Group1|dma_2_mem_fsm
gui_list_collapse -id ${Wave.1} Group1|ddr5_2_core_fsm
gui_list_collapse -id ${Wave.1} Group1|core_2_dma_fsm
gui_list_collapse -id ${Wave.1} Group1|core_2_ddr5_fsm
gui_list_collapse -id ${Wave.1} Group1|DTE_MEM_2_ICache
gui_list_collapse -id ${Wave.1} Group1|uut0_DTE
gui_list_collapse -id ${Wave.1} {Group1|g_dcache_2_mem_bank_fsms[1].dcache_2_mem_fsm}
gui_list_collapse -id ${Wave.1} {Group1|g_dcache_2_mem_bank_fsms[2].dcache_2_mem_fsm}
gui_list_collapse -id ${Wave.1} {Group1|g_dcache_2_mem_bank_fsms[0].dcache_2_mem_fsm}
gui_list_collapse -id ${Wave.1} tb_DTE_1
gui_list_collapse -id ${Wave.1} uut0_DTE
gui_list_collapse -id ${Wave.1} uut1_mem
gui_list_collapse -id ${Wave.1} uut0_DTE_1
gui_list_collapse -id ${Wave.1} DTE_MEM_2_ICache
gui_list_expand -id ${Wave.1} tb_DTE.uut1_mem.controller.DTE_i
gui_list_select -id ${Wave.1} {tb_DTE.uut1_mem.controller.DTE_i.ld_req }
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
gui_list_set_insertion_bar  -id ${Wave.1} -group controller  -position in

gui_marker_move -id ${Wave.1} {C1} 155.7
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

