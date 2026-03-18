module DCache_Bank (
    input wire clk,
    input wire rst,
    
    input bool DCache_En,
    input p_address_t addr,

    //data bus is only an input here, outputs go to V$
    input dataBus[DATA_BUS_WIDTH_BITS -1 : 0],
    
    //

);

//need to run the dache fsm here,
//nned to create the dcache swap buffer
//need to create the data store
//need to create the TagStore
//


//create the cells for the dataStore

endmodule
