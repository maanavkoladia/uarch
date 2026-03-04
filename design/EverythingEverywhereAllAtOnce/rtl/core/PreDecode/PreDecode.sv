import Fetch_pkg::instruction_q_2_predecode_t;

`define slot inputs.latches.slot_info_list

module PreDecode(
    input predecode_stage_latches_t inputs,

    output reg[31:0] EIP;
    output predecode_2_fetch predecode_forward;
    output decode_stage_latches decode_latches;
);

    byte_t IR[CACHE_LINES_SIZE];
    logic pf0, pf1, pf2;
    logic[9:0] pf0_vect, pf1_vect, pf2_vect, total_pf_vector;
    logic[1:0] num_pfs;
    logic[7:0] op_byte, mod_byte, sib_byte;
    logic needr_m;
    logic[2:0] imm_size;
    logic[2:0] msd_size, disp_size;
    logic sib_size;
    logic[3:0] total_inst_length;
    byte_t disp[4];
    byte_t imm[4];

    uint8_t cl_end;
    assign cl_end = EIP[5:0] + 16;

    assign op_byte = IR[num_pfs];
    assign imm_size = (total_pf_vector[3]) ? 3'b010 : imm_size;
    assign mod_byte = IR[num_pfs + 1];
    assign sib_byte = IR[num_pfs + 2];
    assign msd_size = (needr_m) ? msd_size : 3'b0;
    assign total_inst_length = num_pfs + imm_size + msd_size + 1'b1;

    //latch assigns
    assign decode_latches.branch_info = slot[EIP[5:4]].br_metadata;
    assign decode_latches.NEIP = EIP + total_inst_length;
    assign decode_latches.imm32 = imm32;
    assign decode_latches.disp = disp;
    assign decode_latches.sib = sib_byte;
    assign decode_latches.mod = mod_byte;
    assign decode_latches.opcode = op_byte;
    assign decode_latches.pfs = num_pfs;
    assign decode_latches.total_pf_vector = total_pf_vector;
    assign decode_latches.needr_m = needr_m
    assign decode_latches.disp_size = disp_size;
    assign decode_latches.imm_size = imm_size;
    assign decode_latches.sib_size = sib_size;

    always_comb begin
        //defaults to prevent inferred latches
        invalid_instruction = 1'b0;
        pf0 = 1'b0;
        pf1 = 1'b0;
        pf2 = 1'b0;
        pf0_vect = 10'b0;
        pf1_vect = 10'b0;
        pf2_vect = 10'b0;
        total_pf_vector = 10'b0;
        num_pfs = 2'b0;
        

        if(slot[EIP[5:4]].valid){
            if((EIP[3]|EIP[2]|EIP[1]|EIP[0])){ 
                if(slot[EIP[5:4] + 1].valid){//lowkey gotta figure out this invalid inst business
                    IR = {slot[EIP[5:4] + 1].data[cl_end:0], slot[EIP[5:4]].data[15:EIP[3:0]]};
                }
            }
            else {
                IR = slot[EIP[5:4]][15:0];
            }
        }
        else{
            invalid_instruction = 1'b1;
        }

        //could maybe have a valid bit for each byte of IR which you check each time for invalid insts
        case(IR[0])     //MSB --> 2e, 36, 3e, 26, 64, 65, 66, 67, 0f, f3  <-- LSB vector
            8'h2E: begin
                pf0 = 1'b1;
                pf0_vect = 10'b10_0000_0000;
            end
            8'h36: begin
                pf0 = 1'b1;
                pf0_vect = 10'b01_0000_0000;
            end

            8'h3E: begin
                pf0 = 1'b1;
                pf0_vect = 10'b00_1000_0000;
            end
            8'h26: begin
                pf0 = 1'b1;
                pf0_vect = 10'b00_0100_0000;
            end
            8'h64: begin
                pf0 = 1'b1;
                pf0_vect = 10'b00_0010_0000;
            end
            8'h65: begin
                pf0 = 1'b1;
                pf0_vect = 10'b00_0001_0000;
            end

            8'h66: begin
                pf0 = 1'b1;
                pf0_vect = 10'b00_0000_1000;
            end
            8'h67: begin
                pf0 = 1'b1;
                pf0_vect = 10'b00_0000_0100;
            end
            8'h0F: begin
                pf0 = 1'b1;
                pf0_vect = 10'b00_0000_0010;
            end
            8'hF3: begin
                pf0 = 1'b1;
                pf0_vect = 10'b00_0000_0001;
            end
        endcase

        case(IR[1])     //MSB --> 2e, 36, 3e, 26, 64, 65, 66, 67, 0f, f3  <-- LSB vector
            8'h2E: begin
                pf1 = 1'b1;
                pf1_vect = 10'b10_0000_0000;
            end
            8'h36: begin
                pf1 = 1'b1;
                pf1_vect = 10'b01_0000_0000;
            end

            8'h3E: begin
                pf1 = 1'b1;
                pf1_vect = 10'b00_1000_0000;
            end
            8'h26: begin
                pf1 = 1'b1;
                pf1_vect = 10'b00_0100_0000;
            end
            8'h64: begin
                pf1 = 1'b1;
                pf1_vect = 10'b00_0010_0000;
            end
            8'h65: begin
                pf1 = 1'b1;
                pf1_vect = 10'b00_0001_0000;
            end

            8'h66: begin
                pf1 = 1'b1;
                pf1_vect = 10'b00_0000_1000;
            end
            8'h67: begin
                pf1 = 1'b1;
                pf1_vect = 10'b00_0000_0100;
            end
            8'h0F: begin
                pf1 = 1'b1;
                pf1_vect = 10'b00_0000_0010;
            end
            8'hF3: begin
                pf1 = 1'b1;
                pf1_vect = 10'b00_0000_0001;
            end
        endcase

        case(IR[2])     //MSB --> 2e, 36, 3e, 26, 64, 65, 66, 67, 0f, f3  <-- LSB vector
            8'h2E: begin
                pf2 = 1'b1;
                pf2_vect = 10'b10_0000_0000;
            end
            8'h36: begin
                pf2 = 1'b1;
                pf2_vect = 10'b01_0000_0000;
            end

            8'h3E: begin
                pf2 = 1'b1;
                pf2_vect = 10'b00_1000_0000;
            end
            8'h26: begin
                pf2 = 1'b1;
                pf2_vect = 10'b00_0100_0000;
            end
            8'h64: begin
                pf2 = 1'b1;
                pf2_vect = 10'b00_0010_0000;
            end
            8'h65: begin
                pf2 = 1'b1;
                pf2_vect = 10'b00_0001_0000;
            end

            8'h66: begin
                pf2 = 1'b1;
                pf2_vect = 10'b00_0000_1000;
            end
            8'h67: begin
                pf2 = 1'b1;
                pf2_vect = 10'b00_0000_0100;
            end
            8'h0F: begin
                pf2 = 1'b1;
                pf2_vect = 10'b00_0000_0010;
            end
            8'hF3: begin
                pf2 = 1'b1;
                pf2_vect = 10'b00_0000_0001;
            end
        endcase

        if(pf0){
            if(pf1){
                if(pf2){
                    num_pfs = 2'b11;
                }
                else{
                    num_pfs = 2'b10;
                }
            }
            else{
                num_pfs = 2'b01;
            }
        }
        else{
            num_pfs = 2'b00;
        }

        case(num_pfs)
            2'b01: total_pf_vector = pf0_vector;
            2'b10: total_pf_vector = pf0_vector | pf1_vector;
            2'b11: total_pf_vector = pf0_vector | pf1_vector | pf2_vector;
            default: total_pf_vector = 10'b0;
        endcase

        OP_LUT oplut(op_byte, needr_m, imm_size);
        MOD_LUT modlut(mod_byte, msd_size, sib_size, disp_size);

        disp = IR[num_pfs+3 + 3 : num_pfs+3];
        imm = IR[num_pfs+3+4 + 3: num_pfs+3+4];

    end

    //needs eip logic block, have not worked out details yet.
    always_ff @(posedge clk) begin
        EIP <= EIP + total_inst_length;        
    end

endmodule


/*
import Fetch_pkg::instruction_q_2_predecode_t;

`define slot inputs.latches.slot_info_list

