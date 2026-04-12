# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Sun Apr 12 02:53:27 2026
# Designs open: 1
#   V1: vcdplus.vpd
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: tb_dma
#   Wave.1: 230 signals
#   Group count = 12
#   Group tb_dma signal count = 18
#   Group u_BusArb signal count = 16
#   Group u_dcache signal count = 16
#   Group mio_block_unit signal count = 20
#   Group uut_ddr5 signal count = 9
#   Group uut_dma signal count = 21
#   Group diskWrapper_Unit signal count = 11
#   Group scheduler_unit signal count = 17
#   Group u_mainMem signal count = 15
# End_DVE_Session_Save_Info

# DVE version: T-2022.06_Full64
# DVE build date: May 31 2022 20:53:03


#<Session mode="Full" path="/home/ecelrc/students/mak4738/uarch/design_project/design/EverythingEverywhereAllAtOnce/tests/IO/DMA/session.vcdplus.vpd.tcl" type="Debug">

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
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 332]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 332
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 331} {height 468} {dock_state left} {dock_on_new_line true} {child_hier_colhier 232} {child_hier_coltype 100} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 235]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 235
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 267
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 234} {height 468} {dock_state left} {dock_on_new_line true} {child_data_colvariable 140} {child_data_colvalue 100} {child_data_coltype 40} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 105]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 565
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 105
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 1279} {height 105} {dock_state bottom} {dock_on_new_line true}}
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
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 538} {child_wave_right 736} {child_wave_colname 294} {child_wave_colvalue 240} {child_wave_col1 0} {child_wave_col2 1}}

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
gui_load_child_values {tb_dma.u_dcache.mio_block_unit}
gui_load_child_values {tb_dma.u_mainMem.g_mem_banks[0].mem_bank}
gui_load_child_values {tb_dma.u_mainMem.controller}
gui_load_child_values {tb_dma.u_BusArb.scheduler_unit}
gui_load_child_values {tb_dma.u_BusArb}
gui_load_child_values {tb_dma.uut_ddr5}
gui_load_child_values {tb_dma}
gui_load_child_values {tb_dma.u_mainMem}
gui_load_child_values {tb_dma.u_dcache}


set _session_group_125 tb_dma
gui_sg_create "$_session_group_125"
set tb_dma "$_session_group_125"

gui_sg_addsignal -group "$_session_group_125" { {tb_dma.$unit} tb_dma.clk tb_dma.rst tb_dma.dataBus tb_dma.addrBus tb_dma.CLK_PERIOD tb_dma.mem_2_dte tb_dma.dte_2_mem tb_dma.mem_2_sch tb_dma.icache_2_sch tb_dma.dma_2_sch tb_dma.core_2_dcache tb_dma.dcache_2_core tb_dma.dcache_2_sch tb_dma.dte_2_dcache tb_dma.dte_2_dma tb_dma.dma_2_core tb_dma.dte_2_ddr5 }
gui_set_radix -radix {decimal} -signals {V1:tb_dma.CLK_PERIOD}
gui_set_radix -radix {twosComplement} -signals {V1:tb_dma.CLK_PERIOD}

set _session_group_126 u_BusArb
gui_sg_create "$_session_group_126"
set u_BusArb "$_session_group_126"

gui_sg_addsignal -group "$_session_group_126" { {tb_dma.u_BusArb.$unit} tb_dma.u_BusArb.clk tb_dma.u_BusArb.rst tb_dma.u_BusArb.sch_best_pick tb_dma.u_BusArb.sch_best_pick_bk_id tb_dma.u_BusArb.iCache_2_Sch_i tb_dma.u_BusArb.dte_out_2_icache_o tb_dma.u_BusArb.dCache_2_Sch_i tb_dma.u_BusArb.dte_out_2_dcache_o tb_dma.u_BusArb.mem_2_Sch_i tb_dma.u_BusArb.mem_2_dte_i tb_dma.u_BusArb.dte_2_mem_o tb_dma.u_BusArb.dma_2_sch_i tb_dma.u_BusArb.dte_2_dma_o tb_dma.u_BusArb.dte_2_ddr5_o }

set _session_group_127 $_session_group_126|
append _session_group_127 dte_unit
gui_sg_create "$_session_group_127"
set u_BusArb|dte_unit "$_session_group_127"

