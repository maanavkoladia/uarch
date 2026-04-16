import common_pkg::*;

module adc_op (
    input  uint64_t srA,
    input  uint64_t srB,
    input  logic    CF_in,
    input  logic [3:0] data_size, // 0001=AL, 0010=AH, 0011=AX, 0111=EAX

    output uint64_t dr_o,
    output uint64_t res_buf_o,
    output logic CF, PF, AF, ZF, SF, OF
);

    logic [32:0] sum;
    logic [4:0]  msb_ptr; // Pointer to the relevant sign bit (7, 15, or 31)

    assign sum = srA[31:0] + srB[31:0] + {32'd0, CF_in};
    assign dr_o = {32'd0, sum[31:0]};
    assign res_buf_o = {32'd0, sum[31:0]};
    always_comb begin
        CF = sum[32];
        SF = sum[31];
        ZF = sum[31:0] == 32'h0;
        PF = ~^sum[7:0]; // Always low 8 bits of the result segment
        AF = (srA[3:0] + srB[3:0] + {3'd0, CF_in}) > 4'hF;
        OF = (srA[31] == srB[31]) && (srA[31] != sum[31]);
    end

endmodule
