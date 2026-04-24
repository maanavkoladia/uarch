# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Fri Apr 24 04:39:48 2026
# Designs open: 1
#   V1: vcdplus.vpd
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: 
#   Wave.1: 1466 signals
#   Group count = 90
#   Group uut_AllAtOnce signal count = 9
#   Group uut_AllAtOnce_1 signal count = 9
#   Group Mem_System signal count = 18
#   Group flags_reg signal count = 3
#   Group uut_stuff signal count = 7
#   Group Core signal count = 1
#   Group latches signal count = 6
#   Group stages signal count = 8
# End_DVE_Session_Save_Info

# DVE version: T-2022.06_Full64
# DVE build date: May 31 2022 20:53:03


#<Session mode="Full" path="/misc/scratch/je28497/uarch/design/EverythingEverywhereAllAtOnce/tests/Stages/Harish_StageTesting/jacob_save.tcl" type="Debug">

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
gui_show_window -window ${TopLevel.1} -show_state maximized -rect {{1536 31} {3071 823}}

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
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 431]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 431
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 430} {height 519} {dock_state left} {dock_on_new_line true} {child_hier_colhier 335} {child_hier_coltype 107} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 496]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 496
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 517
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 495} {height 519} {dock_state left} {dock_on_new_line true} {child_data_colvariable 279} {child_data_colvalue 57} {child_data_coltype 171} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 175]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value -1
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 175
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 271} {height 174} {dock_state bottom} {dock_on_new_line true}}
set DriverLoad.1 [gui_create_window -type DriverLoad -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line false -dock_extent 175]
gui_set_window_pref_key -window ${DriverLoad.1} -key dock_width -value_type integer -value 150
gui_set_window_pref_key -window ${DriverLoad.1} -key dock_height -value_type integer -value 175
gui_set_window_pref_key -window ${DriverLoad.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DriverLoad.1} {{left 0} {top 0} {width 1263} {height 174} {dock_state bottom} {dock_on_new_line false}}
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
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 443} {child_wave_right 831} {child_wave_colname 366} {child_wave_colvalue 73} {child_wave_col1 0} {child_wave_col2 1}}

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
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_imm}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op}
gui_load_child_values {tb_stages.uut_AllAtOnce}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_logic}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.rr_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_imm_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst}
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
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pop_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_call_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.idm_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_df_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit}
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
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.fetch_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit}


set _session_group_89 uut_AllAtOnce
gui_sg_create "$_session_group_89"
set uut_AllAtOnce "$_session_group_89"

gui_sg_addsignal -group "$_session_group_89" { {tb_stages.uut_AllAtOnce.$unit} tb_stages.uut_AllAtOnce.clk tb_stages.uut_AllAtOnce.rst tb_stages.uut_AllAtOnce.icache2core tb_stages.uut_AllAtOnce.core2icache tb_stages.uut_AllAtOnce.stq2dcache tb_stages.uut_AllAtOnce.core2dcache tb_stages.uut_AllAtOnce.dcache2core tb_stages.uut_AllAtOnce.dma2core }

set _session_group_90 uut_AllAtOnce_1
gui_sg_create "$_session_group_90"
set uut_AllAtOnce_1 "$_session_group_90"

gui_sg_addsignal -group "$_session_group_90" { tb_stages.uut_AllAtOnce.stq2dcache tb_stages.uut_AllAtOnce.icache2core tb_stages.uut_AllAtOnce.core2dcache tb_stages.uut_AllAtOnce.clk tb_stages.uut_AllAtOnce.core2icache tb_stages.uut_AllAtOnce.dma2core tb_stages.uut_AllAtOnce.dcache2core {tb_stages.uut_AllAtOnce.$unit} tb_stages.uut_AllAtOnce.rst }

set _session_group_91 Mem_System
gui_sg_create "$_session_group_91"
set Mem_System "$_session_group_91"

