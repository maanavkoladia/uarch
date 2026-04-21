# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Sun Apr 19 18:55:41 2026
# Designs open: 1
#   V1: vcdplus.vpd
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel
#   Wave.1: 1028 signals
#   Group count = 75
#   Group uut_AllAtOnce signal count = 9
#   Group uut_AllAtOnce_1 signal count = 9
#   Group Mem_System signal count = 26
#   Group flags_reg signal count = 3
#   Group uut_stuff signal count = 7
#   Group Core signal count = 1
#   Group latches signal count = 3
#   Group stages signal count = 3
# End_DVE_Session_Save_Info

# DVE version: T-2022.06_Full64
# DVE build date: May 31 2022 20:53:03


#<Session mode="Full" path="/home/ecelrc/students/je28497/uarch/design/EverythingEverywhereAllAtOnce/tests/Stages/Harish_StageTesting/jacob_save.tcl" type="Debug">

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
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 436]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 436
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 435} {height 514} {dock_state left} {dock_on_new_line true} {child_hier_colhier 335} {child_hier_coltype 107} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 501]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 501
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 517
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 500} {height 514} {dock_state left} {dock_on_new_line true} {child_data_colvariable 279} {child_data_colvalue 57} {child_data_coltype 171} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 174]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value -1
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 174
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


# Create and position top-level window: TopLevel.2

if {![gui_exist_window -window TopLevel.2]} {
    set TopLevel.2 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.2 TopLevel.2
}
gui_show_window -window ${TopLevel.2} -show_state maximized -rect {{0 23} {1279 671}}

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
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 443} {child_wave_right 831} {child_wave_colname 254} {child_wave_colvalue 185} {child_wave_col1 0} {child_wave_col2 1}}

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
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_imm}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op}
gui_load_child_values {tb_stages.uut_AllAtOnce}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_logic}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.rr_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_imm_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.dc_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_far_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pop_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_call_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.idm_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_df_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.write_back_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit}


set _session_group_388 uut_AllAtOnce
gui_sg_create "$_session_group_388"
set uut_AllAtOnce "$_session_group_388"

gui_sg_addsignal -group "$_session_group_388" { {tb_stages.uut_AllAtOnce.$unit} tb_stages.uut_AllAtOnce.clk tb_stages.uut_AllAtOnce.rst tb_stages.uut_AllAtOnce.icache2core tb_stages.uut_AllAtOnce.core2icache tb_stages.uut_AllAtOnce.stq2dcache tb_stages.uut_AllAtOnce.core2dcache tb_stages.uut_AllAtOnce.dcache2core tb_stages.uut_AllAtOnce.dma2core }

set _session_group_389 uut_AllAtOnce_1
gui_sg_create "$_session_group_389"
set uut_AllAtOnce_1 "$_session_group_389"

gui_sg_addsignal -group "$_session_group_389" { tb_stages.uut_AllAtOnce.stq2dcache tb_stages.uut_AllAtOnce.icache2core tb_stages.uut_AllAtOnce.core2dcache tb_stages.uut_AllAtOnce.clk tb_stages.uut_AllAtOnce.core2icache tb_stages.uut_AllAtOnce.dma2core tb_stages.uut_AllAtOnce.dcache2core {tb_stages.uut_AllAtOnce.$unit} tb_stages.uut_AllAtOnce.rst }

set _session_group_390 Mem_System
gui_sg_create "$_session_group_390"
set Mem_System "$_session_group_390"

