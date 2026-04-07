module buffer_delay_stages$ #(
    parameter integer STAGES = 4
) (
    input  wire in,
    output wire out
);

    wire [STAGES:0] chain;

    assign chain[0] = in;
    assign out = chain[STAGES];

    genvar i;
    generate
        for (i = 0; i < STAGES; i = i + 1) begin : g_BUF_STAGE
            buffer$ u_buf (
                .out(chain[i+1]),
                .in (chain[i])
            );
        end
    endgenerate

endmodule