gui_sg_addsignal -group "$_session_group_91" { {tb_stages.uut_AllAtOnce.mem_sys_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.addressBus tb_stages.uut_AllAtOnce.mem_sys_unit.core2icache_i tb_stages.uut_AllAtOnce.mem_sys_unit.icache2core_o tb_stages.uut_AllAtOnce.mem_sys_unit.core2dcache_i tb_stages.uut_AllAtOnce.mem_sys_unit.dcache2core_o tb_stages.uut_AllAtOnce.mem_sys_unit.dma2core_o }

set _session_group_92 $_session_group_91|
append _session_group_92 icache_dataStore_unit
gui_sg_create "$_session_group_92"
set Mem_System|icache_dataStore_unit "$_session_group_92"

gui_sg_addsignal -group "$_session_group_92" { {tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.en tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.v_addr_i tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.LD_IC_SWAP_BUF tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.fill0_i tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.fill1_i tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.fill2_i tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.fill3_i tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.busy tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.ld_From_I_VC_Swap tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.I_VC_SwapBuf_i_valid tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.I_VC_SwapBuf_i_lineAddr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.I_VC_SwapBuf_i_line tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.currLine_o tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.v_addr_index tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.addr_2_store tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.dataLineOutSel tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.clk_45_phase tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.wbw_Q tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.sel_layer tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.dataLineOutSel_bar tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.DIN_pack tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.want_pack tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.gate_pack tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.WR_actual tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.busy_bar tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.nb_or_ld tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.oe_hi tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.OE_2_DataStore tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit.dout_pack }

set _session_group_93 $_session_group_91|
append _session_group_93 icache_TagStore_unit
gui_sg_create "$_session_group_93"
set Mem_System|icache_TagStore_unit "$_session_group_93"

gui_sg_addsignal -group "$_session_group_93" { {tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.en tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.v_addr_i tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.ld_From_I_VC_Swap tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.LD_IC_SWAP_BUF tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.fill3_i tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.busy tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.I_VC_SwapBuf_i_valid tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.I_VC_SwapBuf_i_lineAddr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.I_VC_SwapBuf_i_line tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.currTag_o tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.currLine_V tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.v_addr_tag tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.v_addr_index tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.addr_2_store tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.tagCellOutSel tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.clk_45_phase tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.WR_actual tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.tagCellOutSel_bar tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.or_f3_vc tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.sel0 tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.sel1 tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.sel0_gated tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.sel1_gated tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.gate0 tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.gate1 tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.DIN_2_TagStore tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.busy_bar tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.nb_or_ld tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.oe_hi tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.OE_2_TagStore tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.dout_pack tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.idx_oh_16 tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.we_valid_base tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.we_valid tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_TagStore_unit.validStore }

gui_sg_move "$_session_group_93" -after "$_session_group_91" -pos 1 

set _session_group_94 $_session_group_91|
append _session_group_94 icache_unit
gui_sg_create "$_session_group_94"
set Mem_System|icache_unit "$_session_group_94"

gui_sg_addsignal -group "$_session_group_94" { tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.HIGH_PRI_VAL tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.saved_vAddr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.addrBus_drv tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.num_valid_IDM_slots tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_swapbuf_lineAddr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.tag_eq tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.MakeReq tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_swapbuf_valid tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.out_instruction_line tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_miss tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_hit tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.pri_val tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.LOW_PRI_VAL tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_swapbuf_line tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.RD_I_VC_SWAP_BUF tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_swapBuf_lineAddr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.Fill3EN tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.Mem_Valid tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.Fill2EN tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.Fill1EN tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.clr_bar tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_swapBuf_V_Clr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.Fill0EN tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.NO_REQ_VAL tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.v_addr_i tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.num1_bar tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.d_swapbuf_v tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.num2_bar tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.busy_bar tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.curr_v_addr_to_use tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.saved_pAddr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_hit tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_swapBuf_line tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.nv_or_neq tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.busy tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.p_addr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.we_swapbuf_v tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.v_addr_i_tag_live tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_dataLines tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.num_lt_2 tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.save_v_addr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_tag_V_bar tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.S_0 tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.S_1 tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.S_2 tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.driveAddrBus_bar tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.out_hit tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.LD_IC_SWAP_BUF tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.valid_and_eq tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataLines tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.driveAddrBus tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.addrBus tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_en tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_swapBuf_valid tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_tag_V {tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.tag_neq tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.set_case tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_miss tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_tag tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.out_req tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.swap_lineAddr_d }

gui_sg_move "$_session_group_94" -after "$_session_group_91" -pos 2 

set _session_group_95 $_session_group_91|
append _session_group_95 bus_arbitration_unit
gui_sg_create "$_session_group_95"
set Mem_System|bus_arbitration_unit "$_session_group_95"

gui_sg_addsignal -group "$_session_group_95" { {tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.sch_best_pick tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.sch_best_pick_bk_id tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.iCache_2_Sch_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_out_2_icache_o tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dCache_2_Sch_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_out_2_dcache_o tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.mem_2_Sch_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.mem_2_dte_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_2_mem_o tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dma_2_sch_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_2_dma_o tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_2_ddr5_o }

gui_sg_move "$_session_group_95" -after "$_session_group_91" -pos 7 

set _session_group_96 $_session_group_91|
append _session_group_96 dcache_unit
gui_sg_create "$_session_group_96"
set Mem_System|dcache_unit "$_session_group_96"

gui_sg_addsignal -group "$_session_group_96" { {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.address_bus tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.hitVec tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.arb_st_override_Out tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.arb_req_served_0_out tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.arb_req_served_1_out tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.inFromCore_i tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.out2Core_o tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.inFromDTE_i tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.out2Sch_o tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.blockOutputs {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.req_2_blocks[0].p_addr} tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.req_2_blocks tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.mio_block_outputs }

gui_sg_move "$_session_group_96" -after "$_session_group_91" -pos 6 

set _session_group_97 $_session_group_91|
append _session_group_97 ddr5_unit
gui_sg_create "$_session_group_97"
set Mem_System|ddr5_unit "$_session_group_97"

gui_sg_addsignal -group "$_session_group_97" { {tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.addrBus tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.tempValue tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.powerGate tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.dataBus_fake tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.inFromDTE_i }

gui_sg_move "$_session_group_97" -after "$_session_group_91" -pos 5 

set _session_group_98 $_session_group_91|
append _session_group_98 dma_controller_unit
gui_sg_create "$_session_group_98"
set Mem_System|dma_controller_unit "$_session_group_98"

gui_sg_addsignal -group "$_session_group_98" { {tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.addrBus tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.fsmState tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.fsmState_bits tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.commiting tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.disk_ld_Buffer_V tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.disk_ld_Buffer tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.counter tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.writeBuf tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.writeBuf_addr tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.writeBuf_V tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.writeComplete tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.write2_srcAddr_req tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.write2_destAddr_req tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.write2_numBytes_req tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.write2_startWrite_req tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.addrBus_drv tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.dataBus_drv tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.driveDataBus tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.inFromDTE_i tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.out2Core_o tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.out2Sch_o tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.dma_Regs tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.fsmOuts }

gui_sg_move "$_session_group_98" -after "$_session_group_91" -pos 4 

set _session_group_99 $_session_group_91|
append _session_group_99 mem_unit_1
gui_sg_create "$_session_group_99"
set Mem_System|mem_unit_1 "$_session_group_99"

gui_sg_addsignal -group "$_session_group_99" { {tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.address_bus tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.data_bus tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.mem_bus tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.dataToDrive }

gui_sg_move "$_session_group_99" -after "$_session_group_91" -pos 3 

set _session_group_100 flags_reg
gui_sg_create "$_session_group_100"
set flags_reg "$_session_group_100"

gui_sg_addsignal -group "$_session_group_100" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.flags_reg }

set _session_group_101 $_session_group_100|
append _session_group_101 RegisterFile_unit
gui_sg_create "$_session_group_101"
set flags_reg|RegisterFile_unit "$_session_group_101"

gui_sg_addsignal -group "$_session_group_101" { tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.SR_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR1_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR0_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.DR_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR0_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR1_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.Segment0_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.wb_wr_to_both tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.Segment1_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.SIB_BASE_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.outputs tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.SIB_IDX_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.REGISTERS tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.clk tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR1_data {tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR0_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.rst }

gui_sg_move "$_session_group_101" -after "$_session_group_100" -pos 2 

set _session_group_102 $_session_group_100|
append _session_group_102 reg_sb_unit
gui_sg_create "$_session_group_102"
set flags_reg|reg_sb_unit "$_session_group_102"

gui_sg_addsignal -group "$_session_group_102" { tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_dr_rd tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sr_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.flush tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr1_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_sr_wr tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.dep_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.dr_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.ecx_sb tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr0_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_dr_wr tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sr_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr1_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.depStall_Internal tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.Segment0_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.seg0_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_wr_to_both tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.Segment1_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_idx_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.codeSeg_sb tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.farFlush tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_wr_to_both tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_eax_rd tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_base_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.updateSB tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.instructionforward tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_base_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_idx_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_eax_wr tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.eax_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.clk tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.seg1_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_sr_rd {tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.dr_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.SCORE_BOARD tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.Segment1_valid tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr0_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_sib_size tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.rst }

gui_sg_move "$_session_group_102" -after "$_session_group_100" -pos 1 

set _session_group_103 uut_stuff
gui_sg_create "$_session_group_103"
set uut_stuff "$_session_group_103"

gui_sg_addsignal -group "$_session_group_103" { tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches.EIP tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches.valid tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches.data_size_vec tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches.cs.OP_TYPE tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches }

set _session_group_104 $_session_group_103|
append _session_group_104 u_sbb_op
gui_sg_create "$_session_group_104"
set uut_stuff|u_sbb_op "$_session_group_104"

gui_sg_addsignal -group "$_session_group_104" { {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.CF_in tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.al_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.ah_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.ax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.eax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.result }

gui_sg_move "$_session_group_104" -after "$_session_group_103" -pos 6 

set _session_group_105 $_session_group_103|
append _session_group_105 u_mov_op
gui_sg_create "$_session_group_105"
set uut_stuff|u_mov_op "$_session_group_105"

gui_sg_addsignal -group "$_session_group_105" { {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.curr_cf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.masked_data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.merged_res }

gui_sg_move "$_session_group_105" -after "$_session_group_103" -pos 5 

set _session_group_106 Core
gui_sg_create "$_session_group_106"
set Core "$_session_group_106"

gui_sg_addsignal -group "$_session_group_106" { }

set _session_group_107 $_session_group_106|
append _session_group_107 core_unit
gui_sg_create "$_session_group_107"
set Core|core_unit "$_session_group_107"

gui_sg_addsignal -group "$_session_group_107" { tb_stages.uut_AllAtOnce.core_unit.mem_latches tb_stages.uut_AllAtOnce.core_unit.wb_latches_next tb_stages.uut_AllAtOnce.core_unit.DCacheIn_i tb_stages.uut_AllAtOnce.core_unit.inFromDMA_i tb_stages.uut_AllAtOnce.core_unit.dc_outputs tb_stages.uut_AllAtOnce.core_unit.mem_latches_next tb_stages.uut_AllAtOnce.core_unit.mem_outputs tb_stages.uut_AllAtOnce.core_unit.dc_latches_next tb_stages.uut_AllAtOnce.core_unit.wb_latches tb_stages.uut_AllAtOnce.core_unit.rr_latches_next tb_stages.uut_AllAtOnce.core_unit.rr_latches tb_stages.uut_AllAtOnce.core_unit.exe_latches tb_stages.uut_AllAtOnce.core_unit.idm_outputs tb_stages.uut_AllAtOnce.core_unit.fetch_outputs tb_stages.uut_AllAtOnce.core_unit.clk tb_stages.uut_AllAtOnce.core_unit.wb_outputs tb_stages.uut_AllAtOnce.core_unit.decode_outputs tb_stages.uut_AllAtOnce.core_unit.rr_outputs tb_stages.uut_AllAtOnce.core_unit.exe_latches_next tb_stages.uut_AllAtOnce.core_unit.out2DCache_o tb_stages.uut_AllAtOnce.core_unit.exe_outputs {tb_stages.uut_AllAtOnce.core_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_latches tb_stages.uut_AllAtOnce.core_unit.ICacheIn_i tb_stages.uut_AllAtOnce.core_unit.out2ICache_o tb_stages.uut_AllAtOnce.core_unit.rst }

set _session_group_108 latches
gui_sg_create "$_session_group_108"
set latches "$_session_group_108"

gui_sg_addsignal -group "$_session_group_108" { }

set _session_group_109 $_session_group_108|
append _session_group_109 exe_latches_unit
gui_sg_create "$_session_group_109"
set latches|exe_latches_unit "$_session_group_109"

gui_sg_addsignal -group "$_session_group_109" { tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.flush tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.write_enable_i {tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.rst }

gui_sg_move "$_session_group_109" -after "$_session_group_108" -pos 4 

set _session_group_110 $_session_group_108|
append _session_group_110 dc_latches_unit
gui_sg_create "$_session_group_110"
set latches|dc_latches_unit "$_session_group_110"

gui_sg_addsignal -group "$_session_group_110" { tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.flush tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.latches tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.farFlush tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.write_enable_i {tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.rst }

gui_sg_move "$_session_group_110" -after "$_session_group_108" -pos 2 

set _session_group_111 $_session_group_108|
append _session_group_111 idm_unit
gui_sg_create "$_session_group_111"
set latches|idm_unit "$_session_group_111"

gui_sg_addsignal -group "$_session_group_111" { tb_stages.uut_AllAtOnce.core_unit.idm_unit.fetch_outs_i tb_stages.uut_AllAtOnce.core_unit.idm_unit.idm_outs_o tb_stages.uut_AllAtOnce.core_unit.idm_unit.clk tb_stages.uut_AllAtOnce.core_unit.idm_unit.idm {tb_stages.uut_AllAtOnce.core_unit.idm_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.idm_unit.rst }

set _session_group_112 $_session_group_108|
append _session_group_112 wb_latches_unit
gui_sg_create "$_session_group_112"
set latches|wb_latches_unit "$_session_group_112"

gui_sg_addsignal -group "$_session_group_112" { tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.latches tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.write_enable_i {tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.rst }

gui_sg_move "$_session_group_112" -after "$_session_group_108" -pos 5 

set _session_group_113 $_session_group_108|
append _session_group_113 mem_latches_unit
gui_sg_create "$_session_group_113"
set latches|mem_latches_unit "$_session_group_113"

gui_sg_addsignal -group "$_session_group_113" { tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.flush tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.latches tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.farFlush tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.write_enable_i {tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.rst }

gui_sg_move "$_session_group_113" -after "$_session_group_108" -pos 3 

set _session_group_114 $_session_group_108|
append _session_group_114 rr_latches_unit
gui_sg_create "$_session_group_114"
set latches|rr_latches_unit "$_session_group_114"

gui_sg_addsignal -group "$_session_group_114" { tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.flush tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.latches tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.farFlush tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.write_enable_i {tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.rst }

gui_sg_move "$_session_group_114" -after "$_session_group_108" -pos 1 

set _session_group_115 stages
gui_sg_create "$_session_group_115"
set stages "$_session_group_115"

gui_sg_addsignal -group "$_session_group_115" { }

set _session_group_116 $_session_group_115|
append _session_group_116 dc_unit
gui_sg_create "$_session_group_116"
set stages|dc_unit "$_session_group_116"

gui_sg_addsignal -group "$_session_group_116" { tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_out tb_stages.uut_AllAtOnce.core_unit.dc_unit.fetch_outs_i tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_latches_next_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_mio_V tb_stages.uut_AllAtOnce.core_unit.dc_unit.dep_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.rr_exception tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_served_0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_served_1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_ST_OP tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_stage_we_valid_unit_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.data_size_vec tb_stages.uut_AllAtOnce.core_unit.dc_unit.exp_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_mio tb_stages.uut_AllAtOnce.core_unit.dc_unit.latches_i tb_stages.uut_AllAtOnce.core_unit.dc_unit.sr_data_size_vec tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_0_V tb_stages.uut_AllAtOnce.core_unit.dc_unit.shift_sr_up tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_stage_next_vaild_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_exception tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_out tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_1_V tb_stages.uut_AllAtOnce.core_unit.dc_unit.dc_ST_OP tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.in_flight_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.exe_outs_i tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_served_mio tb_stages.uut_AllAtOnce.core_unit.dc_unit.arb_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.clk tb_stages.uut_AllAtOnce.core_unit.dc_unit.dc_outs_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.wb_outs_i tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_outs_i tb_stages.uut_AllAtOnce.core_unit.dc_unit.shift_sr_down tb_stages.uut_AllAtOnce.core_unit.dc_unit.dc_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.exe_ST_OP tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_exception {tb_stages.uut_AllAtOnce.core_unit.dc_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_unit.next_st_addr_0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.next_st_xcl tb_stages.uut_AllAtOnce.core_unit.dc_unit.next_st_addr_1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.wb_ST_OP tb_stages.uut_AllAtOnce.core_unit.dc_unit.rst }

gui_sg_move "$_session_group_116" -after "$_session_group_115" -pos 4 

set _session_group_117 $_session_group_116|
append _session_group_117 stq_dep_check
gui_sg_create "$_session_group_117"
set stages|dc_unit|stq_dep_check "$_session_group_117"

gui_sg_addsignal -group "$_session_group_117" { {tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.valid tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.ld_paddr_0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.ld_paddr_1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.LD_OP tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.LD_XCL tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.ld0_bank_num tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.ld1_bank_num tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.ld0_bank_hit tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.ld1_bank_hit tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.valid_dep0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.valid_dep1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.stq_info }

gui_sg_move "$_session_group_117" -after "$_session_group_116" -pos 7 

set _session_group_118 $_session_group_116|
append _session_group_118 req_gen_1
gui_sg_create "$_session_group_118"
set stages|dc_unit|req_gen_1 "$_session_group_118"

gui_sg_addsignal -group "$_session_group_118" { tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.is_served_mio tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_addr_mio_V tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.dep_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.req_served_0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.req_served_1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.mem_stage_we_valid_unit_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_addr_mio tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.XCL tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.MIO tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_addr_0_V tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_0_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_addrMIO tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.forward_valid tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_addr0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_addr1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.is_served_0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_addr_1_V tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.is_served_1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_addr_0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_addr_1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.req_served_mio tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.valid tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.arb_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.clk tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.mio_stall {tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_1_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.mem_stage_next_valid_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.LD_OP tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.rst }

gui_sg_move "$_session_group_118" -after "$_session_group_116" -pos 4 

set _session_group_119 $_session_group_116|
append _session_group_119 ld_neuralnet_part2
gui_sg_create "$_session_group_119"
set stages|dc_unit|ld_neuralnet_part2 "$_session_group_119"

gui_sg_addsignal -group "$_session_group_119" { {tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.vaddy_start tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.seg_limit_w_datasize tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.datasize tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.write_intent tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.mem_op tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.next_page_vaddy tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.vaddy_end tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.cross_page_access tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb0_pagefault tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb0_generalprotection tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb1_pagefault tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb1_generalprotection tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.segx_gp tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.outputs tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.vaddy_start_fields tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.vaddy_end_fields tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb0_in tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb1_in tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb0_out tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb1_out }

gui_sg_move "$_session_group_119" -after "$_session_group_116" -pos 3 

set _session_group_120 $_session_group_116|
append _session_group_120 st_neuralnet_part2
gui_sg_create "$_session_group_120"
set stages|dc_unit|st_neuralnet_part2 "$_session_group_120"

gui_sg_addsignal -group "$_session_group_120" { {tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.vaddy_start tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.seg_limit_w_datasize tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.datasize tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.write_intent tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.mem_op tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.next_page_vaddy tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.vaddy_end tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.cross_page_access tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb0_pagefault tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb0_generalprotection tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb1_pagefault tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb1_generalprotection tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.segx_gp tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.outputs tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.vaddy_start_fields tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.vaddy_end_fields tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb0_in tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb1_in tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb0_out tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb1_out }

gui_sg_move "$_session_group_120" -after "$_session_group_116" -pos 2 

set _session_group_121 $_session_group_115|
append _session_group_121 rr_unit
gui_sg_create "$_session_group_121"
set stages|rr_unit "$_session_group_121"

gui_sg_addsignal -group "$_session_group_121" { tb_stages.uut_AllAtOnce.core_unit.rr_unit.fetch_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.next_ld_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.cs_sb tb_stages.uut_AllAtOnce.core_unit.rr_unit.RR_GP tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_input_addy tb_stages.uut_AllAtOnce.core_unit.rr_unit.ecx_sb tb_stages.uut_AllAtOnce.core_unit.rr_unit.ld_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.next_dc_valid tb_stages.uut_AllAtOnce.core_unit.rr_unit.latches_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.dc_latches_next tb_stages.uut_AllAtOnce.core_unit.rr_unit.seg0_limit_w_datasize tb_stages.uut_AllAtOnce.core_unit.rr_unit.seg1_limit_w_datasize tb_stages.uut_AllAtOnce.core_unit.rr_unit.latchesInUse tb_stages.uut_AllAtOnce.core_unit.rr_unit.SEGMENT_LIMITS tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_out tb_stages.uut_AllAtOnce.core_unit.rr_unit.instructionforward tb_stages.uut_AllAtOnce.core_unit.rr_unit.rr_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.dc_latches_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.dc_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.exe_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.outs_o tb_stages.uut_AllAtOnce.core_unit.rr_unit.clk tb_stages.uut_AllAtOnce.core_unit.rr_unit.wb_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.mem_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.depstall {tb_stages.uut_AllAtOnce.core_unit.rr_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.rr_unit.actual_st_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.rst tb_stages.uut_AllAtOnce.core_unit.rr_unit.decode_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.actual_next_st_vaddy }

gui_sg_move "$_session_group_121" -after "$_session_group_115" -pos 3 

set _session_group_122 $_session_group_121|
append _session_group_122 addygen_logic_unit
gui_sg_create "$_session_group_122"
set stages|rr_unit|addygen_logic_unit "$_session_group_122"

gui_sg_addsignal -group "$_session_group_122" { {tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.register_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.regout_sr_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.regout_dr_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.SIB_IDX_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.SIB_BASE_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.SIB_SCALE_val tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.sib_needed tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.disp_needed tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.dispsize tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.special_modrm_bs tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.displacement tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.datasize tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.seg0_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.seg1_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.seg1_valid tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.modrm_needed tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.rm_is_dr tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.st_sel tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.movs_op tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.ld_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.seg0_limit_w_datasize tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.next_ld_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.actual_st_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.seg1_limit_w_datasize tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.actual_next_st_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.displacement_out tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.sib_or_reg tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.sib_nonsense tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.shift_result tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.real_seg1_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.seg0val_plus_displacement tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.seg1val_plus_displacement tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.st_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.shifted_sr_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.shifted_dr_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.shifted_seg1_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.next_ld_VPN tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.next_st_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.next_st_VPN tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.next_shifted_sr_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.next_shifted_sr_VPN tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.next_shifted_dr_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.next_shifted_dr_VPN tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.segment0_limit tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_logic_unit.segment1_limit }

gui_sg_move "$_session_group_122" -after "$_session_group_121" -pos 1 

set _session_group_123 $_session_group_115|
append _session_group_123 decode_unit
gui_sg_create "$_session_group_123"
set stages|decode_unit "$_session_group_123"

gui_sg_addsignal -group "$_session_group_123" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.EIP tb_stages.uut_AllAtOnce.core_unit.decode_unit.clk tb_stages.uut_AllAtOnce.core_unit.decode_unit.rst tb_stages.uut_AllAtOnce.core_unit.decode_unit.PrevEIP tb_stages.uut_AllAtOnce.core_unit.decode_unit.NEIP tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_length tb_stages.uut_AllAtOnce.core_unit.decode_unit.PrevLength tb_stages.uut_AllAtOnce.core_unit.decode_unit.sib_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.sib_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.disp_needed tb_stages.uut_AllAtOnce.core_unit.decode_unit.displacement tb_stages.uut_AllAtOnce.core_unit.decode_unit.disp_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.imm64 tb_stages.uut_AllAtOnce.core_unit.decode_unit.total_pf_vector tb_stages.uut_AllAtOnce.core_unit.decode_unit.invalid_inst tb_stages.uut_AllAtOnce.core_unit.decode_unit.opcode_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.modrm_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_gp tb_stages.uut_AllAtOnce.core_unit.decode_unit.flush tb_stages.uut_AllAtOnce.core_unit.decode_unit.REP_LATCH tb_stages.uut_AllAtOnce.core_unit.decode_unit.REP_CMP_LATCH tb_stages.uut_AllAtOnce.core_unit.decode_unit.REP_MOV_LATCH tb_stages.uut_AllAtOnce.core_unit.decode_unit.HALT_REG tb_stages.uut_AllAtOnce.core_unit.decode_unit.rr_latch_we_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.stall tb_stages.uut_AllAtOnce.core_unit.decode_unit.queue tb_stages.uut_AllAtOnce.core_unit.decode_unit.predicted_taken tb_stages.uut_AllAtOnce.core_unit.decode_unit.predicted_target tb_stages.uut_AllAtOnce.core_unit.decode_unit.branch_present tb_stages.uut_AllAtOnce.core_unit.decode_unit.sibbase tb_stages.uut_AllAtOnce.core_unit.decode_unit.sibidx tb_stages.uut_AllAtOnce.core_unit.decode_unit.sibscale tb_stages.uut_AllAtOnce.core_unit.decode_unit.clear_rep tb_stages.uut_AllAtOnce.core_unit.decode_unit.next_rr_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.segment0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.idm_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.fetch_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.rr_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.dc_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.mem_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.exe_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.wb_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.rr_latches_next tb_stages.uut_AllAtOnce.core_unit.decode_unit.outs_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_decode_cs tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_rr_cs tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_dc_cs tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_mem_cs tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_exe_cs tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_wb_cs tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_rr_latch tb_stages.uut_AllAtOnce.core_unit.decode_unit.br_info_for_latches tb_stages.uut_AllAtOnce.core_unit.decode_unit.rep_latch_holder }

gui_sg_move "$_session_group_123" -after "$_session_group_115" -pos 2 

set _session_group_124 $_session_group_123|
append _session_group_124 cs_post_prossesing_unit
gui_sg_create "$_session_group_124"
set stages|decode_unit|cs_post_prossesing_unit "$_session_group_124"

gui_sg_addsignal -group "$_session_group_124" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.invalid_inst tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.xchg tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.cmpxchg tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.op_in_modrm tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.op_in_modrm_subset tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.modrm_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.overriden_op_type tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.overriden_br_sel tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.reg_field tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.ff_jmp tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.ff_push tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.ff_call tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.decode_cs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.rr_cs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.dc_cs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.mem_cs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.exe_cs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.wb_cs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.decode_cs_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.rr_cs_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.dc_cs_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.mem_cs_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.exe_cs_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.wb_cs_o }

gui_sg_move "$_session_group_124" -after "$_session_group_123" -pos 5 

set _session_group_125 $_session_group_123|
append _session_group_125 mod_rm_cs_gen
gui_sg_create "$_session_group_125"
set stages|decode_unit|mod_rm_cs_gen "$_session_group_125"

gui_sg_addsignal -group "$_session_group_125" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.modrm_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.datasize tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.dr_id tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.sr_id tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.dr_rd tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.sr_rd tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.dr_wr tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.sr_wr tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.ld_op_unmasked tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.st_op_unmasked tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.ld_op tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.st_op tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.rm_is_dr tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.reg_is_dr tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.reg_is_segment tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.modrm_but_no_sr tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.alu_inputA_override tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.alu_inputB_override tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.dr_high8 tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.sr_high8 tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.alu_inputA_override_sel tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.alu_inputB_override_sel tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.decode_cs_inputs tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.outputs }

gui_sg_move "$_session_group_125" -after "$_session_group_123" -pos 4 

set _session_group_126 $_session_group_115|
append _session_group_126 idm_unit
gui_sg_create "$_session_group_126"
set stages|idm_unit "$_session_group_126"

gui_sg_addsignal -group "$_session_group_126" { tb_stages.uut_AllAtOnce.core_unit.idm_unit.fetch_outs_i tb_stages.uut_AllAtOnce.core_unit.idm_unit.idm_outs_o tb_stages.uut_AllAtOnce.core_unit.idm_unit.clk tb_stages.uut_AllAtOnce.core_unit.idm_unit.idm {tb_stages.uut_AllAtOnce.core_unit.idm_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.idm_unit.rst }

gui_sg_move "$_session_group_126" -after "$_session_group_115" -pos 1 

set _session_group_127 $_session_group_115|
append _session_group_127 execute_unit
gui_sg_create "$_session_group_127"
set stages|execute_unit "$_session_group_127"

gui_sg_addsignal -group "$_session_group_127" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.latches_i.EIP tb_stages.uut_AllAtOnce.core_unit.execute_unit.rst tb_stages.uut_AllAtOnce.core_unit.execute_unit.clk tb_stages.uut_AllAtOnce.core_unit.execute_unit.latches_i.valid tb_stages.uut_AllAtOnce.core_unit.execute_unit.latches_i.cs.OP_TYPE tb_stages.uut_AllAtOnce.core_unit.execute_unit.outs_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_outs_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.latches_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.flags_reg tb_stages.uut_AllAtOnce.core_unit.execute_unit.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.latches_i.cs.alu_inputA_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.latches_i.cs.alu_inputB_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.dr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.sr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.eax_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.flush_mask tb_stages.uut_AllAtOnce.core_unit.execute_unit.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.sr_data_size_vec tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_latches_next_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.dr_next tb_stages.uut_AllAtOnce.core_unit.execute_unit.res_buf_next tb_stages.uut_AllAtOnce.core_unit.execute_unit.res_buf_selected tb_stages.uut_AllAtOnce.core_unit.execute_unit.next_wb_cs tb_stages.uut_AllAtOnce.core_unit.execute_unit.bit_vec_0_next tb_stages.uut_AllAtOnce.core_unit.execute_unit.bit_vec_1_next tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_stage_we_valid_unit_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.branch_resolution_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.df_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.af_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.pf_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.cf_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.sf_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.of_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.zf_flag_o }

gui_sg_move "$_session_group_127" -after "$_session_group_115" -pos 6 

set _session_group_128 $_session_group_127|
append _session_group_128 u_alu_input_sel
gui_sg_create "$_session_group_128"
set stages|execute_unit|u_alu_input_sel "$_session_group_128"

gui_sg_addsignal -group "$_session_group_128" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.br_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.EIP tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.dr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.shift_sr_up tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.sr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.imm64 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.flags tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.ld_addr_0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.NEIP tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.alu_inputB_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.alu_inputA_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.EAX tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.br_input_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.shift_sr_down tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.res_buf_offset tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.srA_64 {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.res_buf_out tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.srB_64 }

gui_sg_move "$_session_group_128" -after "$_session_group_127" -pos 75 

set _session_group_129 $_session_group_127|
append _session_group_129 u_and_op
gui_sg_create "$_session_group_129"
set stages|execute_unit|u_and_op "$_session_group_129"

gui_sg_addsignal -group "$_session_group_129" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.and_result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.merged_result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.ld_16 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.ld_32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.ld_8 }

gui_sg_move "$_session_group_129" -after "$_session_group_127" -pos 74 

set _session_group_130 $_session_group_127|
append _session_group_130 u_bit_vec_logic
gui_sg_create "$_session_group_130"
set stages|execute_unit|u_bit_vec_logic "$_session_group_130"

gui_sg_addsignal -group "$_session_group_130" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.st_addr_0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.ST_XCL tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.st_vec0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.st_vec1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.num_bytes tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.start_offset tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.offset_xcl tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.end_of_st_addr_1 }

gui_sg_move "$_session_group_130" -after "$_session_group_127" -pos 73 

set _session_group_131 $_session_group_127|
append _session_group_131 u_br_res
gui_sg_create "$_session_group_131"
set stages|execute_unit|u_br_res "$_session_group_131"

gui_sg_addsignal -group "$_session_group_131" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.stage_valid_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_info_valid_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.flush_mask tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_eip_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_xcl_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_pred_taken_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.speculative_target_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_ucond_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.relative_branch_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.special_br_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.is_far_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.is_call_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.second_flag_needed_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_source_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.NEIP_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_rel_target tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.valid tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.taken tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.clr_exp_mode tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.flush tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.miss_prediction tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.second_flag_result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.cond_br_res tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.target_match tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.farFlush tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.callFlush tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.outs_o }

gui_sg_move "$_session_group_131" -after "$_session_group_127" -pos 72 

set _session_group_132 $_session_group_127|
append _session_group_132 u_bsf
gui_sg_create "$_session_group_132"
set stages|execute_unit|u_bsf "$_session_group_132"

gui_sg_addsignal -group "$_session_group_132" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.op32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.op16 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.index32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.index16 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.found32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.found16 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.result32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.result16 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.ZF32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.ZF16 }

gui_sg_move "$_session_group_132" -after "$_session_group_127" -pos 71 

set _session_group_133 $_session_group_127|
append _session_group_133 u_call_op
gui_sg_create "$_session_group_133"
set stages|execute_unit|u_call_op "$_session_group_133"

gui_sg_addsignal -group "$_session_group_133" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_call_op.NEIP tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_call_op.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_call_op.sr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_call_op.res_buf }

gui_sg_move "$_session_group_133" -after "$_session_group_127" -pos 70 

set _session_group_134 $_session_group_127|
append _session_group_134 u_cf_flag_sel
gui_sg_create "$_session_group_134"
set stages|execute_unit|u_cf_flag_sel "$_session_group_134"

gui_sg_addsignal -group "$_session_group_134" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.aaa_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.adc_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.add_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.and_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.cmp_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.cmpxchg_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.or_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.sal_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.sar_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.sbb_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.iretd_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.curr_cf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.cf_flag_o }

gui_sg_move "$_session_group_134" -after "$_session_group_127" -pos 69 

set _session_group_135 $_session_group_127|
append _session_group_135 u_cmp
gui_sg_create "$_session_group_135"
set stages|execute_unit|u_cmp "$_session_group_135"

gui_sg_addsignal -group "$_session_group_135" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.low_sr_val tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.al_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.ax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.eax_sum }

gui_sg_move "$_session_group_135" -after "$_session_group_127" -pos 68 

set _session_group_136 $_session_group_127|
append _session_group_136 u_cmpxchg_op
gui_sg_create "$_session_group_136"
set stages|execute_unit|u_cmpxchg_op "$_session_group_136"

gui_sg_addsignal -group "$_session_group_136" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.r_upper tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.rm_low tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.sr_data_size_vec tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.rm tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.r tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.EAX_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.next_dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.next_EAX tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.r_low tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.EAX tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.SF {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.ZF }

gui_sg_move "$_session_group_136" -after "$_session_group_127" -pos 67 

set _session_group_137 $_session_group_127|
append _session_group_137 u_df_flag_sel
gui_sg_create "$_session_group_137"
set stages|execute_unit|u_df_flag_sel "$_session_group_137"

gui_sg_addsignal -group "$_session_group_137" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_df_flag_sel.curr_df_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_df_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_df_flag_sel.df_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_df_flag_sel.next_df_flag }

gui_sg_move "$_session_group_137" -after "$_session_group_127" -pos 66 

set _session_group_138 $_session_group_127|
append _session_group_138 u_dr_sel
gui_sg_create "$_session_group_138"
set stages|execute_unit|u_dr_sel "$_session_group_138"

gui_sg_addsignal -group "$_session_group_138" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.aaa_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.adc_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.add_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.and_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.bsf_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.cmpxchg_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.mov_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.not_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.or_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.packssdw_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.packsswb_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.paddd_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.paddw_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.pavgb_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.pavgw_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.pop_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.ret_far_imm_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.sal_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.sar_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.sbb_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.xchg_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.dr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.dr_o }

gui_sg_move "$_session_group_138" -after "$_session_group_127" -pos 65 

set _session_group_139 $_session_group_127|
append _session_group_139 u_far_op
gui_sg_create "$_session_group_139"
set stages|execute_unit|u_far_op "$_session_group_139"

gui_sg_addsignal -group "$_session_group_139" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_far_op.neip tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_far_op.segment tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_far_op.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_far_op.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_far_op.sr_o }

gui_sg_move "$_session_group_139" -after "$_session_group_127" -pos 64 

set _session_group_140 $_session_group_127|
append _session_group_140 u_iretd_op
gui_sg_create "$_session_group_140"
set stages|execute_unit|u_iretd_op "$_session_group_140"

gui_sg_addsignal -group "$_session_group_140" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.cs tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.flags tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.sr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.OF }

gui_sg_move "$_session_group_140" -after "$_session_group_127" -pos 63 

set _session_group_141 $_session_group_127|
append _session_group_141 u_mov_op
gui_sg_create "$_session_group_141"
set stages|execute_unit|u_mov_op "$_session_group_141"

gui_sg_addsignal -group "$_session_group_141" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.merged_res tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.curr_cf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.masked_data_size {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.res_buf_o }

gui_sg_move "$_session_group_141" -after "$_session_group_127" -pos 62 

set _session_group_142 $_session_group_127|
append _session_group_142 u_not_op
gui_sg_create "$_session_group_142"
set stages|execute_unit|u_not_op "$_session_group_142"

gui_sg_addsignal -group "$_session_group_142" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op.out_32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op.merged_res }

gui_sg_move "$_session_group_142" -after "$_session_group_127" -pos 61 

set _session_group_143 $_session_group_127|
append _session_group_143 u_of_flag_sel
gui_sg_create "$_session_group_143"
set stages|execute_unit|u_of_flag_sel "$_session_group_143"

gui_sg_addsignal -group "$_session_group_143" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.adc_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.add_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.and_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.cmp_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.cmpxchg_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.or_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.sal_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.sar_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.sbb_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.iretd_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.curr_of_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.of_flag_o }

gui_sg_move "$_session_group_143" -after "$_session_group_127" -pos 60 

set _session_group_144 $_session_group_127|
append _session_group_144 u_or_op
gui_sg_create "$_session_group_144"
set stages|execute_unit|u_or_op "$_session_group_144"

gui_sg_addsignal -group "$_session_group_144" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.or_result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.merged_result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.zf_low8 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.zf_up8 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.zf_up16 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.zf_low16 }

gui_sg_move "$_session_group_144" -after "$_session_group_127" -pos 59 

set _session_group_145 $_session_group_127|
append _session_group_145 u_packssdw
gui_sg_create "$_session_group_145"
set stages|execute_unit|u_packssdw "$_session_group_145"

gui_sg_addsignal -group "$_session_group_145" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.a0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.a1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.b0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.b1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.r0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.r1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.r2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.r3 }

gui_sg_move "$_session_group_145" -after "$_session_group_127" -pos 58 

set _session_group_146 $_session_group_127|
append _session_group_146 u_packsswb
gui_sg_create "$_session_group_146"
set stages|execute_unit|u_packsswb "$_session_group_146"

gui_sg_addsignal -group "$_session_group_146" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.a0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.a1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.a2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.a3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.b0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.b1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.b2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.b3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r4 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r5 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r6 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r7 }

gui_sg_move "$_session_group_146" -after "$_session_group_127" -pos 57 

set _session_group_147 $_session_group_127|
append _session_group_147 u_paddd
gui_sg_create "$_session_group_147"
set stages|execute_unit|u_paddd "$_session_group_147"

gui_sg_addsignal -group "$_session_group_147" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.a0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.a1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.b0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.b1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.r0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.r1 }

gui_sg_move "$_session_group_147" -after "$_session_group_127" -pos 56 

set _session_group_148 $_session_group_127|
append _session_group_148 u_paddw
gui_sg_create "$_session_group_148"
set stages|execute_unit|u_paddw "$_session_group_148"

gui_sg_addsignal -group "$_session_group_148" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.a0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.a1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.a2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.a3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.b0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.b1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.b2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.b3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.r0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.r1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.r2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.r3 }

gui_sg_move "$_session_group_148" -after "$_session_group_127" -pos 55 

set _session_group_149 $_session_group_127|
append _session_group_149 u_pavgb
gui_sg_create "$_session_group_149"
set stages|execute_unit|u_pavgb "$_session_group_149"

gui_sg_addsignal -group "$_session_group_149" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a4 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a5 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a6 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a7 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b4 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b5 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b6 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b7 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s4 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s5 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s6 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s7 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r4 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r5 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r6 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r7 }

gui_sg_move "$_session_group_149" -after "$_session_group_127" -pos 54 

set _session_group_150 $_session_group_127|
append _session_group_150 u_pavgw
gui_sg_create "$_session_group_150"
set stages|execute_unit|u_pavgw "$_session_group_150"

gui_sg_addsignal -group "$_session_group_150" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.a0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.a1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.a2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.a3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.b0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.b1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.b2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.b3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.s0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.s1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.s2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.s3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.r0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.r1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.r2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.r3 }

gui_sg_move "$_session_group_150" -after "$_session_group_127" -pos 53 

set _session_group_151 $_session_group_127|
append _session_group_151 u_pf_flag_sel
gui_sg_create "$_session_group_151"
set stages|execute_unit|u_pf_flag_sel "$_session_group_151"

gui_sg_addsignal -group "$_session_group_151" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.adc_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.add_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.and_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.cmp_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.cmpxchg_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.or_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.sal_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.sar_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.sbb_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.iretd_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.curr_pf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.pf_flag_o }

gui_sg_move "$_session_group_151" -after "$_session_group_127" -pos 52 

set _session_group_152 $_session_group_127|
append _session_group_152 u_pop_op
gui_sg_create "$_session_group_152"
set stages|execute_unit|u_pop_op "$_session_group_152"

gui_sg_addsignal -group "$_session_group_152" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pop_op.value_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pop_op.sp_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pop_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pop_op.sr_o }

gui_sg_move "$_session_group_152" -after "$_session_group_127" -pos 51 

set _session_group_153 $_session_group_127|
append _session_group_153 u_push_op
gui_sg_create "$_session_group_153"
set stages|execute_unit|u_push_op "$_session_group_153"

gui_sg_addsignal -group "$_session_group_153" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.sp tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.data_size_vec tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.value tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.sr_o {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.num_bytes }

gui_sg_move "$_session_group_153" -after "$_session_group_127" -pos 50 

set _session_group_154 $_session_group_127|
append _session_group_154 u_res_buf_logic
gui_sg_create "$_session_group_154"
set stages|execute_unit|u_res_buf_logic "$_session_group_154"

gui_sg_addsignal -group "$_session_group_154" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_logic.res_info_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_logic.st_addr_0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_logic.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_logic.offset }

