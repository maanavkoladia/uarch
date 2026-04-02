# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Thu Apr 2 14:39:43 2026
# Designs open: 1
#   V1: vcdplus.vpd
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: tb_dcache
#   Wave.1: 238 signals
#   Group count = 11
#   Group tb_dcache signal count = 17
#   Group uut0_dcache signal count = 26
#   Group evictionBuf_unit signal count = 11
#   Group DCache signal count = 3
#   Group VCache signal count = 3
# End_DVE_Session_Save_Info

# DVE version: T-2022.06_Full64
# DVE build date: May 31 2022 20:53:03


#<Session mode="Full" path="/home/ecelrc/students/mak4738/uarch/design_project/design/EverythingEverywhereAllAtOnce/tests/DCache/system/session.vcdplus.vpd.tcl" type="Debug">

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
gui_show_window -window ${TopLevel.1} -show_state normal -rect {{10 109} {1415 847}}

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
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 338]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 338
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 337} {height 482} {dock_state left} {dock_on_new_line true} {child_hier_colhier 232} {child_hier_coltype 100} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 241]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 241
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 486
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 240} {height 482} {dock_state left} {dock_on_new_line true} {child_data_colvariable 140} {child_data_colvalue 100} {child_data_coltype 40} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 158]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 1407
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 158
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 1405} {height 157} {dock_state bottom} {dock_on_new_line true}}
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
gui_show_window -window ${TopLevel.2} -show_state normal -rect {{5 56} {1594 921}}

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
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 461} {child_wave_right 1123} {child_wave_colname 296} {child_wave_colvalue 161} {child_wave_col1 0} {child_wave_col2 1}}

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
gui_load_child_values {tb_dcache.uut0_dcache.vcache_unit}
gui_load_child_values {tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit}
gui_load_child_values {tb_dcache.uut0_dcache}
gui_load_child_values {tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit}
gui_load_child_values {tb_dcache}
gui_load_child_values {tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit}
gui_load_child_values {tb_dcache.uut0_dcache.dcache_bank_unit}
gui_load_child_values {tb_dcache.uut0_dcache.evictionBuf_unit}
gui_load_child_values {tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit}


set _session_group_1 tb_dcache
gui_sg_create "$_session_group_1"
set tb_dcache "$_session_group_1"

gui_sg_addsignal -group "$_session_group_1" { tb_dcache.out2Core tb_dcache.addrBus tb_dcache.driveAddrBus tb_dcache.out2Sch tb_dcache.inFromCore tb_dcache.st_overide_fromArb tb_dcache.inFromDTE tb_dcache.clk tb_dcache.dte_2_dcache tb_dcache.block_req tb_dcache.dataBus tb_dcache.driveDataBus tb_dcache.addrForBus {tb_dcache.$unit} tb_dcache.CLK_PERIOD tb_dcache.dataForBus tb_dcache.rst }
gui_set_radix -radix {decimal} -signals {V1:tb_dcache.CLK_PERIOD}
gui_set_radix -radix {twosComplement} -signals {V1:tb_dcache.CLK_PERIOD}

set _session_group_2 uut0_dcache
gui_sg_create "$_session_group_2"
set uut0_dcache "$_session_group_2"

gui_sg_addsignal -group "$_session_group_2" { {tb_dcache.uut0_dcache.$unit} tb_dcache.uut0_dcache.clk_i tb_dcache.uut0_dcache.rst_i tb_dcache.uut0_dcache.mem_Valid_FromDte_i tb_dcache.uut0_dcache.evictionBuf_clr_FromDTE_i tb_dcache.uut0_dcache.evictionBuf_setCommiting_FromDTE_i tb_dcache.uut0_dcache.permissionToDriveDataBus_evictionBuf tb_dcache.uut0_dcache.permissionToDriveAddrBus_Ld tb_dcache.uut0_dcache.permissionToDriveAddrBus_eb tb_dcache.uut0_dcache.st_override_for_sch_req tb_dcache.uut0_dcache.dataBus tb_dcache.uut0_dcache.address_bus tb_dcache.uut0_dcache.block_busy tb_dcache.uut0_dcache.makeBlockReq tb_dcache.uut0_dcache.eb_blockingVCache tb_dcache.uut0_dcache.eb_V tb_dcache.uut0_dcache.eb_curr_commiting tb_dcache.uut0_dcache.eb_blocking_Bank tb_dcache.uut0_dcache.address_bus_fake tb_dcache.uut0_dcache.startingOffset tb_dcache.uut0_dcache.dataBus_fake tb_dcache.uut0_dcache.block_req_i tb_dcache.uut0_dcache.outputs_o tb_dcache.uut0_dcache.dcache_bank_outputs tb_dcache.uut0_dcache.vcache_outputs tb_dcache.uut0_dcache.eb_outputs }

