module decode_gp_gen (
    input wire [31:0] prev_eip,
    input wire [3:0] prev_length,
    input wire [31:0] segLimit,

    output wire gp_fault_o
);
    wire [31:0] l_addr_o
    wire [3:0] decremented_length;
    wire adder_cout, adder_cout1, adder_cout2;
    
    `ADD_N(decrementer_length_adder, 4, decremented_length, adder_cout, prev_length, 4'hF, 1'b0)
    `ADD_N(l_addr_adder, 32, l_addr_o, adder_cout1, prev_eip, {28'd0, decremented_length}, 1'b0)

    wire [31:0] inv_l_addr_o;
    `INV_N(l_addr_inverter, 32, l_addr_o, inv_l_addr_o)


    wire [31:0] gp_fault_adder_result; //segLimit - l_addr
    `ADD_N(gp_fault_comp, 32, gp_fault_adder_result, adder_cout2, inv_l_addr_o, segLimit, 1'b1)

    //assign gp_fault_o = l_addr_o > segLimit;
    assign gp_fault_o = gp_fault_adder_result[31];

endmodule

