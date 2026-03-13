module selection_logic (
    input [63:0][7:0] queue,
    input [31:0] EIP,
    output [15:0][7:0] IRbyte
);

    wire [15:0][5:0] temp;
    assign temp[0] = EIP[5:0];
    assign temp[1] = EIP[5:0] + 6'd1;
    assign temp[2] = EIP[5:0] + 6'd2;
    assign temp[3] = EIP[5:0] + 6'd3;

    assign temp[4] = EIP[5:0] + 6'd4;
    assign temp[5] = EIP[5:0] + 6'd5;
    assign temp[6] = EIP[5:0] + 6'd6;
    assign temp[7] = EIP[5:0] + 6'd7;

    assign temp[8] = EIP[5:0] + 6'd8;
    assign temp[9] = EIP[5:0] + 6'd9;
    assign temp[10] = EIP[5:0] + 6'd10;
    assign temp[11] = EIP[5:0] + 6'd11;

    assign temp[12] = EIP[5:0] + 6'd12;
    assign temp[13] = EIP[5:0] + 6'd13;
    assign temp[14] = EIP[5:0] + 6'd14;
    assign temp[15] = EIP[5:0] + 6'd15;

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
            mux64_8 sixtyfourmux(.in(queue), .sel(temp[i]), .out(IRbyte[i]));
        end
    endgenerate

endmodule
