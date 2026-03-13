//we dont throw gps here bc we catch them when we have an intruction that
//actually throws a gp, these are hanlded by the prev eip eip logic
import common_pkg::*;

module SegmentTranslation_Fetch (
    input l_address_t l_spc_addr_i,

    input uint32_t codeSeg_data_i,

    output v_address_t v_spc_addr_o
);
    assign v_spc_addr_o = (codeSeg_data_i << 16) + l_spc_addr_i;

endmodule

