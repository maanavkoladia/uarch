package Mem_pkg;

    import common_pkg::*;


    localparam int num_rows = 128;
    localparam int num_banks = 16;
    localparam int num_cols = 4;
 
    localparam int num_row_bits = $clog2(num_rows);
    localparam int num_bank_bits = $clog2(num_banks);
    localparam int num_col_bits = $clog2(num_cols);

    localparam int data_bus_width_bits = 32;
    localparam int address_bus_width_bits= 128;


//need to figure out later 

    typedef struct {
        logic [num_row_bits-1:0] row_addr;
        inout [data_busbus_width_bits-1:0] DIO;

        //arbitrator outputs here 

    } bank_outputs_t;





endpackage


