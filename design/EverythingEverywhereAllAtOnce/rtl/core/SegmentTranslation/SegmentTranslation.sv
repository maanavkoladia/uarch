import common_pkg::l_address_t;
import common_pkg::v_address_t;

module SegmentTranslation(
    input wire clk,
    input wire rst,

    input l_address_t l_addr,
    input logic dataSize,

    input reg_ids_e segID,

    output l_address_t v_addr_out,
    output bool gp_fault,

);

endmodule

