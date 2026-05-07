module cmp (
    input  uint64_t srA, //EAX
    input  uint64_t srB, //rm reg
    input  logic [3:0] data_size,  // bottom 3 bits used: data_size[2:0]
    output bool CF,
    output bool OF,
    output bool SF,
    output bool ZF,
    output bool AF,
    output bool PF
);

    logic [7:0] low_sr_val;

    logic [8:0] al_sum;
    logic [16:0] ax_sum;
    logic [32:0] eax_sum;
    // in the case of compare the "dr input" corresponds to either EAX, AX, AL or rm32
    //This is bc we only use cmp in cmpxchg and REP cmp 32.
    //this means we never subtract AH - AL. its either AL - BH, AL - BL or AX - BX

    //the input data_size is the source into this module for cmpxchg
    assign low_sr_val = data_size[0] ? srB[7:0] : srB[15:8];

    assign al_sum  = {1'b0, srA[7:0]}  - {1'b0, low_sr_val};
    assign ax_sum  = {1'b0, srA[15:0]} - {1'b0, srB[15:0]};
    assign eax_sum = {1'b0, srA[31:0]} - {1'b0, srB[31:0]};


    always_comb begin
        ZF = 0; SF = 0; CF = 0; OF = 0; PF = 0;

        case (data_size)
            4'b0001: begin // AL (lower 8-bit)
                ZF = (al_sum[7:0] == 8'h0);
                SF = al_sum[7];
                CF = al_sum[8];
                PF = ~^al_sum[7:0];
                OF = ((srA[7] ^ low_sr_val[7])) & (srA[7] ^ al_sum[7]);
                AF = srA[4] ^ low_sr_val[4] ^ al_sum[4];
            end
//Regarldess of the dr data size from the op code, since we are comparing against EAX it will always be AL - AL/AH
            4'b0010: begin
                ZF = (al_sum[7:0] == 8'h0);
                SF = al_sum[7];
                CF = al_sum[8];
                PF = ~^al_sum[7:0];
                OF = ((srA[7] ^ low_sr_val[7])) & (srA[7] ^ al_sum[7]);
                AF =  srA[4] ^ low_sr_val[4] ^ al_sum[4];
            end
            4'b0011: begin // AX (16-bit)
                ZF = (ax_sum[15:0] == 16'h0);
                SF = ax_sum[15];
                CF = ax_sum[16];
                PF = ~^ax_sum[7:0];
                OF = ((srA[15] ^ srB[15])) & (srA[15] ^ ax_sum[15]);
                AF = srA[4] ^ srB[4] ^ ax_sum[4];
            end
            4'b0111: begin // EAX (32-bit)
                ZF = (eax_sum[31:0] == 32'h0);
                SF = eax_sum[31];
                CF = eax_sum[32];
                PF = ~^eax_sum[7:0];
                OF = (srA[31] ^ srB[31]) & (srA[31] ^ eax_sum[31]);

                AF = srA[4] ^ srB[4] ^ eax_sum[4];
            end
            default: begin
                ZF = 0; SF = 0; CF = 0; OF = 0; PF = 0;
            end
        endcase
    end

endmodule