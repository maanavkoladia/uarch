# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Sun Mar 29 17:40:46 2026
# Designs open: 1
#   V1: vcdplus.vpd
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Schematic.1: tb_ICache.u_icache
#   Schematic.2: tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell
#   Source.1: tb_ICache
#   Wave.1: 800 signals
#   Group count = 40
#   Group u_icache signal count = 29
#   Group icache_TagStore_unit signal count = 24
#   Group icache_dataStore_unit signal count = 23
#   Group i_vcache_unit signal count = 32
#   Group icache_contrller_fsm signal count = 44
#   Group tag_store_ramCell_Lower signal count = 20
#   Group tag_store_ramCell_Upper signal count = 20
#   Group datstore_memcells signal count = 32
# End_DVE_Session_Save_Info

# DVE version: T-2022.06_Full64
# DVE build date: May 31 2022 20:53:03


#<Session mode="Full" path="/home/ecelrc/students/mak4738/uarch/design_project/design/EverythingEverywhereAllAtOnce/tests/ICache/session.vcdplus.vpd.tcl" type="Debug">

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
gui_show_window -window ${TopLevel.1} -show_state maximized -rect {{0 51} {1279 719}}

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
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 341]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 341
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 340} {height 382} {dock_state left} {dock_on_new_line true} {child_hier_colhier 232} {child_hier_coltype 100} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 244]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 244
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 747
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 243} {height 382} {dock_state left} {dock_on_new_line true} {child_data_colvariable 140} {child_data_colvalue 100} {child_data_coltype 40} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 161]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value -1
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 161
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 295} {height 179} {dock_state bottom} {dock_on_new_line true}}
set DriverLoad.1 [gui_create_window -type DriverLoad -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line false -dock_extent 180]
gui_set_window_pref_key -window ${DriverLoad.1} -key dock_width -value_type integer -value 150
gui_set_window_pref_key -window ${DriverLoad.1} -key dock_height -value_type integer -value 180
gui_set_window_pref_key -window ${DriverLoad.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DriverLoad.1} {{left 0} {top 0} {width 983} {height 179} {dock_state bottom} {dock_on_new_line false}}
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
gui_use_schematics
set Schematic.1 [gui_create_window -type {Schematic}  -parent ${TopLevel.1} -defer_create_taskbar_icon]
set setting [::Misc::Setting::create -array DveSchematicSettings]
Misc::init_window $setting ${Schematic.1}
::Misc::exec_method -window ${Schematic.1} -method captionCmd
gui_add_icon_to_taskbar -window ${Schematic.1}
gui_show_window -window ${Schematic.1} -show_state maximized
gui_update_layout -id ${Schematic.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false}}
set Schematic.2 [gui_create_window -type {Schematic}  -parent ${TopLevel.1} -defer_create_taskbar_icon]
set setting [::Misc::Setting::create -array DveSchematicSettings]
Misc::init_window $setting ${Schematic.2}
::Misc::exec_method -window ${Schematic.2} -method captionCmd
gui_add_icon_to_taskbar -window ${Schematic.2}
gui_show_window -window ${Schematic.2} -show_state maximized
gui_update_layout -id ${Schematic.2} {{show_state maximized} {dock_state undocked} {dock_on_new_line false}}

# End MDI window settings


# Create and position top-level window: TopLevel.2

if {![gui_exist_window -window TopLevel.2]} {
    set TopLevel.2 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.2 TopLevel.2
}
gui_show_window -window ${TopLevel.2} -show_state maximized -rect {{0 51} {1279 719}}

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
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 343} {child_wave_right 931} {child_wave_colname 181} {child_wave_colvalue 158} {child_wave_col1 0} {child_wave_col2 1}}

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
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_contrller_fsm}
gui_load_child_values {tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.i_vcache_unit}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell}
gui_load_child_values {tb_ICache.u_icache.icache_TagStore_unit}


set _session_group_289 u_icache
gui_sg_create "$_session_group_289"
set u_icache "$_session_group_289"

gui_sg_addsignal -group "$_session_group_289" { tb_ICache.u_icache.clk tb_ICache.u_icache.rst tb_ICache.u_icache.dataBus tb_ICache.u_icache.addrBus tb_ICache.u_icache.inFromCore_i tb_ICache.u_icache.inFromDte_i tb_ICache.u_icache.fsmOuts tb_ICache.u_icache.fsmOuts.busy tb_ICache.u_icache.controller_fsmState tb_ICache.u_icache.icache_dataLines tb_ICache.u_icache.icache_tag tb_ICache.u_icache.icache_tag_V tb_ICache.u_icache.icache_hit tb_ICache.u_icache.i_vcache_hit tb_ICache.u_icache.icache_miss tb_ICache.u_icache.i_vcache_miss tb_ICache.u_icache.i_vcache_busy tb_ICache.u_icache.i_vcache_swapBuf_V_Clr tb_ICache.u_icache.i_vcache_dataLines tb_ICache.u_icache.saved_pAddr tb_ICache.u_icache.saved_vAddr tb_ICache.u_icache.curr_p_addr_to_use tb_ICache.u_icache.curr_v_addr_to_use tb_ICache.u_icache.addrBus_drv tb_ICache.u_icache.out2Core_o tb_ICache.u_icache.out2Sch_o tb_ICache.u_icache.icache_swapbuf tb_ICache.u_icache.i_vcache_swapBuf {tb_ICache.u_icache.$unit} }

