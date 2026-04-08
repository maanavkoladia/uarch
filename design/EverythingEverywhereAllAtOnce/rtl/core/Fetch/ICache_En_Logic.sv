import Fetch_pkg::*;
import common_pkg::*;

module ICache_En_Logic(
    input rst,
    input exp_mode,
    input cs_sb,
    input int_mode,
    input f_exp,
    input DMA_int,

    output bool out

);

    assign out = !exp_mode && !cs_sb && !int_mode && !f_ex && !DMA_int && rst;

endmodule