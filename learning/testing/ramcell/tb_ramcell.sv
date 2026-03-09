module tb_ramcell;

  reg  [2:0] A;
  reg  [7:0] DIN;
  reg        WR, OE;
  wire [7:0] DOUT;

  ram8b8w$ uut (
    .A(A), .DIN(DIN), .OE(OE), .WR(WR), .DOUT(DOUT)
  );

  initial begin
    // Init
    A = 0; DIN = 0; WR = 1; OE = 1;

    // --- Write 0xAB to address 3 ---
    #5;
    A   = 3'h3;
    DIN = 8'hAB;
    #1.5;          // satisfy addr_setup_time (1.4 max) before WR falls
    WR  = 0;
    #1.5;          // satisfy write_pulse_low  (1.4 max)
    WR  = 1;
    #2;            // satisfy write_pulse_high (1.4 max)


   for (int i = 0; i < 8; i = i + 1) begin
      A   = i[2:0];
      DIN = i * 8'h11;   // 0x00, 0x11, 0x22 ... 0x77
      #1.5;
      WR = 0;
      #1.5;
      WR = 1;
      #2;
      $display("[WRITE] addr=%0d  data=0x%02H  at time %0t", i, DIN, $time);
   end

    $display("[WRITE] Wrote 0xAB to addr 3 at time %0t", $time);
   for (int i = 0; i < 8; i = i + 1) begin
      A  = i[2:0];
      #2;
      OE = 0;
      #3;
      $display("[READ]  addr=%0d  DOUT=0x%02H  at time %0t", i, DOUT, $time);
      OE = 1;
      #4;
   end

    $finish;
  end

  // Optional waveform dump
  initial begin
    $vcdplusfile("ramcell.vcd");
    $vcdpluson(0, tb_ramcell);
  end

endmodule