set _session_group_3 evictionBuf_unit
gui_sg_create "$_session_group_3"
set evictionBuf_unit "$_session_group_3"

gui_sg_addsignal -group "$_session_group_3" { {tb_dcache.uut0_dcache.evictionBuf_unit.$unit} tb_dcache.uut0_dcache.evictionBuf_unit.clk_i tb_dcache.uut0_dcache.evictionBuf_unit.rst_i tb_dcache.uut0_dcache.evictionBuf_unit.eb_clr_i tb_dcache.uut0_dcache.evictionBuf_unit.set_commiting tb_dcache.uut0_dcache.evictionBuf_unit.validReq tb_dcache.uut0_dcache.evictionBuf_unit.hit tb_dcache.uut0_dcache.evictionBuf_unit.blockReq_i tb_dcache.uut0_dcache.evictionBuf_unit.vcache_outputs_i tb_dcache.uut0_dcache.evictionBuf_unit.outputs_o tb_dcache.uut0_dcache.evictionBuf_unit.eb }

set _session_group_4 DCache
gui_sg_create "$_session_group_4"
set DCache "$_session_group_4"

gui_sg_addsignal -group "$_session_group_4" { }

set _session_group_5 $_session_group_4|
append _session_group_5 DCache_Bank_TagStore_unit
gui_sg_create "$_session_group_5"
set DCache|DCache_Bank_TagStore_unit "$_session_group_5"

gui_sg_addsignal -group "$_session_group_5" { {tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.$unit} tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.clk tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.rst tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.p_addr_i tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.oe_i tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.we_i tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.ld_From_V_Swap_i tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.V_Cache_SwapBuf_DirtyBit tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.fill3_i tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.write2_Dwap_i tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.bankControllerBusy_i tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.writeSuccess tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.tagOut_o tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.currLine_V_o tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.currLine_Dirty_o tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.ADDRESS_2_TagStore tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.WR_2_TagStore_clk tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.WR_2_TagStore_delay tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.WR_2_TagStore_actual tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.DIN_2_TagStore tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.OE_2_TagStore tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.DOUT_2_TagStore tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.DOUT_2_TagStore_extended tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.WR_2_TagStore_Delay tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.tagMetaStore tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_TagStore_unit.p_addr_fields }

set _session_group_6 $_session_group_4|
append _session_group_6 DCache_Bank_DataStore_unit
gui_sg_create "$_session_group_6"
set DCache|DCache_Bank_DataStore_unit "$_session_group_6"

gui_sg_addsignal -group "$_session_group_6" { {tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.$unit} tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.rst tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.p_addr_i tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.oe tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.we tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.ld_From_V_Swap_i tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.fill0_i tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.fill1_i tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.fill2_i tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.fill3_i tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.write2_Dwap_i tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.bankControllerBusy_i tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.st_q_data tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.st_data_vec tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.VCache_SwapBuf_Line_i tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.dataBus_i tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.tagStore_hit_i tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.lineOut_o tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.ADDRESS_2_DataStore tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.DIN_2_DataStore tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.OE_2_DataStore tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.DOUT_DataStore tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.WR_2_DataStore_clk tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.WR_2_DataStore_Delay tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.WR_2_DataStore_actual tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.NUM_CELL_IN_DATA_STORE tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.p_addr_fields }
gui_set_radix -radix {decimal} -signals {V1:tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.NUM_CELL_IN_DATA_STORE}
gui_set_radix -radix {twosComplement} -signals {V1:tb_dcache.uut0_dcache.dcache_bank_unit.DCache_Bank_DataStore_unit.NUM_CELL_IN_DATA_STORE}

