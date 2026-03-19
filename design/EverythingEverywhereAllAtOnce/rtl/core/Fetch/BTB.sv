import common_pkg::*;
import Fetch_pkg::*;

module BTB (
    input  wire         clk,
    input  wire         reset,
    input  address_t    spc,

        //execute info
    input  bool         exe_br_valid,
    input  address_t    exe_br_target,
    input  address_t    exe_br_eip,
    input  bool         exe_br_XCL,
    input  bool         exe_br_ucond,
    output btb_output_t outputs
);


    localparam int btb_entries = 8;
    localparam int btb_entries_bits = $clog2(btb_entries);
    localparam int tagBits = ADDRESS_BITS - $clog2(CACHE_LINES_SIZE_B) - btb_entries_bits;
    localparam int indexIdx = $clog2(CACHE_LINES_SIZE_B);

    //entries are for storing regular branches and uncodintiaonal branches and calls
    //we dont store far calls or jumps
    typedef struct packed {
        logic [tagBits-1:0]   tag;
        l_address_t           br_target;
        l_address_t           br_eip;
        bool                  XCL;
        bool                  br_ucond; //for call and jmp.
        bool                  valid;
    } btb_entry_t;

    /* an address is 32 bits. Since we are fetching cache lines the bottom 4 bits are always 0
       We are making a direct index BTB. To index into the btb we cant just use the botton 4 bits since they are 0
       so we use the next log(entries) bits. Thats why we do indexIDX+btb_entries_bits
       since there are 64 entires rn bits [10:4] would be the tag bits. the rest are tag
    */
    typedef struct packed {
        logic [tagBits-1:0]          tag;
        logic [btb_entries_bits-1:0] index;
    } spc_fields_t;

    spc_fields_t spc_fields, exe_fields;

    btb_entry_t btb_entry_arr[btb_entries];


    assign spc_fields = '{
            tag: spc[ADDRESS_BITS-1 : (indexIdx+btb_entries_bits)],
            index: spc[(indexIdx+btb_entries_bits-1) : indexIdx]
        };

    assign exe_fields = '{
            tag: exe_br_eip[ADDRESS_BITS-1 : (indexIdx+btb_entries_bits)],
            index: exe_br_eip[(indexIdx+btb_entries_bits-1) : indexIdx]
        };


    always_comb begin
        outputs = '{default: '0};

        if (btb_entry_arr[spc_fields.index].valid &&
            btb_entry_arr[spc_fields.index].tag == spc_fields.tag) begin

            outputs.hit        = 1'b1;
            outputs.br_target  = btb_entry_arr[spc_fields.index].br_target;
            outputs.br_eip     = btb_entry_arr[spc_fields.index].br_eip;
            outputs.XCL        = btb_entry_arr[spc_fields.index].XCL;
            outputs.br_ucond   = btb_entry_arr[spc_fields.index].br_ucond;
        end
    end


    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < btb_entries; i++) begin
                btb_entry_arr[i].valid <= 1'b0;
            end
        end else if (exe_br_valid) begin
            btb_entry_arr[exe_fields.index] <= '{
                tag: exe_fields.tag,
                br_target: exe_br_target,
                br_eip: exe_br_eip,
                XCL: exe_br_XCL,
                br_ucond: exe_br_ucond,
                valid: 1'b1
            };
        end
    end

endmodule
