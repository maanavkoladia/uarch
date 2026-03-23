import common_pkg::*;
import DCache_common_pkg::*;

module EvictionBuf (
    input wire clk_i,
    input wire rst_i,  //active low

    input v_cache_outputs_t vcache_outputs_i,
    //just a valid bit
    output eb_outputs_t outputs_o
);
    //assumption is that if something is in the evictionbuf
    //then its dirty

    typedef struct {
        byte_t dataLine[CACHE_LINES_SIZE_B];
        p_address_t address;
        bool valid;
    } evictionbuf_t;

    evictionbuf_t eb;

    always_ff @(posedge clk) begin
        if (!rst) begin
            eb.valid   <= 0;
            eb.address <= 0;
            for (int i = 0; i < CACHE_LINES_SIZE_B; i++) begin
                eb.dataLine[i] <= 0;
            end
        end else begin
            if (vcache_outputs_i.LD_EB && !eb.valid) begin
                eb.valid <= 1;
                for (int i = 0; i < CACHE_LINES_SIZE_B; i++) begin
                    eb.dataLine[i] <= vcache_outputs_i.lineOut[i];
                end
            end
        end
    end

    assign outputs_o.valid = eb.valid;
    assign outputs_o.addr  = eb.address;
    always_comb begin
        outputs_o.lineOut[i] = eb.dataLine[i];
    end
endmodule