gui_sg_move "$_session_group_6" -after "$_session_group_4" -pos 1 

set _session_group_7 $_session_group_4|
append _session_group_7 dcache_bank_unit
gui_sg_create "$_session_group_7"
set DCache|dcache_bank_unit "$_session_group_7"

gui_sg_addsignal -group "$_session_group_7" { {tb_dcache.uut0_dcache.dcache_bank_unit.$unit} tb_dcache.uut0_dcache.dcache_bank_unit.clk tb_dcache.uut0_dcache.dcache_bank_unit.rst tb_dcache.uut0_dcache.dcache_bank_unit.mem_Valid_FromDte_i tb_dcache.uut0_dcache.dcache_bank_unit.block_busy_i tb_dcache.uut0_dcache.dcache_bank_unit.dataBus tb_dcache.uut0_dcache.dcache_bank_unit.dcache_bank_State tb_dcache.uut0_dcache.dcache_bank_unit.dcache_bank_State_bits tb_dcache.uut0_dcache.dcache_bank_unit.hit tb_dcache.uut0_dcache.dcache_bank_unit.miss tb_dcache.uut0_dcache.dcache_bank_unit.currTag tb_dcache.uut0_dcache.dcache_bank_unit.currLineValid tb_dcache.uut0_dcache.dcache_bank_unit.currLineDirty tb_dcache.uut0_dcache.dcache_bank_unit.dataStore_Line tb_dcache.uut0_dcache.dcache_bank_unit.writeSuccess2TagStore tb_dcache.uut0_dcache.dcache_bank_unit.doAccess tb_dcache.uut0_dcache.dcache_bank_unit.V_Cache_i tb_dcache.uut0_dcache.dcache_bank_unit.eb_i tb_dcache.uut0_dcache.dcache_bank_unit.blockReq_i tb_dcache.uut0_dcache.dcache_bank_unit.outputs_o tb_dcache.uut0_dcache.dcache_bank_unit.fsmOuts tb_dcache.uut0_dcache.dcache_bank_unit.dcache_bank_swapBuf tb_dcache.uut0_dcache.dcache_bank_unit.savedReq tb_dcache.uut0_dcache.dcache_bank_unit.reqInUse tb_dcache.uut0_dcache.dcache_bank_unit.blockReq_p_addr_fields }

gui_sg_move "$_session_group_7" -after "$_session_group_4" -pos 2 

set _session_group_8 VCache
gui_sg_create "$_session_group_8"
set VCache "$_session_group_8"

gui_sg_addsignal -group "$_session_group_8" { }

set _session_group_9 $_session_group_8|
append _session_group_9 vcache_datastore_unit
gui_sg_create "$_session_group_9"
set VCache|vcache_datastore_unit "$_session_group_9"

gui_sg_addsignal -group "$_session_group_9" { {tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.$unit} tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.rst_i tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.p_addr_i tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.oe_i tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.we_i tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.st_q_data_i tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.st_data_vec_i tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.DCache_SwapBuf_Line_i tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.read_D_SWAP_i tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.Write_VSWAP_i tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.busy_i tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.LD_EB_i tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.tagStore_hit_i tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.use_savedSwapIDX_i tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.hitIDX_i tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.evictionIDX_i tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.savedSwapIDX_i tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.VCache_DataStore_LineOut_o tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.ADDRESS_2_DataStore tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.DIN_2_DataStore tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.OE_2_DataStore tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.DOUT_DataStore tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.WR_2_DataStore_clk tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.WR_2_DataStore_delay tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.WR_2_DataStore_actual tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.NUM_CELL_IN_DATA_STORE }
gui_set_radix -radix {decimal} -signals {V1:tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.NUM_CELL_IN_DATA_STORE}
gui_set_radix -radix {twosComplement} -signals {V1:tb_dcache.uut0_dcache.vcache_unit.vcache_datastore_unit.NUM_CELL_IN_DATA_STORE}

