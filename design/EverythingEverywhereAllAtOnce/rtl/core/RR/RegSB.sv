module RegSB (
    input wire clk,
    input wire rst,

    input bool instructionforward,

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

    input bool cs_eax_rd,
    input bool cs_eax_wr,

    input reg_ids_e Segment0_ID,  //reads regfile
    input reg_ids_e Segment1_ID,  //readregfile
    input bool Segment1_valid,  //inidcated wether or not we need to read the regfile for the scond Segment1_ID

    input bool LD_OP,
    input bool ST_OP,
    input bool REP_OP,

    input bool flush,  //clear everthing
    input bool farFlush,  //preserve CS sb, to keep fetch off
    input bool callFlush,
    output bool dep_stall,
    output bool ecx_sb,
    output bool codeSeg_sb
);


    //lowkey don't want to use reg ids, nvm might have to
    //nv, maybe not since just use segnment0/1 id since if needed here we will wait.
    //write back will send clear signal in dr0_id, must be able to clear segreg through that

    regsb_entry_t SCORE_BOARD[NUM_REGS];
    regsb_entry_t next_SCORE_BOARD[NUM_REGS];
    bool depStall_Internal;

    bool updateSB;
    assign updateSB = !depStall_Internal && instructionforward;


    //make sur edecode only sends in valid dr_wr and sr_wr, can't have false scoreboard setting
    //make sure decode is zeroing out any sensitive cs like sr_wr
    bool cs_wr_to_both;
    assign cs_wr_to_both = (cs_dr_wr && cs_sr_wr && (dr_id == sr_id)) || (cs_dr_wr && cs_eax_wr && (dr_id == EAX));

    bool wb_wr_to_both;
    assign wb_wr_to_both = wb_dr0_we && wb_dr1_we && (wb_dr0_id == wb_dr1_id);


    assign dep_stall = depStall_Internal;
    assign ecx_sb = SCORE_BOARD[ECX].counter != 0;
    assign codeSeg_sb = SCORE_BOARD[CS].counter != 0;
    //dr, sr, and segment Reg is encasulated in dr

    always_comb begin
        next_SCORE_BOARD = SCORE_BOARD;
        if ((cs_dr_wr && updateSB && !cs_wr_to_both) || (cs_wr_to_both && updateSB)) next_SCORE_BOARD[dr_id].counter++;
        if (cs_sr_wr && updateSB && !cs_wr_to_both) next_SCORE_BOARD[sr_id].counter++;
        if (cs_eax_wr && updateSB && !cs_wr_to_both) next_SCORE_BOARD[EAX].counter++;

        if (wb_dr0_we || wb_wr_to_both) next_SCORE_BOARD[wb_dr0_id].counter--;
        if (wb_dr1_we && !wb_wr_to_both) next_SCORE_BOARD[wb_dr1_id].counter--;
    end

    always_ff @(posedge clk) begin
        if (!rst || flush || callFlush || farFlush) SCORE_BOARD <= '{default: '0};
        else SCORE_BOARD <= next_SCORE_BOARD;
    end

    // always_ff @(posedge clk) begin
    //     if(!rst || flush || callFlush || farFlush) SCORE_BOARD <= '{default : '0};
    //     else begin
    //         if(updateSB) begin
    //             if((cs_dr_wr || cs_wr_to_both) && !(wb0_dr_same_id || wb1_dr_same_id)) SCORE_BOARD[dr_id].counter++;
    //             if((cs_sr_wr && !cs_wr_to_both) && !(wb0_sr_same_id || wb1_sr_same_id)) SCORE_BOARD[sr_id].counter++;
    //             if((cs_eax_wr && !cs_wr_to_both) && !(wb0_eax_same_id || wb1_eax_same_id)) SCORE_BOARD[EAX].counter++;
    //         end

    //         if((wb_dr0_we || wb_wr_to_both) && !(wb0_dr_same_id || wb0_sr_same_id || wb0_eax_same_id)) SCORE_BOARD[wb_dr0_id].counter--;
    //         if((wb_dr1_we && !wb_wr_to_both) && !(wb1_dr_same_id || wb1_sr_same_id || wb1_eax_same_id)) SCORE_BOARD[wb_dr1_id].counter--;
    //     end
    // end

    //dr_rd, sr_rd, sib_rd if rd(sib_base_id, sib_idx_id), Segment0_ID, Segment1_ID
    logic dr_stall, sr_stall, seg0_stall, seg1_stall, sib_base_stall, sib_idx_stall, eax_stall;
    always_comb begin
        // Stall logic (ALL using match-aware rule)
        dr_stall = cs_dr_rd && (LD_OP || ST_OP || REP_OP) && (SCORE_BOARD[dr_id].counter != 0);
        sr_stall = cs_sr_rd && (LD_OP || ST_OP || REP_OP) && (SCORE_BOARD[sr_id].counter != 0);
        eax_stall = 0;
        //            cs_eax_rd && (LD_OP || ST_OP || REP_OP) &&
        //        (SCORE_BOARD[EAX].counter != 0);
        //
        //dr_stall = cs_dr_rd && (SCORE_BOARD[dr_id].counter != 0);
        //sr_stall = cs_sr_rd && (SCORE_BOARD[sr_id].counter != 0);
        //eax_stall =  cs_eax_rd && (SCORE_BOARD[EAX].counter != 0);

        seg0_stall = (SCORE_BOARD[Segment0_ID].counter != 0);

        seg1_stall = Segment1_valid && (SCORE_BOARD[Segment1_ID].counter != 0);

        sib_base_stall = (cs_sib_size != 0) && (SCORE_BOARD[sib_base_id].counter != 0);

        sib_idx_stall = (cs_sib_size != 0) && (SCORE_BOARD[sib_idx_id].counter != 0);

        // Final OR
        depStall_Internal = dr_stall || sr_stall || seg0_stall || seg1_stall || sib_base_stall || sib_idx_stall || eax_stall;
    end

endmodule