set _session_group_290 icache_TagStore_unit
gui_sg_create "$_session_group_290"
set icache_TagStore_unit "$_session_group_290"

gui_sg_addsignal -group "$_session_group_290" { tb_ICache.u_icache.icache_TagStore_unit.rst tb_ICache.u_icache.icache_TagStore_unit.clk tb_ICache.u_icache.icache_TagStore_unit.en tb_ICache.u_icache.icache_TagStore_unit.v_addr_i tb_ICache.u_icache.icache_TagStore_unit.p_addr_i tb_ICache.u_icache.icache_TagStore_unit.ld_From_I_VC_Swap tb_ICache.u_icache.icache_TagStore_unit.LD_IC_SWAP_BUF tb_ICache.u_icache.icache_TagStore_unit.fill3_i tb_ICache.u_icache.icache_TagStore_unit.busy tb_ICache.u_icache.icache_TagStore_unit.currTag_o tb_ICache.u_icache.icache_TagStore_unit.currLine_V tb_ICache.u_icache.icache_TagStore_unit.I_VC_SwapBuf_i tb_ICache.u_icache.icache_TagStore_unit.validStore tb_ICache.u_icache.icache_TagStore_unit.tagCellOutSel tb_ICache.u_icache.icache_TagStore_unit.ADDRESS_2_TagStore tb_ICache.u_icache.icache_TagStore_unit.WR_2_TagStore_clk tb_ICache.u_icache.icache_TagStore_unit.WR_2_TagStore_Delay tb_ICache.u_icache.icache_TagStore_unit.WR_2_TagStore_actual tb_ICache.u_icache.icache_TagStore_unit.DIN_2_TagStore tb_ICache.u_icache.icache_TagStore_unit.OE_2_TagStore tb_ICache.u_icache.icache_TagStore_unit.DOUT_2_TagStore tb_ICache.u_icache.icache_TagStore_unit.DOUT_2_TagStore_extended tb_ICache.u_icache.icache_TagStore_unit.p_addr_i_tag tb_ICache.u_icache.icache_TagStore_unit.v_addr_i_index }

set _session_group_291 icache_dataStore_unit
gui_sg_create "$_session_group_291"
set icache_dataStore_unit "$_session_group_291"

gui_sg_addsignal -group "$_session_group_291" { tb_ICache.u_icache.icache_dataStore_unit.rst tb_ICache.u_icache.icache_dataStore_unit.en tb_ICache.u_icache.icache_dataStore_unit.busy tb_ICache.u_icache.icache_dataStore_unit.ld_From_I_VC_Swap tb_ICache.u_icache.icache_dataStore_unit.LD_IC_SWAP_BUF tb_ICache.u_icache.icache_dataStore_unit.I_VC_SwapBuf_i tb_ICache.u_icache.icache_dataStore_unit.ADDRESS_2_DataStore tb_ICache.u_icache.icache_dataStore_unit.WR_2_DataStore_actual tb_ICache.u_icache.icache_dataStore_unit.WR_2_DataStore_Delay tb_ICache.u_icache.icache_dataStore_unit.WR_2_DataStore_clk tb_ICache.u_icache.icache_dataStore_unit.DIN_2_DataStore tb_ICache.u_icache.icache_dataStore_unit.OE_2_DataStore tb_ICache.u_icache.icache_dataStore_unit.DOUT_2_DataStore tb_ICache.u_icache.icache_dataStore_unit.currLine_o tb_ICache.u_icache.icache_dataStore_unit.dataBus tb_ICache.u_icache.icache_dataStore_unit.dataLineOutSel tb_ICache.u_icache.icache_dataStore_unit.fill0_i tb_ICache.u_icache.icache_dataStore_unit.fill1_i tb_ICache.u_icache.icache_dataStore_unit.fill2_i tb_ICache.u_icache.icache_dataStore_unit.fill3_i tb_ICache.u_icache.icache_dataStore_unit.p_addr_i tb_ICache.u_icache.icache_dataStore_unit.v_addr_i tb_ICache.u_icache.icache_dataStore_unit.v_addr_i_index }

set _session_group_292 i_vcache_unit
gui_sg_create "$_session_group_292"
set i_vcache_unit "$_session_group_292"