gui_sg_move "$_session_group_154" -after "$_session_group_127" -pos 49 

set _session_group_155 $_session_group_127|
append _session_group_155 u_res_buf_sel
gui_sg_create "$_session_group_155"
set stages|execute_unit|u_res_buf_sel "$_session_group_155"

gui_sg_addsignal -group "$_session_group_155" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.adc_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.add_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.and_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.call_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.cmpxchg_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.far_call_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.mov_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.not_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.or_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.push_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.sar_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.sbb_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.xchg_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.res_buf_o }

gui_sg_move "$_session_group_155" -after "$_session_group_127" -pos 48 

set _session_group_156 $_session_group_127|
append _session_group_156 u_ret_far_imm
gui_sg_create "$_session_group_156"
set stages|execute_unit|u_ret_far_imm "$_session_group_156"

gui_sg_addsignal -group "$_session_group_156" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_imm.cs tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_imm.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_imm.imm64 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_imm.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_imm.sr_o }

gui_sg_move "$_session_group_156" -after "$_session_group_127" -pos 47 

set _session_group_157 $_session_group_127|
append _session_group_157 u_ret_far_op
gui_sg_create "$_session_group_157"
set stages|execute_unit|u_ret_far_op "$_session_group_157"

gui_sg_addsignal -group "$_session_group_157" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_op.cs tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_op.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_op.sr_o }

