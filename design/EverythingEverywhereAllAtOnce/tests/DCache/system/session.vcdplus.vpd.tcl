# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Sat Apr 11 00:15:30 2026
# Designs open: 1
#   V1: vcdplus.vpd
# Toplevel windows open: 1
# 	TopLevel.1
#   Source.1: tb_dcache.uut0_dcache
#   Group count = 17
#   Group uut1_mem signal count = 7
#   Group uut2_DTE signal count = 0
#   Group Dcache signal count = 7
#   Group dcahce_block signal count = 4
#   Group vcache_datastore_unit signal count = 29
#   Group vcache_tag_store_unit signal count = 51
# End_DVE_Session_Save_Info

# DVE version: T-2022.06_Full64
# DVE build date: May 31 2022 20:53:03


#<Session mode="Full" path="/home/ecelrc/students/je28497/uarch/design/EverythingEverywhereAllAtOnce/tests/DCache/system/session.vcdplus.vpd.tcl" type="Debug">

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
gui_show_window -window ${TopLevel.1} -show_state maximized -rect {{1536 23} {3071 815}}

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
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 444]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 444
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 443} {height 514} {dock_state left} {dock_on_new_line true} {child_hier_colhier 335} {child_hier_coltype 107} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 337]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 337
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 520
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 336} {height 514} {dock_state left} {dock_on_new_line true} {child_data_colvariable 352} {child_data_colvalue 161} {child_data_coltype 159} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 172]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value -1
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 172
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 271} {height 179} {dock_state bottom} {dock_on_new_line true}}
set DriverLoad.1 [gui_create_window -type DriverLoad -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line false -dock_extent 180]
gui_set_window_pref_key -window ${DriverLoad.1} -key dock_width -value_type integer -value 150
gui_set_window_pref_key -window ${DriverLoad.1} -key dock_height -value_type integer -value 180
gui_set_window_pref_key -window ${DriverLoad.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DriverLoad.1} {{left 0} {top 0} {width 1263} {height 179} {dock_state bottom} {dock_on_new_line false}}
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

gui_set_env TOPLEVELS::TARGET_FRAME(Source) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Schematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(PathSchematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Wave) none
gui_set_env TOPLEVELS::TARGET_FRAME(List) none
gui_set_env TOPLEVELS::TARGET_FRAME(Memory) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(DriverLoad) none
gui_update_statusbar_target_frame ${TopLevel.1}

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
gui_load_child_values {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit}
gui_load_child_values {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit}
gui_load_child_values {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit}
gui_load_child_values {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit}
gui_load_child_values {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit}


set _session_group_1 uut1_mem
gui_sg_create "$_session_group_1"
set uut1_mem "$_session_group_1"

gui_sg_addsignal -group "$_session_group_1" { {tb_dcache.uut1_mem.$unit} tb_dcache.uut1_mem.clk tb_dcache.uut1_mem.rst tb_dcache.uut1_mem.address_bus tb_dcache.uut1_mem.data_bus tb_dcache.uut1_mem.mem_bus tb_dcache.uut1_mem.dataToDrive }

set _session_group_2 uut2_DTE
gui_sg_create "$_session_group_2"
set uut2_DTE "$_session_group_2"


set _session_group_3 Dcache
gui_sg_create "$_session_group_3"
set Dcache "$_session_group_3"

gui_sg_addsignal -group "$_session_group_3" { }

set _session_group_4 $_session_group_3|
append _session_group_4 {g_dcache_block[0].block}
gui_sg_create "$_session_group_4"
set {Dcache|g_dcache_block[0].block} "$_session_group_4"