gui_sg_addsignal -group "$_session_group_390" { {tb_stages.uut_AllAtOnce.mem_sys_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.addressBus tb_stages.uut_AllAtOnce.mem_sys_unit.core2icache_i tb_stages.uut_AllAtOnce.mem_sys_unit.icache2core_o tb_stages.uut_AllAtOnce.mem_sys_unit.core2dcache_i tb_stages.uut_AllAtOnce.mem_sys_unit.dcache2core_o tb_stages.uut_AllAtOnce.mem_sys_unit.dma2core_o tb_stages.uut_AllAtOnce.mem_sys_unit.icache_2_sched tb_stages.uut_AllAtOnce.mem_sys_unit.dte_2_icache tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_2_sched tb_stages.uut_AllAtOnce.mem_sys_unit.dte_2_dcache tb_stages.uut_AllAtOnce.mem_sys_unit.mem_2_sched tb_stages.uut_AllAtOnce.mem_sys_unit.mem_2_dte tb_stages.uut_AllAtOnce.mem_sys_unit.dte_2_mem tb_stages.uut_AllAtOnce.mem_sys_unit.dma_2_sched tb_stages.uut_AllAtOnce.mem_sys_unit.dte_2_dma tb_stages.uut_AllAtOnce.mem_sys_unit.dte_2_ddr5 }

set _session_group_391 $_session_group_390|
append _session_group_391 bus_arbitration_unit
gui_sg_create "$_session_group_391"
set Mem_System|bus_arbitration_unit "$_session_group_391"

gui_sg_addsignal -group "$_session_group_391" { {tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.sch_best_pick tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.sch_best_pick_bk_id tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.iCache_2_Sch_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_out_2_icache_o tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dCache_2_Sch_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_out_2_dcache_o tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.mem_2_Sch_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.mem_2_dte_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_2_mem_o tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dma_2_sch_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_2_dma_o tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_2_ddr5_o }

gui_sg_move "$_session_group_391" -after "$_session_group_390" -pos 5 

set _session_group_392 $_session_group_390|
append _session_group_392 dcache_unit
gui_sg_create "$_session_group_392"
set Mem_System|dcache_unit "$_session_group_392"

gui_sg_addsignal -group "$_session_group_392" { {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.address_bus tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.hitVec tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.arb_st_override_Out tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.arb_req_served_0_out tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.arb_req_served_1_out tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.inFromCore_i tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.out2Core_o tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.inFromDTE_i tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.out2Sch_o tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.blockOutputs tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.req_2_blocks tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.mio_block_outputs }

gui_sg_move "$_session_group_392" -after "$_session_group_390" -pos 4 

set _session_group_393 $_session_group_390|
append _session_group_393 ddr5_unit
gui_sg_create "$_session_group_393"
set Mem_System|ddr5_unit "$_session_group_393"

gui_sg_addsignal -group "$_session_group_393" { {tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.addrBus tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.tempValue tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.powerGate tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.dataBus_fake tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.inFromDTE_i }

gui_sg_move "$_session_group_393" -after "$_session_group_390" -pos 3 

set _session_group_394 $_session_group_390|
append _session_group_394 dma_controller_unit
gui_sg_create "$_session_group_394"
set Mem_System|dma_controller_unit "$_session_group_394"

gui_sg_addsignal -group "$_session_group_394" { {tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.addrBus tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.fsmState tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.fsmState_bits tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.commiting tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.disk_ld_Buffer_V tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.disk_ld_Buffer tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.counter tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.writeBuf tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.writeBuf_addr tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.writeBuf_V tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.writeComplete tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.write2_srcAddr_req tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.write2_destAddr_req tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.write2_numBytes_req tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.write2_startWrite_req tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.addrBus_drv tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.dataBus_drv tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.driveDataBus tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.inFromDTE_i tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.out2Core_o tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.out2Sch_o tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.dma_Regs tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.fsmOuts }

gui_sg_move "$_session_group_394" -after "$_session_group_390" -pos 2 

set _session_group_395 $_session_group_390|
append _session_group_395 icache_unit
gui_sg_create "$_session_group_395"
set Mem_System|icache_unit "$_session_group_395"

gui_sg_addsignal -group "$_session_group_395" { {tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.addrBus tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.controller_fsmState tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.controller_fsmState_bits tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataLines tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_tag tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_tag_V tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_hit tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_miss tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_hit tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_miss tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_swapBuf_V_Clr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_dataLines tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.saved_pAddr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.saved_vAddr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.curr_v_addr_to_use tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.useSaved_v_Addr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.save_v_addr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.addrBus_drv tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.inFromCore_i tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.out2Core_o tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.inFromDte_i tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.out2Sch_o tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.fsmOuts tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_swapbuf tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_swapBuf }

gui_sg_move "$_session_group_395" -after "$_session_group_390" -pos 1 

set _session_group_396 $_session_group_390|
append _session_group_396 mem_unit_1
gui_sg_create "$_session_group_396"
set Mem_System|mem_unit_1 "$_session_group_396"

gui_sg_addsignal -group "$_session_group_396" { {tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.address_bus tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.data_bus tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.mem_bus tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.drive_Data_Bus tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.dataToDrive tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.inFromDte tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.out2Dte tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.out2Sch tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.controller_2_bank_Cmds tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.bank_out_2_controller }

set _session_group_397 flags_reg
gui_sg_create "$_session_group_397"
set flags_reg "$_session_group_397"

gui_sg_addsignal -group "$_session_group_397" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.flags_reg }

set _session_group_398 $_session_group_397|
append _session_group_398 reg_sb_unit
gui_sg_create "$_session_group_398"
set flags_reg|reg_sb_unit "$_session_group_398"

gui_sg_addsignal -group "$_session_group_398" { tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_dr_rd tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sr_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.flush tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr1_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_sr_wr tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.dep_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.dr_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.ecx_sb tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr0_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_dr_wr tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sr_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr1_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.depStall_Internal tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.Segment0_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.seg0_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_wr_to_both tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.Segment1_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_idx_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.codeSeg_sb tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.farFlush tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_wr_to_both tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_eax_rd tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_base_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.updateSB tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.instructionforward tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_base_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_idx_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_eax_wr tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.eax_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.clk tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.seg1_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_sr_rd {tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.dr_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.SCORE_BOARD tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.Segment1_valid tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr0_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_sib_size tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.rst }

gui_sg_move "$_session_group_398" -after "$_session_group_397" -pos 1 

set _session_group_399 $_session_group_397|
append _session_group_399 RegisterFile_unit
gui_sg_create "$_session_group_399"
set flags_reg|RegisterFile_unit "$_session_group_399"

gui_sg_addsignal -group "$_session_group_399" { tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.SR_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR1_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR0_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.DR_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR0_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR1_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.Segment0_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.wb_wr_to_both tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.Segment1_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.SIB_BASE_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.outputs tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.SIB_IDX_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.REGISTERS tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.clk tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR1_data {tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR0_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.rst }

gui_sg_move "$_session_group_399" -after "$_session_group_397" -pos 2 

set _session_group_400 uut_stuff
gui_sg_create "$_session_group_400"
set uut_stuff "$_session_group_400"

gui_sg_addsignal -group "$_session_group_400" { tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches.EIP tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches.valid tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches.data_size_vec tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches.cs.OP_TYPE tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches }

set _session_group_401 $_session_group_400|
append _session_group_401 u_mov_op
gui_sg_create "$_session_group_401"
set uut_stuff|u_mov_op "$_session_group_401"

gui_sg_addsignal -group "$_session_group_401" { {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.curr_cf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.masked_data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.merged_res }

gui_sg_move "$_session_group_401" -after "$_session_group_400" -pos 5 

set _session_group_402 $_session_group_400|
append _session_group_402 u_sbb_op
gui_sg_create "$_session_group_402"
set uut_stuff|u_sbb_op "$_session_group_402"

gui_sg_addsignal -group "$_session_group_402" { {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.CF_in tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.al_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.ah_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.ax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.eax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.result }

gui_sg_move "$_session_group_402" -after "$_session_group_400" -pos 6 

set _session_group_403 Core
gui_sg_create "$_session_group_403"
set Core "$_session_group_403"

gui_sg_addsignal -group "$_session_group_403" { }

set _session_group_404 $_session_group_403|
append _session_group_404 core_unit
gui_sg_create "$_session_group_404"
set Core|core_unit "$_session_group_404"

gui_sg_addsignal -group "$_session_group_404" { tb_stages.uut_AllAtOnce.core_unit.mem_latches tb_stages.uut_AllAtOnce.core_unit.wb_latches_next tb_stages.uut_AllAtOnce.core_unit.DCacheIn_i tb_stages.uut_AllAtOnce.core_unit.inFromDMA_i tb_stages.uut_AllAtOnce.core_unit.dc_outputs tb_stages.uut_AllAtOnce.core_unit.mem_latches_next tb_stages.uut_AllAtOnce.core_unit.mem_outputs tb_stages.uut_AllAtOnce.core_unit.dc_latches_next tb_stages.uut_AllAtOnce.core_unit.wb_latches tb_stages.uut_AllAtOnce.core_unit.rr_latches_next tb_stages.uut_AllAtOnce.core_unit.rr_latches tb_stages.uut_AllAtOnce.core_unit.exe_latches tb_stages.uut_AllAtOnce.core_unit.idm_outputs tb_stages.uut_AllAtOnce.core_unit.fetch_outputs tb_stages.uut_AllAtOnce.core_unit.clk tb_stages.uut_AllAtOnce.core_unit.wb_outputs tb_stages.uut_AllAtOnce.core_unit.decode_outputs tb_stages.uut_AllAtOnce.core_unit.rr_outputs tb_stages.uut_AllAtOnce.core_unit.exe_latches_next tb_stages.uut_AllAtOnce.core_unit.out2DCache_o tb_stages.uut_AllAtOnce.core_unit.exe_outputs {tb_stages.uut_AllAtOnce.core_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_latches tb_stages.uut_AllAtOnce.core_unit.ICacheIn_i tb_stages.uut_AllAtOnce.core_unit.out2ICache_o tb_stages.uut_AllAtOnce.core_unit.rst }

set _session_group_405 latches
gui_sg_create "$_session_group_405"
set latches "$_session_group_405"

gui_sg_addsignal -group "$_session_group_405" { }

set _session_group_406 $_session_group_405|
append _session_group_406 idm_unit
gui_sg_create "$_session_group_406"
set latches|idm_unit "$_session_group_406"

gui_sg_addsignal -group "$_session_group_406" { tb_stages.uut_AllAtOnce.core_unit.idm_unit.fetch_outs_i tb_stages.uut_AllAtOnce.core_unit.idm_unit.idm_outs_o tb_stages.uut_AllAtOnce.core_unit.idm_unit.clk tb_stages.uut_AllAtOnce.core_unit.idm_unit.idm {tb_stages.uut_AllAtOnce.core_unit.idm_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.idm_unit.rst }

set _session_group_407 $_session_group_405|
append _session_group_407 rr_latches_unit
gui_sg_create "$_session_group_407"
set latches|rr_latches_unit "$_session_group_407"

gui_sg_addsignal -group "$_session_group_407" { tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.flush tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.latches tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.farFlush tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.write_enable_i {tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.rst }

gui_sg_move "$_session_group_407" -after "$_session_group_405" -pos 1 

set _session_group_408 $_session_group_405|
append _session_group_408 dc_latches_unit
gui_sg_create "$_session_group_408"
set latches|dc_latches_unit "$_session_group_408"

gui_sg_addsignal -group "$_session_group_408" { tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.flush tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.latches tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.farFlush tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.write_enable_i {tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.rst }

set _session_group_409 $_session_group_405|
append _session_group_409 mem_latches_unit
gui_sg_create "$_session_group_409"
set latches|mem_latches_unit "$_session_group_409"

gui_sg_addsignal -group "$_session_group_409" { tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.flush tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.latches tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.farFlush tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.write_enable_i {tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.rst }

set _session_group_410 $_session_group_405|
append _session_group_410 exe_latches_unit
gui_sg_create "$_session_group_410"
set latches|exe_latches_unit "$_session_group_410"

gui_sg_addsignal -group "$_session_group_410" { tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.flush tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.write_enable_i {tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.rst }

gui_sg_move "$_session_group_410" -after "$_session_group_405" -pos 2 

set _session_group_411 $_session_group_405|
append _session_group_411 wb_latches_unit
gui_sg_create "$_session_group_411"
set latches|wb_latches_unit "$_session_group_411"

gui_sg_addsignal -group "$_session_group_411" { tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.latches tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.write_enable_i {tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.rst }

set _session_group_412 stages
gui_sg_create "$_session_group_412"
set stages "$_session_group_412"

gui_sg_addsignal -group "$_session_group_412" { }

set _session_group_413 $_session_group_412|
append _session_group_413 idm_unit
gui_sg_create "$_session_group_413"
set stages|idm_unit "$_session_group_413"

gui_sg_addsignal -group "$_session_group_413" { tb_stages.uut_AllAtOnce.core_unit.idm_unit.fetch_outs_i tb_stages.uut_AllAtOnce.core_unit.idm_unit.idm_outs_o tb_stages.uut_AllAtOnce.core_unit.idm_unit.clk tb_stages.uut_AllAtOnce.core_unit.idm_unit.idm {tb_stages.uut_AllAtOnce.core_unit.idm_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.idm_unit.rst }

set _session_group_414 $_session_group_412|
append _session_group_414 rr_unit
gui_sg_create "$_session_group_414"
set stages|rr_unit "$_session_group_414"

gui_sg_addsignal -group "$_session_group_414" { tb_stages.uut_AllAtOnce.core_unit.rr_unit.fetch_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.next_ld_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.cs_sb tb_stages.uut_AllAtOnce.core_unit.rr_unit.RR_GP tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_input_addy tb_stages.uut_AllAtOnce.core_unit.rr_unit.ecx_sb tb_stages.uut_AllAtOnce.core_unit.rr_unit.ld_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.next_dc_valid tb_stages.uut_AllAtOnce.core_unit.rr_unit.latches_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.dc_latches_next tb_stages.uut_AllAtOnce.core_unit.rr_unit.seg0_limit_w_datasize tb_stages.uut_AllAtOnce.core_unit.rr_unit.seg1_limit_w_datasize tb_stages.uut_AllAtOnce.core_unit.rr_unit.latchesInUse tb_stages.uut_AllAtOnce.core_unit.rr_unit.SEGMENT_LIMITS tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_out tb_stages.uut_AllAtOnce.core_unit.rr_unit.instructionforward tb_stages.uut_AllAtOnce.core_unit.rr_unit.rr_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.dc_latches_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.dc_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.exe_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.outs_o tb_stages.uut_AllAtOnce.core_unit.rr_unit.clk tb_stages.uut_AllAtOnce.core_unit.rr_unit.wb_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.mem_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.depstall {tb_stages.uut_AllAtOnce.core_unit.rr_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.rr_unit.actual_st_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.rst tb_stages.uut_AllAtOnce.core_unit.rr_unit.decode_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.actual_next_st_vaddy }

set _session_group_415 $_session_group_412|
append _session_group_415 dc_unit
gui_sg_create "$_session_group_415"
set stages|dc_unit "$_session_group_415"

gui_sg_addsignal -group "$_session_group_415" { tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_out tb_stages.uut_AllAtOnce.core_unit.dc_unit.fetch_outs_i tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_latches_next_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_mio_V tb_stages.uut_AllAtOnce.core_unit.dc_unit.dep_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.rr_exception tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_served_0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_served_1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_ST_OP tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_stage_we_valid_unit_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.data_size_vec tb_stages.uut_AllAtOnce.core_unit.dc_unit.exp_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_mio tb_stages.uut_AllAtOnce.core_unit.dc_unit.latches_i tb_stages.uut_AllAtOnce.core_unit.dc_unit.sr_data_size_vec tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_0_V tb_stages.uut_AllAtOnce.core_unit.dc_unit.shift_sr_up tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_stage_next_vaild_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_exception tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_out tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_1_V tb_stages.uut_AllAtOnce.core_unit.dc_unit.dc_ST_OP tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.in_flight_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.exe_outs_i tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_served_mio tb_stages.uut_AllAtOnce.core_unit.dc_unit.arb_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.clk tb_stages.uut_AllAtOnce.core_unit.dc_unit.dc_outs_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.wb_outs_i tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_outs_i tb_stages.uut_AllAtOnce.core_unit.dc_unit.shift_sr_down tb_stages.uut_AllAtOnce.core_unit.dc_unit.dc_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.exe_ST_OP tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_exception {tb_stages.uut_AllAtOnce.core_unit.dc_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_unit.next_st_addr_0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.next_st_xcl tb_stages.uut_AllAtOnce.core_unit.dc_unit.next_st_addr_1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.wb_ST_OP tb_stages.uut_AllAtOnce.core_unit.dc_unit.rst }

set _session_group_416 $_session_group_412|
append _session_group_416 mem_unit
gui_sg_create "$_session_group_416"
set stages|mem_unit "$_session_group_416"

gui_sg_addsignal -group "$_session_group_416" { tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_buf_v tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_1_masked tb_stages.uut_AllAtOnce.core_unit.mem_unit.C0 tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_buf_mio tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_MIO tb_stages.uut_AllAtOnce.core_unit.mem_unit.low_buf tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_0 tb_stages.uut_AllAtOnce.core_unit.mem_unit.br_rel_target tb_stages.uut_AllAtOnce.core_unit.mem_unit.latches_i tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_1 tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_buf_mio_v tb_stages.uut_AllAtOnce.core_unit.mem_unit.miss_stall tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_MIO tb_stages.uut_AllAtOnce.core_unit.mem_unit.cacheline tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_0_masked tb_stages.uut_AllAtOnce.core_unit.mem_unit.clr_dcache_mio_latch tb_stages.uut_AllAtOnce.core_unit.mem_unit.exe_latches_next_o tb_stages.uut_AllAtOnce.core_unit.mem_unit.forward_valid tb_stages.uut_AllAtOnce.core_unit.mem_unit.exe_stage_next_vaild_o tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_buf tb_stages.uut_AllAtOnce.core_unit.mem_unit.exe_outs_i tb_stages.uut_AllAtOnce.core_unit.mem_unit.outs_o tb_stages.uut_AllAtOnce.core_unit.mem_unit.clk tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_mio tb_stages.uut_AllAtOnce.core_unit.mem_unit.bank_num_0 tb_stages.uut_AllAtOnce.core_unit.mem_unit.wb_outs_i tb_stages.uut_AllAtOnce.core_unit.mem_unit.rel_offset tb_stages.uut_AllAtOnce.core_unit.mem_unit.bank_num_1 tb_stages.uut_AllAtOnce.core_unit.mem_unit.ld_buf tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit tb_stages.uut_AllAtOnce.core_unit.mem_unit.up_buf tb_stages.uut_AllAtOnce.core_unit.mem_unit.exe_stage_we_valid_unit_o {tb_stages.uut_AllAtOnce.core_unit.mem_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.mem_unit.clr_dcache_arb_latches tb_stages.uut_AllAtOnce.core_unit.mem_unit.next_st_addr_0 tb_stages.uut_AllAtOnce.core_unit.mem_unit.next_st_addr_1 tb_stages.uut_AllAtOnce.core_unit.mem_unit.rst }

gui_sg_move "$_session_group_416" -after "$_session_group_412" -pos 1 

set _session_group_417 $_session_group_412|
append _session_group_417 execute_unit
gui_sg_create "$_session_group_417"
set stages|execute_unit "$_session_group_417"

gui_sg_addsignal -group "$_session_group_417" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.latches_i.EIP tb_stages.uut_AllAtOnce.core_unit.execute_unit.rst tb_stages.uut_AllAtOnce.core_unit.execute_unit.clk tb_stages.uut_AllAtOnce.core_unit.execute_unit.latches_i.valid tb_stages.uut_AllAtOnce.core_unit.execute_unit.latches_i.cs.OP_TYPE tb_stages.uut_AllAtOnce.core_unit.execute_unit.outs_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_outs_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.latches_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.flags_reg tb_stages.uut_AllAtOnce.core_unit.execute_unit.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.dr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.sr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.eax_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.flush_mask tb_stages.uut_AllAtOnce.core_unit.execute_unit.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.sr_data_size_vec tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_latches_next_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.dr_next tb_stages.uut_AllAtOnce.core_unit.execute_unit.res_buf_next tb_stages.uut_AllAtOnce.core_unit.execute_unit.res_buf_selected tb_stages.uut_AllAtOnce.core_unit.execute_unit.next_wb_cs tb_stages.uut_AllAtOnce.core_unit.execute_unit.bit_vec_0_next tb_stages.uut_AllAtOnce.core_unit.execute_unit.bit_vec_1_next tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_stage_we_valid_unit_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.branch_resolution_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.df_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.af_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.pf_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.cf_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.sf_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.of_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.zf_flag_o }

gui_sg_move "$_session_group_417" -after "$_session_group_412" -pos 2 

set _session_group_418 $_session_group_417|
append _session_group_418 wb_valid_logic_unit
gui_sg_create "$_session_group_418"
set stages|execute_unit|wb_valid_logic_unit "$_session_group_418"

gui_sg_addsignal -group "$_session_group_418" { {tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.WB_we_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.N_WB_V_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.EXE_V_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.WB_stall_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.WB_stall_i_inv tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.WB_we_o_and_buf_mid tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.N_WB_V_o_and_buf_mid }

set _session_group_419 $_session_group_417|
append _session_group_419 u_zf_flag_sel
gui_sg_create "$_session_group_419"
set stages|execute_unit|u_zf_flag_sel "$_session_group_419"

gui_sg_addsignal -group "$_session_group_419" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.adc_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.add_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.and_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.bsf_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.cmp_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.cmpxchg_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.or_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.sal_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.sar_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.sbb_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.iretd_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.curr_zf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.zf_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.clr_ZF_sb }

gui_sg_move "$_session_group_419" -after "$_session_group_417" -pos 1 

set _session_group_420 $_session_group_417|
append _session_group_420 u_xchg_op
gui_sg_create "$_session_group_420"
set stages|execute_unit|u_xchg_op "$_session_group_420"

gui_sg_addsignal -group "$_session_group_420" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.sr_data_size_vec tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.sr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.new_rm_value tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.new_r32_val tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.new_rm_low_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.new_rm_upper_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.new_r32_low_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.new_r32_upper_sel }

gui_sg_move "$_session_group_420" -after "$_session_group_417" -pos 2 

set _session_group_421 $_session_group_417|
append _session_group_421 u_sr_sel
gui_sg_create "$_session_group_421"
set stages|execute_unit|u_sr_sel "$_session_group_421"

gui_sg_addsignal -group "$_session_group_421" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.sr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.pop_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.push_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.ret_far_imm_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.ret_imm_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.ret_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.xchg_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.call_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.far_call_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.sr_o }

gui_sg_move "$_session_group_421" -after "$_session_group_417" -pos 3 

set _session_group_422 $_session_group_417|
append _session_group_422 u_sf_flag_sel
gui_sg_create "$_session_group_422"
set stages|execute_unit|u_sf_flag_sel "$_session_group_422"

gui_sg_addsignal -group "$_session_group_422" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.add_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.adc_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.and_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.cmp_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.cmpxchg_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.or_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.sal_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.sar_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.sbb_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.iretd_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.curr_sf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.sf_flag_o }

gui_sg_move "$_session_group_422" -after "$_session_group_417" -pos 5 

set _session_group_423 $_session_group_417|
append _session_group_423 u_sbb_op
gui_sg_create "$_session_group_423"
set stages|execute_unit|u_sbb_op "$_session_group_423"

gui_sg_addsignal -group "$_session_group_423" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.CF_in tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.al_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.ax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.ah_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.SF {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.eax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.ZF }

gui_sg_move "$_session_group_423" -after "$_session_group_417" -pos 6 

set _session_group_424 $_session_group_417|
append _session_group_424 u_sar_op
gui_sg_create "$_session_group_424"
set stages|execute_unit|u_sar_op "$_session_group_424"

gui_sg_addsignal -group "$_session_group_424" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.value_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.shift_amt_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.shift_by_one tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.count tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.result }

gui_sg_move "$_session_group_424" -after "$_session_group_417" -pos 7 

set _session_group_425 $_session_group_417|
append _session_group_425 u_sal_op
gui_sg_create "$_session_group_425"
set stages|execute_unit|u_sal_op "$_session_group_425"

gui_sg_addsignal -group "$_session_group_425" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.value_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.shift_amt_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.shift_by_one tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.count tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.result }

gui_sg_move "$_session_group_425" -after "$_session_group_417" -pos 8 

set _session_group_426 $_session_group_417|
append _session_group_426 u_ret_op
gui_sg_create "$_session_group_426"
set stages|execute_unit|u_ret_op "$_session_group_426"

gui_sg_addsignal -group "$_session_group_426" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_op.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_op.sr_o }

gui_sg_move "$_session_group_426" -after "$_session_group_417" -pos 9 

set _session_group_427 $_session_group_417|
append _session_group_427 u_ret_imm_op
gui_sg_create "$_session_group_427"
set stages|execute_unit|u_ret_imm_op "$_session_group_427"

gui_sg_addsignal -group "$_session_group_427" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_imm_op.imm64 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_imm_op.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_imm_op.sr_o }

gui_sg_move "$_session_group_427" -after "$_session_group_417" -pos 10 

set _session_group_428 $_session_group_417|
append _session_group_428 u_ret_far_op
gui_sg_create "$_session_group_428"
set stages|execute_unit|u_ret_far_op "$_session_group_428"

gui_sg_addsignal -group "$_session_group_428" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_op.cs tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_op.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_op.sr_o }

gui_sg_move "$_session_group_428" -after "$_session_group_417" -pos 11 

set _session_group_429 $_session_group_417|
append _session_group_429 u_ret_far_imm
gui_sg_create "$_session_group_429"
set stages|execute_unit|u_ret_far_imm "$_session_group_429"

gui_sg_addsignal -group "$_session_group_429" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_imm.cs tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_imm.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_imm.imm64 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_imm.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_imm.sr_o }

gui_sg_move "$_session_group_429" -after "$_session_group_417" -pos 12 

set _session_group_430 $_session_group_417|
append _session_group_430 u_res_buf_sel
gui_sg_create "$_session_group_430"
set stages|execute_unit|u_res_buf_sel "$_session_group_430"

gui_sg_addsignal -group "$_session_group_430" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.adc_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.add_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.and_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.call_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.cmpxchg_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.far_call_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.mov_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.not_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.or_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.push_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.sar_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.sbb_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.xchg_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.res_buf_o }

gui_sg_move "$_session_group_430" -after "$_session_group_417" -pos 13 

set _session_group_431 $_session_group_417|
append _session_group_431 u_res_buf_logic
gui_sg_create "$_session_group_431"
set stages|execute_unit|u_res_buf_logic "$_session_group_431"

gui_sg_addsignal -group "$_session_group_431" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_logic.res_info_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_logic.st_addr_0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_logic.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_logic.offset }

gui_sg_move "$_session_group_431" -after "$_session_group_417" -pos 14 

set _session_group_432 $_session_group_417|
append _session_group_432 u_push_op
gui_sg_create "$_session_group_432"
set stages|execute_unit|u_push_op "$_session_group_432"

gui_sg_addsignal -group "$_session_group_432" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.sp tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.data_size_vec tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.value tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.sr_o {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.num_bytes }

gui_sg_move "$_session_group_432" -after "$_session_group_417" -pos 15 

set _session_group_433 $_session_group_417|
append _session_group_433 u_pop_op
gui_sg_create "$_session_group_433"
set stages|execute_unit|u_pop_op "$_session_group_433"

gui_sg_addsignal -group "$_session_group_433" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pop_op.value_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pop_op.sp_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pop_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pop_op.sr_o }

gui_sg_move "$_session_group_433" -after "$_session_group_417" -pos 16 

set _session_group_434 $_session_group_417|
append _session_group_434 u_pf_flag_sel
gui_sg_create "$_session_group_434"
set stages|execute_unit|u_pf_flag_sel "$_session_group_434"

gui_sg_addsignal -group "$_session_group_434" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.adc_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.add_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.and_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.cmp_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.cmpxchg_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.or_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.sal_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.sar_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.sbb_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.iretd_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.curr_pf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.pf_flag_o }

gui_sg_move "$_session_group_434" -after "$_session_group_417" -pos 17 

set _session_group_435 $_session_group_417|
append _session_group_435 u_pavgw
gui_sg_create "$_session_group_435"
set stages|execute_unit|u_pavgw "$_session_group_435"

gui_sg_addsignal -group "$_session_group_435" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.a0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.a1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.a2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.a3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.b0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.b1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.b2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.b3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.s0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.s1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.s2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.s3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.r0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.r1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.r2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.r3 }

gui_sg_move "$_session_group_435" -after "$_session_group_417" -pos 18 

set _session_group_436 $_session_group_417|
append _session_group_436 u_pavgb
gui_sg_create "$_session_group_436"
set stages|execute_unit|u_pavgb "$_session_group_436"

gui_sg_addsignal -group "$_session_group_436" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a4 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a5 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a6 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a7 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b4 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b5 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b6 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b7 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s4 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s5 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s6 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s7 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r4 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r5 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r6 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r7 }

gui_sg_move "$_session_group_436" -after "$_session_group_417" -pos 19 

set _session_group_437 $_session_group_417|
append _session_group_437 u_paddw
gui_sg_create "$_session_group_437"
set stages|execute_unit|u_paddw "$_session_group_437"

gui_sg_addsignal -group "$_session_group_437" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.a0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.a1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.a2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.a3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.b0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.b1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.b2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.b3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.r0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.r1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.r2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.r3 }

gui_sg_move "$_session_group_437" -after "$_session_group_417" -pos 20 

set _session_group_438 $_session_group_417|
append _session_group_438 u_paddd
gui_sg_create "$_session_group_438"
set stages|execute_unit|u_paddd "$_session_group_438"

gui_sg_addsignal -group "$_session_group_438" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.a0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.a1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.b0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.b1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.r0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.r1 }

gui_sg_move "$_session_group_438" -after "$_session_group_417" -pos 21 

set _session_group_439 $_session_group_417|
append _session_group_439 u_packsswb
gui_sg_create "$_session_group_439"
set stages|execute_unit|u_packsswb "$_session_group_439"

gui_sg_addsignal -group "$_session_group_439" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.a0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.a1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.a2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.a3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.b0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.b1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.b2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.b3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r4 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r5 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r6 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r7 }

gui_sg_move "$_session_group_439" -after "$_session_group_417" -pos 22 

set _session_group_440 $_session_group_417|
append _session_group_440 u_packssdw
gui_sg_create "$_session_group_440"
set stages|execute_unit|u_packssdw "$_session_group_440"

gui_sg_addsignal -group "$_session_group_440" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.a0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.a1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.b0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.b1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.r0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.r1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.r2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.r3 }

gui_sg_move "$_session_group_440" -after "$_session_group_417" -pos 23 

set _session_group_441 $_session_group_417|
append _session_group_441 u_or_op
gui_sg_create "$_session_group_441"
set stages|execute_unit|u_or_op "$_session_group_441"

gui_sg_addsignal -group "$_session_group_441" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.or_result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.merged_result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.zf_low8 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.zf_up8 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.zf_up16 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.zf_low16 }

