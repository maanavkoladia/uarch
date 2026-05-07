module rep_cmp (
    input  uint64_t srA, //EAX
    input  uint64_t srB, //rm reg
    output bool ZF
);
    assign ZF = srA[31:0] == srB[31:0];
endmodule