set _session_group_10 $_session_group_8|
append _session_group_10 vcache_tagstore_unit
gui_sg_create "$_session_group_10"
set VCache|vcache_tagstore_unit "$_session_group_10"

gui_sg_addsignal -group "$_session_group_10" { {tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.$unit} tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.clk_i tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.rst tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.p_addr_i tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.oe_i tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.we_i tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.Read_DSWAP_i tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.D_Cache_SwapBuf_Addr tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.D_Cache_SwapBuf_DirtyBit tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.DCache_Will_Evict_i tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.saveSwapIDX tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.use_savedSwapIDX tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.bankControllerBusy_i tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.LD_EB_i tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.Write_VSWAP_i tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.Update_LRU tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.tagOut_o tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.hit_o tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.miss_o tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.hitIDX_o tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.evictionIDX_o tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.savedSwapIDX_o tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.currLine_Dirty_o tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.VC_Will_Need_ToEvict_o tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.doAccess tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.hit tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.miss tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.writeSuccess tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.noHit tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.hitIdx tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.hitIdx_onehot tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.saved_SwapIDX tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.saved_SwapIDX_oneHot tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.currLRU_IDX tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.newLRU tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.update_idx tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.WR_2_TagStore_idx tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.DIN_2_TagStore tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.OE_2_TagStore_idx tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.DOUT_of_TagStore_Net tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.currLine_Dirty_idx tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.WR_2_TagStore_clk tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.WR_2_TagStore_delay tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.WR_2_TagStore_actual tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.DIN_2_TagStore_net tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.OE_2_TagStore tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.DOUT_of_TagStore tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.NUM_CELLS_NEEDED tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.CELL_WIDTH_BITS tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.NUM_LRU_BITS tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.LRU_ROOT tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.LRU_LEFT_LEAF tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.LRU_RIGHT_LEAF tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.tagMetaStore tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.p_addr_fields tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.DCache_SwapBuf_lineAddr_fields }
gui_set_radix -radix {decimal} -signals {V1:tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.NUM_CELLS_NEEDED}
gui_set_radix -radix {twosComplement} -signals {V1:tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.NUM_CELLS_NEEDED}
gui_set_radix -radix {decimal} -signals {V1:tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.CELL_WIDTH_BITS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.CELL_WIDTH_BITS}
gui_set_radix -radix {decimal} -signals {V1:tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.NUM_LRU_BITS}
gui_set_radix -radix {twosComplement} -signals {V1:tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.NUM_LRU_BITS}
gui_set_radix -radix {decimal} -signals {V1:tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.LRU_ROOT}
gui_set_radix -radix {twosComplement} -signals {V1:tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.LRU_ROOT}
gui_set_radix -radix {decimal} -signals {V1:tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.LRU_LEFT_LEAF}
gui_set_radix -radix {twosComplement} -signals {V1:tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.LRU_LEFT_LEAF}
gui_set_radix -radix {decimal} -signals {V1:tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.LRU_RIGHT_LEAF}
gui_set_radix -radix {twosComplement} -signals {V1:tb_dcache.uut0_dcache.vcache_unit.vcache_tagstore_unit.LRU_RIGHT_LEAF}

gui_sg_move "$_session_group_10" -after "$_session_group_8" -pos 1 

set _session_group_11 $_session_group_8|
append _session_group_11 vcache_unit
gui_sg_create "$_session_group_11"
set VCache|vcache_unit "$_session_group_11"

