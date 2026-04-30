# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Wed Apr 29 23:51:02 2026
# Designs open: 1
#   V1: vcdplus.vpd
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing
#   Wave.1: 1902 signals
#   Group count = 111
#   Group uut_AllAtOnce signal count = 9
#   Group uut_AllAtOnce_1 signal count = 9
#   Group Mem_System signal count = 26
#   Group flags_reg signal count = 3
#   Group uut_stuff signal count = 7
#   Group Core signal count = 1
#   Group latches signal count = 6
#   Group stages signal count = 8
# End_DVE_Session_Save_Info

# DVE version: T-2022.06_Full64
# DVE build date: May 31 2022 20:53:03


#<Session mode="Full" path="/misc/scratch/he3837/UARCH/uarch/design/EverythingEverywhereAllAtOnce/tests/Stages/Harish_StageTesting/session.vcdplus.vpd.tcl" type="Debug">

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
gui_show_window -window ${TopLevel.1} -show_state normal -rect {{248 191} {1525 837}}

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
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 430]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 430
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 429} {height 343} {dock_state left} {dock_on_new_line true} {child_hier_colhier 335} {child_hier_coltype 107} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 495]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 495
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 517
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 494} {height 343} {dock_state left} {dock_on_new_line true} {child_data_colvariable 279} {child_data_colvalue 57} {child_data_coltype 171} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 174]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value -1
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 174
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 355} {height 173} {dock_state bottom} {dock_on_new_line true}}
set DriverLoad.1 [gui_create_window -type DriverLoad -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line false -dock_extent 174]
gui_set_window_pref_key -window ${DriverLoad.1} -key dock_width -value_type integer -value 150
gui_set_window_pref_key -window ${DriverLoad.1} -key dock_height -value_type integer -value 174
gui_set_window_pref_key -window ${DriverLoad.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DriverLoad.1} {{left 0} {top 0} {width 921} {height 173} {dock_state bottom} {dock_on_new_line false}}
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
gui_show_window -window ${TopLevel.2} -show_state maximized -rect {{78 101} {1997 1116}}

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
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 665} {child_wave_right 1249} {child_wave_colname 309} {child_wave_colvalue 352} {child_wave_col1 0} {child_wave_col2 1}}

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
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.checker0}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_imm}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op}
gui_load_child_values {tb_stages.uut_AllAtOnce}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.sel_log1}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb0}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb1}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_logic}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.vec_gen}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_imm_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_far_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pop_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_call_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.mem_unit.mem_stall}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.idm_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.opcode_size}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_df_flag_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.num_pf_gen0}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.mod_size}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.write_back_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.adder0}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.fetch_unit}
gui_load_child_values {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel}
gui_load_child_values {tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit}


set _session_group_1957 uut_AllAtOnce
gui_sg_create "$_session_group_1957"
set uut_AllAtOnce "$_session_group_1957"

gui_sg_addsignal -group "$_session_group_1957" { {tb_stages.uut_AllAtOnce.$unit} tb_stages.uut_AllAtOnce.clk tb_stages.uut_AllAtOnce.rst tb_stages.uut_AllAtOnce.icache2core tb_stages.uut_AllAtOnce.core2icache tb_stages.uut_AllAtOnce.stq2dcache tb_stages.uut_AllAtOnce.core2dcache tb_stages.uut_AllAtOnce.dcache2core tb_stages.uut_AllAtOnce.dma2core }

set _session_group_1958 uut_AllAtOnce_1
gui_sg_create "$_session_group_1958"
set uut_AllAtOnce_1 "$_session_group_1958"

gui_sg_addsignal -group "$_session_group_1958" { tb_stages.uut_AllAtOnce.stq2dcache tb_stages.uut_AllAtOnce.icache2core tb_stages.uut_AllAtOnce.core2dcache tb_stages.uut_AllAtOnce.clk tb_stages.uut_AllAtOnce.core2icache tb_stages.uut_AllAtOnce.dma2core tb_stages.uut_AllAtOnce.dcache2core {tb_stages.uut_AllAtOnce.$unit} tb_stages.uut_AllAtOnce.rst }

set _session_group_1959 Mem_System
gui_sg_create "$_session_group_1959"
set Mem_System "$_session_group_1959"