gui_sg_addsignal -group "$_session_group_127" { {tb_dma.u_BusArb.dte_unit.$unit} tb_dma.u_BusArb.dte_unit.clk tb_dma.u_BusArb.dte_unit.rst tb_dma.u_BusArb.dte_unit.bestPick_i tb_dma.u_BusArb.dte_unit.bestPick_bk_id_i tb_dma.u_BusArb.dte_unit.dte_mem_2_icache_fsm_state tb_dma.u_BusArb.dte_unit.dte_mem_2_dcache_fsm_state tb_dma.u_BusArb.dte_unit.dte_dcache_2_mem_fsm_state tb_dma.u_BusArb.dte_unit.dte_ddr5_2_core_fsm_state tb_dma.u_BusArb.dte_unit.dte_core_2_ddr5_fsm_state tb_dma.u_BusArb.dte_unit.dte_core_2_dma_fsm_state tb_dma.u_BusArb.dte_unit.dte_dma_2_mem_fsm_state tb_dma.u_BusArb.dte_unit.ddr5_2_core_fsmout_busy tb_dma.u_BusArb.dte_unit.core_2_ddr5_fsmout_busy tb_dma.u_BusArb.dte_unit.core_2_dma_fsmout_busy tb_dma.u_BusArb.dte_unit.dma_2_mem_fsmout_busy tb_dma.u_BusArb.dte_unit.mem_2_icache_fsmout_busy tb_dma.u_BusArb.dte_unit.mem_2_dcache_fsmout_busy_per tb_dma.u_BusArb.dte_unit.mem_2_dcache_fsmout_busy tb_dma.u_BusArb.dte_unit.dcache_2_mem_fsmout_busy_per tb_dma.u_BusArb.dte_unit.dcache_2_mem_fsmout_busy tb_dma.u_BusArb.dte_unit.DTE_Busy tb_dma.u_BusArb.dte_unit.mem_2_icache_ld_req_fsmOut tb_dma.u_BusArb.dte_unit.mem_2_dcache_ld_req_fsmOut tb_dma.u_BusArb.dte_unit.mem_2_icache_drv_db_fsmOut tb_dma.u_BusArb.dte_unit.mem_2_dcache_drv_db_fsmOut tb_dma.u_BusArb.dte_unit.dcache_2_mem_st_req_fsmOut tb_dma.u_BusArb.dte_unit.dma_2_mem_st_req_fsmOut tb_dma.u_BusArb.dte_unit.ddr5_2_core_reqServed_fsmOut tb_dma.u_BusArb.dte_unit.core_2_ddr5_reqServed_fsmOut tb_dma.u_BusArb.dte_unit.core_2_dma_reqServed_fsmOut tb_dma.u_BusArb.dte_unit.ddr5_2_core_driveAddrBus_fsmOut tb_dma.u_BusArb.dte_unit.core_2_ddr5_driveAddrBus_fsmOut tb_dma.u_BusArb.dte_unit.core_2_dma_driveAddrBus_fsmOut tb_dma.u_BusArb.dte_unit.core_2_ddr5_drvDB_fsmOut tb_dma.u_BusArb.dte_unit.core_2_dma_drvDB_fsmOut tb_dma.u_BusArb.dte_unit.mem_2_icache_req_hit tb_dma.u_BusArb.dte_unit.mem_2_dcache_req_hit tb_dma.u_BusArb.dte_unit.mem_2_dcache_bk_hit tb_dma.u_BusArb.dte_unit.dcache_2_mem_req_hit tb_dma.u_BusArb.dte_unit.dcache_2_mem_bk_hit tb_dma.u_BusArb.dte_unit.ddr5_2_core_req_hit tb_dma.u_BusArb.dte_unit.core_2_ddr5_req_hit tb_dma.u_BusArb.dte_unit.core_2_dma_req_hit tb_dma.u_BusArb.dte_unit.dma_2_mem_req_hit tb_dma.u_BusArb.dte_unit.dte_mem_2_dcache_fsm_state_bits tb_dma.u_BusArb.dte_unit.dte_dcache_2_mem_fsm_state_bits tb_dma.u_BusArb.dte_unit.dte_out_2_icache_o tb_dma.u_BusArb.dte_unit.dte_out_2_dcache_o tb_dma.u_BusArb.dte_unit.mem_2_dte_i tb_dma.u_BusArb.dte_unit.dte_2_mem_o tb_dma.u_BusArb.dte_unit.dte_2_dma_o tb_dma.u_BusArb.dte_unit.dte_2_ddr5_o }

set _session_group_128 u_dcache
gui_sg_create "$_session_group_128"
set u_dcache "$_session_group_128"