gui_sg_move "$_session_group_157" -after "$_session_group_127" -pos 46 

set _session_group_158 $_session_group_127|
append _session_group_158 u_ret_imm_op
gui_sg_create "$_session_group_158"
set stages|execute_unit|u_ret_imm_op "$_session_group_158"

gui_sg_addsignal -group "$_session_group_158" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_imm_op.imm64 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_imm_op.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_imm_op.sr_o }

gui_sg_move "$_session_group_158" -after "$_session_group_127" -pos 45 

set _session_group_159 $_session_group_127|
append _session_group_159 u_ret_op
gui_sg_create "$_session_group_159"
set stages|execute_unit|u_ret_op "$_session_group_159"

gui_sg_addsignal -group "$_session_group_159" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_op.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_op.sr_o }

gui_sg_move "$_session_group_159" -after "$_session_group_127" -pos 44 

set _session_group_160 $_session_group_127|
append _session_group_160 u_sbb_op
gui_sg_create "$_session_group_160"
set stages|execute_unit|u_sbb_op "$_session_group_160"

gui_sg_addsignal -group "$_session_group_160" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.CF_in tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.al_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.ax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.ah_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.SF {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.eax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.ZF }

gui_sg_move "$_session_group_160" -after "$_session_group_127" -pos 43 

