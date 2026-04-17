// ===========================================================================
// tb_debug_pkg.sv - Reusable Debug Tasks for Stage Testbenches
// ===========================================================================
// This package provides debug printing tasks that can work across different
// testbenches with different DUT instance names. 
//
// USAGE:
// Before importing this package, define the DUT instance names using macros:
//
//   `define CORE_DUT_PATH  uut_core
//   `define DCACHE_DUT_PATH uut_dcache
//   `define ICACHE_DUT_PATH uut_icache
//   import tb_debug_pkg::*;
//
// If a DUT is not present in your testbench, you can skip defining that macro.
// ===========================================================================

package tb_debug_pkg;

    import common_pkg::*;
    import interconnect_pkg::*;
    import core_common_pkg::*;
    import core_stage_latches_pkg::*;
    import control_store_pkg::*;
    import reg_ids_pkg::*;
    import Fetch_pkg::*;
    import DCache_common_pkg::*;
    import WriteBack_pkg::*;

    // ===================== REG NAME HELPER =====================
    function automatic string get_reg_name(reg_ids_e id);
        case (id)
            CS: return "CS ";
            DS: return "DS ";
            SS: return "SS ";
            ES: return "ES ";
            FS: return "FS ";
            GS: return "GS ";
            EAX: return "EAX";
            EBX: return "EBX";
            ECX: return "ECX";
            EDX: return "EDX";
            ESI: return "ESI";
            EDI: return "EDI";
            ESP: return "ESP";
            EBP: return "EBP";
            MM0: return "MM0";
            MM1: return "MM1";
            MM2: return "MM2";
            MM3: return "MM3";
            MM4: return "MM4";
            MM5: return "MM5";
            MM6: return "MM6";
            MM7: return "MM7";
            ETR: return "ETR";
            ERROR_REG: return "ERR";
            NO_REG: return "---";
            default: return "???";
        endcase
    endfunction

    function automatic string get_op_name(exe_cs_operation_type_e op);
        case (op)
            ADD: return "ADD";
            ADC: return "ADC";
            AND: return "AND";
            OR: return "OR ";
            NOT: return "NOT";
            SAL: return "SAL";
            SAR: return "SAR";
            SBB: return "SBB";
            BSF: return "BSF";
            CMP: return "CMP";
            MOV: return "MOV";
            PUSH: return "PSH";
            POP: return "POP";
            CALL: return "CAL";
            RET: return "RET";
            XCHG: return "XCH";
            CMPXCHG: return "CXG";
            IRETD: return "IRT";
            default: return "???";
        endcase
    endfunction

// ===================== SOURCE SELECTOR NAME HELPER =====================
function automatic string get_source_selector_name(source_selector_e sel);
    case (sel)
        // register sources
        control_store_pkg::NO_EXE        : return "NO_EXE";
        control_store_pkg::SR_REGISTER   : return "SR_REG";
        control_store_pkg::DR_REGISTER   : return "DR_REG";
        control_store_pkg::BUFFER        : return "BUFFER";
        control_store_pkg::NEIP          : return "NEIP";
        control_store_pkg::EAX_REG       : return "EAX_REG";
        control_store_pkg::SEXT8         : return "SEXT8";
        control_store_pkg::SEGMENT_NEIP  : return "SEG_NEIP";
        control_store_pkg::IMM64         : return "IMM64";

        // branch sources
        control_store_pkg::IMM32         : return "IMM32";
        control_store_pkg::ZEXT_IMM8     : return "ZIMM8";
        control_store_pkg::BUF32         : return "BUF32";
        control_store_pkg::ZEXT_BUF16    : return "ZBUF16";
        control_store_pkg::ZEXT_IMM16    : return "ZIMM16";
        control_store_pkg::SEGMENT_EIP   : return "SEG_EIP";
        control_store_pkg::FLAGS         : return "FLAGS";
        control_store_pkg::EIP           : return "EIP";
        control_store_pkg::CMPXCHG_SEL   : return "CMPXCHG";
        control_store_pkg::IRETD_SEL     : return "IRETD";

        default       : return "???";
    endcase
endfunction

    function automatic string get_spc_sel_name(spc_sel_logic_output_options_e sel);
        case (sel)
            Fetch_pkg::SPC: return "SPC     ";
            Fetch_pkg::SPC_P16: return "SPC_P16 ";
            Fetch_pkg::BR_RESTORE: return "BR_RST  ";
            Fetch_pkg::BTB_TARGET: return "BTB_TGT ";
            default: return "UNKNOWN ";
        endcase
    endfunction

endpackage