gui_sg_addsignal -group "$_session_group_128" { {tb_dma.u_dcache.$unit} tb_dma.u_dcache.clk tb_dma.u_dcache.rst tb_dma.u_dcache.dataBus tb_dma.u_dcache.address_bus tb_dma.u_dcache.hitVec tb_dma.u_dcache.arb_st_override_Out tb_dma.u_dcache.arb_req_served_0_out tb_dma.u_dcache.arb_req_served_1_out tb_dma.u_dcache.inFromCore_i tb_dma.u_dcache.out2Core_o tb_dma.u_dcache.inFromDTE_i tb_dma.u_dcache.out2Sch_o tb_dma.u_dcache.blockOutputs tb_dma.u_dcache.req_2_blocks tb_dma.u_dcache.mio_block_outputs }

set _session_group_129 mio_block_unit
gui_sg_create "$_session_group_129"
set mio_block_unit "$_session_group_129"

gui_sg_addsignal -group "$_session_group_129" { {tb_dma.u_dcache.mio_block_unit.$unit} tb_dma.u_dcache.mio_block_unit.clk tb_dma.u_dcache.mio_block_unit.rst tb_dma.u_dcache.mio_block_unit.reqServed_FromDTE_i tb_dma.u_dcache.mio_block_unit.PermissionToDriveAddrBus tb_dma.u_dcache.mio_block_unit.permission2DriveDataBus tb_dma.u_dcache.mio_block_unit.ld_addr_MIO_V tb_dma.u_dcache.mio_block_unit.ld_addr_MIO tb_dma.u_dcache.mio_block_unit.memStage_CLR_REQ_MIO tb_dma.u_dcache.mio_block_unit.address_bus tb_dma.u_dcache.mio_block_unit.dataBus tb_dma.u_dcache.mio_block_unit.block_idle tb_dma.u_dcache.mio_block_unit.readyForNewReq tb_dma.u_dcache.mio_block_unit.permission2DriveDataBus_bar tb_dma.u_dcache.mio_block_unit.dataBus_drv tb_dma.u_dcache.mio_block_unit.WE_ADDR_MASK tb_dma.u_dcache.mio_block_unit.stq_info_mio tb_dma.u_dcache.mio_block_unit.outputs_o tb_dma.u_dcache.mio_block_unit.block_req tb_dma.u_dcache.mio_block_unit.next_block_req }
gui_set_radix -radix {decimal} -signals {V1:tb_dma.u_dcache.mio_block_unit.WE_ADDR_MASK}
gui_set_radix -radix {twosComplement} -signals {V1:tb_dma.u_dcache.mio_block_unit.WE_ADDR_MASK}

set _session_group_130 uut_ddr5
gui_sg_create "$_session_group_130"
set uut_ddr5 "$_session_group_130"

gui_sg_addsignal -group "$_session_group_130" { {tb_dma.uut_ddr5.$unit} tb_dma.uut_ddr5.clk tb_dma.uut_ddr5.rst tb_dma.uut_ddr5.dataBus tb_dma.uut_ddr5.addrBus tb_dma.uut_ddr5.tempValue tb_dma.uut_ddr5.powerGate tb_dma.uut_ddr5.dataBus_fake tb_dma.uut_ddr5.inFromDTE_i }

set _session_group_131 uut_dma
gui_sg_create "$_session_group_131"
set uut_dma "$_session_group_131"

gui_sg_addsignal -group "$_session_group_131" { {tb_dma.uut_dma.$unit} tb_dma.uut_dma.clk tb_dma.uut_dma.rst tb_dma.uut_dma.dataBus tb_dma.uut_dma.addrBus tb_dma.uut_dma.fsmState tb_dma.uut_dma.disk_ld_Buffer_V tb_dma.uut_dma.disk_ld_Buffer tb_dma.uut_dma.counter tb_dma.uut_dma.writeBuf tb_dma.uut_dma.writeBuf_addr tb_dma.uut_dma.writeBuf_V tb_dma.uut_dma.writeComplete tb_dma.uut_dma.addrBus_drv tb_dma.uut_dma.dataBus_drv tb_dma.uut_dma.driveDataBus tb_dma.uut_dma.inFromDTE_i tb_dma.uut_dma.out2Core_o tb_dma.uut_dma.out2Sch_o tb_dma.uut_dma.dma_Regs tb_dma.uut_dma.fsmOuts }

set _session_group_132 diskWrapper_Unit
gui_sg_create "$_session_group_132"
set diskWrapper_Unit "$_session_group_132"

