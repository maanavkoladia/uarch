import common_pkg::*;
import interconnect_pkg::*;
import DCache_common_pkg::*;

module MIO_Block (
    input wire clk,
    input wire rst,  //active low

    //from dte
    //input bool dataOnBus_FromDTE_i,
    input bool reqServed_FromDTE_i,
    input bool PermissionToDriveAddrBus,
    input bool permission2DriveDataBus,

    //from core
    input bool ld_addr_MIO_V,
    input p_address_t ld_addr_MIO,
    input st_q_2_dcache_t stq_info_mio,
    input bool memStage_CLR_REQ_MIO,

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
    //0x0040 DDR5: write power gating 1 bit 32 bit thoughd
    //0x0050 DDR5: ld temperature value

    block_req_mio_t block_req;
    block_req_mio_t next_block_req;
    bool block_idle;
    assign block_idle = !block_req.oe && !block_req.we;
    bool readyForNewReq;

    //TODO need to updated readyForNew Req
    assign readyForNewReq = (block_req.we && reqServed_FromDTE_i) || (memStage_CLR_REQ_MIO && block_req.oe) || block_idle;

    //arb - combinational logic
    always_comb begin
        next_block_req = block_req;
        outputs_o.writeSuccess = 0;
        outputs_o.reqServed = 0;
        if (block_req.oe && block_req.we && rst) $fatal;
        if (readyForNewReq) begin
            if (ld_addr_MIO_V) begin
                next_block_req = '{
                    oe: 1,
                    we: 0,
                    p_addr: ld_addr_MIO,
                    st_q_data: '{default: '0}
                };
                outputs_o.reqServed = 1;
            end
            else if (!stq_info_mio.empty) begin
                next_block_req = '{
                    oe: 0,
                    we: 1,
                    p_addr: stq_info_mio.address,
                    st_q_data: stq_info_mio.data
                };
                outputs_o.writeSuccess = 1;
            end
            else next_block_req = '{default: '0};
        end
    end

    //register update
    always_ff @(posedge clk) begin
        if (!rst) block_req <= '{default: '0};
        else block_req <= next_block_req;
    end

    //outputs

    assign outputs_o.hit_o = reqServed_FromDTE_i && block_req.oe;

    //assign the output to the core, this is gonna be from ddr5
    always_comb begin
        outputs_o.dataLineOut = '{default: '0};  // zero all 16 bytes

        for (int i = 0; i < 4; i++) begin
            outputs_o.dataLineOut[i] = dataBus[i*8+:8];
        end
    end

    always_comb begin
        case ({
            block_req.we, block_req.oe
        })
            2'b00: outputs_o.req_2_sch = NO_REQ;

            2'b01: outputs_o.req_2_sch = DCACHE_MIO_LD_FROM_SIMPLE;

            2'b10:
            outputs_o.req_2_sch = block_req.p_addr & WE_ADDR_MASK ? 
            DCACHE_MIO_WR_SIMPLE : DCACHE_MIO_WR_COMPLEX;

            default: begin
            end
        endcase
    end

    //buses
    //wire [ADDRESS_BUS_WIDTH_BITS - 1 : 0] address_bus_fake = block_req.p_addr;
    assign address_bus = PermissionToDriveAddrBus ? block_req.p_addr : 'z;


    logic permission2DriveDataBus_bar;
    assign permission2DriveDataBus_bar = ~permission2DriveDataBus;
    logic [ADDRESS_BUS_WIDTH_BITS - 1 : 0] dataBus_drv;
    assign dataBus_drv = {
        block_req.st_q_data[3],
        block_req.st_q_data[2],
        block_req.st_q_data[1],
        block_req.st_q_data[0]
    };

    `BUS_TRISTATE(u_mio_block_busTristate, 32, permission2DriveDataBus_bar, dataBus_drv, dataBus);


endmodule
