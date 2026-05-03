module ddr5 (
    input  wire clk,
    input  wire rst,
    input  wire newPowerGateValueFromCore_i,
    input  wire driveDataBus_i,
    inout       [`DATA_BUS_WIDTH_BITS    - 1 : 0] dataBus,
    inout       [`ADDRESS_BUS_WIDTH_BITS - 1 : 0] addrBus
);

    // powerGate must reset to 1, but REG_RST_WE only resets q->0.
    // Store the inverted value internally, invert d and q at the boundary:
    //   on rst:  powerGate_inv = 0  => powerGate = 1 (gated)
    //   on load: powerGate_inv = ~dataBus[0] => powerGate = dataBus[0]
    wire d_inv;
    wire powerGate_inv;
    wire powerGate;

    `INV_N(inv_d_pg, 1, dataBus[0], d_inv)
    `REG_RST_WE(ff_pg_inv, 1, clk, rst, newPowerGateValueFromCore_i, d_inv, powerGate_inv)
    `INV_N(inv_q_pg, 1, powerGate_inv, powerGate)

    // tempValue: load TEMP_VAL=3000 every cycle; reset to 0 when rst OR powerGate.
    // REG_RST_WE uses active-low reset, so temp_rst must go low when
    // rst is low (active reset) OR powerGate is high (gated).
    // temp_rst = rst & ~powerGate
    wire powerGate_bar;
    wire temp_rst;
    wire [31:0] tempValue;

    `INV_N(inv_pg_bar, 1, powerGate, powerGate_bar)
    `AND_2(and_temp_rst, 1, temp_rst, rst, powerGate_bar)
    `REG_RST_WE(ff_temp, 32, clk, temp_rst, 1'b1, 32'd3000, tempValue)

    // BUS_TRISTATE uses active-low enbar.
    wire drive_bar;

    `INV_N(inv_drv, 1, driveDataBus_i, drive_bar)
    `BUS_TRISTATE(u_drv, `DATA_BUS_WIDTH_BITS, drive_bar, tempValue, dataBus)

endmodule
