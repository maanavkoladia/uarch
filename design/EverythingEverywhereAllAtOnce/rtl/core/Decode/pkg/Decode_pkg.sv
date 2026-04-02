import common_pkg::*;
package Decode_pkg;

    typedef struct{
        reg_ids_e dr_id,
        reg_ids_e sr_id,
        bool dr_rd,
        bool sr_rd,
        bool dr_wr,
        bool sr_wr
    } modrm_processor_outs_t;

endpackage