gui_sg_move "$_session_group_441" -after "$_session_group_417" -pos 24 

set _session_group_442 $_session_group_417|
append _session_group_442 u_of_flag_sel
gui_sg_create "$_session_group_442"
set stages|execute_unit|u_of_flag_sel "$_session_group_442"

gui_sg_addsignal -group "$_session_group_442" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.adc_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.add_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.and_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.cmp_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.cmpxchg_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.or_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.sal_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.sar_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.sbb_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.iretd_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.curr_of_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.of_flag_o }

gui_sg_move "$_session_group_442" -after "$_session_group_417" -pos 25 

set _session_group_443 $_session_group_417|
append _session_group_443 u_not_op
gui_sg_create "$_session_group_443"
set stages|execute_unit|u_not_op "$_session_group_443"

gui_sg_addsignal -group "$_session_group_443" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op.out_32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op.merged_res }

gui_sg_move "$_session_group_443" -after "$_session_group_417" -pos 26 

set _session_group_444 $_session_group_417|
append _session_group_444 u_mov_op
gui_sg_create "$_session_group_444"
set stages|execute_unit|u_mov_op "$_session_group_444"

gui_sg_addsignal -group "$_session_group_444" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.merged_res tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.curr_cf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.masked_data_size {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.res_buf_o }

