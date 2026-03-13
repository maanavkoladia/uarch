import common_pkg::*;
import core_stage_latches_pkg::NUM_IDM_SLOTS;
package IDM_pkg;

    typedef struct {
        bool valid;
        bool br_valid;
        address_t br_eip;
        address_t br_target;
        bool br_xcl;
        byte_t data[CACHE_LINES_SIZE];

        // you may add internal-only metadata here later
        // e.g. age bits, debug tags, etc.
    } slot_t;

    typedef struct {slot_t slots[NUM_IDM_SLOTS];} idm_t;

endpackage
