
package Fetch_pkg;
    import common_pkg::*;

    typedef struct {
        address_t btfn_target;
        address_t spc;
    } btfn_inputs_t;

    typedef struct {bool taken;} btfn_output_t;

    typedef struct {
        address_t spc;

        //execute info
        bool exe_br_valid;
        address_t exe_br_target;
        address_t exe_br_eip;
        bool exe_br_XCL;
    } btb_input_t;

    typedef struct {
        bool hit;
        address_t br_target;
        address_t br_eip;
        bool XCL;
    } btb_output_t;



endpackage
