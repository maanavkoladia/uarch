import common_pkg::*;
import DCache_common_pkg::*;

module EvictionBuf (
    input wire clk_i,
    input wire rst_i,  //active low

    input wire eb_clr_i,
    input wire set_commiting,

    input block_req_t blockReq_i,

    input v_cache_outputs_t vcache_outputs_i,

    output eb_outputs_t outputs_o
);

    typedef struct {
        byte_t dataLine[CACHE_LINES_SIZE_B];
        p_address_t address;
        bool valid;
        bool commiting;
    } evictionbuf_t;

    evictionbuf_t eb;

    bool validReq;
    bool hit;


    assign validReq = blockReq_i.oe || blockReq_i.we;
    assign hit = validReq && eb.valid && (blockReq_i.p_addr[14:4] == eb.address[14:4]);

    always_ff @(posedge clk_i) begin
        if (!rst_i) eb <= '{default: '0};
        else begin
            if (vcache_outputs_i.LD_EB && !eb.valid) begin
                eb.valid <= 1;
                eb.commiting <= 0;
                eb.address <= vcache_outputs_i.addrOut;
                eb.dataLine <= vcache_outputs_i.lineOut;
            end else if (eb_clr_i) begin
                eb.valid <= 0;
                eb.commiting <= 0;
            end else if (set_commiting) begin
                eb.commiting <= 1;
            end
        end
    end

    assign outputs_o.valid = eb.valid;
    assign outputs_o.addr = eb.address;
    assign outputs_o.lineOut = eb.dataLine;
    assign outputs_o.commiting = eb.commiting;
    assign outputs_o.reqHit = hit;

endmodule
