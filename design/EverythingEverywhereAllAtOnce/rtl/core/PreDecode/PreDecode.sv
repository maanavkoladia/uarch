import Fetch_pkg::instruction_q_2_predecode_t;

`define slot inputs.latches.slot_info_list

module PreDecode(
    input predecode_stage_latches_t inputs,

    output uint32_t EIP,
    output logic invalid_instruction;
);

    byte_t IR[CACHE_LINES_SIZE];
    wire pf0, pf1, pf2;
    wire[9:0] pf0_vect, pf1_vect, pf2_vect, total_pf_vector;
    wire[1:0] num_pfs;

    uint8_t cl_end;
    assign cl_end = EIP[5:0] + 16;

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
                    IR = {slot[EIP[5:4] + 1][cl_end:0], slot[EIP[5:4]][15:EIP[3:0]]};
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

        



    end

endmodule

