 `ifndef STD_CELL_MACROS_VH
`define STD_CELL_MACROS_VH

`define INV_N(__unitName__, __width__, __in__, __out__) \
    inv_N$ #(.WIDTH(__width__)) __unitName__ ( .in(__in__), .out(__out__) );

`define XOR_2(__unitName__, __width__, __out__, __in0__, __in1__) \
    MPS_XOR_IN2 #(.WIDTH(__width__)) __unitName__ (.out(__out__), .in0(__in0__), .in1(__in1__));


`define AND_2(__unitName__, __width__, __out__, __in0__, __in1__) \
    and2_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__) );
`define AND_3(__unitName__, __width__, __out__, __in0__, __in1__, __in2__) \
    and3_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__) );
`define AND_4(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__) \
    and4_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__) );
`define AND_5(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__) \
    and5_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), .in4(__in4__) );
`define AND_6(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__) \
    and6_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), .in4(__in4__), .in5(__in5__) );
`define AND_7(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__, __in6__) \
    and7_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), .in4(__in4__), .in5(__in5__), .in6(__in6__) );
`define AND_8(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__, __in6__, __in7__) \
    and8_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), .in4(__in4__), .in5(__in5__), .in6(__in6__), .in7(__in7__) );
`define AND_9(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__, __in6__, __in7__, __in8__) \
    and9_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), .in4(__in4__), .in5(__in5__), .in6(__in6__), .in7(__in7__), .in8(__in8__) );
`define AND_10(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__, __in6__, __in7__, __in8__, __in9__) \
    and10_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), .in4(__in4__), .in5(__in5__), .in6(__in6__), .in7(__in7__), .in8(__in8__), .in9(__in9__) );
`define AND_11(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__, __in6__, __in7__, __in8__, __in9__, __in10__) \
    and11_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), .in4(__in4__), .in5(__in5__), .in6(__in6__), .in7(__in7__), .in8(__in8__), .in9(__in9__), .in10(__in10__) );
`define AND_12(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__, __in6__, __in7__, __in8__, __in9__, __in10__, __in11__) \
    and12_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), .in4(__in4__), .in5(__in5__), .in6(__in6__), .in7(__in7__), .in8(__in8__), .in9(__in9__), .in10(__in10__), .in11(__in11__) );



/* ---------------- OR_2 to OR_12 macros ---------------- */

`define OR_2(__unitName__, __width__, __out__, __in0__, __in1__) \
    or2_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__) );

`define OR_3(__unitName__, __width__, __out__, __in0__, __in1__, __in2__) \
    or3_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__) );

`define OR_4(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__) \
    or4_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__) );

`define OR_5(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__) \
    or5_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), .in4(__in4__) );

`define OR_6(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__) \
    or6_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), .in4(__in4__), .in5(__in5__) );

`define OR_7(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__, __in6__) \
    or7_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), .in4(__in4__), .in5(__in5__), .in6(__in6__) );

`define OR_8(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__, __in6__, __in7__) \
    or8_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), .in4(__in4__), .in5(__in5__), .in6(__in6__), .in7(__in7__) );

`define OR_9(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__, __in6__, __in7__, __in8__) \
    or9_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), .in4(__in4__), .in5(__in5__), .in6(__in6__), .in7(__in7__), .in8(__in8__) );

`define OR_10(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__, __in6__, __in7__, __in8__, __in9__) \
    or10_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), .in4(__in4__), .in5(__in5__), .in6(__in6__), .in7(__in7__), .in8(__in8__), .in9(__in9__) );

`define OR_11(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__, __in6__, __in7__, __in8__, __in9__, __in10__) \
    or11_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), .in4(__in4__), .in5(__in5__), .in6(__in6__), .in7(__in7__), .in8(__in8__), .in9(__in9__), .in10(__in10__) );

`define OR_12(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__, __in6__, __in7__, __in8__, __in9__, __in10__, __in11__) \
    or12_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), .in4(__in4__), .in5(__in5__), .in6(__in6__), .in7(__in7__), .in8(__in8__), .in9(__in9__), .in10(__in10__), .in11(__in11__) );