gui_sg_move "$_session_group_444" -after "$_session_group_417" -pos 27 

set _session_group_445 $_session_group_417|
append _session_group_445 u_iretd_op
gui_sg_create "$_session_group_445"
set stages|execute_unit|u_iretd_op "$_session_group_445"

gui_sg_addsignal -group "$_session_group_445" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.cs tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.flags tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.sr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.OF }

gui_sg_move "$_session_group_445" -after "$_session_group_417" -pos 28 

set _session_group_446 $_session_group_417|
append _session_group_446 u_far_op
gui_sg_create "$_session_group_446"
set stages|execute_unit|u_far_op "$_session_group_446"

gui_sg_addsignal -group "$_session_group_446" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_far_op.neip tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_far_op.segment tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_far_op.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_far_op.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_far_op.sr_o }

gui_sg_move "$_session_group_446" -after "$_session_group_417" -pos 29 

set _session_group_447 $_session_group_417|
append _session_group_447 u_dr_sel
gui_sg_create "$_session_group_447"
set stages|execute_unit|u_dr_sel "$_session_group_447"

gui_sg_addsignal -group "$_session_group_447" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.aaa_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.adc_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.add_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.and_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.bsf_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.cmpxchg_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.mov_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.not_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.or_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.packssdw_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.packsswb_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.paddd_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.paddw_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.pavgb_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.pavgw_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.pop_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.ret_far_imm_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.sal_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.sar_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.sbb_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.xchg_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.dr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.dr_o }

