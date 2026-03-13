import common_pkg::*;
import Fetch_pkg::*;

module BTB (
    input  wire         clk,
    input  wire         reset,
    input  btb_input_t  inputs,
    output BTB_output_t outputs
);


    localparam int btb_entries = 64;
    localparam int btb_entries_bits = $clog2(btb_entries);
    localparam int tagBits = ADDRESS_BITS - $clog2(CACHE_LINES_SIZE) - btb_entries_bits;
    localparam int indexIdx = $clog2(CACHE_LINES_SIZE);

    typedef struct packed {
        logic [tagBits-1:0] tag;
        address_t           exe_br_target;
        address_t           exe_br_eip;
        logic               XCL;
        logic               valid;
    } btb_entry_t;

    typedef struct packed {
        logic [tagBits-1:0]          tag;
        logic [btb_entries_bits-1:0] index;
    } spc_fields_t;

    spc_fields_t spc_fields, exe_fields;

    btb_entry_t btb_entry_arr[btb_entries];

    // -----------------------------
    // Extract tag + index from PCs
    // -----------------------------
    assign spc_fields = '{
            tag: inputs.spc[ADDRESS_BITS-1 : (indexIdx+btb_entries_bits)],
            index: inputs.spc[(indexIdx+btb_entries_bits-1) : indexIdx]
        };

    assign exe_fields = '{
            tag: inputs.exe_br_eip[ADDRESS_BITS-1 : (indexIdx+btb_entries_bits)],
            index: inputs.exe_br_eip[(indexIdx+btb_entries_bits-1) : indexIdx]
        };

    // -----------------------------
    // Combinational lookup
    // -----------------------------
    always_comb begin
        outputs = '0;

        if (btb_entry_arr[spc_fields.index].valid &&
            btb_entry_arr[spc_fields.index].tag == spc_fields.tag) begin

            outputs.hit        = 1'b1;
            outputs.target     = btb_entry_arr[spc_fields.index].exe_br_target;
            outputs.exe_br_eip = btb_entry_arr[spc_fields.index].exe_br_eip;
            outputs.XCL        = btb_entry_arr[spc_fields.index].XCL;
        end
    end

    // -----------------------------
    // Sequential update
    // -----------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < btb_entries; i++) begin
                btb_entry_arr[i].valid <= 1'b0;
            end
        end else if (inputs.exe_br_valid) begin
            btb_entry_arr[exe_fields.index] <= '{
                tag: exe_fields.tag,
                exe_br_target: inputs.exe_br_target,
                exe_br_eip: inputs.exe_br_eip,
                XCL: inputs.exe_br_XCL,
                valid: 1'b1
            };
        end
    end

endmodule