set _session_group_161 $_session_group_127|
append _session_group_161 u_sf_flag_sel
gui_sg_create "$_session_group_161"
set stages|execute_unit|u_sf_flag_sel "$_session_group_161"

gui_sg_addsignal -group "$_session_group_161" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.add_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.adc_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.and_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.cmp_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.cmpxchg_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.or_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.sal_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.sar_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.sbb_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.iretd_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.curr_sf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.sf_flag_o }

gui_sg_move "$_session_group_161" -after "$_session_group_127" -pos 42 

set _session_group_162 $_session_group_127|
append _session_group_162 u_sr_sel
gui_sg_create "$_session_group_162"
set stages|execute_unit|u_sr_sel "$_session_group_162"

gui_sg_addsignal -group "$_session_group_162" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.sr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.pop_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.push_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.ret_far_imm_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.ret_imm_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.ret_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.xchg_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.call_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.far_call_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.sr_o }

gui_sg_move "$_session_group_162" -after "$_session_group_127" -pos 41 

set _session_group_163 $_session_group_127|
append _session_group_163 u_xchg_op
gui_sg_create "$_session_group_163"
set stages|execute_unit|u_xchg_op "$_session_group_163"

gui_sg_addsignal -group "$_session_group_163" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.sr_data_size_vec tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.sr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.new_rm_value tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.new_r32_val tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.new_rm_low_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.new_rm_upper_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.new_r32_low_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.new_r32_upper_sel }