gui_sg_addsignal -group "$_session_group_4" { {tb_dcache.uut0_dcache.g_dcache_block[0].block.$unit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.clk_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.rst_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.mem_Valid_FromDte_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_clr_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_setCommiting_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.permissionToDriveDataBus_evictionBuf} {tb_dcache.uut0_dcache.g_dcache_block[0].block.permissionToDriveAddrBus_Ld} {tb_dcache.uut0_dcache.g_dcache_block[0].block.permissionToDriveAddrBus_eb} {tb_dcache.uut0_dcache.g_dcache_block[0].block.st_override_for_sch_req} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dataBus} {tb_dcache.uut0_dcache.g_dcache_block[0].block.address_bus} {tb_dcache.uut0_dcache.g_dcache_block[0].block.block_busy} {tb_dcache.uut0_dcache.g_dcache_block[0].block.makeBlockReq} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_blockingVCache} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_V} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_curr_commiting} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_blocking_Bank} {tb_dcache.uut0_dcache.g_dcache_block[0].block.address_bus_fake} {tb_dcache.uut0_dcache.g_dcache_block[0].block.startingOffset} {tb_dcache.uut0_dcache.g_dcache_block[0].block.block_req_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.outputs_o} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_outputs} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_outputs} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_outputs} }

gui_sg_move "$_session_group_4" -after "$_session_group_3" -pos 4 

set _session_group_5 $_session_group_3|
append _session_group_5 {g_dcache_block[3].block}
gui_sg_create "$_session_group_5"
set {Dcache|g_dcache_block[3].block} "$_session_group_5"

gui_sg_addsignal -group "$_session_group_5" { {tb_dcache.uut0_dcache.g_dcache_block[3].block.$unit} {tb_dcache.uut0_dcache.g_dcache_block[3].block.clk_i} {tb_dcache.uut0_dcache.g_dcache_block[3].block.rst_i} {tb_dcache.uut0_dcache.g_dcache_block[3].block.mem_Valid_FromDte_i} {tb_dcache.uut0_dcache.g_dcache_block[3].block.evictionBuf_clr_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[3].block.evictionBuf_setCommiting_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[3].block.permissionToDriveDataBus_evictionBuf} {tb_dcache.uut0_dcache.g_dcache_block[3].block.permissionToDriveAddrBus_Ld} {tb_dcache.uut0_dcache.g_dcache_block[3].block.permissionToDriveAddrBus_eb} {tb_dcache.uut0_dcache.g_dcache_block[3].block.st_override_for_sch_req} {tb_dcache.uut0_dcache.g_dcache_block[3].block.dataBus} {tb_dcache.uut0_dcache.g_dcache_block[3].block.address_bus} {tb_dcache.uut0_dcache.g_dcache_block[3].block.block_busy} {tb_dcache.uut0_dcache.g_dcache_block[3].block.makeBlockReq} {tb_dcache.uut0_dcache.g_dcache_block[3].block.eb_blockingVCache} {tb_dcache.uut0_dcache.g_dcache_block[3].block.eb_V} {tb_dcache.uut0_dcache.g_dcache_block[3].block.eb_curr_commiting} {tb_dcache.uut0_dcache.g_dcache_block[3].block.eb_blocking_Bank} {tb_dcache.uut0_dcache.g_dcache_block[3].block.address_bus_fake} {tb_dcache.uut0_dcache.g_dcache_block[3].block.startingOffset} {tb_dcache.uut0_dcache.g_dcache_block[3].block.block_req_i} {tb_dcache.uut0_dcache.g_dcache_block[3].block.outputs_o} {tb_dcache.uut0_dcache.g_dcache_block[3].block.dcache_bank_outputs} {tb_dcache.uut0_dcache.g_dcache_block[3].block.vcache_outputs} {tb_dcache.uut0_dcache.g_dcache_block[3].block.eb_outputs} }
gui_set_radix -radix {decimal} -signals {{V1:tb_dcache.uut0_dcache.g_dcache_block[3].block.startingOffset}}
gui_set_radix -radix {twosComplement} -signals {{V1:tb_dcache.uut0_dcache.g_dcache_block[3].block.startingOffset}}

gui_sg_move "$_session_group_5" -after "$_session_group_3" -pos 2 

