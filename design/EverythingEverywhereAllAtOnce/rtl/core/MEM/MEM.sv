import core_common_pkg::*;
import core_stage_latches_pkg::*;
import common_pkg::*;

module MEM (
    input wire clk,
    input wire rst,


    input mem_latches_t latches_i,

    //these are for valid bit shit and flushing
    input exe_outputs_t exe_outs_i,

    //only used for valid logic
    input wb_outputs_t wb_outs_i,

    //not sure if valid are needed, leaving for now
    //if not XCL, then wait for line_0 to hit, if XCL, wait for both line_0
    //and C1

    //from dcache
    input bool hit[NUM_DCACHE_PORTS],
    input byte_t cacheline[NUM_DCACHE_PORTS][CACHE_LINES_SIZE_B],

    input bool hit_MIO,
    input byte_t line_MIO[CACHE_LINES_SIZE_B],

    output exe_latches_t exe_latches_next_o,
    output mem_outputs_t outs_o
);
    //imteral buffers
    bool hit_buf_mio_v;
    byte_t hit_buf_mio[CACHE_LINES_SIZE_B];

    bool hit_buf_v[NUM_DCACHE_PORTS];
    byte_t hit_buf[NUM_DCACHE_PORTS][CACHE_LINES_SIZE_B];

    bool clr_dcache_arb_latches[NUM_DCACHE_PORTS];
    bool clr_dcache_mio_latch;

    byte_t ld_buf[EXE_BUFFER_SIZE];

    byte_t C0[CACHE_LINES_SIZE_B];
    byte_t up_buf[CACHE_LINES_SIZE_B];
    byte_t low_buf[CACHE_LINES_SIZE_B];

    bool miss_stall;

    bool exe_stage_we_valid_unit_o;
    bool exe_stage_next_vaild_o;
    bool forward_valid;

    p_address_t next_st_addr_0;
    p_address_t next_st_addr_1;
    bool next_xcl;

    logic [1:0] bank_num_0;
    logic [1:0] bank_num_1;


    l_address_t rel_offset;
    l_address_t br_rel_target;

    always_comb begin
        rel_offset = 32'd0;
        case(latches_i.exe_cs.branch_target_sel)
            ZEXT_IMM8: rel_offset = {24'd0, latches_i.imm64[7:0]};
            ZEXT_IMM16: rel_offset = {16'd0, latches_i.imm64[15:0]};
            IMM32: rel_offset = latches_i.imm64[31:0];
            default: rel_offset = 0;
        endcase

        br_rel_target = rel_offset + latches_i.NEIP;
    end


    assign forward_valid = exe_stage_we_valid_unit_o &
                           exe_stage_next_vaild_o;

    assign bank_num_0 = latches_i.LD_PADDR_0[$clog2(CACHE_LINES_SIZE_B) +: 2];
    assign bank_num_1 = latches_i.LD_PADDR_1[$clog2(CACHE_LINES_SIZE_B) +: 2];

    always_ff @(posedge clk) begin
        if(!rst)begin
            hit_buf_v <= '{default: '0};
            hit_buf_mio_v <= 0;
        end
        else if (forward_valid) begin
            hit_buf_v <= '{default: '0};
            hit_buf_mio_v <= 0;
        end
        else begin
            for(int i = 0; i < NUM_DCACHE_PORTS; i++)begin
                if(hit[i] && latches_i.valid)begin
                    hit_buf_v[i] <= 1;
                    hit_buf[i] <= cacheline[i];
                end
            end
            if(hit_MIO && latches_i.valid)begin
                hit_buf_mio_v <= 1;
                hit_buf_mio <= line_MIO;
            end
        end
    end


    byte_t line_in_0[CACHE_LINES_SIZE_B];
    assign line_in_0 = hit_buf_v[bank_num_0] ? hit_buf[bank_num_0] : cacheline[bank_num_0];

    byte_t line_in_1[CACHE_LINES_SIZE_B];
    assign line_in_1 = hit_buf_v[bank_num_1] ? hit_buf[bank_num_1] : cacheline[bank_num_1];

    byte_t line_in_mio[CACHE_LINES_SIZE_B];
    assign line_in_mio = hit_buf_mio_v ? hit_buf_mio : line_MIO;

    byte_t line_in_0_masked[CACHE_LINES_SIZE_B];
    assign line_in_0_masked = (latches_i.cs.LD_OP) ? line_in_0 : '{default: '0};

    byte_t line_in_1_masked[CACHE_LINES_SIZE_B];
    assign line_in_1_masked = (latches_i.LD_XCL) ? line_in_1 : '{default: '0};

    always_comb begin
        C0 = latches_i.MIO ? line_in_mio : line_in_0;
        up_buf = latches_i.swapLines ? line_in_0_masked : line_in_1_masked;
        low_buf = latches_i.swapLines ? line_in_1_masked : C0;
    end


    always_comb begin
        clr_dcache_arb_latches = '{default : '0};
        clr_dcache_mio_latch = 0;
        for(int i = 0; i < NUM_DCACHE_PORTS; i++)begin
            if(bank_num_0 == i && latches_i.cs.LD_OP && hit[i] && ~hit_buf_v[i] && latches_i.valid)begin
                clr_dcache_arb_latches[i] = 1;
            end
            if(bank_num_1 == i && latches_i.cs.LD_OP && latches_i.LD_XCL && hit[i] && ~hit_buf_v[i] && latches_i.valid)begin
                clr_dcache_arb_latches[i] = 1;
            end
        end
        if(latches_i.MIO && latches_i.cs.LD_OP && hit_MIO && ~hit_buf_mio_v && latches_i.valid)begin
            clr_dcache_mio_latch = 1;
        end
    end

    push_address_gen pus_addr_gen(
        .ST_PADDR_0(latches_i.ST_PADDR_0),
        .ST_PADDR_1(latches_i.ST_PADDR_1),
        .ST_XCL(latches_i.ST_XCL),
        .data_size_vec(latches_i.data_size_vec),
        .OP_TYPE(latches_i.data_size_vec),
        .ST_PADDR_0_o(next_st_addr_0),
        .ST_PADDR_1_o(next_st_addr_1),
        .ST_XCL_o(next_xcl)
    );



    mem_miss_stall_logic mem_stall (
        .valid(latches_i.valid),
        .LD_XCL(latches_i.LD_XCL),
        .LD_OP(latches_i.cs.LD_OP),
        .MIO(latches_i.MIO),
        .hits(hit), //from dcache
        .hit_MIO(hit_MIO), //from dcache

        .hit_buf_v(hit_buf_v), //from internal reg
        .hit_buf_mio_v(hit_buf_mio_v), //from internal reg
        .bank_num_0(bank_num_0),
        .bank_num_1(bank_num_1),
        .miss_stall(miss_stall)
    );


    EXE_valid_logic exe_valid_logic_unit (
        .EXE_we_o(exe_stage_we_valid_unit_o),
        .N_EXE_V_o(exe_stage_next_vaild_o),
        .MEM_V_i(latches_i.valid),
        .MEM_stall_i(miss_stall),
        .EXE_V_i(exe_outs_i.valid),
        .WB_stall_i(wb_outs_i.wb_stall)
    );

    always_comb begin
        ld_buf = '{default: '0};
        for (int i = 0; i < CACHE_LINES_SIZE_B; i++) begin
            ld_buf[i] = low_buf[i];
            ld_buf[i+CACHE_LINES_SIZE_B] = up_buf[i];
        end
        if(!forward_valid) ld_buf = '{default: '0};
    end


    assign exe_latches_next_o = '{
            valid: exe_stage_next_vaild_o,
            cs: latches_i.exe_cs,
            wb_cs: latches_i.wb_cs,
            data_size_vec: latches_i.data_size_vec,
            sr_data_size_vec : latches_i.sr_data_size_vec,
            shift_sr_up: latches_i.shift_sr_up,
            shift_sr_down: latches_i.shift_sr_down,
            ST_XCL: next_xcl,
            ST_PADDR_0: next_st_addr_0,
            ST_PADDR_1: next_st_addr_1,
            MIO: latches_i.MIO,
            br_info: latches_i.br_info,
            br_rel_target: br_rel_target,
            NEIP: latches_i.NEIP,
            EIP: latches_i.EIP,
            EAX: latches_i.EAX,
            imm64: latches_i.imm64,
            ld_buf: ld_buf,
            sr_id: latches_i.sr_id,
            sr_data: latches_i.sr_data,
            dr_id: latches_i.dr_id,
            dr_data: latches_i.dr_data,
            ld_addy: latches_i.LD_PADDR_0  //rn this I Think is cache unaligned. 
        };

    assign outs_o = '{
            valid: latches_i.valid,
            stall: miss_stall,
            ST_XCL: latches_i.ST_XCL,  //valid bit or second set of st info if st_op
            ST_PADDR_0: latches_i.ST_PADDR_0,  //cacheline unalgned, ie actual addr
            ST_PADDR_1: latches_i.ST_PADDR_1,  //cacheline algned
            ST_OP: latches_i.cs.ST_OP,
            exe_stage_latch_we: exe_stage_we_valid_unit_o,
            clr_dcache_arb_latches: clr_dcache_arb_latches,
            clr_dcache_mio_latch: clr_dcache_mio_latch
        };



endmodule
