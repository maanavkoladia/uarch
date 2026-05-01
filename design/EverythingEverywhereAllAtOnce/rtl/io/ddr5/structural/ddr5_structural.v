module ddr5 (
    input  wire clk,
    input  wire rst,
    input  wire newPowerGateValueFromCore_i,
    input  wire driveDataBus_i,
    inout       [`DATA_BUS_WIDTH_BITS    - 1 : 0] dataBus,
    inout       [`ADDRESS_BUS_WIDTH_BITS - 1 : 0] addrBus
);

    // rst is active-low; REG_RST_WE expects active-high.
    wire rst_inv;
    `INV_N(inv_rst, 1, rst, rst_inv)

    // powerGate must reset to 1, but REG_RST_WE only resets q->0.
    // Store the inverted value internally, invert d and q at the boundary:
    //   on rst:  powerGate_inv = 0  => powerGate = 1 (gated)
    //   on load: powerGate_inv = ~dataBus[0] => powerGate = dataBus[0]
    wire d_inv;
    wire powerGate_inv;
    wire powerGate;
    `INV_N(inv_d_pg, 1, dataBus[0], d_inv)
    `REG_RST_WE(ff_pg_inv, 1, clk, rst_inv, newPowerGateValueFromCore_i, d_inv, powerGate_inv)
    `INV_N(inv_q_pg, 1, powerGate_inv, powerGate)

    // tempValue: load TEMP_VAL=3000 every cycle; reset to 0 when rst OR powerGate.
    wire temp_rst;
    wire [31:0] tempValue;
    `OR_2(or_temp_rst, 1, temp_rst, rst_inv, powerGate)
    `REG_RST_WE(ff_temp, 32, clk, temp_rst, 1'b1, 32'd3000, tempValue)

    // BUS_TRISTATE uses active-low enbar.
    wire drive_bar;
    `INV_N(inv_drv, 1, driveDataBus_i, drive_bar)
    `BUS_TRISTATE(u_drv, `DATA_BUS_WIDTH_BITS, drive_bar, tempValue, dataBus)

endmodule

`default_nettype wire
