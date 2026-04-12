import io_common_pkg::*;
import common_pkg::*;

module DiskWrapper (
    input wire clk,
    input wire rst,  // active low

    input logic ld_write_buf_req,
    input uint32_t ld_diskAddr,
    input uint32_t ld_num_bytes,

    output bool   disk_ld_Buffer_V,
    output byte_t disk_ld_Buffer_o[PAGE_SIZE]
);

    byte_t disk[DISK_SIZE];
    byte_t disk_ld_Buffer[PAGE_SIZE];
    uint32_t delayCycles_Counter;
    bool loading;

    assign disk_ld_Buffer_o = disk_ld_Buffer;

    always @(posedge clk) begin
        if (!rst) begin
            disk_ld_Buffer_V <= 0;
            disk_ld_Buffer <= '{default : '0};
            delayCycles_Counter <= 0;
            loading <= 0;
        end else begin
            if (ld_write_buf_req) begin
                loading <= 1;
                delayCycles_Counter <= DISK_LOAD_DELAY;
                disk_ld_Buffer_V <= 0;
            end else if (loading) begin
                if (delayCycles_Counter == 0) begin
                    loading <= 0;
                    disk_ld_Buffer_V <= 1;
                    // copy disk → buffer (instant after delay)
                    for (int i = 0; i < (ld_num_bytes % PAGE_SIZE == 0 ? PAGE_SIZE : ld_num_bytes % PAGE_SIZE); i = i + 1) begin
                        disk_ld_Buffer[i] <= disk[(ld_diskAddr + i) % DISK_SIZE];
                    end
                end else begin
                    delayCycles_Counter <= delayCycles_Counter - 1;
                end
            end
        end
    end

endmodule