gui_sg_move "$_session_group_447" -after "$_session_group_417" -pos 30 

set _session_group_448 $_session_group_417|
append _session_group_448 u_df_flag_sel
gui_sg_create "$_session_group_448"
set stages|execute_unit|u_df_flag_sel "$_session_group_448"

gui_sg_addsignal -group "$_session_group_448" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_df_flag_sel.curr_df_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_df_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_df_flag_sel.df_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_df_flag_sel.next_df_flag }

gui_sg_move "$_session_group_448" -after "$_session_group_417" -pos 31 

set _session_group_449 $_session_group_417|
append _session_group_449 u_cmpxchg_op
gui_sg_create "$_session_group_449"
set stages|execute_unit|u_cmpxchg_op "$_session_group_449"

gui_sg_addsignal -group "$_session_group_449" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.r_upper tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.rm_low tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.sr_data_size_vec tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.rm tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.r tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.acc_res tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.EAX_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.next_dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.next_EAX tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.r_low tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.rm_upper tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.EAX tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.SF {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.lock_res tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.ZF }

gui_sg_move "$_session_group_449" -after "$_session_group_417" -pos 32 

set _session_group_450 $_session_group_417|
append _session_group_450 u_cmp
gui_sg_create "$_session_group_450"
set stages|execute_unit|u_cmp "$_session_group_450"

