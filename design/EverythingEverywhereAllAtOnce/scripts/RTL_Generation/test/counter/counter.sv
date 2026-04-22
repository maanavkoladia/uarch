module counter (
    input logic clk_i,
    input logic rst_i,  // active low

    input logic [9:0] interrupt_val_i,
    input logic interrupt_clr_i,
    output logic [9:0] timerVal_o,
    output logic interrupt_o
);

    logic [9:0] timerVal;
    logic interrupt_bit;
    logic conditionMet;

    assign timerVal_o   = timerVal;
    assign interrupt_o  = interrupt_bit;
    assign conditionMet = timerVal == interrupt_val_i;

    always_ff @(posedge clk_i) begin
        if (!rst_i) begin
            timerVal <= 0;
        end else begin
            timerVal <= timerVal + 1;
        end
    end

    always_ff @(posedge clk_i) begin
        if (!rst_i) begin
            interrupt_bit <= 0;
        end else if (conditionMet) begin
            interrupt_bit <= 1;
        end else if (interrupt_clr_i) begin
            interrupt_bit <= 0;
        end

    end

endmodule
