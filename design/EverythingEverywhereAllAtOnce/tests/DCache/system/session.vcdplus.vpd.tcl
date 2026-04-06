# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Mon Apr 6 03:12:22 2026
# Designs open: 1
#   V1: vcdplus.vpd
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: tb_dcache
#   Wave.1: 262 signals
#   Group count = 15
#   Group uut1_mem signal count = 13
#   Group uut2_DTE signal count = 0
#   Group Dcache signal count = 7
#   Group dcahce_block signal count = 4
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
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 445]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 445
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 444} {height 521} {dock_state left} {dock_on_new_line true} {child_hier_colhier 335} {child_hier_coltype 107} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 338]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 338
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 520
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 337} {height 521} {dock_state left} {dock_on_new_line true} {child_data_colvariable 352} {child_data_colvalue 161} {child_data_coltype 159} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 173]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 1476
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 173
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 1535} {height 172} {dock_state bottom} {dock_on_new_line true}}
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
gui_show_window -window ${TopLevel.2} -show_state normal -rect {{8 31} {1286 678}}

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
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 511} {child_wave_right 762} {child_wave_colname 324} {child_wave_colvalue 183} {child_wave_col1 0} {child_wave_col2 1}}

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
gui_load_child_values {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit}
gui_load_child_values {tb_dcache.uut0_dcache.mio_block_unit}
gui_load_child_values {tb_dcache.uut0_dcache.g_dcache_block[1].block}
gui_load_child_values {tb_dcache.uut0_dcache}
gui_load_child_values {tb_dcache.uut0_dcache.g_dcache_block[3].block}
gui_load_child_values {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit}
gui_load_child_values {tb_dcache.uut0_dcache.g_dcache_block[0].block}
gui_load_child_values {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit}
gui_load_child_values {tb_dcache.uut1_mem}
gui_load_child_values {tb_dcache.uut0_dcache.g_dcache_block[2].block}
gui_load_child_values {tb_dcache.uut0_dcache.dcache_arbitration}


set _session_group_71 uut1_mem
gui_sg_create "$_session_group_71"
set uut1_mem "$_session_group_71"

gui_sg_addsignal -group "$_session_group_71" { {tb_dcache.uut1_mem.$unit} tb_dcache.uut1_mem.clk tb_dcache.uut1_mem.rst tb_dcache.uut1_mem.address_bus tb_dcache.uut1_mem.data_bus tb_dcache.uut1_mem.mem_bus tb_dcache.uut1_mem.drive_Data_Bus tb_dcache.uut1_mem.dataToDrive tb_dcache.uut1_mem.inFromDte tb_dcache.uut1_mem.out2Dte tb_dcache.uut1_mem.out2Sch tb_dcache.uut1_mem.controller_2_bank_Cmds tb_dcache.uut1_mem.bank_out_2_controller }

set _session_group_72 uut2_DTE
gui_sg_create "$_session_group_72"
set uut2_DTE "$_session_group_72"


set _session_group_73 Dcache
gui_sg_create "$_session_group_73"
set Dcache "$_session_group_73"

gui_sg_addsignal -group "$_session_group_73" { }

set _session_group_74 $_session_group_73|
append _session_group_74 {g_dcache_block[0].block}
gui_sg_create "$_session_group_74"
set {Dcache|g_dcache_block[0].block} "$_session_group_74"

gui_sg_addsignal -group "$_session_group_74" { {tb_dcache.uut0_dcache.g_dcache_block[0].block.$unit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.clk_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.rst_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.mem_Valid_FromDte_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_clr_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_setCommiting_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.permissionToDriveDataBus_evictionBuf} {tb_dcache.uut0_dcache.g_dcache_block[0].block.permissionToDriveAddrBus_Ld} {tb_dcache.uut0_dcache.g_dcache_block[0].block.permissionToDriveAddrBus_eb} {tb_dcache.uut0_dcache.g_dcache_block[0].block.st_override_for_sch_req} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dataBus} {tb_dcache.uut0_dcache.g_dcache_block[0].block.address_bus} {tb_dcache.uut0_dcache.g_dcache_block[0].block.block_busy} {tb_dcache.uut0_dcache.g_dcache_block[0].block.makeBlockReq} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_blockingVCache} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_V} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_curr_commiting} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_blocking_Bank} {tb_dcache.uut0_dcache.g_dcache_block[0].block.address_bus_fake} {tb_dcache.uut0_dcache.g_dcache_block[0].block.startingOffset} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dataBus_fake} {tb_dcache.uut0_dcache.g_dcache_block[0].block.block_req_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.outputs_o} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_outputs} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_outputs} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_outputs} }
gui_set_radix -radix {decimal} -signals {{V1:tb_dcache.uut0_dcache.g_dcache_block[0].block.startingOffset}}
gui_set_radix -radix {twosComplement} -signals {{V1:tb_dcache.uut0_dcache.g_dcache_block[0].block.startingOffset}}

