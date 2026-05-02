// =============================================================================
// DMA_Controller_structural.v
// =============================================================================
// Structural Verilog-2005 port of DMA_Controller.sv.
// All combinational and sequential logic implemented via STDCell macros.
// FSM (gen/DMA_FSM.sv) and DiskWrapper (DiskWrapper_Behav.v) are instantiated
// as-is.
//
// Struct ports flattened (see io_common_pkg / interconnect_pkg for the original
// SV bundles):
//   inFromDTE_i (dte_2_dma_controller_t)         -> dte_*
//   out2Core_o  (dma_controller_2_core_t)        -> core_*
//   out2Sch_o   (dma_controller_2_scheduler_t)   -> sch_*
// =============================================================================

module DMA_Controller (
    input  wire clk,
    input  wire rst,                                     // active low

    // ---- inFromDTE_i (dte_2_dma_controller_t) flattened ----
    // permission2DriveDataBus[MEM_BUS_SIZE/DATA_BUS_WIDTH_BITS] = 4 lanes, one per 32-bit word in the cacheline
    input  wire [`MEM_BUS_SIZE/`DATA_BUS_WIDTH_BITS - 1 : 0] dte_permission2DriveDataBus,
    input  wire                                              dte_permission2DriveADDRBus,
    input  wire                                              dte_commiting,
    input  wire                                              dte_writeComplete,
    input  wire                                              dte_coreValOnBus,

    // ---- out2Core_o (dma_controller_2_core_t) flattened ----
    output wire                                              core_intOut,

    // ---- out2Sch_o (dma_controller_2_scheduler_t) flattened ----
    output wire [`NUM_REQS - 1 : 0]                          sch_dma_req,
    output wire [14:0]                                       sch_writeBuf_Address,  // p_address_t = $clog2(PHY_MEM_SIZE) = 15 bits

    inout       [`DATA_BUS_WIDTH_BITS    - 1 : 0]            dataBus,
    inout       [`ADDRESS_BUS_WIDTH_BITS - 1 : 0]            addrBus
);

    // ============================================================
    // io_common_pkg memory-mapped register addresses
    // (32-bit form so the addrBus comparison matches the SV semantics
    //  of widening p_address_t with zero-extension)
    // ============================================================
    localparam [31:0] DMA_WRITE_SRC_ADDRESS_C            = 32'h00000000;
    localparam [31:0] DMA_WRITE_DEST_ADDRESS_C           = 32'h00000010;
    localparam [31:0] DMA_WRITE_NUM_BYTES_ADDRESS_C      = 32'h00000020;
    localparam [31:0] DMA_WRITE_START_TRANSFER_ADDRESS_C = 32'h00000030;

    // ============================================================
    // dma_control_regs_t (flattened)
    // ============================================================
    wire [31:0] srcAddr;
    wire [31:0] destAddr;
    wire [31:0] numBytes;
    wire        startWrite;

    // ============================================================
    // fsm_outs_t (flattened) + state bits
    // ============================================================
    wire fsm_S_0, fsm_S_1, fsm_S_2;
    wire req_ld;
    wire ld_counter;
    wire inc_counter;
    wire ld_writeBuf;
    wire clr_start_write_bit;
    wire req_bus;
    wire busy;
    wire interrupt;

    // ============================================================
    // DiskWrapper output buffer (kept flat: 4096 bytes = 32768 bits)
    // ============================================================
    wire                          disk_ld_Buffer_V;
    wire [8*`PAGE_SIZE - 1 : 0]   disk_ld_Buffer_flat;

    // ============================================================
    // Datapath state
    // ============================================================
    wire [31:0]                              counter;
    wire [`CACHE_LINES_SIZE_BITS - 1 : 0]    writeBuf;        // 128-bit cacheline
    wire                                     writeBuf_V;
    wire [14:0]                              writeBuf_addr;
    wire                                     commiting;
    wire                                     writeComplete;   // (counter >= numBytes)

    // ============================================================
    // Address decode (32-bit equality on addrBus)
    // ============================================================
    wire match_src;
    wire match_dest;
    wire match_numBytes;
    wire match_startWrite;
    `CMP_N(u_match_src,        32, match_src,        addrBus, DMA_WRITE_SRC_ADDRESS_C)
    `CMP_N(u_match_dest,       32, match_dest,       addrBus, DMA_WRITE_DEST_ADDRESS_C)
    `CMP_N(u_match_numBytes,   32, match_numBytes,   addrBus, DMA_WRITE_NUM_BYTES_ADDRESS_C)
    `CMP_N(u_match_startWrite, 32, match_startWrite, addrBus, DMA_WRITE_START_TRANSFER_ADDRESS_C)

    // Updates only when (coreValOnBus & ~busy)
    wire busy_inv;
    `INV_N(u_busy_inv, 1, busy, busy_inv)
    wire coreValOnBus_and_notBusy;
    `AND_2(u_cval_nbusy, 1, coreValOnBus_and_notBusy, dte_coreValOnBus, busy_inv)

    wire we_srcAddr;
    wire we_destAddr;
    wire we_numBytes;
    wire set_we_startWrite;
    `AND_2(u_we_src, 1, we_srcAddr,        coreValOnBus_and_notBusy, match_src)
    `AND_2(u_we_dst, 1, we_destAddr,       coreValOnBus_and_notBusy, match_dest)
    `AND_2(u_we_nb,  1, we_numBytes,       coreValOnBus_and_notBusy, match_numBytes)
    `AND_2(u_we_sw,  1, set_we_startWrite, coreValOnBus_and_notBusy, match_startWrite)

    // ============================================================
    // Control registers: srcAddr, destAddr, numBytes
    //   D = dataBus, WE = matched-decode AND coreValOnBus AND ~busy
    // ============================================================
    `REG_RST_WE(u_src_reg, 32, clk, rst, we_srcAddr,  dataBus, srcAddr)
    `REG_RST_WE(u_dst_reg, 32, clk, rst, we_destAddr, dataBus, destAddr)
    `REG_RST_WE(u_nb_reg,  32, clk, rst, we_numBytes, dataBus, numBytes)

    // ============================================================
    // startWrite register:
    //   set:   D <- dataBus[0]   when (coreValOnBus & ~busy & match_startWrite)
    //   clear: D <- 0            when clr_start_write_bit
    //   set has priority over clear (matches SV "else if" order)
    //
    //   D = dataBus[0] AND set_we   (set->dataBus[0]; clear-only->0)
    //   WE = set_we OR clear_we
    // ============================================================
    wire we_startWrite;
    wire d_startWrite;
    `OR_2 (u_or_we_sw,  1, we_startWrite, set_we_startWrite, clr_start_write_bit)
    `AND_2(u_and_d_sw,  1, d_startWrite,  dataBus[0],        set_we_startWrite)
    `REG_RST_WE(u_sw_reg, 1, clk, rst, we_startWrite, d_startWrite, startWrite)

    // ============================================================
    // writeComplete = (counter >= numBytes)
    //   counter + ~numBytes + 1   ==   counter - numBytes (unsigned)
    //   carry-out = 1  iff  counter >= numBytes
    // ============================================================
    wire [31:0] numBytes_inv;
    `INV_N(u_inv_nb, 32, numBytes, numBytes_inv)
    wire [31:0] wc_sub_unused;
    `ADD_N(u_wc_add, 32, wc_sub_unused, writeComplete, counter, numBytes_inv, 1'b1)

    // ============================================================
    // FSM (already structural)
    // ============================================================
    DMA_FSM dma_fsm_unit (
        .clk             (clk),
        .rst             (rst),
        .start_write_i   (startWrite),
        .ld_buf_data_V_i (disk_ld_Buffer_V),
        .write_Complete_i(writeComplete),
        .writeBuf_V_i    (writeBuf_V),
        .S_0             (fsm_S_0),
        .S_1             (fsm_S_1),
        .S_2             (fsm_S_2),
        .req_ld_o             (req_ld),
        .ld_counter_o         (ld_counter),
        .inc_counter_o        (inc_counter),
        .ld_writeBuf_o        (ld_writeBuf),
        .clr_start_write_bit_o(clr_start_write_bit),
        .req_bus_o            (req_bus),
        .busy_o               (busy),
        .interrupt_o          (interrupt)
    );

    // ============================================================
    // DiskWrapper (kept behavioral - separate file)
    // ============================================================
    DiskWrapper diskWrapper_Unit (
        .clk             (clk),
        .rst             (rst),
        .ld_write_buf_req(req_ld),
        .ld_diskAddr     (srcAddr),
        .ld_num_bytes    (numBytes),
        .disk_ld_Buffer_V(disk_ld_Buffer_V),
        .disk_ld_Buffer_o(disk_ld_Buffer_flat)
    );

    // ============================================================
    // Counter:
    //   ld_counter   : counter <= 0
    //   inc_counter  : counter <= counter + CACHE_LINES_SIZE_B (16)
    //   ld_counter has priority over inc_counter
    //
    //   D  = ld_counter ? 0 : counter+16   -> MUX_2 with sel=ld_counter
    //   WE = ld_counter | inc_counter
    // ============================================================
    wire [31:0] counter_inc;
    wire        counter_inc_cout;
    // counter increments by CACHE_LINES_SIZE_B (=16) bytes per write
    `ADD_N(u_counter_add, 32, counter_inc, counter_inc_cout, counter, 32'd16, 1'b0)

    wire [31:0] counter_d;
    `MUX_2(u_counter_d_mux, 32, counter_d, counter_inc, 32'd0, ld_counter)

    wire we_counter;
    `OR_2(u_or_we_cnt, 1, we_counter, ld_counter, inc_counter)

    `REG_RST_WE(u_counter_reg, 32, clk, rst, we_counter, counter_d, counter)

    // ============================================================
    // Disk buffer chunk select (256:1 mux of 128-bit chunks)
    //
    // counter only ever increments by CACHE_LINES_SIZE_B (16), so
    // counter[3:0] == 0 always.  The 16 bytes for one writeBuf load
    // therefore live in a single aligned 128-bit chunk indexed by
    // counter[11:4].  Implement as 4 layers of MUX_64 (each 64:1,
    // 128-bit wide), reduced by a final MUX_4.
    // ============================================================
    wire [7:0] chunk_sel;
    assign chunk_sel = counter[11:4];

    wire [127:0] chunkLevel1_0;
    wire [127:0] chunkLevel1_1;
    wire [127:0] chunkLevel1_2;
    wire [127:0] chunkLevel1_3;
    wire [127:0] selected_chunk;

    `MUX_64(u_lvl1_0, 128, chunkLevel1_0,
        disk_ld_Buffer_flat[(  0)*128 +: 128], disk_ld_Buffer_flat[(  1)*128 +: 128],
        disk_ld_Buffer_flat[(  2)*128 +: 128], disk_ld_Buffer_flat[(  3)*128 +: 128],
        disk_ld_Buffer_flat[(  4)*128 +: 128], disk_ld_Buffer_flat[(  5)*128 +: 128],
        disk_ld_Buffer_flat[(  6)*128 +: 128], disk_ld_Buffer_flat[(  7)*128 +: 128],
        disk_ld_Buffer_flat[(  8)*128 +: 128], disk_ld_Buffer_flat[(  9)*128 +: 128],
        disk_ld_Buffer_flat[( 10)*128 +: 128], disk_ld_Buffer_flat[( 11)*128 +: 128],
        disk_ld_Buffer_flat[( 12)*128 +: 128], disk_ld_Buffer_flat[( 13)*128 +: 128],
        disk_ld_Buffer_flat[( 14)*128 +: 128], disk_ld_Buffer_flat[( 15)*128 +: 128],
        disk_ld_Buffer_flat[( 16)*128 +: 128], disk_ld_Buffer_flat[( 17)*128 +: 128],
        disk_ld_Buffer_flat[( 18)*128 +: 128], disk_ld_Buffer_flat[( 19)*128 +: 128],
        disk_ld_Buffer_flat[( 20)*128 +: 128], disk_ld_Buffer_flat[( 21)*128 +: 128],
        disk_ld_Buffer_flat[( 22)*128 +: 128], disk_ld_Buffer_flat[( 23)*128 +: 128],
        disk_ld_Buffer_flat[( 24)*128 +: 128], disk_ld_Buffer_flat[( 25)*128 +: 128],
        disk_ld_Buffer_flat[( 26)*128 +: 128], disk_ld_Buffer_flat[( 27)*128 +: 128],
        disk_ld_Buffer_flat[( 28)*128 +: 128], disk_ld_Buffer_flat[( 29)*128 +: 128],
        disk_ld_Buffer_flat[( 30)*128 +: 128], disk_ld_Buffer_flat[( 31)*128 +: 128],
        disk_ld_Buffer_flat[( 32)*128 +: 128], disk_ld_Buffer_flat[( 33)*128 +: 128],
        disk_ld_Buffer_flat[( 34)*128 +: 128], disk_ld_Buffer_flat[( 35)*128 +: 128],
        disk_ld_Buffer_flat[( 36)*128 +: 128], disk_ld_Buffer_flat[( 37)*128 +: 128],
        disk_ld_Buffer_flat[( 38)*128 +: 128], disk_ld_Buffer_flat[( 39)*128 +: 128],
        disk_ld_Buffer_flat[( 40)*128 +: 128], disk_ld_Buffer_flat[( 41)*128 +: 128],
        disk_ld_Buffer_flat[( 42)*128 +: 128], disk_ld_Buffer_flat[( 43)*128 +: 128],
        disk_ld_Buffer_flat[( 44)*128 +: 128], disk_ld_Buffer_flat[( 45)*128 +: 128],
        disk_ld_Buffer_flat[( 46)*128 +: 128], disk_ld_Buffer_flat[( 47)*128 +: 128],
        disk_ld_Buffer_flat[( 48)*128 +: 128], disk_ld_Buffer_flat[( 49)*128 +: 128],
        disk_ld_Buffer_flat[( 50)*128 +: 128], disk_ld_Buffer_flat[( 51)*128 +: 128],
        disk_ld_Buffer_flat[( 52)*128 +: 128], disk_ld_Buffer_flat[( 53)*128 +: 128],
        disk_ld_Buffer_flat[( 54)*128 +: 128], disk_ld_Buffer_flat[( 55)*128 +: 128],
        disk_ld_Buffer_flat[( 56)*128 +: 128], disk_ld_Buffer_flat[( 57)*128 +: 128],
        disk_ld_Buffer_flat[( 58)*128 +: 128], disk_ld_Buffer_flat[( 59)*128 +: 128],
        disk_ld_Buffer_flat[( 60)*128 +: 128], disk_ld_Buffer_flat[( 61)*128 +: 128],
        disk_ld_Buffer_flat[( 62)*128 +: 128], disk_ld_Buffer_flat[( 63)*128 +: 128],
        chunk_sel[5:0])

    `MUX_64(u_lvl1_1, 128, chunkLevel1_1,
        disk_ld_Buffer_flat[( 64)*128 +: 128], disk_ld_Buffer_flat[( 65)*128 +: 128],
        disk_ld_Buffer_flat[( 66)*128 +: 128], disk_ld_Buffer_flat[( 67)*128 +: 128],
        disk_ld_Buffer_flat[( 68)*128 +: 128], disk_ld_Buffer_flat[( 69)*128 +: 128],
        disk_ld_Buffer_flat[( 70)*128 +: 128], disk_ld_Buffer_flat[( 71)*128 +: 128],
        disk_ld_Buffer_flat[( 72)*128 +: 128], disk_ld_Buffer_flat[( 73)*128 +: 128],
        disk_ld_Buffer_flat[( 74)*128 +: 128], disk_ld_Buffer_flat[( 75)*128 +: 128],
        disk_ld_Buffer_flat[( 76)*128 +: 128], disk_ld_Buffer_flat[( 77)*128 +: 128],
        disk_ld_Buffer_flat[( 78)*128 +: 128], disk_ld_Buffer_flat[( 79)*128 +: 128],
        disk_ld_Buffer_flat[( 80)*128 +: 128], disk_ld_Buffer_flat[( 81)*128 +: 128],
        disk_ld_Buffer_flat[( 82)*128 +: 128], disk_ld_Buffer_flat[( 83)*128 +: 128],
        disk_ld_Buffer_flat[( 84)*128 +: 128], disk_ld_Buffer_flat[( 85)*128 +: 128],
        disk_ld_Buffer_flat[( 86)*128 +: 128], disk_ld_Buffer_flat[( 87)*128 +: 128],
        disk_ld_Buffer_flat[( 88)*128 +: 128], disk_ld_Buffer_flat[( 89)*128 +: 128],
        disk_ld_Buffer_flat[( 90)*128 +: 128], disk_ld_Buffer_flat[( 91)*128 +: 128],
        disk_ld_Buffer_flat[( 92)*128 +: 128], disk_ld_Buffer_flat[( 93)*128 +: 128],
        disk_ld_Buffer_flat[( 94)*128 +: 128], disk_ld_Buffer_flat[( 95)*128 +: 128],
        disk_ld_Buffer_flat[( 96)*128 +: 128], disk_ld_Buffer_flat[( 97)*128 +: 128],
        disk_ld_Buffer_flat[( 98)*128 +: 128], disk_ld_Buffer_flat[( 99)*128 +: 128],
        disk_ld_Buffer_flat[(100)*128 +: 128], disk_ld_Buffer_flat[(101)*128 +: 128],
        disk_ld_Buffer_flat[(102)*128 +: 128], disk_ld_Buffer_flat[(103)*128 +: 128],
        disk_ld_Buffer_flat[(104)*128 +: 128], disk_ld_Buffer_flat[(105)*128 +: 128],
        disk_ld_Buffer_flat[(106)*128 +: 128], disk_ld_Buffer_flat[(107)*128 +: 128],
        disk_ld_Buffer_flat[(108)*128 +: 128], disk_ld_Buffer_flat[(109)*128 +: 128],
        disk_ld_Buffer_flat[(110)*128 +: 128], disk_ld_Buffer_flat[(111)*128 +: 128],
        disk_ld_Buffer_flat[(112)*128 +: 128], disk_ld_Buffer_flat[(113)*128 +: 128],
        disk_ld_Buffer_flat[(114)*128 +: 128], disk_ld_Buffer_flat[(115)*128 +: 128],
        disk_ld_Buffer_flat[(116)*128 +: 128], disk_ld_Buffer_flat[(117)*128 +: 128],
        disk_ld_Buffer_flat[(118)*128 +: 128], disk_ld_Buffer_flat[(119)*128 +: 128],
        disk_ld_Buffer_flat[(120)*128 +: 128], disk_ld_Buffer_flat[(121)*128 +: 128],
        disk_ld_Buffer_flat[(122)*128 +: 128], disk_ld_Buffer_flat[(123)*128 +: 128],
        disk_ld_Buffer_flat[(124)*128 +: 128], disk_ld_Buffer_flat[(125)*128 +: 128],
        disk_ld_Buffer_flat[(126)*128 +: 128], disk_ld_Buffer_flat[(127)*128 +: 128],
        chunk_sel[5:0])

    `MUX_64(u_lvl1_2, 128, chunkLevel1_2,
        disk_ld_Buffer_flat[(128)*128 +: 128], disk_ld_Buffer_flat[(129)*128 +: 128],
        disk_ld_Buffer_flat[(130)*128 +: 128], disk_ld_Buffer_flat[(131)*128 +: 128],
        disk_ld_Buffer_flat[(132)*128 +: 128], disk_ld_Buffer_flat[(133)*128 +: 128],
        disk_ld_Buffer_flat[(134)*128 +: 128], disk_ld_Buffer_flat[(135)*128 +: 128],
        disk_ld_Buffer_flat[(136)*128 +: 128], disk_ld_Buffer_flat[(137)*128 +: 128],
        disk_ld_Buffer_flat[(138)*128 +: 128], disk_ld_Buffer_flat[(139)*128 +: 128],
        disk_ld_Buffer_flat[(140)*128 +: 128], disk_ld_Buffer_flat[(141)*128 +: 128],
        disk_ld_Buffer_flat[(142)*128 +: 128], disk_ld_Buffer_flat[(143)*128 +: 128],
        disk_ld_Buffer_flat[(144)*128 +: 128], disk_ld_Buffer_flat[(145)*128 +: 128],
        disk_ld_Buffer_flat[(146)*128 +: 128], disk_ld_Buffer_flat[(147)*128 +: 128],
        disk_ld_Buffer_flat[(148)*128 +: 128], disk_ld_Buffer_flat[(149)*128 +: 128],
        disk_ld_Buffer_flat[(150)*128 +: 128], disk_ld_Buffer_flat[(151)*128 +: 128],
        disk_ld_Buffer_flat[(152)*128 +: 128], disk_ld_Buffer_flat[(153)*128 +: 128],
        disk_ld_Buffer_flat[(154)*128 +: 128], disk_ld_Buffer_flat[(155)*128 +: 128],
        disk_ld_Buffer_flat[(156)*128 +: 128], disk_ld_Buffer_flat[(157)*128 +: 128],
        disk_ld_Buffer_flat[(158)*128 +: 128], disk_ld_Buffer_flat[(159)*128 +: 128],
        disk_ld_Buffer_flat[(160)*128 +: 128], disk_ld_Buffer_flat[(161)*128 +: 128],
        disk_ld_Buffer_flat[(162)*128 +: 128], disk_ld_Buffer_flat[(163)*128 +: 128],
        disk_ld_Buffer_flat[(164)*128 +: 128], disk_ld_Buffer_flat[(165)*128 +: 128],
        disk_ld_Buffer_flat[(166)*128 +: 128], disk_ld_Buffer_flat[(167)*128 +: 128],
        disk_ld_Buffer_flat[(168)*128 +: 128], disk_ld_Buffer_flat[(169)*128 +: 128],
        disk_ld_Buffer_flat[(170)*128 +: 128], disk_ld_Buffer_flat[(171)*128 +: 128],
        disk_ld_Buffer_flat[(172)*128 +: 128], disk_ld_Buffer_flat[(173)*128 +: 128],
        disk_ld_Buffer_flat[(174)*128 +: 128], disk_ld_Buffer_flat[(175)*128 +: 128],
        disk_ld_Buffer_flat[(176)*128 +: 128], disk_ld_Buffer_flat[(177)*128 +: 128],
        disk_ld_Buffer_flat[(178)*128 +: 128], disk_ld_Buffer_flat[(179)*128 +: 128],
        disk_ld_Buffer_flat[(180)*128 +: 128], disk_ld_Buffer_flat[(181)*128 +: 128],
        disk_ld_Buffer_flat[(182)*128 +: 128], disk_ld_Buffer_flat[(183)*128 +: 128],
        disk_ld_Buffer_flat[(184)*128 +: 128], disk_ld_Buffer_flat[(185)*128 +: 128],
        disk_ld_Buffer_flat[(186)*128 +: 128], disk_ld_Buffer_flat[(187)*128 +: 128],
        disk_ld_Buffer_flat[(188)*128 +: 128], disk_ld_Buffer_flat[(189)*128 +: 128],
        disk_ld_Buffer_flat[(190)*128 +: 128], disk_ld_Buffer_flat[(191)*128 +: 128],
        chunk_sel[5:0])

    `MUX_64(u_lvl1_3, 128, chunkLevel1_3,
        disk_ld_Buffer_flat[(192)*128 +: 128], disk_ld_Buffer_flat[(193)*128 +: 128],
        disk_ld_Buffer_flat[(194)*128 +: 128], disk_ld_Buffer_flat[(195)*128 +: 128],
        disk_ld_Buffer_flat[(196)*128 +: 128], disk_ld_Buffer_flat[(197)*128 +: 128],
        disk_ld_Buffer_flat[(198)*128 +: 128], disk_ld_Buffer_flat[(199)*128 +: 128],
        disk_ld_Buffer_flat[(200)*128 +: 128], disk_ld_Buffer_flat[(201)*128 +: 128],
        disk_ld_Buffer_flat[(202)*128 +: 128], disk_ld_Buffer_flat[(203)*128 +: 128],
        disk_ld_Buffer_flat[(204)*128 +: 128], disk_ld_Buffer_flat[(205)*128 +: 128],
        disk_ld_Buffer_flat[(206)*128 +: 128], disk_ld_Buffer_flat[(207)*128 +: 128],
        disk_ld_Buffer_flat[(208)*128 +: 128], disk_ld_Buffer_flat[(209)*128 +: 128],
        disk_ld_Buffer_flat[(210)*128 +: 128], disk_ld_Buffer_flat[(211)*128 +: 128],
        disk_ld_Buffer_flat[(212)*128 +: 128], disk_ld_Buffer_flat[(213)*128 +: 128],
        disk_ld_Buffer_flat[(214)*128 +: 128], disk_ld_Buffer_flat[(215)*128 +: 128],
        disk_ld_Buffer_flat[(216)*128 +: 128], disk_ld_Buffer_flat[(217)*128 +: 128],
        disk_ld_Buffer_flat[(218)*128 +: 128], disk_ld_Buffer_flat[(219)*128 +: 128],
        disk_ld_Buffer_flat[(220)*128 +: 128], disk_ld_Buffer_flat[(221)*128 +: 128],
        disk_ld_Buffer_flat[(222)*128 +: 128], disk_ld_Buffer_flat[(223)*128 +: 128],
        disk_ld_Buffer_flat[(224)*128 +: 128], disk_ld_Buffer_flat[(225)*128 +: 128],
        disk_ld_Buffer_flat[(226)*128 +: 128], disk_ld_Buffer_flat[(227)*128 +: 128],
        disk_ld_Buffer_flat[(228)*128 +: 128], disk_ld_Buffer_flat[(229)*128 +: 128],
        disk_ld_Buffer_flat[(230)*128 +: 128], disk_ld_Buffer_flat[(231)*128 +: 128],
        disk_ld_Buffer_flat[(232)*128 +: 128], disk_ld_Buffer_flat[(233)*128 +: 128],
        disk_ld_Buffer_flat[(234)*128 +: 128], disk_ld_Buffer_flat[(235)*128 +: 128],
        disk_ld_Buffer_flat[(236)*128 +: 128], disk_ld_Buffer_flat[(237)*128 +: 128],
        disk_ld_Buffer_flat[(238)*128 +: 128], disk_ld_Buffer_flat[(239)*128 +: 128],
        disk_ld_Buffer_flat[(240)*128 +: 128], disk_ld_Buffer_flat[(241)*128 +: 128],
        disk_ld_Buffer_flat[(242)*128 +: 128], disk_ld_Buffer_flat[(243)*128 +: 128],
        disk_ld_Buffer_flat[(244)*128 +: 128], disk_ld_Buffer_flat[(245)*128 +: 128],
        disk_ld_Buffer_flat[(246)*128 +: 128], disk_ld_Buffer_flat[(247)*128 +: 128],
        disk_ld_Buffer_flat[(248)*128 +: 128], disk_ld_Buffer_flat[(249)*128 +: 128],
        disk_ld_Buffer_flat[(250)*128 +: 128], disk_ld_Buffer_flat[(251)*128 +: 128],
        disk_ld_Buffer_flat[(252)*128 +: 128], disk_ld_Buffer_flat[(253)*128 +: 128],
        disk_ld_Buffer_flat[(254)*128 +: 128], disk_ld_Buffer_flat[(255)*128 +: 128],
        chunk_sel[5:0])

    `MUX_4(u_lvl2, 128, selected_chunk,
        chunkLevel1_0, chunkLevel1_1, chunkLevel1_2, chunkLevel1_3,
        chunk_sel[7:6])

    // ============================================================
    // Per-byte valid mask:  valid_mask[i] = (counter + i) < numBytes
    //
    //   diff = numBytes - counter   (computed as numBytes + ~counter + 1)
    //   large_diff = (diff[31:4] != 0)        -> all 16 bytes valid
    //   else, mask is a 16-bit thermometer of diff[3:0]
    //
    // Note: the FSM only asserts ld_writeBuf when counter < numBytes,
    //       so diff is always positive when this mask is consumed.
    // ============================================================
    wire [31:0] counter_inv;
    `INV_N(u_inv_counter, 32, counter, counter_inv)

    wire [31:0] diff;
    wire        diff_cout_unused;
    `ADD_N(u_diff_calc, 32, diff, diff_cout_unused, numBytes, counter_inv, 1'b1)

    wire upper_zero;
    `CMP_N(u_diff_upper_zero, 28, upper_zero, diff[31:4], 28'd0)

    wire large_diff;
    `INV_N(u_large_diff, 1, upper_zero, large_diff)

    // 4->16 one-hot decode of diff[3:0]
    wire [15:0] one_hot_diff;
    `DECODER_N(u_dec_diff, 4, diff[3:0], one_hot_diff)

    // Thermometer:  tcoded[i] = OR(one_hot_diff[i+1 .. 15])
    //               tcoded[15] = 0 (no bit position above 15)
    wire [15:0] tcoded;
    assign tcoded[15] = 1'b0;

    genvar ti;
    generate
        for (ti = 0; ti < 15; ti = ti + 1) begin : g_thermo
            `OR_2(u_t, 1, tcoded[ti], tcoded[ti+1], one_hot_diff[ti+1])
        end
    endgenerate

    // valid_mask[i] = tcoded[i] | large_diff
    wire [15:0] valid_mask;
    genvar vi;
    generate
        for (vi = 0; vi < 16; vi = vi + 1) begin : g_vmask
            `OR_2(u_vm, 1, valid_mask[vi], tcoded[vi], large_diff)
        end
    endgenerate

    // ============================================================
    // writeBuf[0..15] (16 byte registers):
    //   when ld_writeBuf:
    //     D[i] = valid_mask[i] ? selected_chunk[byte i] : 0
    //   else:
    //     hold
    //
    //   D[i] = selected_chunk[byte i] AND replicate(valid_mask[i], 8)
    //   WE   = ld_writeBuf
    // ============================================================
    genvar bi;
    generate
        for (bi = 0; bi < `CACHE_LINES_SIZE_B; bi = bi + 1) begin : g_wb_byte
            wire [7:0] cond_rep;
            assign cond_rep = {8{valid_mask[bi]}};

            wire [7:0] din_byte;
            `AND_2(u_byte_d, 8, din_byte, selected_chunk[bi*8 +: 8], cond_rep)

            `REG_RST_WE(u_byte_reg, 8, clk, rst, ld_writeBuf, din_byte, writeBuf[bi*8 +: 8])
        end
    endgenerate

    // ============================================================
    // writeBuf_V:
    //   ld_writeBuf       -> 1
    //   dte_writeComplete -> 0
    //   ld_writeBuf has priority (set wins)
    //
    //   D  = ld_writeBuf
    //   WE = ld_writeBuf | dte_writeComplete
    // ============================================================
    wire we_writeBuf_V;
    `OR_2(u_or_we_wbv, 1, we_writeBuf_V, ld_writeBuf, dte_writeComplete)
    `REG_RST_WE(u_wbv_reg, 1, clk, rst, we_writeBuf_V, ld_writeBuf, writeBuf_V)

    // ============================================================
    // Address bus driver:
    //   addrBus_drv = destAddr + counter  (unsigned 32-bit add)
    //   tristate driven by dte_permission2DriveADDRBus
    //
    //   This adder also feeds writeBuf_addr (the low 15 bits).
    // ============================================================
    wire [31:0] addrBus_drv;
    wire        addr_add_cout_unused;
    `ADD_N(u_addr_add, 32, addrBus_drv, addr_add_cout_unused, destAddr, counter, 1'b0)

    wire perm_addr_inv;
    `INV_N(u_inv_perm_addr, 1, dte_permission2DriveADDRBus, perm_addr_inv)
    `BUS_TRISTATE(u_addr_drv, `ADDRESS_BUS_WIDTH_BITS, perm_addr_inv, addrBus_drv, addrBus)

    // ============================================================
    // writeBuf_addr register:
    //   on ld_writeBuf : addrBus_drv[14:0]  (= destAddr+counter, p_address_t)
    // ============================================================
    `REG_RST_WE(u_wba_reg, 15, clk, rst, ld_writeBuf, addrBus_drv[14:0], writeBuf_addr)

    // ============================================================
    // commiting register:
    //   dte_commiting     -> 1   (set has priority)
    //   dte_writeComplete -> 0
    // ============================================================
    wire we_commiting;
    `OR_2(u_or_we_cm, 1, we_commiting, dte_commiting, dte_writeComplete)
    `REG_RST_WE(u_cm_reg, 1, clk, rst, we_commiting, dte_commiting, commiting)

    // ============================================================
    // Data bus driver (one-hot 4:1 mux of writeBuf word chunks)
    //
    //   chunk_w : writeBuf[w*32 +: 32]  (4 words per cacheline)
    //   masked_w = chunk_w AND {32{permission2DriveDataBus[w]}}
    //   dataBus_drv = masked_0 | masked_1 | masked_2 | masked_3
    //   driveDataBus = OR-reduce(permission2DriveDataBus)
    //
    // Inputs are guaranteed one-hot by the DTE.
    // ============================================================
    wire [31:0] perm_rep_0;
    wire [31:0] perm_rep_1;
    wire [31:0] perm_rep_2;
    wire [31:0] perm_rep_3;
    assign perm_rep_0 = {`DATA_BUS_WIDTH_BITS{dte_permission2DriveDataBus[0]}};
    assign perm_rep_1 = {`DATA_BUS_WIDTH_BITS{dte_permission2DriveDataBus[1]}};
    assign perm_rep_2 = {`DATA_BUS_WIDTH_BITS{dte_permission2DriveDataBus[2]}};
    assign perm_rep_3 = {`DATA_BUS_WIDTH_BITS{dte_permission2DriveDataBus[3]}};

    wire [31:0] masked_word_0;
    wire [31:0] masked_word_1;
    wire [31:0] masked_word_2;
    wire [31:0] masked_word_3;
    `AND_2(u_msk_w0, 32, masked_word_0, writeBuf[ 0*32 +: 32], perm_rep_0)
    `AND_2(u_msk_w1, 32, masked_word_1, writeBuf[ 1*32 +: 32], perm_rep_1)
    `AND_2(u_msk_w2, 32, masked_word_2, writeBuf[ 2*32 +: 32], perm_rep_2)
    `AND_2(u_msk_w3, 32, masked_word_3, writeBuf[ 3*32 +: 32], perm_rep_3)

    wire [31:0] dataBus_drv;
    `OR_4(u_dat_or, 32, dataBus_drv,
          masked_word_0, masked_word_1, masked_word_2, masked_word_3)

    wire driveDataBus;
    `OR_4(u_drv_or, 1, driveDataBus,
          dte_permission2DriveDataBus[0], dte_permission2DriveDataBus[1],
          dte_permission2DriveDataBus[2], dte_permission2DriveDataBus[3])

    wire drive_data_inv;
    `INV_N(u_inv_drv_data, 1, driveDataBus, drive_data_inv)
    `BUS_TRISTATE(u_dat_drv, `DATA_BUS_WIDTH_BITS, drive_data_inv, dataBus_drv, dataBus)

    // ============================================================
    // Output assignments
    //
    //   sch_dma_req encodes req_2_sch_t as a binary value (NUM_REQS bits wide):
    //     NO_REQ        = 0
    //     DMA_WRITE_REQ = 1
    //   so dma_req[0] = req_bus & ~commiting, upper bits = 0.
    // ============================================================
    wire commiting_inv;
    `INV_N(u_inv_cm, 1, commiting, commiting_inv)
    wire dma_req_active;
    `AND_2(u_and_dr, 1, dma_req_active, req_bus, commiting_inv)

    assign sch_dma_req[0]                   = dma_req_active;
    assign sch_dma_req[`NUM_REQS - 1 : 1]   = {(`NUM_REQS - 1){1'b0}};
    assign sch_writeBuf_Address             = writeBuf_addr;
    assign core_intOut                      = interrupt;

endmodule