gui_sg_addsignal -group "$_session_group_292" { tb_ICache.u_icache.i_vcache_unit.clk tb_ICache.u_icache.i_vcache_unit.rst tb_ICache.u_icache.i_vcache_unit.controller_fsmState tb_ICache.u_icache.i_vcache_unit.req_V_i tb_ICache.u_icache.i_vcache_unit.p_addr_i tb_ICache.u_icache.i_vcache_unit.hit_o tb_ICache.u_icache.i_vcache_unit.miss_o tb_ICache.u_icache.i_vcache_unit.busy_o tb_ICache.u_icache.i_vcache_unit.IC_SwapBuf_V_clr_o tb_ICache.u_icache.i_vcache_unit.dataLineOut_o tb_ICache.u_icache.i_vcache_unit.LD_I_VC_SWAP_BUF tb_ICache.u_icache.i_vcache_unit.RD_IC_SWAP_BUF tb_ICache.u_icache.i_vcache_unit.hit_idx tb_ICache.u_icache.i_vcache_unit.currTag tb_ICache.u_icache.i_vcache_unit.currTagHit tb_ICache.u_icache.i_vcache_unit.currTagHit tb_ICache.u_icache.i_vcache_unit.currDataLine tb_ICache.u_icache.i_vcache_unit.hit tb_ICache.u_icache.i_vcache_unit.miss tb_ICache.u_icache.i_vcache_unit.updateLRU tb_ICache.u_icache.i_vcache_unit.currLRU_IDX tb_ICache.u_icache.i_vcache_unit.NUM_LINES tb_ICache.u_icache.i_vcache_unit.NUM_LRU_BITS tb_ICache.u_icache.i_vcache_unit.LRU_ROOT tb_ICache.u_icache.i_vcache_unit.LRU_LEFT_LEAF tb_ICache.u_icache.i_vcache_unit.LRU_RIGHT_LEAF tb_ICache.u_icache.i_vcache_unit.IC_SwapBuf_i tb_ICache.u_icache.i_vcache_unit.I_VC_SwapBuf_o tb_ICache.u_icache.i_vcache_unit.tagStore tb_ICache.u_icache.i_vcache_unit.dataStore tb_ICache.u_icache.i_vcache_unit.I_VC_swapBuf {tb_ICache.u_icache.i_vcache_unit.$unit} }
gui_set_radix -radix {decimal} -signals {V1:tb_ICache.u_icache.i_vcache_unit.NUM_LINES}
gui_set_radix -radix {twosComplement} -signals {V1:tb_ICache.u_icache.i_vcache_unit.NUM_LINES}
gui_set_radix -radix {decimal} -signals {V1:tb_ICache.u_icache.i_vcache_unit.NUM_LRU_BITS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_ICache.u_icache.i_vcache_unit.NUM_LRU_BITS}
gui_set_radix -radix {decimal} -signals {V1:tb_ICache.u_icache.i_vcache_unit.LRU_ROOT}
gui_set_radix -radix {twosComplement} -signals {V1:tb_ICache.u_icache.i_vcache_unit.LRU_ROOT}
gui_set_radix -radix {decimal} -signals {V1:tb_ICache.u_icache.i_vcache_unit.LRU_LEFT_LEAF}
gui_set_radix -radix {twosComplement} -signals {V1:tb_ICache.u_icache.i_vcache_unit.LRU_LEFT_LEAF}
gui_set_radix -radix {decimal} -signals {V1:tb_ICache.u_icache.i_vcache_unit.LRU_RIGHT_LEAF}
gui_set_radix -radix {twosComplement} -signals {V1:tb_ICache.u_icache.i_vcache_unit.LRU_RIGHT_LEAF}

set _session_group_293 icache_contrller_fsm
gui_sg_create "$_session_group_293"
set icache_contrller_fsm "$_session_group_293"

gui_sg_addsignal -group "$_session_group_293" { tb_ICache.u_icache.icache_contrller_fsm.S_0_inv tb_ICache.u_icache.icache_contrller_fsm.I_VC_Miss_i_inv tb_ICache.u_icache.icache_contrller_fsm.rst tb_ICache.u_icache.icache_contrller_fsm.S_1_inv tb_ICache.u_icache.icache_contrller_fsm.IC_miss_i tb_ICache.u_icache.icache_contrller_fsm.busy_o tb_ICache.u_icache.icache_contrller_fsm.S_2_inv tb_ICache.u_icache.icache_contrller_fsm.clk tb_ICache.u_icache.icache_contrller_fsm.Fill0EN_o tb_ICache.u_icache.icache_contrller_fsm.NS_0_t0 tb_ICache.u_icache.icache_contrller_fsm.NS_0_t1 tb_ICache.u_icache.icache_contrller_fsm.NS_0_t2 tb_ICache.u_icache.icache_contrller_fsm.Fill1EN_o tb_ICache.u_icache.icache_contrller_fsm.UseSavedAddr_o_t0 tb_ICache.u_icache.icache_contrller_fsm.UseSavedAddr_o_t1 tb_ICache.u_icache.icache_contrller_fsm.UseSavedAddr_o_t2 tb_ICache.u_icache.icache_contrller_fsm.I_VC_Miss_i tb_ICache.u_icache.icache_contrller_fsm.mem_valid_i tb_ICache.u_icache.icache_contrller_fsm.Fill2EN_o tb_ICache.u_icache.icache_contrller_fsm.mem_valid_i_inv tb_ICache.u_icache.icache_contrller_fsm.Fill3EN_o tb_ICache.u_icache.icache_contrller_fsm.NS_1_t0 tb_ICache.u_icache.icache_contrller_fsm.NS_1_t1 tb_ICache.u_icache.icache_contrller_fsm.NS_1_t2 tb_ICache.u_icache.icache_contrller_fsm.NS_0 tb_ICache.u_icache.icache_contrller_fsm.NS_1 tb_ICache.u_icache.icache_contrller_fsm.NS_2 tb_ICache.u_icache.icache_contrller_fsm.en_i tb_ICache.u_icache.icache_contrller_fsm.RD_I_VC_SWAP_BUF_o tb_ICache.u_icache.icache_contrller_fsm.UseSavedAddr_o tb_ICache.u_icache.icache_contrller_fsm.S_0 tb_ICache.u_icache.icache_contrller_fsm.S_1 tb_ICache.u_icache.icache_contrller_fsm.S_2 tb_ICache.u_icache.icache_contrller_fsm.busy_o_t0 tb_ICache.u_icache.icache_contrller_fsm.saveAddress_o tb_ICache.u_icache.icache_contrller_fsm.busy_o_t1 tb_ICache.u_icache.icache_contrller_fsm.MakeReq_o tb_ICache.u_icache.icache_contrller_fsm.busy_o_t2 {tb_ICache.u_icache.icache_contrller_fsm.$unit} tb_ICache.u_icache.icache_contrller_fsm.LD_IC_SWAP_BUF_o tb_ICache.u_icache.icache_contrller_fsm.NS_2_t0 tb_ICache.u_icache.icache_contrller_fsm.NS_2_t1 tb_ICache.u_icache.icache_contrller_fsm.NS_2_t2 tb_ICache.u_icache.icache_contrller_fsm.NS_2_t3 }

