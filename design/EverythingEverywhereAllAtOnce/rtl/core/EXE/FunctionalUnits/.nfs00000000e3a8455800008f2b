module far_jmp_op(
    input exe_cs_operation_type_e op_type,
    input uint64_t srA, //from resbuf
    output uint64_t dr_o //code segment
);

    assign dr_o = (op_type == control_store_pkg::FAR_JMP16) ? {48'd0, srA[31:16]} : {48'd0, srA[47:32]};

endmodule