gui_sg_move "$_session_group_74" -after "$_session_group_73" -pos 4 

set _session_group_75 $_session_group_73|
append _session_group_75 {g_dcache_block[3].block}
gui_sg_create "$_session_group_75"
set {Dcache|g_dcache_block[3].block} "$_session_group_75"

gui_sg_addsignal -group "$_session_group_75" { {tb_dcache.uut0_dcache.g_dcache_block[3].block.$unit} {tb_dcache.uut0_dcache.g_dcache_block[3].block.clk_i} {tb_dcache.uut0_dcache.g_dcache_block[3].block.rst_i} {tb_dcache.uut0_dcache.g_dcache_block[3].block.mem_Valid_FromDte_i} {tb_dcache.uut0_dcache.g_dcache_block[3].block.evictionBuf_clr_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[3].block.evictionBuf_setCommiting_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[3].block.permissionToDriveDataBus_evictionBuf} {tb_dcache.uut0_dcache.g_dcache_block[3].block.permissionToDriveAddrBus_Ld} {tb_dcache.uut0_dcache.g_dcache_block[3].block.permissionToDriveAddrBus_eb} {tb_dcache.uut0_dcache.g_dcache_block[3].block.st_override_for_sch_req} {tb_dcache.uut0_dcache.g_dcache_block[3].block.dataBus} {tb_dcache.uut0_dcache.g_dcache_block[3].block.address_bus} {tb_dcache.uut0_dcache.g_dcache_block[3].block.block_busy} {tb_dcache.uut0_dcache.g_dcache_block[3].block.makeBlockReq} {tb_dcache.uut0_dcache.g_dcache_block[3].block.eb_blockingVCache} {tb_dcache.uut0_dcache.g_dcache_block[3].block.eb_V} {tb_dcache.uut0_dcache.g_dcache_block[3].block.eb_curr_commiting} {tb_dcache.uut0_dcache.g_dcache_block[3].block.eb_blocking_Bank} {tb_dcache.uut0_dcache.g_dcache_block[3].block.address_bus_fake} {tb_dcache.uut0_dcache.g_dcache_block[3].block.startingOffset} {tb_dcache.uut0_dcache.g_dcache_block[3].block.dataBus_fake} {tb_dcache.uut0_dcache.g_dcache_block[3].block.block_req_i} {tb_dcache.uut0_dcache.g_dcache_block[3].block.outputs_o} {tb_dcache.uut0_dcache.g_dcache_block[3].block.dcache_bank_outputs} {tb_dcache.uut0_dcache.g_dcache_block[3].block.vcache_outputs} {tb_dcache.uut0_dcache.g_dcache_block[3].block.eb_outputs} }

gui_sg_move "$_session_group_75" -after "$_session_group_73" -pos 2 

set _session_group_76 $_session_group_73|
append _session_group_76 mio_block_unit
gui_sg_create "$_session_group_76"
set Dcache|mio_block_unit "$_session_group_76"

gui_sg_addsignal -group "$_session_group_76" { {tb_dcache.uut0_dcache.mio_block_unit.$unit} tb_dcache.uut0_dcache.mio_block_unit.clk tb_dcache.uut0_dcache.mio_block_unit.rst tb_dcache.uut0_dcache.mio_block_unit.reqServed_FromDTE_i tb_dcache.uut0_dcache.mio_block_unit.PermissionToDriveAddrBus tb_dcache.uut0_dcache.mio_block_unit.permission2DriveDataBus tb_dcache.uut0_dcache.mio_block_unit.ld_addr_MIO_V tb_dcache.uut0_dcache.mio_block_unit.ld_addr_MIO tb_dcache.uut0_dcache.mio_block_unit.memStalling_FromCore tb_dcache.uut0_dcache.mio_block_unit.address_bus tb_dcache.uut0_dcache.mio_block_unit.dataBus tb_dcache.uut0_dcache.mio_block_unit.block_idle tb_dcache.uut0_dcache.mio_block_unit.readyForNewReq tb_dcache.uut0_dcache.mio_block_unit.data_bus_fake tb_dcache.uut0_dcache.mio_block_unit.WE_ADDR_MASK tb_dcache.uut0_dcache.mio_block_unit.stq_info_mio tb_dcache.uut0_dcache.mio_block_unit.outputs_o tb_dcache.uut0_dcache.mio_block_unit.block_req }
gui_set_radix -radix {decimal} -signals {V1:tb_dcache.uut0_dcache.mio_block_unit.WE_ADDR_MASK}
gui_set_radix -radix {twosComplement} -signals {V1:tb_dcache.uut0_dcache.mio_block_unit.WE_ADDR_MASK}

