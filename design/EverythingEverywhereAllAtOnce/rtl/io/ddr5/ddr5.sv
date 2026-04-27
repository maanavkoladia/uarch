import common_pkg::*;
import interconnect_pkg::*;
import io_common_pkg::*;

module ddr5 (
    input wire clk,
    input wire rst,  //active low

    input dte_2_ddr5_t inFromDTE_i,

    inout [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus,
    inout [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addrBus

);
    //0x0040 DDR5: write power gating 1 bit 32 bit though
    //0x0050 DDR5: ld temperature value
    //todo, need to add assert to make sure that tht address on the bus form the
    //core is correct

    uint32_t tempValue;

    //not that it matters, 1 means that it is gated (not gettig pwoer), 0 mean power
    bool powerGate;
    //
    always_ff @(posedge clk) begin
        if (!rst || powerGate) tempValue <= 0;
        else tempValue <= TEMP_VAL;
    end

    always_ff @(posedge clk) begin
        if (!rst) powerGate <= 1;
        else if (inFromDTE_i.newPowerGateValueFromCore)
            powerGate <= dataBus[0];  //get new value from bus
    end

    //drive the bus
    logic [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus_fake;
    assign #5 dataBus = inFromDTE_i.driveDataBus ? dataBus_fake : 'z;
    assign dataBus_fake = tempValue;

endmodule
