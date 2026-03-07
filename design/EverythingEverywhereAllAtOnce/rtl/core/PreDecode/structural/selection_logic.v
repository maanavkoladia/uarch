module selection_logic (
    input [63:0][7:0] queue,
    input [31:0] EIP,
    output [15:0][7:0] IRbyte
);

      /*
    genvar i;
    generate 
        for(i = 1; i < 15; i=i+1) begin
            fulladder adder1 (a[i], b[i], carryoutwire[i - 1], sum[i], carryoutwire[i]);
        end
    endgenerate 
    */

    genvar i;
    generate
        for(i = 0; i < 16; i=i+1) begin
            mux64_8 sixtyfourmux(.in(queue), .sel(EIP[5:0] + i), .out(IRbyte[i]));
        end
    endgenerate

endmodule