gui_sg_addsignal -group "$_session_group_450" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.low_sr_val tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.al_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.ax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.eax_sum }

gui_sg_move "$_session_group_450" -after "$_session_group_417" -pos 33 

set _session_group_451 $_session_group_417|
append _session_group_451 u_cf_flag_sel
gui_sg_create "$_session_group_451"
set stages|execute_unit|u_cf_flag_sel "$_session_group_451"

gui_sg_addsignal -group "$_session_group_451" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.aaa_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.adc_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.add_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.and_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.cmp_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.cmpxchg_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.or_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.sal_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.sar_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.sbb_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.iretd_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.curr_cf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.cf_flag_o }

gui_sg_move "$_session_group_451" -after "$_session_group_417" -pos 34 

set _session_group_452 $_session_group_417|
append _session_group_452 u_call_op
gui_sg_create "$_session_group_452"
set stages|execute_unit|u_call_op "$_session_group_452"

gui_sg_addsignal -group "$_session_group_452" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_call_op.NEIP tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_call_op.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_call_op.sr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_call_op.res_buf }

gui_sg_move "$_session_group_452" -after "$_session_group_417" -pos 35 

set _session_group_453 $_session_group_417|
append _session_group_453 u_bsf
gui_sg_create "$_session_group_453"
set stages|execute_unit|u_bsf "$_session_group_453"

gui_sg_addsignal -group "$_session_group_453" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.op32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.op16 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.index32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.index16 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.found32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.found16 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.result32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.result16 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.ZF32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.ZF16 }

gui_sg_move "$_session_group_453" -after "$_session_group_417" -pos 36 

set _session_group_454 $_session_group_417|
append _session_group_454 u_br_res
gui_sg_create "$_session_group_454"
set stages|execute_unit|u_br_res "$_session_group_454"

gui_sg_addsignal -group "$_session_group_454" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.stage_valid_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_info_valid_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.flush_mask tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_eip_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_xcl_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_pred_taken_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.speculative_target_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_ucond_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.relative_branch_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.special_br_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.is_far_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.is_call_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.second_flag_needed_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_source_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.NEIP_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_rel_target tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.valid tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_target tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.taken tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.clr_exp_mode tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.flush tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.miss_prediction tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.second_flag_result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.cond_br_res tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.target_match tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.farFlush tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.callFlush tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.outs_o }

gui_sg_move "$_session_group_454" -after "$_session_group_417" -pos 37 

set _session_group_455 $_session_group_417|
append _session_group_455 u_bit_vec_logic
gui_sg_create "$_session_group_455"
set stages|execute_unit|u_bit_vec_logic "$_session_group_455"

gui_sg_addsignal -group "$_session_group_455" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.st_addr_0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.ST_XCL tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.st_vec0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.st_vec1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.num_bytes tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.start_offset tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.offset_xcl tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.end_of_st_addr_1 }

gui_sg_move "$_session_group_455" -after "$_session_group_417" -pos 38 

set _session_group_456 $_session_group_417|
append _session_group_456 u_and_op
gui_sg_create "$_session_group_456"
set stages|execute_unit|u_and_op "$_session_group_456"

gui_sg_addsignal -group "$_session_group_456" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.and_result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.merged_result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.ld_16 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.ld_32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.ld_8 }

