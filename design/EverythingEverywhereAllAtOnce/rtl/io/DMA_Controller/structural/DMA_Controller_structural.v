import common_pkg::*;
import interconnect_pkg::*;
import io_common_pkg::*;

module DMA_Controller (

    input logic clk,
    input logic rst,

    input dte_2_dma_controller_t inFromDTE_i,

    output dma_controller_2_core_t      out2Core_o,
    output dma_controller_2_scheduler_t out2Sch_o,

    inout [DATA_BUS_WIDTH_BITS-1:0]    dataBus,
    inout [ADDRESS_BUS_WIDTH_BITS-1:0] addrBus
);

    // =============================
    // Types
    // =============================
    typedef struct packed {
        logic req_ld;
        logic ld_counter;
        logic inc_counter;
        logic ld_writeBuf;
        logic clr_start_write_bit;
        logic req_bus;
        logic busy;
        logic interrupt;
    } fsm_outs_t;

    typedef struct packed {
        uint32_t srcAddr;
        uint32_t destAddr;
        uint32_t numBytes;
        logic    startWrite;
    } dma_control_regs_t;

    // =============================
    // Registers / Signals
    // =============================
    dma_control_regs_t dma_Regs;

    dma_fsm_states_e fsmState;
    logic [$clog2(DMA_FSM_NUM_STATES) -1:0] fsmState_bits;
    assign fsmState = fsmState_bits;

    fsm_outs_t fsmOuts;

    logic commiting;
    logic disk_ld_Buffer_V;
    byte_t disk_ld_Buffer[PAGE_SIZE];
    wire [8*PAGE_SIZE-1:0] disk_ld_Buffer_flat;

    assign disk_ld_Buffer_flat = {<<8{disk_ld_Buffer}};

    uint32_t counter;

    byte_t writeBuf[CACHE_LINES_SIZE_B];
    p_address_t writeBuf_addr;
    logic writeBuf_V;

    logic writeComplete;

    // =============================
    // Address decode
    // =============================
    logic write2_srcAddr_req;
    logic write2_destAddr_req;
    logic write2_numBytes_req;
    logic write2_startWrite_req;

    assign write2_srcAddr_req = inFromDTE_i.coreValOnBus && (addrBus == DMA_WRITE_SRC_ADDRESS);
    ;
    assign write2_destAddr_req = inFromDTE_i.coreValOnBus && (addrBus == DMA_WRITE_DEST_ADDRESS);
    assign write2_numBytes_req   = inFromDTE_i.coreValOnBus && (addrBus == DMA_WRITE_NUM_BYTES_ADDRESS);
    assign write2_startWrite_req = inFromDTE_i.coreValOnBus && (addrBus == DMA_WRITE_START_TRANSFER_ADDRESS);

    assign writeComplete = (counter >= dma_Regs.numBytes);

    // =============================
    // FSM
    // =============================
    DMA_FSM dma_fsm_unit (
        .clk(clk),
        .rst(rst),

        .start_write_i(dma_Regs.startWrite),
        .ld_buf_data_V_i(disk_ld_Buffer_V),
        .write_Complete_i(writeComplete),
        .writeBuf_V_i(writeBuf_V),

        .S_0(fsmState_bits[0]),
        .S_1(fsmState_bits[1]),
        .S_2(fsmState_bits[2]),

        .req_ld_o(fsmOuts.req_ld),
        .ld_counter_o(fsmOuts.ld_counter),
        .inc_counter_o(fsmOuts.inc_counter),
        .ld_writeBuf_o(fsmOuts.ld_writeBuf),
        .clr_start_write_bit_o(fsmOuts.clr_start_write_bit),
        .req_bus_o(fsmOuts.req_bus),
        .busy_o(fsmOuts.busy),
        .interrupt_o(fsmOuts.interrupt)
    );

    // =============================
    // Disk Wrapper
    // =============================
    DiskWrapper diskWrapper_Unit (
        .clk(clk),
        .rst(rst),
        .ld_write_buf_req(fsmOuts.req_ld),
        .ld_diskAddr(dma_Regs.srcAddr),  // ✅ FIXED
        .ld_num_bytes(dma_Regs.numBytes),
        .disk_ld_Buffer_V(disk_ld_Buffer_V),
        .disk_ld_Buffer_o(disk_ld_Buffer_flat)
    );

    // =============================
    // Control Registers
    // =============================
    always_ff @(posedge clk) begin
        if (!rst) begin
            dma_Regs <= '{default: '0};
        end else if (inFromDTE_i.coreValOnBus && !fsmOuts.busy) begin
            if (write2_srcAddr_req) dma_Regs.srcAddr <= dataBus;
            if (write2_destAddr_req) dma_Regs.destAddr <= dataBus;
            if (write2_numBytes_req) dma_Regs.numBytes <= dataBus;
            if (write2_startWrite_req) dma_Regs.startWrite <= dataBus[0];
        end else if (fsmOuts.clr_start_write_bit) begin
            dma_Regs.startWrite <= 0;
        end
    end

    // =============================
    // Counter
    // =============================
    always_ff @(posedge clk) begin
        if (!rst) begin
            counter <= 0;
        end else begin
            if (fsmOuts.ld_counter) counter <= 0;
            else if (fsmOuts.inc_counter) counter <= counter + CACHE_LINES_SIZE_B;
        end
    end

    // =============================
    // Write Buffer
    // =============================
    always_ff @(posedge clk) begin
        if (!rst) begin
            writeBuf_V <= 0;
            writeBuf_addr <= 0;
            writeBuf <= '{default: '0};
        end else if (fsmOuts.ld_writeBuf) begin
            for (int i = 0; i < CACHE_LINES_SIZE_B; i++) begin
                if ((counter + i) < dma_Regs.numBytes) writeBuf[i] <= disk_ld_Buffer[counter+i];
                else writeBuf[i] <= '0;
            end
            writeBuf_V <= 1;
            writeBuf_addr <= dma_Regs.destAddr + counter;
        end else if (inFromDTE_i.writeComplete) begin
            writeBuf_V <= 0;
        end
    end

    always_ff @(posedge clk) begin
        if (!rst) commiting <= 0;
        else if (inFromDTE_i.commiting) commiting <= 1;
        else if (inFromDTE_i.writeComplete) commiting <= 0;
    end

    // =============================
    // Address Bus
    // =============================
    logic [ADDRESS_BUS_WIDTH_BITS-1:0] addrBus_drv;

    assign addrBus_drv = dma_Regs.destAddr + counter;

    assign #5 addrBus = (inFromDTE_i.permission2DriveADDRBus) ? addrBus_drv : 'z;

    // =============================
    // Data Bus
    // =============================
    logic [DATA_BUS_WIDTH_BITS-1:0] dataBus_drv;
    logic driveDataBus;

    always_comb begin
        driveDataBus = 0;
        dataBus_drv  = '0;

        for (int i = 0; i < (CACHE_LINES_SIZE_B / 4); i++) begin
            if (inFromDTE_i.permission2DriveDataBus[i]) begin
                driveDataBus = 1;
                dataBus_drv  = {writeBuf[i*4+3], writeBuf[i*4+2], writeBuf[i*4+1], writeBuf[i*4+0]};
            end
        end
    end

    assign dataBus = driveDataBus ? dataBus_drv : 'z;

    // =============================
    // Outputs
    // =============================
    assign out2Core_o.intOut = fsmOuts.interrupt;
    assign out2Sch_o.dma_req = fsmOuts.req_bus && !commiting ? DMA_WRITE_REQ : NO_REQ;
    assign out2Sch_o.writeBuf_Address = writeBuf_addr;

endmodule