gui_sg_move "$_session_group_163" -after "$_session_group_127" -pos 40 

set _session_group_164 $_session_group_127|
append _session_group_164 u_zf_flag_sel
gui_sg_create "$_session_group_164"
set stages|execute_unit|u_zf_flag_sel "$_session_group_164"

gui_sg_addsignal -group "$_session_group_164" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.adc_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.add_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.and_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.bsf_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.cmp_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.cmpxchg_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.or_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.sal_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.sar_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.sbb_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.iretd_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.curr_zf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.zf_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.clr_ZF_sb }

gui_sg_move "$_session_group_164" -after "$_session_group_127" -pos 39 

set _session_group_165 $_session_group_127|
append _session_group_165 wb_valid_logic_unit
gui_sg_create "$_session_group_165"
set stages|execute_unit|wb_valid_logic_unit "$_session_group_165"

gui_sg_addsignal -group "$_session_group_165" { {tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.WB_we_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.N_WB_V_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.EXE_V_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.WB_stall_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.WB_stall_i_inv tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.WB_we_o_and_buf_mid tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.N_WB_V_o_and_buf_mid }

gui_sg_move "$_session_group_165" -after "$_session_group_127" -pos 38 

set _session_group_166 $_session_group_127|
append _session_group_166 u_sal_op
gui_sg_create "$_session_group_166"
set stages|execute_unit|u_sal_op "$_session_group_166"

gui_sg_addsignal -group "$_session_group_166" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.shift_by_one tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.curr_sf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.sr_data_size_vec tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.curr_of_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.curr_zf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.shift_amt_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.curr_cf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.curr_af_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.count tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.value_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.curr_pf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.SF {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.ZF }

gui_sg_move "$_session_group_166" -after "$_session_group_127" -pos 37 

set _session_group_167 $_session_group_127|
append _session_group_167 u_add_op
gui_sg_create "$_session_group_167"
set stages|execute_unit|u_add_op "$_session_group_167"

gui_sg_addsignal -group "$_session_group_167" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.al_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.ah_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.ax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.eax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.af_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.merged_result }