set _session_group_6 $_session_group_3|
append _session_group_6 mio_block_unit
gui_sg_create "$_session_group_6"
set Dcache|mio_block_unit "$_session_group_6"

gui_sg_addsignal -group "$_session_group_6" { {tb_dcache.uut0_dcache.mio_block_unit.$unit} tb_dcache.uut0_dcache.mio_block_unit.clk tb_dcache.uut0_dcache.mio_block_unit.rst tb_dcache.uut0_dcache.mio_block_unit.reqServed_FromDTE_i tb_dcache.uut0_dcache.mio_block_unit.PermissionToDriveAddrBus tb_dcache.uut0_dcache.mio_block_unit.permission2DriveDataBus tb_dcache.uut0_dcache.mio_block_unit.ld_addr_MIO_V tb_dcache.uut0_dcache.mio_block_unit.ld_addr_MIO tb_dcache.uut0_dcache.mio_block_unit.address_bus tb_dcache.uut0_dcache.mio_block_unit.dataBus tb_dcache.uut0_dcache.mio_block_unit.block_idle tb_dcache.uut0_dcache.mio_block_unit.readyForNewReq tb_dcache.uut0_dcache.mio_block_unit.data_bus_fake tb_dcache.uut0_dcache.mio_block_unit.WE_ADDR_MASK tb_dcache.uut0_dcache.mio_block_unit.stq_info_mio tb_dcache.uut0_dcache.mio_block_unit.outputs_o tb_dcache.uut0_dcache.mio_block_unit.block_req }
gui_set_radix -radix {decimal} -signals {V1:tb_dcache.uut0_dcache.mio_block_unit.WE_ADDR_MASK}
gui_set_radix -radix {twosComplement} -signals {V1:tb_dcache.uut0_dcache.mio_block_unit.WE_ADDR_MASK}

gui_sg_move "$_session_group_6" -after "$_session_group_3" -pos 1 

set _session_group_7 $_session_group_3|
append _session_group_7 uut0_dcache
gui_sg_create "$_session_group_7"
set Dcache|uut0_dcache "$_session_group_7"

gui_sg_addsignal -group "$_session_group_7" { {tb_dcache.uut0_dcache.$unit} tb_dcache.uut0_dcache.clk tb_dcache.uut0_dcache.rst tb_dcache.uut0_dcache.dataBus tb_dcache.uut0_dcache.address_bus tb_dcache.uut0_dcache.hitVec tb_dcache.uut0_dcache.arb_st_override_Out tb_dcache.uut0_dcache.inFromCore_i tb_dcache.uut0_dcache.out2Core_o tb_dcache.uut0_dcache.inFromDTE_i tb_dcache.uut0_dcache.out2Sch_o tb_dcache.uut0_dcache.blockOutputs tb_dcache.uut0_dcache.req_2_blocks tb_dcache.uut0_dcache.mio_block_outputs }

set _session_group_8 $_session_group_3|
append _session_group_8 {g_dcache_block[2].block}
gui_sg_create "$_session_group_8"
set {Dcache|g_dcache_block[2].block} "$_session_group_8"

