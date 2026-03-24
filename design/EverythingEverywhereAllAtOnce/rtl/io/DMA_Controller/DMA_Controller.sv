import common_pkg::*;
import interconnect_pkg::*;
import io_common_pkg::*;


module DMA_Controller (

    input wire clk,
    input wire rst,

    input dte_2_dma_controller_t inFromDTE_i,

    output dma_controller_2_core_t out2Core_o,
    output dma_controller_2_scheduler_t out2Sch_o,

    inout [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus,
    inout [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addrBus
);
    //0x0000, DMA: write src addr, 32 bit
    //0x0010, DMA: write dest addr, 32 bit
    //0x0020, DMA: write num bytes to transfer, up to 12KB, 32 bit though
    //0x0030 DMA: start transfer, 1 bit, 32 bit though
    uint32_t srcAddr;
    uint32_t destAddr;
    uint32_t numBytes;
    uint32_t startWrite;

    bool write2_srcAddr_req = addrBus == DMA_WRITE_SRC_ADDRESS;
    bool write2_destddr_req = addrBus == DMA_WRITE_DEST_ADDRESS;
    bool write2_numBytes_req = addrBus == DMA_WRITE_NUM_BYTES_ADDRESS;
    bool write2_startWrite_req = addrBus == DMA_WRITE_START_TRANSFER_ADDRESS;

    always_ff @(posedge clk) begin
        if (!rst) begin
            srcAddr <= 0;
            destAddr <= 0;
            numBytes <= 0;
            startWrite <= 0;
        end
    end




endmodule
