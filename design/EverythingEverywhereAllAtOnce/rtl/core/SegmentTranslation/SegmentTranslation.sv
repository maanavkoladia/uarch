import common_pkg::l_address_t;
import common_pkg::v_address_t;

module SegmentTranslation (
    input wire clk,
    input wire rst,

    input l_address_t l_addr_i,
    input logic dataSize_i,

    input reg_ids_e segID_i,

    output l_address_t v_addr_o,
    output bool gp_fault_o

);

endmodule