gui_sg_addsignal -group "$_session_group_1959" { {tb_stages.uut_AllAtOnce.mem_sys_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.addressBus tb_stages.uut_AllAtOnce.mem_sys_unit.core2icache_i tb_stages.uut_AllAtOnce.mem_sys_unit.icache2core_o tb_stages.uut_AllAtOnce.mem_sys_unit.core2dcache_i tb_stages.uut_AllAtOnce.mem_sys_unit.dcache2core_o tb_stages.uut_AllAtOnce.mem_sys_unit.dma2core_o tb_stages.uut_AllAtOnce.mem_sys_unit.icache_2_sched tb_stages.uut_AllAtOnce.mem_sys_unit.dte_2_icache tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_2_sched tb_stages.uut_AllAtOnce.mem_sys_unit.dte_2_dcache tb_stages.uut_AllAtOnce.mem_sys_unit.mem_2_sched tb_stages.uut_AllAtOnce.mem_sys_unit.mem_2_dte tb_stages.uut_AllAtOnce.mem_sys_unit.dte_2_mem tb_stages.uut_AllAtOnce.mem_sys_unit.dma_2_sched tb_stages.uut_AllAtOnce.mem_sys_unit.dte_2_dma tb_stages.uut_AllAtOnce.mem_sys_unit.dte_2_ddr5 }

set _session_group_1960 $_session_group_1959|
append _session_group_1960 bus_arbitration_unit
gui_sg_create "$_session_group_1960"
set Mem_System|bus_arbitration_unit "$_session_group_1960"

gui_sg_addsignal -group "$_session_group_1960" { {tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.sch_best_pick tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.sch_best_pick_bk_id tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.iCache_2_Sch_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_out_2_icache_o tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dCache_2_Sch_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_out_2_dcache_o tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.mem_2_Sch_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.mem_2_dte_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_2_mem_o tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dma_2_sch_i tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_2_dma_o tb_stages.uut_AllAtOnce.mem_sys_unit.bus_arbitration_unit.dte_2_ddr5_o }

gui_sg_move "$_session_group_1960" -after "$_session_group_1959" -pos 5 

set _session_group_1961 $_session_group_1959|
append _session_group_1961 dcache_unit
gui_sg_create "$_session_group_1961"
set Mem_System|dcache_unit "$_session_group_1961"

gui_sg_addsignal -group "$_session_group_1961" { {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.address_bus tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.hitVec tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.arb_st_override_Out tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.arb_req_served_0_out tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.arb_req_served_1_out tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.inFromCore_i tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.out2Core_o tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.inFromDTE_i tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.out2Sch_o tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.blockOutputs {tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.req_2_blocks[0].p_addr} tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.req_2_blocks tb_stages.uut_AllAtOnce.mem_sys_unit.dcache_unit.mio_block_outputs }

gui_sg_move "$_session_group_1961" -after "$_session_group_1959" -pos 4 

set _session_group_1962 $_session_group_1959|
append _session_group_1962 ddr5_unit
gui_sg_create "$_session_group_1962"
set Mem_System|ddr5_unit "$_session_group_1962"

gui_sg_addsignal -group "$_session_group_1962" { {tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.addrBus tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.tempValue tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.powerGate tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.dataBus_fake tb_stages.uut_AllAtOnce.mem_sys_unit.ddr5_unit.inFromDTE_i }

gui_sg_move "$_session_group_1962" -after "$_session_group_1959" -pos 3 

set _session_group_1963 $_session_group_1959|
append _session_group_1963 dma_controller_unit
gui_sg_create "$_session_group_1963"
set Mem_System|dma_controller_unit "$_session_group_1963"

gui_sg_addsignal -group "$_session_group_1963" { {tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.addrBus tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.fsmState tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.fsmState_bits tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.commiting tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.disk_ld_Buffer_V tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.disk_ld_Buffer tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.counter tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.writeBuf tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.writeBuf_addr tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.writeBuf_V tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.writeComplete tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.write2_srcAddr_req tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.write2_destAddr_req tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.write2_numBytes_req tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.write2_startWrite_req tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.addrBus_drv tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.dataBus_drv tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.driveDataBus tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.inFromDTE_i tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.out2Core_o tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.out2Sch_o tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.dma_Regs tb_stages.uut_AllAtOnce.mem_sys_unit.dma_controller_unit.fsmOuts }

gui_sg_move "$_session_group_1963" -after "$_session_group_1959" -pos 2 

set _session_group_1964 $_session_group_1959|
append _session_group_1964 icache_unit
gui_sg_create "$_session_group_1964"
set Mem_System|icache_unit "$_session_group_1964"

gui_sg_addsignal -group "$_session_group_1964" { {tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.dataBus tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.addrBus tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.controller_fsmState tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.controller_fsmState_bits tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_dataLines tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_tag tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_tag_V tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_hit tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_miss tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_hit tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_miss tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_swapBuf_V_Clr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_dataLines tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.saved_pAddr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.saved_vAddr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.curr_v_addr_to_use tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.useSaved_v_Addr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.save_v_addr tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.addrBus_drv tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.inFromCore_i tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.out2Core_o tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.inFromDte_i tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.out2Sch_o tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.fsmOuts tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.icache_swapbuf tb_stages.uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_swapBuf }

gui_sg_move "$_session_group_1964" -after "$_session_group_1959" -pos 1 

set _session_group_1965 $_session_group_1959|
append _session_group_1965 mem_unit_1
gui_sg_create "$_session_group_1965"
set Mem_System|mem_unit_1 "$_session_group_1965"

gui_sg_addsignal -group "$_session_group_1965" { {tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.$unit} tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.clk tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.rst tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.address_bus tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.data_bus tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.mem_bus tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.drive_Data_Bus tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.dataToDrive tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.inFromDte tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.out2Dte tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.out2Sch tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.controller_2_bank_Cmds tb_stages.uut_AllAtOnce.mem_sys_unit.mem_unit.bank_out_2_controller }

set _session_group_1966 flags_reg
gui_sg_create "$_session_group_1966"
set flags_reg "$_session_group_1966"

gui_sg_addsignal -group "$_session_group_1966" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.flags_reg }

set _session_group_1967 $_session_group_1966|
append _session_group_1967 RegisterFile_unit
gui_sg_create "$_session_group_1967"
set flags_reg|RegisterFile_unit "$_session_group_1967"

gui_sg_addsignal -group "$_session_group_1967" { tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.SR_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR1_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR0_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.DR_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR0_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR1_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.Segment0_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.wb_wr_to_both tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.Segment1_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.SIB_BASE_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.outputs tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.SIB_IDX_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.REGISTERS tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.clk tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR1_data {tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR0_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.rst }

gui_sg_move "$_session_group_1967" -after "$_session_group_1966" -pos 2 

set _session_group_1968 $_session_group_1966|
append _session_group_1968 reg_sb_unit
gui_sg_create "$_session_group_1968"
set flags_reg|reg_sb_unit "$_session_group_1968"

gui_sg_addsignal -group "$_session_group_1968" { tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_dr_rd tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sr_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.flush tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr1_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_sr_wr tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.dep_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.dr_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.ecx_sb tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr0_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_dr_wr tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sr_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr1_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.depStall_Internal tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.Segment0_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.seg0_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_wr_to_both tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.Segment1_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_idx_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.codeSeg_sb tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.farFlush tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_wr_to_both tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_eax_rd tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_base_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.updateSB tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.instructionforward tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_base_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_idx_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_eax_wr tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.eax_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.clk tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.seg1_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_sr_rd {tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.dr_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.SCORE_BOARD tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.Segment1_valid tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr0_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_sib_size tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.rst }

gui_sg_move "$_session_group_1968" -after "$_session_group_1966" -pos 1 

set _session_group_1969 uut_stuff
gui_sg_create "$_session_group_1969"
set uut_stuff "$_session_group_1969"

gui_sg_addsignal -group "$_session_group_1969" { tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches.EIP tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches.valid tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches.data_size_vec tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches.cs.OP_TYPE tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches }

set _session_group_1970 $_session_group_1969|
append _session_group_1970 u_sbb_op
gui_sg_create "$_session_group_1970"
set uut_stuff|u_sbb_op "$_session_group_1970"

gui_sg_addsignal -group "$_session_group_1970" { {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.CF_in tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.al_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.ah_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.ax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.eax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.result }

gui_sg_move "$_session_group_1970" -after "$_session_group_1969" -pos 6 

set _session_group_1971 $_session_group_1969|
append _session_group_1971 u_mov_op
gui_sg_create "$_session_group_1971"
set uut_stuff|u_mov_op "$_session_group_1971"

gui_sg_addsignal -group "$_session_group_1971" { {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.curr_cf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.masked_data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.merged_res }

gui_sg_move "$_session_group_1971" -after "$_session_group_1969" -pos 5 

set _session_group_1972 Core
gui_sg_create "$_session_group_1972"
set Core "$_session_group_1972"

gui_sg_addsignal -group "$_session_group_1972" { }

set _session_group_1973 $_session_group_1972|
append _session_group_1973 core_unit
gui_sg_create "$_session_group_1973"
set Core|core_unit "$_session_group_1973"

gui_sg_addsignal -group "$_session_group_1973" { tb_stages.uut_AllAtOnce.core_unit.mem_latches tb_stages.uut_AllAtOnce.core_unit.wb_latches_next tb_stages.uut_AllAtOnce.core_unit.DCacheIn_i tb_stages.uut_AllAtOnce.core_unit.inFromDMA_i tb_stages.uut_AllAtOnce.core_unit.dc_outputs tb_stages.uut_AllAtOnce.core_unit.mem_latches_next tb_stages.uut_AllAtOnce.core_unit.mem_outputs tb_stages.uut_AllAtOnce.core_unit.dc_latches_next tb_stages.uut_AllAtOnce.core_unit.wb_latches tb_stages.uut_AllAtOnce.core_unit.rr_latches_next tb_stages.uut_AllAtOnce.core_unit.rr_latches tb_stages.uut_AllAtOnce.core_unit.exe_latches tb_stages.uut_AllAtOnce.core_unit.idm_outputs tb_stages.uut_AllAtOnce.core_unit.fetch_outputs tb_stages.uut_AllAtOnce.core_unit.clk tb_stages.uut_AllAtOnce.core_unit.wb_outputs tb_stages.uut_AllAtOnce.core_unit.decode_outputs tb_stages.uut_AllAtOnce.core_unit.rr_outputs tb_stages.uut_AllAtOnce.core_unit.exe_latches_next tb_stages.uut_AllAtOnce.core_unit.out2DCache_o tb_stages.uut_AllAtOnce.core_unit.exe_outputs {tb_stages.uut_AllAtOnce.core_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_latches tb_stages.uut_AllAtOnce.core_unit.ICacheIn_i tb_stages.uut_AllAtOnce.core_unit.out2ICache_o tb_stages.uut_AllAtOnce.core_unit.rst }

set _session_group_1974 latches
gui_sg_create "$_session_group_1974"
set latches "$_session_group_1974"

gui_sg_addsignal -group "$_session_group_1974" { }

set _session_group_1975 $_session_group_1974|
append _session_group_1975 dc_latches_unit
gui_sg_create "$_session_group_1975"
set latches|dc_latches_unit "$_session_group_1975"

gui_sg_addsignal -group "$_session_group_1975" { tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.flush tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.latches tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.farFlush tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.write_enable_i {tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_latches_unit.rst }

gui_sg_move "$_session_group_1975" -after "$_session_group_1974" -pos 2 

set _session_group_1976 $_session_group_1974|
append _session_group_1976 rr_latches_unit
gui_sg_create "$_session_group_1976"
set latches|rr_latches_unit "$_session_group_1976"

gui_sg_addsignal -group "$_session_group_1976" { tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.flush tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.latches tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.farFlush tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.write_enable_i {tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.rr_latches_unit.rst }

gui_sg_move "$_session_group_1976" -after "$_session_group_1974" -pos 1 

set _session_group_1977 $_session_group_1974|
append _session_group_1977 exe_latches_unit
gui_sg_create "$_session_group_1977"
set latches|exe_latches_unit "$_session_group_1977"

gui_sg_addsignal -group "$_session_group_1977" { tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.flush tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.write_enable_i {tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.rst }

gui_sg_move "$_session_group_1977" -after "$_session_group_1974" -pos 4 

set _session_group_1978 $_session_group_1974|
append _session_group_1978 idm_unit
gui_sg_create "$_session_group_1978"
set latches|idm_unit "$_session_group_1978"

gui_sg_addsignal -group "$_session_group_1978" { tb_stages.uut_AllAtOnce.core_unit.idm_unit.fetch_outs_i tb_stages.uut_AllAtOnce.core_unit.idm_unit.idm_outs_o tb_stages.uut_AllAtOnce.core_unit.idm_unit.clk tb_stages.uut_AllAtOnce.core_unit.idm_unit.idm {tb_stages.uut_AllAtOnce.core_unit.idm_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.idm_unit.rst }

set _session_group_1979 $_session_group_1974|
append _session_group_1979 wb_latches_unit
gui_sg_create "$_session_group_1979"
set latches|wb_latches_unit "$_session_group_1979"

gui_sg_addsignal -group "$_session_group_1979" { tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.latches tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.write_enable_i {tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.wb_latches_unit.rst }

gui_sg_move "$_session_group_1979" -after "$_session_group_1974" -pos 5 

set _session_group_1980 $_session_group_1974|
append _session_group_1980 mem_latches_unit
gui_sg_create "$_session_group_1980"
set latches|mem_latches_unit "$_session_group_1980"

gui_sg_addsignal -group "$_session_group_1980" { tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.flush tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.latches tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.latches_o tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.farFlush tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.nextLatches_i tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.clk tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.write_enable_i {tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.mem_latches_unit.rst }

gui_sg_move "$_session_group_1980" -after "$_session_group_1974" -pos 3 

set _session_group_1981 stages
gui_sg_create "$_session_group_1981"
set stages "$_session_group_1981"

gui_sg_addsignal -group "$_session_group_1981" { }

set _session_group_1982 $_session_group_1981|
append _session_group_1982 execute_unit
gui_sg_create "$_session_group_1982"
set stages|execute_unit "$_session_group_1982"

gui_sg_addsignal -group "$_session_group_1982" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.rst tb_stages.uut_AllAtOnce.core_unit.execute_unit.clk tb_stages.uut_AllAtOnce.core_unit.execute_unit.latches_i.valid tb_stages.uut_AllAtOnce.core_unit.execute_unit.latches_i.EIP tb_stages.uut_AllAtOnce.core_unit.execute_unit.latches_i.cs.OP_TYPE tb_stages.uut_AllAtOnce.core_unit.execute_unit.latches_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.outs_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_outs_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.flags_reg tb_stages.uut_AllAtOnce.core_unit.execute_unit.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.latches_i.cs.alu_inputA_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.latches_i.cs.alu_inputB_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.dr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.sr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.eax_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.sr_data_size_vec tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_latches_next_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.dr_next tb_stages.uut_AllAtOnce.core_unit.execute_unit.res_buf_next tb_stages.uut_AllAtOnce.core_unit.execute_unit.res_buf_selected tb_stages.uut_AllAtOnce.core_unit.execute_unit.bit_vec_0_next tb_stages.uut_AllAtOnce.core_unit.execute_unit.bit_vec_1_next tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_stage_we_valid_unit_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.branch_resolution_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.df_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.af_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.pf_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.cf_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.sf_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.of_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.zf_flag_o }

gui_sg_move "$_session_group_1982" -after "$_session_group_1981" -pos 6 

set _session_group_1983 $_session_group_1982|
append _session_group_1983 u_add_op
gui_sg_create "$_session_group_1983"
set stages|execute_unit|u_add_op "$_session_group_1983"

gui_sg_addsignal -group "$_session_group_1983" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.al_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.ah_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.ax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.eax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.af_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_add_op.merged_result }

gui_sg_move "$_session_group_1983" -after "$_session_group_1982" -pos 75 

set _session_group_1984 $_session_group_1982|
append _session_group_1984 u_af_flag_sel
gui_sg_create "$_session_group_1984"
set stages|execute_unit|u_af_flag_sel "$_session_group_1984"

gui_sg_addsignal -group "$_session_group_1984" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.aaa_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.adc_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.add_op_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.cmp_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.cmpxchg_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.sbb_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.iretd_af tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.curr_af_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_af_flag_sel.af_flag_o }

gui_sg_move "$_session_group_1984" -after "$_session_group_1982" -pos 74 

set _session_group_1985 $_session_group_1982|
append _session_group_1985 u_alu_input_sel
gui_sg_create "$_session_group_1985"
set stages|execute_unit|u_alu_input_sel "$_session_group_1985"

gui_sg_addsignal -group "$_session_group_1985" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.br_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.EIP tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.dr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.shift_sr_up tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.sr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.imm64 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.flags tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.ld_addr_0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.NEIP tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.alu_inputB_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.alu_inputA_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.EAX tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.br_input_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.shift_sr_down tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.res_buf_offset tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.srA_64 {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.res_buf_out tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.srB_64 }

gui_sg_move "$_session_group_1985" -after "$_session_group_1982" -pos 73 

set _session_group_1986 $_session_group_1982|
append _session_group_1986 u_and_op
gui_sg_create "$_session_group_1986"
set stages|execute_unit|u_and_op "$_session_group_1986"

gui_sg_addsignal -group "$_session_group_1986" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.and_result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.merged_result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.ld_16 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.ld_32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_and_op.ld_8 }

gui_sg_move "$_session_group_1986" -after "$_session_group_1982" -pos 72 

set _session_group_1987 $_session_group_1982|
append _session_group_1987 u_bit_vec_logic
gui_sg_create "$_session_group_1987"
set stages|execute_unit|u_bit_vec_logic "$_session_group_1987"

gui_sg_addsignal -group "$_session_group_1987" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.st_addr_0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.ST_XCL tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.st_vec0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.st_vec1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.num_bytes tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.start_offset tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.offset_xcl tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bit_vec_logic.end_of_st_addr_1 }

gui_sg_move "$_session_group_1987" -after "$_session_group_1982" -pos 71 

set _session_group_1988 $_session_group_1982|
append _session_group_1988 u_br_res
gui_sg_create "$_session_group_1988"
set stages|execute_unit|u_br_res "$_session_group_1988"

gui_sg_addsignal -group "$_session_group_1988" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.stage_valid_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_info_valid_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.flush_mask tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_eip_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_xcl_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_pred_taken_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.speculative_target_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_ucond_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.relative_branch_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.special_br_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.is_far_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.is_call_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.second_flag_needed_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_source_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.NEIP_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.br_rel_target tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.valid tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.taken tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.clr_exp_mode tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.flush tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.miss_prediction tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.second_flag_result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.cond_br_res tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.target_match tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.farFlush tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.callFlush tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_br_res.outs_o }

gui_sg_move "$_session_group_1988" -after "$_session_group_1982" -pos 70 

set _session_group_1989 $_session_group_1982|
append _session_group_1989 u_bsf
gui_sg_create "$_session_group_1989"
set stages|execute_unit|u_bsf "$_session_group_1989"

gui_sg_addsignal -group "$_session_group_1989" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.op32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.op16 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.index32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.index16 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.found32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.found16 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.result32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.result16 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.ZF32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_bsf.ZF16 }

gui_sg_move "$_session_group_1989" -after "$_session_group_1982" -pos 69 

set _session_group_1990 $_session_group_1982|
append _session_group_1990 u_call_op
gui_sg_create "$_session_group_1990"
set stages|execute_unit|u_call_op "$_session_group_1990"

gui_sg_addsignal -group "$_session_group_1990" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_call_op.NEIP tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_call_op.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_call_op.sr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_call_op.res_buf }

gui_sg_move "$_session_group_1990" -after "$_session_group_1982" -pos 68 

set _session_group_1991 $_session_group_1982|
append _session_group_1991 u_cf_flag_sel
gui_sg_create "$_session_group_1991"
set stages|execute_unit|u_cf_flag_sel "$_session_group_1991"

gui_sg_addsignal -group "$_session_group_1991" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.aaa_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.adc_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.add_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.and_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.cmp_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.cmpxchg_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.or_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.sal_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.sar_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.sbb_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.iretd_cf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.curr_cf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cf_flag_sel.cf_flag_o }

gui_sg_move "$_session_group_1991" -after "$_session_group_1982" -pos 67 

set _session_group_1992 $_session_group_1982|
append _session_group_1992 u_cmp
gui_sg_create "$_session_group_1992"
set stages|execute_unit|u_cmp "$_session_group_1992"

gui_sg_addsignal -group "$_session_group_1992" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.low_sr_val tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.al_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.ax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmp.eax_sum }

gui_sg_move "$_session_group_1992" -after "$_session_group_1982" -pos 66 

set _session_group_1993 $_session_group_1982|
append _session_group_1993 u_cmpxchg_op
gui_sg_create "$_session_group_1993"
set stages|execute_unit|u_cmpxchg_op "$_session_group_1993"

gui_sg_addsignal -group "$_session_group_1993" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.r_upper tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.rm_low tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.sr_data_size_vec tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.rm tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.r tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.EAX_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.next_dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.next_EAX tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.r_low tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.EAX tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.cmp_AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.SF {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_cmpxchg_op.ZF }

gui_sg_move "$_session_group_1993" -after "$_session_group_1982" -pos 65 

set _session_group_1994 $_session_group_1982|
append _session_group_1994 u_df_flag_sel
gui_sg_create "$_session_group_1994"
set stages|execute_unit|u_df_flag_sel "$_session_group_1994"

gui_sg_addsignal -group "$_session_group_1994" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_df_flag_sel.curr_df_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_df_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_df_flag_sel.df_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_df_flag_sel.next_df_flag }

gui_sg_move "$_session_group_1994" -after "$_session_group_1982" -pos 64 

set _session_group_1995 $_session_group_1982|
append _session_group_1995 u_dr_sel
gui_sg_create "$_session_group_1995"
set stages|execute_unit|u_dr_sel "$_session_group_1995"

gui_sg_addsignal -group "$_session_group_1995" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.aaa_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.adc_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.add_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.and_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.bsf_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.cmpxchg_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.mov_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.not_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.or_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.packssdw_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.packsswb_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.paddd_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.paddw_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.pavgb_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.pavgw_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.pop_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.ret_far_imm_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.sal_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.sar_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.sbb_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.xchg_dr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.dr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_dr_sel.dr_o }

gui_sg_move "$_session_group_1995" -after "$_session_group_1982" -pos 63 

set _session_group_1996 $_session_group_1982|
append _session_group_1996 u_far_op
gui_sg_create "$_session_group_1996"
set stages|execute_unit|u_far_op "$_session_group_1996"

gui_sg_addsignal -group "$_session_group_1996" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_far_op.neip tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_far_op.segment tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_far_op.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_far_op.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_far_op.sr_o }

gui_sg_move "$_session_group_1996" -after "$_session_group_1982" -pos 62 

set _session_group_1997 $_session_group_1982|
append _session_group_1997 u_iretd_op
gui_sg_create "$_session_group_1997"
set stages|execute_unit|u_iretd_op "$_session_group_1997"

gui_sg_addsignal -group "$_session_group_1997" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.cs tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.flags tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.sr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_iretd_op.OF }

gui_sg_move "$_session_group_1997" -after "$_session_group_1982" -pos 61 

set _session_group_1998 $_session_group_1982|
append _session_group_1998 u_mov_op
gui_sg_create "$_session_group_1998"
set stages|execute_unit|u_mov_op "$_session_group_1998"

gui_sg_addsignal -group "$_session_group_1998" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.merged_res tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.curr_cf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.masked_data_size {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_mov_op.res_buf_o }

gui_sg_move "$_session_group_1998" -after "$_session_group_1982" -pos 60 

set _session_group_1999 $_session_group_1982|
append _session_group_1999 u_not_op
gui_sg_create "$_session_group_1999"
set stages|execute_unit|u_not_op "$_session_group_1999"

gui_sg_addsignal -group "$_session_group_1999" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op.out_32 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_not_op.merged_res }

gui_sg_move "$_session_group_1999" -after "$_session_group_1982" -pos 59 

set _session_group_2000 $_session_group_1982|
append _session_group_2000 u_of_flag_sel
gui_sg_create "$_session_group_2000"
set stages|execute_unit|u_of_flag_sel "$_session_group_2000"

gui_sg_addsignal -group "$_session_group_2000" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.adc_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.add_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.and_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.cmp_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.cmpxchg_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.or_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.sal_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.sar_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.sbb_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.iretd_of tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.curr_of_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_of_flag_sel.of_flag_o }

