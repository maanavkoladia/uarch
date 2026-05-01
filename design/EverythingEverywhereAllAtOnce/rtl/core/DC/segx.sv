module segx (
    input uint32_t laddy,
    input uint32_t seg_limit,
    input uint32_t seg_limit_w_datasize,
    input bool stack_access,
    output bool segx_gp
);

    //assign segx_gp = (laddy >= seg_limit_w_datasize) || (laddy >= seg_limit);
    assign segx_gp = (laddy >= seg_limit_w_datasize) && !stack_access;
    
endmodule