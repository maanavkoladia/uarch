module req_gen_logic(
    input clk,
    input rst,
    input bool valid,
    input bool flush,
    input bool LD_OP,
    input bool XCL,
    input bool dep_stall,
    input bool exp_stall,
    input bool MIO,

    input p_address_t ld_addr0,
    input p_address_t ld_addr1,
    input p_address_t ld_addrMIO,

    input bool req_served_0,
    input bool req_served_1,
    input bool req_served_mio,

    input bool mem_stage_we_valid_unit_o,
    input bool mem_stage_next_valid_o,

    output bool ld_addr_0_V,
    output bool ld_addr_1_V,
    output bool ld_addr_mio_V,

    output p_address_t ld_addr_mio,
    output p_address_t ld_addr_0,
    output p_address_t ld_addr_1,
    output bool arb_stall

);

    //if there is a dep stall then we dont want to send any requests 


    //internal regs for tracking if a request has been latched
    bool is_served_0;
    bool is_served_1;
    bool is_served_mio;

    bool stall;
    assign stall = exp_stall || dep_stall;

    //is dc ready to move forwward with valid logic
    bool forward_valid;

    bool mio_stall;
    bool ld_0_stall;
    bool ld_1_stall;

    assign mio_stall = (~req_served_mio & ~is_served_mio & MIO & LD_OP);
    assign ld_0_stall = (~req_served_0 &  ~is_served_0 & LD_OP & ~MIO);
    assign ld_1_stall = (~req_served_1 & ~is_served_1 & LD_OP & XCL & ~MIO);

    assign arb_stall = (mio_stall | ld_0_stall | ld_1_stall) & valid;



    assign forward_valid = mem_stage_we_valid_unit_o &
                           mem_stage_next_valid_o;

    always_ff @(posedge clk) begin
        if(!rst)begin
            is_served_0 <=0;
            is_served_1 <=0;
            is_served_mio <=0;
        end
        else begin
            if(forward_valid | flush)begin
                is_served_0 <=0;
                is_served_1 <= 0;
                is_served_mio <=0;
            end
            else begin
                if(req_served_0 && valid)
                    is_served_0 <= 1;
                if(req_served_1 && valid)
                    is_served_1 <= 1;
                if(req_served_mio && valid)
                    is_served_mio <=1;
            end
        end
    end

    //pretty trivial.. keeping this file structure like this for when we convert to structural
    //load address cache aligned

    assign ld_addr_0 = ld_addr0 & 32'hFFFFFFF0;
    assign ld_addr_1 = ld_addr1 & 32'hFFFFFFF0;
    assign ld_addr_mio = ld_addrMIO & 32'hFFFFFFF0;

    assign ld_addr_1_V = ~stall & LD_OP & XCL & valid & ~MIO & ~is_served_1 & ~flush;
    assign ld_addr_0_V = ~stall & LD_OP & valid & ~MIO & ~is_served_0 & ~flush;
    assign ld_addr_mio_V = ~stall & LD_OP & valid & MIO & ~is_served_mio & ~flush;






endmodule