gui_sg_addsignal -group "$_session_group_8" { {tb_dcache.uut0_dcache.g_dcache_block[2].block.$unit} {tb_dcache.uut0_dcache.g_dcache_block[2].block.clk_i} {tb_dcache.uut0_dcache.g_dcache_block[2].block.rst_i} {tb_dcache.uut0_dcache.g_dcache_block[2].block.mem_Valid_FromDte_i} {tb_dcache.uut0_dcache.g_dcache_block[2].block.evictionBuf_clr_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[2].block.evictionBuf_setCommiting_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[2].block.permissionToDriveDataBus_evictionBuf} {tb_dcache.uut0_dcache.g_dcache_block[2].block.permissionToDriveAddrBus_Ld} {tb_dcache.uut0_dcache.g_dcache_block[2].block.permissionToDriveAddrBus_eb} {tb_dcache.uut0_dcache.g_dcache_block[2].block.st_override_for_sch_req} {tb_dcache.uut0_dcache.g_dcache_block[2].block.dataBus} {tb_dcache.uut0_dcache.g_dcache_block[2].block.address_bus} {tb_dcache.uut0_dcache.g_dcache_block[2].block.block_busy} {tb_dcache.uut0_dcache.g_dcache_block[2].block.makeBlockReq} {tb_dcache.uut0_dcache.g_dcache_block[2].block.eb_blockingVCache} {tb_dcache.uut0_dcache.g_dcache_block[2].block.eb_V} {tb_dcache.uut0_dcache.g_dcache_block[2].block.eb_curr_commiting} {tb_dcache.uut0_dcache.g_dcache_block[2].block.eb_blocking_Bank} {tb_dcache.uut0_dcache.g_dcache_block[2].block.address_bus_fake} {tb_dcache.uut0_dcache.g_dcache_block[2].block.startingOffset} {tb_dcache.uut0_dcache.g_dcache_block[2].block.dataBus_fake} {tb_dcache.uut0_dcache.g_dcache_block[2].block.block_req_i} {tb_dcache.uut0_dcache.g_dcache_block[2].block.outputs_o} {tb_dcache.uut0_dcache.g_dcache_block[2].block.dcache_bank_outputs} {tb_dcache.uut0_dcache.g_dcache_block[2].block.vcache_outputs} {tb_dcache.uut0_dcache.g_dcache_block[2].block.eb_outputs} }

gui_sg_move "$_session_group_8" -after "$_session_group_3" -pos 6 

set _session_group_9 $_session_group_3|
append _session_group_9 {g_dcache_block[1].block}
gui_sg_create "$_session_group_9"
set {Dcache|g_dcache_block[1].block} "$_session_group_9"

gui_sg_addsignal -group "$_session_group_9" { {tb_dcache.uut0_dcache.g_dcache_block[1].block.$unit} {tb_dcache.uut0_dcache.g_dcache_block[1].block.clk_i} {tb_dcache.uut0_dcache.g_dcache_block[1].block.rst_i} {tb_dcache.uut0_dcache.g_dcache_block[1].block.mem_Valid_FromDte_i} {tb_dcache.uut0_dcache.g_dcache_block[1].block.evictionBuf_clr_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[1].block.evictionBuf_setCommiting_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[1].block.permissionToDriveDataBus_evictionBuf} {tb_dcache.uut0_dcache.g_dcache_block[1].block.permissionToDriveAddrBus_Ld} {tb_dcache.uut0_dcache.g_dcache_block[1].block.permissionToDriveAddrBus_eb} {tb_dcache.uut0_dcache.g_dcache_block[1].block.st_override_for_sch_req} {tb_dcache.uut0_dcache.g_dcache_block[1].block.dataBus} {tb_dcache.uut0_dcache.g_dcache_block[1].block.address_bus} {tb_dcache.uut0_dcache.g_dcache_block[1].block.block_busy} {tb_dcache.uut0_dcache.g_dcache_block[1].block.makeBlockReq} {tb_dcache.uut0_dcache.g_dcache_block[1].block.eb_blockingVCache} {tb_dcache.uut0_dcache.g_dcache_block[1].block.eb_V} {tb_dcache.uut0_dcache.g_dcache_block[1].block.eb_curr_commiting} {tb_dcache.uut0_dcache.g_dcache_block[1].block.eb_blocking_Bank} {tb_dcache.uut0_dcache.g_dcache_block[1].block.address_bus_fake} {tb_dcache.uut0_dcache.g_dcache_block[1].block.startingOffset} {tb_dcache.uut0_dcache.g_dcache_block[1].block.dataBus_fake} {tb_dcache.uut0_dcache.g_dcache_block[1].block.block_req_i} {tb_dcache.uut0_dcache.g_dcache_block[1].block.outputs_o} {tb_dcache.uut0_dcache.g_dcache_block[1].block.dcache_bank_outputs} {tb_dcache.uut0_dcache.g_dcache_block[1].block.vcache_outputs} {tb_dcache.uut0_dcache.g_dcache_block[1].block.eb_outputs} }