module PreDecode(
    input predecode_stage_latches_t inputs,

    // FIX #1: Changed ';' to ',' in port list
    output reg[31:0] EIP,
    output predecode_2_fetch predecode_forward,
    output decode_stage_latches decode_latches
);

    byte_t IR[CACHE_LINES_SIZE];
    logic pf0, pf1, pf2;
    logic[9:0] pf0_vect, pf1_vect, pf2_vect, total_pf_vector;
    logic[1:0] num_pfs;
    logic[7:0] op_byte, mod_byte, sib_byte;
    logic needr_m;
    logic[2:0] imm_size;
    logic[2:0] msd_size, disp_size;
    logic sib_size;
    logic[3:0] total_inst_length;
    byte_t disp[4];
    byte_t imm[4];

    // FIX #2: Changed 'uint8_t' (C type) to 'logic [7:0]' (SV type)
    logic [7:0] cl_end;

    // FIX #3: Declared missing 'invalid_instruction' signal
    logic invalid_instruction;

    // FIX #4: Declared missing 'imm32' signal (assembled from imm byte array)
    logic [31:0] imm32;

    assign cl_end = EIP[5:0] + 16;

    assign op_byte = IR[num_pfs];
    assign mod_byte = IR[num_pfs + 1];
    assign sib_byte = IR[num_pfs + 2];

    // FIX #5: Removed self-referential continuous assignments for imm_size and
    // msd_size — these created combinational loops. They are now driven
    // exclusively inside the always_comb block below.

    assign total_inst_length = num_pfs + imm_size + msd_size + 1'b1;

    // latch assigns
    assign decode_latches.branch_info   = `slot[EIP[5:4]].br_metadata;
    assign decode_latches.NEIP          = EIP + total_inst_length;
    assign decode_latches.imm32         = imm32;
    assign decode_latches.disp          = disp;
    assign decode_latches.sib           = sib_byte;
    assign decode_latches.mod           = mod_byte;
    assign decode_latches.opcode        = op_byte;
    assign decode_latches.pfs           = num_pfs;
    assign decode_latches.total_pf_vector = total_pf_vector;
    assign decode_latches.needr_m       = needr_m; // FIX #6: Added missing semicolon
    assign decode_latches.disp_size     = disp_size;
    assign decode_latches.imm_size      = imm_size;
    assign decode_latches.sib_size      = sib_size;

    // FIX #7: Moved OP_LUT and MOD_LUT instantiations to module level —
    // module instantiations are illegal inside procedural (always_comb) blocks.
    OP_LUT  oplut  (.op(op_byte),  .needr_m(needr_m), .imm_size(imm_size));
    MOD_LUT modlut (.mod(mod_byte), .msd_size(msd_size), .sib_size(sib_size), .disp_size(disp_size));

    always_comb begin
        // defaults to prevent inferred latches
        invalid_instruction = 1'b0;
        pf0                 = 1'b0;
        pf1                 = 1'b0;
        pf2                 = 1'b0;
        pf0_vect            = 10'b0;
        pf1_vect            = 10'b0;
        pf2_vect            = 10'b0;
        total_pf_vector     = 10'b0;
        num_pfs             = 2'b0;

        // FIX #5 (cont.): Default values for imm_size and msd_size set here,
        // replacing the removed self-referential continuous assignments.
        imm_size = 3'b0;
        msd_size = 3'b0;

        // FIX #8: Changed C-style '{}' braces to SystemVerilog 'begin/end'
        // (applied throughout this block)
        if (`slot[EIP[5:4]].valid) begin
            if ((EIP[3] | EIP[2] | EIP[1] | EIP[0])) begin
                if (`slot[EIP[5:4] + 1].valid) begin
                    // FIX #9: Replaced variable-bound slice '[cl_end:0]' with
                    // indexed part-select '[0 +: cl_end]' — SV requires
                    // constant or indexed part-select bounds.
                    IR = {`slot[EIP[5:4] + 1].data[0 +: cl_end],
                          `slot[EIP[5:4]].data[EIP[3:0] +: (16 - EIP[3:0])]};
                end
            end
            else begin
                // FIX #10: Added missing '.data' field access on slot struct
                IR = `slot[EIP[5:4]].data[15:0];
            end
        end
        else begin
            invalid_instruction = 1'b1;
        end

        // Prefix detection for IR[0]
        // MSB --> 2e, 36, 3e, 26, 64, 65, 66, 67, 0f, f3  <-- LSB vector
        case (IR[0])
            8'h2E: begin pf0 = 1'b1; pf0_vect = 10'b10_0000_0000; end
            8'h36: begin pf0 = 1'b1; pf0_vect = 10'b01_0000_0000; end
            8'h3E: begin pf0 = 1'b1; pf0_vect = 10'b00_1000_0000; end
            8'h26: begin pf0 = 1'b1; pf0_vect = 10'b00_0100_0000; end
            8'h64: begin pf0 = 1'b1; pf0_vect = 10'b00_0010_0000; end
            8'h65: begin pf0 = 1'b1; pf0_vect = 10'b00_0001_0000; end
            8'h66: begin pf0 = 1'b1; pf0_vect = 10'b00_0000_1000; end
            8'h67: begin pf0 = 1'b1; pf0_vect = 10'b00_0000_0100; end
            8'h0F: begin pf0 = 1'b1; pf0_vect = 10'b00_0000_0010; end
            8'hF3: begin pf0 = 1'b1; pf0_vect = 10'b00_0000_0001; end
        endcase

        // Prefix detection for IR[1]
        case (IR[1])
            8'h2E: begin pf1 = 1'b1; pf1_vect = 10'b10_0000_0000; end
            8'h36: begin pf1 = 1'b1; pf1_vect = 10'b01_0000_0000; end
            8'h3E: begin pf1 = 1'b1; pf1_vect = 10'b00_1000_0000; end
            8'h26: begin pf1 = 1'b1; pf1_vect = 10'b00_0100_0000; end
            8'h64: begin pf1 = 1'b1; pf1_vect = 10'b00_0010_0000; end
            8'h65: begin pf1 = 1'b1; pf1_vect = 10'b00_0001_0000; end
            8'h66: begin pf1 = 1'b1; pf1_vect = 10'b00_0000_1000; end
            8'h67: begin pf1 = 1'b1; pf1_vect = 10'b00_0000_0100; end
            8'h0F: begin pf1 = 1'b1; pf1_vect = 10'b00_0000_0010; end
            8'hF3: begin pf1 = 1'b1; pf1_vect = 10'b00_0000_0001; end
        endcase

        // Prefix detection for IR[2]
        case (IR[2])
            8'h2E: begin pf2 = 1'b1; pf2_vect = 10'b10_0000_0000; end
            8'h36: begin pf2 = 1'b1; pf2_vect = 10'b01_0000_0000; end
            8'h3E: begin pf2 = 1'b1; pf2_vect = 10'b00_1000_0000; end
            8'h26: begin pf2 = 1'b1; pf2_vect = 10'b00_0100_0000; end
            8'h64: begin pf2 = 1'b1; pf2_vect = 10'b00_0010_0000; end
            8'h65: begin pf2 = 1'b1; pf2_vect = 10'b00_0001_0000; end
            8'h66: begin pf2 = 1'b1; pf2_vect = 10'b00_0000_1000; end
            8'h67: begin pf2 = 1'b1; pf2_vect = 10'b00_0000_0100; end
            8'h0F: begin pf2 = 1'b1; pf2_vect = 10'b00_0000_0010; end
            8'hF3: begin pf2 = 1'b1; pf2_vect = 10'b00_0000_0001; end
        endcase

        if (pf0) begin
            if (pf1) begin
                if (pf2)
                    num_pfs = 2'b11;
                else
                    num_pfs = 2'b10;
            end
            else begin
                num_pfs = 2'b01;
            end
        end
        else begin
            num_pfs = 2'b00;
        end

        // FIX #11: Renamed 'pf0_vector/pf1_vector/pf2_vector' to match the
        // declared signal names 'pf0_vect/pf1_vect/pf2_vect'
        case (num_pfs)
            2'b01:   total_pf_vector = pf0_vect;
            2'b10:   total_pf_vector = pf0_vect | pf1_vect;
            2'b11:   total_pf_vector = pf0_vect | pf1_vect | pf2_vect;
            default: total_pf_vector = 10'b0;
        endcase

        // FIX #5 (cont.): imm_size conditional now driven here rather than
        // via a self-referential continuous assign
        if (total_pf_vector[3])
            imm_size = 3'b010;

        // FIX #9 (cont.): Replaced variable-bound slices on disp and imm with
        // indexed part-selects (+:)
        disp  = IR[num_pfs+3 +: 4];
        imm   = IR[num_pfs+7 +: 4];

        // FIX #4 (cont.): Assemble imm32 from the imm byte array
        imm32 = {imm[3], imm[2], imm[1], imm[0]};

    end

    // needs eip logic block, have not worked out details yet.
    always_ff @(posedge clk) begin
        EIP <= EIP + total_inst_length;
    end

endmodule
*/