gui_sg_move "$_session_group_2000" -after "$_session_group_1982" -pos 58 

set _session_group_2001 $_session_group_1982|
append _session_group_2001 u_or_op
gui_sg_create "$_session_group_2001"
set stages|execute_unit|u_or_op "$_session_group_2001"

gui_sg_addsignal -group "$_session_group_2001" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.or_result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.merged_result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.zf_low8 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.zf_up8 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.zf_up16 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_or_op.zf_low16 }

gui_sg_move "$_session_group_2001" -after "$_session_group_1982" -pos 57 

set _session_group_2002 $_session_group_1982|
append _session_group_2002 u_packssdw
gui_sg_create "$_session_group_2002"
set stages|execute_unit|u_packssdw "$_session_group_2002"

gui_sg_addsignal -group "$_session_group_2002" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.a0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.a1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.b0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.b1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.r0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.r1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.r2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packssdw.r3 }

gui_sg_move "$_session_group_2002" -after "$_session_group_1982" -pos 56 

set _session_group_2003 $_session_group_1982|
append _session_group_2003 u_packsswb
gui_sg_create "$_session_group_2003"
set stages|execute_unit|u_packsswb "$_session_group_2003"

gui_sg_addsignal -group "$_session_group_2003" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.a0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.a1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.a2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.a3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.b0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.b1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.b2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.b3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r4 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r5 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r6 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_packsswb.r7 }

gui_sg_move "$_session_group_2003" -after "$_session_group_1982" -pos 55 

set _session_group_2004 $_session_group_1982|
append _session_group_2004 u_paddd
gui_sg_create "$_session_group_2004"
set stages|execute_unit|u_paddd "$_session_group_2004"

gui_sg_addsignal -group "$_session_group_2004" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.a0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.a1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.b0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.b1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.r0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddd.r1 }

gui_sg_move "$_session_group_2004" -after "$_session_group_1982" -pos 54 

set _session_group_2005 $_session_group_1982|
append _session_group_2005 u_paddw
gui_sg_create "$_session_group_2005"
set stages|execute_unit|u_paddw "$_session_group_2005"

gui_sg_addsignal -group "$_session_group_2005" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.a0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.a1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.a2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.a3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.b0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.b1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.b2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.b3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.r0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.r1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.r2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_paddw.r3 }

gui_sg_move "$_session_group_2005" -after "$_session_group_1982" -pos 53 

set _session_group_2006 $_session_group_1982|
append _session_group_2006 u_pavgb
gui_sg_create "$_session_group_2006"
set stages|execute_unit|u_pavgb "$_session_group_2006"

gui_sg_addsignal -group "$_session_group_2006" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a4 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a5 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a6 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.a7 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b4 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b5 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b6 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.b7 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s4 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s5 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s6 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.s7 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r4 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r5 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r6 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgb.r7 }

gui_sg_move "$_session_group_2006" -after "$_session_group_1982" -pos 52 

set _session_group_2007 $_session_group_1982|
append _session_group_2007 u_pavgw
gui_sg_create "$_session_group_2007"
set stages|execute_unit|u_pavgw "$_session_group_2007"

gui_sg_addsignal -group "$_session_group_2007" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.a0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.a1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.a2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.a3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.b0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.b1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.b2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.b3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.s0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.s1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.s2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.s3 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.r0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.r1 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.r2 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pavgw.r3 }

gui_sg_move "$_session_group_2007" -after "$_session_group_1982" -pos 51 

set _session_group_2008 $_session_group_1982|
append _session_group_2008 u_pf_flag_sel
gui_sg_create "$_session_group_2008"
set stages|execute_unit|u_pf_flag_sel "$_session_group_2008"

gui_sg_addsignal -group "$_session_group_2008" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.adc_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.add_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.and_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.cmp_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.cmpxchg_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.or_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.sal_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.sar_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.sbb_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.iretd_pf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.curr_pf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pf_flag_sel.pf_flag_o }

gui_sg_move "$_session_group_2008" -after "$_session_group_1982" -pos 50 

set _session_group_2009 $_session_group_1982|
append _session_group_2009 u_pop_op
gui_sg_create "$_session_group_2009"
set stages|execute_unit|u_pop_op "$_session_group_2009"

gui_sg_addsignal -group "$_session_group_2009" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pop_op.value_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pop_op.sp_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pop_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_pop_op.sr_o }

gui_sg_move "$_session_group_2009" -after "$_session_group_1982" -pos 49 

set _session_group_2010 $_session_group_1982|
append _session_group_2010 u_push_op
gui_sg_create "$_session_group_2010"
set stages|execute_unit|u_push_op "$_session_group_2010"

gui_sg_addsignal -group "$_session_group_2010" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.sp tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.data_size_vec tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.value tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.sr_o {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_push_op.num_bytes }

gui_sg_move "$_session_group_2010" -after "$_session_group_1982" -pos 48 

set _session_group_2011 $_session_group_1982|
append _session_group_2011 u_res_buf_logic
gui_sg_create "$_session_group_2011"
set stages|execute_unit|u_res_buf_logic "$_session_group_2011"

gui_sg_addsignal -group "$_session_group_2011" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_logic.res_info_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_logic.st_addr_0 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_logic.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_logic.offset }

gui_sg_move "$_session_group_2011" -after "$_session_group_1982" -pos 47 

set _session_group_2012 $_session_group_1982|
append _session_group_2012 u_res_buf_sel
gui_sg_create "$_session_group_2012"
set stages|execute_unit|u_res_buf_sel "$_session_group_2012"

gui_sg_addsignal -group "$_session_group_2012" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.adc_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.add_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.and_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.call_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.cmpxchg_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.far_call_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.mov_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.not_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.or_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.push_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.sar_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.sbb_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.xchg_res_buf_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_res_buf_sel.res_buf_o }

gui_sg_move "$_session_group_2012" -after "$_session_group_1982" -pos 46 

set _session_group_2013 $_session_group_1982|
append _session_group_2013 u_ret_far_imm
gui_sg_create "$_session_group_2013"
set stages|execute_unit|u_ret_far_imm "$_session_group_2013"

gui_sg_addsignal -group "$_session_group_2013" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_imm.cs tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_imm.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_imm.imm64 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_imm.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_imm.sr_o }

gui_sg_move "$_session_group_2013" -after "$_session_group_1982" -pos 45 

set _session_group_2014 $_session_group_1982|
append _session_group_2014 u_ret_far_op
gui_sg_create "$_session_group_2014"
set stages|execute_unit|u_ret_far_op "$_session_group_2014"

gui_sg_addsignal -group "$_session_group_2014" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_op.cs tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_op.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_far_op.sr_o }

gui_sg_move "$_session_group_2014" -after "$_session_group_1982" -pos 44 

set _session_group_2015 $_session_group_1982|
append _session_group_2015 u_ret_imm_op
gui_sg_create "$_session_group_2015"
set stages|execute_unit|u_ret_imm_op "$_session_group_2015"

gui_sg_addsignal -group "$_session_group_2015" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_imm_op.imm64 tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_imm_op.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_imm_op.sr_o }

gui_sg_move "$_session_group_2015" -after "$_session_group_1982" -pos 43 

set _session_group_2016 $_session_group_1982|
append _session_group_2016 u_ret_op
gui_sg_create "$_session_group_2016"
set stages|execute_unit|u_ret_op "$_session_group_2016"

gui_sg_addsignal -group "$_session_group_2016" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_op.stack_ptr tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_ret_op.sr_o }

gui_sg_move "$_session_group_2016" -after "$_session_group_1982" -pos 42 

set _session_group_2017 $_session_group_1982|
append _session_group_2017 u_sbb_op
gui_sg_create "$_session_group_2017"
set stages|execute_unit|u_sbb_op "$_session_group_2017"

gui_sg_addsignal -group "$_session_group_2017" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.CF_in tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.al_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.ax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.ah_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.SF {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.eax_sum tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sbb_op.ZF }

gui_sg_move "$_session_group_2017" -after "$_session_group_1982" -pos 41 

set _session_group_2018 $_session_group_1982|
append _session_group_2018 u_sf_flag_sel
gui_sg_create "$_session_group_2018"
set stages|execute_unit|u_sf_flag_sel "$_session_group_2018"

gui_sg_addsignal -group "$_session_group_2018" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.add_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.adc_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.and_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.cmp_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.cmpxchg_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.or_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.sal_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.sar_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.sbb_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.iretd_sf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.curr_sf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sf_flag_sel.sf_flag_o }

gui_sg_move "$_session_group_2018" -after "$_session_group_1982" -pos 40 

set _session_group_2019 $_session_group_1982|
append _session_group_2019 u_sr_sel
gui_sg_create "$_session_group_2019"
set stages|execute_unit|u_sr_sel "$_session_group_2019"

gui_sg_addsignal -group "$_session_group_2019" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.sr_data tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.pop_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.push_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.ret_far_imm_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.ret_imm_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.ret_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.xchg_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.call_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.far_call_sr_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sr_sel.sr_o }

gui_sg_move "$_session_group_2019" -after "$_session_group_1982" -pos 39 

set _session_group_2020 $_session_group_1982|
append _session_group_2020 u_xchg_op
gui_sg_create "$_session_group_2020"
set stages|execute_unit|u_xchg_op "$_session_group_2020"

gui_sg_addsignal -group "$_session_group_2020" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.sr_data_size_vec tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.res_buf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.sr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.new_rm_value tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.new_r32_val tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.new_rm_low_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.new_rm_upper_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.new_r32_low_sel tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_xchg_op.new_r32_upper_sel }