gui_sg_move "$_session_group_456" -after "$_session_group_417" -pos 39 

set _session_group_457 $_session_group_417|
append _session_group_457 u_alu_input_sel
gui_sg_create "$_session_group_457"
set stages|execute_unit|u_alu_input_sel "$_session_group_457"

gui_sg_addsignal -group "$_session_group_457" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.br_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.EIP tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.dr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.shift_sr_up tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.sr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.imm64 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.flags tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.ld_addr_0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.NEIP tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.alu_inputB_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.alu_inputA_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.EAX tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.br_input_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.shift_sr_down tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.res_buf_offset tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.srA_64 {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.res_buf_out tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.srB_64 }

gui_sg_move "$_session_group_457" -after "$_session_group_417" -pos 40 

set _session_group_458 $_session_group_417|
append _session_group_458 u_af_flag_sel
gui_sg_create "$_session_group_458"
set stages|execute_unit|u_af_flag_sel "$_session_group_458"

gui_sg_addsignal -group "$_session_group_458" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.aaa_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.adc_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.add_op_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.cmp_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.cmpxchg_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.sbb_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.iretd_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.curr_af_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.af_flag_o }

gui_sg_move "$_session_group_458" -after "$_session_group_417" -pos 41 

set _session_group_459 $_session_group_417|
append _session_group_459 u_add_op
gui_sg_create "$_session_group_459"
set stages|execute_unit|u_add_op "$_session_group_459"

gui_sg_addsignal -group "$_session_group_459" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.al_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.ah_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.ax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.eax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.af_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.merged_result }

gui_sg_move "$_session_group_459" -after "$_session_group_417" -pos 42 

set _session_group_460 $_session_group_417|
append _session_group_460 u_adc_op
gui_sg_create "$_session_group_460"
set stages|execute_unit|u_adc_op "$_session_group_460"

gui_sg_addsignal -group "$_session_group_460" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.CF_in tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.sum }

gui_sg_move "$_session_group_460" -after "$_session_group_417" -pos 43 

set _session_group_461 $_session_group_417|
append _session_group_461 u_aaa
gui_sg_create "$_session_group_461"
set stages|execute_unit|u_aaa "$_session_group_461"