gui_sg_move "$_session_group_76" -after "$_session_group_73" -pos 1 

set _session_group_77 $_session_group_73|
append _session_group_77 dcache_arbitration
gui_sg_create "$_session_group_77"
set Dcache|dcache_arbitration "$_session_group_77"

gui_sg_addsignal -group "$_session_group_77" { {tb_dcache.uut0_dcache.dcache_arbitration.$unit} tb_dcache.uut0_dcache.dcache_arbitration.clk_i tb_dcache.uut0_dcache.dcache_arbitration.rst tb_dcache.uut0_dcache.dcache_arbitration.block_hit_i tb_dcache.uut0_dcache.dcache_arbitration.req_rejected_0_o tb_dcache.uut0_dcache.dcache_arbitration.req_rejected_1_o tb_dcache.uut0_dcache.dcache_arbitration.st_override_o tb_dcache.uut0_dcache.dcache_arbitration.block_idleness tb_dcache.uut0_dcache.dcache_arbitration.readyForNewReq tb_dcache.uut0_dcache.dcache_arbitration.ld_req_0_bankNum tb_dcache.uut0_dcache.dcache_arbitration.ld_req_1_bankNum tb_dcache.uut0_dcache.dcache_arbitration.st_override tb_dcache.uut0_dcache.dcache_arbitration.ldReq_2_BankPresent tb_dcache.uut0_dcache.dcache_arbitration.LD_REQ_BANK_UB tb_dcache.uut0_dcache.dcache_arbitration.LD_REQ_BANK_LB tb_dcache.uut0_dcache.dcache_arbitration.LD_REQ_BANK_WIDTH tb_dcache.uut0_dcache.dcache_arbitration.core_i tb_dcache.uut0_dcache.dcache_arbitration.reqs_2_blocks_o tb_dcache.uut0_dcache.dcache_arbitration.reqs }
gui_set_radix -radix {decimal} -signals {V1:tb_dcache.uut0_dcache.dcache_arbitration.LD_REQ_BANK_UB}
gui_set_radix -radix {twosComplement} -signals {V1:tb_dcache.uut0_dcache.dcache_arbitration.LD_REQ_BANK_UB}
gui_set_radix -radix {decimal} -signals {V1:tb_dcache.uut0_dcache.dcache_arbitration.LD_REQ_BANK_LB}
gui_set_radix -radix {twosComplement} -signals {V1:tb_dcache.uut0_dcache.dcache_arbitration.LD_REQ_BANK_LB}
gui_set_radix -radix {decimal} -signals {V1:tb_dcache.uut0_dcache.dcache_arbitration.LD_REQ_BANK_WIDTH}
gui_set_radix -radix {twosComplement} -signals {V1:tb_dcache.uut0_dcache.dcache_arbitration.LD_REQ_BANK_WIDTH}

gui_sg_move "$_session_group_77" -after "$_session_group_73" -pos 3 

set _session_group_78 $_session_group_73|
append _session_group_78 {g_dcache_block[1].block}
gui_sg_create "$_session_group_78"
set {Dcache|g_dcache_block[1].block} "$_session_group_78"

