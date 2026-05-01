module disp_finder (
    input [3:0] sib_index,
    input sib_size,
    input [15:0][7:0] IR,
    output [3:0][7:0] disp
);
    wire [3:0] disp_index0, disp_index1, disp_index2, disp_index3;
    assign disp_index0 = sib_index + sib_size;
    assign disp_index1 = sib_index + sib_size + 4'd1;
    assign disp_index2 = sib_index + sib_size + 4'd2;
    assign disp_index3 = sib_index + sib_size + 4'd3;
    assign disp = {IR[disp_index3], IR[disp_index2], IR[disp_index1], IR[disp_index0]};
endmodule

/*
    wire [3:0] disp_index;  //byte index
    wire adder_cout;
    `ADD_N(disp_index_adder, 4, disp_index, adder_cout, sib_index, {3'b0, sib_size}, 1'b0)

    
    assign disp = IR[{disp_index, 3'd0} +: 32];

    */
