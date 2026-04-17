//value comes from DR latch/SRA
//SP will ALWAYS come from SR/SRB
//RES_BUF <- DR_latch/SRA
//SR_o <- SP
module push_op(
    input  logic [63:0] value, // value to push SRA
    input  logic [63:0] sp,    // stack pointer in SRB
    input  logic [3:0] data_size_vec,
    output logic [63:0] res_buf,  // value to write to memory
    output logic [63:0] sr_o      // new stack pointer out
);

    logic [2:0] num_bytes;
    always_comb begin
            // Map data_size to byte count
        num_bytes = 2;
        if(data_size_vec[2])
            num_bytes = 4;

        sr_o = sp-num_bytes;
        res_buf = {32'd0, value[31:0]};
    end


endmodule