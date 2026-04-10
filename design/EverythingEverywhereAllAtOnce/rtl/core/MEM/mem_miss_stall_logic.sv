module mem_miss_stall_logic(
    input valid,
    input bool LD_XCL,
    input bool LD_OP,
    input MIO,
    input bool hits[NUM_DCACHE_PORTS],
    input bool hit_MIO,
    input bool hit_buf_v[NUM_DCACHE_PORTS],
    input bool hit_buf_mio_v,
    input logic[1:0] bank_num_0,
    input logic[1:0] bank_num_1,

    output miss_stall
);


    bool xcl_miss;
    bool ld_miss;
    bool mio_miss;

    assign mio_miss = MIO & ~hit_MIO & ~hit_buf_mio_v;

    always_comb begin
        ld_miss = 0;
        xcl_miss = 0;
        for(int i = 0; i < NUM_DCACHE_PORTS; i++)begin
            if(bank_num_0 == i && ~hits[i] && ~hit_buf_v[i] & LD_OP)
                ld_miss = 1;
            if(bank_num_1 == i && ~hits[i] && ~hit_buf_v[i] & LD_OP & LD_XCL)
                xcl_miss = 1;
        end
    end

    assign miss_stall = (mio_miss | ld_miss | xcl_miss) & valid;


endmodule