gui_sg_move "$_session_group_9" -after "$_session_group_3" -pos 5 

set _session_group_10 $_session_group_3|
append _session_group_10 dcache_arbitration
gui_sg_create "$_session_group_10"
set Dcache|dcache_arbitration "$_session_group_10"

gui_sg_addsignal -group "$_session_group_10" { {tb_dcache.uut0_dcache.dcache_arbitration.$unit} tb_dcache.uut0_dcache.dcache_arbitration.clk_i tb_dcache.uut0_dcache.dcache_arbitration.rst tb_dcache.uut0_dcache.dcache_arbitration.block_hit_i tb_dcache.uut0_dcache.dcache_arbitration.st_override_o tb_dcache.uut0_dcache.dcache_arbitration.block_idleness tb_dcache.uut0_dcache.dcache_arbitration.readyForNewReq tb_dcache.uut0_dcache.dcache_arbitration.ld_req_0_bankNum tb_dcache.uut0_dcache.dcache_arbitration.ld_req_1_bankNum tb_dcache.uut0_dcache.dcache_arbitration.st_override tb_dcache.uut0_dcache.dcache_arbitration.ldReq_2_BankPresent tb_dcache.uut0_dcache.dcache_arbitration.LD_REQ_BANK_UB tb_dcache.uut0_dcache.dcache_arbitration.LD_REQ_BANK_LB tb_dcache.uut0_dcache.dcache_arbitration.LD_REQ_BANK_WIDTH tb_dcache.uut0_dcache.dcache_arbitration.core_i tb_dcache.uut0_dcache.dcache_arbitration.reqs_2_blocks_o tb_dcache.uut0_dcache.dcache_arbitration.reqs }
gui_set_radix -radix {decimal} -signals {V1:tb_dcache.uut0_dcache.dcache_arbitration.LD_REQ_BANK_UB}
gui_set_radix -radix {twosComplement} -signals {V1:tb_dcache.uut0_dcache.dcache_arbitration.LD_REQ_BANK_UB}
gui_set_radix -radix {decimal} -signals {V1:tb_dcache.uut0_dcache.dcache_arbitration.LD_REQ_BANK_LB}
gui_set_radix -radix {twosComplement} -signals {V1:tb_dcache.uut0_dcache.dcache_arbitration.LD_REQ_BANK_LB}
gui_set_radix -radix {decimal} -signals {V1:tb_dcache.uut0_dcache.dcache_arbitration.LD_REQ_BANK_WIDTH}
gui_set_radix -radix {twosComplement} -signals {V1:tb_dcache.uut0_dcache.dcache_arbitration.LD_REQ_BANK_WIDTH}

gui_sg_move "$_session_group_10" -after "$_session_group_3" -pos 3 

set _session_group_11 dcahce_block
gui_sg_create "$_session_group_11"
set dcahce_block "$_session_group_11"

gui_sg_addsignal -group "$_session_group_11" { }

set _session_group_12 $_session_group_11|
append _session_group_12 vcache_unit
gui_sg_create "$_session_group_12"
set dcahce_block|vcache_unit "$_session_group_12"

gui_sg_addsignal -group "$_session_group_12" { {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.$unit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.clk} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.rst} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.block_busy_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_fsm_state} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_fsm_state_bits} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.saveReq} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.useSavedReq} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.saveIDX} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.useSavedIDX} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.currTag} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.hit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.miss} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.hitIDX} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.evictionIDX} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.savedIDX} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.V_Cache_needs_2_evict} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.V_Cache_TagStore_CurrLine_Dirty} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_dataStore_Line} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.blockReq_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.eb_outs_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.dcache_outs_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.outputs_o} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.fsmOuts} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.savedReq} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.reqInUse} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.block_req_p_addr_fields} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_swapBuf} }

