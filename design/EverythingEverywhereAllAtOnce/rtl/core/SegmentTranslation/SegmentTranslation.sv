import common_pkg::l_address_t;
import common_pkg::v_address_t;
import common_pkg::bool;
import reg_ids_pkg::reg_ids_e;
import SegmentTranslation_pkg::*;
//written with Claude 
module SegmentTranslation (
    input wire clk,
    input wire rst,

    input l_address_t l_addr_i,      // Logical address (offset)
    input logic data_size_i,          // Data size for access (0=byte, 1=word/dword)

    input reg_ids_e segID_i,         // Segment ID (CS, DS, SS, ES, FS, GS)

    output l_address_t v_addr_o,     // Virtual/Linear address after translation
    output bool gp_fault_o           // General Protection Fault (limit violation)

);


    // Segment Descriptor Table (one entry per segment register)
    // In x86 protected mode, these would be loaded from GDT/LDT
    // For this implementation, we'll initialize them to reasonable defaults
    segment_descriptor_t seg_descriptors[6];

    // Internal signals
    segment_descriptor_t selected_descriptor;
    logic [31:0] access_end;         // Last byte of access (offset + size)
    logic limit_violation;

    // Initialize segment descriptors
    // Real x86 would load these from memory (GDT/LDT) when segment registers are loaded
    // For simplicity, using flat memory model with some limits
    initial begin
        // CS (Code Segment) - Index 0
        seg_descriptors[0].base  = 32'h00000000;
        seg_descriptors[0].limit = 32'hFFFFFFFF;  // 4GB limit (flat model)

        // DS (Data Segment) - Index 1
        seg_descriptors[1].base  = 32'h00000000;
        seg_descriptors[1].limit = 32'hFFFFFFFF;

        // SS (Stack Segment) - Index 2
        seg_descriptors[2].base  = 32'h00000000;
        seg_descriptors[2].limit = 32'hFFFFFFFF;

        // ES (Extra Segment) - Index 3
        seg_descriptors[3].base  = 32'h00000000;
        seg_descriptors[3].limit = 32'hFFFFFFFF;

        // FS - Index 4
        seg_descriptors[4].base  = 32'h00000000;
        seg_descriptors[4].limit = 32'hFFFFFFFF;

        // GS - Index 5
        seg_descriptors[5].base  = 32'h00000000;
        seg_descriptors[5].limit = 32'hFFFFFFFF;
    end

    // Segment Descriptor Selection
    // Map segment register ID to descriptor array index
    always_comb begin
        case (segID_i)
            reg_ids_pkg::CS: selected_descriptor = seg_descriptors[0];
            reg_ids_pkg::DS: selected_descriptor = seg_descriptors[1];
            reg_ids_pkg::SS: selected_descriptor = seg_descriptors[2];
            reg_ids_pkg::ES: selected_descriptor = seg_descriptors[3];
            reg_ids_pkg::FS: selected_descriptor = seg_descriptors[4];
            reg_ids_pkg::GS: selected_descriptor = seg_descriptors[5];
            default:         selected_descriptor = seg_descriptors[0]; // Default to CS
        endcase
    end

    // Calculate access range
    // data_size_i: 0 = byte access, 1 = larger access (assume 4 bytes for conservatism)
    always_comb begin
        access_end = l_addr_i + data_size_i;
    end

    // Segment Translation: Linear Address = Base + Offset
    // In x86 protected mode with flat memory model, segments typically have base=0
    // but we support non-zero bases for completeness
    assign v_addr_o = selected_descriptor.base + l_addr_i;

    // Limit Check: GP fault if access exceeds segment limit
    // In x86, limit check depends on granularity bit, but we'll use byte granularity
    always_comb begin
        if (access_end > selected_descriptor.limit)
            limit_violation = 1'b1;
        else
            limit_violation = 1'b0;
    end

    assign gp_fault_o = limit_violation;

endmodule