gui_sg_addsignal -group "$_session_group_132" { {tb_dma.uut_dma.diskWrapper_Unit.$unit} tb_dma.uut_dma.diskWrapper_Unit.clk tb_dma.uut_dma.diskWrapper_Unit.rst tb_dma.uut_dma.diskWrapper_Unit.ld_write_buf_req tb_dma.uut_dma.diskWrapper_Unit.ld_diskAddr tb_dma.uut_dma.diskWrapper_Unit.ld_num_bytes tb_dma.uut_dma.diskWrapper_Unit.disk_ld_Buffer_V tb_dma.uut_dma.diskWrapper_Unit.disk_ld_Buffer_o tb_dma.uut_dma.diskWrapper_Unit.disk_ld_Buffer tb_dma.uut_dma.diskWrapper_Unit.delayCycles_Counter tb_dma.uut_dma.diskWrapper_Unit.loading }

set _session_group_133 scheduler_unit
gui_sg_create "$_session_group_133"
set scheduler_unit "$_session_group_133"

gui_sg_addsignal -group "$_session_group_133" { tb_dma.u_BusArb.scheduler_unit.IC_MIO_Pick tb_dma.u_BusArb.scheduler_unit.bestPick_o tb_dma.u_BusArb.scheduler_unit.sch_latches tb_dma.u_BusArb.scheduler_unit.dcache_Best_Pick tb_dma.u_BusArb.scheduler_unit.mem_2_Sch_i tb_dma.u_BusArb.scheduler_unit.dma_req tb_dma.u_BusArb.scheduler_unit.iCache_2_Sch_i tb_dma.u_BusArb.scheduler_unit.bestPick_bk_id_o tb_dma.u_BusArb.scheduler_unit.clk tb_dma.u_BusArb.scheduler_unit.dCache_2_Sch_i {tb_dma.u_BusArb.scheduler_unit.$unit} tb_dma.u_BusArb.scheduler_unit.IC_MIO_DMA_PICK tb_dma.u_BusArb.scheduler_unit.dma_2_sch_i tb_dma.u_BusArb.scheduler_unit.bestPick tb_dma.u_BusArb.scheduler_unit.dma_req_clashing tb_dma.u_BusArb.scheduler_unit.dcache_Best_Pick_BK_ID tb_dma.u_BusArb.scheduler_unit.rst }

set _session_group_134 u_mainMem
gui_sg_create "$_session_group_134"
set u_mainMem "$_session_group_134"

gui_sg_addsignal -group "$_session_group_134" { tb_dma.u_mainMem.inFromDte tb_dma.u_mainMem.rst tb_dma.u_mainMem.clk tb_dma.u_mainMem.bank_out_2_controller tb_dma.u_mainMem.controller_2_bank_Cmds tb_dma.u_mainMem.data_bus tb_dma.u_mainMem.address_bus tb_dma.u_mainMem.out2Sch tb_dma.u_mainMem.out2Dte tb_dma.u_mainMem.mem_bus {tb_dma.u_mainMem.$unit} tb_dma.u_mainMem.drive_Data_Bus tb_dma.u_mainMem.dataToDrive }

set _session_group_135 $_session_group_134|
append _session_group_135 controller
gui_sg_create "$_session_group_135"
set u_mainMem|controller "$_session_group_135"

gui_sg_addsignal -group "$_session_group_135" { {tb_dma.u_mainMem.controller.$unit} tb_dma.u_mainMem.controller.clk tb_dma.u_mainMem.controller.rst tb_dma.u_mainMem.controller.address_bus tb_dma.u_mainMem.controller.data_bus tb_dma.u_mainMem.controller.mem_controller_state_bits tb_dma.u_mainMem.controller.fsm_state tb_dma.u_mainMem.controller.hit_into_fsm tb_dma.u_mainMem.controller.chipNum tb_dma.u_mainMem.controller.bankBits_InChip tb_dma.u_mainMem.controller.rowBitFromChipAddress tb_dma.u_mainMem.controller.bank_num_for_chip tb_dma.u_mainMem.controller.bankGroup tb_dma.u_mainMem.controller.DTE_i tb_dma.u_mainMem.controller.ToDTE_o tb_dma.u_mainMem.controller.ToScheduler_o tb_dma.u_mainMem.controller.bank_cmds_o tb_dma.u_mainMem.controller.banks_i tb_dma.u_mainMem.controller.bankGroupTable tb_dma.u_mainMem.controller.chipTable tb_dma.u_mainMem.controller.fsm_outs }

set _session_group_136 $_session_group_134|
append _session_group_136 {g_mem_banks[0].mem_bank}
gui_sg_create "$_session_group_136"
set {u_mainMem|g_mem_banks[0].mem_bank} "$_session_group_136"

