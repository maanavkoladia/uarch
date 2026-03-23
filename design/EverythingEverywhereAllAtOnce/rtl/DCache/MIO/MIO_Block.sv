import common_pkg::*;
import DCache_pkg::*;
import interconnect_pkg::*;


module MIO_Block (
    input wire clk,
    input wire rst,  //active low

    //from dte
    input bool dataOnBus_FromDTE_i,
    input bool reqServed_FromDTE_i,
    input bool PermissionToDriveAddrBus,
    input bool permission2DriveDataBus,

    //from core
    input bool ld_addr_MIO_V,
    input p_address_t ld_addr_MIO,
    input st_q_2_dcache_t stq_info_mio,

    //only the address in the block req from mio arb
    inout [ADDRESS_BUS_WIDTH_BITS - 1 : 0] address_bus,
    //only data sitting in  the mio stq
    inout wire [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus,

    output mio_block_outputs_t outputs_o
);
    localparam int WE_ADDR_MASK = 15'h0040;
    //0x0000, DMA: write src addr, 32 bit
    //0x0010, DMA: write dest addr, 32 bit
    //0x0020, DMA: write num bytes to transfer, up to 12KB, 32 bit though
    //0x0030 DMA: start transfer, 1 bit, 32 bit though
    //0x0040 DDR5: write power gating 1 bit 32 bit though
    //0x0050 DDR5: ld temperature value

    block_req_MIO_t block_req;

    //arb
    always_ff @(posedge clk) begin
        if (!rst) block_req <= '0;
        else begin

        end
    end
    //outputs

    dcache_req_types_mio_2_scheduler_e block_req_2_sch;
    assign outputs_o.data_lineOut = {12'h000, dataBus};
    assign outputs_o.hit_o = dataOnBus_FromDTE_i;
    assign outputs_o.writeSuccess = reqServed_FromDTE_i;
    assign outputs_o.req_2_sch = block_req_2_sch;

    always_comb begin
        unique case ({
            block_req.we, block_req.oe
        })
            2'b00: block_req_2_sch = DCACHE_MIO_IDLE;

            2'b01: block_req_2_sch = DCACHE_MIO_LD_FROM_SIMPLE;

            2'b10:
            block_req_2_sch = block_req.p_addr & WE_ADDR_MASK ? DCACHE_MIO_WR_SIMPLE : DCACHE_MIO_WR_COMPLEX;

            2'b11: $fatal;
        endcase
    end

    //buses
    wire [ADDRESS_BUS_WIDTH_BITS - 1 : 0] address_bus_fake = block_req.p_addr;
    assign address_bus = PermissionToDriveAddrBus ? address_bus_fake : 'z;

    wire [ADDRESS_BUS_WIDTH_BITS - 1 : 0] data_bus_fake = {
        block_req.st_q_data[3],
        block_req.st_q_data[2],
        block_req.st_q_data[1],
        block_req.st_q_data[0]
    };
    assign dataBus = permission2DriveDataBus ? data_bus_fake : 'z;

endmodule
