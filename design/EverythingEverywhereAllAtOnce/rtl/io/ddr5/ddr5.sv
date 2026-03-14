module ddr5 (
    input wire clk,
    input wire rst,

    input dte_2_ddr5_t inFromDTE_i,

    inout [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus,
    inout [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addrBus

);
    //
endmodule
