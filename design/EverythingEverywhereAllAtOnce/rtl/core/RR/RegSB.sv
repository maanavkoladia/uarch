module RegSB (
    input wire clk,
    input wire rst,

    input reg_ids_e dr_id,
    input reg_ids_e sr_id,
    input reg_ids_e sib_base_id,
    input reg_ids_e sib_idx_id,

    input reg_ids_e wb_dr0_id,
    input bool wb_dr0_we,
    input reg_ids_e wb_dr1_id,
    input bool wb_dr1_we,  //

    input bool cs_sib_size,  //if 0 no need to read sib

    input bool cs_dr_wr,  //just sr
    input bool cs_sr_wr,  //dr or seg to be modifed in dr_id
    input bool cs_dr_rd,  //read dr
    input bool cs_sr_rd,  //read dr

    input reg_ids_e Segment0_ID,  //reads regfile
    input reg_ids_e Segment1_ID,  //readregfile
    input bool Segment1_valid,  //inidcated wether or not we need to read the regfile for the scond Segment1_ID

    input bool flush,  //clear everthing
    input bool farFlush,  //preserve CS sb, to keep fetch off
    output bool dep_stall,
    output bool ecx_sb,
    output bool codeSeg_sb
);


    //lowkey don't want to use reg ids, nvm might have to
    //nv, maybe not since just use segnment0/1 id since if needed here we will wait.
    //write back will send clear signal in dr0_id, must be able to clear segreg through that

    regsb_entry_t SCORE_BOARD[NUM_REGS];
    bool depStall_Internal;

    assign dep_stall = depStall_Internal;
    assign ecx_sb = SCORE_BOARD[ECX].counter != 0;
    assign codeSeg_sb = SCORE_BOARD[CS].counter != 0;
    //dr, sr, and segment Reg is encasulated in dr

    always_ff @(posedge clk) begin
        if (!rst) SCORE_BOARD <= '{default: '0};
        else if (flush) SCORE_BOARD <= '{default: '0};
        else if (farFlush) begin  //realies on CS being the zero Segment ID
            for (int i = 0; i < NUM_REGS - 1; i++) begin
                if (!(i == CS)) SCORE_BOARD[i].counter <= 0;
            end
        end else begin
            if (cs_dr_wr && !depStall_Internal) SCORE_BOARD[dr_id].counter++;
            if (cs_sr_wr && !depStall_Internal) SCORE_BOARD[sr_id].counter++;

            //dec logic
            if (wb_dr0_we) SCORE_BOARD[wb_dr0_id].counter--;
            if (wb_dr1_we) SCORE_BOARD[wb_dr1_id].counter--;
        end
    end

    //dr_rd, sr_rd, sib_rd if rd(sib_base_id, sib_idx_id), Segment0_ID, Segment1_ID
    logic dr_stall, sr_stall, seg0_stall, seg1_stall, sib_base_stall, sib_idx_stall;
    always_comb begin
        // Stall logic (ALL using match-aware rule)
        dr_stall = cs_dr_rd &&
        (SCORE_BOARD[dr_id].counter != 0);

        sr_stall = cs_sr_rd &&
        (SCORE_BOARD[sr_id].counter != 0);

        seg0_stall =
        (SCORE_BOARD[Segment0_ID].counter != 0);

        seg1_stall = Segment1_valid &&
        (SCORE_BOARD[Segment1_ID].counter != 0);

        sib_base_stall = (cs_sib_size != 0) &&
        (SCORE_BOARD[sib_base_id].counter != 0);

        sib_idx_stall = (cs_sib_size != 0) &&
        (SCORE_BOARD[sib_idx_id].counter != 0);

        // Final OR
        depStall_Internal = dr_stall || sr_stall || seg0_stall || seg1_stall || sib_base_stall || sib_idx_stall;
    end

endmodule