gui_sg_move "$_session_group_2020" -after "$_session_group_1982" -pos 38 

set _session_group_2021 $_session_group_1982|
append _session_group_2021 u_zf_flag_sel
gui_sg_create "$_session_group_2021"
set stages|execute_unit|u_zf_flag_sel "$_session_group_2021"

gui_sg_addsignal -group "$_session_group_2021" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.adc_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.add_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.and_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.bsf_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.cmp_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.cmpxchg_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.or_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.sal_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.sar_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.sbb_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.iretd_zf tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.curr_zf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.op_type tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.zf_flag_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_zf_flag_sel.clr_ZF_sb }

gui_sg_move "$_session_group_2021" -after "$_session_group_1982" -pos 37 

set _session_group_2022 $_session_group_1982|
append _session_group_2022 wb_valid_logic_unit
gui_sg_create "$_session_group_2022"
set stages|execute_unit|wb_valid_logic_unit "$_session_group_2022"

gui_sg_addsignal -group "$_session_group_2022" { {tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.WB_we_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.N_WB_V_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.EXE_V_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.WB_stall_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.WB_stall_i_inv tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.WB_we_o_and_buf_mid tb_stages.uut_AllAtOnce.core_unit.execute_unit.wb_valid_logic_unit.N_WB_V_o_and_buf_mid }

gui_sg_move "$_session_group_2022" -after "$_session_group_1982" -pos 36 

set _session_group_2023 $_session_group_1982|
append _session_group_2023 u_sal_op
gui_sg_create "$_session_group_2023"
set stages|execute_unit|u_sal_op "$_session_group_2023"

gui_sg_addsignal -group "$_session_group_2023" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.shift_by_one tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.curr_sf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.sr_data_size_vec tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.curr_of_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.curr_zf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.shift_amt_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.curr_cf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.curr_af_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.count tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.value_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.curr_pf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.SF {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sal_op.ZF }

gui_sg_move "$_session_group_2023" -after "$_session_group_1982" -pos 35 

set _session_group_2024 $_session_group_1982|
append _session_group_2024 u_sar_op
gui_sg_create "$_session_group_2024"
set stages|execute_unit|u_sar_op "$_session_group_2024"

gui_sg_addsignal -group "$_session_group_2024" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.result tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.shift_by_one tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.shift_amt_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.count tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.value_i tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.SF {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.sr_data_size_vec tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.curr_zf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.curr_sf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.curr_pf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.curr_of_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.curr_cf_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.curr_af_flag tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_sar_op.AF }

gui_sg_move "$_session_group_2024" -after "$_session_group_1982" -pos 34 

set _session_group_2025 $_session_group_1982|
append _session_group_2025 u_aaa
gui_sg_create "$_session_group_2025"
set stages|execute_unit|u_aaa "$_session_group_2025"

gui_sg_addsignal -group "$_session_group_2025" { {tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.$unit} tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.EAX_in tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.AF_flag_in tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.adjust tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.AL tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.AH tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_aaa.AX_new }

gui_sg_move "$_session_group_2025" -after "$_session_group_1982" -pos 77 

set _session_group_2026 $_session_group_1982|
append _session_group_2026 u_adc_op
gui_sg_create "$_session_group_2026"
set stages|execute_unit|u_adc_op "$_session_group_2026"

gui_sg_addsignal -group "$_session_group_2026" { tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.srA tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.srB tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.CF_in tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.data_size tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.dr_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.res_buf_o tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.CF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.PF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.AF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.ZF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.SF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.OF tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_adc_op.sum }

gui_sg_move "$_session_group_2026" -after "$_session_group_1982" -pos 76 

set _session_group_2027 $_session_group_1981|
append _session_group_2027 decode_unit
gui_sg_create "$_session_group_2027"
set stages|decode_unit "$_session_group_2027"

gui_sg_addsignal -group "$_session_group_2027" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.rst tb_stages.uut_AllAtOnce.core_unit.decode_unit.clk tb_stages.uut_AllAtOnce.core_unit.decode_unit.rr_latches_next.normal_latches.valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.EIP tb_stages.uut_AllAtOnce.core_unit.decode_unit.NEIP tb_stages.uut_AllAtOnce.core_unit.decode_unit.rr_latches_next.normal_latches.exe_cs.OP_TYPE tb_stages.uut_AllAtOnce.core_unit.decode_unit.rr_latches_next tb_stages.uut_AllAtOnce.core_unit.decode_unit.PrevEIP tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_length tb_stages.uut_AllAtOnce.core_unit.decode_unit.PrevLength tb_stages.uut_AllAtOnce.core_unit.decode_unit.sib_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.sib_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.disp_needed tb_stages.uut_AllAtOnce.core_unit.decode_unit.displacement tb_stages.uut_AllAtOnce.core_unit.decode_unit.disp_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.imm64 tb_stages.uut_AllAtOnce.core_unit.decode_unit.total_pf_vector tb_stages.uut_AllAtOnce.core_unit.decode_unit.invalid_inst tb_stages.uut_AllAtOnce.core_unit.decode_unit.opcode_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.modrm_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_gp tb_stages.uut_AllAtOnce.core_unit.decode_unit.flush tb_stages.uut_AllAtOnce.core_unit.decode_unit.REP_LATCH tb_stages.uut_AllAtOnce.core_unit.decode_unit.REP_CMP_LATCH tb_stages.uut_AllAtOnce.core_unit.decode_unit.REP_MOV_LATCH tb_stages.uut_AllAtOnce.core_unit.decode_unit.HALT_REG tb_stages.uut_AllAtOnce.core_unit.decode_unit.rr_latch_we_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.queue tb_stages.uut_AllAtOnce.core_unit.decode_unit.predicted_taken tb_stages.uut_AllAtOnce.core_unit.decode_unit.predicted_target tb_stages.uut_AllAtOnce.core_unit.decode_unit.branch_present tb_stages.uut_AllAtOnce.core_unit.decode_unit.sibbase tb_stages.uut_AllAtOnce.core_unit.decode_unit.sibidx tb_stages.uut_AllAtOnce.core_unit.decode_unit.sibscale tb_stages.uut_AllAtOnce.core_unit.decode_unit.clear_rep tb_stages.uut_AllAtOnce.core_unit.decode_unit.next_rr_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.segment0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.idm_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.fetch_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.rr_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.dc_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.mem_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.exe_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.wb_outs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.rr_latches_next.normal_latches.cs.eax_rd tb_stages.uut_AllAtOnce.core_unit.decode_unit.rr_latches_next.normal_latches.cs.eax_wr tb_stages.uut_AllAtOnce.core_unit.decode_unit.rr_latches_next.normal_latches.cs.eax_rd tb_stages.uut_AllAtOnce.core_unit.decode_unit.outs_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_decode_cs tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_rr_cs tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_dc_cs tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_mem_cs tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_exe_cs tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_wb_cs tb_stages.uut_AllAtOnce.core_unit.decode_unit.temp_rr_latch tb_stages.uut_AllAtOnce.core_unit.decode_unit.br_info_for_latches tb_stages.uut_AllAtOnce.core_unit.decode_unit.rep_latch_holder }

gui_sg_move "$_session_group_2027" -after "$_session_group_1981" -pos 2 

set _session_group_2028 $_session_group_2027|
append _session_group_2028 cs_post_prossesing_unit
gui_sg_create "$_session_group_2028"
set stages|decode_unit|cs_post_prossesing_unit "$_session_group_2028"

gui_sg_addsignal -group "$_session_group_2028" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.invalid_inst tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.xchg tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.cmpxchg tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.op_in_modrm tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.op_in_modrm_subset tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.modrm_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.overriden_op_type tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.overriden_br_sel tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.reg_field tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.ff_jmp tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.ff_push tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.ff_call tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.decode_cs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.rr_cs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.dc_cs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.mem_cs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.exe_cs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.wb_cs_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.decode_cs_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.rr_cs_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.dc_cs_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.mem_cs_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.exe_cs_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.cs_post_prossesing_unit.wb_cs_o }

gui_sg_move "$_session_group_2028" -after "$_session_group_2027" -pos 12 

set _session_group_2029 $_session_group_2027|
append _session_group_2029 inst_processing
gui_sg_create "$_session_group_2029"
set stages|decode_unit|inst_processing "$_session_group_2029"

gui_sg_addsignal -group "$_session_group_2029" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.clk tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.rst tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.queue tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.queue_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.EIP tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.NEIP tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.inst_length tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.sib_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.sib_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.opcode_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.modrm_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.disp tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.disp_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.disp_needed tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.imm64 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.total_pf_vector tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.invalid_inst tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.IR tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.IR_valid_vect tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_inst_length tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_imm_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_msd_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_sib_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_displacement tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_imm tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_needrm tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_disp_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_disp_needed tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.ppu_sib_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.num_pfs tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pf_vector0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pf_vector1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pf_vector2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.sext_inst_length tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.inst_length_cout tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.inst_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.true_inst_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.adder_cout tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.possible_eips tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pf0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pf1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pf2 }

gui_sg_move "$_session_group_2029" -after "$_session_group_2027" -pos 11 

set _session_group_2030 $_session_group_2029|
append _session_group_2030 sel_log1
gui_sg_create "$_session_group_2030"
set stages|decode_unit|inst_processing|sel_log1 "$_session_group_2030"

gui_sg_addsignal -group "$_session_group_2030" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.sel_log1.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.sel_log1.queue tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.sel_log1.EIP tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.sel_log1.queue_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.sel_log1.IR tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.sel_log1.IR_valid_vect tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.sel_log1.sel_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.sel_log1.adder_cout }

gui_sg_move "$_session_group_2030" -after "$_session_group_2029" -pos 10 

set _session_group_2031 $_session_group_2029|
append _session_group_2031 pfs0
gui_sg_create "$_session_group_2031"
set stages|decode_unit|inst_processing|pfs0 "$_session_group_2031"

gui_sg_addsignal -group "$_session_group_2031" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.opcode_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.modrm_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.IR tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.IR_valid_vect tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.total_pf_vector tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.num_pfs_plusone tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.inst_length tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.msd_size_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.imm_size_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.disp_size_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.disp_needed_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.sib_size_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.needrm_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.sib_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.disp tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.imm64 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.inst_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.msd_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.imm_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.disp_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.disp_needed tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.sib_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.needrm tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.sib_size_unmasked tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.disp_needed_unmasked tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.imm_size_fake tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.msd_size_fake tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.sib_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.imm_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.op_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.mod_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.sib_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.disp_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.disp_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.imm_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.imm_valid_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.imm_size_override }

gui_sg_move "$_session_group_2031" -after "$_session_group_2029" -pos 9 

set _session_group_2032 $_session_group_2031|
append _session_group_2032 adder0
gui_sg_create "$_session_group_2032"
set stages|decode_unit|inst_processing|pfs0|adder0 "$_session_group_2032"

gui_sg_addsignal -group "$_session_group_2032" { tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.adder0.result tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.adder0.cout tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.adder0.msd_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.adder0.first_result tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.adder0.imm_size {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.adder0.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.adder0.pfs_plus_one }

gui_sg_move "$_session_group_2032" -after "$_session_group_2031" -pos 9 

set _session_group_2033 $_session_group_2029|
append _session_group_2033 pfs2
gui_sg_create "$_session_group_2033"
set stages|decode_unit|inst_processing|pfs2 "$_session_group_2033"

gui_sg_addsignal -group "$_session_group_2033" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.opcode_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.modrm_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.IR tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.IR_valid_vect tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.total_pf_vector tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.num_pfs_plusone tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.inst_length tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.msd_size_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.imm_size_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.disp_size_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.disp_needed_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.sib_size_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.needrm_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.sib_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.disp tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.imm64 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.inst_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.msd_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.imm_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.disp_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.disp_needed tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.sib_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.needrm tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.sib_size_unmasked tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.disp_needed_unmasked tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.imm_size_fake tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.msd_size_fake tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.sib_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.imm_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.op_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.mod_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.sib_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.disp_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.disp_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.imm_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.imm_valid_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.imm_size_override }

gui_sg_move "$_session_group_2033" -after "$_session_group_2029" -pos 8 

set _session_group_2034 $_session_group_2033|
append _session_group_2034 adder0
gui_sg_create "$_session_group_2034"
set stages|decode_unit|inst_processing|pfs2|adder0 "$_session_group_2034"

gui_sg_addsignal -group "$_session_group_2034" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.adder0.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.adder0.pfs_plus_one tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.adder0.msd_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.adder0.imm_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.adder0.result tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.adder0.first_result tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.adder0.cout }

gui_sg_move "$_session_group_2034" -after "$_session_group_2033" -pos 8 

