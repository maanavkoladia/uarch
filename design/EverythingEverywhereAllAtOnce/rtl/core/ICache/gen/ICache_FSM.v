module ICache_FSM (
    input wire clk,
    input wire reset,
    input wire hit_or_miss_i,
    input wire mem_valid_i,
    output wire mem_request_o,
    output wire fill0_o,
    output wire  fill1_o,
    output wire  fill2_o,
    output wire  fill3_o
);

    localparam STATE_SIZE = 3;

    wire [STATE_SIZE-1:0] state;
    wire [STATE_SIZE-1:0] nextstate;

    genvar i;
    generate
        for (i = 0; i < STATE_SIZE; i = i + 1) begin : state_regs
            reg1b ff (
                .clk(clk),
                .rst(reset),
                .d(nextstate[i]),
                .q(state[i])
            );
        end
    endgenerate

    // ROM address = {state, inputs}
    wire [4:0] rom_addr;
    assign rom_addr = {state, hit_or_miss_i, mem_valid_i};

    // ROM data = {nextstate, outputs}
    wire [7:0] rom_data;

    wire [31:0] ROM_0_out;
    rom32b32w$ ROM_0 (
        .A(rom_addr[4:0]),
        .OE(1'b1),
        .DOUT(ROM_0_out)
    );
    initial $readmemh("ICache_FSM_rom0_0.hex", ROM_0.mem);

    assign rom_data = ROM_0_out[7:0];

    // Extract nextstate and outputs from ROM data
    assign nextstate = rom_data[7:5];
    assign mem_request_o = rom_data[0];
    assign fill0_o = rom_data[1];
    assign  fill1_o = rom_data[2];
    assign  fill2_o = rom_data[3];
    assign  fill3_o = rom_data[4];

endmodule