gui_sg_addsignal -group "$_session_group_461" { {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.EAX_in tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.AF_flag_in tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.adjust tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.AL tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.AH tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.AX_new }

gui_sg_move "$_session_group_461" -after "$_session_group_417" -pos 44 

set _session_group_462 $_session_group_412|
append _session_group_462 write_back_unit
gui_sg_create "$_session_group_462"
set stages|write_back_unit "$_session_group_462"

gui_sg_addsignal -group "$_session_group_462" { tb_stages.uut_AllAtOnce.core_unit.write_back_unit.write_success tb_stages.uut_AllAtOnce.core_unit.write_back_unit.reg_wb_logic_outs tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stq_info tb_stages.uut_AllAtOnce.core_unit.write_back_unit.mio_q_output tb_stages.uut_AllAtOnce.core_unit.write_back_unit.mio_push_fail tb_stages.uut_AllAtOnce.core_unit.write_back_unit.write_success_mio tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stq_heads tb_stages.uut_AllAtOnce.core_unit.write_back_unit.wb_latches tb_stages.uut_AllAtOnce.core_unit.write_back_unit.outputs tb_stages.uut_AllAtOnce.core_unit.write_back_unit.mio_q_input tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stq_outputs tb_stages.uut_AllAtOnce.core_unit.write_back_unit.dc_dep tb_stages.uut_AllAtOnce.core_unit.write_back_unit.clk tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stall_flop_next tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stall_flop {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.write_back_unit.rst }

# Global: Highlighting
gui_highlight_signals -color #00ff00 {{tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.dr_data[63:0]}}

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 1575.373



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
catch {gui_list_expand -id ${Hier.1} tb_stages.uut_AllAtOnce.core_unit}
catch {gui_list_expand -id ${Hier.1} tb_stages.uut_AllAtOnce.core_unit.execute_unit}
catch {gui_list_select -id ${Hier.1} {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa}}
gui_view_scroll -id ${Hier.1} -vertical -set 200
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 200
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel /home/ecelrc/students/je28497/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/alu_input_sel.sv
gui_view_scroll -id ${Source.1} -vertical -set 420
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
gui_marker_create -id ${Wave.1} M2 1575.373
gui_marker_select -id ${Wave.1} {  M2 }
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 1336.615 1626.919
gui_list_add_group -id ${Wave.1} -after {New Group} {uut_AllAtOnce_1}
gui_list_add_group -id ${Wave.1} -after {New Group} {Mem_System}
gui_list_add_group -id ${Wave.1}  -after Mem_System {Mem_System|mem_unit_1}
gui_list_add_group -id ${Wave.1} -after Mem_System|mem_unit_1 {Mem_System|icache_unit}
gui_list_add_group -id ${Wave.1} -after Mem_System|icache_unit {Mem_System|dma_controller_unit}
gui_list_add_group -id ${Wave.1} -after Mem_System|dma_controller_unit {Mem_System|ddr5_unit}
gui_list_add_group -id ${Wave.1} -after Mem_System|ddr5_unit {Mem_System|dcache_unit}
gui_list_add_group -id ${Wave.1} -after Mem_System|dcache_unit {Mem_System|bus_arbitration_unit}
gui_list_add_group -id ${Wave.1} -after {New Group} {flags_reg}
gui_list_add_group -id ${Wave.1} -after {{tb_stages.uut_AllAtOnce.core_unit.execute_unit.flags_reg[31:0]}} {flags_reg|reg_sb_unit}
gui_list_add_group -id ${Wave.1} -after flags_reg|reg_sb_unit {flags_reg|RegisterFile_unit}
gui_list_add_group -id ${Wave.1} -after {New Group} {uut_stuff}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches {uut_stuff|u_mov_op}
gui_list_add_group -id ${Wave.1} -after uut_stuff|u_mov_op {uut_stuff|u_sbb_op}
gui_list_add_group -id ${Wave.1} -after {New Group} {Core}
gui_list_add_group -id ${Wave.1}  -after Core {Core|core_unit}
gui_list_add_group -id ${Wave.1} -after {New Group} {latches}
gui_list_add_group -id ${Wave.1}  -after latches {latches|idm_unit}
gui_list_add_group -id ${Wave.1} -after latches|idm_unit {latches|rr_latches_unit}
gui_list_add_group -id ${Wave.1} -after latches|rr_latches_unit {latches|dc_latches_unit}
gui_list_add_group -id ${Wave.1} -after latches|dc_latches_unit {latches|mem_latches_unit}
gui_list_add_group -id ${Wave.1} -after latches|mem_latches_unit {latches|exe_latches_unit}
gui_list_add_group -id ${Wave.1} -after latches|exe_latches_unit {latches|wb_latches_unit}
gui_list_add_group -id ${Wave.1} -after {New Group} {stages}
gui_list_add_group -id ${Wave.1}  -after stages {stages|idm_unit}
gui_list_add_group -id ${Wave.1} -after stages|idm_unit {stages|rr_unit}
gui_list_add_group -id ${Wave.1} -after stages|rr_unit {stages|dc_unit}
gui_list_add_group -id ${Wave.1} -after stages|dc_unit {stages|mem_unit}
gui_list_add_group -id ${Wave.1} -after stages|mem_unit {stages|execute_unit}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.execute_unit.zf_flag_o {stages|execute_unit|wb_valid_logic_unit}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|wb_valid_logic_unit {stages|execute_unit|u_zf_flag_sel}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_zf_flag_sel {stages|execute_unit|u_xchg_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_xchg_op {stages|execute_unit|u_sr_sel}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_sr_sel {stages|execute_unit|u_sf_flag_sel}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_sf_flag_sel {stages|execute_unit|u_sbb_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_sbb_op {stages|execute_unit|u_sar_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_sar_op {stages|execute_unit|u_sal_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_sal_op {stages|execute_unit|u_ret_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_ret_op {stages|execute_unit|u_ret_imm_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_ret_imm_op {stages|execute_unit|u_ret_far_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_ret_far_op {stages|execute_unit|u_ret_far_imm}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_ret_far_imm {stages|execute_unit|u_res_buf_sel}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_res_buf_sel {stages|execute_unit|u_res_buf_logic}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_res_buf_logic {stages|execute_unit|u_push_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_push_op {stages|execute_unit|u_pop_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_pop_op {stages|execute_unit|u_pf_flag_sel}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_pf_flag_sel {stages|execute_unit|u_pavgw}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_pavgw {stages|execute_unit|u_pavgb}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_pavgb {stages|execute_unit|u_paddw}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_paddw {stages|execute_unit|u_paddd}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_paddd {stages|execute_unit|u_packsswb}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_packsswb {stages|execute_unit|u_packssdw}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_packssdw {stages|execute_unit|u_or_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_or_op {stages|execute_unit|u_of_flag_sel}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_of_flag_sel {stages|execute_unit|u_not_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_not_op {stages|execute_unit|u_mov_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_mov_op {stages|execute_unit|u_iretd_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_iretd_op {stages|execute_unit|u_far_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_far_op {stages|execute_unit|u_dr_sel}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_dr_sel {stages|execute_unit|u_df_flag_sel}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_df_flag_sel {stages|execute_unit|u_cmpxchg_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_cmpxchg_op {stages|execute_unit|u_cmp}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_cmp {stages|execute_unit|u_cf_flag_sel}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_cf_flag_sel {stages|execute_unit|u_call_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_call_op {stages|execute_unit|u_bsf}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_bsf {stages|execute_unit|u_br_res}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_br_res {stages|execute_unit|u_bit_vec_logic}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_bit_vec_logic {stages|execute_unit|u_and_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_and_op {stages|execute_unit|u_alu_input_sel}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_alu_input_sel {stages|execute_unit|u_af_flag_sel}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_af_flag_sel {stages|execute_unit|u_add_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_add_op {stages|execute_unit|u_adc_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_adc_op {stages|execute_unit|u_aaa}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit {stages|write_back_unit}
gui_list_collapse -id ${Wave.1} uut_AllAtOnce_1
gui_list_collapse -id ${Wave.1} Mem_System
gui_list_collapse -id ${Wave.1} Mem_System|mem_unit_1
gui_list_collapse -id ${Wave.1} Mem_System|icache_unit
gui_list_collapse -id ${Wave.1} Mem_System|dma_controller_unit
gui_list_collapse -id ${Wave.1} Mem_System|ddr5_unit
gui_list_collapse -id ${Wave.1} Mem_System|dcache_unit
gui_list_collapse -id ${Wave.1} Mem_System|bus_arbitration_unit
gui_list_collapse -id ${Wave.1} flags_reg|reg_sb_unit
gui_list_collapse -id ${Wave.1} flags_reg|RegisterFile_unit
gui_list_collapse -id ${Wave.1} uut_stuff
gui_list_collapse -id ${Wave.1} uut_stuff|u_mov_op
gui_list_collapse -id ${Wave.1} uut_stuff|u_sbb_op
gui_list_collapse -id ${Wave.1} Core
gui_list_collapse -id ${Wave.1} latches
gui_list_collapse -id ${Wave.1} latches|idm_unit
gui_list_collapse -id ${Wave.1} latches|rr_latches_unit
gui_list_collapse -id ${Wave.1} latches|dc_latches_unit
gui_list_collapse -id ${Wave.1} latches|mem_latches_unit
gui_list_collapse -id ${Wave.1} latches|exe_latches_unit
gui_list_collapse -id ${Wave.1} latches|wb_latches_unit
gui_list_collapse -id ${Wave.1} stages|idm_unit
gui_list_collapse -id ${Wave.1} stages|rr_unit
gui_list_collapse -id ${Wave.1} stages|dc_unit
gui_list_collapse -id ${Wave.1} stages|mem_unit
gui_list_collapse -id ${Wave.1} stages|execute_unit|wb_valid_logic_unit
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_zf_flag_sel
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_xchg_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_sr_sel
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_sf_flag_sel
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_sbb_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_sar_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_sal_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_ret_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_ret_imm_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_ret_far_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_ret_far_imm
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_res_buf_sel
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_res_buf_logic
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_push_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_pop_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_pf_flag_sel
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_pavgw
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_pavgb
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_paddw
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_paddd
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_packsswb
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_packssdw
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_or_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_of_flag_sel
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_not_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_mov_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_iretd_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_far_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_dr_sel
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_df_flag_sel
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_cmpxchg_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_cmp
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_cf_flag_sel
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_call_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_bsf
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_br_res
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_bit_vec_logic
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_and_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_alu_input_sel
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_add_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_adc_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_aaa
gui_list_collapse -id ${Wave.1} stages|write_back_unit
gui_list_expand -id ${Wave.1} tb_stages.uut_AllAtOnce.core_unit.execute_unit.flags_reg
gui_list_select -id ${Wave.1} {tb_stages.uut_AllAtOnce.core_unit.execute_unit.af_flag_o }
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
gui_list_set_insertion_bar  -id ${Wave.1} -group stages|execute_unit  -item {tb_stages.uut_AllAtOnce.core_unit.execute_unit.latches_i.EIP[31:0]} -position below

gui_marker_move -id ${Wave.1} {C1} 1575.373
gui_view_scroll -id ${Wave.1} -vertical -set 1878
gui_show_grid -id ${Wave.1} -enable false

# DriverLoad 'DriverLoad.1'
gui_get_drivers -session -id ${DriverLoad.1} -signal tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches.valid -time 476 -starttime 477.846
gui_get_drivers -session -id ${DriverLoad.1} -signal {tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches.cs.OP_TYPE[31:0]} -time 476 -starttime 477.846
gui_get_drivers -session -id ${DriverLoad.1} -signal tb_stages.uut_AllAtOnce.core_unit.execute_unit.next_wb_cs -time 1212 -starttime 1479.979
gui_get_drivers -session -id ${DriverLoad.1} -signal {tb_stages.uut_AllAtOnce.core_unit.execute_unit.srA[63:0]} -time 1436 -starttime 1479.979
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