set _session_group_2035 $_session_group_2029|
append _session_group_2035 pfs1
gui_sg_create "$_session_group_2035"
set stages|decode_unit|inst_processing|pfs1 "$_session_group_2035"

gui_sg_addsignal -group "$_session_group_2035" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.opcode_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.modrm_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.IR tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.IR_valid_vect tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.total_pf_vector tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.num_pfs_plusone tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.inst_length tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.msd_size_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.imm_size_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.disp_size_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.disp_needed_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.sib_size_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.needrm_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.sib_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.disp tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.imm64 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.inst_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.msd_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.imm_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.disp_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.disp_needed tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.sib_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.needrm tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.sib_size_unmasked tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.disp_needed_unmasked tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.imm_size_fake tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.msd_size_fake tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.sib_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.imm_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.op_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.mod_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.sib_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.disp_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.disp_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.imm_valid tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.imm_valid_index tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.imm_size_override }

gui_sg_move "$_session_group_2035" -after "$_session_group_2029" -pos 7 

set _session_group_2036 $_session_group_2035|
append _session_group_2036 adder0
gui_sg_create "$_session_group_2036"
set stages|decode_unit|inst_processing|pfs1|adder0 "$_session_group_2036"

gui_sg_addsignal -group "$_session_group_2036" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.adder0.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.adder0.pfs_plus_one tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.adder0.msd_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.adder0.imm_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.adder0.result tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.adder0.first_result tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.adder0.cout }

gui_sg_move "$_session_group_2036" -after "$_session_group_2035" -pos 8 

set _session_group_2037 $_session_group_2035|
append _session_group_2037 mod_size
gui_sg_create "$_session_group_2037"
set stages|decode_unit|inst_processing|pfs1|mod_size "$_session_group_2037"

gui_sg_addsignal -group "$_session_group_2037" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.mod_size.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.mod_size.mod_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.mod_size.msd_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.mod_size.sib_needed tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.mod_size.disp_needed tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.mod_size.disp_size }

gui_sg_move "$_session_group_2037" -after "$_session_group_2035" -pos 7 

set _session_group_2038 $_session_group_2035|
append _session_group_2038 opcode_size
gui_sg_create "$_session_group_2038"
set stages|decode_unit|inst_processing|pfs1|opcode_size "$_session_group_2038"

gui_sg_addsignal -group "$_session_group_2038" { tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.opcode_size.zero_f_prefix tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.opcode_size.other_imm_size tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.opcode_size.needrm_other tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.opcode_size.imm_size_regular tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.opcode_size.needr_m tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.opcode_size.imm_size {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.opcode_size.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.opcode_size.opcode_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.opcode_size.needrm_regular }

gui_sg_move "$_session_group_2038" -after "$_session_group_2035" -pos 6 

set _session_group_2039 $_session_group_2029|
append _session_group_2039 neip_picker_mux
gui_sg_create "$_session_group_2039"
set stages|decode_unit|inst_processing|neip_picker_mux "$_session_group_2039"

gui_sg_addsignal -group "$_session_group_2039" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.out tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.in0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.in1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.in2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.in3 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.in4 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.in5 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.in6 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.in7 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.in8 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.in9 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.in10 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.in11 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.in12 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.in13 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.in14 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.in15 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.sel {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[0].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[1].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[2].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[3].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[4].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[5].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[6].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[7].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[8].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[9].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[10].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[11].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[12].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[13].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[14].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[15].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[16].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[17].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[18].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[19].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[20].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[21].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[22].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[23].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[24].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[25].o} }
gui_sg_addsignal -group "$_session_group_2039" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[26].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[27].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[28].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[29].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[30].o} {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.mux_bits[31].o} tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.WIDTH }
gui_set_radix -radix {decimal} -signals {V1:tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.WIDTH}
gui_set_radix -radix {twosComplement} -signals {V1:tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.neip_picker_mux.WIDTH}

gui_sg_move "$_session_group_2039" -after "$_session_group_2029" -pos 6 

set _session_group_2040 $_session_group_2029|
append _session_group_2040 vec_gen
gui_sg_create "$_session_group_2040"
set stages|decode_unit|inst_processing|vec_gen "$_session_group_2040"

gui_sg_addsignal -group "$_session_group_2040" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.vec_gen.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.vec_gen.pfs tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.vec_gen.pf_vector0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.vec_gen.pf_vector1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.vec_gen.pf_vector2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.vec_gen.total_pf_vector tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.vec_gen.real_vector0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.vec_gen.real_vector1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.vec_gen.real_vector2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.vec_gen.sel0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.vec_gen.sel2 }

gui_sg_move "$_session_group_2040" -after "$_session_group_2029" -pos 5 

set _session_group_2041 $_session_group_2029|
append _session_group_2041 num_pf_gen0
gui_sg_create "$_session_group_2041"
set stages|decode_unit|inst_processing|num_pf_gen0 "$_session_group_2041"

gui_sg_addsignal -group "$_session_group_2041" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.num_pf_gen0.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.num_pf_gen0.pf0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.num_pf_gen0.pf1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.num_pf_gen0.pf2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.num_pf_gen0.num_pfs }

gui_sg_move "$_session_group_2041" -after "$_session_group_2029" -pos 4 

set _session_group_2042 $_session_group_2029|
append _session_group_2042 checker0
gui_sg_create "$_session_group_2042"
set stages|decode_unit|inst_processing|checker0 "$_session_group_2042"

gui_sg_addsignal -group "$_session_group_2042" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.checker0.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.checker0.IRbyte tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.checker0.pf tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.checker0.pf_vector tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.checker0.oroutput0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.checker0.oroutput1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.checker0.oroutput2 }

gui_sg_move "$_session_group_2042" -after "$_session_group_2029" -pos 3 

set _session_group_2043 $_session_group_2027|
append _session_group_2043 mod_rm_cs_gen
gui_sg_create "$_session_group_2043"
set stages|decode_unit|mod_rm_cs_gen "$_session_group_2043"

gui_sg_addsignal -group "$_session_group_2043" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.modrm_byte tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.datasize tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.dr_id tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.sr_id tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.dr_rd tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.sr_rd tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.dr_wr tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.sr_wr tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.ld_op_unmasked tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.st_op_unmasked tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.ld_op tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.st_op tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.rm_is_dr tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.reg_is_dr tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.reg_is_segment tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.modrm_but_no_sr tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.alu_inputA_override tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.alu_inputB_override tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.dr_high8 tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.sr_high8 tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.alu_inputA_override_sel tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.alu_inputB_override_sel tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.decode_cs_inputs tb_stages.uut_AllAtOnce.core_unit.decode_unit.cs.mod_rm_cs_gen.outputs }

gui_sg_move "$_session_group_2043" -after "$_session_group_2027" -pos 10 

set _session_group_2044 $_session_group_2027|
append _session_group_2044 piece_of_shit_rep_controller
gui_sg_create "$_session_group_2044"
set stages|decode_unit|piece_of_shit_rep_controller "$_session_group_2044"

gui_sg_addsignal -group "$_session_group_2044" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.clk tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.rep_fsm_state tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.rep_cmp_fsm_state tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.rep_movs_fsm_state tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.rst tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.mov_inst tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_inst tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.clear_zf tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.set_zf tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.ecx tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.ecx_sb tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.zf_flag tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.stall tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.flush tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.clear_rep tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.continue_mov tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.continue_cmp tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.wait_mov tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.wait_cmp tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.exit_mov tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.exit_cmp tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.inst_select tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_inst_select tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_inst_select tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_clear tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_clear tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_start tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_start tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.rep_latches tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.zf_sb tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.idle_output tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_instruction tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.dec_ecx tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp2 }

gui_sg_move "$_session_group_2044" -after "$_session_group_2027" -pos 9 

set _session_group_2045 $_session_group_2044|
append _session_group_2045 cmp_fsm
gui_sg_create "$_session_group_2045"
set stages|decode_unit|piece_of_shit_rep_controller|cmp_fsm "$_session_group_2045"

gui_sg_addsignal -group "$_session_group_2045" { tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.clk tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.rst tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.start_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.exit_mov_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.cont_cmp_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.exit_cmp_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.wait_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.S_0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.S_1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.S_2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.clear_rep_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.select_line2_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.select_line1_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.select_line0_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.S_0_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.S_1_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.S_2_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.cont_cmp_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.exit_cmp_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.exit_mov_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.wait_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_0_t0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_0_t1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_0_t2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_0_t3 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_0_t4 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_0_t5 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_0_t6 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_1_t0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_1_t1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_1_t2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_1_t3 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_1_t4 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_1_t5 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_1_t6 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_2_t0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_2_t1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_2_t2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_2_t3 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_2_t4 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_2_t5 }
gui_sg_addsignal -group "$_session_group_2045" { tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.NS_2_t6 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.clear_rep_o_t0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.clear_rep_o_t1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.select_line2_o_t0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.select_line2_o_t1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.select_line0_o_t0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.select_line0_o_t1 {tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.cmp_fsm.$unit} }

gui_sg_move "$_session_group_2045" -after "$_session_group_2044" -pos 7 

set _session_group_2046 $_session_group_2044|
append _session_group_2046 fsm_rep
gui_sg_create "$_session_group_2046"
set stages|decode_unit|piece_of_shit_rep_controller|fsm_rep "$_session_group_2046"

gui_sg_addsignal -group "$_session_group_2046" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.clk tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.rst tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.rep_prefix_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.cs_mov_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.cs_cmp_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.mov_clear_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.cmp_clear_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.stall_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.S_0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.S_1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.S_2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.movs_start_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.cmp_start_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.NS_0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.NS_1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.NS_2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.S_0_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.S_1_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.S_2_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.cmp_clear_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.cs_cmp_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.cs_mov_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.mov_clear_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.stall_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.NS_0_t0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.NS_0_t1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.NS_0_t2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.NS_0_t3 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.NS_0_t4 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.NS_0_t5 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.NS_1_t0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.NS_1_t1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.NS_1_t2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.NS_1_t3 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.NS_1_t4 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.NS_2_t0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.NS_2_t1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.fsm_rep.NS_2_t2 }

gui_sg_move "$_session_group_2046" -after "$_session_group_2044" -pos 6 

set _session_group_2047 $_session_group_2044|
append _session_group_2047 movs_fsm
gui_sg_create "$_session_group_2047"
set stages|decode_unit|piece_of_shit_rep_controller|movs_fsm "$_session_group_2047"

gui_sg_addsignal -group "$_session_group_2047" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.clk tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.rst tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.start_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.cont_mov_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.wait_mov_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.exit_mov_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.stall_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.S_0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.S_1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.S_2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.clear_rep_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.select_line2_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.select_line1_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.select_line0_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.NS_0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.NS_1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.NS_2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.S_0_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.S_1_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.S_2_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.cont_mov_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.exit_mov_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.stall_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.wait_mov_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.NS_0_t0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.NS_0_t1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.NS_0_t2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.NS_0_t3 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.NS_0_t4 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.NS_1_t0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.NS_1_t1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.NS_1_t2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.NS_1_t3 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.NS_1_t4 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.NS_1_t5 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.NS_2_t0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.movs_fsm.NS_2_t1 }

gui_sg_move "$_session_group_2047" -after "$_session_group_2044" -pos 5 

set _session_group_2048 $_session_group_2027|
append _session_group_2048 decode_2_RR_valid_logic
gui_sg_create "$_session_group_2048"
set stages|decode_unit|decode_2_RR_valid_logic "$_session_group_2048"

gui_sg_addsignal -group "$_session_group_2048" { {tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.$unit} tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.RR_we_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.N_RR_V_o tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.DECODE_V_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.RR_stall_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.RR_V_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.DC_stall_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.DC_V_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.MEM_V_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.MEM_stall_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.EXE_V_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.WB_stall_i tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.DC_V_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.DC_stall_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.EXE_V_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.MEM_V_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.MEM_stall_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.RR_V_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.RR_stall_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.WB_stall_i_inv tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.RR_we_o_t0 tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.RR_we_o_and0_buf_mid tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.RR_we_o_t1 tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.RR_we_o_t2 tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.RR_we_o_t3 tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.RR_we_o_t4 tb_stages.uut_AllAtOnce.core_unit.decode_unit.decode_2_RR_valid_logic.N_RR_V_o_and_buf_mid }

gui_sg_move "$_session_group_2048" -after "$_session_group_2027" -pos 8 

set _session_group_2049 $_session_group_1981|
append _session_group_2049 idm_unit
gui_sg_create "$_session_group_2049"
set stages|idm_unit "$_session_group_2049"