gui_sg_addsignal -group "$_session_group_136" { {tb_dma.u_mainMem.g_mem_banks[0].mem_bank.$unit} {tb_dma.u_mainMem.g_mem_banks[0].mem_bank.clk} {tb_dma.u_mainMem.g_mem_banks[0].mem_bank.rst} {tb_dma.u_mainMem.g_mem_banks[0].mem_bank.mem_bus} {tb_dma.u_mainMem.g_mem_banks[0].mem_bank.mem_bank_controller_oe} {tb_dma.u_mainMem.g_mem_banks[0].mem_bank.mem_bank_controller_we} {tb_dma.u_mainMem.g_mem_banks[0].mem_bank.mem_bank_controller_send_store_address} {tb_dma.u_mainMem.g_mem_banks[0].mem_bank.mem_bank_controller_send_store_address_delayed} {tb_dma.u_mainMem.g_mem_banks[0].mem_bank.mem_bank_controller_states_bits} {tb_dma.u_mainMem.g_mem_banks[0].mem_bank.fsm_state} {tb_dma.u_mainMem.g_mem_banks[0].mem_bank.bank_address_i} {tb_dma.u_mainMem.g_mem_banks[0].mem_bank.bank_bus} {tb_dma.u_mainMem.g_mem_banks[0].mem_bank.bank_write_data} {tb_dma.u_mainMem.g_mem_banks[0].mem_bank.NUM_SRAM_CELLS} {tb_dma.u_mainMem.g_mem_banks[0].mem_bank.controller2bank_i} {tb_dma.u_mainMem.g_mem_banks[0].mem_bank.outputs} }
gui_set_radix -radix {decimal} -signals {{V1:tb_dma.u_mainMem.g_mem_banks[0].mem_bank.NUM_SRAM_CELLS}}
gui_set_radix -radix {twosComplement} -signals {{V1:tb_dma.u_mainMem.g_mem_banks[0].mem_bank.NUM_SRAM_CELLS}}

gui_sg_move "$_session_group_136" -after "$_session_group_134" -pos 1 

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 1084000



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
catch {gui_list_expand -id ${Hier.1} tb_dma}
catch {gui_list_select -id ${Hier.1} {tb_dma.u_mainMem}}
gui_view_scroll -id ${Hier.1} -vertical -set 60
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {tb_dma.u_mainMem.g_mem_banks[0].mem_bank}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 60
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active tb_dma tb_dma.sv
gui_view_scroll -id ${Source.1} -vertical -set 30
gui_src_set_reusable -id ${Source.1}

# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_create -id ${Wave.1} M1 380000
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 134518 166980
gui_list_add_group -id ${Wave.1} -after {New Group} {u_mainMem}
gui_list_add_group -id ${Wave.1}  -after u_mainMem {u_mainMem|controller}
gui_list_add_group -id ${Wave.1} -after u_mainMem|controller {{u_mainMem|g_mem_banks[0].mem_bank}}
gui_list_add_group -id ${Wave.1} -after {New Group} {tb_dma}
gui_list_add_group -id ${Wave.1} -after {New Group} {u_BusArb}
gui_list_add_group -id ${Wave.1}  -after u_BusArb {u_BusArb|dte_unit}
gui_list_add_group -id ${Wave.1} -after {New Group} {u_dcache}
gui_list_add_group -id ${Wave.1} -after {New Group} {mio_block_unit}
gui_list_add_group -id ${Wave.1} -after {New Group} {uut_ddr5}
gui_list_add_group -id ${Wave.1} -after {New Group} {uut_dma}
gui_list_add_group -id ${Wave.1} -after {New Group} {diskWrapper_Unit}
gui_list_add_group -id ${Wave.1} -after {New Group} {scheduler_unit}
gui_list_collapse -id ${Wave.1} u_mainMem|controller
gui_list_collapse -id ${Wave.1} tb_dma
gui_list_collapse -id ${Wave.1} u_BusArb
gui_list_collapse -id ${Wave.1} u_BusArb|dte_unit
gui_list_collapse -id ${Wave.1} u_dcache
gui_list_collapse -id ${Wave.1} mio_block_unit
gui_list_collapse -id ${Wave.1} uut_ddr5
gui_list_collapse -id ${Wave.1} uut_dma
gui_list_collapse -id ${Wave.1} diskWrapper_Unit
gui_list_collapse -id ${Wave.1} scheduler_unit
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
gui_list_set_insertion_bar  -id ${Wave.1} -group u_mainMem  -item {tb_dma.u_mainMem.dataToDrive[31:0]} -position below

gui_marker_move -id ${Wave.1} {C1} 1084000
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