set _session_group_294 tag_store_ramCell_Lower
gui_sg_create "$_session_group_294"
set tag_store_ramCell_Lower "$_session_group_294"

gui_sg_addsignal -group "$_session_group_294" { {tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.$unit} tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.A tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.DIN tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.WR tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.OE tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.DOUT tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.ramout tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.lastread_addr tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.lastwrite_addr tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.wr_cycle_check tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.read_cycle_check tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.addr_hold_flag tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.addr_setup_flag tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.data_hold_flag tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.data_setup_flag tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.din_changed tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.a_changed tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.output_enable tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.addr_unstable_memory tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.mem }

set _session_group_295 tag_store_ramCell_Upper
gui_sg_create "$_session_group_295"
set tag_store_ramCell_Upper "$_session_group_295"

gui_sg_addsignal -group "$_session_group_295" { {tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.$unit} tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.A tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.DIN tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.WR tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.OE tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.DOUT tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.ramout tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.lastread_addr tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.lastwrite_addr tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.wr_cycle_check tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.read_cycle_check tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.addr_hold_flag tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.addr_setup_flag tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.data_hold_flag tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.data_setup_flag tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.din_changed tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.a_changed tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.output_enable tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.addr_unstable_memory tb_ICache.u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.mem }

set _session_group_296 datstore_memcells
gui_sg_create "$_session_group_296"
set datstore_memcells "$_session_group_296"

gui_sg_addsignal -group "$_session_group_296" { }

set _session_group_297 $_session_group_296|
append _session_group_297 {g_mem_layer[0].g_memCells[0].dataStore_memCell}
gui_sg_create "$_session_group_297"
set {datstore_memcells|g_mem_layer[0].g_memCells[0].dataStore_memCell} "$_session_group_297"

gui_sg_addsignal -group "$_session_group_297" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.mem} }

gui_sg_move "$_session_group_297" -after "$_session_group_296" -pos 1 

set _session_group_298 $_session_group_296|
append _session_group_298 {g_mem_layer[0].g_memCells[1].dataStore_memCell}
gui_sg_create "$_session_group_298"
set {datstore_memcells|g_mem_layer[0].g_memCells[1].dataStore_memCell} "$_session_group_298"

gui_sg_addsignal -group "$_session_group_298" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.mem} }

gui_sg_move "$_session_group_298" -after "$_session_group_296" -pos 3 

set _session_group_299 $_session_group_296|
append _session_group_299 {g_mem_layer[0].g_memCells[2].dataStore_memCell}
gui_sg_create "$_session_group_299"
set {datstore_memcells|g_mem_layer[0].g_memCells[2].dataStore_memCell} "$_session_group_299"

gui_sg_addsignal -group "$_session_group_299" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.mem} }

gui_sg_move "$_session_group_299" -after "$_session_group_296" -pos 6 

set _session_group_300 $_session_group_296|
append _session_group_300 {g_mem_layer[0].g_memCells[3].dataStore_memCell}
gui_sg_create "$_session_group_300"
set {datstore_memcells|g_mem_layer[0].g_memCells[3].dataStore_memCell} "$_session_group_300"

gui_sg_addsignal -group "$_session_group_300" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.mem} }

gui_sg_move "$_session_group_300" -after "$_session_group_296" -pos 9 

set _session_group_301 $_session_group_296|
append _session_group_301 {g_mem_layer[0].g_memCells[4].dataStore_memCell}
gui_sg_create "$_session_group_301"
set {datstore_memcells|g_mem_layer[0].g_memCells[4].dataStore_memCell} "$_session_group_301"

gui_sg_addsignal -group "$_session_group_301" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.mem} }

gui_sg_move "$_session_group_301" -after "$_session_group_296" -pos 11 

set _session_group_302 $_session_group_296|
append _session_group_302 {g_mem_layer[0].g_memCells[5].dataStore_memCell}
gui_sg_create "$_session_group_302"
set {datstore_memcells|g_mem_layer[0].g_memCells[5].dataStore_memCell} "$_session_group_302"

gui_sg_addsignal -group "$_session_group_302" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.mem} }

gui_sg_move "$_session_group_302" -after "$_session_group_296" -pos 14 