gui_sg_addsignal -group "$_session_group_78" { {tb_dcache.uut0_dcache.g_dcache_block[1].block.$unit} {tb_dcache.uut0_dcache.g_dcache_block[1].block.clk_i} {tb_dcache.uut0_dcache.g_dcache_block[1].block.rst_i} {tb_dcache.uut0_dcache.g_dcache_block[1].block.mem_Valid_FromDte_i} {tb_dcache.uut0_dcache.g_dcache_block[1].block.evictionBuf_clr_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[1].block.evictionBuf_setCommiting_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[1].block.permissionToDriveDataBus_evictionBuf} {tb_dcache.uut0_dcache.g_dcache_block[1].block.permissionToDriveAddrBus_Ld} {tb_dcache.uut0_dcache.g_dcache_block[1].block.permissionToDriveAddrBus_eb} {tb_dcache.uut0_dcache.g_dcache_block[1].block.st_override_for_sch_req} {tb_dcache.uut0_dcache.g_dcache_block[1].block.dataBus} {tb_dcache.uut0_dcache.g_dcache_block[1].block.address_bus} {tb_dcache.uut0_dcache.g_dcache_block[1].block.block_busy} {tb_dcache.uut0_dcache.g_dcache_block[1].block.makeBlockReq} {tb_dcache.uut0_dcache.g_dcache_block[1].block.eb_blockingVCache} {tb_dcache.uut0_dcache.g_dcache_block[1].block.eb_V} {tb_dcache.uut0_dcache.g_dcache_block[1].block.eb_curr_commiting} {tb_dcache.uut0_dcache.g_dcache_block[1].block.eb_blocking_Bank} {tb_dcache.uut0_dcache.g_dcache_block[1].block.address_bus_fake} {tb_dcache.uut0_dcache.g_dcache_block[1].block.startingOffset} {tb_dcache.uut0_dcache.g_dcache_block[1].block.dataBus_fake} {tb_dcache.uut0_dcache.g_dcache_block[1].block.block_req_i} {tb_dcache.uut0_dcache.g_dcache_block[1].block.outputs_o} {tb_dcache.uut0_dcache.g_dcache_block[1].block.dcache_bank_outputs} {tb_dcache.uut0_dcache.g_dcache_block[1].block.vcache_outputs} {tb_dcache.uut0_dcache.g_dcache_block[1].block.eb_outputs} }

gui_sg_move "$_session_group_78" -after "$_session_group_73" -pos 6 

set _session_group_79 $_session_group_73|
append _session_group_79 {g_dcache_block[2].block}
gui_sg_create "$_session_group_79"
set {Dcache|g_dcache_block[2].block} "$_session_group_79"

gui_sg_addsignal -group "$_session_group_79" { {tb_dcache.uut0_dcache.g_dcache_block[2].block.$unit} {tb_dcache.uut0_dcache.g_dcache_block[2].block.clk_i} {tb_dcache.uut0_dcache.g_dcache_block[2].block.rst_i} {tb_dcache.uut0_dcache.g_dcache_block[2].block.mem_Valid_FromDte_i} {tb_dcache.uut0_dcache.g_dcache_block[2].block.evictionBuf_clr_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[2].block.evictionBuf_setCommiting_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[2].block.permissionToDriveDataBus_evictionBuf} {tb_dcache.uut0_dcache.g_dcache_block[2].block.permissionToDriveAddrBus_Ld} {tb_dcache.uut0_dcache.g_dcache_block[2].block.permissionToDriveAddrBus_eb} {tb_dcache.uut0_dcache.g_dcache_block[2].block.st_override_for_sch_req} {tb_dcache.uut0_dcache.g_dcache_block[2].block.dataBus} {tb_dcache.uut0_dcache.g_dcache_block[2].block.address_bus} {tb_dcache.uut0_dcache.g_dcache_block[2].block.block_busy} {tb_dcache.uut0_dcache.g_dcache_block[2].block.makeBlockReq} {tb_dcache.uut0_dcache.g_dcache_block[2].block.eb_blockingVCache} {tb_dcache.uut0_dcache.g_dcache_block[2].block.eb_V} {tb_dcache.uut0_dcache.g_dcache_block[2].block.eb_curr_commiting} {tb_dcache.uut0_dcache.g_dcache_block[2].block.eb_blocking_Bank} {tb_dcache.uut0_dcache.g_dcache_block[2].block.address_bus_fake} {tb_dcache.uut0_dcache.g_dcache_block[2].block.startingOffset} {tb_dcache.uut0_dcache.g_dcache_block[2].block.dataBus_fake} {tb_dcache.uut0_dcache.g_dcache_block[2].block.block_req_i} {tb_dcache.uut0_dcache.g_dcache_block[2].block.outputs_o} {tb_dcache.uut0_dcache.g_dcache_block[2].block.dcache_bank_outputs} {tb_dcache.uut0_dcache.g_dcache_block[2].block.vcache_outputs} {tb_dcache.uut0_dcache.g_dcache_block[2].block.eb_outputs} }

gui_sg_move "$_session_group_79" -after "$_session_group_73" -pos 5 