gui_sg_move "$_session_group_12" -after "$_session_group_11" -pos 1 

set _session_group_13 $_session_group_11|
append _session_group_13 {g_dcache_block[0].block}
gui_sg_create "$_session_group_13"
set {dcahce_block|g_dcache_block[0].block} "$_session_group_13"

gui_sg_addsignal -group "$_session_group_13" { {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_clr_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.makeBlockReq} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_outputs} {tb_dcache.uut0_dcache.g_dcache_block[0].block.mem_Valid_FromDte_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.address_bus_fake} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_outputs} {tb_dcache.uut0_dcache.g_dcache_block[0].block.block_req_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.address_bus} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_V} {tb_dcache.uut0_dcache.g_dcache_block[0].block.block_busy} {tb_dcache.uut0_dcache.g_dcache_block[0].block.permissionToDriveAddrBus_eb} {tb_dcache.uut0_dcache.g_dcache_block[0].block.startingOffset} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_curr_commiting} {tb_dcache.uut0_dcache.g_dcache_block[0].block.permissionToDriveAddrBus_Ld} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_blockingVCache} {tb_dcache.uut0_dcache.g_dcache_block[0].block.st_override_for_sch_req} {tb_dcache.uut0_dcache.g_dcache_block[0].block.rst_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_setCommiting_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.outputs_o} {tb_dcache.uut0_dcache.g_dcache_block[0].block.permissionToDriveDataBus_evictionBuf} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dataBus} {tb_dcache.uut0_dcache.g_dcache_block[0].block.$unit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dataBus_fake} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_blocking_Bank} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_outputs} {tb_dcache.uut0_dcache.g_dcache_block[0].block.clk_i} }

set _session_group_14 $_session_group_11|
append _session_group_14 dcache_bank_unit
gui_sg_create "$_session_group_14"
set dcahce_block|dcache_bank_unit "$_session_group_14"

gui_sg_addsignal -group "$_session_group_14" { {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.$unit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.clk} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.rst} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.mem_Valid_FromDte_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.block_busy_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.dataBus} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.dcache_bank_State} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.dcache_bank_State_bits} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.saveReq} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.useSavedReq} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.hit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.miss} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.currTag} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.currLineValid} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.currLineDirty} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.dataStore_Line} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.writeSuccess2TagStore} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.doAccess} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.V_Cache_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.eb_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.blockReq_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.outputs_o} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.fsmOuts} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.dcache_bank_swapBuf} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.savedReq} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.reqInUse} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.blockReq_p_addr_fields} }

gui_sg_move "$_session_group_14" -after "$_session_group_11" -pos 3 

set _session_group_15 $_session_group_11|
append _session_group_15 evictionBuf_unit
gui_sg_create "$_session_group_15"
set dcahce_block|evictionBuf_unit "$_session_group_15"

gui_sg_addsignal -group "$_session_group_15" { {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.$unit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.clk_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.rst_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.eb_clr_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.set_commiting} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.validReq} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.hit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.blockReq_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.vcache_outputs_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.outputs_o} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.eb} }

gui_sg_move "$_session_group_15" -after "$_session_group_11" -pos 2 

set _session_group_16 vcache_datastore_unit
gui_sg_create "$_session_group_16"
set vcache_datastore_unit "$_session_group_16"

