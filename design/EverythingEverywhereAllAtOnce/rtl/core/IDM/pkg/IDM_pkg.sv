
package IDM_pkg;

    import common_pkg::*;
    typedef struct {
        bool valid;
        bool br_valid;
        address_t br_eip;
        address_t br_target;
        bool br_xcl;
        byte_t data[CACHE_LINES_SIZE_B];

        // you may add internal-only metadata here later
        // e.g. age bits, debug tags, etc.
    } slot_t;

    typedef struct {slot_t slots[NUM_IDM_SLOTS];} idm_t;

endpackage
