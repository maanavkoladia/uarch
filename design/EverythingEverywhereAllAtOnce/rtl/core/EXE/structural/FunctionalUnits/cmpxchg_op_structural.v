// Structural Verilog 2005 port of EXE/FunctionalUnits/cmpxchg_op.sv
//
// Instantiates the structural cmp module to derive the 6 flags from
// {32'd0,EAX} - {32'd0,rm[31:0]}, then muxes the EAX/rm/r byte-lane swap.
// EAX_o = ~ZF ? next_EAX : {32'd0, EAX}     (zero-extend EAX to 64-bit)
// dr_o  =  ZF ? next_dr  : rm
// res_buf = same as dr_o.

module cmpxchg_op (
    input  wire [31:0] EAX,
    input  wire [63:0] rm,
    input  wire [31:0] r,
    input  wire [3:0]  data_size,
    input  wire [3:0]  sr_data_size_vec,
    output wire [63:0] dr_o,
    output wire [63:0] EAX_o,
    output wire [63:0] res_buf,
    output wire        ZF,
    output wire        SF,
    output wire        PF,
    output wire        CF,
    output wire        OF,
    output wire        AF
);

    // ---- Flag derivation via cmp ----
    wire cmp_CF, cmp_AF, cmp_ZF, cmp_SF, cmp_PF, cmp_OF;
    cmp u_cmp (
        .srA       ({32'd0, EAX}),
        .srB       ({32'd0, rm[31:0]}),
        .data_size (data_size),
        .CF        (cmp_CF),
        .AF        (cmp_AF),
        .ZF        (cmp_ZF),
        .SF        (cmp_SF),
        .PF        (cmp_PF),
        .OF        (cmp_OF)
    );

    // ---- next_EAX byte-lane swap (using rm) ----
    wire [7:0] rm_low_sel;
    `MUX_2(u_mux_rm_lo, 8, rm_low_sel, rm[15:8], rm[7:0], data_size[0])

    wire [7:0]  next_eax_b1;
    wire [15:0] next_eax_hi;
    wire swap_raw, swap;
    `AND_2(u_and_d1_d0, 1, swap_raw, data_size[1], data_size[0])
    bufferH16$ u_swap_buf (.out(swap), .in(swap_raw));
    `MUX_2(u_mux_eax_b1, 8,  next_eax_b1, EAX[15:8],  rm[15:8],  swap)
    `MUX_2(u_mux_eax_hi, 16, next_eax_hi, EAX[31:16], rm[31:16], data_size[2])

    wire [31:0] next_EAX;
    assign next_EAX = {next_eax_hi, next_eax_b1, rm_low_sel};

    // ---- next_dr byte-lane swap (using r) ----
    wire [7:0] r_low_sel, r_upper_sel;
    `MUX_2(u_mux_r_lo, 8, r_low_sel,   r[15:8], r[7:0],  sr_data_size_vec[0])
    `MUX_2(u_mux_r_up, 8, r_upper_sel, r[7:0],  r[15:8], sr_data_size_vec[1])

    wire [7:0]  next_dr_b0, next_dr_b1;
    wire [15:0] next_dr_hi;
    `MUX_2(u_mux_dr_b0, 8,  next_dr_b0, rm[7:0],   r_low_sel,    data_size[0])
    `MUX_2(u_mux_dr_b1, 8,  next_dr_b1, rm[15:8],  r_upper_sel,  data_size[1])
    `MUX_2(u_mux_dr_hi, 16, next_dr_hi, rm[31:16], r[31:16],     data_size[2])

    wire [31:0] next_dr;
    assign next_dr = {next_dr_hi, next_dr_b1, next_dr_b0};

    // ---- Outputs ----
    // EAX_o = ~ZF ? next_EAX : EAX  (both then zero-extended to 64-bit)
    wire [31:0] eax_pre;
    `MUX_2(u_mux_eax, 32, eax_pre, next_EAX, EAX, cmp_ZF)
    assign EAX_o = {32'd0, eax_pre};

    // dr_o = ZF ? next_dr : rm
    wire [63:0] dr_pre;
    `MUX_2(u_mux_dr, 64, dr_pre, rm, {32'd0, next_dr}, cmp_ZF)
    assign dr_o    = dr_pre;
    assign res_buf = dr_pre;

    assign ZF = cmp_ZF;
    assign SF = cmp_SF;
    assign PF = cmp_PF;
    assign CF = cmp_CF;
    assign OF = cmp_OF;
    assign AF = cmp_AF;

endmodule
