//this file needs to ouput the isntruncitons needed for
//taken an isntrunciton

module EXP_Ctrl_ROMS (
    //fully comb no clk

    //exp mux sels
    input logic RR_pf,
    input logic RR_exp,
    input logic Fetch_pf,

    //probably from the dma jk 
    input logic DMA_int,

    //from the expmode bit in fetch
    input logic exp_mode,

    output byte_t rom_data_out[CACHE_LINES_SIZE_B]
);




endmodule
