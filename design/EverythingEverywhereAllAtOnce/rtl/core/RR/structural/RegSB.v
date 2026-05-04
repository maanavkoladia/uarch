module RegSB (
    input  wire        clk,
    input  wire        rst,

    input  wire        instructionforward,

    input  wire [`REG_ID_W-1:0]  dr_id,
    input  wire [`REG_ID_W-1:0]  sr_id,
    input  wire [`REG_ID_W-1:0]  sib_base_id,
    input  wire [`REG_ID_W-1:0]  sib_idx_id,

    input  wire [`REG_ID_W:0]  wb_dr0_id,
    input  wire        wb_dr0_we,
    input  wire [`REG_ID_W:0]  wb_dr1_id,
    input  wire        wb_dr1_we,

    input  wire        cs_sib_size,

    input  wire        cs_dr_wr,
    input  wire        cs_sr_wr,
    input  wire        cs_dr_rd,
    input  wire        cs_sr_rd,

    input  wire        cs_eax_rd,
    input  wire        cs_eax_wr,

    input  wire [`REG_ID_W:0]  Segment0_ID,
    input  wire [`REG_ID_W:0]  Segment1_ID,
    input  wire        Segment1_valid,

    input  wire        LD_OP,
    input  wire        ST_OP,
    input  wire        REP_OP,

    input  wire        flush,
    input  wire        farFlush,
    input  wire        callFlush,

    output wire        dep_stall,
    output wire        ecx_sb,
    output wire        codeSeg_sb
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
    assign cs_wr_to_both = cs_dr_wr && cs_sr_wr && (dr_id == sr_id);

    bool wb_wr_to_both;
    assign wb_wr_to_both = wb_dr0_we && wb_dr1_we && (wb_dr0_id == wb_dr1_id);




    bool wb0_dr_same_id, wb0_sr_same_id, wb1_dr_same_id, wb1_sr_same_id;
    bool wb0_eax_same_id, wb1_eax_same_id;

    assign wb0_dr_same_id = (dr_id == wb_dr0_id) && (cs_dr_wr && wb_dr0_we);
    assign wb0_sr_same_id = (sr_id == wb_dr0_id) && (cs_sr_wr && wb_dr0_we);
    assign wb0_eax_same_id = (EAX == wb_dr0_id) && (cs_eax_wr && wb_dr0_we);
    assign wb1_dr_same_id = (dr_id == wb_dr1_id) && (cs_dr_wr && wb_dr1_we);
    assign wb1_sr_same_id = (sr_id == wb_dr1_id) && (cs_sr_wr && wb_dr1_we);
    assign wb1_eax_same_id = (EAX == wb_dr1_id) && (cs_eax_wr && wb_dr1_we);

    assign dep_stall = depStall_Internal;
    assign ecx_sb = SCORE_BOARD[ECX].counter != 0;
    assign codeSeg_sb = SCORE_BOARD[CS].counter != 0;
    //dr, sr, and segment Reg is encasulated in dr

    always_comb begin
        next_SCORE_BOARD = SCORE_BOARD;
        if (cs_wr_to_both) begin
            if (updateSB) next_SCORE_BOARD[dr_id].counter++;
        end else begin
            if (cs_dr_wr && updateSB) next_SCORE_BOARD[dr_id].counter++;
            if (cs_sr_wr && updateSB) next_SCORE_BOARD[sr_id].counter++;
            if (cs_eax_wr && updateSB) next_SCORE_BOARD[EAX].counter++;
        end

        if (wb_wr_to_both) begin
            next_SCORE_BOARD[wb_dr0_id].counter--;
        end else begin
            //dec logic
            if (wb_dr0_we) next_SCORE_BOARD[wb_dr0_id].counter--;
            if (wb_dr1_we) next_SCORE_BOARD[wb_dr1_id].counter--;
        end
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