set _session_group_303 $_session_group_296|
append _session_group_303 {g_mem_layer[0].g_memCells[6].dataStore_memCell}
gui_sg_create "$_session_group_303"
set {datstore_memcells|g_mem_layer[0].g_memCells[6].dataStore_memCell} "$_session_group_303"

gui_sg_addsignal -group "$_session_group_303" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.mem} }

gui_sg_move "$_session_group_303" -after "$_session_group_296" -pos 17 

set _session_group_304 $_session_group_296|
append _session_group_304 {g_mem_layer[0].g_memCells[7].dataStore_memCell}
gui_sg_create "$_session_group_304"
set {datstore_memcells|g_mem_layer[0].g_memCells[7].dataStore_memCell} "$_session_group_304"

gui_sg_addsignal -group "$_session_group_304" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.mem} }

gui_sg_move "$_session_group_304" -after "$_session_group_296" -pos 19 

set _session_group_305 $_session_group_296|
append _session_group_305 {g_mem_layer[0].g_memCells[8].dataStore_memCell}
gui_sg_create "$_session_group_305"
set {datstore_memcells|g_mem_layer[0].g_memCells[8].dataStore_memCell} "$_session_group_305"

gui_sg_addsignal -group "$_session_group_305" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.mem} }

gui_sg_move "$_session_group_305" -after "$_session_group_296" -pos 22 

set _session_group_306 $_session_group_296|
append _session_group_306 {g_mem_layer[0].g_memCells[9].dataStore_memCell}
gui_sg_create "$_session_group_306"
set {datstore_memcells|g_mem_layer[0].g_memCells[9].dataStore_memCell} "$_session_group_306"

gui_sg_addsignal -group "$_session_group_306" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.mem} }

gui_sg_move "$_session_group_306" -after "$_session_group_296" -pos 25 

set _session_group_307 $_session_group_296|
append _session_group_307 {g_mem_layer[0].g_memCells[10].dataStore_memCell}
gui_sg_create "$_session_group_307"
set {datstore_memcells|g_mem_layer[0].g_memCells[10].dataStore_memCell} "$_session_group_307"

gui_sg_addsignal -group "$_session_group_307" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.mem} }

gui_sg_move "$_session_group_307" -after "$_session_group_296" -pos 27 

set _session_group_308 $_session_group_296|
append _session_group_308 {g_mem_layer[0].g_memCells[11].dataStore_memCell}
gui_sg_create "$_session_group_308"
set {datstore_memcells|g_mem_layer[0].g_memCells[11].dataStore_memCell} "$_session_group_308"

gui_sg_addsignal -group "$_session_group_308" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.mem} }

gui_sg_move "$_session_group_308" -after "$_session_group_296" -pos 30 

set _session_group_309 $_session_group_296|
append _session_group_309 {g_mem_layer[0].g_memCells[12].dataStore_memCell}
gui_sg_create "$_session_group_309"
set {datstore_memcells|g_mem_layer[0].g_memCells[12].dataStore_memCell} "$_session_group_309"

gui_sg_addsignal -group "$_session_group_309" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.mem} }

gui_sg_move "$_session_group_309" -after "$_session_group_296" -pos 31 

set _session_group_310 $_session_group_296|
append _session_group_310 {g_mem_layer[0].g_memCells[13].dataStore_memCell}
gui_sg_create "$_session_group_310"
set {datstore_memcells|g_mem_layer[0].g_memCells[13].dataStore_memCell} "$_session_group_310"

gui_sg_addsignal -group "$_session_group_310" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.mem} }

gui_sg_move "$_session_group_310" -after "$_session_group_296" -pos 29 

set _session_group_311 $_session_group_296|
append _session_group_311 {g_mem_layer[0].g_memCells[14].dataStore_memCell}
gui_sg_create "$_session_group_311"
set {datstore_memcells|g_mem_layer[0].g_memCells[14].dataStore_memCell} "$_session_group_311"

gui_sg_addsignal -group "$_session_group_311" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.mem} }

gui_sg_move "$_session_group_311" -after "$_session_group_296" -pos 28 

set _session_group_312 $_session_group_296|
append _session_group_312 {g_mem_layer[0].g_memCells[15].dataStore_memCell}
gui_sg_create "$_session_group_312"
set {datstore_memcells|g_mem_layer[0].g_memCells[15].dataStore_memCell} "$_session_group_312"

gui_sg_addsignal -group "$_session_group_312" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.mem} }

gui_sg_move "$_session_group_312" -after "$_session_group_296" -pos 26 

set _session_group_313 $_session_group_296|
append _session_group_313 {g_mem_layer[1].g_memCells[0].dataStore_memCell}
gui_sg_create "$_session_group_313"
set {datstore_memcells|g_mem_layer[1].g_memCells[0].dataStore_memCell} "$_session_group_313"

gui_sg_addsignal -group "$_session_group_313" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.mem} }

gui_sg_move "$_session_group_313" -after "$_session_group_296" -pos 24 

set _session_group_314 $_session_group_296|
append _session_group_314 {g_mem_layer[1].g_memCells[1].dataStore_memCell}
gui_sg_create "$_session_group_314"
set {datstore_memcells|g_mem_layer[1].g_memCells[1].dataStore_memCell} "$_session_group_314"

gui_sg_addsignal -group "$_session_group_314" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.mem} }

gui_sg_move "$_session_group_314" -after "$_session_group_296" -pos 23 