set _session_group_80 $_session_group_73|
append _session_group_80 uut0_dcache
gui_sg_create "$_session_group_80"
set Dcache|uut0_dcache "$_session_group_80"

gui_sg_addsignal -group "$_session_group_80" { {tb_dcache.uut0_dcache.$unit} tb_dcache.uut0_dcache.clk tb_dcache.uut0_dcache.rst tb_dcache.uut0_dcache.dataBus tb_dcache.uut0_dcache.address_bus tb_dcache.uut0_dcache.hitVec tb_dcache.uut0_dcache.arb_st_override_Out tb_dcache.uut0_dcache.arb_req_rejected_0_out tb_dcache.uut0_dcache.arb_req_rejected_1_out tb_dcache.uut0_dcache.inFromCore_i tb_dcache.uut0_dcache.out2Core_o tb_dcache.uut0_dcache.inFromDTE_i tb_dcache.uut0_dcache.out2Sch_o tb_dcache.uut0_dcache.blockOutputs tb_dcache.uut0_dcache.req_2_blocks tb_dcache.uut0_dcache.mio_block_outputs }

set _session_group_81 dcahce_block
gui_sg_create "$_session_group_81"
set dcahce_block "$_session_group_81"

gui_sg_addsignal -group "$_session_group_81" { }

set _session_group_82 $_session_group_81|
append _session_group_82 evictionBuf_unit
gui_sg_create "$_session_group_82"
set dcahce_block|evictionBuf_unit "$_session_group_82"

gui_sg_addsignal -group "$_session_group_82" { {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.$unit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.clk_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.rst_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.eb_clr_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.set_commiting} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.validReq} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.hit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.blockReq_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.vcache_outputs_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.outputs_o} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_unit.eb} }

gui_sg_move "$_session_group_82" -after "$_session_group_81" -pos 2 

set _session_group_83 $_session_group_81|
append _session_group_83 dcache_bank_unit
gui_sg_create "$_session_group_83"
set dcahce_block|dcache_bank_unit "$_session_group_83"

gui_sg_addsignal -group "$_session_group_83" { {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.$unit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.clk} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.rst} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.mem_Valid_FromDte_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.block_busy_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.dataBus} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.dcache_bank_State} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.dcache_bank_State_bits} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.saveReq} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.useSavedReq} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.hit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.miss} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.currTag} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.currLineValid} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.currLineDirty} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.dataStore_Line} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.writeSuccess2TagStore} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.doAccess} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.V_Cache_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.eb_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.blockReq_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.outputs_o} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.fsmOuts} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.dcache_bank_swapBuf} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.savedReq} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.reqInUse} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_unit.blockReq_p_addr_fields} }

gui_sg_move "$_session_group_83" -after "$_session_group_81" -pos 3 

set _session_group_84 $_session_group_81|
append _session_group_84 {g_dcache_block[0].block}
gui_sg_create "$_session_group_84"
set {dcahce_block|g_dcache_block[0].block} "$_session_group_84"

gui_sg_addsignal -group "$_session_group_84" { {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_clr_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.makeBlockReq} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dcache_bank_outputs} {tb_dcache.uut0_dcache.g_dcache_block[0].block.mem_Valid_FromDte_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.address_bus_fake} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_outputs} {tb_dcache.uut0_dcache.g_dcache_block[0].block.block_req_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.address_bus} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_V} {tb_dcache.uut0_dcache.g_dcache_block[0].block.block_busy} {tb_dcache.uut0_dcache.g_dcache_block[0].block.permissionToDriveAddrBus_eb} {tb_dcache.uut0_dcache.g_dcache_block[0].block.startingOffset} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_curr_commiting} {tb_dcache.uut0_dcache.g_dcache_block[0].block.permissionToDriveAddrBus_Ld} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_blockingVCache} {tb_dcache.uut0_dcache.g_dcache_block[0].block.st_override_for_sch_req} {tb_dcache.uut0_dcache.g_dcache_block[0].block.rst_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.evictionBuf_setCommiting_FromDTE_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.outputs_o} {tb_dcache.uut0_dcache.g_dcache_block[0].block.permissionToDriveDataBus_evictionBuf} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dataBus} {tb_dcache.uut0_dcache.g_dcache_block[0].block.$unit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.dataBus_fake} {tb_dcache.uut0_dcache.g_dcache_block[0].block.eb_blocking_Bank} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_outputs} {tb_dcache.uut0_dcache.g_dcache_block[0].block.clk_i} }
gui_set_radix -radix {decimal} -signals {{V1:tb_dcache.uut0_dcache.g_dcache_block[0].block.startingOffset}}
gui_set_radix -radix {twosComplement} -signals {{V1:tb_dcache.uut0_dcache.g_dcache_block[0].block.startingOffset}}

