define_design_lib WORK -path ./WORK

set top_design "AllAtOnce_TOP"

# Send analyze/elaborate/link chatter to a log file so the terminal
# only shows the behavioral-code report at the end. The whole setup
# is wrapped in catch so that a Tcl-level error aborts cleanly. Each
# major step's return value is also checked: analyze/elaborate/link
# return 0 on failure without necessarily throwing, so we convert
# those into errors with `error` so the catch picks them up.
set setup_status [catch {
redirect -file check_behavioral_setup.log {

if {![analyze -format Verilog {
lib_header
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/defines/common_define.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/defines/interconnect_define.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/defines/BusArbitration_common_define.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/defines/core_stage_latches_define.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/defines/DCache_common_define.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/defines/DCache_req_2_sch_define.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/defines/DTE_FSM_gen_define.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/defines/ICache_common_define.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/defines/io_common_define.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/defines/mem_common_define.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/defines/reg_ids_define.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/defines/exe_structural_defines.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/defines/TLB_define.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/lib/Common/LOG.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/lib/Common/utils.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/lib/STDCells/MUX_Multi.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/lib/STDCells/NAND_N_NOR_N.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/lib/STDCells/AND_multi.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/lib/STDCells/OR_multi.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/lib/STDCells/AND_N.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/lib/STDCells/OR_N.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/lib/STDCells/MUX_N.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/lib/STDCells/decoder_N.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/lib/STDCells/UniqueLib.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/lib/STDCells/REG_N.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/lib/STDCells/STDCell_Macros.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/lib/STDCells/triple_adder.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/lib/STDCells/KoggeStone.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/mem/structural/fanout/bank_controller_fsm_logic.sv
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/mem/structural/fanout/MemBank_Structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/mem/structural/fanout/mem_controller_fsm.sv
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/mem/structural/fanout/mem_controller_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/mem/structural/fanout/mem_TOP_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/ICache/structural/fanout/ICache_Controller_Logic.sv
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/ICache/structural/fanout/ICache_DataStore_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/ICache/structural/fanout/ICache_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/ICache/structural/fanout/ICache_TagStore_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/ICache/structural/fanout/I_VCache_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/DCache/structural/fanout/DCache_Arbitration_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/DCache/structural/fanout/DCache_Bank_DataStore_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/DCache/structural/fanout/DCache_Bank_FSM.sv
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/DCache/structural/fanout/DCache_Bank_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/DCache/structural/fanout/DCache_Bank_TagStore_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/DCache/structural/fanout/DCache_Block_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/DCache/structural/fanout/DCache_TOP_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/DCache/structural/fanout/EvictionBuf_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/DCache/structural/fanout/LRU_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/DCache/structural/fanout/MIO_Block_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/DCache/structural/fanout/VCache_DataStore_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/DCache/structural/fanout/VCache_FSM.sv
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/DCache/structural/fanout/VCache_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/DCache/structural/fanout/VCache_TagStore_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/BusArbitration/structural/fanout/BusArbitration_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/BusArbitration/structural/fanout/DTE_Core_2_DDR5_FSM.sv
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/BusArbitration/structural/fanout/DTE_Core_2_DMA_FSM.sv
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/BusArbitration/structural/fanout/DTE_DCache_2_MEM_FSM.sv
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/BusArbitration/structural/fanout/DTE_DDR5_2_Core_FSM.sv
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/BusArbitration/structural/fanout/DTE_DMA_2_MEM_FSM.sv
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/BusArbitration/structural/fanout/DTE_MEM_2_DCache_FSM.sv
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/BusArbitration/structural/fanout/DTE_MEM_2_ICache_FSM.sv
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/BusArbitration/structural/fanout/DTE_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/BusArbitration/structural/fanout/Scheduler_DCachePicking_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/BusArbitration/structural/fanout/Scheduler_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/io/DMA_Controller/structural/fanout/DMA_FSM.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/io/DMA_Controller/structural/fanout/DMA_Controller_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/io/ddr5/structural/ddr5_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/DC_latches.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/DC_outputs.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/DC_stage.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/decode_outputs.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/decode_stage.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/EXE_latches.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/EXE_outputs.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/EXE_stage.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/fetch_outputs.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/fetch_stage.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/IDM_outputs.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/IDM_stage.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/MEM_latches.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/MEM_outputs.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/MEM_stage.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/RR_latches.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/RR_outputs.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/RR_stage.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/WB_latches.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/WB_outputs.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/WB_stage.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/IDM/structural/IDM_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/TLB/TLB_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/structural/BTB_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/structural/BTFN_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/structural/EXP_Ctrl_ROMS_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/structural/EXP_Set_logic_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/structural/Fetch_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/structural/GShare_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/structural/ICache_En_Logic_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/structural/IDM_Ctrl_Logic_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/structural/IDM_Invalidate_Logic_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/structural/Predictor_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/structural/SegmentTranslation_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/structural/SPC_Sel_Logic_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/structural/two_bit_sat_count_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/../../defines/reg_ids_define.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/../../defines/control_store_define.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/gen/MOD_LUT.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/gen/OP_LUT.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/gen/PF_LUT.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/gen/rep_fsm.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/gen/rep_movs_fsm.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/gen/rep_cmp_fsm.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/gen/ir_logic.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/gen/length_adder.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/gen/ir_vector_roms.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/gen/rr_valid_logic.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/disp_finder_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/imm_finder_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/modrm_size.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/num_pf_gen.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/op_size.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/pf_checker.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/pf_vector_gen.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/ppu_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/selection_logic_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/sib_finder_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/predecode_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/br_info_processing_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/control_store_top_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/control_store_genned.sv
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/control_store_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/cs_post_processor_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/decode_gp_gen_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/modrm_processor_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/sib_processor_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/rep_controller_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/Decode/structural/Decode_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/RR/../../defines/reg_ids_define.vh
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/RR/gen/dc_valid_logic.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/RR/structural/npu_node1.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/RR/structural/RegFile.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/RR/structural/RegSB.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/RR/structural/RR_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/DC/gen/mem_valid_logic.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/DC/structural/npu_node2.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/DC/structural/in_flight_sb_logic.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/DC/structural/wb_stq_sb_logic.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/DC/structural/req_gen_logic.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/DC/structural/data_size_vec_logic.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/DC/structural/segx.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/DC/structural/push_address_gen.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/DC/structural/DC_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/MEM/gen/EXE_valid_logic.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/MEM/structural/mem_miss_stall_logic_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/MEM/structural/MEM_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/gen/wb_valid_logic.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/alu_input_sel_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/bit_vec_logic_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/branch_res_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/res_buf_logic_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/res_buf_sel_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/dr_sel_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/sr_sel_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/reg_wb_logic_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/flag_sel/af_flag_sel_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/flag_sel/cf_flag_sel_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/flag_sel/df_flag_sel_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/flag_sel/of_flag_sel_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/flag_sel/pf_flag_sel_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/flag_sel/sf_flag_sel_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/flag_sel/zf_flag_sel_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/flag_helpers_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/aaa_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/adc_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/add_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/and_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/bsf_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/call_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/cmp_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/cmpxchg_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/far_call_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/iretd_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/mov_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/not_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/or_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/packssdw_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/packsswb_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/paddd_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/paddw_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/pavgb_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/pavgw_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/pop_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/push_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/ret_far_imm_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/ret_far_ops_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/ret_imm_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/ret_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/sal_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/sar_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/sbb_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/xchg_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/movs_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/add_df_op_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/far_jmp_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/exp_call_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/FunctionalUnits/rep_cmp_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/EXE_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/WB/structural/MIO_Q_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/WB/structural/ST_Q_logic_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/WB/structural/ST_Q_MIO_logic_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/WB/structural/ST_Q_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/WB/structural/WB_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/StageLatches/structural/DC_Latches.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/StageLatches/structural/EXE_Latches.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/StageLatches/structural/MEM_Latches.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/StageLatches/structural/RR_Latches.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/StageLatches/structural/WB_Latches.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/core_structural/EveryThing_TOP_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/structural/Everywhere_TOP_structural.v
/misc/scratch/mak4738/uarch/uarch/design/EverythingEverywhereAllAtOnce/rtl/structural/AllAtOnce_TOP_structural.v
}]} { error "analyze failed" }

if {![elaborate $top_design]}        { error "elaborate failed" }
current_design $top_design
set target_library ""
set link_library "*"
if {![link]}                         { error "link failed" }

}
} setup_err]
# end of redirect / catch — everything below prints to the terminal

