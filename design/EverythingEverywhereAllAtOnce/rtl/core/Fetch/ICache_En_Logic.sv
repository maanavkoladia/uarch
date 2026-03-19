import Fetch_pkg::*;
import common_pkg::*;

module ICache_En_Logic(
    input exp_mode,
    input cs_sb,
    input int_mode,

    output icache_en_logic_output_t out

);

    assign out.en_icache = !exp_mode && !cs_sb && !int_mode;

endmodule