set _session_group_315 $_session_group_296|
append _session_group_315 {g_mem_layer[1].g_memCells[2].dataStore_memCell}
gui_sg_create "$_session_group_315"
set {datstore_memcells|g_mem_layer[1].g_memCells[2].dataStore_memCell} "$_session_group_315"

gui_sg_addsignal -group "$_session_group_315" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.mem} }

gui_sg_move "$_session_group_315" -after "$_session_group_296" -pos 21 

set _session_group_316 $_session_group_296|
append _session_group_316 {g_mem_layer[1].g_memCells[3].dataStore_memCell}
gui_sg_create "$_session_group_316"
set {datstore_memcells|g_mem_layer[1].g_memCells[3].dataStore_memCell} "$_session_group_316"

gui_sg_addsignal -group "$_session_group_316" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.mem} }

gui_sg_move "$_session_group_316" -after "$_session_group_296" -pos 20 

set _session_group_317 $_session_group_296|
append _session_group_317 {g_mem_layer[1].g_memCells[4].dataStore_memCell}
gui_sg_create "$_session_group_317"
set {datstore_memcells|g_mem_layer[1].g_memCells[4].dataStore_memCell} "$_session_group_317"

gui_sg_addsignal -group "$_session_group_317" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.mem} }

gui_sg_move "$_session_group_317" -after "$_session_group_296" -pos 18 

set _session_group_318 $_session_group_296|
append _session_group_318 {g_mem_layer[1].g_memCells[5].dataStore_memCell}
gui_sg_create "$_session_group_318"
set {datstore_memcells|g_mem_layer[1].g_memCells[5].dataStore_memCell} "$_session_group_318"

gui_sg_addsignal -group "$_session_group_318" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.mem} }

gui_sg_move "$_session_group_318" -after "$_session_group_296" -pos 16 

set _session_group_319 $_session_group_296|
append _session_group_319 {g_mem_layer[1].g_memCells[6].dataStore_memCell}
gui_sg_create "$_session_group_319"
set {datstore_memcells|g_mem_layer[1].g_memCells[6].dataStore_memCell} "$_session_group_319"

gui_sg_addsignal -group "$_session_group_319" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.mem} }

gui_sg_move "$_session_group_319" -after "$_session_group_296" -pos 15 

set _session_group_320 $_session_group_296|
append _session_group_320 {g_mem_layer[1].g_memCells[7].dataStore_memCell}
gui_sg_create "$_session_group_320"
set {datstore_memcells|g_mem_layer[1].g_memCells[7].dataStore_memCell} "$_session_group_320"

gui_sg_addsignal -group "$_session_group_320" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.mem} }

gui_sg_move "$_session_group_320" -after "$_session_group_296" -pos 13 

set _session_group_321 $_session_group_296|
append _session_group_321 {g_mem_layer[1].g_memCells[8].dataStore_memCell}
gui_sg_create "$_session_group_321"
set {datstore_memcells|g_mem_layer[1].g_memCells[8].dataStore_memCell} "$_session_group_321"

gui_sg_addsignal -group "$_session_group_321" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.mem} }

gui_sg_move "$_session_group_321" -after "$_session_group_296" -pos 12 

set _session_group_322 $_session_group_296|
append _session_group_322 {g_mem_layer[1].g_memCells[9].dataStore_memCell}
gui_sg_create "$_session_group_322"
set {datstore_memcells|g_mem_layer[1].g_memCells[9].dataStore_memCell} "$_session_group_322"

gui_sg_addsignal -group "$_session_group_322" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.mem} }

gui_sg_move "$_session_group_322" -after "$_session_group_296" -pos 10 

set _session_group_323 $_session_group_296|
append _session_group_323 {g_mem_layer[1].g_memCells[10].dataStore_memCell}
gui_sg_create "$_session_group_323"
set {datstore_memcells|g_mem_layer[1].g_memCells[10].dataStore_memCell} "$_session_group_323"

gui_sg_addsignal -group "$_session_group_323" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.mem} }

gui_sg_move "$_session_group_323" -after "$_session_group_296" -pos 8 

set _session_group_324 $_session_group_296|
append _session_group_324 {g_mem_layer[1].g_memCells[11].dataStore_memCell}
gui_sg_create "$_session_group_324"
set {datstore_memcells|g_mem_layer[1].g_memCells[11].dataStore_memCell} "$_session_group_324"

gui_sg_addsignal -group "$_session_group_324" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.mem} }

gui_sg_move "$_session_group_324" -after "$_session_group_296" -pos 7 

set _session_group_325 $_session_group_296|
append _session_group_325 {g_mem_layer[1].g_memCells[12].dataStore_memCell}
gui_sg_create "$_session_group_325"
set {datstore_memcells|g_mem_layer[1].g_memCells[12].dataStore_memCell} "$_session_group_325"

gui_sg_addsignal -group "$_session_group_325" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.mem} }

gui_sg_move "$_session_group_325" -after "$_session_group_296" -pos 5 

set _session_group_326 $_session_group_296|
append _session_group_326 {g_mem_layer[1].g_memCells[13].dataStore_memCell}
gui_sg_create "$_session_group_326"
set {datstore_memcells|g_mem_layer[1].g_memCells[13].dataStore_memCell} "$_session_group_326"

gui_sg_addsignal -group "$_session_group_326" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.mem} }

