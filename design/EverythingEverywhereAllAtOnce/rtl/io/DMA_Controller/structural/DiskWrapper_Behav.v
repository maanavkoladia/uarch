module DiskWrapper (
    input wire clk,
    input wire rst,  // active low

    input wire ld_write_buf_req,
    input wire [31:0] ld_diskAddr,
    input wire [31:0] ld_num_bytes,

    output reg disk_ld_Buffer_V,
    output wire [8*`PAGE_SIZE-1:0] disk_ld_Buffer_o
);

    // -------------------------
    // Internal storage
    // -------------------------
    reg [7:0] disk[0:`DISK_SIZE-1];
    reg [7:0] disk_ld_Buffer[0:`PAGE_SIZE-1];

    reg [31:0] delayCycles_Counter;
    reg loading;

    integer i;
    integer copy_len;

    // -------------------------
    // Flatten buffer to output
    // -------------------------
    genvar gi;
    generate
        for (gi = 0; gi < `PAGE_SIZE; gi = gi + 1) begin : FLATTEN
            assign disk_ld_Buffer_o[gi*8+:8] = disk_ld_Buffer[gi];
        end
    endgenerate

    // -------------------------
    // Sequential logic
    // -------------------------
    always @(posedge clk) begin
        if (!rst) begin
            disk_ld_Buffer_V <= 0;
            delayCycles_Counter <= 0;
            loading <= 0;

            // manual array reset
            for (i = 0; i < `PAGE_SIZE; i = i + 1) begin
                disk_ld_Buffer[i] <= 8'd0;
            end

        end else begin
            if (ld_write_buf_req) begin
                loading <= 1;
                delayCycles_Counter <= `DISK_LOAD_DELAY;
                disk_ld_Buffer_V <= 0;

            end else if (loading) begin
                if (delayCycles_Counter == 0) begin
                    loading <= 0;
                    disk_ld_Buffer_V <= 1;

                    // compute copy length
                    if (ld_num_bytes % `PAGE_SIZE == 0) copy_len = `PAGE_SIZE;
                    else copy_len = ld_num_bytes % `PAGE_SIZE;

                    // copy disk → buffer
                    for (i = 0; i < copy_len; i = i + 1) begin
                        disk_ld_Buffer[i] <= disk[(ld_diskAddr+i)%`DISK_SIZE];
                    end

                end else begin
                    delayCycles_Counter <= delayCycles_Counter - 1;
                end
            end
        end
    end

endmodule