gui_sg_addsignal -group "$_session_group_2049" { tb_stages.uut_AllAtOnce.core_unit.idm_unit.fetch_outs_i tb_stages.uut_AllAtOnce.core_unit.idm_unit.idm_outs_o tb_stages.uut_AllAtOnce.core_unit.idm_unit.clk tb_stages.uut_AllAtOnce.core_unit.idm_unit.idm {tb_stages.uut_AllAtOnce.core_unit.idm_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.idm_unit.rst }

gui_sg_move "$_session_group_2049" -after "$_session_group_1981" -pos 1 

set _session_group_2050 $_session_group_1981|
append _session_group_2050 dc_unit
gui_sg_create "$_session_group_2050"
set stages|dc_unit "$_session_group_2050"

gui_sg_addsignal -group "$_session_group_2050" { tb_stages.uut_AllAtOnce.core_unit.dc_unit.rst tb_stages.uut_AllAtOnce.core_unit.dc_unit.clk tb_stages.uut_AllAtOnce.core_unit.dc_unit.latches_i.valid tb_stages.uut_AllAtOnce.core_unit.dc_unit.latches_i.EIP tb_stages.uut_AllAtOnce.core_unit.dc_unit.latches_i.exe_cs.OP_TYPE tb_stages.uut_AllAtOnce.core_unit.dc_unit.latches_i tb_stages.uut_AllAtOnce.core_unit.dc_unit.latches_i.ld_vaddy tb_stages.uut_AllAtOnce.core_unit.dc_unit.latches_i.st_vaddy tb_stages.uut_AllAtOnce.core_unit.dc_unit.wb_ST_OP tb_stages.uut_AllAtOnce.core_unit.dc_unit.next_st_addr_0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.next_st_addr_1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.next_st_xcl {tb_stages.uut_AllAtOnce.core_unit.dc_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_unit.arb_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.data_size_vec tb_stages.uut_AllAtOnce.core_unit.dc_unit.dc_ST_OP tb_stages.uut_AllAtOnce.core_unit.dc_unit.dc_outs_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.dc_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.dep_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.exe_ST_OP tb_stages.uut_AllAtOnce.core_unit.dc_unit.exe_outs_i tb_stages.uut_AllAtOnce.core_unit.dc_unit.exp_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.fetch_outs_i tb_stages.uut_AllAtOnce.core_unit.dc_unit.in_flight_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_0_V tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_1_V tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_mio tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_addr_mio_V tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_exception tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_out tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_latches_next_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_outs_i tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_stage_next_vaild_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_stage_we_valid_unit_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_served_0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_served_1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_served_mio tb_stages.uut_AllAtOnce.core_unit.dc_unit.rr_exception tb_stages.uut_AllAtOnce.core_unit.dc_unit.shift_sr_down tb_stages.uut_AllAtOnce.core_unit.dc_unit.shift_sr_up tb_stages.uut_AllAtOnce.core_unit.dc_unit.sr_data_size_vec tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_exception tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_out tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.wb_outs_i }

gui_sg_move "$_session_group_2050" -after "$_session_group_1981" -pos 4 

set _session_group_2051 $_session_group_2050|
append _session_group_2051 st_neuralnet_part2
gui_sg_create "$_session_group_2051"
set stages|dc_unit|st_neuralnet_part2 "$_session_group_2051"

gui_sg_addsignal -group "$_session_group_2051" { {tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.cross_page_access tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.datasize tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.mem_op tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.next_page_vaddy tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.outputs tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb0_generalprotection tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb0_in tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb0_out tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb0_pagefault tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb1_generalprotection tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb1_in tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb1_out tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb1_pagefault tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.vaddy_end tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.vaddy_end_fields tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.vaddy_start tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.vaddy_start_fields tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.write_intent }

gui_sg_move "$_session_group_2051" -after "$_session_group_2050" -pos 10 

set _session_group_2052 $_session_group_2051|
append _session_group_2052 tlb1
gui_sg_create "$_session_group_2052"
set stages|dc_unit|st_neuralnet_part2|tlb1 "$_session_group_2052"

gui_sg_addsignal -group "$_session_group_2052" { {tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb1.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb1.inputs tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb1.outputs tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb1.tlb }

gui_sg_move "$_session_group_2052" -after "$_session_group_2051" -pos 11 

set _session_group_2053 $_session_group_2051|
append _session_group_2053 tlb0
gui_sg_create "$_session_group_2053"
set stages|dc_unit|st_neuralnet_part2|tlb0 "$_session_group_2053"

gui_sg_addsignal -group "$_session_group_2053" { {tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb0.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb0.inputs tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb0.outputs tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb0.tlb }

gui_sg_move "$_session_group_2053" -after "$_session_group_2051" -pos 6 

set _session_group_2054 $_session_group_2050|
append _session_group_2054 stq_dep_check
gui_sg_create "$_session_group_2054"
set stages|dc_unit|stq_dep_check "$_session_group_2054"

gui_sg_addsignal -group "$_session_group_2054" { {tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.LD_OP tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.LD_XCL tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.ld0_bank_hit tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.ld0_bank_num tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.ld1_bank_hit tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.ld1_bank_num tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.ld_paddr_0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.ld_paddr_1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.stq_info tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.valid tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.valid_dep0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.stq_dep_check.valid_dep1 }

gui_sg_move "$_session_group_2054" -after "$_session_group_2050" -pos 11 

set _session_group_2055 $_session_group_2050|
append _session_group_2055 ld_neuralnet_part2
gui_sg_create "$_session_group_2055"
set stages|dc_unit|ld_neuralnet_part2 "$_session_group_2055"

gui_sg_addsignal -group "$_session_group_2055" { {tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.cross_page_access tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.datasize tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.mem_op tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.next_page_vaddy tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.outputs tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb0_generalprotection tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb0_in tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb0_out tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb0_pagefault tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb1_generalprotection tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb1_in tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb1_out tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.tlb1_pagefault tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.vaddy_end tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.vaddy_end_fields tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.vaddy_start tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.vaddy_start_fields tb_stages.uut_AllAtOnce.core_unit.dc_unit.ld_neuralnet_part2.write_intent }

gui_sg_move "$_session_group_2055" -after "$_session_group_2050" -pos 8 

set _session_group_2056 $_session_group_2050|
append _session_group_2056 req_gen_1
gui_sg_create "$_session_group_2056"
set stages|dc_unit|req_gen_1 "$_session_group_2056"

gui_sg_addsignal -group "$_session_group_2056" { tb_stages.uut_AllAtOnce.core_unit.dc_unit.mem_ST_OP {tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.$unit} tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.LD_OP tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.MIO tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.XCL tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.arb_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.clk tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.dep_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.forward_valid tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.is_served_0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.is_served_1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.is_served_mio tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_0_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_1_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_addr0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_addr1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_addrMIO tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_addr_0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_addr_0_V tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_addr_1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_addr_1_V tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_addr_mio tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.ld_addr_mio_V tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.mem_stage_next_valid_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.mem_stage_we_valid_unit_o tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.mio_stall tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.req_served_0 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.req_served_1 tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.req_served_mio tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.rst tb_stages.uut_AllAtOnce.core_unit.dc_unit.req_gen.valid }

gui_sg_move "$_session_group_2056" -after "$_session_group_2050" -pos 9 

set _session_group_2057 $_session_group_1981|
append _session_group_2057 write_back_unit
gui_sg_create "$_session_group_2057"
set stages|write_back_unit "$_session_group_2057"

gui_sg_addsignal -group "$_session_group_2057" { {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.write_back_unit.rst tb_stages.uut_AllAtOnce.core_unit.write_back_unit.clk tb_stages.uut_AllAtOnce.core_unit.write_back_unit.wb_latches.valid tb_stages.uut_AllAtOnce.core_unit.write_back_unit.wb_latches.EIP tb_stages.uut_AllAtOnce.core_unit.write_back_unit.wb_latches tb_stages.uut_AllAtOnce.core_unit.write_back_unit.wb_latches.ST_XCL tb_stages.uut_AllAtOnce.core_unit.write_back_unit.wb_latches.ST_PADDR_0 tb_stages.uut_AllAtOnce.core_unit.write_back_unit.wb_latches.ST_BIT_VEC_0 tb_stages.uut_AllAtOnce.core_unit.write_back_unit.wb_latches.ST_PADDR_1 tb_stages.uut_AllAtOnce.core_unit.write_back_unit.wb_latches.ST_BIT_VEC_1 tb_stages.uut_AllAtOnce.core_unit.write_back_unit.dc_dep tb_stages.uut_AllAtOnce.core_unit.write_back_unit.mio_push_fail tb_stages.uut_AllAtOnce.core_unit.write_back_unit.mio_q_input tb_stages.uut_AllAtOnce.core_unit.write_back_unit.mio_q_output tb_stages.uut_AllAtOnce.core_unit.write_back_unit.outputs tb_stages.uut_AllAtOnce.core_unit.write_back_unit.reg_wb_logic_outs tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stall_flop tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stall_flop_next tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stq_heads tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stq_info tb_stages.uut_AllAtOnce.core_unit.write_back_unit.stq_outputs tb_stages.uut_AllAtOnce.core_unit.write_back_unit.write_success tb_stages.uut_AllAtOnce.core_unit.write_back_unit.write_success_mio }

gui_sg_move "$_session_group_2057" -after "$_session_group_1981" -pos 7 

set _session_group_2058 $_session_group_2057|
append _session_group_2058 {gen_st_q[3].stq_inst}
gui_sg_create "$_session_group_2058"
set {stages|write_back_unit|gen_st_q[3].stq_inst} "$_session_group_2058"

gui_sg_addsignal -group "$_session_group_2058" { {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.$unit} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.clk} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.head} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.head_ptr} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.outputs} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.q} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.q_empty} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.q_full} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.rst} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.tail} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.tail_ptr} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.unnamed$$_10} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.valid_pop} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.valid_push} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[3].stq_inst.wb_in} }

gui_sg_move "$_session_group_2058" -after "$_session_group_2057" -pos 14 

set _session_group_2059 $_session_group_2057|
append _session_group_2059 {gen_st_q[2].stq_inst}
gui_sg_create "$_session_group_2059"
set {stages|write_back_unit|gen_st_q[2].stq_inst} "$_session_group_2059"

gui_sg_addsignal -group "$_session_group_2059" { {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.clk} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.head} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.head_ptr} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.outputs} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.q} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.q_empty} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.q_full} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.rst} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.tail} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.tail_ptr} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.unnamed$$_10} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.valid_pop} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.valid_push} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[2].stq_inst.wb_in} }

gui_sg_move "$_session_group_2059" -after "$_session_group_2057" -pos 13 

set _session_group_2060 $_session_group_2057|
append _session_group_2060 {gen_st_q[1].stq_inst}
gui_sg_create "$_session_group_2060"
set {stages|write_back_unit|gen_st_q[1].stq_inst} "$_session_group_2060"

gui_sg_addsignal -group "$_session_group_2060" { {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.clk} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.head} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.head_ptr} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.outputs} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.q} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.q_empty} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.q_full} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.rst} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.tail} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.tail_ptr} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.unnamed$$_10} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.valid_pop} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.valid_push} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[1].stq_inst.wb_in} }

gui_sg_move "$_session_group_2060" -after "$_session_group_2057" -pos 12 

set _session_group_2061 $_session_group_2057|
append _session_group_2061 {gen_st_q[0].stq_inst}
gui_sg_create "$_session_group_2061"
set {stages|write_back_unit|gen_st_q[0].stq_inst} "$_session_group_2061"

gui_sg_addsignal -group "$_session_group_2061" { {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.$unit} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.clk} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.head} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.head_ptr} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.outputs} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.q} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.q_empty} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.q_full} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.rst} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.tail} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.tail_ptr} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.unnamed$$_10} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.valid_pop} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.valid_push} {tb_stages.uut_AllAtOnce.core_unit.write_back_unit.gen_st_q[0].stq_inst.wb_in} }

gui_sg_move "$_session_group_2061" -after "$_session_group_2057" -pos 11 

set _session_group_2062 $_session_group_1981|
append _session_group_2062 fetch_unit
gui_sg_create "$_session_group_2062"
set stages|fetch_unit "$_session_group_2062"

