import Fetch_pkg::*;
import common_pkg::*;

module ICache_En_Logic(
    input exp_mode,
    input cs_sb,
    input int_mode,

    output bool out

);

    assign out = !exp_mode && !cs_sb && !int_mode;

endmodule