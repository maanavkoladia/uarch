

//need to finish later


module bank(
   input logic [num_row_bits-1:0] row_addr;
   input logic arbitrator_req_valid;


   output bank_busy;



);
    import Mem_pkg::*;

    //the current row that is being sericed in the bank 
    logic [num_row_bits-1:0] curr_service_addr;


endmodule