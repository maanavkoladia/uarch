/* ================================================== */
/*                      INCLUDES                      */
/* ================================================== */

/* ================================================== */
/*            GLOBAL VARIABLE DEFINITIONS             */
/* ================================================== */

`define ANSI_COLOR_RESET "\x1b[0m"
`define ANSI_COLOR_RED "\x1b[31m"
`define ANSI_COLOR_GREEN "\x1b[32m"
`define ANSI_COLOR_YELLOW "\x1b[33m"
`define ANSI_COLOR_BLUE "\x1b[34m"
`define ANSI_COLOR_MAGENTA "\x1b[35m"
`define ANSI_COLOR_CYAN "\x1b[36m"
`define ANSI_COLOR_WHITE "\x1b[37m"

/* ================================================== */
/*            FUNCTION PROTOTYPES (DECLARATIONS)      */
/* ================================================== */


/* ================================================== */
/*                 FUNCTION DEFINITIONS               */
/* ================================================== */

`define DO_NOTHING always(*)begin end

`ifndef NDEBUG
`define LOG $display
`else
`define LOG `DO_NOTHING
`endif

`ifndef NDEBUG
`define LOG_SIMPLE(msg) $display(msg)
`else
`define LOG_SIMPLE(msg) `DO_NOTHING
`endif