`define NAND_2(__unitName__, __width__, __out__, __in0__, __in1__) \
    nand2_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__) );
`define NAND_3(__unitName__, __width__, __out__, __in0__, __in1__, __in2__) \
    nand3_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__) );
`define NAND_4(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__) \
    nand4_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__) );

`define NOR_2(__unitName__, __width__, __out__, __in0__, __in1__) \
    nor2_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__) );

`define NOR_3(__unitName__, __width__, __out__, __in0__, __in1__, __in2__) \
    nor3_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__) );

`define NOR_4(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__) \
    nor4_N$ #(.WIDTH(__width__)) __unitName__ ( .out(__out__), .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__) );


///////////////////////muxes/////////////////////////////
`define MUX_2(__unitName__, __width__, __out__, __in0__, __in1__, __sel__) \
    mux2_N #(.WIDTH(__width__)) __unitName__ ( \
        .out(__out__), \
        .in0(__in0__), \
        .in1(__in1__), \
        .sel(__sel__) \
    );

`define MUX_2_H8(__unitName__, __width__, __out__, __in0__, __in1__, __sel0__, __sel1__) \
    mux2_N_H8 #(.WIDTH(__width__)) __unitName__ ( \
        .out(__out__), \
        .in0(__in0__), \
        .in1(__in1__), \
        .sel0(__sel0__), \
        .sel1(__sel1__) \
    );

`define MUX_3(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __sel__) \
    mux3_N #(.WIDTH(__width__)) __unitName__ ( \
        .out(__out__), \
        .in0(__in0__), \
        .in1(__in1__), \
        .in2(__in2__), \
        .sel(__sel__) \
    );

`define MUX_4(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __sel__) \
    mux4_N #(.WIDTH(__width__)) __unitName__ ( \
        .out(__out__), \
        .in0(__in0__), \
        .in1(__in1__), \
        .in2(__in2__), \
        .in3(__in3__), \
        .sel(__sel__) \
    );

`define MUX_4_H8(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __sel0__, __sel1__) \
    mux4_N_H8 #(.WIDTH(__width__)) __unitName__ ( \
        .out(__out__), \
        .in0(__in0__), \
        .in1(__in1__), \
        .in2(__in2__), \
        .in3(__in3__), \
        .sel0(__sel0__), \
        .sel1(__sel1__) \
    );

`define MUX_8(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__, __in6__, __in7__, __sel__) \
    mux8_N #(.WIDTH(__width__)) __unitName__ ( \
        .out(__out__), \
        .in0(__in0__), \
        .in1(__in1__), \
        .in2(__in2__), \
        .in3(__in3__), \
        .in4(__in4__), \
        .in5(__in5__), \
        .in6(__in6__), \
        .in7(__in7__), \
        .sel(__sel__) \
    );

`define MUX_8_H8(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__, __in6__, __in7__, __sel0__, __sel1__) \
    mux8_N_H8 #(.WIDTH(__width__)) __unitName__ ( \
        .out(__out__), \
        .in0(__in0__), \
        .in1(__in1__), \
        .in2(__in2__), \
        .in3(__in3__), \
        .in4(__in4__), \
        .in5(__in5__), \
        .in6(__in6__), \
        .in7(__in7__), \
        .sel0(__sel0__), \
        .sel1(__sel1__) \
    );

`define MUX_16(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__, __in6__, __in7__, __in8__, __in9__, __in10__, __in11__, __in12__, __in13__, __in14__, __in15__, __sel__) \
    mux16_N #(.WIDTH(__width__)) __unitName__ ( \
        .out(__out__), \
        .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), \
        .in4(__in4__), .in5(__in5__), .in6(__in6__), .in7(__in7__), \
        .in8(__in8__), .in9(__in9__), .in10(__in10__), .in11(__in11__), \
        .in12(__in12__), .in13(__in13__), .in14(__in14__), .in15(__in15__), \
        .sel(__sel__) \
    );

