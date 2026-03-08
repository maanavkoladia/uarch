`ifndef UTILS_V
`define UTILS_V

// ============================================================
// Exit control
// ============================================================

`ifndef NDEBUG
`define EXIT $finish
`else
`define EXIT `DO_NOTHING
`endif


// ============================================================
// Assertions and error checking
// ============================================================

`ifndef NDEBUG
`define ASSERT(cond, msg) \
    if (!(cond)) begin \
      `LOG("%sASSERT FAILED: %s%s", `ANSI_COLOR_RED, `ANSI_COLOR_WHITE, msg); \
      $fatal; \
    end
`else
`define ASSERT(cond, msg) `DO_NOTHING
`endif

`ifndef NDEBUG
`define ERR_CHECK(cond, TestName, errMsg) \
    if (cond) begin \
      `LOG("%sCHECK PASSED %s(%s)", `ANSI_COLOR_GREEN, `ANSI_COLOR_WHITE, TestName); \
    end else begin \
      `LOG("%sCHECK FAILED %s(%s): %s", `ANSI_COLOR_RED, `ANSI_COLOR_WHITE, TestName, errMsg); \
      $finish; \
    end
`else
`define ERR_CHECK(cond, TestName, msg) `DO_NOTHING
`endif


// ============================================================
// Waveform generation
// ============================================================

`define GEN_WAVEFORM_VCD(filename, moduleName, lvl) \
initial begin \
  $dumpfile(filename); \
  $dumpvars(lvl, moduleName); \
end

`define GEN_WAVEFORM_VPD(filename) \
initial begin \
  $vcdplusfile(filename); \
  $vcdpluson(0); \
end

// ============================================================
// Timing helpers
// ============================================================
`define TRUE (1'b1)
`define FALSE (1'b0)

// ============================================================
// Timing helpers
// ============================================================

`define DELAY(time) #(time)

`define CLK_INIT(cycleTicks) \
  logic clk = 0; \
  always begin \
    `DELAY(cycleTicks/2); \
    clk = ~clk; \
  end

`define CLOCK_DELAY(clkCycles, cycleTicks) `DELAY(clkCycles * cycleTicks)

`endif  // UTILS_V
