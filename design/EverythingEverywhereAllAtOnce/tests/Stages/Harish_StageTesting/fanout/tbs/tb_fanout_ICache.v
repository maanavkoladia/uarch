module tb_fanout_ICache ();
    
    // Wires for ICache inputs
wire         clk;
wire         rst;

wire         icache_en;
wire [14:0]  p_addr;
wire [31:0]  v_addr_i;
wire [2:0]   num_valid_IDM_slots;

wire         Mem_Valid;
wire         driveAddrBus;

// Wires for ICache outputs
wire         out_hit;
wire [127:0] out_instruction_line;
wire [3:0]   out_req;

// Shared buses
wire [31:0]  dataBus;
wire [31:0]  addrBus;


// ICache instantiation
ICache icache_inst (
    .clk(clk),
    .rst(rst),

    .icache_en(icache_en),
    .p_addr(p_addr),
    .v_addr_i(v_addr_i),
    .num_valid_IDM_slots(num_valid_IDM_slots),

    .out_hit(out_hit),
    .out_instruction_line(out_instruction_line),

    .Mem_Valid(Mem_Valid),
    .driveAddrBus(driveAddrBus),

    .out_req(out_req),

    .dataBus(dataBus),
    .addrBus(addrBus)
);


endmodule