`define MUX_16_H32(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__, __in6__, __in7__, __in8__, __in9__, __in10__, __in11__, __in12__, __in13__, __in14__, __in15__, __sel0__, __sel1__, __sel2__, __sel3__, __sel4__, __sel5__, __sel6__, __sel7__) \
    mux16_N_H32 #(.WIDTH(__width__)) __unitName__ ( \
        .out(__out__), \
        .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), \
        .in4(__in4__), .in5(__in5__), .in6(__in6__), .in7(__in7__), \
        .in8(__in8__), .in9(__in9__), .in10(__in10__), .in11(__in11__), \
        .in12(__in12__), .in13(__in13__), .in14(__in14__), .in15(__in15__), \
        .sel0(__sel0__), .sel1(__sel1__), \
        .sel2(__sel2__), .sel3(__sel3__), \
        .sel4(__sel4__), .sel5(__sel5__), \
        .sel6(__sel6__), .sel7(__sel7__) \
    );

`define MUX_32(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__, __in6__, __in7__, __in8__, __in9__, __in10__, __in11__, __in12__, __in13__, __in14__, __in15__, __in16__, __in17__, __in18__, __in19__, __in20__, __in21__, __in22__, __in23__, __in24__, __in25__, __in26__, __in27__, __in28__, __in29__, __in30__, __in31__, __sel__) \
    mux32_N #(.WIDTH(__width__)) __unitName__ ( \
        .out(__out__), \
        .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), \
        .in4(__in4__), .in5(__in5__), .in6(__in6__), .in7(__in7__), \
        .in8(__in8__), .in9(__in9__), .in10(__in10__), .in11(__in11__), \
        .in12(__in12__), .in13(__in13__), .in14(__in14__), .in15(__in15__), \
        .in16(__in16__), .in17(__in17__), .in18(__in18__), .in19(__in19__), \
        .in20(__in20__), .in21(__in21__), .in22(__in22__), .in23(__in23__), \
        .in24(__in24__), .in25(__in25__), .in26(__in26__), .in27(__in27__), \
        .in28(__in28__), .in29(__in29__), .in30(__in30__), .in31(__in31__), \
        .sel(__sel__) \
    );

`define MUX_64(__unitName__, __width__, __out__, __in0__, __in1__, __in2__, __in3__, __in4__, __in5__, __in6__, __in7__, __in8__, __in9__, __in10__, __in11__, __in12__, __in13__, __in14__, __in15__, __in16__, __in17__, __in18__, __in19__, __in20__, __in21__, __in22__, __in23__, __in24__, __in25__, __in26__, __in27__, __in28__, __in29__, __in30__, __in31__, __in32__, __in33__, __in34__, __in35__, __in36__, __in37__, __in38__, __in39__, __in40__, __in41__, __in42__, __in43__, __in44__, __in45__, __in46__, __in47__, __in48__, __in49__, __in50__, __in51__, __in52__, __in53__, __in54__, __in55__, __in56__, __in57__, __in58__, __in59__, __in60__, __in61__, __in62__, __in63__, __sel__) \
    mux64_N #(.WIDTH(__width__)) __unitName__ ( \
        .out(__out__), \
        .in0(__in0__), .in1(__in1__), .in2(__in2__), .in3(__in3__), \
        .in4(__in4__), .in5(__in5__), .in6(__in6__), .in7(__in7__), \
        .in8(__in8__), .in9(__in9__), .in10(__in10__), .in11(__in11__), \
        .in12(__in12__), .in13(__in13__), .in14(__in14__), .in15(__in15__), \
        .in16(__in16__), .in17(__in17__), .in18(__in18__), .in19(__in19__), \
        .in20(__in20__), .in21(__in21__), .in22(__in22__), .in23(__in23__), \
        .in24(__in24__), .in25(__in25__), .in26(__in26__), .in27(__in27__), \
        .in28(__in28__), .in29(__in29__), .in30(__in30__), .in31(__in31__), \
        .in32(__in32__), .in33(__in33__), .in34(__in34__), .in35(__in35__), \
        .in36(__in36__), .in37(__in37__), .in38(__in38__), .in39(__in39__), \
        .in40(__in40__), .in41(__in41__), .in42(__in42__), .in43(__in43__), \
        .in44(__in44__), .in45(__in45__), .in46(__in46__), .in47(__in47__), \
        .in48(__in48__), .in49(__in49__), .in50(__in50__), .in51(__in51__), \
        .in52(__in52__), .in53(__in53__), .in54(__in54__), .in55(__in55__), \
        .in56(__in56__), .in57(__in57__), .in58(__in58__), .in59(__in59__), \
        .in60(__in60__), .in61(__in61__), .in62(__in62__), .in63(__in63__), \
        .sel(__sel__) \
    );

//////////////////// EQ COMPARE ////////////////////

`define CMP_N(__unitName__, __width__, __out__, __in0__, __in1__) \
    MPS_COMP_EQ #(.WIDTH(__width__)) __unitName__ ( \
        .in0(__in0__), \
        .in1(__in1__), \
        .eq(__out__) \
    );