gui_sg_addsignal -group "$_session_group_16" { {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.$unit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.clk_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.rst_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.p_addr_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.oe_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.we_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.st_q_data_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.st_data_vec_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.DCache_SwapBuf_Line_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.read_D_SWAP_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.Write_VSWAP_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.busy_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.WR_2_EB} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.tagStore_hit_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.useSavedIDX} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.hitIDX_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.evictionIDX_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.savedIDX_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.VCache_DataStore_LineOut_o} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.ADDRESS_2_DataStore} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.clk_phase_45} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.DIN_2_DataStore} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.OE_2_DataStore_clk} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.OE_2_DataStore_delay} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.OE_2_DataStore_actual} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.DOUT_DataStore} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.WR_2_DataStore_clk} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.WR_2_DataStore_actual} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.NUM_CELL_IN_DATA_STORE} }
gui_set_radix -radix {decimal} -signals {{V1:tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.NUM_CELL_IN_DATA_STORE}}
gui_set_radix -radix {twosComplement} -signals {{V1:tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit.NUM_CELL_IN_DATA_STORE}}

set _session_group_17 vcache_tag_store_unit
gui_sg_create "$_session_group_17"
set vcache_tag_store_unit "$_session_group_17"

gui_sg_addsignal -group "$_session_group_17" { {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.$unit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.clk} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.rst} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.p_addr_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.oe_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.we_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.Read_DSWAP_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.D_Cache_SwapBuf_Addr} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.D_Cache_SwapBuf_DirtyBit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.DCache_Will_Evict_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.saveIDX} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.use_savedIDX} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.busy_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.WR_2_EB_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.Write_VSWAP_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.Update_LRU} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.tagOut_o} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.hit_o} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.miss_o} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.hitIDX_o} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.evictionIDX_o} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.savedIDX_o} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.currLine_Dirty_o} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.VC_Will_Need_ToEvict_o} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.clk_phase_45} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.doAccess} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.hit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.miss} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.writeSuccess} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.hitIdx} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.hitIdx_onehot} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.savedIDX} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.savedIDX_oneHot} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.currLRU_IDX} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.DIN_2_TagStore} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.OE_2_TagStore_idx} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.DOUT_of_TagStore_Net} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.currLine_Dirty_idx} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.tag_out_write_to_vswap_idx} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.tag_out_write_to_eb_idx} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.tag_assigned} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.WR_2_TagStore_clk} }
gui_sg_addsignal -group "$_session_group_17" { {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.WR_2_TagStore_actual} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.DIN_2_TagStore_net} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.OE_2_TagStore} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.DOUT_of_TagStore} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.NUM_CELLS_NEEDED} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.CELL_WIDTH_BITS} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.tagMetaStore} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.p_addr_fields} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.DCache_SwapBuf_lineAddr_fields} }
gui_set_radix -radix {decimal} -signals {{V1:tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.NUM_CELLS_NEEDED}}
gui_set_radix -radix {twosComplement} -signals {{V1:tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.NUM_CELLS_NEEDED}}
gui_set_radix -radix {decimal} -signals {{V1:tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.CELL_WIDTH_BITS}}
gui_set_radix -radix {twosComplement} -signals {{V1:tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit.CELL_WIDTH_BITS}}

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 1548.681



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
catch {gui_list_expand -id ${Hier.1} tb_dcache}
catch {gui_list_expand -id ${Hier.1} tb_dcache.uut0_dcache}
catch {gui_list_expand -id ${Hier.1} {tb_dcache.uut0_dcache.g_dcache_block[0].block}}
catch {gui_list_expand -id ${Hier.1} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit}}
catch {gui_list_select -id ${Hier.1} {{tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_datastore_unit}}}
gui_view_scroll -id ${Hier.1} -vertical -set 60
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_tag_store_unit}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 60
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active tb_dcache.uut0_dcache /home/ecelrc/students/je28497/uarch/design/EverythingEverywhereAllAtOnce/rtl/DCache/DCache_TOP.sv
gui_view_scroll -id ${Source.1} -vertical -set 1050
gui_src_set_reusable -id ${Source.1}

# DriverLoad 'DriverLoad.1'
gui_get_drivers -session -id ${DriverLoad.1} -signal {tb_dcache.uut0_dcache.hitVec[1]} -time 0 -starttime 1147.858
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Source.1}
	gui_set_active_window -window ${DriverLoad.1}
}
#</Session>