gui_sg_move "$_session_group_326" -after "$_session_group_296" -pos 4 

set _session_group_327 $_session_group_296|
append _session_group_327 {g_mem_layer[1].g_memCells[14].dataStore_memCell}
gui_sg_create "$_session_group_327"
set {datstore_memcells|g_mem_layer[1].g_memCells[14].dataStore_memCell} "$_session_group_327"

gui_sg_addsignal -group "$_session_group_327" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.mem} }

gui_sg_move "$_session_group_327" -after "$_session_group_296" -pos 2 

set _session_group_328 $_session_group_296|
append _session_group_328 {g_mem_layer[1].g_memCells[15].dataStore_memCell}
gui_sg_create "$_session_group_328"
set {datstore_memcells|g_mem_layer[1].g_memCells[15].dataStore_memCell} "$_session_group_328"

gui_sg_addsignal -group "$_session_group_328" { {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.A} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.DIN} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.WR} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.OE} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.DOUT} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.ramout} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.lastread_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.lastwrite_addr} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.wr_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.read_cycle_check} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.addr_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.addr_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.data_hold_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.data_setup_flag} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.din_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.a_changed} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.output_enable} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.addr_unstable_memory} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.mem} }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 620



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
catch {gui_list_expand -id ${Hier.1} tb_ICache}
catch {gui_list_expand -id ${Hier.1} tb_ICache.u_icache}
catch {gui_list_expand -id ${Hier.1} tb_ICache.u_icache.icache_dataStore_unit}
catch {gui_list_select -id ${Hier.1} {{tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell}}}
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active tb_ICache tb_ICache.sv
gui_view_scroll -id ${Source.1} -vertical -set 752
gui_src_set_reusable -id ${Source.1}

# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_create -id ${Wave.1} M1 655.83
gui_marker_create -id ${Wave.1} M2 615
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 590.75 642.793
gui_list_add_group -id ${Wave.1} -after {New Group} {u_icache}
gui_list_add_group -id ${Wave.1} -after {New Group} {icache_TagStore_unit}
gui_list_add_group -id ${Wave.1} -after {New Group} {icache_dataStore_unit}
gui_list_add_group -id ${Wave.1} -after {New Group} {i_vcache_unit}
gui_list_add_group -id ${Wave.1} -after {New Group} {icache_contrller_fsm}
gui_list_add_group -id ${Wave.1} -after {New Group} {tag_store_ramCell_Lower}
gui_list_add_group -id ${Wave.1} -after {New Group} {tag_store_ramCell_Upper}
gui_list_add_group -id ${Wave.1} -after {New Group} {datstore_memcells}
gui_list_add_group -id ${Wave.1}  -after datstore_memcells {{datstore_memcells|g_mem_layer[1].g_memCells[15].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[1].g_memCells[15].dataStore_memCell}} {{datstore_memcells|g_mem_layer[0].g_memCells[0].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[0].g_memCells[0].dataStore_memCell}} {{datstore_memcells|g_mem_layer[1].g_memCells[14].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[1].g_memCells[14].dataStore_memCell}} {{datstore_memcells|g_mem_layer[0].g_memCells[1].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[0].g_memCells[1].dataStore_memCell}} {{datstore_memcells|g_mem_layer[1].g_memCells[13].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[1].g_memCells[13].dataStore_memCell}} {{datstore_memcells|g_mem_layer[1].g_memCells[12].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[1].g_memCells[12].dataStore_memCell}} {{datstore_memcells|g_mem_layer[0].g_memCells[2].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[0].g_memCells[2].dataStore_memCell}} {{datstore_memcells|g_mem_layer[1].g_memCells[11].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[1].g_memCells[11].dataStore_memCell}} {{datstore_memcells|g_mem_layer[1].g_memCells[10].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[1].g_memCells[10].dataStore_memCell}} {{datstore_memcells|g_mem_layer[0].g_memCells[3].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[0].g_memCells[3].dataStore_memCell}} {{datstore_memcells|g_mem_layer[1].g_memCells[9].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[1].g_memCells[9].dataStore_memCell}} {{datstore_memcells|g_mem_layer[0].g_memCells[4].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[0].g_memCells[4].dataStore_memCell}} {{datstore_memcells|g_mem_layer[1].g_memCells[8].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[1].g_memCells[8].dataStore_memCell}} {{datstore_memcells|g_mem_layer[1].g_memCells[7].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[1].g_memCells[7].dataStore_memCell}} {{datstore_memcells|g_mem_layer[0].g_memCells[5].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[0].g_memCells[5].dataStore_memCell}} {{datstore_memcells|g_mem_layer[1].g_memCells[6].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[1].g_memCells[6].dataStore_memCell}} {{datstore_memcells|g_mem_layer[1].g_memCells[5].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[1].g_memCells[5].dataStore_memCell}} {{datstore_memcells|g_mem_layer[0].g_memCells[6].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[0].g_memCells[6].dataStore_memCell}} {{datstore_memcells|g_mem_layer[1].g_memCells[4].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[1].g_memCells[4].dataStore_memCell}} {{datstore_memcells|g_mem_layer[0].g_memCells[7].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[0].g_memCells[7].dataStore_memCell}} {{datstore_memcells|g_mem_layer[1].g_memCells[3].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[1].g_memCells[3].dataStore_memCell}} {{datstore_memcells|g_mem_layer[1].g_memCells[2].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[1].g_memCells[2].dataStore_memCell}} {{datstore_memcells|g_mem_layer[0].g_memCells[8].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[0].g_memCells[8].dataStore_memCell}} {{datstore_memcells|g_mem_layer[1].g_memCells[1].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[1].g_memCells[1].dataStore_memCell}} {{datstore_memcells|g_mem_layer[1].g_memCells[0].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[1].g_memCells[0].dataStore_memCell}} {{datstore_memcells|g_mem_layer[0].g_memCells[9].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[0].g_memCells[9].dataStore_memCell}} {{datstore_memcells|g_mem_layer[0].g_memCells[15].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[0].g_memCells[15].dataStore_memCell}} {{datstore_memcells|g_mem_layer[0].g_memCells[10].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[0].g_memCells[10].dataStore_memCell}} {{datstore_memcells|g_mem_layer[0].g_memCells[14].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[0].g_memCells[14].dataStore_memCell}} {{datstore_memcells|g_mem_layer[0].g_memCells[13].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[0].g_memCells[13].dataStore_memCell}} {{datstore_memcells|g_mem_layer[0].g_memCells[11].dataStore_memCell}}
gui_list_add_group -id ${Wave.1} -after {{datstore_memcells|g_mem_layer[0].g_memCells[11].dataStore_memCell}} {{datstore_memcells|g_mem_layer[0].g_memCells[12].dataStore_memCell}}
gui_list_collapse -id ${Wave.1} icache_TagStore_unit
gui_list_collapse -id ${Wave.1} i_vcache_unit
gui_list_collapse -id ${Wave.1} icache_contrller_fsm
gui_list_collapse -id ${Wave.1} tag_store_ramCell_Lower
gui_list_collapse -id ${Wave.1} tag_store_ramCell_Upper
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[1].g_memCells[15].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[1].g_memCells[14].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[0].g_memCells[1].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[1].g_memCells[13].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[1].g_memCells[12].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[0].g_memCells[2].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[1].g_memCells[11].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[1].g_memCells[10].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[0].g_memCells[3].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[1].g_memCells[9].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[0].g_memCells[4].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[1].g_memCells[8].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[1].g_memCells[7].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[0].g_memCells[5].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[1].g_memCells[6].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[1].g_memCells[5].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[0].g_memCells[6].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[1].g_memCells[4].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[0].g_memCells[7].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[1].g_memCells[3].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[1].g_memCells[2].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[0].g_memCells[8].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[1].g_memCells[1].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[1].g_memCells[0].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[0].g_memCells[9].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[0].g_memCells[15].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[0].g_memCells[10].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[0].g_memCells[14].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[0].g_memCells[13].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[0].g_memCells[11].dataStore_memCell}
gui_list_collapse -id ${Wave.1} {datstore_memcells|g_mem_layer[0].g_memCells[12].dataStore_memCell}
gui_list_expand -id ${Wave.1} tb_ICache.u_icache.inFromDte_i
gui_list_expand -id ${Wave.1} tb_ICache.u_icache.icache_dataLines
gui_list_expand -id ${Wave.1} tb_ICache.u_icache.icache_dataStore_unit.WR_2_DataStore_actual
gui_list_expand -id ${Wave.1} {tb_ICache.u_icache.icache_dataStore_unit.WR_2_DataStore_actual[0]}
gui_list_expand -id ${Wave.1} {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.mem}
gui_set_radix -radix enum_toggle -signal {{tb_ICache.u_icache.icache_dataStore_unit.WR_2_DataStore_actual[0]}}
gui_set_radix -radix enum_toggle -signal {{tb_ICache.u_icache.icache_dataStore_unit.WR_2_DataStore_actual[1]}}
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
gui_list_set_insertion_bar  -id ${Wave.1} -group u_icache  -item tb_ICache.u_icache.inFromDte_i.driveAddrBus -position below

gui_marker_move -id ${Wave.1} {C1} 620
gui_view_scroll -id ${Wave.1} -vertical -set 0
gui_show_grid -id ${Wave.1} -enable false

# DriverLoad 'DriverLoad.1'
gui_get_drivers -session -id ${DriverLoad.1} -signal {tb_ICache.u_icache.icache_dataStore_unit.currLine_o[0:15][7:0]} -time 200 -starttime 201.09
gui_get_drivers -session -id ${DriverLoad.1} -signal tb_ICache.u_icache.icache_TagStore_unit.currLine_V -time 5 -starttime 247.054

# View 'Schematic.1'
gui_use_schematics

# Create schematic window 'Schematic.1'
gui_sch_show -window ${Schematic.1} -name tb_ICache.u_icache
gui_show_pin_value_annotate [gui_window_hier_name -window ${Schematic.1}]
gui_zoom -window ${Schematic.1} -rect { {68249 -131097} {204430 -56684} }



# View 'Schematic.2'
gui_use_schematics

# Create schematic window 'Schematic.2'
gui_sch_show -window ${Schematic.2} -name {tb_ICache.u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell}
gui_show_pin_value_annotate [gui_window_hier_name -window ${Schematic.2}]
gui_zoom -window ${Schematic.2} -rect { {-36603 -80725} {119220 4420} }


# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Source.1}
}
#</Session>