gui_sg_move "$_session_group_167" -after "$_session_group_127" -pos 77 

set _session_group_168 $_session_group_127|
append _session_group_168 u_sar_op
gui_sg_create "$_session_group_168"
set stages|execute_unit|u_sar_op "$_session_group_168"

gui_sg_addsignal -group "$_session_group_168" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.shift_by_one tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.shift_amt_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.count tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.value_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.SF {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.sr_data_size_vec tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.curr_zf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.curr_sf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.curr_pf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.curr_of_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.curr_cf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.curr_af_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.AF }

gui_sg_move "$_session_group_168" -after "$_session_group_127" -pos 36 

set _session_group_169 $_session_group_127|
append _session_group_169 u_aaa
gui_sg_create "$_session_group_169"
set stages|execute_unit|u_aaa "$_session_group_169"

gui_sg_addsignal -group "$_session_group_169" { {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.EAX_in tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.AF_flag_in tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.adjust tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.AL tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.AH tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.AX_new }

gui_sg_move "$_session_group_169" -after "$_session_group_127" -pos 79 

set _session_group_170 $_session_group_127|
append _session_group_170 u_adc_op
gui_sg_create "$_session_group_170"
set stages|execute_unit|u_adc_op "$_session_group_170"

gui_sg_addsignal -group "$_session_group_170" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.CF_in tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.sum }

gui_sg_move "$_session_group_170" -after "$_session_group_127" -pos 78 

set _session_group_171 $_session_group_127|
append _session_group_171 u_af_flag_sel
gui_sg_create "$_session_group_171"
set stages|execute_unit|u_af_flag_sel "$_session_group_171"

gui_sg_addsignal -group "$_session_group_171" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.aaa_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.adc_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.add_op_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.cmp_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.cmpxchg_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.sbb_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.iretd_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.curr_af_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.af_flag_o }

gui_sg_move "$_session_group_171" -after "$_session_group_127" -pos 76 

set _session_group_172 $_session_group_115|
append _session_group_172 write_back_unit
gui_sg_create "$_session_group_172"
set stages|write_back_unit "$_session_group_172"

gui_sg_addsignal -group "$_session_group_172" { tb_stages.uut_AllAtOnce.core_unit.write_back_unit.write_success tb_stages.uut_AllAtOnce.core_unit.write_back_unit.reg_wb_logic_outs tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stq_info tb_stages.uut_AllAtOnce.core_unit.write_back_unit.mio_q_output tb_stages.uut_AllAtOnce.core_unit.write_back_unit.mio_push_fail tb_stages.uut_AllAtOnce.core_unit.write_back_unit.write_success_mio tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stq_heads tb_stages.uut_AllAtOnce.core_unit.write_back_unit.wb_latches tb_stages.uut_AllAtOnce.core_unit.write_back_unit.outputs tb_stages.uut_AllAtOnce.core_unit.write_back_unit.mio_q_input tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stq_outputs tb_stages.uut_AllAtOnce.core_unit.write_back_unit.dc_dep tb_stages.uut_AllAtOnce.core_unit.write_back_unit.clk tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stall_flop_next tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stall_flop {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.write_back_unit.rst }

gui_sg_move "$_session_group_172" -after "$_session_group_115" -pos 7 

set _session_group_173 $_session_group_172|
append _session_group_173 {gen_st_q[2].stq_inst}
gui_sg_create "$_session_group_173"
set {stages|write_back_unit|gen_st_q[2].stq_inst} "$_session_group_173"

gui_sg_addsignal -group "$_session_group_173" { {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.q_empty} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.clk} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.rst} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.head} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.tail} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.head_ptr} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.tail_ptr} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.q_full} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.valid_push} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.valid_pop} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.wb_in} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.outputs} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.q} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.unnamed$$_10} }

gui_sg_move "$_session_group_173" -after "$_session_group_172" -pos 8 

set _session_group_174 $_session_group_172|
append _session_group_174 {gen_st_q[3].stq_inst}
gui_sg_create "$_session_group_174"
set {stages|write_back_unit|gen_st_q[3].stq_inst} "$_session_group_174"

gui_sg_addsignal -group "$_session_group_174" { {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.$unit} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.q_empty} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.clk} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.rst} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.head} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.tail} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.head_ptr} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.tail_ptr} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.q_full} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.valid_push} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.valid_pop} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.wb_in} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.outputs} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.q} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.unnamed$$_10} }

gui_sg_move "$_session_group_174" -after "$_session_group_172" -pos 6 

set _session_group_175 $_session_group_172|
append _session_group_175 {gen_st_q[1].stq_inst}
gui_sg_create "$_session_group_175"
set {stages|write_back_unit|gen_st_q[1].stq_inst} "$_session_group_175"

gui_sg_addsignal -group "$_session_group_175" { {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.q_empty} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.clk} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.rst} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.head} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.tail} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.head_ptr} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.tail_ptr} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.q_full} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.valid_push} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.valid_pop} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.wb_in} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.outputs} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.q} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.unnamed$$_10} }

gui_sg_move "$_session_group_175" -after "$_session_group_172" -pos 2 

set _session_group_176 $_session_group_172|
append _session_group_176 {gen_st_q[0].stq_inst}
gui_sg_create "$_session_group_176"
set {stages|write_back_unit|gen_st_q[0].stq_inst} "$_session_group_176"

gui_sg_addsignal -group "$_session_group_176" { {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.$unit} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.q_empty} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.clk} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.rst} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.head} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.tail} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.head_ptr} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.tail_ptr} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.q_full} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.valid_push} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.valid_pop} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.wb_in} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.outputs} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.q} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.unnamed$$_10} }

gui_sg_move "$_session_group_176" -after "$_session_group_172" -pos 4 

set _session_group_177 $_session_group_115|
append _session_group_177 fetch_unit
gui_sg_create "$_session_group_177"
set stages|fetch_unit "$_session_group_177"

