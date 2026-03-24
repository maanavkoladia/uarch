import common_pkg::l_address_t;
import common_pkg::v_address_t;

module SegmentTranslation (
    input l_address_t l_addr_i,
    input logic[1:0] dataSize_i,

    input uint32_t segValue,
    input uint32_t segLimit,

    output v_address_t v_addr_o,
    output bool gp_fault_o
);
    assign v_addr_o = (segValue << 16) + l_addr_i;
    assign gp_fault_o = v_addr_o > segLimit;

endmodule