//////////////////// ADD (Kogge-Stone) ////////////////////

`define ADD_N(__unitName__, __width__, __sum__, __cout__, __in0__, __in1__, __cin__) \
    kogge_stone_adder #(.WIDTH(__width__)) __unitName__ ( \
        .a(__in0__), \
        .b(__in1__), \
        .cin(__cin__), \
        .sum(__sum__), \
        .cout(__cout__) \
    );

//////////////////// BUFFER DELAY ////////////////////

//stages are .25 ns timeunits each
`define BUFFER_DELAY(__unitName__, __stages__, __width__, __in__, __out__) \
    MPS_buffer_delay$ #(.STAGES(__stages__), .WIDTH(__width__)) __unitName__ ( \
        .in(__in__), \
        .out(__out__) \
    );

//////////////////// TRISTATE ////////////////////

`define TRISTATE_L(__unitName__, __width__, __enbar__, __in__, __out__) \
    MPS_tristateL #(.WIDTH(__width__)) __unitName__ ( \
        .enbar(__enbar__), \
        .in(__in__), \
        .out(__out__) \
    );


`define BUS_TRISTATE(__unitName__, __width__, __enbar__, __in__, __out__) \
    MPS_bus_tristate #(.WIDTH(__width__)) __unitName__ ( \
        .enbar(__enbar__), \
        .in(__in__), \
        .out(__out__) \
    );

//////////////////// DECODER ////////////////////

`define DECODER_N(__unitName__, __inputs__, __in__, __out__) \
    MPS_decoder$ #(.INPUTS(__inputs__)) __unitName__ ( \
        .in(__in__), \
        .out(__out__) \
    );

//////////////////// REG WITH WE ////////////////////
//active low rst, do not use signals other than rst for the rst input, this is
//async rst
`define REG_RST_WE(__unitName__, __width__, __clk__, __rst__, __we__, __din__, __dout__) \
    MPS_reg_rst_we$ #(.WIDTH(__width__)) __unitName__ ( \
        .clk(__clk__), \
        .rst(__rst__), \
        .we(__we__), \
        .d(__din__), \
        .q(__dout__) \
    );

//////////////////// REG ALWAYS ENABLED ////////////////////

//active low rst
`define REG_RST(__unitName__, __width__, __clk__, __rst__, __din__, __dout__) \
    MPS_reg_rst_we$ #(.WIDTH(__width__)) __unitName__ ( \
        .clk(__clk__), \
        .rst(__rst__), \
        .we(1'b1), \
        .d(__din__), \
        .q(__dout__) \
    );

//ROMS
`define ROM_32W_64b(__unitName__, __ADDR__, __OE__, __dout__) \
    rom64b32w$ __unitName__ ( \
        .A(__ADDR__), \
        .OE(__OE__), \
        .DOUT(__dout__) \
    );

`endif

