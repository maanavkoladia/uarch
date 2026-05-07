module tb_fanout

module ICache (
    .clk(clk_i),
    .rst(rst_i),
    .icache_en(icache_en_i),
    .p_addr(p_addr_i),
    .v_addr_i(v_addr_i_i),
    .num_valid_IDM_slots(num_valid_IDM_slots_i),
    .out_hit(out_hit_i),
    .out_instruction_line(out_instruction_line_i),
    .Mem_Valid(Mem_Valid_i),
    .driveAddrBus(driveAddrBus_i),
    .out_req(out_req_i),
    .dataBus(dataBus_i),
    .addrBus(addrBus_i)
);
endmodule