set _session_group_85 $_session_group_81|
append _session_group_85 vcache_unit
gui_sg_create "$_session_group_85"
set dcahce_block|vcache_unit "$_session_group_85"

gui_sg_addsignal -group "$_session_group_85" { {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.$unit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.clk} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.rst} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.block_busy_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_fsm_state} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_fsm_state_bits} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.saveReq} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.useSavedReq} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.saveIDX} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.useSavedIDX} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.currTag} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.hit} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.miss} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.hitIDX} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.evictionIDX} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.savedIDX} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.V_Cache_needs_2_evict} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.V_Cache_TagStore_CurrLine_Dirty} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_dataStore_Line} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.blockReq_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.eb_outs_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.dcache_outs_i} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.outputs_o} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.fsmOuts} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.savedReq} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.reqInUse} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.block_req_p_addr_fields} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit.vcache_swapBuf} }

gui_sg_move "$_session_group_85" -after "$_session_group_81" -pos 1 

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 365000



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
catch {gui_list_select -id ${Hier.1} {{tb_dcache.uut0_dcache.g_dcache_block[0].block}}}
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {tb_dcache.uut0_dcache.g_dcache_block[0].block.vcache_unit}
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
gui_wv_zoom_timerange -id ${Wave.1} 158887 664872
gui_list_add_group -id ${Wave.1} -after {New Group} {uut1_mem}
gui_list_add_group -id ${Wave.1} -after {New Group} {uut2_DTE}
gui_list_add_group -id ${Wave.1} -after {New Group} {Dcache}
gui_list_add_group -id ${Wave.1}  -after Dcache {Dcache|uut0_dcache}
gui_list_add_group -id ${Wave.1} -after Dcache|uut0_dcache {Dcache|mio_block_unit}
gui_list_add_group -id ${Wave.1} -after Dcache|mio_block_unit {{Dcache|g_dcache_block[3].block}}
gui_list_add_group -id ${Wave.1} -after {{Dcache|g_dcache_block[3].block}} {Dcache|dcache_arbitration}
gui_list_add_group -id ${Wave.1} -after Dcache|dcache_arbitration {{Dcache|g_dcache_block[0].block}}
gui_list_add_group -id ${Wave.1} -after {{Dcache|g_dcache_block[0].block}} {{Dcache|g_dcache_block[2].block}}
gui_list_add_group -id ${Wave.1} -after {{Dcache|g_dcache_block[2].block}} {{Dcache|g_dcache_block[1].block}}
gui_list_add_group -id ${Wave.1} -after {New Group} {dcahce_block}
gui_list_add_group -id ${Wave.1}  -after dcahce_block {{dcahce_block|g_dcache_block[0].block}}
gui_list_add_group -id ${Wave.1} -after {{dcahce_block|g_dcache_block[0].block}} {dcahce_block|vcache_unit}
gui_list_add_group -id ${Wave.1} -after dcahce_block|vcache_unit {dcahce_block|evictionBuf_unit}
gui_list_add_group -id ${Wave.1} -after dcahce_block|evictionBuf_unit {dcahce_block|dcache_bank_unit}
gui_list_collapse -id ${Wave.1} uut1_mem
gui_list_collapse -id ${Wave.1} uut2_DTE
gui_list_collapse -id ${Wave.1} {dcahce_block|g_dcache_block[0].block}
gui_list_collapse -id ${Wave.1} dcahce_block|vcache_unit
gui_list_collapse -id ${Wave.1} dcahce_block|evictionBuf_unit
gui_list_collapse -id ${Wave.1} dcahce_block|dcache_bank_unit
gui_list_expand -id ${Wave.1} tb_dcache.uut0_dcache.req_2_blocks
gui_list_expand -id ${Wave.1} {tb_dcache.uut0_dcache.req_2_blocks[0]}
gui_list_select -id ${Wave.1} {{tb_dcache.uut0_dcache.req_2_blocks[0].p_addr} }
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
gui_list_set_insertion_bar  -id ${Wave.1} -group dcahce_block  -position in

gui_marker_move -id ${Wave.1} {C1} 365000
gui_view_scroll -id ${Wave.1} -vertical -set 361
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