gui_sg_addsignal -group "$_session_group_2062" { {tb_stages.uut_AllAtOnce.core_unit.fetch_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.fetch_unit.SPC tb_stages.uut_AllAtOnce.core_unit.fetch_unit.clk tb_stages.uut_AllAtOnce.core_unit.fetch_unit.rst tb_stages.uut_AllAtOnce.core_unit.fetch_unit.dma_int tb_stages.uut_AllAtOnce.core_unit.fetch_unit.exp_mode_jk tb_stages.uut_AllAtOnce.core_unit.fetch_unit.int_mode_jk tb_stages.uut_AllAtOnce.core_unit.fetch_unit.DMA_int_jk tb_stages.uut_AllAtOnce.core_unit.fetch_unit.f_exp tb_stages.uut_AllAtOnce.core_unit.fetch_unit.seg_xlation_out tb_stages.uut_AllAtOnce.core_unit.fetch_unit.rom_data_out tb_stages.uut_AllAtOnce.core_unit.fetch_unit.idm_ctrl_data_in tb_stages.uut_AllAtOnce.core_unit.fetch_unit.next_spc tb_stages.uut_AllAtOnce.core_unit.fetch_unit.spc_16 tb_stages.uut_AllAtOnce.core_unit.fetch_unit.br_restore_spc tb_stages.uut_AllAtOnce.core_unit.fetch_unit.br_target tb_stages.uut_AllAtOnce.core_unit.fetch_unit.spc_2_IDM_CTRL tb_stages.uut_AllAtOnce.core_unit.fetch_unit.en_icache tb_stages.uut_AllAtOnce.core_unit.fetch_unit.icache_info_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.idm_info_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.decode_outs_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.rr_outs_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.dc_outs_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.mem_outs_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.exe_outs_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.wb_outs_i tb_stages.uut_AllAtOnce.core_unit.fetch_unit.outs_o tb_stages.uut_AllAtOnce.core_unit.fetch_unit.predictor_inputs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.tlb_inputs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.btb_outs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.spc_sel_logic_outs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.predictor_outs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.idm_ctrl_logic_outs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.idm_invalidate_logic_outs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.tlb_outs tb_stages.uut_AllAtOnce.core_unit.fetch_unit.exp_set_logic_outs }

set _session_group_2063 $_session_group_1981|
append _session_group_2063 mem_unit
gui_sg_create "$_session_group_2063"
set stages|mem_unit "$_session_group_2063"

gui_sg_addsignal -group "$_session_group_2063" { {tb_stages.uut_AllAtOnce.core_unit.mem_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.mem_unit.rst tb_stages.uut_AllAtOnce.core_unit.mem_unit.clk tb_stages.uut_AllAtOnce.core_unit.mem_unit.latches_i.valid tb_stages.uut_AllAtOnce.core_unit.mem_unit.latches_i.EIP tb_stages.uut_AllAtOnce.core_unit.mem_unit.latches_i.exe_cs.OP_TYPE tb_stages.uut_AllAtOnce.core_unit.mem_unit.latches_i.LD_PADDR_0 tb_stages.uut_AllAtOnce.core_unit.mem_unit.latches_i.LD_PADDR_1 tb_stages.uut_AllAtOnce.core_unit.mem_unit.latches_i tb_stages.uut_AllAtOnce.core_unit.mem_unit.clr_dcache_arb_latches tb_stages.uut_AllAtOnce.core_unit.mem_unit.C0 tb_stages.uut_AllAtOnce.core_unit.mem_unit.bank_num_0 tb_stages.uut_AllAtOnce.core_unit.mem_unit.bank_num_1 tb_stages.uut_AllAtOnce.core_unit.mem_unit.br_rel_target tb_stages.uut_AllAtOnce.core_unit.mem_unit.cacheline tb_stages.uut_AllAtOnce.core_unit.mem_unit.clr_dcache_mio_latch tb_stages.uut_AllAtOnce.core_unit.mem_unit.exe_latches_next_o tb_stages.uut_AllAtOnce.core_unit.mem_unit.exe_outs_i tb_stages.uut_AllAtOnce.core_unit.mem_unit.exe_stage_next_vaild_o tb_stages.uut_AllAtOnce.core_unit.mem_unit.exe_stage_we_valid_unit_o tb_stages.uut_AllAtOnce.core_unit.mem_unit.forward_valid tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_MIO tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_buf tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_buf_mio tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_buf_mio_v tb_stages.uut_AllAtOnce.core_unit.mem_unit.hit_buf_v tb_stages.uut_AllAtOnce.core_unit.mem_unit.ld_buf tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_MIO tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_0 tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_0_masked tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_1 tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_1_masked tb_stages.uut_AllAtOnce.core_unit.mem_unit.line_in_mio tb_stages.uut_AllAtOnce.core_unit.mem_unit.low_buf tb_stages.uut_AllAtOnce.core_unit.mem_unit.miss_stall tb_stages.uut_AllAtOnce.core_unit.mem_unit.outs_o tb_stages.uut_AllAtOnce.core_unit.mem_unit.rel_offset tb_stages.uut_AllAtOnce.core_unit.mem_unit.up_buf tb_stages.uut_AllAtOnce.core_unit.mem_unit.wb_outs_i }

gui_sg_move "$_session_group_2063" -after "$_session_group_1981" -pos 5 

set _session_group_2064 $_session_group_2063|
append _session_group_2064 mem_stall
gui_sg_create "$_session_group_2064"
set stages|mem_unit|mem_stall "$_session_group_2064"

gui_sg_addsignal -group "$_session_group_2064" { {tb_stages.uut_AllAtOnce.core_unit.mem_unit.mem_stall.$unit} tb_stages.uut_AllAtOnce.core_unit.mem_unit.mem_stall.valid tb_stages.uut_AllAtOnce.core_unit.mem_unit.mem_stall.LD_XCL tb_stages.uut_AllAtOnce.core_unit.mem_unit.mem_stall.LD_OP tb_stages.uut_AllAtOnce.core_unit.mem_unit.mem_stall.MIO tb_stages.uut_AllAtOnce.core_unit.mem_unit.mem_stall.hits tb_stages.uut_AllAtOnce.core_unit.mem_unit.mem_stall.hit_MIO tb_stages.uut_AllAtOnce.core_unit.mem_unit.mem_stall.hit_buf_v tb_stages.uut_AllAtOnce.core_unit.mem_unit.mem_stall.hit_buf_mio_v tb_stages.uut_AllAtOnce.core_unit.mem_unit.mem_stall.bank_num_0 tb_stages.uut_AllAtOnce.core_unit.mem_unit.mem_stall.bank_num_1 tb_stages.uut_AllAtOnce.core_unit.mem_unit.mem_stall.miss_stall tb_stages.uut_AllAtOnce.core_unit.mem_unit.mem_stall.xcl_miss tb_stages.uut_AllAtOnce.core_unit.mem_unit.mem_stall.ld_miss tb_stages.uut_AllAtOnce.core_unit.mem_unit.mem_stall.mio_miss }

set _session_group_2065 $_session_group_1981|
append _session_group_2065 rr_unit
gui_sg_create "$_session_group_2065"
set stages|rr_unit "$_session_group_2065"

gui_sg_addsignal -group "$_session_group_2065" { tb_stages.uut_AllAtOnce.core_unit.rr_unit.rst tb_stages.uut_AllAtOnce.core_unit.rr_unit.clk tb_stages.uut_AllAtOnce.core_unit.rr_unit.latchesInUse.valid tb_stages.uut_AllAtOnce.core_unit.rr_unit.latchesInUse.EIP tb_stages.uut_AllAtOnce.core_unit.rr_unit.latchesInUse.exe_cs.OP_TYPE tb_stages.uut_AllAtOnce.core_unit.rr_unit.latchesInUse {tb_stages.uut_AllAtOnce.core_unit.rr_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.rr_unit.actual_next_st_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.RR_GP tb_stages.uut_AllAtOnce.core_unit.rr_unit.actual_st_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.decode_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.SEGMENT_LIMITS tb_stages.uut_AllAtOnce.core_unit.rr_unit.addygen_input_addy tb_stages.uut_AllAtOnce.core_unit.rr_unit.cs_sb tb_stages.uut_AllAtOnce.core_unit.rr_unit.dc_latches_next tb_stages.uut_AllAtOnce.core_unit.rr_unit.dc_latches_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.dc_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.depstall tb_stages.uut_AllAtOnce.core_unit.rr_unit.ecx_sb tb_stages.uut_AllAtOnce.core_unit.rr_unit.exe_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.fetch_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.instructionforward tb_stages.uut_AllAtOnce.core_unit.rr_unit.latches_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.ld_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.mem_outs_i tb_stages.uut_AllAtOnce.core_unit.rr_unit.next_dc_valid tb_stages.uut_AllAtOnce.core_unit.rr_unit.next_ld_vaddy tb_stages.uut_AllAtOnce.core_unit.rr_unit.outs_o tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_out tb_stages.uut_AllAtOnce.core_unit.rr_unit.rr_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.seg0_limit_w_datasize tb_stages.uut_AllAtOnce.core_unit.rr_unit.seg1_limit_w_datasize tb_stages.uut_AllAtOnce.core_unit.rr_unit.wb_outs_i }

gui_sg_move "$_session_group_2065" -after "$_session_group_1981" -pos 3 

set _session_group_2066 $_session_group_2065|
append _session_group_2066 reg_sb_unit
gui_sg_create "$_session_group_2066"
set stages|rr_unit|reg_sb_unit "$_session_group_2066"

gui_sg_addsignal -group "$_session_group_2066" { {tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.SCORE_BOARD tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.Segment0_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.Segment1_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.Segment1_valid tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.callFlush tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.clk tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.codeSeg_sb tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_dr_rd tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_dr_wr tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_eax_rd tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_eax_wr tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_sib_size tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_sr_rd tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_sr_wr tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.cs_wr_to_both tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.depStall_Internal tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.dep_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.dr_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.dr_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.eax_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.ecx_sb tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.farFlush tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.flush tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.instructionforward tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.next_SCORE_BOARD tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.rst tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.seg0_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.seg1_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_base_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_base_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_idx_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sib_idx_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sr_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.sr_stall tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.updateSB tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb0_dr_same_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb0_eax_same_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb0_sr_same_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb1_dr_same_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb1_eax_same_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb1_sr_same_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr0_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr0_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr1_id tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_dr1_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.reg_sb_unit.wb_wr_to_both }

gui_sg_move "$_session_group_2066" -after "$_session_group_2065" -pos 7 

set _session_group_2067 $_session_group_2065|
append _session_group_2067 RegisterFile_unit
gui_sg_create "$_session_group_2067"
set stages|rr_unit|RegisterFile_unit "$_session_group_2067"

gui_sg_addsignal -group "$_session_group_2067" { {tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.$unit} tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.DR_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.REGISTERS tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.SIB_BASE_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.SIB_IDX_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.SR_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.Segment0_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.Segment1_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR0_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR0_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR0_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR1_ID tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR1_data tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.WB_DR1_we tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.clk tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.outputs tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.rst tb_stages.uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit.wb_wr_to_both }

gui_sg_move "$_session_group_2067" -after "$_session_group_2065" -pos 6 

# Global: Highlighting
gui_highlight_signals -color #00ff00 {{tb_stages.uut_AllAtOnce.core_unit.execute_unit.u_alu_input_sel.dr_data[63:0]}}

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 6099.472



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
gui_list_set_filter -id ${Hier.1} -list { {Package 1} {All 0} {Process 1} {VirtPowSwitch 0} {UnnamedProcess 1} {UDP 0} {Function 0} {Block 1} {SrsnAndSpaCell 0} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {LeafVhdCell 1} {$unit 1} {NamedBlock 1} {Task 0} {VlgPackage 1} {ClassDef 1} {VirtIsoCell 0} }
gui_list_set_filter -id ${Hier.1} -text {*}
gui_hier_list_init -id ${Hier.1}
gui_change_design -id ${Hier.1} -design V1
catch {gui_list_expand -id ${Hier.1} tb_stages}
catch {gui_list_expand -id ${Hier.1} tb_stages.uut_AllAtOnce}
catch {gui_list_expand -id ${Hier.1} tb_stages.uut_AllAtOnce.core_unit}
catch {gui_list_select -id ${Hier.1} {tb_stages.uut_AllAtOnce.core_unit.dc_unit}}
gui_view_scroll -id ${Hier.1} -vertical -set 208
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {tb_stages.uut_AllAtOnce.core_unit.dc_unit}
gui_list_expand -id ${Data.1} tb_stages.uut_AllAtOnce.core_unit.dc_unit.latches_i
gui_show_window -window ${Data.1}
catch { gui_list_select -id ${Data.1} {tb_stages.uut_AllAtOnce.core_unit.dc_unit.latches_i.ld_vaddy tb_stages.uut_AllAtOnce.core_unit.dc_unit.latches_i.st_vaddy tb_stages.uut_AllAtOnce.core_unit.dc_unit.latches_i.ld_vaddy tb_stages.uut_AllAtOnce.core_unit.dc_unit.latches_i.st_vaddy }}
gui_view_scroll -id ${Data.1} -vertical -set 1134
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 208
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# DriverLoad 'DriverLoad.1'
gui_get_drivers -session -id ${DriverLoad.1} -signal tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches.valid -time 476 -starttime 477.846
gui_get_drivers -session -id ${DriverLoad.1} -signal {tb_stages.uut_AllAtOnce.core_unit.exe_latches_unit.latches.cs.OP_TYPE[31:0]} -time 476 -starttime 477.846
gui_get_drivers -session -id ${DriverLoad.1} -signal {tb_stages.uut_AllAtOnce.core_unit.execute_unit.srA[63:0]} -time 1436 -starttime 1479.979

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing /misc/scratch/he3837/UARCH/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/predecode.v
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
gui_marker_create -id ${Wave.1} M1 444
gui_marker_create -id ${Wave.1} M2 452
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 6083.357 6310.999
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
gui_list_add_group -id ${Wave.1}  -after stages {stages|fetch_unit}
gui_list_add_group -id ${Wave.1} -after stages|fetch_unit {stages|idm_unit}
gui_list_add_group -id ${Wave.1} -after stages|idm_unit {stages|decode_unit}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.decode_unit.rr_latches_next {stages|decode_unit|decode_2_RR_valid_logic}
gui_list_add_group -id ${Wave.1} -after stages|decode_unit|decode_2_RR_valid_logic {stages|decode_unit|piece_of_shit_rep_controller}
gui_list_add_group -id ${Wave.1} -after {{tb_stages.uut_AllAtOnce.core_unit.decode_unit.piece_of_shit_rep_controller.rep_movs_fsm_state[2:0]}} {stages|decode_unit|piece_of_shit_rep_controller|movs_fsm}
gui_list_add_group -id ${Wave.1} -after stages|decode_unit|piece_of_shit_rep_controller|movs_fsm {stages|decode_unit|piece_of_shit_rep_controller|fsm_rep}
gui_list_add_group -id ${Wave.1} -after stages|decode_unit|piece_of_shit_rep_controller|fsm_rep {stages|decode_unit|piece_of_shit_rep_controller|cmp_fsm}
gui_list_add_group -id ${Wave.1} -after stages|decode_unit|piece_of_shit_rep_controller {stages|decode_unit|mod_rm_cs_gen}
gui_list_add_group -id ${Wave.1} -after stages|decode_unit|mod_rm_cs_gen {stages|decode_unit|inst_processing}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.rst {stages|decode_unit|inst_processing|checker0}
gui_list_add_group -id ${Wave.1} -after stages|decode_unit|inst_processing|checker0 {stages|decode_unit|inst_processing|num_pf_gen0}
gui_list_add_group -id ${Wave.1} -after stages|decode_unit|inst_processing|num_pf_gen0 {stages|decode_unit|inst_processing|vec_gen}
gui_list_add_group -id ${Wave.1} -after stages|decode_unit|inst_processing|vec_gen {stages|decode_unit|inst_processing|neip_picker_mux}
gui_list_add_group -id ${Wave.1} -after stages|decode_unit|inst_processing|neip_picker_mux {stages|decode_unit|inst_processing|pfs1}
gui_list_add_group -id ${Wave.1} -after {{tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs1.total_pf_vector[9:0]}} {stages|decode_unit|inst_processing|pfs1|opcode_size}
gui_list_add_group -id ${Wave.1} -after stages|decode_unit|inst_processing|pfs1|opcode_size {stages|decode_unit|inst_processing|pfs1|mod_size}
gui_list_add_group -id ${Wave.1} -after stages|decode_unit|inst_processing|pfs1|mod_size {stages|decode_unit|inst_processing|pfs1|adder0}
gui_list_add_group -id ${Wave.1} -after stages|decode_unit|inst_processing|pfs1 {stages|decode_unit|inst_processing|pfs2}
gui_list_add_group -id ${Wave.1} -after {{tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs2.inst_length[3:0]}} {stages|decode_unit|inst_processing|pfs2|adder0}
gui_list_add_group -id ${Wave.1} -after stages|decode_unit|inst_processing|pfs2 {stages|decode_unit|inst_processing|pfs0}
gui_list_add_group -id ${Wave.1} -after {{tb_stages.uut_AllAtOnce.core_unit.decode_unit.inst_processing.pfs0.msd_size_o[2:0]}} {stages|decode_unit|inst_processing|pfs0|adder0}
gui_list_add_group -id ${Wave.1} -after stages|decode_unit|inst_processing|pfs0 {stages|decode_unit|inst_processing|sel_log1}
gui_list_add_group -id ${Wave.1} -after stages|decode_unit|inst_processing {stages|decode_unit|cs_post_prossesing_unit}
gui_list_add_group -id ${Wave.1} -after stages|decode_unit {stages|rr_unit}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.rr_unit.latchesInUse {stages|rr_unit|RegisterFile_unit}
gui_list_add_group -id ${Wave.1} -after stages|rr_unit|RegisterFile_unit {stages|rr_unit|reg_sb_unit}
gui_list_add_group -id ${Wave.1} -after stages|rr_unit {stages|dc_unit}
gui_list_add_group -id ${Wave.1} -after {{tb_stages.uut_AllAtOnce.core_unit.dc_unit.latches_i.st_vaddy[31:0]}} {stages|dc_unit|ld_neuralnet_part2}
gui_list_add_group -id ${Wave.1} -after stages|dc_unit|ld_neuralnet_part2 {stages|dc_unit|req_gen_1}
gui_list_add_group -id ${Wave.1} -after stages|dc_unit|req_gen_1 {stages|dc_unit|st_neuralnet_part2}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.outputs {stages|dc_unit|st_neuralnet_part2|tlb0}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.dc_unit.st_neuralnet_part2.tlb0_pagefault {stages|dc_unit|st_neuralnet_part2|tlb1}
gui_list_add_group -id ${Wave.1} -after stages|dc_unit|st_neuralnet_part2 {stages|dc_unit|stq_dep_check}
gui_list_add_group -id ${Wave.1} -after stages|dc_unit {stages|mem_unit}
gui_list_add_group -id ${Wave.1} -after tb_stages.uut_AllAtOnce.core_unit.mem_unit.latches_i {stages|mem_unit|mem_stall}
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
gui_list_add_group -id ${Wave.1} -after {{tb_stages.uut_AllAtOnce.core_unit.write_back_unit.wb_latches.ST_BIT_VEC_1[15:0]}} {{stages|write_back_unit|gen_st_q[0].stq_inst}}
gui_list_add_group -id ${Wave.1} -after {{stages|write_back_unit|gen_st_q[0].stq_inst}} {{stages|write_back_unit|gen_st_q[1].stq_inst}}
gui_list_add_group -id ${Wave.1} -after {{stages|write_back_unit|gen_st_q[1].stq_inst}} {{stages|write_back_unit|gen_st_q[2].stq_inst}}
gui_list_add_group -id ${Wave.1} -after {{stages|write_back_unit|gen_st_q[2].stq_inst}} {{stages|write_back_unit|gen_st_q[3].stq_inst}}
gui_list_collapse -id ${Wave.1} uut_AllAtOnce_1
gui_list_collapse -id ${Wave.1} Mem_System
gui_list_collapse -id ${Wave.1} Mem_System|mem_unit_1
gui_list_collapse -id ${Wave.1} Mem_System|icache_unit
gui_list_collapse -id ${Wave.1} Mem_System|dma_controller_unit
gui_list_collapse -id ${Wave.1} Mem_System|ddr5_unit
gui_list_collapse -id ${Wave.1} Mem_System|dcache_unit
gui_list_collapse -id ${Wave.1} Mem_System|bus_arbitration_unit
gui_list_collapse -id ${Wave.1} flags_reg
gui_list_collapse -id ${Wave.1} flags_reg|reg_sb_unit
gui_list_collapse -id ${Wave.1} flags_reg|RegisterFile_unit
gui_list_collapse -id ${Wave.1} uut_stuff
gui_list_collapse -id ${Wave.1} uut_stuff|u_mov_op
gui_list_collapse -id ${Wave.1} uut_stuff|u_sbb_op
gui_list_collapse -id ${Wave.1} Core
gui_list_collapse -id ${Wave.1} Core|core_unit
gui_list_collapse -id ${Wave.1} latches
gui_list_collapse -id ${Wave.1} latches|idm_unit
gui_list_collapse -id ${Wave.1} latches|rr_latches_unit
gui_list_collapse -id ${Wave.1} latches|dc_latches_unit
gui_list_collapse -id ${Wave.1} latches|mem_latches_unit
gui_list_collapse -id ${Wave.1} latches|exe_latches_unit
gui_list_collapse -id ${Wave.1} latches|wb_latches_unit
gui_list_collapse -id ${Wave.1} stages|fetch_unit
gui_list_collapse -id ${Wave.1} stages|idm_unit
gui_list_collapse -id ${Wave.1} stages|decode_unit
gui_list_collapse -id ${Wave.1} stages|decode_unit|decode_2_RR_valid_logic
gui_list_collapse -id ${Wave.1} stages|decode_unit|piece_of_shit_rep_controller
gui_list_collapse -id ${Wave.1} stages|decode_unit|piece_of_shit_rep_controller|movs_fsm
gui_list_collapse -id ${Wave.1} stages|decode_unit|piece_of_shit_rep_controller|fsm_rep
gui_list_collapse -id ${Wave.1} stages|decode_unit|piece_of_shit_rep_controller|cmp_fsm
gui_list_collapse -id ${Wave.1} stages|decode_unit|mod_rm_cs_gen
gui_list_collapse -id ${Wave.1} stages|decode_unit|inst_processing
gui_list_collapse -id ${Wave.1} stages|decode_unit|inst_processing|checker0
gui_list_collapse -id ${Wave.1} stages|decode_unit|inst_processing|num_pf_gen0
gui_list_collapse -id ${Wave.1} stages|decode_unit|inst_processing|vec_gen
gui_list_collapse -id ${Wave.1} stages|decode_unit|inst_processing|neip_picker_mux
gui_list_collapse -id ${Wave.1} stages|decode_unit|inst_processing|pfs1
gui_list_collapse -id ${Wave.1} stages|decode_unit|inst_processing|pfs1|opcode_size
gui_list_collapse -id ${Wave.1} stages|decode_unit|inst_processing|pfs1|mod_size
gui_list_collapse -id ${Wave.1} stages|decode_unit|inst_processing|pfs1|adder0
gui_list_collapse -id ${Wave.1} stages|decode_unit|inst_processing|pfs2
gui_list_collapse -id ${Wave.1} stages|decode_unit|inst_processing|pfs2|adder0
gui_list_collapse -id ${Wave.1} stages|decode_unit|inst_processing|pfs0
gui_list_collapse -id ${Wave.1} stages|decode_unit|inst_processing|pfs0|adder0
gui_list_collapse -id ${Wave.1} stages|decode_unit|inst_processing|sel_log1
gui_list_collapse -id ${Wave.1} stages|decode_unit|cs_post_prossesing_unit
gui_list_collapse -id ${Wave.1} stages|rr_unit
gui_list_collapse -id ${Wave.1} stages|rr_unit|RegisterFile_unit
gui_list_collapse -id ${Wave.1} stages|rr_unit|reg_sb_unit
gui_list_collapse -id ${Wave.1} stages|dc_unit
gui_list_collapse -id ${Wave.1} stages|dc_unit|ld_neuralnet_part2
gui_list_collapse -id ${Wave.1} stages|dc_unit|req_gen_1
gui_list_collapse -id ${Wave.1} stages|dc_unit|st_neuralnet_part2
gui_list_collapse -id ${Wave.1} stages|dc_unit|st_neuralnet_part2|tlb0
gui_list_collapse -id ${Wave.1} stages|dc_unit|st_neuralnet_part2|tlb1
gui_list_collapse -id ${Wave.1} stages|dc_unit|stq_dep_check
gui_list_collapse -id ${Wave.1} stages|mem_unit
gui_list_collapse -id ${Wave.1} stages|mem_unit|mem_stall
gui_list_collapse -id ${Wave.1} stages|execute_unit
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_sar_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_sal_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|wb_valid_logic_unit
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_zf_flag_sel
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_xchg_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_sr_sel
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_sf_flag_sel
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_sbb_op
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
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_af_flag_sel
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_add_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_adc_op
gui_list_collapse -id ${Wave.1} stages|execute_unit|u_aaa
gui_list_collapse -id ${Wave.1} stages|write_back_unit
gui_list_collapse -id ${Wave.1} {stages|write_back_unit|gen_st_q[0].stq_inst}
gui_list_collapse -id ${Wave.1} {stages|write_back_unit|gen_st_q[1].stq_inst}
gui_list_collapse -id ${Wave.1} {stages|write_back_unit|gen_st_q[2].stq_inst}
gui_list_collapse -id ${Wave.1} {stages|write_back_unit|gen_st_q[3].stq_inst}
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
gui_list_set_insertion_bar  -id ${Wave.1} -group stages|dc_unit  -position in

gui_marker_move -id ${Wave.1} {C1} 6099.472
gui_view_scroll -id ${Wave.1} -vertical -set 0
gui_show_grid -id ${Wave.1} -enable false
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Source.1}
	gui_set_active_window -window ${DLPane.1}
}
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
#</Session>

