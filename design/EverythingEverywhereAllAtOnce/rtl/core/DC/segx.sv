module segx (
    input uint32_t laddy,
    input uint32_t seg_limit,
    input uint32_t seg_limit_w_datasize,
    output segx_gp
);

    //assign segx_gp = (laddy >= seg_limit_w_datasize) || (laddy >= seg_limit);
    assign segx_gp = (laddy >= seg_limit_w_datasize);
    
endmodule