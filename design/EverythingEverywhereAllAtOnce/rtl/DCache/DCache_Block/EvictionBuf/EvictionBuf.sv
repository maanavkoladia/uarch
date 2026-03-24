import common_pkg::*;
import DCache_common_pkg::*;

module EvictionBuf (
    input wire clk_i,
    input wire rst_i,  //active low
    input wire clr_v_i,
    input v_cache_outputs_t vcache_outputs_i,
    output eb_outputs_t outputs_o
);

    typedef struct {
        byte_t dataLine[CACHE_LINES_SIZE_B];
        p_address_t address;
        bool valid;
    } evictionbuf_t;

    evictionbuf_t eb;

    always_ff @(posedge clk_i) begin
        if (!rst_i) eb <= '0;
        else begin
            if (vcache_outputs_i.LD_EB && !eb.valid) begin
                eb.valid <= 1;
                eb.address <= vcache_outputs_i.addrOut;
                eb.dataLine <= vcache_outputs_i.lineOut;
            end else if (clr_v_i) begin
                eb.valid <= 0;
            end
        end
    end

    assign outputs_o.valid = eb.valid;
    assign outputs_o.addr = eb.address;
    assign outputs_o.lineOut = eb.dataLine;

endmodule