gui_sg_addsignal -group "$_session_group_11" { {tb_dcache.uut0_dcache.vcache_unit.$unit} tb_dcache.uut0_dcache.vcache_unit.clk tb_dcache.uut0_dcache.vcache_unit.rst tb_dcache.uut0_dcache.vcache_unit.block_busy_i tb_dcache.uut0_dcache.vcache_unit.vcache_fsm_state tb_dcache.uut0_dcache.vcache_unit.vcache_fsm_state_bits tb_dcache.uut0_dcache.vcache_unit.currTag tb_dcache.uut0_dcache.vcache_unit.hit tb_dcache.uut0_dcache.vcache_unit.miss tb_dcache.uut0_dcache.vcache_unit.hitIDX tb_dcache.uut0_dcache.vcache_unit.evictionIDX tb_dcache.uut0_dcache.vcache_unit.savedSwapIDX tb_dcache.uut0_dcache.vcache_unit.V_Cache_needs_2_evict tb_dcache.uut0_dcache.vcache_unit.V_Cache_TagStore_CurrLine_Dirty tb_dcache.uut0_dcache.vcache_unit.vcache_dataStore_Line tb_dcache.uut0_dcache.vcache_unit.blockReq_i tb_dcache.uut0_dcache.vcache_unit.eb_outs_i tb_dcache.uut0_dcache.vcache_unit.dcache_outs_i tb_dcache.uut0_dcache.vcache_unit.outputs_o tb_dcache.uut0_dcache.vcache_unit.fsmOuts tb_dcache.uut0_dcache.vcache_unit.savedReq tb_dcache.uut0_dcache.vcache_unit.reqInUse tb_dcache.uut0_dcache.vcache_unit.block_req_p_addr_fields tb_dcache.uut0_dcache.vcache_unit.vcache_swapBuf }

gui_sg_move "$_session_group_11" -after "$_session_group_8" -pos 2 

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 275551



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
catch {gui_list_select -id ${Hier.1} {tb_dcache}}
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {tb_dcache.uut0_dcache.evictionBuf_unit}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active tb_dcache tb_dcache.sv
gui_view_scroll -id ${Source.1} -vertical -set 45
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
gui_wv_zoom_timerange -id ${Wave.1} 150543 290669
gui_list_add_group -id ${Wave.1} -after {New Group} {tb_dcache}
gui_list_add_group -id ${Wave.1} -after {New Group} {uut0_dcache}
gui_list_add_group -id ${Wave.1} -after {New Group} {evictionBuf_unit}
gui_list_add_group -id ${Wave.1} -after {New Group} {DCache}
gui_list_add_group -id ${Wave.1}  -after DCache {DCache|DCache_Bank_TagStore_unit}
gui_list_add_group -id ${Wave.1} -after DCache|DCache_Bank_TagStore_unit {DCache|DCache_Bank_DataStore_unit}
gui_list_add_group -id ${Wave.1} -after DCache|DCache_Bank_DataStore_unit {DCache|dcache_bank_unit}
gui_list_add_group -id ${Wave.1} -after {New Group} {VCache}
gui_list_add_group -id ${Wave.1}  -after VCache {VCache|vcache_datastore_unit}
gui_list_add_group -id ${Wave.1} -after VCache|vcache_datastore_unit {VCache|vcache_tagstore_unit}
gui_list_add_group -id ${Wave.1} -after VCache|vcache_tagstore_unit {VCache|vcache_unit}
gui_list_collapse -id ${Wave.1} tb_dcache
gui_list_collapse -id ${Wave.1} uut0_dcache
gui_list_collapse -id ${Wave.1} evictionBuf_unit
gui_list_collapse -id ${Wave.1} DCache
gui_list_collapse -id ${Wave.1} DCache|DCache_Bank_TagStore_unit
gui_list_collapse -id ${Wave.1} DCache|DCache_Bank_DataStore_unit
gui_list_collapse -id ${Wave.1} DCache|dcache_bank_unit
gui_list_collapse -id ${Wave.1} VCache
gui_list_collapse -id ${Wave.1} VCache|vcache_datastore_unit
gui_list_collapse -id ${Wave.1} VCache|vcache_tagstore_unit
gui_list_collapse -id ${Wave.1} VCache|vcache_unit
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
gui_list_set_insertion_bar  -id ${Wave.1} -group DCache  -position in

gui_marker_move -id ${Wave.1} {C1} 275551
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