gui_sg_addsignal -group "$_session_group_177" { {tb_stages.uut_AllAtOnce.core_unit.fetch_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.fetch_unit.SPC tb_stages.uut_AllAtOnce.core_unit.fetch_unit.clk tb_stages.uut_AllAtOnce.core_unit.fetch_unit.rst tb_stages.uut_AllAtOnce.core_unit.fetch_unit.dma_int tb_stages.uut_AllAtOnce.core_unit.fetch_unit.exp_mode_jk tb_stages.uut_AllAtOnce.core_unit.fetch_unit.int_mode_jk tb_stages.uut_AllAtOnce.core_unit.fetch_unit.DMA_int_jk tb_stages.uut_AllAtOnce.core_unit.fetch_unit.f_exp tb_stages.uut_AllAtOnce.core_unit.fetch_unit.seg_xlation_out tb_stages.uut_AllAtOnce.core_unit.fetch_unit.rom_data_out tb_stages.uut_AllAtOnce.core_unit.fetch_unit.idm_ctrl_data_in tb_stages.uut_AllAtOnce.core_unit.fetch_unit.next_spc tb_stages.uut_AllAtOnce.core_unit.fetch_unit.spc_16 tb_stages.uut_AllAtOnce.core_unit.fetch_unit.br_restore_spc tb_stages.uut_AllAtOnce.core_unit.fetch_unit.br_target tb_stages.uut_AllAtOnce.core_unit.fetch_unit.spc_2_IDM_CTRL tb_stages.uut_AllAtOnce.core_unit.fetch_unit.en_icache tb_stages.uut_AllAtOnce.core_unit.fetch_unit.icache_info_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.idm_info_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.decode_outs_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.rr_outs_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.dc_outs_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.mem_outs_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.exe_outs_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.wb_outs_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.outs_o tb_stages.uut_AllAtOnce.core_unit.fetch_unit.predictor_inputs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.tlb_inputs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.btb_outs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.spc_sel_logic_outs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.predictor_outs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.idm_ctrl_logic_outs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.idm_invalidate_logic_outs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.tlb_outs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.exp_set_logic_outs }

set _session_group_178 $_session_group_115|
append _session_group_178 mem_unit
gui_sg_create "$_session_group_178"
set stages|mem_unit "$_session_group_178"

gui_sg_addsignal -group "$_session_group_178" { tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_buf_v tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_1_masked tb_stages.uut_AllAtOnce.core_unit.mem_unit.C0 tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_buf_mio tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_MIO tb_stages.uut_AllAtOnce.core_unit.mem_unit.low_buf tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_0 tb_stages.uut_AllAtOnce.core_unit.mem_unit.br_rel_target tb_stages.uut_AllAtOnce.core_unit.mem_unit.latches_i tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_1 tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_buf_mio_v tb_stages.uut_AllAtOnce.core_unit.mem_unit.miss_stall tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_MIO tb_stages.uut_AllAtOnce.core_unit.mem_unit.cacheline tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_0_masked tb_stages.uut_AllAtOnce.core_unit.mem_unit.clr_dcache_mio_latch tb_stages.uut_AllAtOnce.core_unit.mem_unit.exe_latches_next_o tb_stages.uut_AllAtOnce.core_unit.mem_unit.forward_valid tb_stages.uut_AllAtOnce.core_unit.mem_unit.exe_stage_next_vaild_o tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_buf tb_stages.uut_AllAtOnce.core_unit.mem_unit.exe_outs_i tb_stages.uut_AllAtOnce.core_unit.mem_unit.outs_o tb_stages.uut_AllAtOnce.core_unit.mem_unit.clk tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_mio tb_stages.uut_AllAtOnce.core_unit.mem_unit.bank_num_0 tb_stages.uut_AllAtOnce.core_unit.mem_unit.wb_outs_i tb_stages.uut_AllAtOnce.core_unit.mem_unit.rel_offset tb_stages.uut_AllAtOnce.core_unit.mem_unit.bank_num_1 tb_stages.uut_AllAtOnce.core_unit.mem_unit.ld_buf tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit tb_stages.uut_AllAtOnce.core_unit.mem_unit.up_buf tb_stages.uut_AllAtOnce.core_unit.mem_unit.exe_stage_we_valid_unit_o {tb_stages.uut_AllAtOnce.core_unit.mem_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.mem_unit.clr_dcache_arb_latches tb_stages.uut_AllAtOnce.core_unit.mem_unit.next_st_addr_0 tb_stages.uut_AllAtOnce.core_unit.mem_unit.next_st_addr_1 tb_stages.uut_AllAtOnce.core_unit.mem_unit.rst }

gui_sg_move "$_session_group_178" -after "$_session_group_115" -pos 5 

# Global: Highlighting
gui_highlight_signals -color #00ff00 {{tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.dr_data[63:0]}}

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 314.17



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
catch {gui_list_expand -id ${Hier.1} tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit}
catch {gui_list_select -id ${Hier.1} {tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit}}
gui_view_scroll -id ${Hier.1} -vertical -set 600
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataStore_unit}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 600
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# DriverLoad 'DriverLoad.1'
gui_get_drivers -session -id ${DriverLoad.1} -signal tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches.valid -time 476 -starttime 477.846
gui_get_drivers -session -id ${DriverLoad.1} -signal {tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches.cs.OP_TYPE[31:0]} -time 476 -starttime 477.846
gui_get_drivers -session -id ${DriverLoad.1} -signal tb_stages.uut_AllAtOnce.core_unit.execute_unit.next_wb_cs -time 1212 -starttime 1479.979
gui_get_drivers -session -id ${DriverLoad.1} -signal {tb_stages.uut_AllAtOnce.core_unit.execute_unit.srA[63:0]} -time 1436 -starttime 1479.979

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_view_scroll -id ${Source.1} -vertical -set 0
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
gui_marker_create -id ${Wave.1} M3 5059.986
gui_marker_create -id ${Wave.1} M4 585.761
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 278.262 350.063
gui_list_add_group -id ${Wave.1} -after {New Group} {uut_AllAtOnce_1}
gui_list_add_group -id ${Wave.1} -after {New Group} {Mem_System}
gui_list_add_group -id ${Wave.1}  -after Mem_System {Mem_System|icache_dataStore_unit}
gui_list_add_group -id ${Wave.1} -after Mem_System|icache_dataStore_unit {Mem_System|icache_TagStore_unit}
gui_list_add_group -id ${Wave.1} -after Mem_System|icache_TagStore_unit {Mem_System|icache_unit}
gui_list_add_group -id ${Wave.1} -after Mem_System|icache_unit {Mem_System|mem_unit_1}
gui_list_add_group -id ${Wave.1} -after Mem_System|mem_unit_1 {Mem_System|dma_controller_unit}
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
gui_list_add_group -id ${Wave.1}  -after stages {stages|fetch_unit}
gui_list_add_group -id ${Wave.1} -after stages|fetch_unit {stages|idm_unit}
gui_list_add_group -id ${Wave.1} -after stages|idm_unit {stages|decode_unit}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.decode_unit.rst {stages|decode_unit|mod_rm_cs_gen}
gui_list_add_group -id ${Wave.1} -after stages|decode_unit|mod_rm_cs_gen {stages|decode_unit|cs_post_prossesing_unit}
gui_list_add_group -id ${Wave.1} -after stages|decode_unit {stages|rr_unit}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.rr_unit.fetch_outs_i {stages|rr_unit|addygen_logic_unit}
gui_list_add_group -id ${Wave.1} -after stages|rr_unit {stages|dc_unit}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.dc_unit.fetch_outs_i {stages|dc_unit|st_neuralnet_part2}
gui_list_add_group -id ${Wave.1} -after stages|dc_unit|st_neuralnet_part2 {stages|dc_unit|ld_neuralnet_part2}
gui_list_add_group -id ${Wave.1} -after stages|dc_unit|ld_neuralnet_part2 {stages|dc_unit|req_gen_1}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_mio_V {stages|dc_unit|stq_dep_check}
gui_list_add_group -id ${Wave.1} -after stages|dc_unit {stages|mem_unit}
gui_list_add_group -id ${Wave.1} -after stages|mem_unit {stages|execute_unit}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.execute_unit.zf_flag_o {stages|execute_unit|u_sar_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_sar_op {stages|execute_unit|u_sal_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_sal_op {stages|execute_unit|wb_valid_logic_unit}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|wb_valid_logic_unit {stages|execute_unit|u_zf_flag_sel}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_zf_flag_sel {stages|execute_unit|u_xchg_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_xchg_op {stages|execute_unit|u_sr_sel}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_sr_sel {stages|execute_unit|u_sf_flag_sel}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_sf_flag_sel {stages|execute_unit|u_sbb_op}
gui_list_add_group -id ${Wave.1} -after stages|execute_unit|u_sbb_op {stages|execute_unit|u_ret_op}
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
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.write_back_unit.reg_wb_logic_outs {{stages|write_back_unit|gen_st_q[1].stq_inst}}
gui_list_add_group -id ${Wave.1} -after {{tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stq_info[0:3]}} {{stages|write_back_unit|gen_st_q[0].stq_inst}}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.write_back_unit.mio_q_output {{stages|write_back_unit|gen_st_q[3].stq_inst}}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.write_back_unit.mio_push_fail {{stages|write_back_unit|gen_st_q[2].stq_inst}}
gui_list_collapse -id ${Wave.1} uut_AllAtOnce_1
gui_list_collapse -id ${Wave.1} Mem_System|icache_dataStore_unit
gui_list_collapse -id ${Wave.1} Mem_System|icache_TagStore_unit
gui_list_collapse -id ${Wave.1} Mem_System|icache_unit
gui_list_collapse -id ${Wave.1} Mem_System|mem_unit_1
gui_list_collapse -id ${Wave.1} Mem_System|dma_controller_unit
gui_list_collapse -id ${Wave.1} Mem_System|ddr5_unit
gui_list_collapse -id ${Wave.1} Mem_System|dcache_unit
gui_list_collapse -id ${Wave.1} Mem_System|bus_arbitration_unit
gui_list_collapse -id ${Wave.1} flags_reg
gui_list_collapse -id ${Wave.1} uut_stuff
gui_list_collapse -id ${Wave.1} Core
gui_list_collapse -id ${Wave.1} latches
gui_list_collapse -id ${Wave.1} stages
gui_list_expand -id ${Wave.1} tb_stages.uut_AllAtOnce.mem_sys_unit.core2icache_i
gui_list_select -id ${Wave.1} {tb_stages.uut_AllAtOnce.mem_sys_unit.addressBus }
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
gui_list_set_insertion_bar  -id ${Wave.1} -group Mem_System  -position in

gui_marker_move -id ${Wave.1} {C1} 314.17
gui_view_scroll -id ${Wave.1} -vertical -set 210
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