if {$setup_status != 0} {
    echo ""
    echo "============================================================"
    echo " ERROR during setup of $top_design"
    echo "   $setup_err"
    echo " See check_behavioral_setup.log for details."
    echo " Skipping behavioral check."
    echo "============================================================"
} else {

# ---------------------------------------------------------------------------
# Behavioral-code check
# ---------------------------------------------------------------------------
# After elaborate, any operator (&, |, +, ==, ?:, ~, etc.) or procedural
# block becomes either a GTECH_* primitive (e.g. GTECH_AND2) or a
# synthetic-operator cell whose ref_name contains _OP_ (e.g.
# *ADD_UNS_OP_8_8_8, *SELECT_OP_2.8_2.1_8, *EQ_UNS_OP_8_8_1). Inferred
# flops show up in all_registers as **SEQGEN**. Pure wiring (concat,
# bit-select, constant shift, direct assign) and explicit gate
# instantiations produce no such cells, so they are ignored.
# ---------------------------------------------------------------------------

set inferred [get_cells -hierarchical -filter \
    "ref_name =~ GTECH_* || ref_name =~ *_OP_*"]
set n_inferred [sizeof_collection $inferred]
set n_regs     [sizeof_collection [all_registers]]

echo "============================================================"
echo " Behavioral-code report for $top_design"
echo "============================================================"
echo " Inferred operator/GTECH cells : $n_inferred"
echo " Inferred registers            : $n_regs"
echo "------------------------------------------------------------"

if {$n_inferred > 0 || $n_regs > 0} {
    echo " >>> Behavioral / operator logic PRESENT"

    # ----- helpers -----------------------------------------------------
    # parent_module: which Verilog module owns this cell?
    #   * top-level cells (no parent path) belong to $top_design
    #   * deeper cells: parent_cell's ref_name is the Verilog module type
    proc parent_module {cell top_design} {
        set fn [get_attribute $cell full_name]
        set parent_path [file dirname $fn]
        if {$parent_path eq "." || $parent_path eq "/"} {
            return $top_design
        }
        set pcell [get_cells -quiet $parent_path]
        if {[sizeof_collection $pcell] == 0} {
            return "<unknown>"
        }
        return [get_attribute $pcell ref_name]
    }

    # grep_module: try one literal module name. Returns "<file>:<line>"
    # or "" on miss.
    proc grep_module {mod_name root} {
        set pat "^module +${mod_name}( |\\(|$)"
        if {[catch {
            set out [exec grep -rnE --include=*.v -- $pat $root]
        } _err]} {
            return ""
        }
        set first [lindex [split $out "\n"] 0]
        if {[regexp {^([^:]+):([0-9]+):} $first _ file lineno]} {
            return "$file:$lineno"
        }
        return $first
    }

    # find_module_source: try exact name, then progressively strip the
    # rightmost parameter suffix (DC mangles `module INV #(parameter
    # WIDTH=16)` instantiated as INV #(.WIDTH(8)) into `INV_WIDTH8`,
    # and multi-param into `<base>_<P1><V1>_<P2><V2>...`).  Walk back
    # through `_+<letters/digits>+<digits>$` chunks until the source
    # is found or there are no more suffixes to strip.
    set source_root "$::env(HOME)/MICROARCH"
    proc find_module_source {mod_name root} {
        set candidate $mod_name
        while {1} {
            set src [grep_module $candidate $root]
            if {$src ne ""} {
                if {$candidate eq $mod_name} {
                    return $src
                }
                return "$src   (template $candidate, specialized as $mod_name)"
            }
            set newc $candidate
            if {[regsub {_+[A-Za-z][A-Za-z0-9]*[0-9]+$} $newc "" newc] == 0} {
                break
            }
            if {$newc eq $candidate} break
            set candidate $newc
        }
        return "<not found>"
    }

    # ----- group cells & regs by parent Verilog module -----------------
    array unset by_module
    array unset regs_by_module
    foreach_in_collection c $inferred {
        set mod [parent_module $c $top_design]
        lappend by_module($mod) [list \
            [get_attribute $c full_name] [get_attribute $c ref_name]]
    }
    foreach_in_collection r [all_registers] {
        set mod [parent_module $r $top_design]
        lappend regs_by_module($mod) [get_attribute $r full_name]
    }

    set all_modules [lsort -unique [concat \
        [array names by_module] [array names regs_by_module]]]

    # ----- emit per-module report --------------------------------------
    foreach mod $all_modules {
        set src   [find_module_source $mod $source_root]
        set ncell 0; set nreg 0
        if {[info exists by_module($mod)]}      { set ncell [llength $by_module($mod)] }
        if {[info exists regs_by_module($mod)]} { set nreg  [llength $regs_by_module($mod)] }
        echo ""
        echo " Module $mod   (inferred cells: $ncell, regs: $nreg)"
        echo "   source: $src"
        if {$ncell > 0} {
            foreach pair $by_module($mod) {
                lassign $pair fn ref
                echo "     cell  $fn   ($ref)"
            }
        }
        if {$nreg > 0} {
            foreach fn $regs_by_module($mod) {
                echo "     reg   $fn"
            }
        }
    }
} else {
    echo " >>> Pure structural / wiring only - no behavioral code found"
}
echo "============================================================"

}
# end of `if {$setup_status != 0} ... else { ... }`
